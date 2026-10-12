<script setup lang="ts">
import { computed, onActivated, reactive, ref, watch } from 'vue'

import AppEmpty from '@/components/common/AppEmpty.vue'
import AppError from '@/components/common/AppError.vue'
import CardStoreScopeFields from '@/components/goods/CardStoreScopeFields.vue'
import {
  fetchCardCategoryOptions,
  createPackageCard,
  deactivatePackageCard,
  fetchGeneralCardOptions,
  fetchPackageCardDetail,
  fetchPackageCardList,
  fetchSavingCardOptions,
  fetchTimeCardOptions,
  updatePackageCard,
} from '@/api/card'
import { fetchCardSaleEntities, replaceCardSaleEntities } from '@/api/goods-scope'
import { fetchProductOptions } from '@/api/product'
import { fetchProjectOptions } from '@/api/project'
import { useGoodsStoreOptions } from '@/composables/useGoodsStoreOptions'
import {
  CARD_SORT_FIELDS,
  CardPermission,
  formatCardValidPeriod,
  formatSellStatus,
  type CardCategoryItem,
  type CardSortField,
  type PackageCardItem,
} from '@/types/card'
import type { ProductOption } from '@/types/product'
import type { ProjectItem } from '@/types/project'
import { usePermissionStore } from '@/stores/permission'
import { formatAmountDisplay, normalizeAmountString } from '@/utils/amount'
import {
  getUserFriendlyErrorMessage,
  notifyError,
  runExclusive,
  uiConfirm,
  uiMessage,
} from '@/utils/ui'

defineOptions({ name: 'PackageCardManageView' })

interface ChildLineForm {
  itemId: number | null
  price: string
  amount: number
  largess: boolean
}

const permissionStore = usePermissionStore()
const { storeOptions, storeOptionsError, loadStoreOptions } = useGoodsStoreOptions()

const hasViewPermission = computed(() =>
  permissionStore.hasPermission(CardPermission.PACKAGE_VIEW),
)
const hasEditPermission = computed(() =>
  permissionStore.hasPermission(CardPermission.PACKAGE_EDIT),
)

const SORT_WHITELIST = new Set<string>(CARD_SORT_FIELDS)

const loading = ref(false)
const listError = ref<string | null>(null)
const onlySellable = ref(false)
const categoryFilter = ref<number | null>(null)
const records = ref<PackageCardItem[]>([])
const sortField = ref<CardSortField>('id')
const sortOrder = ref<'asc' | 'desc'>('desc')
const projectOptions = ref<ProjectItem[]>([])
const productOptions = ref<ProductOption[]>([])
const generalOptions = ref<Array<{ id: number; name: string | null }>>([])
const timeOptions = ref<Array<{ id: number; name: string | null }>>([])
const savingOptions = ref<Array<{ id: number; name: string | null }>>([])
const deactivatingIds = ref<Set<number>>(new Set())
const categoryOptions = ref<CardCategoryItem[]>([])
/** 编辑时若当前分类已停用，合并进下拉以免静默清空 */
const inactiveCategoryOption = ref<CardCategoryItem | null>(null)

const formCategoryOptions = computed(() => {
  const opts = [...categoryOptions.value]
  const extra = inactiveCategoryOption.value
  if (extra != null && !opts.some((o) => o.id === extra.id)) {
    opts.unshift({
      id: extra.id,
      name: `${extra.name || extra.id}（已停用）`,
      sequence: extra.sequence,
      active: false,
    })
  }
  return opts
})

async function loadCategoryOptions(): Promise<void> {
  try {
    categoryOptions.value = await fetchCardCategoryOptions('package')
  } catch {
    categoryOptions.value = []
  }
}

function syncInactiveCategoryOption(
  categoryId: number | null | undefined,
  categoryName: string | null | undefined,
): void {
  inactiveCategoryOption.value = null
  if (categoryId == null) {
    return
  }
  if (categoryOptions.value.some((o) => o.id === categoryId)) {
    return
  }
  inactiveCategoryOption.value = {
    id: categoryId,
    name: categoryName ?? String(categoryId),
    sequence: null,
    active: false,
  }
}


