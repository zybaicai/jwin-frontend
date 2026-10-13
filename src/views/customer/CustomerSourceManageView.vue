<script setup lang="ts">
import { computed, reactive, ref, watch } from 'vue'

import AppEmpty from '@/components/common/AppEmpty.vue'
import AppError from '@/components/common/AppError.vue'
import {
  createCustomerSource,
  deleteCustomerSource,
  fetchCustomerSourceDetail,
  fetchCustomerSourcePage,
  updateCustomerSource,
} from '@/api/customer'
import {
  CustomerPermission,
  type CustomerSource,
} from '@/types/customer'
import { usePermissionStore } from '@/stores/permission'
import {
  getUserFriendlyErrorMessage,
  notifyError,
  runExclusive,
  uiConfirm,
  uiMessage,
} from '@/utils/ui'

defineOptions({ name: 'CustomerSourceManageView' })

const permissionStore = usePermissionStore()

const hasViewPermission = computed(() =>
  permissionStore.hasPermission(CustomerPermission.SOURCE_VIEW),
)
const hasEditPermission = computed(() =>
  permissionStore.hasPermission(CustomerPermission.SOURCE_EDIT),
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
const records = ref<CustomerSource[]>([])

/** 父级名称解析（当前页 + 候选缓存） */
const parentNameCache = ref<Map<number, string>>(new Map())

const formVisible = ref(false)
const formMode = ref<'create' | 'edit'>('create')
const formLoading = ref(false)
const formSaving = ref(false)
const formError = ref<string | null>(null)
const editingId = ref<number | null>(null)
const parentCandidates = ref<CustomerSource[]>([])
const togglingIds = ref<Set<number>>(new Set())

const form = reactive({
  name: '',
  parentId: 0 as number,
  sequence: 0 as number,
  active: true,
})

const parentSelectOptions = computed(() => {
  const excludeId = formMode.value === 'edit' ? editingId.value : null
  return parentCandidates.value.filter((item) => item.id !== excludeId)
})

function resolveParentName(parentId: number | null | undefined): string {
  if (parentId == null || parentId === 0) {
    return '—'
  }
  return parentNameCache.value.get(parentId) || `来源#${parentId}`
}

function mergeParentCache(list: CustomerSource[]): void {
  const next = new Map(parentNameCache.value)
  for (const item of list) {
    next.set(item.id, item.name)
  }
  parentNameCache.value = next
}

async function loadParentCandidates(): Promise<void> {
  try {
    const data = await fetchCustomerSourcePage({ page: 1, size: 100 })
    parentCandidates.value = data.records ?? []
    mergeParentCache(parentCandidates.value)
  } catch {
    parentCandidates.value = []
  }
}

async function loadList(): Promise<void> {
  if (!hasViewPermission.value) {
    records.value = []
    total.value = 0
    listError.value = '暂无权限查看来源（customer:source:view）'
    return
  }
  await runExclusive(loading, async () => {
    listError.value = null
    try {
      const data = await fetchCustomerSourcePage({
        keyword: keyword.value.trim() || undefined,
        active:
          activeFilter.value === 'true'
            ? true
            : activeFilter.value === 'false'
              ? false
              : undefined,
        page: page.value,
        size: size.value,
      })
      records.value = data.records ?? []
      total.value = data.total ?? 0
      page.value = data.page || page.value
      size.value = data.size || size.value
      mergeParentCache(records.value)
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

async function openCreate(): Promise<void> {
  formMode.value = 'create'
  editingId.value = null
  form.name = ''
  form.parentId = 0
  form.sequence = 0
  form.active = true
  formError.value = null
  formVisible.value = true
  formLoading.value = true
  try {
    await loadParentCandidates()
  } finally {
    formLoading.value = false
  }
}

async function openEdit(row: CustomerSource): Promise<void> {
  formMode.value = 'edit'
  editingId.value = row.id
  form.name = row.name ?? ''
  form.parentId = row.parentId ?? 0
  form.sequence = row.sequence ?? 0
  form.active = row.active !== false
  formError.value = null
  formVisible.value = true
  formLoading.value = true
  try {
    await loadParentCandidates()
    const detail = await fetchCustomerSourceDetail(row.id)
    form.name = detail.name ?? ''
    form.parentId = detail.parentId ?? 0
    form.sequence = detail.sequence ?? 0
    form.active = detail.active !== false
  } catch (error) {
    notifyError(error)
  } finally {
    formLoading.value = false
  }
}

async function handleSubmit(): Promise<void> {
  const name = form.name.trim()
  if (!name) {
    uiMessage.warning('请填写来源名称')
    return
  }
  if (name.length > 50) {
    uiMessage.warning('来源名称最多 50 个字符')
    return
  }
  if (!Number.isFinite(form.sequence)) {
    uiMessage.warning('排序必须为数字')
    return
  }
  await runExclusive(formSaving, async () => {
    formError.value = null
    try {
      if (formMode.value === 'create') {
        await createCustomerSource({
          name,
          parentId: form.parentId ?? 0,
          sequence: Number(form.sequence) || 0,
          active: form.active,
        })
        uiMessage.success('来源已创建')
      } else if (editingId.value != null) {
        await updateCustomerSource(editingId.value, {
          name,
          parentId: form.parentId ?? 0,
          sequence: Number(form.sequence) || 0,
          active: form.active,
        })
        uiMessage.success('来源已更新')
      }
      formVisible.value = false
      await loadList()
      void loadParentCandidates()
    } catch (error) {
      formError.value = getUserFriendlyErrorMessage(error)
      notifyError(error)
    }
  })
}

async function handleToggleActive(row: CustomerSource, nextActive: boolean): Promise<void> {
  if (!hasEditPermission.value) {
    return
  }
  const id = row.id
  if (togglingIds.value.has(id)) {
    return
  }
  togglingIds.value = new Set(togglingIds.value).add(id)
  try {
    await updateCustomerSource(id, {
      name: row.name,
      parentId: row.parentId ?? 0,
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

function onActiveSwitchChange(row: CustomerSource, val: string | number | boolean): void {
  void handleToggleActive(row, Boolean(val))
}

async function handleDelete(row: CustomerSource): Promise<void> {
  const ok = await uiConfirm({
    title: '删除来源',
    message: `确认删除来源「${row.name || row.id}」？若仍有子级或顾客引用，后端将拒绝删除。`,
    confirmText: '删除',
  })
  if (!ok) {
    return
  }
  try {
    await deleteCustomerSource(row.id)
    uiMessage.success('来源已删除')
    await loadList()
    void loadParentCandidates()
  } catch (error) {
    notifyError(error)
  }
}

function rowOf(row: unknown): CustomerSource {
  return row as CustomerSource
}

watch(
  hasViewPermission,
  () => {
    void loadList()
    void loadParentCandidates()
  },
  { immediate: true },
)
</script>

<template>
  <section class="source-manage">
    <header class="page-header">
      <div>
        <h1>客户来源管理</h1>
        <p class="subtitle">维护客户首次信息来源；建档下拉仅展示启用项</p>
      </div>
    </header>

    <div class="filter-bar">
      <div class="filter-toolbar">
        <el-form :inline="true" class="filter-form" @submit.prevent="handleSearch">
        <el-form-item label="名称">
          <el-input
            v-model="keywordInput"
            clearable
            placeholder="来源名称"
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
          v-permission="CustomerPermission.SOURCE_EDIT"
          class="create-btn"
          type="primary"
          @click="openCreate"
        >
          新增来源
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
        <el-table :data="records" border stripe size="small" empty-text=" ">
          <el-table-column prop="name" label="来源名称" min-width="180" show-overflow-tooltip>
            <template #default="{ row }">
              {{ rowOf(row).name || '—' }}
            </template>
          </el-table-column>
          <el-table-column label="父级来源" min-width="140" show-overflow-tooltip>
            <template #default="{ row }">
              {{ resolveParentName(rowOf(row).parentId) }}
            </template>
          </el-table-column>
          <el-table-column label="排序" width="90" align="right">
            <template #default="{ row }">
              {{ rowOf(row).sequence ?? 0 }}
            </template>
          </el-table-column>
          <el-table-column label="状态" width="100">
            <template #default="{ row }">
              <el-switch
                v-if="hasEditPermission"
                :model-value="rowOf(row).active !== false"
                :disabled="togglingIds.has(rowOf(row).id)"
                inline-prompt
                active-text="启"
                inactive-text="停"
                @change="(val) => onActiveSwitchChange(rowOf(row), val)"
              />
              <el-tag v-else :type="rowOf(row).active !== false ? 'success' : 'info'" size="small">
                {{ rowOf(row).active !== false ? '启用' : '停用' }}
              </el-tag>
            </template>
          </el-table-column>
          <el-table-column label="操作" width="160" fixed="right">
            <template #default="{ row }">
              <el-button
                v-permission="CustomerPermission.SOURCE_EDIT"
                link
                type="primary"
                @click="openEdit(rowOf(row))"
              >
                编辑
              </el-button>
              <el-button
                v-permission="CustomerPermission.SOURCE_EDIT"
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
          title="暂无来源"
          description="可点击「新增来源」创建信息来源"
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
      :title="formMode === 'create' ? '新增来源' : '编辑来源'"
      width="480px"
      destroy-on-close
      :close-on-click-modal="false"
    >
      <div v-loading="formLoading">
        <AppError v-if="formError" :description="formError" />
        <el-form label-width="90px" @submit.prevent>
          <el-form-item label="来源名称" required>
            <el-input
              v-model="form.name"
              maxlength="50"
              show-word-limit
              placeholder="请输入来源名称"
            />
          </el-form-item>
          <el-form-item label="父级来源">
            <el-select v-model="form.parentId" filterable style="width: 100%">
              <el-option label="无（顶级）" :value="0" />
              <el-option
                v-for="item in parentSelectOptions"
                :key="item.id"
                :label="item.name"
                :value="item.id"
              />
            </el-select>
          </el-form-item>
          <el-form-item label="排序">
            <el-input-number v-model="form.sequence" :step="1" controls-position="right" />
          </el-form-item>
          <el-form-item label="状态">
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
.source-manage {
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
