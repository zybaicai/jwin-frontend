<script setup lang="ts">
import { computed, onBeforeUnmount, ref, watch } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { View, Delete, EditPen, User } from '@element-plus/icons-vue'
import { ElMessageBox } from 'element-plus'

import AppEmpty from '@/components/common/AppEmpty.vue'
import AppError from '@/components/common/AppError.vue'
import SaleCustomerSelector from '@/components/sale/SaleCustomerSelector.vue'
import CashierHandlerEditor, {
  type HandlerDraftRow,
} from '@/components/sale/CashierHandlerEditor.vue'
import CashierPriceAdjustDialog from '@/components/sale/CashierPriceAdjustDialog.vue'
import CashierSettleDialog, {
  type SettleConfirmPayload,
  type SettleLineOption,
} from '@/components/sale/CashierSettleDialog.vue'
import SaleOrderResultDialog from '@/components/sale/SaleOrderResultDialog.vue'
import TreatOrderResultDialog from '@/components/sale/TreatOrderResultDialog.vue'
import SavingConsumeProjectDialog from '@/components/sale/SavingConsumeProjectDialog.vue'
import CustomerDetailDrawer from '@/views/customer/CustomerDetailDrawer.vue'
import { maskMobile } from '@/views/customer/customer-format'
import { fetchCustomerDetail, fetchCustomerPage } from '@/api/customer'
import { fetchGoodsList } from '@/api/catalog'
import { fetchSaleChannelOptions } from '@/api/sale-channel'
import { fetchPriceQuote } from '@/api/price'
import { fetchProjectCategoryTree, fetchProjectPage } from '@/api/project'
import {
  fetchCardCategoryOptions,
  fetchGeneralCardDetail,
  fetchTimeCardDetail,
} from '@/api/card'
import { fetchProductCategoryOptions } from '@/api/product'
import {
  createSaleOrder,
  fetchSaleOrderDetail,
  paySaleOrder,
} from '@/api/sale'
import {
  createTreatOrder,
  fetchCustomerAvailableAssets,
  fetchTreatConfig,
  fetchTreatOrderDetail,
} from '@/api/treat'
import {
  SALE_CASHIER_LAST_ORDER_KEY,
  buildCreateSaleOrderRequest,
  getSaleCheckoutBlockReason,
  mapSaleCheckoutBlockMessage,
} from '@/views/sale/saleCashierOrder'
import {
  TREAT_CASHIER_LAST_ORDER_KEY,
  buildCreateTreatOrderRequest,
  getTreatCheckoutBlockReason,
  mapTreatCheckoutBlockMessage,
  treatLinesNeedCardSign,
} from '@/views/sale/treatCashierOrder'
import type { CatalogItemType, GoodsItem } from '@/types/catalog'
import type { CustomerDetail, CustomerListItem } from '@/types/customer'
import type { CardCategoryKind } from '@/types/card'
import type { ProjectCategoryTreeNode } from '@/types/project'
import type { SaleChannelOption } from '@/types/sale-channel'
import type { PriceQuote } from '@/types/price'
import type { CreateSaleOrderRequest, SaleOrderDetail } from '@/types/sale'
import { SalePermission } from '@/types/sale'
import { PricePermission } from '@/types/price'
import { HandlerSaleBizTypes, HandlerTreatBizTypes } from '@/types/handler'
import {
  TreatPermission,
  TreatItemType,
  type CustomerAvailableAssets,
  type TreatGeneralCardAsset,
  type TreatOrderDetail,
  type TreatPackageAsset,
  type TreatProjectAsset,
  type TreatSavingAsset,
  type TreatTimeCardAsset,
} from '@/types/treat'
import { CustomerPermission } from '@/types/customer'
import { CatalogPermission } from '@/types/catalog'
import { SaleChannelPermission } from '@/types/sale-channel'
import { ProjectPermission } from '@/types/project'
import { usePermissionStore } from '@/stores/permission'
import { useStoreStore } from '@/stores/store'
import { formatAmountDisplay } from '@/utils/amount'
import { getUserFriendlyErrorMessage, runExclusive, uiMessage } from '@/utils/ui'

defineOptions({ name: 'SalesCashierView' })

type WorkbenchMode = 'sale' | 'consume'
type CustomerContextStatus = 'none' | 'invalid' | 'loading' | 'ready' | 'error'

interface SaleLineDraft {
  key: string
  itemType: CatalogItemType | string
  itemId: number
  name: string
  quantity: number
  price: string | number | null
  quotePrice: string | number | null
  allowAdjust: boolean
  minPrice: string | number | null
  priceChangeReason: string | null
  gift: boolean
  /** 仅 PROJECT；加入时取左侧渠道筛选 */
  saleChannelId: number | null
  saleChannelName: string | null
  /** 行欠尾款；产品强制 0 */
  arrearAmount: number
  /** 储值卡赠金（显式） */
  largessAmount: number
  /** 本行储值抵扣（开单明细指定） */
  savingAccountId: number | null
  savingPrincipalAmount: number
  savingBonusAmount: number
  handlers: HandlerDraftRow[]
  categoryName: string | null
  status: string
}

interface ConsumeLineDraft {
  key: string
  itemType: string
  accountId: number
  projectId: number | null
  name: string
  assetName: string
  quantity: number
  remainText: string
  fundSource: 'principal' | 'bonus' | null
  /** 展示用参考价；储值扣款以后端为准，此处可为空 */
  amountHint: string | number | null
  amountHintLabel: string
  status: string
}

interface AssetListRow {
  key: string
  kind: 'PROJECT' | 'PRODUCT' | 'SAVING_CARD' | 'GENERAL_CARD' | 'TIME_CARD' | 'PACKAGE_CARD'
  name: string
  codeText: string
  remainText: string
  validDate: string | null
  canUse: boolean
  raw:
    | TreatProjectAsset
    | TreatSavingAsset
    | TreatGeneralCardAsset
    | TreatTimeCardAsset
    | TreatPackageAsset
}

const ITEM_TYPE_OPTIONS: Array<{ value: string; label: string }> = [
  { value: '', label: '全部' },
  { value: 'PROJECT', label: '项目' },
  { value: 'PRODUCT', label: '产品' },
  { value: 'GENERAL_CARD', label: '通用次卡' },
  { value: 'TIME_CARD', label: '时效卡' },
  { value: 'SAVING_CARD', label: '储值卡' },
  { value: 'PACKAGE_CARD', label: '套餐卡' },
]

const TOP_ACTIONS = [
  { key: 'pickup', label: '取单', enabled: false },
  { key: 'sale', label: '开单', enabled: true },
  { key: 'openCard', label: '开卡', enabled: false },
  { key: 'recharge', label: '充值', enabled: false },
  { key: 'consume', label: '消耗', enabled: true },
  { key: 'arrear', label: '补欠款', enabled: false },
] as const

const CARD_PURCHASE_TYPES = new Set(['GENERAL_CARD', 'TIME_CARD', 'PACKAGE_CARD', 'SAVING_CARD'])

const route = useRoute()
const router = useRouter()
const permissionStore = usePermissionStore()
const storeStore = useStoreStore()

const mode = ref<WorkbenchMode>('sale')
const customerLoading = ref(false)
const customerError = ref<string | null>(null)
const customer = ref<CustomerDetail | null>(null)
const selectorVisible = ref(false)

const customerKeyword = ref('')
const customerSearching = ref(false)
const customerSearchLoadingMore = ref(false)
const customerSearchResults = ref<CustomerListItem[]>([])
const customerDropdownVisible = ref(false)
const customerSearchPage = ref(1)
const customerSearchHasMore = ref(false)
const CUSTOMER_SEARCH_PAGE_SIZE = 10
let customerSearchTimer: ReturnType<typeof setTimeout> | null = null
let customerSearchSeq = 0
const detailDrawerVisible = ref(false)

const goodsLoading = ref(false)
const goodsError = ref<string | null>(null)
const goodsKeyword = ref('')
let goodsSearchTimer: ReturnType<typeof setTimeout> | null = null
const goodsItemType = ref('')
const goodsList = ref<GoodsItem[]>([])
const channelOptions = ref<SaleChannelOption[]>([])
const saleChannelId = ref<number | null>(null)
const categoryTree = ref<ProjectCategoryTreeNode[]>([])
const selectedL1CategoryId = ref<number | null>(null)
const selectedL2CategoryId = ref<number | null>(null)
const categoryProjectIds = ref<Set<number> | null>(null)
/** 产品/卡类：扁平分类（无渠道） */
const flatCategories = ref<Array<{ id: number; name: string }>>([])
const selectedFlatCategoryId = ref<number | null>(null)
const catalogPage = ref(1)
const catalogPageSize = 20
const orderInfoExpanded = ref(false)

const saleLines = ref<SaleLineDraft[]>([])
const consumeLines = ref<ConsumeLineDraft[]>([])
/** 整单统一经手人（底部展开）；写入各明细 */
const handlers = ref<HandlerDraftRow[]>([])
const handlerEditorRef = ref<InstanceType<typeof CashierHandlerEditor> | null>(null)

const backdateEnabled = ref(false)
const billDate = ref(formatToday())

const assetsLoading = ref(false)
const assetsError = ref<string | null>(null)
const assets = ref<CustomerAvailableAssets | null>(null)
const assetFilter = ref('')
const assetKeyword = ref('')

const savingDialogVisible = ref(false)
const savingDialogAsset = ref<TreatSavingAsset | null>(null)

const adjustVisible = ref(false)
const adjustTargetKey = ref<string | null>(null)

const settleVisible = ref(false)
const settleSubmitting = ref(false)
const payExistingOrderId = ref<string | null>(null)
const resultVisible = ref(false)
const resultLoading = ref(false)
const currentOrder = ref<SaleOrderDetail | null>(null)
const postPayAssets = ref<CustomerAvailableAssets | null>(null)
const postPayAssetsNote = ref<string | null>(null)

const treatSubmitting = ref(false)
const treatResultVisible = ref(false)
const treatResultLoading = ref(false)
const currentTreatOrder = ref<TreatOrderDetail | null>(null)
const postTreatAssets = ref<CustomerAvailableAssets | null>(null)

const hasSaleCreate = computed(() =>
  permissionStore.hasPermission(SalePermission.ORDER_CREATE),
)
const hasSaleView = computed(() =>
  permissionStore.hasPermission(SalePermission.ORDER_VIEW),
)
const hasSalePay = computed(() =>
  permissionStore.hasPermission(SalePermission.ORDER_PAY),
)
const hasSaleBackdate = computed(() =>
  permissionStore.hasPermission(SalePermission.ORDER_BACKDATE),
)
const hasTreatView = computed(() =>
  permissionStore.hasPermission(TreatPermission.ORDER_VIEW),
)
const hasTreatCreate = computed(() =>
  permissionStore.hasPermission(TreatPermission.ORDER_CREATE),
)
const hasTreatBackdate = computed(() =>
  permissionStore.hasPermission(TreatPermission.ORDER_BACKDATE),
)
const hasCatalogView = computed(() =>
  permissionStore.hasPermission(CatalogPermission.VIEW),
)
const hasChannelView = computed(() =>
  permissionStore.hasPermission(SaleChannelPermission.VIEW),
)
const hasPriceQuote = computed(() =>
  permissionStore.hasPermission(PricePermission.QUOTE),
)
const hasPriceChange = computed(() =>
  permissionStore.hasPermission(PricePermission.CHANGE),
)
const hasCustomerList = computed(() =>
  permissionStore.hasPermission(CustomerPermission.LIST_VIEW),
)
const hasCategoryView = computed(() =>
  permissionStore.hasPermission(ProjectPermission.CATEGORY_VIEW),
)

const currentStoreId = computed(() => storeStore.currentStoreId)

const canEnterWorkbench = computed(
  () => hasSaleCreate.value || hasTreatView.value || hasTreatCreate.value,
)

function parseCustomerIdQuery(raw: unknown): number | null | 'invalid' {
  if (raw == null || raw === '') {
    return null
  }
  const text = Array.isArray(raw) ? String(raw[0] ?? '') : String(raw)
  const trimmed = text.trim()
  if (trimmed === '') {
    return null
  }
  if (!/^\d+$/.test(trimmed)) {
    return 'invalid'
  }
  const id = Number(trimmed)
  if (!Number.isSafeInteger(id) || id <= 0) {
    return 'invalid'
  }
  return id
}