const tableDefaultSort = computed(() => ({
  prop: sortField.value,
  order: (sortOrder.value === 'asc' ? 'ascending' : 'descending') as
    | 'ascending'
    | 'descending',
}))

function mapSortField(prop: string | null | undefined): CardSortField | null {
  if (prop == null || prop === '') {
    return null
  }
  if (!SORT_WHITELIST.has(prop)) {
    return null
  }
  return prop as CardSortField
}

const formVisible = ref(false)
const formMode = ref<'create' | 'edit'>('create')
const formLoading = ref(false)
const formSaving = ref(false)
const formError = ref<string | null>(null)
const editingId = ref<number | null>(null)

const form = reactive({
  name: '',
  categoryId: null as number | null,
  price: '',
  validType: 0,
  validDay: null as number | null,
  saleStartDate: '',
  saleEndingDate: '',
  allowSell: true,
  allowLargess: false,
  remark: '',
  projects: [] as ChildLineForm[],
  products: [] as ChildLineForm[],
  generalCards: [] as ChildLineForm[],
  timeCards: [] as ChildLineForm[],
  savingCards: [] as ChildLineForm[],
})

const saleScopeMode = ref<'all' | 'specified'>('all')
const saleEntityIds = ref<number[]>([])
const scopeSaving = ref(false)

async function loadChildOptions(): Promise<void> {
  try {
    const [projects, products, generals, times, savings] = await Promise.all([
      fetchProjectOptions(),
      fetchProductOptions(),
      fetchGeneralCardOptions(),
      fetchTimeCardOptions(),
      fetchSavingCardOptions(),
    ])
    projectOptions.value = projects
    productOptions.value = products
    generalOptions.value = generals
    timeOptions.value = times
    savingOptions.value = savings
  } catch {
    // options 失败不阻断编辑主数据
  }
}

async function loadList(): Promise<void> {
  if (!hasViewPermission.value) {
    records.value = []
    listError.value = '暂无权限查看套餐卡（card:package:view）'
    return
  }
  await runExclusive(loading, async () => {
    listError.value = null
    try {
      records.value = await fetchPackageCardList({
        onlySellable: onlySellable.value ? true : undefined,
        categoryId: categoryFilter.value ?? undefined,
        sortField: sortField.value,
        sortOrder: sortOrder.value,
      })
    } catch (error) {
      records.value = []
      listError.value = getUserFriendlyErrorMessage(error)
    }
  })
}

async function handleSortChange(payload: {
  prop: string | null
  order: 'ascending' | 'descending' | null
}): Promise<void> {
  const mapped = mapSortField(payload.prop)
  if (mapped == null || payload.order == null) {
    sortField.value = 'id'
    sortOrder.value = 'desc'
  } else {
    sortField.value = mapped
    sortOrder.value = payload.order === 'ascending' ? 'asc' : 'desc'
  }
  await loadList()
}

function resetScope(): void {
  saleScopeMode.value = 'all'
  saleEntityIds.value = []
}

async function loadScopes(id: number): Promise<void> {
  const sale = await fetchCardSaleEntities('package', id)
  const saleIds = sale.entityIds ?? []
  saleEntityIds.value = [...saleIds]
  saleScopeMode.value = saleIds.length === 0 ? 'all' : 'specified'
}

function emptyLine(): ChildLineForm {
  return { itemId: null, price: '0', amount: 1, largess: false }
}

/** 收费子项 TotalPrice 默认=Price；赠送不计总价 */
function lineChargeTotal(line: ChildLineForm): number {
  if (line.largess) {
    return 0
  }
  const p = normalizeAmountString(line.price)
  if (p == null) {
    return 0
  }
  const n = Number(p)
  return Number.isFinite(n) ? n : 0
}

const computedPackagePrice = computed(() => {
  let sum = 0
  for (const line of [
    ...form.projects,
    ...form.products,
    ...form.generalCards,
    ...form.timeCards,
    ...form.savingCards,
  ]) {
    if (line.itemId == null) {
      continue
    }
    sum += lineChargeTotal(line)
  }
  return sum.toFixed(2)
})

