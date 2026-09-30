<script setup lang="ts">
import { computed, reactive, ref, watch } from 'vue'

import AppEmpty from '@/components/common/AppEmpty.vue'
import AppError from '@/components/common/AppError.vue'
import {
  fetchProjectConsumeEntities,
  fetchProjectSaleEntities,
  replaceProjectConsumeEntities,
  replaceProjectSaleEntities,
} from '@/api/goods-scope'
import {
  createProject,
  deactivateProject,
  fetchProjectCategoryTree,
  fetchProjectDetail,
  fetchProjectPage,
  updateProject,
} from '@/api/project'
import {
  createProjectChannelPrice,
  deactivateProjectChannelPrice,
  fetchProjectChannelPrices,
  updateProjectChannelPrice,
} from '@/api/price'
import { fetchSaleChannelOptions } from '@/api/sale-channel'
import { fetchOrganizationTree, flattenStoreOptions } from '@/api/organization'
import {
  PROJECT_SORT_FIELDS,
  ProjectPermission,
  isProjectDeactivated,
  type ProjectCategoryTreeNode,
  type ProjectItem,
  type ProjectSortField,
} from '@/types/project'
import { PricePermission, type ProjectChannelPriceItem } from '@/types/price'
import type { SaleChannelOption } from '@/types/sale-channel'
import type { StoreOption } from '@/types/goods-scope'
import { usePermissionStore } from '@/stores/permission'
import { useStoreStore } from '@/stores/store'
import { formatAmountDisplay, normalizeAmountString } from '@/utils/amount'
import {
  getUserFriendlyErrorMessage,
  notifyError,
  runExclusive,
  uiConfirm,
  uiMessage,
} from '@/utils/ui'

defineOptions({ name: 'ProjectManageView' })

const SORT_WHITELIST = new Set<string>(PROJECT_SORT_FIELDS)

const permissionStore = usePermissionStore()
const storeStore = useStoreStore()

const hasViewPermission = computed(() =>
  permissionStore.hasPermission(ProjectPermission.VIEW),
)
const hasEditPermission = computed(() =>
  permissionStore.hasPermission(ProjectPermission.EDIT),
)
const hasPriceChannelEdit = computed(() =>
  permissionStore.hasPermission(PricePermission.CHANNEL_EDIT),
)
/** 渠道价写操作须同时具备 project:edit 与 price:channel:edit */
const canEditChannelPrice = computed(
  () => hasEditPermission.value && hasPriceChannelEdit.value,
)
const hasOrgStoreView = computed(() =>
  permissionStore.hasPermission('org:store:view'),
)

const loading = ref(false)
const listError = ref<string | null>(null)
const keywordInput = ref('')
const keyword = ref('')
const categoryFilter = ref<number | null>(null)
const sellableFilter = ref<'' | 'true' | 'false'>('')
const consumableFilter = ref<'' | 'true' | 'false'>('')
const page = ref(1)
const size = ref(20)
const total = ref(0)
const records = ref<ProjectItem[]>([])
const sortField = ref<ProjectSortField>('id')
const sortOrder = ref<'asc' | 'desc'>('asc')
const deactivatingIds = ref<Set<number>>(new Set())

const categoryTree = ref<ProjectCategoryTreeNode[]>([])
/** 新建/编辑用：仅启用分类 */
const activeCategoryTree = ref<ProjectCategoryTreeNode[]>([])

const formVisible = ref(false)
const formMode = ref<'create' | 'edit'>('create')
const formLoading = ref(false)
const formSaving = ref(false)
const formError = ref<string | null>(null)
const editingId = ref<number | null>(null)

const form = reactive({
  name: '',
  alias: '',
  categoryId: null as number | null,
  price: '',
  treatTime: null as number | null,
  allowSell: true,
  allowConsume: true,
  allowLargess: false,
  brandId: null as number | null,
  remark: '',
})

const storeOptions = ref<StoreOption[]>([])
const storeOptionsError = ref<string | null>(null)
const saleEntityIds = ref<number[]>([])
const consumeEntityIds = ref<number[]>([])
const scopeLoading = ref(false)
const scopeSaving = ref(false)
const scopeError = ref<string | null>(null)
/** 空=全部可用；有值=指定适用门店 */
const saleScopeMode = ref<'all' | 'specified'>('all')
const consumeScopeMode = ref<'all' | 'specified'>('all')

const channelPrices = ref<ProjectChannelPriceItem[]>([])
const channelPricesLoading = ref(false)
const channelPricesError = ref<string | null>(null)
const saleChannelOptions = ref<SaleChannelOption[]>([])
const channelFormVisible = ref(false)
const channelFormMode = ref<'create' | 'edit'>('create')
const channelFormSaving = ref(false)
const channelFormError = ref<string | null>(null)
const channelForm = reactive({
  saleChannelId: null as number | null,
  price: '',
  active: true,
  remark: '',
  saleScopeMode: 'all' as 'all' | 'specified',
  consumeScopeMode: 'all' as 'all' | 'specified',
  saleEntityIds: [] as number[],
  consumeEntityIds: [] as number[],
})
const channelDeactivating = ref<Set<number>>(new Set())