const resolvedCustomerId = computed(() => parseCustomerIdQuery(route.query.customerId))

const contextStatus = computed<CustomerContextStatus>(() => {
  if (resolvedCustomerId.value === 'invalid') {
    return 'invalid'
  }
  if (resolvedCustomerId.value == null) {
    return 'none'
  }
  if (customerLoading.value) {
    return 'loading'
  }
  if (customerError.value) {
    return 'error'
  }
  if (customer.value != null) {
    return 'ready'
  }
  return 'loading'
})

const customerReady = computed(() => contextStatus.value === 'ready' && customer.value != null)

const modeLabel = computed(() => (mode.value === 'sale' ? '销售单' : '消耗单'))

const selectedChannel = computed(
  () => channelOptions.value.find((c) => c.id === saleChannelId.value) ?? null,
)

/** 结账摘要：仅汇总项目明细渠道；纯卡/产品显示 — */
const settleChannelSummary = computed(() => {
  if (payExistingOrderId.value && currentOrder.value) {
    const codes = (currentOrder.value.items || [])
      .filter((it) => String(it.itemType || '').toUpperCase() === 'PROJECT')
      .map((it) => it.saleChannelCode?.trim() || null)
      .filter((c): c is string => !!c)
    const uniq = [...new Set(codes)]
    if (uniq.length === 0) return null
    if (uniq.length === 1) return uniq[0]!
    return uniq.join(' / ')
  }
  const names = saleLines.value
    .filter((l) => l.itemType === 'PROJECT')
    .map((l) => l.saleChannelName?.trim() || null)
    .filter((n): n is string => !!n)
  const uniq = [...new Set(names)]
  if (uniq.length === 0) return null
  if (uniq.length === 1) return uniq[0]!
  return uniq.join(' / ')
})

/** 仅「项目」展示销售渠道列；其它类型只按分类层级选品 */
const showChannelColumn = computed(() => goodsItemType.value === 'PROJECT')

const showProjectCategoryColumns = computed(
  () => goodsItemType.value === 'PROJECT' || goodsItemType.value === '',
)

const showFlatCategoryColumns = computed(() => {
  const t = goodsItemType.value
  return (
    t === 'PRODUCT' ||
    t === 'GENERAL_CARD' ||
    t === 'TIME_CARD' ||
    t === 'SAVING_CARD' ||
    t === 'PACKAGE_CARD'
  )
})

const filteredGoods = computed(() => {
  let list = goodsList.value
  if (goodsItemType.value) {
    list = list.filter((g) => g.itemType === goodsItemType.value)
  }
  if (
    showProjectCategoryColumns.value &&
    categoryProjectIds.value != null &&
    (goodsItemType.value === 'PROJECT' || !goodsItemType.value)
  ) {
    list = list.filter((g) => {
      if (g.itemType !== 'PROJECT') {
        return !goodsItemType.value
      }
      return g.itemId != null && categoryProjectIds.value!.has(g.itemId)
    })
  }
  if (showFlatCategoryColumns.value && selectedFlatCategoryId.value != null) {
    const hit = flatCategories.value.find((c) => c.id === selectedFlatCategoryId.value)
    const name = hit?.name?.trim()
    if (name) {
      list = list.filter((g) => (g.categoryName || '').trim() === name)
    }
  }
  return list
})

const assetRows = computed((): AssetListRow[] => {
  const data = assets.value
  if (!data) {
    return []
  }
  const rows: AssetListRow[] = []
  for (const a of data.projects) {
    if (a.packageCardAccountId != null) {
      continue
    }
    rows.push({
      key: `project-${a.accountId}`,
      kind: 'PROJECT',
      name: a.name || `项目账户#${a.accountId}`,
      codeText: `账户 ${a.accountId}`,
      remainText: `剩余 ${a.balance ?? 0} 次`,
      validDate: null,
      canUse: a.canUse !== false,
      raw: a,
    })
  }
  for (const a of data.generalCards) {
    rows.push({
      key: `general-${a.accountId}`,
      kind: 'GENERAL_CARD',
      name: a.name || `通用次卡#${a.accountId}`,
      codeText: `账户 ${a.accountId}`,
      remainText: `剩余 ${a.balance ?? 0} 次`,
      validDate: a.validDate,
      canUse: a.canUse !== false,
      raw: a,
    })
  }
  for (const a of data.timeCards) {
    rows.push({
      key: `time-${a.accountId}`,
      kind: 'TIME_CARD',
      name: a.name || `时效卡#${a.accountId}`,
      codeText: `账户 ${a.accountId}`,
      remainText: `剩余 ${a.performanceBalance ?? 0} 次`,
      validDate: a.validDate,
      canUse: a.canUse !== false,
      raw: a,
    })
  }
  for (const a of data.saving) {
    rows.push({
      key: `saving-${a.accountId}`,
      kind: 'SAVING_CARD',
      name: a.name || `储值卡#${a.accountId}`,
      codeText: `账户 ${a.accountId}`,
      remainText: `本金 ${formatAmountDisplay(a.principalBalance)} / 赠金 ${formatAmountDisplay(a.bonusBalance)}`,
      validDate: a.validDate,
      canUse: a.canUse !== false,
      raw: a,
    })
  }
  for (const a of data.packageCards) {
    rows.push({
      key: `package-${a.accountId}`,
      kind: 'PACKAGE_CARD',
      name: a.name || `套餐卡#${a.accountId}`,
      codeText: `账户 ${a.accountId}`,
      remainText: '查看套餐子项',
      validDate: a.validDate,
      canUse: a.canUse !== false,
      raw: a,
    })
  }
  let filtered = rows
  if (assetFilter.value) {
    filtered = filtered.filter((r) => r.kind === assetFilter.value)
  }
  const kw = assetKeyword.value.trim().toLowerCase()
  if (kw) {
    filtered = filtered.filter(
      (r) =>
        r.name.toLowerCase().includes(kw) ||
        r.codeText.toLowerCase().includes(kw),
    )
  }
  return filtered
})

function lineSaleTotal(line: SaleLineDraft): number {
  if (line.gift) return 0
  const unit = Number(line.price ?? 0)
  return (Number.isFinite(unit) ? unit : 0) * line.quantity
}

function lineSavingDeduct(line: SaleLineDraft): number {
  const p = Number(line.savingPrincipalAmount ?? 0)
  const b = Number(line.savingBonusAmount ?? 0)
  return Math.max(0, (Number.isFinite(p) ? p : 0) + (Number.isFinite(b) ? b : 0))
}

function lineCashDue(line: SaleLineDraft): number {
  const sale = lineSaleTotal(line)
  const arr = Number(line.arrearAmount ?? 0)
  const saving = lineSavingDeduct(line)
  return Math.max(0, Number((sale - (Number.isFinite(arr) ? arr : 0) - saving).toFixed(2)))
}

const saleSummary = computed(() => {
  const count = saleLines.value.reduce((s, l) => s + l.quantity, 0)
  let goodsAmount = 0
  let giftAmount = 0
  let arrearAmount = 0
  let savingDeduct = 0
  for (const line of saleLines.value) {
    const unit = Number(line.price ?? 0)
    const lineTotal = (Number.isFinite(unit) ? unit : 0) * line.quantity
    if (line.gift) {
      giftAmount += lineTotal
    } else {
      goodsAmount += lineTotal
      const arr = Number(line.arrearAmount ?? 0)
      arrearAmount += Number.isFinite(arr) ? Math.max(0, arr) : 0
      savingDeduct += lineSavingDeduct(line)
    }
  }
  const payable = Math.max(0, Number((goodsAmount - arrearAmount - savingDeduct).toFixed(2)))
  return {
    count,
    goodsAmount: goodsAmount.toFixed(2),
    giftAmount: giftAmount.toFixed(2),
    arrearAmount: arrearAmount.toFixed(2),
    savingDeduct: savingDeduct.toFixed(2),
    payable: payable.toFixed(2),
  }
})

const l1Categories = computed(() => categoryTree.value || [])
const l2Categories = computed(() => {
  if (selectedL1CategoryId.value == null) {
    return [] as ProjectCategoryTreeNode[]
  }
  const root = categoryTree.value.find((c) => c.id === selectedL1CategoryId.value)
  return root?.children ?? []
})

/** 关键字已走服务端检索；此处仅做分类/类型过滤后的结果 */
const catalogItems = computed(() => filteredGoods.value)

const catalogEmptyHint = computed(() => {
  if (!goodsItemType.value && !goodsKeyword.value.trim()) {
    return '请选择商品类型，或输入关键字搜索'
  }
  if (goodsItemType.value === 'PROJECT' && saleChannelId.value == null) {
    return '请先选择销售渠道'
  }
  return '请调整分类、渠道或关键字'
})

const catalogTotal = computed(() => catalogItems.value.length)
const pagedCatalogItems = computed(() => {
  const start = (catalogPage.value - 1) * catalogPageSize
  return catalogItems.value.slice(start, start + catalogPageSize)
})

const selectedCustomerLabel = computed(() => {
  if (!customer.value) {
    return ''
  }
  const name = customer.value.name?.trim() || '未命名'
  const mobile = maskMobile(customer.value.mobile)
  return `${name}【${mobile}】`
})

const settleLinesForDialog = computed<SettleLineOption[]>(() => {
  if (payExistingOrderId.value && currentOrder.value?.items?.length) {
    return currentOrder.value.items
      .filter((it) => it.lineId != null)
      .map((it, index) => {
        const saleAmount = Number(it.totalAmount ?? 0)
        const arrear = Number(it.arrearAmount ?? 0)
        const type = String(it.itemType || '')
        const sale = Number.isFinite(saleAmount) ? saleAmount : 0
        const arr = Number.isFinite(arrear) ? Math.max(0, arrear) : 0
        return {
          clientLineKey: it.clientLineKey?.trim() || `L${index + 1}`,
          itemType: type,
          name: it.itemName?.trim() || `${type}#${it.itemId}`,
          saleAmount: sale,
          arrearAmount: arr,
          savingDeductAmount: 0,
          cashDueAmount: Math.max(0, Number((sale - arr).toFixed(2))),
        }
      })
  }
  return saleLines.value.map((line, index) => {
    const sale = lineSaleTotal(line)
    const arr = Number(line.arrearAmount ?? 0)
    const saving = lineSavingDeduct(line)
    return {
      clientLineKey: `L${index + 1}`,
      itemType: String(line.itemType),
      name: line.name,
      saleAmount: sale,
      arrearAmount: Number.isFinite(arr) ? Math.max(0, arr) : 0,
      savingDeductAmount: saving,
      cashDueAmount: lineCashDue(line),
    }
  })
})

const customerSavingAccounts = computed(() => {
  const list = assets.value?.saving ?? []
  return list.map((a) => ({
    accountId: a.accountId,
    name: a.name || `储值账户#${a.accountId}`,
    balance: Number(a.principalBalance ?? 0),
    largessBalance: Number(a.bonusBalance ?? 0),
    allowPayForCardPurchase: a.allowPayForCardPurchase ?? null,
  }))
})

const consumeSummary = computed(() => {
  const count = consumeLines.value.reduce((s, l) => s + l.quantity, 0)
  const savingCount = consumeLines.value.filter((l) => l.itemType === TreatItemType.SAVING_CARD).length
  return {
    count,
    savingCount,
  }
})

/** 销售明细按品类取经手人候选 bizType（允许同行不同品类） */
function saleHandlerBizTypeOf(itemType: string) {
  switch (itemType) {
    case 'PRODUCT':
      return HandlerSaleBizTypes.PRODUCT_SALE
    case 'GENERAL_CARD':
      return HandlerSaleBizTypes.GENERAL_SALE
    case 'TIME_CARD':
      return HandlerSaleBizTypes.TIME_SALE
    case 'SAVING_CARD':
      return HandlerSaleBizTypes.SAVING_SALE
    case 'PACKAGE_CARD':
      return HandlerSaleBizTypes.PACKAGE_SALE
    default:
      return HandlerSaleBizTypes.PROJECT_SALE
  }
}

