<script setup lang="ts">
import { computed, reactive, ref, watch } from 'vue'

import AppEmpty from '@/components/common/AppEmpty.vue'
import AppError from '@/components/common/AppError.vue'
import {
  createConsumableCategory,
  deactivateConsumableCategory,
  fetchConsumableCategoryDetail,
  fetchConsumableCategoryList,
  updateConsumableCategory,
} from '@/api/consumable'
import {
  ConsumablePermission,
  type ConsumableCategoryItem,
} from '@/types/consumable'
import { usePermissionStore } from '@/stores/permission'
import {
  getUserFriendlyErrorMessage,
  notifyError,
  runExclusive,
  uiConfirm,
  uiMessage,
} from '@/utils/ui'

defineOptions({ name: 'ConsumableCategoryManageView' })

const permissionStore = usePermissionStore()

const hasViewPermission = computed(() =>
  permissionStore.hasPermission(ConsumablePermission.VIEW),
)
const hasEditPermission = computed(() =>
  permissionStore.hasPermission(ConsumablePermission.EDIT),
)

const loading = ref(false)
const listError = ref<string | null>(null)
const onlyActiveFilter = ref(false)
const records = ref<ConsumableCategoryItem[]>([])
const deactivatingIds = ref<Set<number>>(new Set())

const formVisible = ref(false)
const formMode = ref<'create' | 'edit'>('create')
const formLoading = ref(false)
const formSaving = ref(false)
const formError = ref<string | null>(null)
const editingId = ref<number | null>(null)

const form = reactive({
  name: '',
  parentId: 0 as number,
  sequence: 0 as number,
  active: true,
})

function rowOf(row: unknown): ConsumableCategoryItem {
  return row as ConsumableCategoryItem
}

async function loadList(): Promise<void> {
  if (!hasViewPermission.value) {
    records.value = []
    listError.value = '暂无权限查看耗材类别（consumable:view）'
    return
  }
  await runExclusive(loading, async () => {
    listError.value = null
    try {
      records.value = await fetchConsumableCategoryList({
        onlyActive: onlyActiveFilter.value ? true : undefined,
      })
    } catch (error) {
      records.value = []
      listError.value = getUserFriendlyErrorMessage(error)
    }
  })
}

function handleReset(): void {
  onlyActiveFilter.value = false
  void loadList()
}

function openCreate(): void {
  formMode.value = 'create'
  editingId.value = null
  form.name = ''
  form.parentId = 0
  form.sequence = 0
  form.active = true
  formError.value = null
  formVisible.value = true
}