const tableDefaultSort = computed(() => ({
  prop: sortField.value,
  order: (sortOrder.value === 'asc' ? 'ascending' : 'descending') as
    | 'ascending'
    | 'descending',
}))

function mapSortField(prop: string | null | undefined): ProjectSortField | null {
  if (prop == null || prop === '') {
    return null
  }
  if (!SORT_WHITELIST.has(prop)) {
    return null
  }
  return prop as ProjectSortField
}

function boolFilter(value: '' | 'true' | 'false'): boolean | undefined {
  if (value === 'true') {
    return true
  }
  if (value === 'false') {
    return false
  }
  return undefined
}

async function loadCategoryTrees(): Promise<void> {
  if (!hasViewPermission.value && !permissionStore.hasPermission(ProjectPermission.CATEGORY_VIEW)) {
    return
  }
  try {
    const [allTree, activeTree] = await Promise.all([
      fetchProjectCategoryTree(false),
      fetchProjectCategoryTree(true),
    ])
    categoryTree.value = allTree
    activeCategoryTree.value = activeTree
  } catch {
    // 分类树失败不阻断列表；表单内会再提示
  }
}

async function loadStoreOptions(): Promise<void> {
  storeOptionsError.value = null
  try {
    if (hasOrgStoreView.value) {
      const tree = await fetchOrganizationTree(true)
      storeOptions.value = flattenStoreOptions(tree)
    } else {
      storeOptions.value = storeStore.availableStores.map((s) => ({
        id: s.id,
        name: s.name,
      }))
      if (storeOptions.value.length === 0) {
        storeOptionsError.value =
          '暂无适用门店选项（需要 org:store:view 拉取全量组织，或当前账号无可访问门店）'
      }
    }
  } catch (error) {
    storeOptions.value = storeStore.availableStores.map((s) => ({
      id: s.id,
      name: s.name,
    }))
    storeOptionsError.value = getUserFriendlyErrorMessage(error)
  }
}

async function loadList(): Promise<void> {
  if (!hasViewPermission.value) {
    records.value = []
    total.value = 0
    listError.value = '暂无权限查看项目（project:view）'
    return
  }
  await runExclusive(loading, async () => {
    listError.value = null
    try {
      const data = await fetchProjectPage({
        keyword: keyword.value.trim() || undefined,
        categoryId: categoryFilter.value ?? undefined,
        sellable: boolFilter(sellableFilter.value),
        consumable: boolFilter(consumableFilter.value),
        sortField: sortField.value,
        sortOrder: sortOrder.value,
        page: page.value,
        size: size.value,
      })
      records.value = data.records ?? []
      total.value = data.total ?? 0
      page.value = data.page || page.value
      size.value = data.size || size.value
      if (total.value > 0 && records.value.length === 0 && page.value > 1) {
        page.value -= 1
        await loadList()
      }
    } catch (error) {
      records.value = []
      total.value = 0
      listError.value = getUserFriendlyErrorMessage(error)
    }
  })
}

function handleSearch(): void {
  keyword.value = keywordInput.value.trim()
  page.value = 1
  void loadList()
}

function handleReset(): void {
  keywordInput.value = ''
  keyword.value = ''
  categoryFilter.value = null
  sellableFilter.value = ''
  consumableFilter.value = ''
  sortField.value = 'id'
  sortOrder.value = 'asc'
  page.value = 1
  void loadList()
}

function handlePageChange(next: number): void {
  page.value = next
  void loadList()
}

function handleSizeChange(next: number): void {
  size.value = next
  page.value = 1
  void loadList()
}

async function handleSortChange(payload: {
  prop: string | null
  order: 'ascending' | 'descending' | null
}): Promise<void> {
  const mapped = mapSortField(payload.prop)
  if (mapped == null || payload.order == null) {
    sortField.value = 'id'
    sortOrder.value = 'asc'
  } else {
    sortField.value = mapped
    sortOrder.value = payload.order === 'ascending' ? 'asc' : 'desc'
  }
  page.value = 1
  await loadList()
}

function resetScopeState(): void {
  saleEntityIds.value = []
  consumeEntityIds.value = []
  saleScopeMode.value = 'all'
  consumeScopeMode.value = 'all'
  scopeError.value = null
}

function resetChannelPriceState(): void {
  channelPrices.value = []
  channelPricesError.value = null
  channelFormVisible.value = false
  channelFormError.value = null
}