const handlerBizType = computed(() => {
  if (mode.value === 'consume') {
    const first = consumeLines.value[0]
    if (!first) {
      return HandlerTreatBizTypes.PROJECT_TREAT
    }
    if (first.itemType === TreatItemType.GENERAL_CARD) {
      return HandlerTreatBizTypes.GENERAL_TREAT
    }
    if (first.itemType === TreatItemType.TIME_CARD) {
      return HandlerTreatBizTypes.TIME_TREAT
    }
    if (first.itemType === TreatItemType.SAVING_CARD) {
      return HandlerTreatBizTypes.SAVING_TREAT
    }
    return HandlerTreatBizTypes.PROJECT_TREAT
  }
  const first = saleLines.value[0]
  return first ? saleHandlerBizTypeOf(String(first.itemType)) : HandlerSaleBizTypes.PROJECT_SALE
})

const adjustLine = computed(() =>
  saleLines.value.find((l) => l.key === adjustTargetKey.value) ?? null,
)

const billDateLimits = computed(() => {
  const now = new Date()
  const y = now.getFullYear()
  const m = now.getMonth()
  const first = new Date(y, m, 1)
  const today = new Date(y, m, now.getDate())
  return {
    min: formatDate(first),
    max: formatDate(today),
  }
})

const backdateAllowed = computed(() =>
  mode.value === 'sale' ? hasSaleBackdate.value : hasTreatBackdate.value,
)

function formatToday(): string {
  return formatDate(new Date())
}

function formatDate(d: Date): string {
  const y = d.getFullYear()
  const m = String(d.getMonth() + 1).padStart(2, '0')
  const day = String(d.getDate()).padStart(2, '0')
  return `${y}-${m}-${day}`
}

function nextKey(prefix: string): string {
  return `${prefix}-${Date.now()}-${Math.random().toString(36).slice(2, 8)}`
}

function itemTypeLabel(type: string | null | undefined): string {
  const hit = ITEM_TYPE_OPTIONS.find((o) => o.value === type)
  return hit?.label || type || '—'
}

async function loadCustomer(customerId: number): Promise<void> {
  await runExclusive(customerLoading, async () => {
    customerError.value = null
    customer.value = null
    try {
      customer.value = await fetchCustomerDetail(customerId)
    } catch (error) {
      customer.value = null
      customerError.value = getUserFriendlyErrorMessage(error)
    }
  })
}

function syncCustomerContext(): void {
  const parsed = resolvedCustomerId.value
  if (parsed === 'invalid' || parsed == null) {
    customer.value = null
    customerError.value = null
    return
  }
  if (customer.value?.id === parsed && !customerError.value) {
    return
  }
  void loadCustomer(parsed)
}

function applySelectedCustomer(item: CustomerListItem): void {
  const nextId = item.id
  const current = resolvedCustomerId.value
  customer.value = null
  customerError.value = null
  customerDropdownVisible.value = false
  customerKeyword.value = ''
  customerSearchResults.value = []
  if (current === nextId) {
    void loadCustomer(nextId)
    return
  }
  void router.replace({
    path: '/sales/cashier',
    query: { customerId: String(nextId) },
  })
}

function clearSelectedCustomer(): void {
  customer.value = null
  customerError.value = null
  customerKeyword.value = ''
  customerSearchResults.value = []
  customerDropdownVisible.value = false
  const nextQuery = { ...route.query }
  delete nextQuery.customerId
  void router.replace({ path: '/sales/cashier', query: nextQuery })
}

function openCustomerDetail(): void {
  if (customer.value?.id == null) {
    return
  }
  detailDrawerVisible.value = true
}

function openCustomerSelector(): void {
  selectorVisible.value = true
}

function retryLoadCustomer(): void {
  const parsed = resolvedCustomerId.value
  if (typeof parsed === 'number') {
    void loadCustomer(parsed)
  }
}

async function searchCustomers(reset = true): Promise<void> {
  if (!hasCustomerList.value) {
    return
  }
  const kw = customerKeyword.value.trim()
  if (!kw) {
    customerSearchResults.value = []
    customerSearchPage.value = 1
    customerSearchHasMore.value = false
    customerDropdownVisible.value = false
    return
  }
  if (!reset && (customerSearching.value || customerSearchLoadingMore.value || !customerSearchHasMore.value)) {
    return
  }
  const nextPage = reset ? 1 : customerSearchPage.value + 1
  const seq = ++customerSearchSeq
  if (reset) {
    customerSearching.value = true
  } else {
    customerSearchLoadingMore.value = true
  }
  try {
    const data = await fetchCustomerPage({
      keyword: kw,
      page: nextPage,
      size: CUSTOMER_SEARCH_PAGE_SIZE,
    })
    if (seq !== customerSearchSeq) return
    const chunk = data.records ?? []
    const total = data.total ?? 0
    if (reset) {
      customerSearchResults.value = chunk
      customerSearchPage.value = 1
    } else {
      customerSearchResults.value = [...customerSearchResults.value, ...chunk]
      customerSearchPage.value = nextPage
    }
    customerSearchHasMore.value =
      total > 0
        ? customerSearchResults.value.length < total
        : chunk.length >= CUSTOMER_SEARCH_PAGE_SIZE
    customerDropdownVisible.value = true
  } catch (error) {
    if (seq !== customerSearchSeq) return
    if (reset) {
      customerSearchResults.value = []
      customerSearchHasMore.value = false
    }
    uiMessage.error(getUserFriendlyErrorMessage(error))
  } finally {
    if (seq === customerSearchSeq) {
      customerSearching.value = false
      customerSearchLoadingMore.value = false
    }
  }
}

function onCustomerKeywordInput(): void {
  if (customerSearchTimer != null) {
    clearTimeout(customerSearchTimer)
  }
  customerSearchTimer = setTimeout(() => {
    void searchCustomers(true)
  }, 300)
}

function onCustomerDropdownScroll(e: Event): void {
  const el = e.target as HTMLElement | null
  if (!el) return
  const remain = el.scrollHeight - el.scrollTop - el.clientHeight
  if (remain <= 36) {
    void searchCustomers(false)
  }
}

function onGoodsKeywordInput(): void {
  if (goodsSearchTimer != null) {
    clearTimeout(goodsSearchTimer)
  }
  goodsSearchTimer = setTimeout(() => {
    catalogPage.value = 1
    void loadGoods()
  }, 300)
}

function onCustomerInputFocus(): void {
  if (customer.value) {
    return
  }
  if (customerSearchResults.value.length) {
    customerDropdownVisible.value = true
  }
}

function onCustomerBlur(): void {
  setTimeout(() => {
    customerDropdownVisible.value = false
  }, 180)
}

function switchMode(next: WorkbenchMode): void {
  if (next === mode.value) {
    return
  }
  if (next === 'sale' && !hasSaleCreate.value) {
    uiMessage.warning('暂无销售开单权限（sale:order:create）')
    return
  }
  if (next === 'consume' && !hasTreatView.value && !hasTreatCreate.value) {
    uiMessage.warning('暂无消耗单权限（treat:order:view / create）')
    return
  }
  mode.value = next
  saleLines.value = []
  consumeLines.value = []
  handlers.value = []
  backdateEnabled.value = false
  billDate.value = formatToday()
  uiMessage.info(`已切换为${next === 'sale' ? '销售单' : '消耗单'}模式`)
  if (next === 'sale') {
    void loadGoods()
  } else if (customerReady.value) {
    void loadAssets()
  }
}

function onTopAction(key: string): void {
  if (key === 'sale') {
    switchMode('sale')
    return
  }
  if (key === 'consume') {
    switchMode('consume')
    return
  }
  uiMessage.info('该入口本阶段未启用')
}

async function loadChannels(): Promise<void> {
  if (!hasChannelView.value) {
    channelOptions.value = []
    return
  }
  try {
    const list = await fetchSaleChannelOptions()
    channelOptions.value = list.filter((c) => c.active !== false && c.leaf !== false)
    if (saleChannelId.value == null && channelOptions.value.length === 1) {
      saleChannelId.value = channelOptions.value[0]!.id
    }
  } catch (error) {
    channelOptions.value = []
    uiMessage.error(getUserFriendlyErrorMessage(error))
  }
}

async function loadCategoryTree(): Promise<void> {
  if (!hasCategoryView.value) {
    categoryTree.value = []
    return
  }
  try {
    categoryTree.value = await fetchProjectCategoryTree(true)
  } catch {
    categoryTree.value = []
  }
}

function cardKindOfItemType(itemType: string): CardCategoryKind | null {
  switch (itemType) {
    case 'GENERAL_CARD':
      return 'general'
    case 'TIME_CARD':
      return 'time'
    case 'SAVING_CARD':
      return 'saving'
    case 'PACKAGE_CARD':
      return 'package'
    default:
      return null
  }
}

async function loadFlatCategories(): Promise<void> {
  selectedFlatCategoryId.value = null
  const t = goodsItemType.value
  if (t === 'PRODUCT') {
    try {
      const opts = await fetchProductCategoryOptions()
      flatCategories.value = (opts ?? [])
        .filter((o) => o.id != null)
        .map((o) => ({ id: Number(o.id), name: o.name?.trim() || `分类#${o.id}` }))
    } catch {
      flatCategories.value = []
    }
    return
  }
  const kind = cardKindOfItemType(t)
  if (!kind) {
    flatCategories.value = []
    return
  }
  try {
    const opts = await fetchCardCategoryOptions(kind)
    flatCategories.value = (opts ?? []).map((o) => ({
      id: o.id,
      name: o.name?.trim() || `分类#${o.id}`,
    }))
  } catch {
    flatCategories.value = []
  }
}

async function loadGoods(): Promise<void> {
  if (mode.value !== 'sale') {
    return
  }
  if (!hasCatalogView.value) {
    goodsError.value = '暂无商品目录权限（catalog:view）'
    goodsList.value = []
    return
  }
  const itemType = goodsItemType.value || undefined
  const keyword = goodsKeyword.value.trim() || undefined
  // 仅项目必须先选渠道再拉目录价；其它类型不传 saleChannelId
  if (itemType === 'PROJECT' && saleChannelId.value == null) {
    goodsList.value = []
    goodsError.value = null
    return
  }
  // 「全部」且无关键字：不拉全量目录，避免一次打爆接口
  if (!itemType && !keyword) {
    goodsList.value = []
    goodsError.value = null
    return
  }
  await runExclusive(goodsLoading, async () => {
    goodsError.value = null
    try {
      if (!itemType) {
        // 「全部」+关键字：按类型并发，但带 keyword 缩小结果
        const othersPromise = Promise.all(
          ['PRODUCT', 'GENERAL_CARD', 'TIME_CARD', 'SAVING_CARD', 'PACKAGE_CARD'].map((t) =>
            fetchGoodsList({ itemType: t, keyword }),
          ),
        ).then((arr) => arr.flat())
        if (saleChannelId.value != null) {
          const [projects, others] = await Promise.all([
            fetchGoodsList({
              itemType: 'PROJECT',
              keyword,
              saleChannelId: saleChannelId.value,
            }),
            othersPromise,
          ])
          goodsList.value = [...projects, ...others]
        } else {
          goodsList.value = await othersPromise
        }
      } else if (itemType === 'PROJECT') {
        goodsList.value = await fetchGoodsList({
          itemType: 'PROJECT',
          keyword,
          saleChannelId: saleChannelId.value!,
        })
      } else {
        goodsList.value = await fetchGoodsList({ itemType, keyword })
      }
    } catch (error) {
      goodsList.value = []
      goodsError.value = getUserFriendlyErrorMessage(error)
    }
  })
}

async function refreshCategoryProjects(): Promise<void> {
  const id = selectedL2CategoryId.value ?? selectedL1CategoryId.value
  catalogPage.value = 1
  if (id == null) {
    categoryProjectIds.value = null
    return
  }
  try {
    const page = await fetchProjectPage({
      page: 1,
      size: 500,
      categoryId: id,
      sellable: true,
    })
    categoryProjectIds.value = new Set((page.records ?? []).map((p) => p.id))
  } catch {
    categoryProjectIds.value = new Set()
  }
}

async function onSelectL1Category(id: number | null): Promise<void> {
  selectedL1CategoryId.value = id
  selectedL2CategoryId.value = null
  await refreshCategoryProjects()
}

async function onSelectL2Category(id: number | null): Promise<void> {
  selectedL2CategoryId.value = id
  await refreshCategoryProjects()
}

function onSelectChannel(id: number): void {
  saleChannelId.value = id
  catalogPage.value = 1
  void loadGoods()
}