watch(
  () =>
    [
      ...form.projects.map((l) => [l.itemId, l.price, l.largess] as const),
      ...form.products.map((l) => [l.itemId, l.price, l.largess] as const),
      ...form.generalCards.map((l) => [l.itemId, l.price, l.largess] as const),
      ...form.timeCards.map((l) => [l.itemId, l.price, l.largess] as const),
      ...form.savingCards.map((l) => [l.itemId, l.price, l.largess] as const),
    ] as const,
  () => {
    form.price = computedPackagePrice.value
    for (const groups of [
      form.projects,
      form.products,
      form.generalCards,
      form.timeCards,
      form.savingCards,
    ]) {
      for (const line of groups) {
        if (line.largess) {
          line.price = '0'
        }
      }
    }
  },
  { deep: true },
)

async function openCreate(): Promise<void> {
  formMode.value = 'create'
  editingId.value = null
  form.name = ''
  inactiveCategoryOption.value = null
  form.price = ''
  form.validType = 0
  form.validDay = null
  form.saleStartDate = ''
  form.saleEndingDate = ''
  form.allowSell = true
  form.allowLargess = false
  form.remark = ''
  form.projects = [emptyLine()]
  form.products = []
  form.generalCards = []
  form.timeCards = []
  form.savingCards = []
  formError.value = null
  resetScope()
  formVisible.value = true
  // 打开新建时重新拉分类，避免在其它页新建分类后本页缓存过期
  await loadCategoryOptions()
  form.categoryId = categoryOptions.value[0]?.id ?? null
  void loadChildOptions()
}

function mapItemLines(
  lines: Array<{ itemId: number; price: string | number | null; amount: number | null; largess: boolean | null }> | null,
): ChildLineForm[] {
  if (lines == null || lines.length === 0) {
    return []
  }
  return lines.map((l) => ({
    itemId: l.itemId,
    price:
      l.price == null
        ? '0'
        : typeof l.price === 'number'
          ? l.price.toFixed(2)
          : String(l.price),
    amount: l.amount ?? 1,
    largess: l.largess === true,
  }))
}

async function openEdit(row: PackageCardItem): Promise<void> {
  formMode.value = 'edit'
  editingId.value = row.id
  formError.value = null
  resetScope()
  formVisible.value = true
  formLoading.value = true
  void loadChildOptions()
  void loadStoreOptions()
  try {
    const detail = await fetchPackageCardDetail(row.id)
    form.name = detail.name ?? ''
    form.categoryId = detail.categoryId ?? null
    syncInactiveCategoryOption(detail.categoryId, detail.categoryName)
    form.price =
      detail.price == null
        ? ''
        : typeof detail.price === 'number'
          ? detail.price.toFixed(2)
          : String(detail.price)
    form.validType = detail.validType ?? 0
    form.validDay = detail.validDay
    form.saleStartDate = detail.saleStartDate ?? ''
    form.saleEndingDate = detail.saleEndingDate ?? ''
    form.allowSell = detail.allowSell !== false
    form.allowLargess = detail.allowLargess === true
    form.remark = detail.remark ?? ''
    form.projects =
      detail.projects != null && detail.projects.length > 0
        ? detail.projects.map((l) => ({
            itemId: l.projectId,
            price:
              l.price == null
                ? '0'
                : typeof l.price === 'number'
                  ? l.price.toFixed(2)
                  : String(l.price),
            amount: l.amount ?? 1,
            largess: l.largess === true,
          }))
        : [emptyLine()]
    form.products = mapItemLines(detail.products)
    form.generalCards = mapItemLines(detail.generalCards)
    form.timeCards = mapItemLines(detail.timeCards)
    form.savingCards = mapItemLines(detail.savingCards)
    await loadScopes(row.id)
  } catch (error) {
    notifyError(error)
  } finally {
    formLoading.value = false
  }
}