async function loadChannelPrices(projectId: number): Promise<void> {
  channelPricesLoading.value = true
  channelPricesError.value = null
  try {
    const [rows, options] = await Promise.all([
      fetchProjectChannelPrices(projectId),
      saleChannelOptions.value.length > 0
        ? Promise.resolve(saleChannelOptions.value)
        : fetchSaleChannelOptions(),
    ])
    channelPrices.value = rows
    if (saleChannelOptions.value.length === 0) {
      saleChannelOptions.value = options
    }
  } catch (error) {
    channelPrices.value = []
    channelPricesError.value = getUserFriendlyErrorMessage(error)
  } finally {
    channelPricesLoading.value = false
  }
}

function formatScopeSummary(ids: number[] | null | undefined): string {
  if (ids == null || ids.length === 0) {
    return '全部可用'
  }
  const names = ids.map((id) => {
    const hit = storeOptions.value.find((s) => s.id === id)
    return hit?.name || String(id)
  })
  return names.join('、')
}

function openChannelCreate(): void {
  if (!canEditChannelPrice.value || editingId.value == null) {
    return
  }
  channelFormMode.value = 'create'
  channelForm.saleChannelId = null
  channelForm.price = form.price || ''
  channelForm.active = true
  channelForm.remark = ''
  channelForm.saleScopeMode = 'all'
  channelForm.consumeScopeMode = 'all'
  channelForm.saleEntityIds = []
  channelForm.consumeEntityIds = []
  channelFormError.value = null
  channelFormVisible.value = true
  if (saleChannelOptions.value.length === 0) {
    void fetchSaleChannelOptions()
      .then((opts) => {
        saleChannelOptions.value = opts
      })
      .catch(() => {
        saleChannelOptions.value = []
      })
  }
}

function openChannelEdit(row: ProjectChannelPriceItem): void {
  if (!canEditChannelPrice.value) {
    return
  }
  channelFormMode.value = 'edit'
  channelForm.saleChannelId = row.saleChannelId
  channelForm.price =
    row.price == null
      ? ''
      : typeof row.price === 'number'
        ? row.price.toFixed(2)
        : String(row.price)
  channelForm.active = row.active !== false
  channelForm.remark = row.remark ?? ''
  const saleIds = row.saleEntityIds ?? []
  const consumeIds = row.consumeEntityIds ?? []
  channelForm.saleEntityIds = [...saleIds]
  channelForm.consumeEntityIds = [...consumeIds]
  channelForm.saleScopeMode = saleIds.length === 0 ? 'all' : 'specified'
  channelForm.consumeScopeMode = consumeIds.length === 0 ? 'all' : 'specified'
  channelFormError.value = null
  channelFormVisible.value = true
}

async function handleChannelSubmit(): Promise<void> {
  if (!canEditChannelPrice.value || editingId.value == null) {
    return
  }
  if (channelForm.saleChannelId == null) {
    channelFormError.value = '请选择销售渠道'
    return
  }
  const price = normalizeAmountString(channelForm.price)
  if (price == null) {
    channelFormError.value = '请填写合法渠道价格'
    return
  }
  await runExclusive(channelFormSaving, async () => {
    channelFormError.value = null
    try {
      if (channelForm.saleScopeMode === 'specified' && channelForm.saleEntityIds.length === 0) {
        channelFormError.value = '指定销售范围时请选择至少一家门店'
        return
      }
      if (
        channelForm.consumeScopeMode === 'specified' &&
        channelForm.consumeEntityIds.length === 0
      ) {
        channelFormError.value = '指定消耗范围时请选择至少一家门店'
        return
      }
      const body = {
        saleChannelId: channelForm.saleChannelId!,
        price,
        active: channelForm.active,
        remark: channelForm.remark.trim() || null,
        saleEntityIds:
          channelForm.saleScopeMode === 'all' ? [] : [...channelForm.saleEntityIds],
        consumeEntityIds:
          channelForm.consumeScopeMode === 'all'
            ? []
            : [...channelForm.consumeEntityIds],
      }
      if (channelFormMode.value === 'create') {
        await createProjectChannelPrice(editingId.value!, body)
        uiMessage.success('渠道价格已新增')
      } else {
        await updateProjectChannelPrice(editingId.value!, body.saleChannelId, body)
        uiMessage.success('渠道价格已保存')
      }
      channelFormVisible.value = false
      await loadChannelPrices(editingId.value!)
    } catch (error) {
      channelFormError.value = getUserFriendlyErrorMessage(error)
    }
  })
}

async function handleChannelDeactivate(row: ProjectChannelPriceItem): Promise<void> {
  if (!canEditChannelPrice.value || editingId.value == null || row.active === false) {
    return
  }
  const ok = await uiConfirm({
    title: '停用确认',
    message: `确认停用渠道「${row.saleChannelName || row.saleChannelId}」的价格配置？停用后收银选该渠道将回落到其他价源/基价。`,
    confirmText: '停用',
  })
  if (!ok) {
    return
  }
  const next = new Set(channelDeactivating.value)
  next.add(row.saleChannelId)
  channelDeactivating.value = next
  try {
    await deactivateProjectChannelPrice(editingId.value, row.saleChannelId)
    uiMessage.success('渠道价格已停用')
    await loadChannelPrices(editingId.value)
  } catch (error) {
    notifyError(error)
  } finally {
    const cleared = new Set(channelDeactivating.value)
    cleared.delete(row.saleChannelId)
    channelDeactivating.value = cleared
  }
}