function onSelectFlatCategory(id: number | null): void {
  selectedFlatCategoryId.value = id
  catalogPage.value = 1
}

/** 底部「订单信息」批量设置：仅用户主动改整单时写入各明细，不在结账时反向覆盖 */
function syncOrderHandlersToLines(): void {
  const cloned = handlers.value.map((h) => ({ ...h }))
  for (const line of saleLines.value) {
    line.handlers = cloned.map((h) => ({ ...h }))
  }
}

function onLineHandlersChange(lineKey: string, next: HandlerDraftRow[]): void {
  const line = saleLines.value.find((l) => l.key === lineKey)
  if (!line) {
    return
  }
  // 仅更新本行，不强制与其它明细或底部整单一致
  line.handlers = next.map((h) => ({ ...h }))
}

function linePayAmount(line: SaleLineDraft): number {
  return lineCashDue(line)
}

function clampLineArrear(line: SaleLineDraft): void {
  if (line.itemType === 'PRODUCT' || line.gift) {
    line.arrearAmount = 0
    clampLineSaving(line)
    return
  }
  const total = lineSaleTotal(line)
  const arr = Number(line.arrearAmount ?? 0)
  if (!Number.isFinite(arr) || arr < 0) {
    line.arrearAmount = 0
  } else if (arr > total) {
    line.arrearAmount = Number(total.toFixed(2))
  }
  clampLineSaving(line)
}

function clampLineSaving(line: SaleLineDraft): void {
  if (line.gift || line.itemType === 'PRODUCT') {
    line.savingAccountId = null
    line.savingPrincipalAmount = 0
    line.savingBonusAmount = 0
    return
  }
  const sale = lineSaleTotal(line)
  const arr = Number(line.arrearAmount ?? 0)
  const maxSaving = Math.max(0, sale - (Number.isFinite(arr) ? arr : 0))
  let p = Number(line.savingPrincipalAmount ?? 0)
  let b = Number(line.savingBonusAmount ?? 0)
  if (!Number.isFinite(p) || p < 0) p = 0
  if (!Number.isFinite(b) || b < 0) b = 0
  if (p + b > maxSaving + 0.001) {
    // 优先压缩赠金
    const keepP = Math.min(p, maxSaving)
    const keepB = Math.max(0, Number((maxSaving - keepP).toFixed(2)))
    line.savingPrincipalAmount = Number(keepP.toFixed(2))
    line.savingBonusAmount = keepB
  } else {
    line.savingPrincipalAmount = Number(p.toFixed(2))
    line.savingBonusAmount = Number(b.toFixed(2))
  }
  if (lineSavingDeduct(line) <= 0) {
    line.savingAccountId = null
  }
}

function lineSavingBlockedHint(line: SaleLineDraft): string | null {
  if (!CARD_PURCHASE_TYPES.has(String(line.itemType))) return null
  if (lineSavingDeduct(line) <= 0) return null
  const acc = customerSavingAccounts.value.find((a) => a.accountId === line.savingAccountId)
  if (acc && acc.allowPayForCardPurchase === false) {
    return `账户「${acc.name}」未开启购卡权限，不能抵扣本卡项`
  }
  return null
}

function goodsOf(row: unknown): GoodsItem {
  return row as GoodsItem
}

function saleLineOf(row: unknown): SaleLineDraft {
  return row as SaleLineDraft
}

function assetRowOf(row: unknown): AssetListRow {
  return row as AssetListRow
}

async function addSaleGoods(row: unknown): Promise<void> {
  const item = goodsOf(row)
  if (!customerReady.value) {
    uiMessage.warning('请先选择客户')
    return
  }
  if (!hasSaleCreate.value) {
    uiMessage.warning('暂无销售开单权限')
    return
  }
  if (item.sellable === false) {
    uiMessage.warning('该商品当前不可售')
    return
  }
  const itemType = item.itemType || ''
  const itemId = item.itemId
  if (!itemType || itemId == null) {
    return
  }

  let price: string | number | null = item.price
  let quote: PriceQuote | null = null
  let allowAdjust = false
  let minPrice: string | number | null = null

  let lineChannelId: number | null = null
  let lineChannelName: string | null = null

  if (itemType === 'PROJECT') {
    if (saleChannelId.value == null) {
      uiMessage.warning('请先在左侧选择销售渠道，再加入项目')
      return
    }
    if (currentStoreId.value == null) {
      uiMessage.warning('当前门店未就绪')
      return
    }
    if (!hasPriceQuote.value) {
      uiMessage.warning('暂无报价权限（price:quote）')
      return
    }
    lineChannelId = saleChannelId.value
    lineChannelName =
      selectedChannel.value?.name || selectedChannel.value?.code || String(lineChannelId)
    try {
      quote = await fetchPriceQuote({
        storeId: currentStoreId.value,
        itemType: 'PROJECT',
        itemId,
        saleChannelId: lineChannelId,
      })
      price = quote.price
      allowAdjust = quote.allowAdjust === true && hasPriceChange.value
      minPrice = quote.minPrice
    } catch (error) {
      uiMessage.error(getUserFriendlyErrorMessage(error))
      return
    }
  }

  const existing = saleLines.value.find(
    (l) =>
      l.itemType === itemType &&
      l.itemId === itemId &&
      !l.gift &&
      (itemType !== 'PROJECT' || l.saleChannelId === lineChannelId),
  )
  if (existing && itemType !== 'SAVING_CARD') {
    existing.quantity += 1
    uiMessage.success('已增加数量')
    return
  }

  saleLines.value.push({
    key: nextKey('sale'),
    itemType,
    itemId,
    name: item.name?.trim() || `${itemTypeLabel(itemType)}#${itemId}`,
    quantity: 1,
    price,
    quotePrice: quote?.price ?? item.price,
    allowAdjust,
    minPrice,
    priceChangeReason: null,
    gift: false,
    saleChannelId: lineChannelId,
    saleChannelName: lineChannelName,
    arrearAmount: 0,
    largessAmount: 0,
    savingAccountId: null,
    savingPrincipalAmount: 0,
    savingBonusAmount: 0,
    handlers: handlers.value.map((h) => ({ ...h })),
    categoryName: item.categoryName,
    status: '待结账',
  })
  uiMessage.success('已加入销售明细')
}

function removeSaleLine(key: string): void {
  saleLines.value = saleLines.value.filter((l) => l.key !== key)
}

function openAdjust(row: unknown): void {
  const line = saleLineOf(row)
  if (!line.allowAdjust) {
    return
  }
  if (currentStoreId.value == null || line.saleChannelId == null) {
    uiMessage.warning('缺少门店或该行销售渠道，无法改价')
    return
  }
  adjustTargetKey.value = line.key
  adjustVisible.value = true
}

function onAdjustConfirmed(payload: { price: string; reason: string }): void {
  const line = saleLines.value.find((l) => l.key === adjustTargetKey.value)
  if (!line) {
    return
  }
  line.price = payload.price
  line.priceChangeReason = payload.reason
  line.status = '已改价'
  clampLineArrear(line)
}

async function loadAssets(): Promise<void> {
  if (!customerReady.value || customer.value == null) {
    assets.value = null
    return
  }
  if (!hasTreatView.value) {
    assetsError.value = '暂无消耗资产查看权限（treat:order:view）'
    assets.value = null
    return
  }
  await runExclusive(assetsLoading, async () => {
    assetsError.value = null
    try {
      assets.value = await fetchCustomerAvailableAssets(customer.value!.id)
    } catch (error) {
      assets.value = null
      assetsError.value = getUserFriendlyErrorMessage(error)
    }
  })
}

function ensureCustomerForLine(): boolean {
  if (!customerReady.value) {
    uiMessage.warning('请先选择客户')
    return false
  }
  return true
}

async function onAssetClick(raw: unknown): Promise<void> {
  const row = assetRowOf(raw)
  if (!ensureCustomerForLine()) {
    return
  }
  if (!row.canUse) {
    uiMessage.warning('该资产当前不可用')
    return
  }
  if (row.kind === 'SAVING_CARD') {
    savingDialogAsset.value = row.raw as TreatSavingAsset
    savingDialogVisible.value = true
    return
  }
  if (row.kind === 'PROJECT') {
    const a = row.raw as TreatProjectAsset
    addConsumeLine({
      itemType: TreatItemType.PROJECT,
      accountId: a.accountId,
      projectId: a.projectId,
      name: a.name || `项目#${a.projectId}`,
      assetName: a.name || '',
      remainText: `剩余 ${a.balance ?? 0} 次`,
      fundSource: null,
      amountHint: null,
      amountHintLabel: '按账户计价',
    })
    return
  }
  if (row.kind === 'GENERAL_CARD') {
    await pickGeneralCardProject(row.raw as TreatGeneralCardAsset)
    return
  }
  if (row.kind === 'TIME_CARD') {
    await pickTimeCardProject(row.raw as TreatTimeCardAsset)
    return
  }
  if (row.kind === 'PACKAGE_CARD') {
    await pickPackageSubItems(row.raw as TreatPackageAsset)
  }
}

async function pickGeneralCardProject(asset: TreatGeneralCardAsset): Promise<void> {
  if (asset.generalCardId == null) {
    uiMessage.warning('缺少通用次卡定义 ID')
    return
  }
  try {
    const detail = await fetchGeneralCardDetail(asset.generalCardId)
    const projects = detail.projects ?? []
    if (projects.length === 0) {
      uiMessage.warning('该次卡未配置可耗项目')
      return
    }
    if (projects.length === 1) {
      const p = projects[0]!
      addConsumeLine({
        itemType: TreatItemType.GENERAL_CARD,
        accountId: asset.accountId,
        projectId: p.projectId,
        name: `${asset.name || '通用次卡'} → 项目#${p.projectId}`,
        assetName: asset.name || '',
        remainText: `剩余 ${asset.balance ?? 0} 次`,
        fundSource: null,
        amountHint: null,
        amountHintLabel: '按次卡账户计价',
      })
      return
    }
    const options = projects.map((p) => ({
      value: p.projectId,
      label: `项目#${p.projectId}（扣次 ${p.consumeAmount ?? 1}）`,
    }))
    const picked = await promptProjectPick('选择次卡内项目', options)
    if (picked == null) {
      return
    }
    addConsumeLine({
      itemType: TreatItemType.GENERAL_CARD,
      accountId: asset.accountId,
      projectId: picked,
      name: `${asset.name || '通用次卡'} → 项目#${picked}`,
      assetName: asset.name || '',
      remainText: `剩余 ${asset.balance ?? 0} 次`,
      fundSource: null,
      amountHint: null,
      amountHintLabel: '按次卡账户计价',
    })
  } catch (error) {
    uiMessage.error(getUserFriendlyErrorMessage(error))
  }
}

async function pickTimeCardProject(asset: TreatTimeCardAsset): Promise<void> {
  if (asset.timeCardId == null) {
    uiMessage.warning('缺少时效卡定义 ID')
    return
  }
  try {
    const detail = await fetchTimeCardDetail(asset.timeCardId)
    const projectIds = detail.projectIds ?? []
    if (projectIds.length === 0) {
      uiMessage.warning('该时效卡未配置可耗项目')
      return
    }
    if (projectIds.length === 1) {
      const pid = projectIds[0]!
      addConsumeLine({
        itemType: TreatItemType.TIME_CARD,
        accountId: asset.accountId,
        projectId: pid,
        name: `${asset.name || '时效卡'} → 项目#${pid}`,
        assetName: asset.name || '',
        remainText: `剩余 ${asset.performanceBalance ?? 0} 次`,
        fundSource: null,
        amountHint: null,
        amountHintLabel: '按时效卡账户计价',
      })
      return
    }
    const options = projectIds.map((id) => ({
      value: id,
      label: `项目#${id}`,
    }))
    const picked = await promptProjectPick('选择时效卡内项目', options)
    if (picked == null) {
      return
    }
    addConsumeLine({
      itemType: TreatItemType.TIME_CARD,
      accountId: asset.accountId,
      projectId: picked,
      name: `${asset.name || '时效卡'} → 项目#${picked}`,
      assetName: asset.name || '',
      remainText: `剩余 ${asset.performanceBalance ?? 0} 次`,
      fundSource: null,
      amountHint: null,
      amountHintLabel: '按时效卡账户计价',
    })
  } catch (error) {
    uiMessage.error(getUserFriendlyErrorMessage(error))
  }
}

