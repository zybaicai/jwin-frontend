<script setup lang="ts">
import { computed, reactive, ref, watch } from 'vue'

import AppEmpty from '@/components/common/AppEmpty.vue'
import AppError from '@/components/common/AppError.vue'
import {
  createSavingCardDiscount,
  deactivateSavingCardDiscount,
  fetchPriceAreaList,
  fetchSavingCardDiscountDetail,
  fetchSavingCardDiscountList,
  updateSavingCardDiscount,
} from '@/api/card'
import { fetchProjectOptions } from '@/api/project'
import {
  CardPermission,
  DISCOUNT_SORT_FIELDS,
  type DiscountSortField,
  type PriceAreaItem,
  type SavingCardDiscountItem,
} from '@/types/card'
import type { ProjectItem } from '@/types/project'
import { usePermissionStore } from '@/stores/permission'
import { normalizeAmountString } from '@/utils/amount'
import {
  getUserFriendlyErrorMessage,
  notifyError,
  runExclusive,
  uiConfirm,
  uiMessage,
} from '@/utils/ui'

defineOptions({ name: 'SavingCardDiscountManageView' })

const permissionStore = usePermissionStore()

const hasViewPermission = computed(() =>
  permissionStore.hasPermission(CardPermission.SAVING_DISCOUNT_VIEW),
)
const hasEditPermission = computed(() =>
  permissionStore.hasPermission(CardPermission.SAVING_DISCOUNT_EDIT),
)

const SORT_WHITELIST = new Set<string>(DISCOUNT_SORT_FIELDS)

const loading = ref(false)
const listError = ref<string | null>(null)
const filterPriceAreaId = ref<number | null>(null)
const filterProjectId = ref<number | null>(null)
const records = ref<SavingCardDiscountItem[]>([])
const sortField = ref<DiscountSortField>('id')
const sortOrder = ref<'asc' | 'desc'>('desc')
const priceAreas = ref<PriceAreaItem[]>([])
const projectOptions = ref<ProjectItem[]>([])
const deactivatingIds = ref<Set<number>>(new Set())
const optionsError = ref<string | null>(null)

const tableDefaultSort = computed(() => ({
  prop: sortField.value,
  order: (sortOrder.value === 'asc' ? 'ascending' : 'descending') as
    | 'ascending'
    | 'descending',
}))

function mapSortField(prop: string | null | undefined): DiscountSortField | null {
  if (prop == null || prop === '') {
    return null
  }
  if (!SORT_WHITELIST.has(prop)) {
    return null
  }
  return prop as DiscountSortField
}

const formVisible = ref(false)
const formMode = ref<'create' | 'edit'>('create')
const formLoading = ref(false)
const formSaving = ref(false)
const formError = ref<string | null>(null)
const editingId = ref<number | null>(null)

const form = reactive({
  priceAreaId: null as number | null,
  projectId: null as number | null,
  discountRate: '',
  beginDate: '' as string,
  endDate: '' as string,
  active: true,
  remark: '',
})

const priceAreaNameMap = computed(() => {
  const map = new Map<number, string>()
  for (const a of priceAreas.value) {
    map.set(a.id, a.name || String(a.id))
  }
  return map
})

const projectNameMap = computed(() => {
  const map = new Map<number, string>()
  for (const p of projectOptions.value) {
    map.set(p.id, p.name || String(p.id))
  }
  return map
})

async function loadOptions(): Promise<void> {
  optionsError.value = null
  try {
    const [areas, projects] = await Promise.all([
      fetchPriceAreaList(true).catch((error: unknown) => {
        throw error
      }),
      fetchProjectOptions(),
    ])
    priceAreas.value = areas
    projectOptions.value = projects
  } catch (error) {
    optionsError.value = getUserFriendlyErrorMessage(error)
    try {
      projectOptions.value = await fetchProjectOptions()
    } catch {
      projectOptions.value = []
    }
  }
}