function validateForm(): string | null {
  if (form.categoryId == null) {
    return '请选择分类'
  }
  if (!form.name.trim()) {
    return '请填写套餐名称'
  }
  const projects = form.projects.filter((l) => l.itemId != null)
  if (formMode.value === 'create' && projects.length === 0) {
    return '套餐卡至少包含一个项目'
  }
  for (const line of [
    ...form.projects,
    ...form.products,
    ...form.generalCards,
    ...form.timeCards,
    ...form.savingCards,
  ]) {
    if (line.itemId == null) {
      continue
    }
    if (line.amount == null || line.amount < 1) {
      return '子项次数须至少为 1'
    }
    if (!line.largess && normalizeAmountString(line.price) == null) {
      return '收费子项价格不合法'
    }
  }
  return null
}

function toChargeLineBody(line: ChildLineForm): {
  itemId: number
  price: string
  amount: number
  totalPrice: string
  largess: boolean
} {
  const largess = line.largess === true
  const price = largess ? '0' : (normalizeAmountString(line.price) ?? '0')
  return {
    itemId: line.itemId as number,
    price,
    amount: line.amount,
    totalPrice: price,
    largess,
  }
}

async function handleSubmit(): Promise<void> {
  const err = validateForm()
  if (err != null) {
    uiMessage.warning(err)
    return
  }
  const price = computedPackagePrice.value
  const projects = form.projects
    .filter((l) => l.itemId != null)
    .map((l) => {
      const body = toChargeLineBody(l)
      return {
        projectId: body.itemId,
        price: body.price,
        amount: body.amount,
        totalPrice: body.totalPrice,
        largess: body.largess,
      }
    })
  // 编辑时始终传非 null 集合，语义=全量替换；创建同理
  const body = {
    name: form.name.trim(),
    categoryId: form.categoryId,
    price,
    validType: form.validType,
    validDay: form.validDay,
    saleStartDate: form.saleStartDate || null,
    saleEndingDate: form.saleEndingDate || null,
    allowSell: form.allowSell,
    allowLargess: form.allowLargess,
    remark: form.remark.trim() || null,
    projects,
    products: form.products.filter((l) => l.itemId != null).map(toChargeLineBody),
    generalCards: form.generalCards.filter((l) => l.itemId != null).map(toChargeLineBody),
    timeCards: form.timeCards.filter((l) => l.itemId != null).map(toChargeLineBody),
    savingCards: form.savingCards.filter((l) => l.itemId != null).map(toChargeLineBody),
  }
  await runExclusive(formSaving, async () => {
    formError.value = null
    try {
      if (formMode.value === 'create') {
        const created = await createPackageCard(body)
        editingId.value = created.id
        formMode.value = 'edit'
        resetScope()
        await loadStoreOptions()
        await loadScopes(created.id)
        uiMessage.success('套餐卡已创建，可配置销售范围后再次保存')
        await loadList()
      } else if (editingId.value != null) {
        await updatePackageCard(editingId.value, body)
        await runExclusive(scopeSaving, async () => {
          await replaceCardSaleEntities('package', editingId.value!, {
            entityIds: saleScopeMode.value === 'all' ? [] : [...saleEntityIds.value],
          })
        })
        uiMessage.success('套餐卡已保存')
        formVisible.value = false
        await loadList()
      }
    } catch (error) {
      formError.value = getUserFriendlyErrorMessage(error)
      notifyError(error)
    }
  })
}

async function handleDeactivate(row: PackageCardItem): Promise<void> {
  if (!hasEditPermission.value || row.allowSell === false) {
    return
  }
  const ok = await uiConfirm({
    title: '停售套餐卡',
    message: `确认停售「${row.name || row.id}」？停售后不会出现在 options。`,
    confirmText: '停售',
  })
  if (!ok) {
    return
  }
  const id = row.id
  deactivatingIds.value = new Set(deactivatingIds.value).add(id)
  try {
    await deactivatePackageCard(id)
    uiMessage.success('已停售')
    await loadList()
  } catch (error) {
    notifyError(error)
  } finally {
    const next = new Set(deactivatingIds.value)
    next.delete(id)
    deactivatingIds.value = next
  }
}

function rowOf(row: unknown): PackageCardItem {
  return row as PackageCardItem
}