async function pickPackageSubItems(asset: TreatPackageAsset): Promise<void> {
  const data = assets.value
  if (!data) {
    return
  }
  const subs = data.projects.filter(
    (p) => p.packageCardAccountId === asset.accountId && p.canUse !== false,
  )
  if (subs.length === 0) {
    uiMessage.warning(
      '该套餐卡下暂无可用项目账户。套餐消耗通过套餐内项目账户完成，后端 CreateTreat 不直接接受 PACKAGE_CARD 行。',
    )
    return
  }
  if (subs.length === 1) {
    const a = subs[0]!
    addConsumeLine({
      itemType: TreatItemType.PROJECT,
      accountId: a.accountId,
      projectId: a.projectId,
      name: `${asset.name || '套餐'} → ${a.name || `项目#${a.projectId}`}`,
      assetName: asset.name || '',
      remainText: `剩余 ${a.balance ?? 0} 次`,
      fundSource: null,
      amountHint: null,
      amountHintLabel: '套餐子项',
    })
    return
  }
  const options = subs.map((a) => ({
    value: a.accountId,
    label: `${a.name || `项目#${a.projectId}`}（剩 ${a.balance ?? 0}）`,
  }))
  const pickedAccountId = await promptProjectPick('选择套餐子项', options)
  if (pickedAccountId == null) {
    return
  }
  const a = subs.find((s) => s.accountId === pickedAccountId)
  if (!a) {
    return
  }
  addConsumeLine({
    itemType: TreatItemType.PROJECT,
    accountId: a.accountId,
    projectId: a.projectId,
    name: `${asset.name || '套餐'} → ${a.name || `项目#${a.projectId}`}`,
    assetName: asset.name || '',
    remainText: `剩余 ${a.balance ?? 0} 次`,
    fundSource: null,
    amountHint: null,
    amountHintLabel: '套餐子项',
  })
}

const pickDialogVisible = ref(false)
const pickDialogTitle = ref('')
const pickDialogOptions = ref<Array<{ value: number; label: string }>>([])
let pickResolve: ((value: number | null) => void) | null = null
const pickValue = ref<number | null>(null)

function promptProjectPick(
  title: string,
  options: Array<{ value: number; label: string }>,
): Promise<number | null> {
  pickDialogTitle.value = title
  pickDialogOptions.value = options
  pickValue.value = options[0]?.value ?? null
  pickDialogVisible.value = true
  return new Promise((resolve) => {
    pickResolve = resolve
  })
}

function confirmPick(): void {
  const resolve = pickResolve
  pickResolve = null
  pickDialogVisible.value = false
  resolve?.(pickValue.value)
}

function cancelPick(): void {
  const resolve = pickResolve
  pickResolve = null
  pickDialogVisible.value = false
  resolve?.(null)
}

function addConsumeLine(input: Omit<ConsumeLineDraft, 'key' | 'quantity' | 'status'> & {
  quantity?: number
}): void {
  consumeLines.value.push({
    key: nextKey('consume'),
    quantity: input.quantity ?? 1,
    status: '待提交',
    itemType: input.itemType,
    accountId: input.accountId,
    projectId: input.projectId,
    name: input.name,
    assetName: input.assetName,
    remainText: input.remainText,
    fundSource: input.fundSource,
    amountHint: input.amountHint,
    amountHintLabel: input.amountHintLabel,
  })
  uiMessage.success('已加入消耗明细')
}

function onSavingProjectSelect(payload: {
  accountId: number
  savingCardId: number | null
  projectId: number
  projectName: string
  fundSource: 'principal' | 'bonus'
  projectPrice: string | number | null
  cardName: string
}): void {
  addConsumeLine({
    itemType: TreatItemType.SAVING_CARD,
    accountId: payload.accountId,
    projectId: payload.projectId,
    name: `${payload.cardName} → ${payload.projectName}`,
    assetName: payload.cardName,
    remainText: payload.fundSource === 'principal' ? '拟用本金' : '拟用赠金',
    fundSource: payload.fundSource,
    amountHint: null,
    amountHintLabel: '扣款提交时由后端计算',
  })
}

function removeConsumeLine(key: string): void {
  consumeLines.value = consumeLines.value.filter((l) => l.key !== key)
}

function persistLastOrderId(id: string): void {
  try {
    sessionStorage.setItem(SALE_CASHIER_LAST_ORDER_KEY, id)
  } catch {
    /* ignore quota */
  }
  const nextQuery = { ...route.query, orderId: id }
  void router.replace({ query: nextQuery })
}

function clearLastOrderId(): void {
  try {
    sessionStorage.removeItem(SALE_CASHIER_LAST_ORDER_KEY)
  } catch {
    /* ignore */
  }
  if (route.query.orderId) {
    const nextQuery = { ...route.query }
    delete nextQuery.orderId
    void router.replace({ query: nextQuery })
  }
}

function buildCreateSaleRequest(payload: SettleConfirmPayload): CreateSaleOrderRequest {
  const orderArrear = Number(saleSummary.value.arrearAmount)
  return buildCreateSaleOrderRequest({
    customerId: customer.value?.id,
    storeId: currentStoreId.value,
    // 整单渠道不再必填；PROJECT 渠道走明细
    saleChannelId: undefined,
    lines: saleLines.value.map((line, index) => ({
      clientLineKey: `L${index + 1}`,
      itemType: String(line.itemType),
      itemId: line.itemId,
      quantity: line.quantity,
      price: line.price,
      priceChangeReason: line.priceChangeReason,
      gift: line.gift,
      saleChannelId: line.itemType === 'PROJECT' ? line.saleChannelId : null,
      arrearAmount: line.arrearAmount,
      largessAmount: line.largessAmount,
      savingAccountId: line.savingAccountId,
      savingPrincipalAmount: line.savingPrincipalAmount,
      savingBonusAmount: line.savingBonusAmount,
      handlers: line.handlers.map((h) => ({
        employeeId: h.employeeId,
        ratio: h.ratio,
      })),
    })),
    backdateEnabled: backdateEnabled.value,
    billDate: billDate.value,
    createOnly: payload.createOnly,
    payments: payload.payments,
    paymentAllocations: undefined,
    arrearAmount: orderArrear > 0 ? orderArrear : payload.arrearAmount,
  })
}

function openSettleForNewOrder(): void {
  const block = getSaleCheckoutBlockReason({
    hasCreatePermission: hasSaleCreate.value,
    customerReady: customerReady.value,
    storeId: currentStoreId.value,
    lines: saleLines.value.map((l) => ({
      itemType: String(l.itemType),
      saleChannelId: l.saleChannelId,
      handlers: l.handlers,
    })),
  })
  if (block) {
    if (block === 'PROJECT_NO_CHANNEL') {
      const miss = saleLines.value.find(
        (l) => l.itemType === 'PROJECT' && l.saleChannelId == null,
      )
      uiMessage.warning(
        miss ? `「${miss.name}」须选择销售渠道` : mapSaleCheckoutBlockMessage(block),
      )
      return
    }
    uiMessage.warning(mapSaleCheckoutBlockMessage(block))
    return
  }
  if (saleLines.value.some((l) => l.itemType === 'PROJECT') && !hasPriceQuote.value) {
    uiMessage.warning('项目销售需要报价权限')
    return
  }
  for (const line of saleLines.value) {
    clampLineArrear(line)
    const hint = lineSavingBlockedHint(line)
    if (hint) {
      uiMessage.warning(`${line.name}：${hint}`)
      return
    }
    if (lineSavingDeduct(line) > 0 && line.savingAccountId == null) {
      uiMessage.warning(`请为「${line.name}」选择储值账户`)
      return
    }
  }
  if (customerReady.value && hasTreatView.value && !assets.value) {
    void loadAssets()
  }
  payExistingOrderId.value = null
  settleVisible.value = true
}

function openSettleForExistingPay(orderId: string): void {
  if (!hasSalePay.value) {
    uiMessage.warning('无收款权限（sale:order:pay）')
    return
  }
  payExistingOrderId.value = orderId
  settleVisible.value = true
}

async function refreshOrderResult(orderId: string): Promise<void> {
  resultLoading.value = true
  postPayAssetsNote.value = null
  try {
    if (!hasSaleView.value) {
      uiMessage.warning('无订单查看权限，无法刷新详情')
      return
    }
    currentOrder.value = await fetchSaleOrderDetail(orderId)
    persistLastOrderId(orderId)
    const status = currentOrder.value.billStatus
    if (status === '已支付' && customer.value?.id != null && hasTreatView.value) {
      try {
        postPayAssets.value = await fetchCustomerAvailableAssets(customer.value.id)
        postPayAssetsNote.value =
          '以下为客户当前可耗权益汇总（含历史账户），非本单独占列表；精确到账户请在消耗模式查看。'
      } catch {
        postPayAssets.value = null
        postPayAssetsNote.value = '权益汇总查询失败，请切换到消耗模式查看客户可用资产。'
      }
    } else {
      postPayAssets.value = null
    }
    resultVisible.value = true
  } catch (error) {
    uiMessage.error(getUserFriendlyErrorMessage(error))
  } finally {
    resultLoading.value = false
  }
}

async function onSettleConfirm(payload: SettleConfirmPayload): Promise<void> {
  await runExclusive(settleSubmitting, async () => {
    try {
      if (payExistingOrderId.value) {
        if (payload.createOnly) {
          uiMessage.warning('待支付订单请直接登记收款')
          return
        }
        if (!hasSalePay.value) {
          uiMessage.warning('无收款权限')
          return
        }
        const orderId = payExistingOrderId.value
        try {
          currentOrder.value = await paySaleOrder(orderId, {
            payments: payload.payments,
          })
        } catch (error) {
          try {
            const latest = await fetchSaleOrderDetail(orderId)
            currentOrder.value = latest
            if (latest.billStatus === '已支付') {
              settleVisible.value = false
              await refreshOrderResult(orderId)
              uiMessage.success('订单已支付，已刷新最新状态')
              return
            }
          } catch {
            /* keep original error */
          }
          throw error
        }
        settleVisible.value = false
        await refreshOrderResult(orderId)
        uiMessage.success('收款已登记')
        return
      }

      const body = buildCreateSaleRequest(payload)
      let order: SaleOrderDetail
      try {
        order = await createSaleOrder(body)
      } catch (error) {
        const cached = sessionStorage.getItem(SALE_CASHIER_LAST_ORDER_KEY)
        if (cached && hasSaleView.value) {
          try {
            const latest = await fetchSaleOrderDetail(cached)
            currentOrder.value = latest
            settleVisible.value = false
            resultVisible.value = true
            uiMessage.warning('创建异常，已尝试加载最近订单，请核对是否重复开单')
            return
          } catch {
            /* fallthrough */
          }
        }
        throw error
      }
      persistLastOrderId(order.id)
      currentOrder.value = order
      settleVisible.value = false
      saleLines.value = []
      await refreshOrderResult(order.id)
      uiMessage.success(payload.createOnly ? '销售单已创建（待支付）' : '销售单已创建并登记收款')
    } catch (error) {
      uiMessage.error(getUserFriendlyErrorMessage(error))
    }
  })
}

function onCheckout(): void {
  openSettleForNewOrder()
}

function onStartNextOrder(): void {
  saleLines.value = []
  handlers.value = []
  currentOrder.value = null
  postPayAssets.value = null
  postPayAssetsNote.value = null
  resultVisible.value = false
  payExistingOrderId.value = null
  clearLastOrderId()
  uiMessage.info('已清空销售明细，可继续开下一单')
}

function onViewSaleOrder(): void {
  const id = currentOrder.value?.id
  if (!id) {
    return
  }
  void router.push({ name: 'sale-orders', query: { detail: id } })
}

function onViewConsumeFromSale(): void {
  resultVisible.value = false
  switchMode('consume')
}

async function tryRestoreOrderFromQuery(): Promise<void> {
  if (!hasSaleView.value) {
    return
  }
  const raw = route.query.orderId
  const fromQuery = Array.isArray(raw) ? raw[0] : raw
  if (typeof fromQuery !== 'string' || !fromQuery.trim()) {
    return
  }
  const id = fromQuery.trim()
  try {
    currentOrder.value = await fetchSaleOrderDetail(id)
    resultVisible.value = true
  } catch {
    /* 过期单号忽略 */
  }
}

