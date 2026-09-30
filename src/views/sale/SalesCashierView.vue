<script setup lang="ts">
import { computed, ref, watch } from 'vue'
import { useRoute, useRouter } from 'vue-router'

import AppEmpty from '@/components/common/AppEmpty.vue'
import AppError from '@/components/common/AppError.vue'
import SaleCustomerSelector from '@/components/sale/SaleCustomerSelector.vue'
import CashierHandlerEditor, {
  type HandlerDraftRow,
} from '@/components/sale/CashierHandlerEditor.vue'
import CashierPriceAdjustDialog from '@/components/sale/CashierPriceAdjustDialog.vue'
import SavingConsumeProjectDialog from '@/components/sale/SavingConsumeProjectDialog.vue'
import { fetchCustomerDetail, fetchCustomerPage } from '@/api/customer'
import { fetchGoodsList } from '@/api/catalog'
import { fetchSaleChannelOptions } from '@/api/sale-channel'
import { fetchPriceQuote } from '@/api/price'
import { fetchProjectCategoryTree, fetchProjectPage } from '@/api/project'
import {
  fetchGeneralCardDetail,
  fetchTimeCardDetail,
} from '@/api/card'
import { fetchCustomerAvailableAssets } from '@/api/treat'
import type { CatalogItemType, GoodsItem } from '@/types/catalog'
import type { CustomerDetail, CustomerListItem } from '@/types/customer'
import type { ProjectCategoryTreeNode } from '@/types/project'
import type { SaleChannelOption } from '@/types/sale-channel'
import type { PriceQuote } from '@/types/price'
import { SalePermission } from '@/types/sale'
import { PricePermission } from '@/types/price'
import { HandlerSaleBizTypes, HandlerTreatBizTypes } from '@/types/handler'
import {
  TreatPermission,
  TreatItemType,
  type CustomerAvailableAssets,
  type TreatGeneralCardAsset,
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
const customerSearchResults = ref<CustomerListItem[]>([])
const customerDropdownVisible = ref(false)

const goodsLoading = ref(false)
const goodsError = ref<string | null>(null)
const goodsKeyword = ref('')
const goodsItemType = ref('')
const goodsList = ref<GoodsItem[]>([])
const channelOptions = ref<SaleChannelOption[]>([])
const saleChannelId = ref<number | null>(null)
const categoryTree = ref<ProjectCategoryTreeNode[]>([])
const selectedCategoryId = ref<number | null>(null)
const categoryProjectIds = ref<Set<number> | null>(null)

const saleLines = ref<SaleLineDraft[]>([])
const consumeLines = ref<ConsumeLineDraft[]>([])
const handlers = ref<HandlerDraftRow[]>([])

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

const hasSaleCreate = computed(() =>
  permissionStore.hasPermission(SalePermission.ORDER_CREATE),
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

const filteredGoods = computed(() => {
  let list = goodsList.value
  if (goodsItemType.value === 'PROJECT' || !goodsItemType.value) {
    if (categoryProjectIds.value != null && (goodsItemType.value === 'PROJECT' || !goodsItemType.value)) {
      if (goodsItemType.value === 'PROJECT') {
        list = list.filter(
          (g) => g.itemType === 'PROJECT' && g.itemId != null && categoryProjectIds.value!.has(g.itemId),
        )
      }
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

const saleSummary = computed(() => {
  const count = saleLines.value.reduce((s, l) => s + l.quantity, 0)
  let goodsAmount = 0
  let giftAmount = 0
  for (const line of saleLines.value) {
    const unit = Number(line.price ?? 0)
    const lineTotal = (Number.isFinite(unit) ? unit : 0) * line.quantity
    if (line.gift) {
      giftAmount += lineTotal
    } else {
      goodsAmount += lineTotal
    }
  }
  return {
    count,
    goodsAmount: goodsAmount.toFixed(2),
    giftAmount: giftAmount.toFixed(2),
    arrearAmount: '0.00',
    payable: goodsAmount.toFixed(2),
  }
})

const consumeSummary = computed(() => {
  const count = consumeLines.value.reduce((s, l) => s + l.quantity, 0)
  const savingCount = consumeLines.value.filter((l) => l.itemType === TreatItemType.SAVING_CARD).length
  return {
    count,
    savingCount,
  }
})

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
  if (!first) {
    return HandlerSaleBizTypes.PROJECT_SALE
  }
  switch (first.itemType) {
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
  if (current === nextId) {
    void loadCustomer(nextId)
    return
  }
  void router.replace({
    path: '/sales/cashier',
    query: { customerId: String(nextId) },
  })
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

async function searchCustomers(): Promise<void> {
  if (!hasCustomerList.value) {
    uiMessage.warning('暂无客户列表权限')
    return
  }
  const kw = customerKeyword.value.trim()
  await runExclusive(customerSearching, async () => {
    try {
      const data = await fetchCustomerPage({
        keyword: kw || undefined,
        page: 1,
        size: 10,
      })
      customerSearchResults.value = data.records ?? []
      customerDropdownVisible.value = true
    } catch (error) {
      customerSearchResults.value = []
      uiMessage.error(getUserFriendlyErrorMessage(error))
    }
  })
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
  if (itemType === 'PROJECT' || !itemType) {
    if (itemType === 'PROJECT' && saleChannelId.value == null) {
      goodsList.value = []
      goodsError.value = '请先选择销售渠道后再查询项目'
      return
    }
  }
  await runExclusive(goodsLoading, async () => {
    goodsError.value = null
    try {
      const query: {
        itemType?: string
        keyword?: string
        saleChannelId?: number
      } = {
        itemType: itemType || undefined,
        keyword: goodsKeyword.value.trim() || undefined,
      }
      if ((itemType === 'PROJECT' || !itemType) && saleChannelId.value != null) {
        // 全部时：分两次拉，项目带渠道，其它不带
        if (!itemType) {
          const [projects, others] = await Promise.all([
            fetchGoodsList({
              itemType: 'PROJECT',
              keyword: query.keyword,
              saleChannelId: saleChannelId.value,
            }),
            Promise.all(
              ['PRODUCT', 'GENERAL_CARD', 'TIME_CARD', 'SAVING_CARD', 'PACKAGE_CARD'].map((t) =>
                fetchGoodsList({ itemType: t, keyword: query.keyword }),
              ),
            ).then((arr) => arr.flat()),
          ])
          goodsList.value = [...projects, ...others]
        } else {
          query.saleChannelId = saleChannelId.value
          goodsList.value = await fetchGoodsList(query)
        }
      } else {
        goodsList.value = await fetchGoodsList(query)
      }
    } catch (error) {
      goodsList.value = []
      goodsError.value = getUserFriendlyErrorMessage(error)
    }
  })
}

async function onCategorySelect(id: number | null): Promise<void> {
  selectedCategoryId.value = id
  if (id == null) {
    categoryProjectIds.value = null
    return
  }
  try {
    const page = await fetchProjectPage({
      page: 1,
      size: 200,
      categoryId: id,
      sellable: true,
    })
    categoryProjectIds.value = new Set((page.records ?? []).map((p) => p.id))
  } catch {
    categoryProjectIds.value = new Set()
  }
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

  if (itemType === 'PROJECT') {
    if (saleChannelId.value == null) {
      uiMessage.warning('项目销售必须选择整单销售渠道')
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
    try {
      quote = await fetchPriceQuote({
        storeId: currentStoreId.value,
        itemType: 'PROJECT',
        itemId,
        saleChannelId: saleChannelId.value,
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
    (l) => l.itemType === itemType && l.itemId === itemId && !l.gift,
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
  if (saleChannelId.value == null || currentStoreId.value == null) {
    uiMessage.warning('缺少门店或渠道，无法改价')
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
    // 多项目：用 Element 简单选择
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

/**
 * 轻量项目选择（避免引入额外弹窗组件）。
 * 使用 Element Plus MessageBox.prompt 不合适（非文本）；改用临时 select dialog 状态。
 */
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

function onCheckoutPlaceholder(): void {
  uiMessage.info('收款功能尚未接入，本阶段不会创建真实订单或支付记录')
}

function onSubmitConsumePlaceholder(): void {
  uiMessage.info('消耗提交尚未接入，本阶段不会创建真实消耗单')
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
    // 渠道变更后项目价失效，清空项目行
    saleLines.value = saleLines.value.filter((l) => l.itemType !== 'PROJECT')
    void loadGoods()
  }
})

watch(goodsItemType, () => {
  void loadGoods()
})

watch(backdateEnabled, (on) => {
  if (!on) {
    billDate.value = formatToday()
  }
})

void loadChannels()
void loadCategoryTree()
void loadGoods()
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
      <!-- 左侧 -->
      <aside class="left-panel">
        <div class="block customer-block">
          <div class="block-title">客户</div>
          <div class="customer-search">
            <el-input
              v-model="customerKeyword"
              clearable
              placeholder="姓名 / 手机号 / 客户编号"
              @keyup.enter="searchCustomers"
            />
            <el-button type="primary" :loading="customerSearching" @click="searchCustomers">
              搜索
            </el-button>
          </div>
          <div v-if="customerDropdownVisible" class="customer-dropdown">
            <div
              v-for="item in customerSearchResults"
              :key="item.id"
              class="customer-option"
              @click="applySelectedCustomer(item)"
            >
              <strong>{{ item.name?.trim() || '未命名' }}</strong>
              <span>{{ item.mobile || '—' }}</span>
              <span>{{ item.code || '—' }}</span>
              <span>{{ item.levelName || '—' }}</span>
              <span>{{ item.storeName || '—' }}</span>
            </div>
            <AppEmpty
              v-if="!customerSearchResults.length"
              title="无匹配客户"
              description="请调整关键字后重试"
            />
          </div>

          <template v-if="contextStatus === 'none'">
            <div class="customer-summary is-empty">未选择客户</div>
            <el-button size="small" @click="openCustomerSelector">选择客户</el-button>
          </template>
          <template v-else-if="contextStatus === 'invalid'">
            <div class="customer-summary is-empty">客户参数无效</div>
            <el-button size="small" @click="openCustomerSelector">选择客户</el-button>
          </template>
          <template v-else-if="contextStatus === 'error'">
            <AppError :description="customerError || '客户加载失败'" @retry="retryLoadCustomer" />
            <el-button size="small" @click="openCustomerSelector">更换客户</el-button>
          </template>
          <template v-else-if="customer">
            <div class="customer-summary">
              <strong>{{ customer.name?.trim() || '未命名客户' }}</strong>
              <span>编号 {{ customer.code || '—' }}</span>
              <span>手机 {{ customer.mobile || '—' }}</span>
              <span>等级 {{ customer.levelName || '—' }}</span>
              <span>门店 {{ customer.storeName || '—' }}</span>
            </div>
            <el-button size="small" @click="openCustomerSelector">更换客户</el-button>
          </template>
        </div>

        <!-- 销售：商品区 -->
        <template v-if="mode === 'sale'">
          <div class="block">
            <div class="block-title">商品搜索</div>
            <div class="row-gap">
              <el-input
                v-model="goodsKeyword"
                clearable
                placeholder="名称 / 别名 / 关键字"
                @keyup.enter="loadGoods"
                @clear="loadGoods"
              />
              <el-button type="primary" :loading="goodsLoading" @click="loadGoods">查询</el-button>
            </div>
            <div class="type-filters">
              <el-radio-group v-model="goodsItemType" size="small">
                <el-radio-button
                  v-for="opt in ITEM_TYPE_OPTIONS"
                  :key="opt.value || 'all'"
                  :value="opt.value"
                >
                  {{ opt.label }}
                </el-radio-button>
              </el-radio-group>
            </div>
            <div class="row-gap">
              <span class="field-label">销售渠道</span>
              <el-select
                v-model="saleChannelId"
                clearable
                filterable
                placeholder="整单渠道（项目必选）"
                style="flex: 1"
              >
                <el-option
                  v-for="ch in channelOptions"
                  :key="ch.id"
                  :label="ch.name || ch.code || String(ch.id)"
                  :value="ch.id"
                />
              </el-select>
            </div>
          </div>

          <div class="block category-block" v-if="goodsItemType === 'PROJECT' || !goodsItemType">
            <div class="block-title">项目类型（归类，非销售渠道）</div>
            <div class="category-list">
              <button
                type="button"
                class="cat-btn"
                :class="{ active: selectedCategoryId == null }"
                @click="onCategorySelect(null)"
              >
                全部
              </button>
              <template v-for="root in categoryTree" :key="root.id">
                <button
                  type="button"
                  class="cat-btn"
                  :class="{ active: selectedCategoryId === root.id }"
                  @click="onCategorySelect(root.id)"
                >
                  {{ root.name || `分类#${root.id}` }}
                </button>
                <button
                  v-for="child in root.children || []"
                  :key="child.id"
                  type="button"
                  class="cat-btn is-child"
                  :class="{ active: selectedCategoryId === child.id }"
                  @click="onCategorySelect(child.id)"
                >
                  {{ child.name || `分类#${child.id}` }}
                </button>
              </template>
            </div>
          </div>

          <div class="block goods-block" v-loading="goodsLoading">
            <div class="block-title">
              可选商品
              <span v-if="selectedChannel" class="sub">渠道 {{ selectedChannel.name }}</span>
            </div>
            <AppError v-if="goodsError" :description="goodsError" @retry="loadGoods" />
            <el-table
              v-else
              :data="filteredGoods"
              size="small"
              height="100%"
              border
              empty-text="暂无数据"
            >
              <el-table-column label="名称" min-width="120" show-overflow-tooltip>
                <template #default="{ row }">{{ row.name || '—' }}</template>
              </el-table-column>
              <el-table-column label="类型" width="88">
                <template #default="{ row }">{{ itemTypeLabel(row.itemType) }}</template>
              </el-table-column>
              <el-table-column label="分类" width="90" show-overflow-tooltip>
                <template #default="{ row }">{{ row.categoryName || '—' }}</template>
              </el-table-column>
              <el-table-column label="价格" width="80" align="right">
                <template #default="{ row }">
                  <template v-if="row.itemType === 'PROJECT' && !saleChannelId">选渠道</template>
                  <template v-else>¥ {{ formatAmountDisplay(row.price) }}</template>
                </template>
              </el-table-column>
              <el-table-column label="可售" width="64" align="center">
                <template #default="{ row }">
                  <el-tag size="small" :type="row.sellable === false ? 'info' : 'success'">
                    {{ row.sellable === false ? '否' : '是' }}
                  </el-tag>
                </template>
              </el-table-column>
              <el-table-column label="" width="64" align="center" fixed="right">
                <template #default="{ row }">
                  <el-button
                    link
                    type="primary"
                    size="small"
                    :disabled="!customerReady || row.sellable === false"
                    @click="addSaleGoods(row)"
                  >
                    加入
                  </el-button>
                </template>
              </el-table-column>
            </el-table>
          </div>
        </template>

        <!-- 消耗：资产区 -->
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

      <!-- 右侧 -->
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

            <el-table
              v-if="mode === 'sale'"
              :data="saleLines"
              size="small"
              border
              empty-text="尚未加入销售明细"
            >
              <el-table-column label="名称" min-width="120" show-overflow-tooltip>
                <template #default="{ row }">{{ row.name }}</template>
              </el-table-column>
              <el-table-column label="类型" width="88">
                <template #default="{ row }">{{ itemTypeLabel(row.itemType) }}</template>
              </el-table-column>
              <el-table-column label="数量" width="100">
                <template #default="{ row }">
                  <el-input-number v-model="row.quantity" :min="1" :max="999" size="small" />
                </template>
              </el-table-column>
              <el-table-column label="单价" width="90" align="right">
                <template #default="{ row }">¥ {{ formatAmountDisplay(row.price) }}</template>
              </el-table-column>
              <el-table-column label="状态" width="80">
                <template #default="{ row }">{{ row.status }}</template>
              </el-table-column>
              <el-table-column label="操作" width="120" align="center" fixed="right">
                <template #default="{ row }">
                  <el-button
                    v-if="row.allowAdjust && row.itemType === 'PROJECT'"
                    link
                    type="warning"
                    size="small"
                    @click="openAdjust(row)"
                  >
                    改价
                  </el-button>
                  <el-button link type="danger" size="small" @click="removeSaleLine(row.key)">
                    删除
                  </el-button>
                </template>
              </el-table-column>
            </el-table>

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

          <div class="block">
            <div class="block-title">经手人 / 分单比例</div>
            <CashierHandlerEditor
              v-model="handlers"
              :biz-type="handlerBizType"
              :store-id="currentStoreId"
            />
          </div>
        </div>

        <footer class="footer-bar">
          <template v-if="mode === 'sale'">
            <div class="sums">
              <span>明细 {{ saleSummary.count }}</span>
              <span>商品金额 ¥{{ saleSummary.goodsAmount }}</span>
              <span>赠送 ¥{{ saleSummary.giftAmount }}</span>
              <span>欠款 ¥{{ saleSummary.arrearAmount }}</span>
              <strong>待收款 ¥{{ saleSummary.payable }}</strong>
            </div>
            <el-button class="checkout-btn" type="primary" @click="onCheckoutPlaceholder">
              结账
            </el-button>
          </template>
          <template v-else>
            <div class="sums">
              <span>消耗项 {{ consumeSummary.count }}</span>
              <span>储值扣款行 {{ consumeSummary.savingCount }}</span>
              <strong>扣款金额：提交时后端计算</strong>
            </div>
            <el-button class="checkout-btn" type="primary" @click="onSubmitConsumePlaceholder">
              提交消耗
            </el-button>
          </template>
        </footer>
      </section>
    </div>

    <SaleCustomerSelector v-model="selectorVisible" @select="applySelectedCustomer" />

    <SavingConsumeProjectDialog
      v-model="savingDialogVisible"
      :asset="savingDialogAsset"
      @select="onSavingProjectSelect"
    />

    <CashierPriceAdjustDialog
      v-if="adjustLine && saleChannelId != null && currentStoreId != null"
      v-model="adjustVisible"
      :store-id="currentStoreId"
      :item-type="String(adjustLine.itemType)"
      :item-id="adjustLine.itemId"
      :item-name="adjustLine.name"
      :sale-channel-id="saleChannelId"
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
  </section>
</template>

<style scoped>
.workbench {
  --wb-orange: #f08a24;
  --wb-orange-dark: #d46b08;
  --wb-header: #fff4e8;
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
  background: var(--wb-header);
}

.mode-actions {
  display: flex;
  flex-wrap: wrap;
  gap: 6px;
}

.action-btn.el-button--primary {
  --el-button-bg-color: var(--wb-orange);
  --el-button-border-color: var(--wb-orange);
  --el-button-hover-bg-color: var(--wb-orange-dark);
  --el-button-hover-border-color: var(--wb-orange-dark);
}

.mode-badge {
  font-size: 13px;
  color: #606266;
}

.mode-badge strong {
  color: var(--wb-orange-dark);
  margin-right: 12px;
}

.store {
  color: #909399;
}

.panels {
  display: grid;
  grid-template-columns: minmax(280px, 38%) minmax(0, 62%);
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
  color: #a15c1a;
}

.block-title .sub {
  font-weight: 400;
  color: #909399;
  font-size: 12px;
}

.customer-search,
.row-gap {
  display: flex;
  gap: 8px;
  align-items: center;
  margin-bottom: 8px;
}

.customer-dropdown {
  max-height: 180px;
  overflow: auto;
  margin-bottom: 8px;
  border: 1px solid #ebeef5;
}

.customer-option {
  display: grid;
  grid-template-columns: 1.2fr 1fr 1fr 0.8fr 1fr;
  gap: 6px;
  padding: 6px 8px;
  font-size: 12px;
  cursor: pointer;
  border-bottom: 1px solid #f5f5f5;
}

.customer-option:hover {
  background: #fffaf5;
}

.customer-summary {
  display: flex;
  flex-wrap: wrap;
  gap: 6px 12px;
  margin-bottom: 8px;
  font-size: 12px;
  color: #606266;
}

.customer-summary.is-empty {
  color: #909399;
}

.type-filters {
  margin-bottom: 8px;
  overflow-x: auto;
}

.field-label {
  font-size: 12px;
  color: #909399;
  white-space: nowrap;
}

.category-block {
  max-height: 160px;
  overflow: auto;
}

.category-list {
  display: flex;
  flex-direction: column;
}

.cat-btn {
  border: 0;
  border-bottom: 1px solid #f5f5f5;
  background: transparent;
  padding: 6px 8px;
  text-align: left;
  font-size: 12px;
  color: #606266;
  cursor: pointer;
}

.cat-btn.is-child {
  padding-left: 20px;
}

.cat-btn.active {
  background: #fff0e0;
  color: var(--wb-orange-dark);
  font-weight: 600;
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

.tip {
  margin: 0;
  font-size: 12px;
  color: #909399;
  line-height: 1.5;
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

.footer-bar {
  display: flex;
  flex-wrap: wrap;
  gap: 12px;
  align-items: center;
  justify-content: space-between;
  padding: 10px 14px;
  border-top: 1px solid #e8e8e8;
  background: #fffaf5;
}

.sums {
  display: flex;
  flex-wrap: wrap;
  gap: 12px;
  font-size: 13px;
  color: #606266;
}

.sums strong {
  color: var(--wb-orange-dark);
  font-size: 15px;
}

.checkout-btn {
  --el-button-bg-color: var(--wb-orange);
  --el-button-border-color: var(--wb-orange);
  --el-button-hover-bg-color: var(--wb-orange-dark);
  --el-button-hover-border-color: var(--wb-orange-dark);
  min-width: 120px;
}

@media (max-width: 1100px) {
  .panels {
    grid-template-columns: 1fr;
  }

  .workbench {
    height: auto;
  }
}
</style>