async function loadScopes(projectId: number): Promise<void> {
  scopeLoading.value = true
  scopeError.value = null
  try {
    const [sale, consume] = await Promise.all([
      fetchProjectSaleEntities(projectId),
      fetchProjectConsumeEntities(projectId),
    ])
    const saleIds = sale.entityIds ?? []
    const consumeIds = consume.entityIds ?? []
    saleEntityIds.value = [...saleIds]
    consumeEntityIds.value = [...consumeIds]
    saleScopeMode.value = saleIds.length === 0 ? 'all' : 'specified'
    consumeScopeMode.value = consumeIds.length === 0 ? 'all' : 'specified'
  } catch (error) {
    scopeError.value = getUserFriendlyErrorMessage(error)
    notifyError(error)
  } finally {
    scopeLoading.value = false
  }
}

function openCreate(): void {
  formMode.value = 'create'
  editingId.value = null
  form.name = ''
  form.alias = ''
  form.categoryId = null
  form.price = ''
  form.treatTime = null
  form.allowSell = true
  form.allowConsume = true
  form.allowLargess = false
  form.brandId = null
  form.remark = ''
  formError.value = null
  resetScopeState()
  resetChannelPriceState()
  formVisible.value = true
  void loadCategoryTrees()
}

async function openEdit(row: ProjectItem): Promise<void> {
  formMode.value = 'edit'
  editingId.value = row.id
  form.name = row.name ?? ''
  form.alias = row.alias ?? ''
  form.categoryId = row.categoryId
  form.price =
    row.price == null ? '' : typeof row.price === 'number' ? row.price.toFixed(2) : String(row.price)
  form.treatTime = row.treatTime
  form.allowSell = row.allowSell !== false
  form.allowConsume = row.allowConsume !== false
  form.allowLargess = row.allowLargess === true
  form.brandId = row.brandId
  form.remark = row.remark ?? ''
  formError.value = null
  resetScopeState()
  resetChannelPriceState()
  formVisible.value = true
  formLoading.value = true
  void loadCategoryTrees()
  void loadStoreOptions()
  try {
    const detail = await fetchProjectDetail(row.id)
    form.name = detail.name ?? ''
    form.alias = detail.alias ?? ''
    form.categoryId = detail.categoryId
    form.price =
      detail.price == null
        ? ''
        : typeof detail.price === 'number'
          ? detail.price.toFixed(2)
          : String(detail.price)
    form.treatTime = detail.treatTime
    form.allowSell = detail.allowSell !== false
    form.allowConsume = detail.allowConsume !== false
    form.allowLargess = detail.allowLargess === true
    form.brandId = detail.brandId
    form.remark = detail.remark ?? ''
    await Promise.all([loadScopes(row.id), loadChannelPrices(row.id)])
  } catch (error) {
    notifyError(error)
  } finally {
    formLoading.value = false
  }
}

function validateForm(): string | null {
  const name = form.name.trim()
  if (!name) {
    return '请填写项目名称'
  }
  if (name.length > 50) {
    return '项目名称最多 50 个字符'
  }
  if (form.categoryId == null) {
    return '请选择分类'
  }
  const price = normalizeAmountString(form.price)
  if (price == null) {
    return '请填写合法基价（非负，最多两位小数）'
  }
  if (form.treatTime != null && (!Number.isInteger(form.treatTime) || form.treatTime < 0)) {
    return '服务时长须为非负整数（分钟）'
  }
  return null
}

async function saveScopes(projectId: number): Promise<void> {
  if (!hasEditPermission.value) {
    return
  }
  const saleIds = saleScopeMode.value === 'all' ? [] : [...saleEntityIds.value]
  const consumeIds = consumeScopeMode.value === 'all' ? [] : [...consumeEntityIds.value]
  await Promise.all([
    replaceProjectSaleEntities(projectId, { entityIds: saleIds }),
    replaceProjectConsumeEntities(projectId, { entityIds: consumeIds }),
  ])
}

