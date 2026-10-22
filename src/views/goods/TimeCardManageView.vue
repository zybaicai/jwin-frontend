<script setup lang="ts">
import { computed, onActivated, reactive, ref, watch } from 'vue'

import AppEmpty from '@/components/common/AppEmpty.vue'
import AppError from '@/components/common/AppError.vue'
import CardStoreScopeFields from '@/components/goods/CardStoreScopeFields.vue'
import {
  fetchCardCategoryOptions,
  createTimeCard,
  deactivateTimeCard,
  fetchTimeCardDetail,
  fetchTimeCardList,
  updateTimeCard,
} from '@/api/card'
import {
  fetchCardConsumeEntities,
  fetchCardSaleEntities,
  replaceCardConsumeEntities,
  replaceCardSaleEntities,
} from '@/api/goods-scope'
import { fetchProjectOptions } from '@/api/project'
import { useGoodsStoreOptions } from '@/composables/useGoodsStoreOptions'
import {
  CARD_SORT_FIELDS,
  CardPermission,
  formatCardValidPeriod,
  formatSellStatus,
  type CardCategoryItem,
  type CardSortField,
  type TimeCardItem,
} from '@/types/card'
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

defineOptions({ name: 'TimeCardManageView' })

const permissionStore = usePermissionStore()
const { storeOptions, storeOptionsError, loadStoreOptions } = useGoodsStoreOptions()

const hasViewPermission = computed(() =>
  permissionStore.hasPermission(CardPermission.TIME_VIEW),
)
const hasEditPermission = computed(() =>
  permissionStore.hasPermission(CardPermission.TIME_EDIT),
)

const SORT_WHITELIST = new Set<string>(CARD_SORT_FIELDS)

const loading = ref(false)
const listError = ref<string | null>(null)
const onlySellable = ref(false)
const categoryFilter = ref<number | null>(null)
const records = ref<TimeCardItem[]>([])
const sortField = ref<CardSortField>('id')
const sortOrder = ref<'asc' | 'desc'>('desc')
const projectOptions = ref<ProjectItem[]>([])
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
    categoryOptions.value = await fetchCardCategoryOptions('time')
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
  consumeCycle: 0,
  cycleLimitAmount: 0,
  performanceAmount: 0,
  validType: 0,
  validDay: null as number | null,
  saleStartDate: '',
  saleEndingDate: '',
  allowSell: true,
  allowLargess: false,
  remark: '',
  projectIds: [] as number[],
})

const saleScopeMode = ref<'all' | 'specified'>('all')
const consumeScopeMode = ref<'all' | 'specified'>('all')
const saleEntityIds = ref<number[]>([])
const consumeEntityIds = ref<number[]>([])
const scopeSaving = ref(false)

async function loadProjectOptions(): Promise<void> {
  try {
    projectOptions.value = await fetchProjectOptions()
  } catch {
    projectOptions.value = []
  }
}