async function openEdit(row: ConsumableCategoryItem): Promise<void> {
  formMode.value = 'edit'
  editingId.value = row.id
  formError.value = null
  formVisible.value = true
  formLoading.value = true
  try {
    const detail = await fetchConsumableCategoryDetail(row.id)
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

function validateForm(): string | null {
  if (!form.name.trim()) {
    return '请输入类别名称'
  }
  if (form.sequence == null || Number.isNaN(Number(form.sequence))) {
    return '请输入排序值'
  }
  return null
}

async function handleSubmit(): Promise<void> {
  if (!hasEditPermission.value) {
    return
  }
  const err = validateForm()
  if (err) {
    formError.value = err
    return
  }
  await runExclusive(formSaving, async () => {
    formError.value = null
    try {
      const body = {
        name: form.name.trim(),
        parentId: form.parentId || 0,
        sequence: form.sequence,
        active: form.active,
      }
      if (formMode.value === 'create') {
        await createConsumableCategory(body)
        uiMessage.success('类别已创建')
      } else if (editingId.value != null) {
        await updateConsumableCategory(editingId.value, body)
        uiMessage.success('类别已保存')
      }
      formVisible.value = false
      await loadList()
    } catch (error) {
      formError.value = getUserFriendlyErrorMessage(error)
    }
  })
}

async function handleDeactivate(row: ConsumableCategoryItem): Promise<void> {
  if (!hasEditPermission.value || row.active === false) {
    return
  }
  const ok = await uiConfirm({
    title: '停用确认',
    message: `确认停用耗材类别「${row.name || row.id}」？停用后不可再用于新建模板。`,
    confirmText: '停用',
  })
  if (!ok) {
    return
  }
  const next = new Set(deactivatingIds.value)
  next.add(row.id)
  deactivatingIds.value = next
  try {
    await deactivateConsumableCategory(row.id)
    uiMessage.success('类别已停用')
    await loadList()
  } catch (error) {
    notifyError(error)
  } finally {
    const cleared = new Set(deactivatingIds.value)
    cleared.delete(row.id)
    deactivatingIds.value = cleared
  }
}

watch(hasViewPermission, () => {
  void loadList()
}, { immediate: true })
</script>

<template>
  <section class="consumable-category-manage">
    <header class="page-header">
      <div>
        <h1>耗材类别</h1>
        <p class="subtitle">商品管理员配置；列表按后端默认 sequence 升序，不支持 sortField</p>
      </div>
      <el-button
        v-permission="ConsumablePermission.EDIT"
        type="primary"
        @click="openCreate"
      >
        新增类别
      </el-button>
    </header>

    <form class="toolbar" @submit.prevent="loadList">
      <el-checkbox v-model="onlyActiveFilter">仅显示启用</el-checkbox>
      <el-button type="primary" native-type="submit" :loading="loading">查询</el-button>
      <el-button native-type="button" :disabled="loading" @click="handleReset">重置</el-button>
    </form>

    <div v-loading="loading" class="table-panel">
      <AppError v-if="listError && !loading" :description="listError" @retry="loadList" />
      <template v-else>
        <el-table :data="records" border stripe size="small" empty-text=" ">
          <el-table-column prop="name" label="类别名称" min-width="180" show-overflow-tooltip>
            <template #default="{ row }">{{ rowOf(row).name || '—' }}</template>
          </el-table-column>
          <el-table-column prop="sequence" label="排序值" width="100" align="right">
            <template #default="{ row }">{{ rowOf(row).sequence ?? 0 }}</template>
          </el-table-column>
          <el-table-column prop="active" label="启用状态" width="100">
            <template #default="{ row }">
              <el-tag :type="rowOf(row).active !== false ? 'success' : 'info'" size="small">
                {{ rowOf(row).active !== false ? '启用' : '停用' }}
              </el-tag>
            </template>
          </el-table-column>
          <el-table-column label="操作" width="160" fixed="right">
            <template #default="{ row }">
              <el-button
                v-permission="ConsumablePermission.EDIT"
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
          title="暂无耗材类别"
          description="可点击「新增类别」创建"
        />
      </template>
    </div>

    <el-dialog
      v-model="formVisible"
      :title="formMode === 'create' ? '新增耗材类别' : '编辑耗材类别'"
      width="480px"
      destroy-on-close
      :close-on-click-modal="false"
    >
      <div v-loading="formLoading">
        <AppError v-if="formError" :description="formError" />
        <el-form label-width="100px" @submit.prevent>
          <el-form-item label="类别名称" required>
            <el-input
              v-model="form.name"
              maxlength="50"
              show-word-limit
              placeholder="请输入类别名称"
              :disabled="!hasEditPermission"
            />
          </el-form-item>
          <el-form-item label="排序值" required>
            <el-input-number
              v-model="form.sequence"
              :step="1"
              :precision="0"
              controls-position="right"
              style="width: 100%"
              :disabled="!hasEditPermission"
            />
            <p class="field-hint">列表按排序值升序展示（后端默认）</p>
          </el-form-item>
          <el-form-item v-if="formMode === 'edit'" label="启用状态">
            <el-switch
              v-model="form.active"
              active-text="启用"
              inactive-text="停用"
              :disabled="!hasEditPermission"
            />
          </el-form-item>
        </el-form>
      </div>
      <template #footer>
        <el-button :disabled="formSaving" @click="formVisible = false">取消</el-button>
        <el-button
          v-if="hasEditPermission"
          type="primary"
          :loading="formSaving"
          :disabled="formLoading"
          @click="handleSubmit"
        >
          保存
        </el-button>
      </template>
    </el-dialog>
  </section>
</template>

<style scoped>
.consumable-category-manage {
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

.field-hint {
  margin: 4px 0 0;
  font-size: 12px;
  color: #909399;
  line-height: 1.4;
}
</style>
