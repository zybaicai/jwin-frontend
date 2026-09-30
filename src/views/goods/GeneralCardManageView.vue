<script setup lang="ts">
import { computed, reactive, ref, watch } from 'vue'

import AppEmpty from '@/components/common/AppEmpty.vue'
import AppError from '@/components/common/AppError.vue'
import CardStoreScopeFields from '@/components/goods/CardStoreScopeFields.vue'
import {
  fetchCardCategoryOptions,
  createGeneralCard,
  deactivateGeneralCard,
  fetchGeneralCardDetail,
  fetchGeneralCardList,
  updateGeneralCard,
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
  type GeneralCardItem,
  type GeneralCardProjectLine,
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

defineOptions({ name: 'GeneralCardManageView' })

const permissionStore = usePermissionStore()
const { storeOptions, storeOptionsError, loadStoreOptions } = useGoodsStoreOptions()

const hasViewPermission = computed(() =>
  permissionStore.hasPermission(CardPermission.GENERAL_VIEW),
)
const hasEditPermission = computed(() =>
  permissionStore.hasPermission(CardPermission.GENERAL_EDIT),
)

const SORT_WHITELIST = new Set<string>(CARD_SORT_FIELDS)

const loading = ref(false)
const listError = ref<string | null>(null)
const onlySellable = ref(false)
const categoryFilter = ref<number | null>(null)
const records = ref<GeneralCardItem[]>([])
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
    categoryOptions.value = await fetchCardCategoryOptions('general')
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
  amount: 1 as number,
  validType: 0 as number,
  validDay: null as number | null,
  saleStartDate: '' as string,
  saleEndingDate: '' as string,
  allowSell: true,
  allowLargess: false,
  remark: '',
  projects: [] as Array<{
    projectId: number | null
    consumeAmount: number
    limitConsumeTimes: number
  }>,
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
    listError.value = '暂无权限查看通用次卡（card:general:view）'
    return
  }
  await runExclusive(loading, async () => {
    listError.value = null
    try {
      records.value = await fetchGeneralCardList({
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
    fetchCardSaleEntities('general', id),
    fetchCardConsumeEntities('general', id),
  ])
  const saleIds = sale.entityIds ?? []
  const consumeIds = consume.entityIds ?? []
  saleEntityIds.value = [...saleIds]
  consumeEntityIds.value = [...consumeIds]
  saleScopeMode.value = saleIds.length === 0 ? 'all' : 'specified'
  consumeScopeMode.value = consumeIds.length === 0 ? 'all' : 'specified'
}

function openCreate(): void {
  formMode.value = 'create'
  editingId.value = null
  form.name = ''
  inactiveCategoryOption.value = null
  form.categoryId = categoryOptions.value[0]?.id ?? null
  form.price = ''
  form.amount = 1
  form.validType = 0
  form.validDay = null
  form.saleStartDate = ''
  form.saleEndingDate = ''
  form.allowSell = true
  form.allowLargess = false
  form.remark = ''
  form.projects = [{ projectId: null, consumeAmount: 1, limitConsumeTimes: 0 }]
  formError.value = null
  resetScope()
  formVisible.value = true
  void loadProjectOptions()
}

async function openEdit(row: GeneralCardItem): Promise<void> {
  formMode.value = 'edit'
  editingId.value = row.id
  formError.value = null
  resetScope()
  formVisible.value = true
  formLoading.value = true
  void loadProjectOptions()
  void loadStoreOptions()
  try {
    const detail = await fetchGeneralCardDetail(row.id)
    applyDetail(detail)
    await loadScopes(row.id)
  } catch (error) {
    notifyError(error)
  } finally {
    formLoading.value = false
  }
}

function applyDetail(detail: GeneralCardItem): void {
  form.name = detail.name ?? ''
  form.categoryId = detail.categoryId ?? null
  syncInactiveCategoryOption(detail.categoryId, detail.categoryName)
  form.price =
    detail.price == null
      ? ''
      : typeof detail.price === 'number'
        ? detail.price.toFixed(2)
        : String(detail.price)
  form.amount = detail.amount ?? 1
  form.validType = detail.validType ?? 0
  form.validDay = detail.validDay
  form.saleStartDate = detail.saleStartDate ?? ''
  form.saleEndingDate = detail.saleEndingDate ?? ''
  form.allowSell = detail.allowSell !== false
  form.allowLargess = detail.allowLargess === true
  form.remark = detail.remark ?? ''
  form.projects =
    detail.projects != null && detail.projects.length > 0
      ? detail.projects.map((p: GeneralCardProjectLine) => ({
          projectId: p.projectId,
          consumeAmount: p.consumeAmount ?? 1,
          limitConsumeTimes: p.limitConsumeTimes ?? 0,
        }))
      : [{ projectId: null, consumeAmount: 1, limitConsumeTimes: 0 }]
}

function addProjectLine(): void {
  form.projects.push({ projectId: null, consumeAmount: 1, limitConsumeTimes: 0 })
}

function removeProjectLine(index: number): void {
  form.projects.splice(index, 1)
}

function validateForm(): string | null {
  if (form.categoryId == null) {
    return '请选择分类'
  }
  if (!form.name.trim()) {
    return '请填写名称'
  }
  if (normalizeAmountString(form.price) == null) {
    return '请填写合法售价（非负，最多两位小数）'
  }
  if (!Number.isInteger(form.amount) || form.amount <= 0) {
    return '次数必须大于 0'
  }
  for (const line of form.projects) {
    if (line.projectId == null) {
      return '请完整选择项目明细中的项目'
    }
  }
  return null
}

async function saveScopes(id: number): Promise<void> {
  const saleIds = saleScopeMode.value === 'all' ? [] : [...saleEntityIds.value]
  const consumeIds = consumeScopeMode.value === 'all' ? [] : [...consumeEntityIds.value]
  await Promise.all([
    replaceCardSaleEntities('general', id, { entityIds: saleIds }),
    replaceCardConsumeEntities('general', id, { entityIds: consumeIds }),
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
  const projects = form.projects
    .filter((p) => p.projectId != null)
    .map((p) => ({
      projectId: p.projectId as number,
      consumeAmount: p.consumeAmount,
      limitConsumeTimes: p.limitConsumeTimes,
    }))
  const body = {
    name: form.name.trim(),
    categoryId: form.categoryId,
    price,
    amount: form.amount,
    validType: form.validType,
    validDay: form.validDay,
    saleStartDate: form.saleStartDate || null,
    saleEndingDate: form.saleEndingDate || null,
    allowSell: form.allowSell,
    allowLargess: form.allowLargess,
    remark: form.remark.trim() || null,
    projects,
  }
  await runExclusive(formSaving, async () => {
    formError.value = null
    try {
      if (formMode.value === 'create') {
        const created = await createGeneralCard(body)
        editingId.value = created.id
        formMode.value = 'edit'
        resetScope()
        await loadStoreOptions()
        await loadScopes(created.id)
        uiMessage.success('次卡已创建，可配置销售/消耗范围后再次保存')
        await loadList()
      } else if (editingId.value != null) {
        await updateGeneralCard(editingId.value, body)
        await runExclusive(scopeSaving, async () => {
          await saveScopes(editingId.value!)
        })
        uiMessage.success('次卡与范围已保存')
        formVisible.value = false
        await loadList()
      }
    } catch (error) {
      formError.value = getUserFriendlyErrorMessage(error)
      notifyError(error)
    }
  })
}

async function handleDeactivate(row: GeneralCardItem): Promise<void> {
  if (!hasEditPermission.value || row.allowSell === false) {
    return
  }
  const ok = await uiConfirm({
    title: '停售次卡',
    message: `确认停售「${row.name || row.id}」？停售后不会出现在 options（非物理删除）。`,
    confirmText: '停售',
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
    await deactivateGeneralCard(id)
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

function rowOf(row: unknown): GeneralCardItem {
  return row as GeneralCardItem
}

watch(
  hasViewPermission,
  () => {
    void loadProjectOptions()
    void loadCategoryOptions()
    void loadList()
  },
  { immediate: true },
)
</script>

<template>
  <section class="card-manage">
    <header class="page-header">
      <div>
        <h1>通用次卡</h1>
        <p class="subtitle">维护次卡定义与项目范围；销售/消耗适用门店由商品管理员配置</p>
      </div>
      <el-button
        v-permission="CardPermission.GENERAL_EDIT"
        type="primary"
        @click="openCreate"
      >
        新增次卡
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
          <el-table-column label="次数" width="80" align="right">
            <template #default="{ row }">{{ rowOf(row).amount ?? '—' }}</template>
          </el-table-column>
          <el-table-column label="有效期" min-width="120">
            <template #default="{ row }">
              {{ formatCardValidPeriod(rowOf(row).validType, rowOf(row).validDay) }}
            </template>
          </el-table-column>
          <el-table-column prop="allowSell" label="状态" width="90" sortable="custom">
            <template #default="{ row }">
              <el-tag
                :type="rowOf(row).allowSell === false ? 'info' : 'success'"
                size="small"
              >
                {{ formatSellStatus(rowOf(row).allowSell) }}
              </el-tag>
            </template>
          </el-table-column>
          <el-table-column label="操作" width="160" fixed="right">
            <template #default="{ row }">
              <el-button
                v-permission="CardPermission.GENERAL_EDIT"
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
          title="暂无通用次卡"
          description="可点击「新增次卡」创建"
        />
      </template>
    </div>

    <el-dialog
      v-model="formVisible"
      :title="formMode === 'create' ? '新增次卡' : '编辑次卡'"
      width="720px"
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
          <el-form-item label="次数" required>
            <el-input-number v-model="form.amount" :min="1" :precision="0" style="width: 100%" />
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
          <el-form-item label="备注">
            <el-input v-model="form.remark" type="textarea" :rows="2" />
          </el-form-item>

          <el-divider content-position="left">项目范围</el-divider>
          <div
            v-for="(line, index) in form.projects"
            :key="index"
            class="line-row"
          >
            <el-select
              v-model="line.projectId"
              filterable
              placeholder="项目"
              style="flex: 1.4"
            >
              <el-option
                v-for="p in projectOptions"
                :key="p.id"
                :label="p.name || String(p.id)"
                :value="p.id"
              />
            </el-select>
            <el-input-number
              v-model="line.consumeAmount"
              :min="1"
              :precision="0"
              controls-position="right"
              placeholder="消耗金额"
            />
            <el-input-number
              v-model="line.limitConsumeTimes"
              :min="0"
              :precision="0"
              controls-position="right"
              placeholder="限制次数"
            />
            <el-button
              link
              type="danger"
              :disabled="form.projects.length <= 1"
              @click="removeProjectLine(index)"
            >
              删除
            </el-button>
          </div>
          <el-button class="add-line" @click="addProjectLine">添加项目</el-button>
          <p class="field-hint">消耗金额 / 限制消耗次数对应后端 consumeAmount / limitConsumeTimes</p>

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
.add-line {
  margin-bottom: 8px;
}
.field-hint {
  margin: 0 0 12px;
  font-size: 12px;
  color: #909399;
}
</style>
