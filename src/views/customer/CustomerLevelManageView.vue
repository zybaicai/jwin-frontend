<script setup lang="ts">
import { computed, reactive, ref, watch } from 'vue'

import AppEmpty from '@/components/common/AppEmpty.vue'
import AppError from '@/components/common/AppError.vue'
import {
  createCustomerLevel,
  deleteCustomerLevel,
  fetchCustomerLevelDetail,
  fetchCustomerLevelPage,
  updateCustomerLevel,
} from '@/api/customer'
import {
  CUSTOMER_LEVEL_SORT_BY,
  CustomerPermission,
  type CustomerLevelItem,
  type CustomerLevelSortBy,
} from '@/types/customer'
import { usePermissionStore } from '@/stores/permission'
import {
  getUserFriendlyErrorMessage,
  notifyError,
  runExclusive,
  uiConfirm,
  uiMessage,
} from '@/utils/ui'

defineOptions({ name: 'CustomerLevelManageView' })

const SORT_WHITELIST = new Set<string>(CUSTOMER_LEVEL_SORT_BY)

const permissionStore = usePermissionStore()

const hasViewPermission = computed(() =>
  permissionStore.hasPermission(CustomerPermission.LEVEL_VIEW),
)
const hasEditPermission = computed(() =>
  permissionStore.hasPermission(CustomerPermission.LEVEL_EDIT),
)

const loading = ref(false)
const listError = ref<string | null>(null)
const keywordInput = ref('')
const keyword = ref('')
/** '' = 全部, 'true' / 'false' */
const activeFilter = ref<'' | 'true' | 'false'>('')
const page = ref(1)
const size = ref(20)
const total = ref(0)
const records = ref<CustomerLevelItem[]>([])
const sortBy = ref<CustomerLevelSortBy>('sequence')
const sortOrder = ref<'asc' | 'desc'>('asc')
const togglingIds = ref<Set<number>>(new Set())

const formVisible = ref(false)
const formMode = ref<'create' | 'edit'>('create')
const formLoading = ref(false)
const formSaving = ref(false)
const formError = ref<string | null>(null)
const editingId = ref<number | null>(null)

const form = reactive({
  name: '',
  levelValue: 0 as number,
  sequence: 0 as number,
  active: true,
})

const tableDefaultSort = computed(() => ({
  prop: sortBy.value,
  order: (sortOrder.value === 'asc' ? 'ascending' : 'descending') as
    | 'ascending'
    | 'descending',
}))

function mapSortBy(prop: string | null | undefined): CustomerLevelSortBy | null {
  if (prop == null || prop === '') {
    return null
  }
  if (!SORT_WHITELIST.has(prop)) {
    return null
  }
  return prop as CustomerLevelSortBy
}