async function loadList(): Promise<void> {
  if (!hasViewPermission.value) {
    records.value = []
    listError.value = '暂无权限查看储值区域折扣（card:saving-discount:view）'
    return
  }
  await runExclusive(loading, async () => {
    listError.value = null
    try {
      records.value = await fetchSavingCardDiscountList({
        priceAreaId: filterPriceAreaId.value ?? undefined,
        projectId: filterProjectId.value ?? undefined,
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

function openCreate(): void {
  formMode.value = 'create'
  editingId.value = null
  form.priceAreaId = null
  form.projectId = null
  form.discountRate = ''
  form.beginDate = ''
  form.endDate = ''
  form.active = true
  form.remark = ''
  formError.value = null
  formVisible.value = true
  void loadOptions()
}

async function openEdit(row: SavingCardDiscountItem): Promise<void> {
  formMode.value = 'edit'
  editingId.value = row.id
  formError.value = null
  formVisible.value = true
  formLoading.value = true
  void loadOptions()
  try {
    const detail = await fetchSavingCardDiscountDetail(row.id)
    form.priceAreaId = detail.priceAreaId
    form.projectId = detail.projectId
    form.discountRate =
      detail.discountRate == null
        ? ''
        : typeof detail.discountRate === 'number'
          ? String(detail.discountRate)
          : String(detail.discountRate)
    form.beginDate = detail.beginDate ?? ''
    form.endDate = detail.endDate ?? ''
    form.active = detail.active !== false
    form.remark = detail.remark ?? ''
  } catch (error) {
    notifyError(error)
  } finally {
    formLoading.value = false
  }
}

function validateForm(): string | null {
  if (form.priceAreaId == null) {
    return '请选择价格区域'
  }
  if (form.projectId == null) {
    return '请选择项目'
  }
  const rate = normalizeAmountString(form.discountRate)
  if (rate == null) {
    return '请填写合法折扣率（(0,1]）'
  }
  const n = Number(rate)
  if (!(n > 0 && n <= 1)) {
    return '折扣率须在 (0,1] 区间'
  }
  return null
}

async function handleSubmit(): Promise<void> {
  const err = validateForm()
  if (err != null) {
    uiMessage.warning(err)
    return
  }
  const discountRate = normalizeAmountString(form.discountRate)
  if (discountRate == null || form.priceAreaId == null || form.projectId == null) {
    return
  }
  const body = {
    priceAreaId: form.priceAreaId,
    projectId: form.projectId,
    discountRate,
    beginDate: form.beginDate || null,
    endDate: form.endDate || null,
    active: form.active,
    remark: form.remark.trim() || null,
  }
  await runExclusive(formSaving, async () => {
    formError.value = null
    try {
      if (formMode.value === 'create') {
        await createSavingCardDiscount(body)
        uiMessage.success('区域折扣已创建')
      } else if (editingId.value != null) {
        await updateSavingCardDiscount(editingId.value, body)
        uiMessage.success('区域折扣已更新')
      }
      formVisible.value = false
      await loadList()
    } catch (error) {
      formError.value = getUserFriendlyErrorMessage(error)
      notifyError(error)
    }
  })
}

async function handleDeactivate(row: SavingCardDiscountItem): Promise<void> {
  if (!hasEditPermission.value || row.active === false) {
    return
  }
  const ok = await uiConfirm({
    title: '停用区域折扣',
    message: `确认停用折扣 #${row.id}？`,
    confirmText: '停用',
  })
  if (!ok) {
    return
  }
  const id = row.id
  deactivatingIds.value = new Set(deactivatingIds.value).add(id)
  try {
    await deactivateSavingCardDiscount(id)
    uiMessage.success('已停用')
    await loadList()
  } catch (error) {
    notifyError(error)
  } finally {
    const next = new Set(deactivatingIds.value)
    next.delete(id)
    deactivatingIds.value = next
  }
}

function rowOf(row: unknown): SavingCardDiscountItem {
  return row as SavingCardDiscountItem
}

watch(
  hasViewPermission,
  () => {
    void loadOptions()
    void loadList()
  },
  { immediate: true },
)
</script>

<template>
  <section class="card-manage">
    <header class="page-header">
      <div>
        <h1>储值区域折扣</h1>
        <p class="subtitle">价格区域 × 项目 × 折扣率；同区域同项目有效期禁止重叠</p>
      </div>
      <el-button
        v-permission="CardPermission.SAVING_DISCOUNT_EDIT"
        type="primary"
        @click="openCreate"
      >
        新增折扣
      </el-button>
    </header>

    <AppError v-if="optionsError" :description="optionsError" @retry="loadOptions" />

    <form class="toolbar" @submit.prevent="loadList">
      <el-select
        v-model="filterPriceAreaId"
        clearable
        filterable
        placeholder="价格区域"
        style="width: 180px"
      >
        <el-option
          v-for="a in priceAreas"
          :key="a.id"
          :label="a.name || String(a.id)"
          :value="a.id"
        />
      </el-select>
      <el-select
        v-model="filterProjectId"
        clearable
        filterable
        placeholder="项目"
        style="width: 200px"
      >
        <el-option
          v-for="p in projectOptions"
          :key="p.id"
          :label="p.name || String(p.id)"
          :value="p.id"
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
          <el-table-column label="价格区域" min-width="140">
            <template #default="{ row }">
              {{
                rowOf(row).priceAreaId != null
                  ? priceAreaNameMap.get(rowOf(row).priceAreaId!) || rowOf(row).priceAreaId
                  : '—'
              }}
            </template>
          </el-table-column>
          <el-table-column label="项目" min-width="140">
            <template #default="{ row }">
              {{
                rowOf(row).projectId != null
                  ? projectNameMap.get(rowOf(row).projectId!) || rowOf(row).projectId
                  : '—'
              }}
            </template>
          </el-table-column>
          <el-table-column
            prop="discountRate"
            label="折扣率"
            width="100"
            align="right"
            sortable="custom"
          >
            <template #default="{ row }">{{ rowOf(row).discountRate ?? '—' }}</template>
          </el-table-column>
          <el-table-column label="开始日" width="120">
            <template #default="{ row }">{{ rowOf(row).beginDate || '—' }}</template>
          </el-table-column>
          <el-table-column label="结束日" width="120">
            <template #default="{ row }">{{ rowOf(row).endDate || '—' }}</template>
          </el-table-column>
          <el-table-column prop="active" label="状态" width="90" sortable="custom">
            <template #default="{ row }">
              <el-tag :type="rowOf(row).active !== false ? 'success' : 'info'" size="small">
                {{ rowOf(row).active !== false ? '启用' : '停用' }}
              </el-tag>
            </template>
          </el-table-column>
          <el-table-column label="操作" width="160" fixed="right">
            <template #default="{ row }">
              <el-button
                v-permission="CardPermission.SAVING_DISCOUNT_EDIT"
                link
                type="primary"
                @click="openEdit(rowOf(row))"
              >
                编辑
              </el-button>
              <el-button
                v-if="hasEditPermission && rowOf(row).active !== false"
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
          title="暂无区域折扣"
          description="可点击「新增折扣」创建"
        />
      </template>
    </div>

    <el-dialog
      v-model="formVisible"
      :title="formMode === 'create' ? '新增区域折扣' : '编辑区域折扣'"
      width="520px"
      destroy-on-close
      :close-on-click-modal="false"
    >
      <div v-loading="formLoading">
        <AppError v-if="formError" :description="formError" />
        <el-form label-width="100px" @submit.prevent>
          <el-form-item label="价格区域" required>
            <el-select v-model="form.priceAreaId" filterable style="width: 100%">
              <el-option
                v-for="a in priceAreas"
                :key="a.id"
                :label="a.name || String(a.id)"
                :value="a.id"
              />
            </el-select>
          </el-form-item>
          <el-form-item label="项目" required>
            <el-select v-model="form.projectId" filterable style="width: 100%">
              <el-option
                v-for="p in projectOptions"
                :key="p.id"
                :label="p.name || String(p.id)"
                :value="p.id"
              />
            </el-select>
          </el-form-item>
          <el-form-item label="折扣率" required>
            <el-input v-model="form.discountRate" placeholder="如 0.85（(0,1]）" />
          </el-form-item>
          <el-form-item label="开始日">
            <el-date-picker
              v-model="form.beginDate"
              type="date"
              value-format="YYYY-MM-DD"
              style="width: 100%"
            />
          </el-form-item>
          <el-form-item label="结束日">
            <el-date-picker
              v-model="form.endDate"
              type="date"
              value-format="YYYY-MM-DD"
              style="width: 100%"
            />
          </el-form-item>
          <el-form-item label="启用">
            <el-switch v-model="form.active" />
          </el-form-item>
          <el-form-item label="备注">
            <el-input v-model="form.remark" type="textarea" :rows="2" />
          </el-form-item>
        </el-form>
      </div>
      <template #footer>
        <el-button :disabled="formSaving" @click="formVisible = false">取消</el-button>
        <el-button
          type="primary"
          :loading="formSaving"
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
</style>