async function handleSubmit(): Promise<void> {
  const err = validateForm()
  if (err != null) {
    uiMessage.warning(err)
    return
  }
  const name = form.name.trim()
  const price = normalizeAmountString(form.price)
  const categoryId = form.categoryId
  if (price == null || categoryId == null) {
    return
  }
  await runExclusive(formSaving, async () => {
    formError.value = null
    scopeError.value = null
    try {
      if (formMode.value === 'create') {
        const created = await createProject({
          name,
          alias: form.alias.trim() || null,
          categoryId,
          price,
          treatTime: form.treatTime,
          allowSell: form.allowSell,
          allowConsume: form.allowConsume,
          allowLargess: form.allowLargess,
          brandId: form.brandId,
          remark: form.remark.trim() || null,
        })
        editingId.value = created.id
        formMode.value = 'edit'
        resetScopeState()
        await loadStoreOptions()
        await loadScopes(created.id)
        uiMessage.success('项目已创建，请配置销售/消耗范围后再次保存')
        await loadList()
      } else if (editingId.value != null) {
        await updateProject(editingId.value, {
          name,
          alias: form.alias.trim() || null,
          categoryId,
          price,
          treatTime: form.treatTime,
          allowSell: form.allowSell,
          allowConsume: form.allowConsume,
          allowLargess: form.allowLargess,
          brandId: form.brandId,
          remark: form.remark.trim() || null,
        })
        await runExclusive(scopeSaving, async () => {
          await saveScopes(editingId.value!)
        })
        uiMessage.success('项目与范围已保存')
        formVisible.value = false
        await loadList()
      }
    } catch (error) {
      formError.value = getUserFriendlyErrorMessage(error)
      notifyError(error)
    }
  })
}

async function handleDeactivate(row: ProjectItem): Promise<void> {
  if (!hasEditPermission.value || isProjectDeactivated(row)) {
    return
  }
  const ok = await uiConfirm({
    title: '停用项目',
    message: `确认停用项目「${row.name || row.id}」？停用后将不可售且不可耗（非物理删除）。`,
    confirmText: '停用',
  })
  if (!ok) {
    return
  }
  const id = row.id
  if (deactivatingIds.value.has(id)) {
    return
  }
  deactivatingIds.value = new Set(deactivatingIds.value).add(id)
  try {
    await deactivateProject(id)
    uiMessage.success('项目已停用')
    await loadList()
  } catch (error) {
    notifyError(error)
  } finally {
    const next = new Set(deactivatingIds.value)
    next.delete(id)
    deactivatingIds.value = next
  }
}

function statusLabel(row: ProjectItem): string {
  return isProjectDeactivated(row) ? '停用' : '启用'
}

function yesNo(value: boolean | null | undefined): string {
  if (value === true) {
    return '是'
  }
  if (value === false) {
    return '否'
  }
  return '—'
}

function rowOf(row: unknown): ProjectItem {
  return row as ProjectItem
}

function flattenCategoryOptions(
  nodes: ProjectCategoryTreeNode[],
  prefix = '',
): { id: number; label: string; disabled: boolean }[] {
  const result: { id: number; label: string; disabled: boolean }[] = []
  for (const node of nodes) {
    const label = `${prefix}${node.name || node.id}`
    result.push({
      id: node.id,
      label,
      disabled: node.active === false,
    })
    if (node.children?.length) {
      result.push(...flattenCategoryOptions(node.children, `${label} / `))
    }
  }
  return result
}

const filterCategoryOptions = computed(() => flattenCategoryOptions(categoryTree.value))
const formCategoryOptions = computed(() =>
  flattenCategoryOptions(activeCategoryTree.value).filter((o) => !o.disabled),
)

watch(
  hasViewPermission,
  () => {
    void loadCategoryTrees()
    void loadList()
  },
  { immediate: true },
)
</script>