function persistLastTreatOrderId(id: string): void {
  try {
    sessionStorage.setItem(TREAT_CASHIER_LAST_ORDER_KEY, id)
  } catch {
    /* ignore */
  }
}

async function refreshTreatResult(orderId: string): Promise<void> {
  treatResultLoading.value = true
  try {
    currentTreatOrder.value = await fetchTreatOrderDetail(orderId)
    persistLastTreatOrderId(orderId)
    if (customer.value?.id != null && hasTreatView.value) {
      try {
        postTreatAssets.value = await fetchCustomerAvailableAssets(customer.value.id)
        assets.value = postTreatAssets.value
      } catch {
        postTreatAssets.value = null
      }
    }
    treatResultVisible.value = true
  } catch (error) {
    uiMessage.error(getUserFriendlyErrorMessage(error))
  } finally {
    treatResultLoading.value = false
  }
}

async function onSubmitConsume(): Promise<void> {
  if (!hasTreatCreate.value) {
    uiMessage.warning('无消耗开单权限（treat:order:create）')
    return
  }
  const linesForSubmit = consumeLines.value.map((l) => ({
    itemType: l.itemType,
    accountId: l.accountId,
    projectId: l.projectId,
    quantity: l.quantity,
    fundSource: l.fundSource,
  }))
  const editor = handlerEditorRef.value
  const block = getTreatCheckoutBlockReason({
    hasCreatePermission: hasTreatCreate.value,
    customerReady: customerReady.value,
    storeId: currentStoreId.value,
    lineCount: consumeLines.value.length,
    handlerCount: handlers.value.length,
    handlerRatioValid: editor ? editor.ratioValid : true,
    lines: linesForSubmit,
  })
  if (block) {
    uiMessage.warning(mapTreatCheckoutBlockMessage(block))
    return
  }

  let signatureImageUrl: string | null = null
  try {
    const config = await fetchTreatConfig()
    if (config.requireCustomerSign && treatLinesNeedCardSign(linesForSubmit)) {
      try {
        const { value } = await ElMessageBox.prompt(
          '总部已开启顾客签字确认，卡类耗卡须提供签字图 URL（本阶段无上传组件）。取消则中止提交。',
          '顾客签字',
          {
            confirmButtonText: '继续提交',
            cancelButtonText: '取消',
            inputPlaceholder: 'https://.../sign.png',
            inputPattern: /\S+/,
            inputErrorMessage: '请填写签字图 URL',
          },
        )
        signatureImageUrl = String(value).trim()
      } catch {
        uiMessage.info('已取消提交')
        return
      }
    }
  } catch (error) {
    uiMessage.error(getUserFriendlyErrorMessage(error))
    return
  }

  await runExclusive(treatSubmitting, async () => {
    try {
      const body = buildCreateTreatOrderRequest({
        customerId: customer.value!.id,
        storeId: currentStoreId.value,
        backdateEnabled: backdateEnabled.value,
        billDate: billDate.value,
        signatureImageUrl,
        lines: linesForSubmit,
        handlers: handlers.value.map((h) => ({
          employeeId: h.employeeId,
          ratio: h.ratio,
        })),
      })
      let order: TreatOrderDetail
      try {
        order = await createTreatOrder(body)
      } catch (error) {
        const cached = sessionStorage.getItem(TREAT_CASHIER_LAST_ORDER_KEY)
        if (cached && hasTreatView.value) {
          try {
            await refreshTreatResult(cached)
            uiMessage.warning('提交异常，已尝试加载最近消耗单，请核对是否重复扣减')
            return
          } catch {
            /* fallthrough */
          }
        }
        throw error
      }
      currentTreatOrder.value = order
      persistLastTreatOrderId(order.id)
      consumeLines.value = []
      await refreshTreatResult(order.id)
      uiMessage.success('消耗单已提交，权益已扣减')
    } catch (error) {
      uiMessage.error(getUserFriendlyErrorMessage(error))
    }
  })
}

function onStartNextTreatOrder(): void {
  consumeLines.value = []
  handlers.value = []
  currentTreatOrder.value = null
  postTreatAssets.value = null
  treatResultVisible.value = false
  try {
    sessionStorage.removeItem(TREAT_CASHIER_LAST_ORDER_KEY)
  } catch {
    /* ignore */
  }
  if (customerReady.value) {
    void loadAssets()
  }
  uiMessage.info('已清空消耗明细，可继续开下一单')
}

function onRefreshTreatAssets(): void {
  if (customerReady.value) {
    void loadAssets()
  }
}

function disabledDate(date: Date): boolean {
  const t = date.getTime()
  const min = new Date(billDateLimits.value.min).setHours(0, 0, 0, 0)
  const max = new Date(billDateLimits.value.max).setHours(23, 59, 59, 999)
  return t < min || t > max
}

watch(
  () => route.query.customerId,
  () => {
    syncCustomerContext()
  },
  { immediate: true },
)

watch(customerReady, (ready) => {
  if (ready && mode.value === 'consume') {
    void loadAssets()
  }
})

watch(saleChannelId, () => {
  if (mode.value === 'sale') {
    saleLines.value = saleLines.value.filter((l) => l.itemType !== 'PROJECT')
    void loadGoods()
  }
})

watch(goodsItemType, () => {
  catalogPage.value = 1
  selectedL1CategoryId.value = null
  selectedL2CategoryId.value = null
  categoryProjectIds.value = null
  selectedFlatCategoryId.value = null
  void loadFlatCategories()
  void loadGoods()
})

watch(backdateEnabled, (on) => {
  if (!on) {
    billDate.value = formatToday()
  }
})

onBeforeUnmount(() => {
  if (customerSearchTimer != null) {
    clearTimeout(customerSearchTimer)
  }
  if (goodsSearchTimer != null) {
    clearTimeout(goodsSearchTimer)
  }
})

void loadChannels()
void loadCategoryTree()
void loadGoods()
void tryRestoreOrderFromQuery()
</script>