function childCount(row: PackageCardItem): string {
  const n =
    (row.projects?.length ?? 0) +
    (row.products?.length ?? 0) +
    (row.generalCards?.length ?? 0) +
    (row.timeCards?.length ?? 0) +
    (row.savingCards?.length ?? 0)
  return String(n)
}

watch(hasViewPermission, () => {
  void loadChildOptions()
  void loadCategoryOptions()
  void loadList()
}, { immediate: true })

/** keepAlive 返回本页时刷新分类下拉（例如刚在分类页新建过） */
onActivated(() => {
  void loadCategoryOptions()
})
</script>

<template>
  <section class="card-manage">
    <header class="page-header">
      <div>
        <h1>套餐卡</h1>
        <p class="subtitle">支持项目/产品/次卡/时效卡/储值卡子项；无消耗范围（后端无套餐 ConsumeEntity）</p>
      </div>
      <el-button v-permission="CardPermission.PACKAGE_EDIT" type="primary" @click="openCreate">
        新增套餐卡
      </el-button>
    </header>

    <form class="toolbar" @submit.prevent="loadList">
      <el-checkbox v-model="onlySellable">仅可售</el-checkbox>
      <el-select
        v-model="categoryFilter"
        clearable
        filterable
        placeholder="分类筛选"
        style="width: 180px"
      >
        <el-option
          v-for="opt in categoryOptions"
          :key="opt.id"
          :label="opt.name || String(opt.id)"
          :value="opt.id"
        />
      </el-select>
      <el-button type="primary" native-type="submit" :loading="loading">查询</el-button>
    </form>

    <div v-loading="loading" class="table-panel">
      <AppError v-if="listError && !loading" :description="listError" @retry="loadList" />
      <template v-else>
        <el-table
          :data="records"
          border
          stripe
          size="small"
          empty-text=" "
          :default-sort="tableDefaultSort"
          @sort-change="handleSortChange"
        >
          <el-table-column
            prop="name"
            label="套餐名称"
            min-width="140"
            sortable="custom"
            show-overflow-tooltip
          >
            <template #default="{ row }">{{ rowOf(row).name || '—' }}</template>
          </el-table-column>
          <el-table-column label="分类" min-width="120" show-overflow-tooltip>
            <template #default="{ row }">
              {{ rowOf(row).categoryName || (rowOf(row).categoryId != null ? `#${rowOf(row).categoryId}` : '—') }}
            </template>
          </el-table-column>
          <el-table-column prop="price" label="售价" min-width="100" align="right" sortable="custom">
            <template #default="{ row }">{{ formatAmountDisplay(rowOf(row).price) }}</template>
          </el-table-column>
          <el-table-column label="有效期" min-width="120">
            <template #default="{ row }">
              {{ formatCardValidPeriod(rowOf(row).validType, rowOf(row).validDay) }}
            </template>
          </el-table-column>
          <el-table-column label="子项数" width="80" align="right">
            <template #default="{ row }">{{ childCount(rowOf(row)) }}</template>
          </el-table-column>
          <el-table-column prop="allowSell" label="状态" width="90" sortable="custom">
            <template #default="{ row }">
              <el-tag :type="rowOf(row).allowSell === false ? 'info' : 'success'" size="small">
                {{ formatSellStatus(rowOf(row).allowSell) }}
              </el-tag>
            </template>
          </el-table-column>
          <el-table-column label="操作" width="160" fixed="right">
            <template #default="{ row }">
              <el-button
                v-permission="CardPermission.PACKAGE_EDIT"
                link
                type="primary"
                @click="openEdit(rowOf(row))"
              >
                编辑
              </el-button>
              <el-button
                v-if="hasEditPermission && rowOf(row).allowSell !== false"
                link
                type="warning"
                :disabled="deactivatingIds.has(rowOf(row).id)"
                @click="handleDeactivate(rowOf(row))"
              >
                停售
              </el-button>
            </template>
          </el-table-column>
        </el-table>
        <AppEmpty
          v-if="!loading && !listError && records.length === 0"
          title="暂无套餐卡"
          description="可点击「新增套餐卡」创建"
        />
      </template>
    </div>

    <el-dialog
      v-model="formVisible"
      :title="formMode === 'create' ? '新增套餐卡' : '编辑套餐卡'"
      width="820px"
      destroy-on-close
      :close-on-click-modal="false"
    >
      <div v-loading="formLoading">
        <AppError v-if="formError" :description="formError" />
        <el-form label-width="110px" @submit.prevent>
          <el-form-item label="套餐名称" required>
            <el-input v-model="form.name" maxlength="50" show-word-limit />
          </el-form-item>
          <el-form-item label="分类" required>
            <el-select
              v-model="form.categoryId"
              filterable
              clearable
              placeholder="请选择分类"
              style="width: 100%"
            >
              <el-option
                v-for="opt in formCategoryOptions"
                :key="opt.id"
                :label="opt.name || String(opt.id)"
                :value="opt.id"
              />
            </el-select>
          </el-form-item>
          <el-form-item label="套餐总价">
            <el-input :model-value="computedPackagePrice" readonly placeholder="由非赠送子项自动汇总" />
          </el-form-item>
          <el-form-item label="有效期类型">
            <el-input-number v-model="form.validType" :precision="0" style="width: 100%" />
          </el-form-item>
          <el-form-item label="有效天数">
            <el-input-number v-model="form.validDay" :min="0" :precision="0" style="width: 100%" />
          </el-form-item>
          <el-form-item label="允许销售">
            <el-switch v-model="form.allowSell" />
          </el-form-item>
          <el-form-item label="允许赠送">
            <el-switch v-model="form.allowLargess" />
          </el-form-item>

          <el-divider content-position="left">项目子项（至少 1 个，创建时必填）</el-divider>
          <div v-for="(line, index) in form.projects" :key="'pj-' + index" class="line-row">
            <el-select v-model="line.itemId" filterable placeholder="项目" style="flex: 1.3">
              <el-option
                v-for="p in projectOptions"
                :key="p.id"
                :label="p.name || String(p.id)"
                :value="p.id"
              />
            </el-select>
            <el-input
              v-model="line.price"
              placeholder="子项价格"
              style="width: 100px"
              :disabled="line.largess"
            />
            <el-input-number v-model="line.amount" :min="1" :precision="0" controls-position="right" />
            <span class="tip-inline">次数</span>
            <el-checkbox v-model="line.largess">赠送</el-checkbox>
            <el-button link type="danger" @click="form.projects.splice(index, 1)">删</el-button>
          </div>
          <el-button class="add-line" @click="form.projects.push(emptyLine())">添加项目</el-button>

          <el-divider content-position="left">产品子项</el-divider>
          <div v-for="(line, index) in form.products" :key="'pd-' + index" class="line-row">
            <el-select v-model="line.itemId" filterable placeholder="产品" style="flex: 1.3">
              <el-option
                v-for="p in productOptions"
                :key="p.id"
                :label="p.name || String(p.id)"
                :value="p.id"
              />
            </el-select>
            <el-input
              v-model="line.price"
              placeholder="子项价格"
              style="width: 100px"
              :disabled="line.largess"
            />
            <el-input-number v-model="line.amount" :min="1" :precision="0" controls-position="right" />
            <span class="tip-inline">次数</span>
            <el-checkbox v-model="line.largess">赠送</el-checkbox>
            <el-button link type="danger" @click="form.products.splice(index, 1)">删</el-button>
          </div>
          <el-button class="add-line" @click="form.products.push(emptyLine())">添加产品</el-button>

          <el-divider content-position="left">通用次卡子项</el-divider>
          <div v-for="(line, index) in form.generalCards" :key="'gc-' + index" class="line-row">
            <el-select v-model="line.itemId" filterable placeholder="次卡" style="flex: 1.3">
              <el-option
                v-for="p in generalOptions"
                :key="p.id"
                :label="p.name || String(p.id)"
                :value="p.id"
              />
            </el-select>
            <el-input
              v-model="line.price"
              placeholder="子项价格"
              style="width: 100px"
              :disabled="line.largess"
            />
            <el-input-number v-model="line.amount" :min="1" :precision="0" controls-position="right" />
            <span class="tip-inline">次数</span>
            <el-checkbox v-model="line.largess">赠送</el-checkbox>
            <el-button link type="danger" @click="form.generalCards.splice(index, 1)">删</el-button>
          </div>
          <el-button class="add-line" @click="form.generalCards.push(emptyLine())">添加次卡</el-button>

          <el-divider content-position="left">时效卡子项</el-divider>
          <div v-for="(line, index) in form.timeCards" :key="'tc-' + index" class="line-row">
            <el-select v-model="line.itemId" filterable placeholder="时效卡" style="flex: 1.3">
              <el-option
                v-for="p in timeOptions"
                :key="p.id"
                :label="p.name || String(p.id)"
                :value="p.id"
              />
            </el-select>
            <el-input
              v-model="line.price"
              placeholder="子项价格"
              style="width: 100px"
              :disabled="line.largess"
            />
            <el-input-number v-model="line.amount" :min="1" :precision="0" controls-position="right" />
            <span class="tip-inline">次数</span>
            <el-checkbox v-model="line.largess">赠送</el-checkbox>
            <el-button link type="danger" @click="form.timeCards.splice(index, 1)">删</el-button>
          </div>
          <el-button class="add-line" @click="form.timeCards.push(emptyLine())">添加时效卡</el-button>

          <el-divider content-position="left">储值卡子项</el-divider>
          <div v-for="(line, index) in form.savingCards" :key="'sc-' + index" class="line-row">
            <el-select v-model="line.itemId" filterable placeholder="储值卡" style="flex: 1.3">
              <el-option
                v-for="p in savingOptions"
                :key="p.id"
                :label="p.name || String(p.id)"
                :value="p.id"
              />
            </el-select>
            <el-input
              v-model="line.price"
              placeholder="子项价格"
              style="width: 100px"
              :disabled="line.largess"
            />
            <el-input-number v-model="line.amount" :min="1" :precision="0" controls-position="right" />
            <span class="tip-inline">次数</span>
            <el-checkbox v-model="line.largess">赠送</el-checkbox>
            <el-button link type="danger" @click="form.savingCards.splice(index, 1)">删</el-button>
          </div>
          <el-button class="add-line" @click="form.savingCards.push(emptyLine())">添加储值卡</el-button>

          <el-form-item label="备注">
            <el-input v-model="form.remark" type="textarea" :rows="2" />
          </el-form-item>

          <template v-if="formMode === 'edit' && editingId != null">
            <el-divider content-position="left">销售范围</el-divider>
            <CardStoreScopeFields
              v-model:sale-mode="saleScopeMode"
              v-model:sale-entity-ids="saleEntityIds"
              :store-options="storeOptions"
              :store-options-error="storeOptionsError"
              :editable="hasEditPermission"
              :show-consume="false"
            />
          </template>
        </el-form>
      </div>
      <template #footer>
        <el-button :disabled="formSaving || scopeSaving" @click="formVisible = false">取消</el-button>
        <el-button
          type="primary"
          :loading="formSaving || scopeSaving"
          :disabled="!hasEditPermission || formLoading"
          @click="handleSubmit"
        >
          保存
        </el-button>
      </template>
    </el-dialog>
  </section>
</template>

<style scoped>
.card-manage {
  display: flex;
  flex-direction: column;
  gap: 16px;
  min-height: 100%;
  padding: 20px 24px 24px;
}
.page-header {
  display: flex;
  flex-wrap: wrap;
  gap: 12px;
  align-items: flex-start;
  justify-content: space-between;
}
.page-header h1 {
  margin: 0 0 4px;
  font-size: 20px;
  font-weight: 600;
  color: #303133;
}
.subtitle {
  margin: 0;
  font-size: 13px;
  color: #909399;
}
.toolbar {
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
  align-items: center;
}
.table-panel {
  min-height: 240px;
  padding: 16px;
  border: 1px solid #ebeef5;
  border-radius: 8px;
  background: #fff;
}
.line-row {
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
  align-items: center;
  margin-bottom: 8px;
}
.tip-inline {
  font-size: 12px;
  color: #909399;
  white-space: nowrap;
}
.add-line {
  margin-bottom: 12px;
}
</style>