async function loadList(): Promise<void> {
  if (!hasViewPermission.value) {
    records.value = []
    listError.value = '暂无权限查看时效卡（card:time:view）'
    return
  }
  await runExclusive(loading, async () => {
    listError.value = null
    try {
      records.value = await fetchTimeCardList({
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
  consumeScopeMode.value = 'all'
  saleEntityIds.value = []
  consumeEntityIds.value = []
}

async function loadScopes(id: number): Promise<void> {
  const [sale, consume] = await Promise.all([
    fetchCardSaleEntities('time', id),
    fetchCardConsumeEntities('time', id),
  ])
  const saleIds = sale.entityIds ?? []
  const consumeIds = consume.entityIds ?? []
  saleEntityIds.value = [...saleIds]
  consumeEntityIds.value = [...consumeIds]
  saleScopeMode.value = saleIds.length === 0 ? 'all' : 'specified'
  consumeScopeMode.value = consumeIds.length === 0 ? 'all' : 'specified'
}

async function openCreate(): Promise<void> {
  formMode.value = 'create'
  editingId.value = null
  form.name = ''
  inactiveCategoryOption.value = null
  form.price = ''
  form.consumeCycle = 0
  form.cycleLimitAmount = 0
  form.performanceAmount = 0
  form.validType = 0
  form.validDay = null
  form.saleStartDate = ''
  form.saleEndingDate = ''
  form.allowSell = true
  form.allowLargess = false
  form.remark = ''
  form.projectIds = []
  formError.value = null
  resetScope()
  formVisible.value = true
  await loadCategoryOptions()
  form.categoryId = categoryOptions.value[0]?.id ?? null
  void loadProjectOptions()
}

async function openEdit(row: TimeCardItem): Promise<void> {
  formMode.value = 'edit'
  editingId.value = row.id
  formError.value = null
  resetScope()
  formVisible.value = true
  formLoading.value = true
  void loadProjectOptions()
  void loadStoreOptions()
  try {
    const detail = await fetchTimeCardDetail(row.id)
    form.name = detail.name ?? ''
    form.categoryId = detail.categoryId ?? null
    syncInactiveCategoryOption(detail.categoryId, detail.categoryName)
    form.price =
      detail.price == null
        ? ''
        : typeof detail.price === 'number'
          ? detail.price.toFixed(2)
          : String(detail.price)
    form.consumeCycle = detail.consumeCycle ?? 0
    form.cycleLimitAmount = detail.cycleLimitAmount ?? 0
    form.performanceAmount = detail.performanceAmount ?? 0
    form.validType = detail.validType ?? 0
    form.validDay = detail.validDay
    form.saleStartDate = detail.saleStartDate ?? ''
    form.saleEndingDate = detail.saleEndingDate ?? ''
    form.allowSell = detail.allowSell !== false
    form.allowLargess = detail.allowLargess === true
    form.remark = detail.remark ?? ''
    form.projectIds = [...(detail.projectIds ?? [])]
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
    return '请填写名称'
  }
  if (normalizeAmountString(form.price) == null) {
    return '请填写合法售价'
  }
  return null
}

async function saveScopes(id: number): Promise<void> {
  await Promise.all([
    replaceCardSaleEntities('time', id, {
      entityIds: saleScopeMode.value === 'all' ? [] : [...saleEntityIds.value],
    }),
    replaceCardConsumeEntities('time', id, {
      entityIds: consumeScopeMode.value === 'all' ? [] : [...consumeEntityIds.value],
    }),
  ])
}

async function handleSubmit(): Promise<void> {
  const err = validateForm()
  if (err != null) {
    uiMessage.warning(err)
    return
  }
  const price = normalizeAmountString(form.price)
  if (price == null) {
    return
  }
  const body = {
    name: form.name.trim(),
    categoryId: form.categoryId,
    price,
    consumeCycle: form.consumeCycle,
    cycleLimitAmount: form.cycleLimitAmount,
    performanceAmount: form.performanceAmount,
    validType: form.validType,
    validDay: form.validDay,
    saleStartDate: form.saleStartDate || null,
    saleEndingDate: form.saleEndingDate || null,
    allowSell: form.allowSell,
    allowLargess: form.allowLargess,
    remark: form.remark.trim() || null,
    projectIds: [...form.projectIds],
  }
  await runExclusive(formSaving, async () => {
    formError.value = null
    try {
      if (formMode.value === 'create') {
        const created = await createTimeCard(body)
        editingId.value = created.id
        formMode.value = 'edit'
        resetScope()
        await loadStoreOptions()
        await loadScopes(created.id)
        uiMessage.success('时效卡已创建，可配置范围后再次保存')
        await loadList()
      } else if (editingId.value != null) {
        await updateTimeCard(editingId.value, body)
        await runExclusive(scopeSaving, async () => {
          await saveScopes(editingId.value!)
        })
        uiMessage.success('时效卡与范围已保存')
        formVisible.value = false
        await loadList()
      }
    } catch (error) {
      formError.value = getUserFriendlyErrorMessage(error)
      notifyError(error)
    }
  })
}

async function handleDeactivate(row: TimeCardItem): Promise<void> {
  if (!hasEditPermission.value || row.allowSell === false) {
    return
  }
  const ok = await uiConfirm({
    title: '停售时效卡',
    message: `确认停售「${row.name || row.id}」？停售后不会出现在 options。`,
    confirmText: '停售',
  })
  if (!ok) {
    return
  }
  const id = row.id
  deactivatingIds.value = new Set(deactivatingIds.value).add(id)
  try {
    await deactivateTimeCard(id)
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

function rowOf(row: unknown): TimeCardItem {
  return row as TimeCardItem
}

watch(hasViewPermission, () => {
  void loadProjectOptions()
  void loadCategoryOptions()
  void loadList()
}, { immediate: true })

onActivated(() => {
  void loadCategoryOptions()
})
</script>

<template>
  <section class="card-manage">

    <div class="filter-bar">
      <div class="filter-toolbar">
        <el-form :inline="true" class="filter-form" @submit.prevent="loadList">
        <el-form-item label="可售">
          <el-checkbox v-model="onlySellable">仅可售</el-checkbox>
        </el-form-item>
        <el-form-item label="分类">
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
        </el-form-item>
        <el-form-item>
          <el-button type="primary" native-type="submit" :loading="loading">查询</el-button>
        </el-form-item>
        </el-form>
        <el-button
          v-permission="CardPermission.TIME_EDIT"
          class="create-btn"
          type="primary"
          @click="openCreate"
        >
          新增时效卡
        </el-button>
      </div>
    </div>

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
            label="名称"
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
                v-permission="CardPermission.TIME_EDIT"
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
          title="暂无时效卡"
          description="可点击「新增时效卡」创建"
        />
      </template>
    </div>

    <el-dialog
      v-model="formVisible"
      :title="formMode === 'create' ? '新增时效卡' : '编辑时效卡'"
      width="640px"
      destroy-on-close
      :close-on-click-modal="false"
    >
      <div v-loading="formLoading">
        <AppError v-if="formError" :description="formError" />
        <el-form label-width="120px" @submit.prevent>
          <el-form-item label="名称" required>
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
          <el-form-item label="售价" required>
            <el-input v-model="form.price" placeholder="如 198.00" />
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
          <el-form-item label="项目范围">
            <el-select
              v-model="form.projectIds"
              multiple
              filterable
              collapse-tags
              collapse-tags-tooltip
              placeholder="选择适用项目"
              style="width: 100%"
            >
              <el-option
                v-for="p in projectOptions"
                :key="p.id"
                :label="p.name || String(p.id)"
                :value="p.id"
              />
            </el-select>
          </el-form-item>
          <el-form-item label="备注">
            <el-input v-model="form.remark" type="textarea" :rows="2" />
          </el-form-item>

          <template v-if="formMode === 'edit' && editingId != null">
            <el-divider content-position="left">销售范围 / 消耗范围</el-divider>
            <CardStoreScopeFields
              v-model:sale-mode="saleScopeMode"
              v-model:consume-mode="consumeScopeMode"
              v-model:sale-entity-ids="saleEntityIds"
              v-model:consume-entity-ids="consumeEntityIds"
              :store-options="storeOptions"
              :store-options-error="storeOptionsError"
              :editable="hasEditPermission"
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
.filter-bar {
  background: #fff;
  border: 1px solid #ebeef5;
  border-radius: 4px;
  padding: 12px 14px;
}

.filter-toolbar {
  display: flex;
  align-items: flex-start;
  justify-content: space-between;
  gap: 12px;
  flex-wrap: wrap;
}

.filter-form {
  flex: 1;
  margin-bottom: 0;
}

.create-btn {
  flex-shrink: 0;
  margin-top: 2px;
}

.table-panel {
  min-height: 240px;
  padding: 16px;
  border: 1px solid #ebeef5;
  border-radius: 8px;
  background: #fff;
}
</style>