<template>
  <section class="workbench" v-loading="contextStatus === 'loading'">
    <header class="top-bar">
      <div class="mode-actions">
        <el-button
          v-for="act in TOP_ACTIONS"
          :key="act.key"
          size="small"
          :type="
            (act.key === 'sale' && mode === 'sale') || (act.key === 'consume' && mode === 'consume')
              ? 'primary'
              : 'default'
          "
          :disabled="!act.enabled"
          class="action-btn"
          @click="onTopAction(act.key)"
        >
          {{ act.label }}
        </el-button>
      </div>
      <div class="mode-badge">
        当前模式：<strong>{{ modeLabel }}</strong>
        <span class="store">门店 {{ storeStore.currentStoreName || '—' }}</span>
      </div>
    </header>

    <AppError
      v-if="!canEnterWorkbench"
      description="暂无开单或消耗权限（sale:order:create / treat:order:view）"
    />

    <div v-else class="panels">
      <aside class="left-panel">
        <div class="block customer-block">
          <div v-if="customer && contextStatus === 'ready'" class="customer-selected-bar">
            <div class="customer-selected-main">
              <el-icon class="user-ico"><User /></el-icon>
              <span class="customer-selected-text">{{ selectedCustomerLabel }}</span>
            </div>
            <div class="customer-selected-actions">
              <el-button link :icon="View" title="查看顾客资料" @click="openCustomerDetail" />
              <el-button link :icon="Delete" title="清除顾客" @click="clearSelectedCustomer" />
            </div>
          </div>
          <div v-else class="customer-search-wrap">
            <el-input
              v-model="customerKeyword"
              clearable
              placeholder="输入姓名 / 手机号 / 客户编号实时搜索"
              @input="onCustomerKeywordInput"
              @focus="onCustomerInputFocus"
              @blur="onCustomerBlur"
              @clear="searchCustomers(true)"
            />
            <div
              v-if="customerDropdownVisible"
              class="customer-dropdown"
              @scroll.passive="onCustomerDropdownScroll"
            >
              <div
                v-for="item in customerSearchResults"
                :key="item.id"
                class="customer-option"
                @mousedown.prevent="applySelectedCustomer(item)"
              >
                <strong>{{ item.name?.trim() || '未命名' }}</strong>
                <span>{{ maskMobile(item.mobile) }}</span>
                <span>{{ item.code || '—' }}</span>
              </div>
              <div v-if="customerSearchLoadingMore" class="customer-empty">加载中…</div>
              <div
                v-else-if="customerSearchHasMore && customerSearchResults.length"
                class="customer-empty"
              >
                下拉加载更多
              </div>
              <div v-if="!customerSearching && !customerSearchResults.length" class="customer-empty">
                无匹配客户
              </div>
            </div>
            <div class="customer-search-extra">
              <el-button size="small" text type="primary" @click="openCustomerSelector">
                高级选择
              </el-button>
              <AppError
                v-if="contextStatus === 'error'"
                :description="customerError || '客户加载失败'"
                @retry="retryLoadCustomer"
              />
              <span v-else-if="contextStatus === 'invalid'" class="tip">客户参数无效</span>
            </div>
          </div>
        </div>

        <template v-if="mode === 'sale'">
          <div class="block catalog-block" v-loading="goodsLoading">
            <div class="type-tabs">
              <button
                v-for="opt in ITEM_TYPE_OPTIONS"
                :key="opt.value || 'all'"
                type="button"
                class="type-tab"
                :class="{ active: goodsItemType === opt.value }"
                @click="goodsItemType = opt.value"
              >
                {{ opt.label }}
              </button>
            </div>
            <div class="catalog-keyword">
              <el-input
                v-model="goodsKeyword"
                clearable
                size="small"
                placeholder="输入名称关键字，自动搜索（防抖）"
                @input="onGoodsKeywordInput"
                @clear="onGoodsKeywordInput"
                @keyup.enter="catalogPage = 1; loadGoods()"
              />
            </div>
            <AppError v-if="goodsError" :description="goodsError" @retry="loadGoods" />
            <div v-else class="catalog-cascade">
              <div v-if="showProjectCategoryColumns" class="cascade-col cat-l1">
                <button
                  type="button"
                  class="cascade-item"
                  :class="{ active: selectedL1CategoryId == null }"
                  @click="onSelectL1Category(null)"
                >
                  全部
                </button>
                <button
                  v-for="root in l1Categories"
                  :key="root.id"
                  type="button"
                  class="cascade-item"
                  :class="{ active: selectedL1CategoryId === root.id }"
                  @click="onSelectL1Category(root.id)"
                >
                  {{ root.name || `分类#${root.id}` }}
                </button>
              </div>
              <div v-if="showProjectCategoryColumns && l2Categories.length" class="cascade-col cat-l2">
                <button
                  type="button"
                  class="cascade-item"
                  :class="{ active: selectedL2CategoryId == null }"
                  @click="onSelectL2Category(null)"
                >
                  全部
                </button>
                <button
                  v-for="child in l2Categories"
                  :key="child.id"
                  type="button"
                  class="cascade-item"
                  :class="{ active: selectedL2CategoryId === child.id }"
                  @click="onSelectL2Category(child.id)"
                >
                  {{ child.name || `分类#${child.id}` }}
                </button>
              </div>
              <div v-if="showFlatCategoryColumns" class="cascade-col cat-l1">
                <button
                  type="button"
                  class="cascade-item"
                  :class="{ active: selectedFlatCategoryId == null }"
                  @click="onSelectFlatCategory(null)"
                >
                  全部
                </button>
                <button
                  v-for="cat in flatCategories"
                  :key="cat.id"
                  type="button"
                  class="cascade-item"
                  :class="{ active: selectedFlatCategoryId === cat.id }"
                  @click="onSelectFlatCategory(cat.id)"
                >
                  {{ cat.name }}
                </button>
                <div v-if="!flatCategories.length" class="cascade-empty">暂无分类</div>
              </div>
              <div v-if="showChannelColumn" class="cascade-col channel-col">
                <button
                  v-for="ch in channelOptions"
                  :key="ch.id"
                  type="button"
                  class="cascade-item"
                  :class="{ active: saleChannelId === ch.id }"
                  @click="onSelectChannel(ch.id)"
                >
                  {{ ch.name || ch.code || String(ch.id) }}
                </button>
                <div v-if="!channelOptions.length" class="cascade-empty">暂无渠道</div>
              </div>
              <div class="cascade-col items-col">
                <button
                  v-for="row in pagedCatalogItems"
                  :key="`${row.itemType}-${row.itemId}`"
                  type="button"
                  class="goods-card"
                  :disabled="!customerReady || row.sellable === false"
                  @click="addSaleGoods(row)"
                >
                  <div class="goods-name">{{ row.name || '—' }}</div>
                  <div class="goods-price">
                    <template v-if="row.itemType === 'PROJECT' && !saleChannelId">请先选渠道</template>
                    <template v-else>¥ {{ formatAmountDisplay(row.price) }}</template>
                  </div>
                </button>
                <AppEmpty
                  v-if="!pagedCatalogItems.length"
                  title="暂无商品"
                  :description="catalogEmptyHint"
                />
                <div v-if="catalogTotal > 0" class="catalog-pager">
                  <span>共 {{ catalogTotal }} 条</span>
                  <el-pagination
                    v-model:current-page="catalogPage"
                    small
                    layout="prev, pager, next"
                    :page-size="catalogPageSize"
                    :total="catalogTotal"
                  />
                </div>
              </div>
            </div>
          </div>
        </template>

        <template v-else>
          <div class="block">
            <div class="block-title">客户可消耗资产</div>
            <div class="row-gap">
              <el-input
                v-model="assetKeyword"
                clearable
                placeholder="资产名称 / 账户"
              />
              <el-select v-model="assetFilter" clearable placeholder="类型" style="width: 140px">
                <el-option label="全部" value="" />
                <el-option label="项目账户" value="PROJECT" />
                <el-option label="通用次卡" value="GENERAL_CARD" />
                <el-option label="时效卡" value="TIME_CARD" />
                <el-option label="储值卡" value="SAVING_CARD" />
                <el-option label="套餐卡" value="PACKAGE_CARD" />
              </el-select>
              <el-button :loading="assetsLoading" @click="loadAssets">刷新</el-button>
            </div>
            <p class="tip">须先选客户。点击储值卡弹出项目选择；次卡/时效卡仅可选卡内项目；套餐走套餐内项目账户。</p>
          </div>
          <div class="block goods-block" v-loading="assetsLoading">
            <AppError
              v-if="!customerReady"
              description="请先选择客户后再查看可消耗资产"
            />
            <AppError
              v-else-if="assetsError"
              :description="assetsError"
              @retry="loadAssets"
            />
            <el-table
              v-else
              :data="assetRows"
              size="small"
              height="100%"
              border
              empty-text="暂无可用资产"
              @row-click="(row) => onAssetClick(row)"
            >
              <el-table-column label="资产名称" min-width="120" show-overflow-tooltip>
                <template #default="{ row }">{{ row.name }}</template>
              </el-table-column>
              <el-table-column label="类型" width="88">
                <template #default="{ row }">{{ itemTypeLabel(row.kind) }}</template>
              </el-table-column>
              <el-table-column label="编号" width="100" show-overflow-tooltip>
                <template #default="{ row }">{{ row.codeText }}</template>
              </el-table-column>
              <el-table-column label="余量" min-width="120" show-overflow-tooltip>
                <template #default="{ row }">{{ row.remainText }}</template>
              </el-table-column>
              <el-table-column label="有效期" width="110" show-overflow-tooltip>
                <template #default="{ row }">{{ row.validDate || '—' }}</template>
              </el-table-column>
              <el-table-column label="可耗" width="64" align="center">
                <template #default="{ row }">
                  <el-tag size="small" :type="row.canUse ? 'success' : 'info'">
                    {{ row.canUse ? '是' : '否' }}
                  </el-tag>
                </template>
              </el-table-column>
            </el-table>
          </div>
        </template>
      </aside>

      <section class="right-panel">
        <div class="right-scroll">
          <div class="block">
            <div class="block-title">
              单据明细
              <el-tag size="small" type="warning">{{ modeLabel }}</el-tag>
            </div>

            <div class="backdate-row">
              <el-switch
                v-model="backdateEnabled"
                :disabled="!backdateAllowed"
                active-text="补单"
              />
              <el-date-picker
                v-if="backdateEnabled && backdateAllowed"
                v-model="billDate"
                type="date"
                value-format="YYYY-MM-DD"
                placeholder="业务日期"
                :disabled-date="disabledDate"
                :clearable="false"
              />
              <span v-else class="tip">业务日期：今天（{{ formatToday() }}）</span>
              <span v-if="!backdateAllowed" class="tip">无补单权限</span>
            </div>

            <template v-if="mode === 'sale'">
              <div v-if="!saleLines.length" class="lines-empty">尚未加入销售明细，请在左侧点选商品</div>
              <div v-for="row in saleLines" :key="row.key" class="sale-line-card">
                <div class="sale-line-top">
                  <div class="sale-line-name">
                    <strong>{{ row.name }}</strong>
                    <span class="muted">{{ itemTypeLabel(row.itemType) }}</span>
                    <span
                      v-if="row.itemType === 'PROJECT' && row.saleChannelName"
                      class="muted channel-tag"
                    >
                      {{ row.saleChannelName }}
                    </span>
                    <span class="unit-price">¥ {{ formatAmountDisplay(row.price) }}</span>
                  </div>
                  <el-button link type="danger" :icon="Delete" @click="removeSaleLine(row.key)" />
                </div>
                <div class="sale-line-fields">
                  <label>
                    数量
                    <el-input-number v-model="row.quantity" :min="1" :max="999" size="small" />
                  </label>
                  <label class="amount-field">
                    金额
                    <span class="amount-num">{{ formatAmountDisplay(Number(row.price ?? 0) * row.quantity) }}</span>
                    <button
                      v-if="row.allowAdjust && row.itemType === 'PROJECT'"
                      type="button"
                      class="pen-btn"
                      title="改价"
                      @click="openAdjust(row)"
                    >
                      <el-icon><EditPen /></el-icon>
                    </button>
                  </label>
                  <label v-if="row.itemType === 'SAVING_CARD'">
                    赠额
                    <el-input-number
                      v-model="row.largessAmount"
                      :min="0"
                      :precision="2"
                      :controls="false"
                      size="small"
                    />
                  </label>
                  <label v-if="row.itemType !== 'PRODUCT' && !row.gift">
                    欠款
                    <el-input-number
                      v-model="row.arrearAmount"
                      :min="0"
                      :precision="2"
                      :controls="false"
                      size="small"
                      @change="clampLineArrear(row)"
                    />
                  </label>
                  <label class="gift-field">
                    <el-checkbox v-model="row.gift" @change="() => clampLineArrear(row)">赠送</el-checkbox>
                  </label>
                  <span class="pay-hint">现金应付: {{ formatAmountDisplay(linePayAmount(row)) }}</span>
                </div>
                <div
                  v-if="!row.gift && row.itemType !== 'PRODUCT' && customerSavingAccounts.length"
                  class="sale-line-saving"
                >
                  <span class="handler-label">储值抵扣</span>
                  <el-select
                    v-model="row.savingAccountId"
                    clearable
                    filterable
                    placeholder="选择账户"
                    size="small"
                    style="width: 160px"
                    @change="clampLineSaving(row)"
                  >
                    <el-option
                      v-for="a in customerSavingAccounts"
                      :key="a.accountId"
                      :label="`${a.name} 本${a.balance}/赠${a.largessBalance}`"
                      :value="a.accountId"
                    />
                  </el-select>
                  <el-input-number
                    v-model="row.savingPrincipalAmount"
                    :min="0"
                    :precision="2"
                    :controls="false"
                    size="small"
                    placeholder="本金"
                    style="width: 88px"
                    @change="clampLineSaving(row)"
                  />
                  <el-input-number
                    v-model="row.savingBonusAmount"
                    :min="0"
                    :precision="2"
                    :controls="false"
                    size="small"
                    placeholder="赠金"
                    style="width: 88px"
                    @change="clampLineSaving(row)"
                  />
                  <span v-if="lineSavingBlockedHint(row)" class="saving-warn">{{
                    lineSavingBlockedHint(row)
                  }}</span>
                </div>
                <div class="sale-line-handlers">
                  <span class="handler-label">销售经手人</span>
                  <CashierHandlerEditor
                    :model-value="row.handlers"
                    variant="chips"
                    :biz-type="saleHandlerBizTypeOf(String(row.itemType))"
                    :store-id="currentStoreId"
                    empty-text="点击选择经手人"
                    @update:model-value="(v) => onLineHandlersChange(row.key, v)"
                  />
                </div>
              </div>
            </template>

            <el-table
              v-else
              :data="consumeLines"
              size="small"
              border
              empty-text="尚未加入消耗明细"
            >
              <el-table-column label="名称" min-width="140" show-overflow-tooltip>
                <template #default="{ row }">{{ row.name }}</template>
              </el-table-column>
              <el-table-column label="类型" width="88">
                <template #default="{ row }">{{ itemTypeLabel(row.itemType) }}</template>
              </el-table-column>
              <el-table-column label="次数" width="100">
                <template #default="{ row }">
                  <el-input-number v-model="row.quantity" :min="1" :max="999" size="small" />
                </template>
              </el-table-column>
              <el-table-column label="余量" width="120" show-overflow-tooltip>
                <template #default="{ row }">{{ row.remainText }}</template>
              </el-table-column>
              <el-table-column label="金额说明" min-width="120" show-overflow-tooltip>
                <template #default="{ row }">{{ row.amountHintLabel }}</template>
              </el-table-column>
              <el-table-column label="状态" width="72">
                <template #default="{ row }">{{ row.status }}</template>
              </el-table-column>
              <el-table-column label="" width="64" align="center" fixed="right">
                <template #default="{ row }">
                  <el-button link type="danger" size="small" @click="removeConsumeLine(row.key)">
                    删除
                  </el-button>
                </template>
              </el-table-column>
            </el-table>
          </div>

          <div v-if="mode === 'consume'" class="block">
            <div class="block-title">经手人 / 分单比例</div>
            <CashierHandlerEditor
              ref="handlerEditorRef"
              v-model="handlers"
              variant="panel"
              :biz-type="handlerBizType"
              :store-id="currentStoreId"
            />
          </div>
        </div>

        <footer class="footer-bar">
          <template v-if="mode === 'sale'">
            <button
              type="button"
              class="order-info-toggle"
              @click="orderInfoExpanded = !orderInfoExpanded"
            >
              订单信息（{{ orderInfoExpanded ? '已展开' : '已折叠' }}）
            </button>
            <div v-if="orderInfoExpanded" class="order-info-panel">
              <div class="order-info-title">整单统一经手人（写入全部明细）</div>
              <CashierHandlerEditor
                v-model="handlers"
                variant="panel"
                :biz-type="handlerBizType"
                :store-id="currentStoreId"
                @update:model-value="syncOrderHandlersToLines"
              />
            </div>
            <div class="sums">
              <span>明细 {{ saleSummary.count }}</span>
              <span>成交 ¥{{ saleSummary.goodsAmount }}</span>
              <span>储值 ¥{{ saleSummary.savingDeduct }}</span>
              <span>欠款 ¥{{ saleSummary.arrearAmount }}</span>
              <strong>现金应收: ¥{{ saleSummary.payable }}</strong>
            </div>
            <el-button
              class="checkout-btn"
              type="primary"
              :disabled="!hasSaleCreate || settleSubmitting"
              :loading="settleSubmitting"
              @click="onCheckout"
            >
              收款
            </el-button>
          </template>
          <template v-else>
            <div class="sums">
              <span>消耗项 {{ consumeSummary.count }}</span>
              <span>储值扣款行 {{ consumeSummary.savingCount }}</span>
              <strong>扣款金额：提交时后端计算</strong>
              <span class="fine-sum">提交成功后刷新权益余额</span>
            </div>
            <el-button
              class="checkout-btn"
              type="primary"
              :disabled="!hasTreatCreate || treatSubmitting"
              :loading="treatSubmitting"
              @click="onSubmitConsume"
            >
              提交消耗
            </el-button>
          </template>
        </footer>
      </section>
    </div>

    <SaleCustomerSelector v-model="selectorVisible" @select="applySelectedCustomer" />

    <CustomerDetailDrawer
      v-model="detailDrawerVisible"
      :customer-id="customer?.id ?? null"
    />

    <SavingConsumeProjectDialog
      v-model="savingDialogVisible"
      :asset="savingDialogAsset"
      @select="onSavingProjectSelect"
    />

    <CashierPriceAdjustDialog
      v-if="adjustLine && adjustLine.saleChannelId != null && currentStoreId != null"
      v-model="adjustVisible"
      :store-id="currentStoreId"
      :item-type="String(adjustLine.itemType)"
      :item-id="adjustLine.itemId"
      :item-name="adjustLine.name"
      :sale-channel-id="adjustLine.saleChannelId"
      :base-price="adjustLine.quotePrice"
      :min-price="adjustLine.minPrice"
      :allow-adjust="adjustLine.allowAdjust"
      @confirmed="onAdjustConfirmed"
    />

    <el-dialog
      v-model="pickDialogVisible"
      :title="pickDialogTitle"
      width="420px"
      append-to-body
      :close-on-click-modal="false"
    >
      <el-select v-model="pickValue" filterable style="width: 100%">
        <el-option
          v-for="opt in pickDialogOptions"
          :key="opt.value"
          :label="opt.label"
          :value="opt.value"
        />
      </el-select>
      <template #footer>
        <el-button @click="cancelPick">取消</el-button>
        <el-button type="primary" @click="confirmPick">确定</el-button>
      </template>
    </el-dialog>

    <CashierSettleDialog
      v-model="settleVisible"
      :payable-amount="
        payExistingOrderId && currentOrder
          ? Number(currentOrder.totalAmount ?? currentOrder.amount ?? 0) -
            Number(currentOrder.arrearAmount ?? 0)
          : saleSummary.payable
      "
      :goods-amount="
        payExistingOrderId && currentOrder
          ? (currentOrder.totalAmount ?? currentOrder.amount ?? saleSummary.goodsAmount)
          : saleSummary.goodsAmount
      "
      :saving-deduct-amount="payExistingOrderId ? 0 : saleSummary.savingDeduct"
      :arrear-amount="
        payExistingOrderId && currentOrder
          ? (currentOrder.arrearAmount ?? 0)
          : saleSummary.arrearAmount
      "
      :customer-name="currentOrder?.customerName ?? customer?.name ?? null"
      :channel-name="settleChannelSummary"
      :line-count="settleLinesForDialog.length"
      :settle-lines="settleLinesForDialog"
      :submitting="settleSubmitting"
      :pay-only-mode="!!payExistingOrderId"
      @confirm="onSettleConfirm"
    />

    <SaleOrderResultDialog
      v-model="resultVisible"
      :order="currentOrder"
      :assets="postPayAssets"
      :assets-note="postPayAssetsNote"
      :loading="resultLoading"
      @refresh="currentOrder?.id && refreshOrderResult(currentOrder.id)"
      @next-order="onStartNextOrder"
      @register-pay="currentOrder?.id && openSettleForExistingPay(currentOrder.id)"
      @view-order="onViewSaleOrder"
      @view-consume="onViewConsumeFromSale"
    />

    <TreatOrderResultDialog
      v-model="treatResultVisible"
      :order="currentTreatOrder"
      :assets="postTreatAssets"
      :loading="treatResultLoading"
      @refresh="currentTreatOrder?.id && refreshTreatResult(currentTreatOrder.id)"
      @refresh-assets="onRefreshTreatAssets"
      @next-order="onStartNextTreatOrder"
    />
  </section>