async function loadList(): Promise<void> {
  if (!hasViewPermission.value) {
    records.value = []
    total.value = 0
    listError.value = '暂无权限查看等级设置（customer:level:view）'
    return
  }
  await runExclusive(loading, async () => {
    listError.value = null
    try {
      const data = await fetchCustomerLevelPage({
        keyword: keyword.value.trim() || undefined,
        active:
          activeFilter.value === 'true'
            ? true
            : activeFilter.value === 'false'
              ? false
              : undefined,
        sortBy: sortBy.value,
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
  activeFilter.value = ''
  sortBy.value = 'sequence'
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
  const mapped = mapSortBy(payload.prop)
  if (mapped == null || payload.order == null) {
    sortBy.value = 'sequence'
    sortOrder.value = 'asc'
  } else {
    sortBy.value = mapped
    sortOrder.value = payload.order === 'ascending' ? 'asc' : 'desc'
  }
  page.value = 1
  await loadList()
}

function openCreate(): void {
  formMode.value = 'create'
  editingId.value = null
  form.name = ''
  form.levelValue = 0
  form.sequence = 0
  form.active = true
  formError.value = null
  formVisible.value = true
}

async function openEdit(row: CustomerLevelItem): Promise<void> {
  formMode.value = 'edit'
  editingId.value = row.id
  form.name = row.name ?? ''
  form.levelValue = row.levelValue ?? 0
  form.sequence = row.sequence ?? 0
  form.active = row.active !== false
  formError.value = null
  formVisible.value = true
  formLoading.value = true
  try {
    const detail = await fetchCustomerLevelDetail(row.id)
    form.name = detail.name ?? ''
    form.levelValue = detail.levelValue ?? 0
    form.sequence = detail.sequence ?? 0
    form.active = detail.active !== false
  } catch (error) {
    notifyError(error)
  } finally {
    formLoading.value = false
  }
}

function validateForm(): string | null {
  const name = form.name.trim()
  if (!name) {
    return '请填写等级名称'
  }
  if (name.length > 50) {
    return '等级名称最多 50 个字符'
  }
  if (!Number.isFinite(form.levelValue) || form.levelValue < 0) {
    return '金额门槛不能为负数'
  }
  if (!Number.isInteger(form.sequence)) {
    return '排序值必须是整数'
  }
  return null
}

async function handleSubmit(): Promise<void> {
  const err = validateForm()
  if (err != null) {
    uiMessage.warning(err)
    return
  }
  const name = form.name.trim()
  await runExclusive(formSaving, async () => {
    formError.value = null
    try {
      if (formMode.value === 'create') {
        await createCustomerLevel({
          name,
          levelValue: Number(form.levelValue),
          sequence: Number(form.sequence),
          active: form.active,
        })
        uiMessage.success('等级已创建')
      } else if (editingId.value != null) {
        await updateCustomerLevel(editingId.value, {
          name,
          levelValue: Number(form.levelValue),
          sequence: Number(form.sequence),
          active: form.active,
        })
        uiMessage.success('等级已更新')
      }
      formVisible.value = false
      await loadList()
    } catch (error) {
      formError.value = getUserFriendlyErrorMessage(error)
      notifyError(error)
    }
  })
}

async function handleToggleActive(row: CustomerLevelItem, nextActive: boolean): Promise<void> {
  if (!hasEditPermission.value) {
    return
  }
  const actionLabel = nextActive ? '启用' : '停用'
  const ok = await uiConfirm({
    title: `${actionLabel}等级`,
    message: `确认${actionLabel}等级「${row.name || row.id}」？`,
    confirmText: actionLabel,
  })
  if (!ok) {
    await loadList()
    return
  }
  const id = row.id
  if (togglingIds.value.has(id)) {
    return
  }
  togglingIds.value = new Set(togglingIds.value).add(id)
  try {
    await updateCustomerLevel(id, {
      name: row.name,
      levelValue: row.levelValue,
      reduceLevelValue: row.reduceLevelValue,
      sequence: row.sequence ?? 0,
      active: nextActive,
    })
    uiMessage.success(nextActive ? '已启用' : '已停用')
    await loadList()
  } catch (error) {
    notifyError(error)
    await loadList()
  } finally {
    const next = new Set(togglingIds.value)
    next.delete(id)
    togglingIds.value = next
  }
}

function onActiveSwitchChange(row: CustomerLevelItem, val: string | number | boolean): void {
  void handleToggleActive(row, Boolean(val))
}

async function handleDelete(row: CustomerLevelItem): Promise<void> {
  const ok = await uiConfirm({
    title: '删除等级',
    message: `确认删除等级「${row.name || row.id}」？若仍有顾客使用该等级，后端将拒绝删除（可改为停用）。`,
    confirmText: '删除',
  })
  if (!ok) {
    return
  }
  try {
    await deleteCustomerLevel(row.id)
    uiMessage.success('等级已删除')
    await loadList()
  } catch (error) {
    notifyError(error)
  }
}

function rowOf(row: unknown): CustomerLevelItem {
  return row as CustomerLevelItem
}

watch(
  hasViewPermission,
  () => {
    void loadList()
  },
  { immediate: true },
)
</script>

<template>
  <section class="level-manage">

    <div class="filter-bar">
      <div class="filter-toolbar">
        <el-form :inline="true" class="filter-form" @submit.prevent="handleSearch">
        <el-form-item label="名称">
          <el-input
            v-model="keywordInput"
            clearable
            placeholder="等级名称"
            style="max-width: 220px"
          />
        </el-form-item>
        <el-form-item label="状态">
          <el-select
            v-model="activeFilter"
            clearable
            placeholder="状态"
            style="width: 140px"
          >
            <el-option label="全部" value="" />
            <el-option label="启用" value="true" />
            <el-option label="停用" value="false" />
          </el-select>
        </el-form-item>
        <el-form-item>
          <el-button type="primary" native-type="submit" :loading="loading">查询</el-button>
          <el-button native-type="button" :disabled="loading" @click="handleReset">重置</el-button>
        </el-form-item>
        </el-form>
        <el-button
          v-permission="CustomerPermission.LEVEL_EDIT"
          class="create-btn"
          type="primary"
          @click="openCreate"
        >
          新增等级
        </el-button>
      </div>
    </div>

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
            label="等级名称"
            min-width="140"
            sortable="custom"
            show-overflow-tooltip
          >
            <template #default="{ row }">
              {{ rowOf(row).name || '—' }}
            </template>
          </el-table-column>
          <el-table-column
            prop="levelValue"
            label="金额门槛"
            min-width="120"
            align="right"
            sortable="custom"
          >
            <template #default="{ row }">
              {{ rowOf(row).levelValue ?? 0 }}
            </template>
          </el-table-column>
          <el-table-column
            prop="sequence"
            label="排序值"
            width="100"
            align="right"
            sortable="custom"
          >
            <template #default="{ row }">
              {{ rowOf(row).sequence ?? 0 }}
            </template>
          </el-table-column>
          <el-table-column prop="active" label="启用状态" width="120" sortable="custom">
            <template #default="{ row }">
              <el-tag
                :type="rowOf(row).active !== false ? 'success' : 'info'"
                size="small"
              >
                {{ rowOf(row).active !== false ? '启用' : '停用' }}
              </el-tag>
            </template>
          </el-table-column>
          <el-table-column label="操作" width="220" fixed="right">
            <template #default="{ row }">
              <el-button
                v-permission="CustomerPermission.LEVEL_EDIT"
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
                :disabled="togglingIds.has(rowOf(row).id)"
                @click="onActiveSwitchChange(rowOf(row), false)"
              >
                停用
              </el-button>
              <el-button
                v-if="hasEditPermission && rowOf(row).active === false"
                link
                type="success"
                :disabled="togglingIds.has(rowOf(row).id)"
                @click="onActiveSwitchChange(rowOf(row), true)"
              >
                启用
              </el-button>
              <el-button
                v-permission="CustomerPermission.LEVEL_EDIT"
                link
                type="danger"
                @click="handleDelete(rowOf(row))"
              >
                删除
              </el-button>
            </template>
          </el-table-column>
        </el-table>

        <AppEmpty
          v-if="!loading && !listError && records.length === 0"
          title="暂无会员等级"
          description="可点击「新增等级」创建门槛配置"
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
      :title="formMode === 'create' ? '新增等级' : '编辑等级'"
      width="480px"
      destroy-on-close
      :close-on-click-modal="false"
    >
      <div v-loading="formLoading">
        <AppError v-if="formError" :description="formError" />
        <el-form label-width="100px" @submit.prevent>
          <el-form-item label="等级名称" required>
            <el-input
              v-model="form.name"
              maxlength="50"
              show-word-limit
              placeholder="请输入等级名称"
            />
          </el-form-item>
          <el-form-item label="金额门槛" required>
            <el-input-number
              v-model="form.levelValue"
              :min="0"
              :step="1"
              :precision="0"
              controls-position="right"
              style="width: 100%"
            />
          </el-form-item>
          <el-form-item label="排序值" required>
            <el-input-number
              v-model="form.sequence"
              :step="1"
              :precision="0"
              controls-position="right"
              style="width: 100%"
            />
          </el-form-item>
          <el-form-item label="启用状态">
            <el-switch v-model="form.active" active-text="启用" inactive-text="停用" />
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
.level-manage {
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

.pager {
  display: flex;
  justify-content: flex-end;
  margin-top: 12px;
}
</style>