<template>
  <section class="project-manage">
    <header class="page-header">
      <div>
        <h1>项目管理</h1>
        <p class="subtitle">维护项目主数据与多渠道总部价；开单须配置有效渠道价，每个渠道可独立配置销售/消耗门店范围</p>
      </div>
      <el-button
        v-permission="ProjectPermission.EDIT"
        type="primary"
        @click="openCreate"
      >
        新增项目
      </el-button>
    </header>

    <form class="toolbar" @submit.prevent="handleSearch">
      <el-input
        v-model="keywordInput"
        clearable
        placeholder="项目名称/别名"
        style="max-width: 200px"
      />
      <el-select
        v-model="categoryFilter"
        clearable
        filterable
        placeholder="分类"
        style="width: 200px"
      >
        <el-option
          v-for="opt in filterCategoryOptions"
          :key="opt.id"
          :label="opt.label"
          :value="opt.id"
        />
      </el-select>
      <el-select v-model="sellableFilter" clearable placeholder="可售" style="width: 120px">
        <el-option label="全部" value="" />
        <el-option label="可售" value="true" />
        <el-option label="不可售" value="false" />
      </el-select>
      <el-select v-model="consumableFilter" clearable placeholder="可耗" style="width: 120px">
        <el-option label="全部" value="" />
        <el-option label="可耗" value="true" />
        <el-option label="不可耗" value="false" />
      </el-select>
      <el-button type="primary" native-type="submit" :loading="loading">查询</el-button>
      <el-button native-type="button" :disabled="loading" @click="handleReset">重置</el-button>
    </form>

    <div v-loading="loading" class="table-panel">
      <AppError
        v-if="listError && !loading"
        :description="listError"
        @retry="loadList"
      />
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
            label="项目名称"
            min-width="140"
            sortable="custom"
            show-overflow-tooltip
          >
            <template #default="{ row }">
              {{ rowOf(row).name || '—' }}
            </template>
          </el-table-column>
          <el-table-column label="项目类型/分类" min-width="120" show-overflow-tooltip>
            <template #default="{ row }">
              {{ rowOf(row).categoryName || '—' }}
            </template>
          </el-table-column>
          <el-table-column
            prop="price"
            label="基价"
            min-width="100"
            align="right"
            sortable="custom"
          >
            <template #default="{ row }">
              {{ formatAmountDisplay(rowOf(row).price) }}
            </template>
          </el-table-column>
          <el-table-column label="服务时长" width="100" align="right">
            <template #default="{ row }">
              {{ rowOf(row).treatTime != null ? `${rowOf(row).treatTime} 分` : '—' }}
            </template>
          </el-table-column>
          <el-table-column label="允许销售" width="90" align="center">
            <template #default="{ row }">
              {{ yesNo(rowOf(row).allowSell) }}
            </template>
          </el-table-column>
          <el-table-column label="允许消耗" width="90" align="center">
            <template #default="{ row }">
              {{ yesNo(rowOf(row).allowConsume) }}
            </template>
          </el-table-column>
          <el-table-column label="允许赠送" width="90" align="center">
            <template #default="{ row }">
              {{ yesNo(rowOf(row).allowLargess) }}
            </template>
          </el-table-column>
          <el-table-column label="状态" width="90">
            <template #default="{ row }">
              <el-tag
                :type="isProjectDeactivated(rowOf(row)) ? 'info' : 'success'"
                size="small"
              >
                {{ statusLabel(rowOf(row)) }}
              </el-tag>
            </template>
          </el-table-column>
          <el-table-column label="操作" width="160" fixed="right">
            <template #default="{ row }">
              <el-button
                v-permission="ProjectPermission.EDIT"
                link
                type="primary"
                @click="openEdit(rowOf(row))"
              >
                编辑
              </el-button>
              <el-button
                v-if="hasEditPermission && !isProjectDeactivated(rowOf(row))"
                link
                type="warning"
                :disabled="deactivatingIds.has(rowOf(row).id)"
                @click="handleDeactivate(rowOf(row))"
              >
                停用
              </el-button>
            </template>
          </el-table-column>
        </el-table>

        <AppEmpty
          v-if="!loading && !listError && records.length === 0"
          title="暂无项目"
          description="可点击「新增项目」创建主数据"
        />

        <div v-if="total > 0" class="pager">
          <el-pagination
            background
            layout="total, sizes, prev, pager, next"
            :total="total"
            :current-page="page"
            :page-size="size"
            :page-sizes="[10, 20, 50, 100]"
            @current-change="handlePageChange"
            @size-change="handleSizeChange"
          />
        </div>
      </template>
    </div>

    <el-dialog
      v-model="formVisible"
      :title="formMode === 'create' ? '新增项目' : '编辑项目'"
      width="640px"
      destroy-on-close
      :close-on-click-modal="false"
    >
      <div v-loading="formLoading || scopeLoading">
        <AppError v-if="formError" :description="formError" />
        <el-form label-width="140px" @submit.prevent>
          <el-form-item label="项目名称" required>
            <el-input
              v-model="form.name"
              maxlength="50"
              show-word-limit
              placeholder="请输入项目名称"
            />
          </el-form-item>
          <el-form-item label="别名">
            <el-input v-model="form.alias" maxlength="50" show-word-limit />
          </el-form-item>
          <el-form-item label="项目类型/项目分类" required>
            <el-select
              v-model="form.categoryId"
              filterable
              placeholder="请选择项目分类（仅启用；非销售渠道）"
              style="width: 100%"
            >
              <el-option
                v-for="opt in formCategoryOptions"
                :key="opt.id"
                :label="opt.label"
                :value="opt.id"
              />
            </el-select>
          </el-form-item>
          <el-form-item label="基价" required>
            <el-input v-model="form.price" placeholder="如 199.00" />
          </el-form-item>
          <el-form-item label="服务时长">
            <el-input-number
              v-model="form.treatTime"
              :min="0"
              :step="1"
              :precision="0"
              controls-position="right"
              style="width: 100%"
              placeholder="分钟"
            />
          </el-form-item>
          <el-form-item label="允许销售">
            <el-switch v-model="form.allowSell" />
          </el-form-item>
          <el-form-item label="允许消耗">
            <el-switch v-model="form.allowConsume" />
          </el-form-item>
          <el-form-item label="允许赠送">
            <el-switch v-model="form.allowLargess" />
          </el-form-item>
          <el-form-item label="备注">
            <el-input
              v-model="form.remark"
              type="textarea"
              maxlength="200"
              show-word-limit
              :rows="2"
            />
          </el-form-item>

          <template v-if="formMode === 'edit' && editingId != null">
            <el-divider content-position="left">渠道价格</el-divider>
            <p class="scope-hint">
              同一项目可配置多个销售渠道总部价；每个渠道独立配置销售范围与消耗范围（全部门店 / 指定门店）。
              未配置或已停用的渠道不可选、不可报价、不可开单；空范围表示该渠道全部可用门店。
            </p>
            <AppError v-if="channelPricesError" :description="channelPricesError" />
            <div class="channel-toolbar">
              <el-button
                v-if="canEditChannelPrice"
                type="primary"
                size="small"
                @click="openChannelCreate"
              >
                新增渠道价格
              </el-button>
              <span v-else class="scope-hint">需同时具备 project:edit 与 price:channel:edit 方可编辑</span>
            </div>
            <el-table
              v-loading="channelPricesLoading"
              :data="channelPrices"
              border
              size="small"
              empty-text="暂无渠道价格（未配置有效渠道价时不可按该渠道报价或开单）"
              style="width: 100%; margin-bottom: 12px"
            >
              <el-table-column label="渠道名称" min-width="120" show-overflow-tooltip>
                <template #default="{ row }">
                  {{
                    (row as ProjectChannelPriceItem).saleChannelName
                      || (row as ProjectChannelPriceItem).saleChannelCode
                      || (row as ProjectChannelPriceItem).saleChannelId
                  }}
                </template>
              </el-table-column>
              <el-table-column label="渠道价格" width="100" align="right">
                <template #default="{ row }">
                  {{ formatAmountDisplay((row as ProjectChannelPriceItem).price) }}
                </template>
              </el-table-column>
              <el-table-column label="销售范围" min-width="140" show-overflow-tooltip>
                <template #default="{ row }">
                  {{ formatScopeSummary((row as ProjectChannelPriceItem).saleEntityIds) }}
                </template>
              </el-table-column>
              <el-table-column label="消耗范围" min-width="140" show-overflow-tooltip>
                <template #default="{ row }">
                  {{ formatScopeSummary((row as ProjectChannelPriceItem).consumeEntityIds) }}
                </template>
              </el-table-column>
              <el-table-column label="状态" width="80">
                <template #default="{ row }">
                  <el-tag
                    :type="(row as ProjectChannelPriceItem).active === false ? 'info' : 'success'"
                    size="small"
                  >
                    {{ (row as ProjectChannelPriceItem).active === false ? '停用' : '启用' }}
                  </el-tag>
                </template>
              </el-table-column>
              <el-table-column label="操作" width="140" fixed="right">
                <template #default="{ row }">
                  <el-button
                    v-if="canEditChannelPrice"
                    link
                    type="primary"
                    @click="openChannelEdit(row as ProjectChannelPriceItem)"
                  >
                    编辑
                  </el-button>
                  <el-button
                    v-if="canEditChannelPrice && (row as ProjectChannelPriceItem).active !== false"
                    link
                    type="warning"
                    :disabled="channelDeactivating.has((row as ProjectChannelPriceItem).saleChannelId)"
                    @click="handleChannelDeactivate(row as ProjectChannelPriceItem)"
                  >
                    停用
                  </el-button>
                </template>
              </el-table-column>
            </el-table>

            <el-divider content-position="left">销售范围 / 消耗范围（旧数据兼容）</el-divider>
            <p class="scope-hint">
              项目级销售范围仅作历史数据与未带渠道的通用目录展示参考，
              <strong>不能</strong>让未配置有效渠道价的项目继续按该渠道开单。
              项目级消耗范围用于账户无法解析原销售渠道时的耗卡兼容；
              已售资产耗卡不因渠道价后来停用而阻断。
            </p>
            <AppError v-if="scopeError" :description="scopeError" />
            <AppError v-if="storeOptionsError" :description="storeOptionsError" />

            <el-form-item label="销售范围">
              <div class="scope-block">
                <el-radio-group
                  v-model="saleScopeMode"
                  :disabled="!hasEditPermission"
                >
                  <el-radio value="all">全部可用</el-radio>
                  <el-radio value="specified">指定适用门店</el-radio>
                </el-radio-group>
                <el-select
                  v-if="saleScopeMode === 'specified'"
                  v-model="saleEntityIds"
                  multiple
                  filterable
                  collapse-tags
                  collapse-tags-tooltip
                  placeholder="选择适用门店"
                  style="width: 100%; margin-top: 8px"
                  :disabled="!hasEditPermission"
                >
                  <el-option
                    v-for="s in storeOptions"
                    :key="s.id"
                    :label="s.name"
                    :value="s.id"
                  />
                </el-select>
              </div>
            </el-form-item>

            <el-form-item label="消耗范围">
              <div class="scope-block">
                <el-radio-group
                  v-model="consumeScopeMode"
                  :disabled="!hasEditPermission"
                >
                  <el-radio value="all">全部可用</el-radio>
                  <el-radio value="specified">指定适用门店</el-radio>
                </el-radio-group>
                <el-select
                  v-if="consumeScopeMode === 'specified'"
                  v-model="consumeEntityIds"
                  multiple
                  filterable
                  collapse-tags
                  collapse-tags-tooltip
                  placeholder="选择适用门店"
                  style="width: 100%; margin-top: 8px"
                  :disabled="!hasEditPermission"
                >
                  <el-option
                    v-for="s in storeOptions"
                    :key="s.id"
                    :label="s.name"
                    :value="s.id"
                  />
                </el-select>
              </div>
            </el-form-item>
          </template>
        </el-form>
      </div>
      <template #footer>
        <el-button :disabled="formSaving || scopeSaving" @click="formVisible = false">
          取消
        </el-button>
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

    <el-dialog
      v-model="channelFormVisible"
      :title="channelFormMode === 'create' ? '新增渠道价格' : '编辑渠道价格'"
      width="560px"
      destroy-on-close
      :close-on-click-modal="false"
      append-to-body
    >
      <AppError v-if="channelFormError" :description="channelFormError" />
      <el-form label-width="100px" @submit.prevent>
        <el-form-item label="销售渠道" required>
          <el-select
            v-model="channelForm.saleChannelId"
            filterable
            placeholder="选择有效叶子渠道"
            style="width: 100%"
            :disabled="channelFormMode === 'edit' || !canEditChannelPrice"
          >
            <el-option
              v-for="opt in saleChannelOptions"
              :key="opt.id"
              :label="opt.name || opt.code || String(opt.id)"
              :value="opt.id"
            />
          </el-select>
        </el-form-item>
        <el-form-item label="渠道价格" required>
          <el-input
            v-model="channelForm.price"
            placeholder="如 198.00"
            :disabled="!canEditChannelPrice"
          />
        </el-form-item>
        <el-form-item v-if="channelFormMode === 'edit'" label="启用状态">
          <el-switch
            v-model="channelForm.active"
            active-text="启用"
            inactive-text="停用"
            :disabled="!canEditChannelPrice"
          />
        </el-form-item>
        <el-form-item label="销售范围">
          <div class="scope-block">
            <el-radio-group
              v-model="channelForm.saleScopeMode"
              :disabled="!canEditChannelPrice"
            >
              <el-radio value="all">全部门店</el-radio>
              <el-radio value="specified">指定门店</el-radio>
            </el-radio-group>
            <el-select
              v-if="channelForm.saleScopeMode === 'specified'"
              v-model="channelForm.saleEntityIds"
              multiple
              filterable
              collapse-tags
              collapse-tags-tooltip
              placeholder="选择可销售门店"
              style="width: 100%; margin-top: 8px"
              :disabled="!canEditChannelPrice"
            >
              <el-option
                v-for="s in storeOptions"
                :key="s.id"
                :label="s.name"
                :value="s.id"
              />
            </el-select>
          </div>
        </el-form-item>
        <el-form-item label="消耗范围">
          <div class="scope-block">
            <el-radio-group
              v-model="channelForm.consumeScopeMode"
              :disabled="!canEditChannelPrice"
            >
              <el-radio value="all">全部门店</el-radio>
              <el-radio value="specified">指定门店</el-radio>
            </el-radio-group>
            <el-select
              v-if="channelForm.consumeScopeMode === 'specified'"
              v-model="channelForm.consumeEntityIds"
              multiple
              filterable
              collapse-tags
              collapse-tags-tooltip
              placeholder="选择可消耗门店"
              style="width: 100%; margin-top: 8px"
              :disabled="!canEditChannelPrice"
            >
              <el-option
                v-for="s in storeOptions"
                :key="s.id"
                :label="s.name"
                :value="s.id"
              />
            </el-select>
          </div>
        </el-form-item>
        <el-form-item label="备注">
          <el-input
            v-model="channelForm.remark"
            type="textarea"
            :rows="2"
            maxlength="200"
            :disabled="!canEditChannelPrice"
          />
        </el-form-item>
        <p class="scope-hint">
          总部渠道价写 PriceAreaID=0、EntityID=0；销售/消耗门店写入渠道桥接表，不得误用 EntityID 作范围。
        </p>
        <AppError v-if="storeOptionsError" :description="storeOptionsError" />
      </el-form>
      <template #footer>
        <el-button :disabled="channelFormSaving" @click="channelFormVisible = false">取消</el-button>
        <el-button
          v-if="canEditChannelPrice"
          type="primary"
          :loading="channelFormSaving"
          @click="handleChannelSubmit"
        >
          保存
        </el-button>
      </template>
    </el-dialog>
  </section>
</template>

<style scoped>
.project-manage {
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

.pager {
  display: flex;
  justify-content: flex-end;
  margin-top: 12px;
}

.scope-hint {
  margin: 0 0 12px;
  font-size: 12px;
  color: #909399;
}

.scope-block {
  width: 100%;
}

.channel-toolbar {
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
  align-items: center;
  margin-bottom: 8px;
}

.scope-tag {
  margin-left: 4px;
  font-size: 11px;
  color: #a8abb2;
}
</style>