</template>

<style scoped>
.workbench {
  display: flex;
  flex-direction: column;
  height: calc(100vh - 120px);
  min-height: 560px;
  background: #fff;
  border: 1px solid #e8e8e8;
}

.top-bar {
  display: flex;
  flex-wrap: wrap;
  gap: 12px;
  align-items: center;
  justify-content: space-between;
  padding: 8px 12px;
  border-bottom: 1px solid #e8e8e8;
  background: var(--el-color-primary-light-9);
}

.mode-actions {
  display: flex;
  flex-wrap: wrap;
  gap: 6px;
}

.mode-badge {
  font-size: 13px;
  color: #606266;
}

.mode-badge strong {
  color: var(--el-color-primary);
  margin-right: 12px;
}

.store {
  color: #909399;
}

.panels {
  display: grid;
  grid-template-columns: minmax(300px, 42%) minmax(0, 58%);
  flex: 1;
  min-height: 0;
}

.left-panel,
.right-panel {
  display: flex;
  flex-direction: column;
  min-height: 0;
  border-right: 1px solid #e8e8e8;
}

.right-panel {
  border-right: 0;
}

.block {
  padding: 10px 12px;
  border-bottom: 1px solid #f0f0f0;
}

.block-title {
  display: flex;
  gap: 8px;
  align-items: center;
  margin-bottom: 8px;
  font-size: 13px;
  font-weight: 600;
  color: #303133;
}

.customer-selected-bar {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 8px;
  padding: 8px 10px;
  background: var(--el-color-primary-light-9);
  border: 1px solid var(--el-color-primary-light-5);
  border-radius: 4px;
}

.customer-selected-main {
  display: flex;
  align-items: center;
  gap: 8px;
  min-width: 0;
}

.user-ico {
  color: var(--el-color-primary);
  font-size: 18px;
}

.customer-selected-text {
  font-size: 14px;
  font-weight: 600;
  color: #303133;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.customer-selected-actions {
  display: flex;
  flex-shrink: 0;
  gap: 2px;
}

.customer-search-wrap {
  position: relative;
}

.customer-dropdown {
  position: absolute;
  z-index: 20;
  left: 0;
  right: 0;
  max-height: 220px;
  overflow: auto;
  margin-top: 4px;
  background: #fff;
  border: 1px solid #e4e7ed;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.08);
}

.customer-option {
  display: grid;
  grid-template-columns: 1.2fr 1fr 1fr;
  gap: 6px;
  padding: 8px 10px;
  font-size: 12px;
  cursor: pointer;
  border-bottom: 1px solid #f5f5f5;
}

.customer-option:hover {
  background: var(--el-color-primary-light-9);
}

.customer-empty {
  padding: 12px;
  color: #909399;
  font-size: 12px;
  text-align: center;
}

.customer-search-extra {
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
  align-items: center;
  margin-top: 8px;
}

.catalog-block {
  flex: 1;
  min-height: 0;
  display: flex;
  flex-direction: column;
  overflow: hidden;
}

.type-tabs {
  display: flex;
  flex-wrap: wrap;
  gap: 0;
  margin-bottom: 8px;
  border-bottom: 1px solid #ebeef5;
}

.type-tab {
  padding: 8px 12px;
  border: 0;
  background: transparent;
  color: #606266;
  font-size: 13px;
  cursor: pointer;
  border-bottom: 2px solid transparent;
}

.type-tab.active {
  color: var(--el-color-primary);
  font-weight: 600;
  border-bottom-color: var(--el-color-primary);
}

.catalog-keyword {
  margin-bottom: 8px;
}

.catalog-cascade {
  display: flex;
  flex: 1;
  min-height: 240px;
  border: 1px solid #ebeef5;
  overflow: hidden;
}

.cascade-col {
  overflow: auto;
  border-right: 1px solid #ebeef5;
}

.cascade-col:last-child {
  border-right: 0;
}

.cat-l1,
.cat-l2,
.channel-col {
  width: 110px;
  flex-shrink: 0;
}

.items-col {
  flex: 1;
  min-width: 0;
  display: flex;
  flex-direction: column;
}

.cascade-item {
  display: block;
  width: 100%;
  padding: 10px 8px;
  border: 0;
  border-bottom: 1px solid #f5f5f5;
  background: transparent;
  text-align: left;
  font-size: 13px;
  color: #606266;
  cursor: pointer;
}

.cascade-item:hover {
  background: var(--el-color-primary-light-9);
}

.cascade-item.active {
  background: var(--el-color-primary-light-9);
  color: var(--el-color-primary);
  font-weight: 600;
}

.cascade-empty {
  padding: 12px 8px;
  color: #909399;
  font-size: 12px;
}

.goods-card {
  display: block;
  width: 100%;
  padding: 10px 12px;
  border: 0;
  border-bottom: 1px solid #f0f0f0;
  background: #fff;
  text-align: left;
  cursor: pointer;
}

.goods-card:hover:not(:disabled) {
  background: #fafafa;
}

.goods-card:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

.goods-name {
  font-size: 13px;
  color: #303133;
  line-height: 1.4;
}

.goods-price {
  margin-top: 4px;
  font-size: 14px;
  font-weight: 600;
  color: #f56c6c;
}

.catalog-pager {
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
  align-items: center;
  justify-content: flex-end;
  padding: 8px;
  margin-top: auto;
  border-top: 1px solid #f0f0f0;
  font-size: 12px;
  color: #909399;
}

.row-gap {
  display: flex;
  gap: 8px;
  align-items: center;
  margin-bottom: 8px;
}

.tip {
  margin: 0;
  font-size: 12px;
  color: #909399;
  line-height: 1.5;
}

.goods-block {
  flex: 1;
  min-height: 200px;
  display: flex;
  flex-direction: column;
  overflow: hidden;
}

.goods-block :deep(.el-table) {
  flex: 1;
}

.right-scroll {
  flex: 1;
  min-height: 0;
  overflow: auto;
}

.backdate-row {
  display: flex;
  flex-wrap: wrap;
  gap: 10px;
  align-items: center;
  margin-bottom: 10px;
}

.lines-empty {
  padding: 24px;
  color: #909399;
  font-size: 13px;
  text-align: center;
}

.sale-line-card {
  margin-bottom: 12px;
  padding: 10px 12px;
  border: 1px solid #ebeef5;
  border-radius: 4px;
  background: #fff;
}

.sale-line-top {
  display: flex;
  align-items: flex-start;
  justify-content: space-between;
  gap: 8px;
  margin-bottom: 8px;
}

.sale-line-name {
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
  align-items: baseline;
}

.sale-line-name strong {
  font-size: 14px;
  color: #303133;
}

.muted {
  font-size: 12px;
  color: #909399;
}

.unit-price {
  font-size: 13px;
  font-weight: 600;
  color: #f56c6c;
}

.sale-line-fields {
  display: flex;
  flex-wrap: wrap;
  gap: 12px 16px;
  align-items: center;
  margin-bottom: 8px;
  font-size: 12px;
  color: #606266;
}

.sale-line-fields label {
  display: inline-flex;
  gap: 6px;
  align-items: center;
}

.amount-field {
  gap: 4px !important;
}

.amount-num {
  font-weight: 600;
  color: #f56c6c;
}

.pen-btn {
  display: inline-flex;
  align-items: center;
  padding: 2px;
  margin-left: 2px;
  color: var(--el-color-primary);
  cursor: pointer;
  background: none;
  border: 0;
}

.pay-hint {
  color: #909399;
}

.sale-line-handlers,
.sale-line-saving {
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
  align-items: center;
  padding-top: 6px;
  border-top: 1px dashed #ebeef5;
}

.handler-label {
  flex-shrink: 0;
  font-size: 12px;
  color: #909399;
}

.saving-warn {
  font-size: 12px;
  color: #e6a23c;
}

.footer-bar {
  display: flex;
  flex-wrap: wrap;
  gap: 12px;
  align-items: center;
  justify-content: space-between;
  padding: 10px 14px;
  border-top: 1px solid #e8e8e8;
  background: #fafafa;
}

.order-info-toggle {
  width: 100%;
  padding: 6px 0;
  color: var(--el-color-primary);
  font-size: 13px;
  text-align: left;
  cursor: pointer;
  background: none;
  border: 0;
}

.order-info-panel {
  width: 100%;
  padding: 8px 0 4px;
  border-bottom: 1px dashed #ebeef5;
}

.order-info-title {
  margin-bottom: 6px;
  font-size: 12px;
  color: #909399;
}

.sums {
  display: flex;
  flex-wrap: wrap;
  gap: 12px;
  font-size: 13px;
  color: #606266;
}

.sums strong {
  color: var(--el-color-primary);
  font-size: 15px;
}

.fine-sum {
  color: #999;
  font-size: 12px;
  font-weight: normal;
}

.checkout-btn {
  min-width: 120px;
}

@media (max-width: 1100px) {
  .panels {
    grid-template-columns: 1fr;
  }

  .workbench {
    height: auto;
  }

  .catalog-cascade {
    flex-direction: column;
  }

  .cat-l1,
  .cat-l2,
  .channel-col {
    width: 100%;
    max-height: 120px;
  }
}
</style>
