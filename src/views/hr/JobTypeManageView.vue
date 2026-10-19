<script setup lang="ts">
import { computed, reactive, ref, watch } from 'vue'

import AppEmpty from '@/components/common/AppEmpty.vue'
import AppError from '@/components/common/AppError.vue'
import {
  createJobType,
  deleteJobType,
  fetchJobTypePage,
  updateJobType,
} from '@/api/hr'
import { OrgPermission, type JobTypeRecord } from '@/types/hr'
import { usePermissionStore } from '@/stores/permission'
import {
  getUserFriendlyErrorMessage,
  notifyError,
  runExclusive,
  uiConfirm,
  uiMessage,
} from '@/utils/ui'

defineOptions({ name: 'JobTypeManageView' })

const permissionStore = usePermissionStore()

const hasViewPermission = computed(() =>
  permissionStore.hasPermission(OrgPermission.JOB_VIEW),
)
const hasEditPermission = computed(() =>
  permissionStore.hasPermission(OrgPermission.JOB_EDIT),
)

const loading = ref(false)
const listError = ref<string | null>(null)
const keywordInput = ref('')
const keyword = ref('')
const activeFilter = ref<'' | 'true' | 'false'>('')
const page = ref(1)
const size = ref(20)
const total = ref(0)
const records = ref<JobTypeRecord[]>([])

const formVisible = ref(false)
const formMode = ref<'create' | 'edit'>('create')
const formSaving = ref(false)
const formError = ref<string | null>(null)
const editingId = ref<number | null>(null)

const form = reactive({
  name: '',
  description: '',
  active: true,
})

function rowOf(row: unknown): JobTypeRecord {
  return row as JobTypeRecord
}

async function loadList(): Promise<void> {
  if (!hasViewPermission.value) {
    records.value = []
    total.value = 0
    listError.value = '暂无权限查看职务（org:job:view）'
    return
  }
  await runExclusive(loading, async () => {
    listError.value = null
    try {
      const data = await fetchJobTypePage({
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

function openCreate(): void {
  formMode.value = 'create'
  editingId.value = null
  form.name = ''
  form.description = ''
  form.active = true
  formError.value = null
  formVisible.value = true
}

function openEdit(row: JobTypeRecord): void {
  formMode.value = 'edit'
  editingId.value = row.id
  form.name = row.name ?? ''
  form.description = row.description ?? ''
  form.active = row.active !== false
  formError.value = null
  formVisible.value = true
}

async function handleSubmit(): Promise<void> {
  if (!hasEditPermission.value) return
  const name = form.name.trim()
  if (!name) {
    uiMessage.warning('请填写职务名称')
    return
  }
  await runExclusive(formSaving, async () => {
    formError.value = null
    try {
      if (formMode.value === 'create') {
        await createJobType({
          name,
          description: form.description.trim() || undefined,
          active: form.active,
        })
        uiMessage.success('职务已创建')
      } else if (editingId.value != null) {
        await updateJobType(editingId.value, {
          name,
          description: form.description.trim() || undefined,
          active: form.active,
        })
        uiMessage.success('职务已更新')
      }
      formVisible.value = false
      await loadList()
    } catch (error) {
      formError.value = getUserFriendlyErrorMessage(error)
      notifyError(error)
    }
  })
}

async function handleDelete(row: JobTypeRecord): Promise<void> {
  if (!hasEditPermission.value) return
  const ok = await uiConfirm({
    title: '删除职务',
    message: `确认删除职务「${row.name || row.id}」？若仍被员工或权限角色引用，后端将拒绝。`,
    confirmText: '删除',
  })
  if (!ok) return
  try {
    await deleteJobType(row.id)
    uiMessage.success('职务已删除')
    await loadList()
  } catch (error) {
    notifyError(error)
  }
}

watch(hasViewPermission, () => void loadList(), { immediate: true })
</script>

<template>
  <section class="job-type-manage">
    <header class="page-header">
      <div>
        <h1>职务管理</h1>
        <p class="subtitle">人事职务档案（TK_JobType）；权限角色绑定亦共用此表</p>
      </div>
    </header>

    <div class="filter-bar">
      <div class="filter-toolbar">
        <el-form :inline="true" class="filter-form" @submit.prevent="handleSearch">
          <el-form-item label="名称">
            <el-input
              v-model="keywordInput"
              clearable
              placeholder="职务名称"
              style="max-width: 200px"
            />
          </el-form-item>
          <el-form-item label="状态">
            <el-select v-model="activeFilter" clearable placeholder="全部" style="width: 120px">
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
          v-if="hasEditPermission"
          class="create-btn"
          type="primary"
          @click="openCreate"
        >
          新增职务
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
          <el-table-column prop="id" label="ID" width="80" />
          <el-table-column prop="name" label="职务名称" min-width="160" show-overflow-tooltip />
          <el-table-column prop="description" label="说明" min-width="200" show-overflow-tooltip>
            <template #default="{ row }">
              {{ rowOf(row).description || '—' }}
            </template>
          </el-table-column>
          <el-table-column label="状态" width="90">
            <template #default="{ row }">
              <el-tag :type="rowOf(row).active !== false ? 'success' : 'info'" size="small">
                {{ rowOf(row).active !== false ? '启用' : '停用' }}
              </el-tag>
            </template>
          </el-table-column>
          <el-table-column label="操作" width="140" fixed="right">
            <template #default="{ row }">
              <el-button
                v-if="hasEditPermission"
                link
                type="primary"
                @click="openEdit(rowOf(row))"
              >
                编辑
              </el-button>
              <el-button
                v-if="hasEditPermission"
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
          title="暂无职务"
          description="可点击「新增职务」创建"
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
      :title="formMode === 'create' ? '新增职务' : '编辑职务'"
      width="460px"
      destroy-on-close
      :close-on-click-modal="false"
    >
      <AppError v-if="formError" :description="formError" />
      <el-form label-width="90px" @submit.prevent>
        <el-form-item label="名称" required>
          <el-input v-model="form.name" maxlength="50" show-word-limit />
        </el-form-item>
        <el-form-item label="说明">
          <el-input v-model="form.description" type="textarea" :rows="2" maxlength="200" />
        </el-form-item>
        <el-form-item label="状态">
          <el-switch v-model="form.active" active-text="启用" inactive-text="停用" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button :disabled="formSaving" @click="formVisible = false">取消</el-button>
        <el-button type="primary" :loading="formSaving" @click="handleSubmit">保存</el-button>
      </template>
    </el-dialog>
  </section>
</template>

<style scoped>
.job-type-manage {
  display: flex;
  flex-direction: column;
  gap: 16px;
  min-height: 100%;
  padding: 20px 24px 24px;
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
