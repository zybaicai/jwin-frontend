<script setup lang="ts">
import { computed, reactive, ref, watch } from 'vue'

import AppEmpty from '@/components/common/AppEmpty.vue'
import AppError from '@/components/common/AppError.vue'
import {
  createProjectCategory,
  deactivateProjectCategory,
  fetchProjectCategoryDetail,
  fetchProjectCategoryTree,
  updateProjectCategory,
} from '@/api/project'
import {
  ProjectPermission,
  type ProjectCategoryTreeNode,
} from '@/types/project'
import { usePermissionStore } from '@/stores/permission'
import {
  getUserFriendlyErrorMessage,
  notifyError,
  runExclusive,
  uiConfirm,
  uiMessage,
} from '@/utils/ui'

defineOptions({ name: 'ProjectCategoryManageView' })

const permissionStore = usePermissionStore()

const hasViewPermission = computed(() =>
  permissionStore.hasPermission(ProjectPermission.CATEGORY_VIEW),
)
const hasEditPermission = computed(() =>
  permissionStore.hasPermission(ProjectPermission.CATEGORY_EDIT),
)

const loading = ref(false)
const listError = ref<string | null>(null)
const onlyActiveFilter = ref(false)
const treeData = ref<ProjectCategoryTreeNode[]>([])
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

/** 一级分类（用于新增二级时的父级选择；编辑时也可选） */
const firstLevelOptions = computed(() => {
  return treeData.value
    .filter((n) => (n.parentId == null || n.parentId === 0) && n.active !== false)
    .map((n) => ({ id: n.id, name: n.name || String(n.id) }))
})

function isFirstLevel(row: ProjectCategoryTreeNode): boolean {
  return row.parentId == null || row.parentId === 0
}

async function loadTree(): Promise<void> {
  if (!hasViewPermission.value) {
    treeData.value = []
    listError.value = '暂无权限查看项目分类（project:category:view）'
    return
  }
  await runExclusive(loading, async () => {
    listError.value = null
    try {
      treeData.value = await fetchProjectCategoryTree(
        onlyActiveFilter.value ? true : undefined,
      )
    } catch (error) {
      treeData.value = []
      listError.value = getUserFriendlyErrorMessage(error)
    }
  })
}

function handleReset(): void {
  onlyActiveFilter.value = false
  void loadTree()
}

function openCreateRoot(): void {
  formMode.value = 'create'
  editingId.value = null
  form.name = ''
  form.parentId = 0
  form.sequence = 0
  form.active = true
  formError.value = null
  formVisible.value = true
}

function openCreateChild(parent: ProjectCategoryTreeNode): void {
  if (!isFirstLevel(parent)) {
    uiMessage.warning('最多两级分类，不能再新增下级')
    return
  }
  if (parent.active === false) {
    uiMessage.warning('停用分类不能作为父级')
    return
  }
  formMode.value = 'create'
  editingId.value = null
  form.name = ''
  form.parentId = parent.id
  form.sequence = 0
  form.active = true
  formError.value = null
  formVisible.value = true
}

async function openEdit(row: ProjectCategoryTreeNode): Promise<void> {
  formMode.value = 'edit'
  editingId.value = row.id
  form.name = row.name ?? ''
  form.parentId = row.parentId == null || row.parentId === 0 ? 0 : row.parentId
  form.sequence = row.sequence ?? 0
  form.active = row.active !== false
  formError.value = null
  formVisible.value = true
  formLoading.value = true
  try {
    const detail = await fetchProjectCategoryDetail(row.id)
    form.name = detail.name ?? ''
    form.parentId =
      detail.parentId == null || detail.parentId === 0 ? 0 : detail.parentId
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
    return '请填写分类名称'
  }
  if (name.length > 50) {
    return '分类名称最多 50 个字符'
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
        await createProjectCategory({
          name,
          parentId: form.parentId === 0 ? 0 : form.parentId,
          sequence: Number(form.sequence),
          active: form.active,
        })
        uiMessage.success('分类已创建')
      } else if (editingId.value != null) {
        await updateProjectCategory(editingId.value, {
          name,
          parentId: form.parentId === 0 ? 0 : form.parentId,
          sequence: Number(form.sequence),
          active: form.active,
        })
        uiMessage.success('分类已更新')
      }
      formVisible.value = false
      await loadTree()
    } catch (error) {
      formError.value = getUserFriendlyErrorMessage(error)
      notifyError(error)
    }
  })
}

async function handleDeactivate(row: ProjectCategoryTreeNode): Promise<void> {
  if (!hasEditPermission.value || row.active === false) {
    return
  }
  const ok = await uiConfirm({
    title: '停用分类',
    message: `确认停用分类「${row.name || row.id}」？停用后不能作为新项目分类选项（非物理删除）。`,
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
    await deactivateProjectCategory(id)
    uiMessage.success('分类已停用')
    await loadTree()
  } catch (error) {
    notifyError(error)
  } finally {
    const next = new Set(deactivatingIds.value)
    next.delete(id)
    deactivatingIds.value = next
  }
}

function rowOf(row: unknown): ProjectCategoryTreeNode {
  return row as ProjectCategoryTreeNode
}

watch(
  hasViewPermission,
  () => {
    void loadTree()
  },
  { immediate: true },
)
</script>

<template>
  <section class="category-manage">
    <header class="page-header">
      <div>
        <h1>项目分类</h1>
        <p class="subtitle">最多两级；停用后不可作为新项目分类选项</p>
      </div>
      <el-button
        v-permission="ProjectPermission.CATEGORY_EDIT"
        type="primary"
        @click="openCreateRoot"
      >
        新增一级分类
      </el-button>
    </header>

    <form class="toolbar" @submit.prevent="loadTree">
      <el-checkbox v-model="onlyActiveFilter">仅显示启用</el-checkbox>
      <el-button type="primary" native-type="submit" :loading="loading">查询</el-button>
      <el-button native-type="button" :disabled="loading" @click="handleReset">重置</el-button>
    </form>

    <div v-loading="loading" class="table-panel">
      <AppError
        v-if="listError && !loading"
        :description="listError"
        @retry="loadTree"
      />
      <template v-else>
        <el-table
          :data="treeData"
          border
          stripe
          size="small"
          row-key="id"
          empty-text=" "
          default-expand-all
          :tree-props="{ children: 'children', hasChildren: 'hasChildren' }"
        >
          <el-table-column prop="name" label="分类名称" min-width="200" show-overflow-tooltip>
            <template #default="{ row }">
              {{ rowOf(row).name || '—' }}
            </template>
          </el-table-column>
          <el-table-column label="层级" width="90" align="center">
            <template #default="{ row }">
              {{ isFirstLevel(rowOf(row)) ? '一级' : '二级' }}
            </template>
          </el-table-column>
          <el-table-column prop="sequence" label="排序" width="90" align="right">
            <template #default="{ row }">
              {{ rowOf(row).sequence ?? 0 }}
            </template>
          </el-table-column>
          <el-table-column prop="active" label="状态" width="100">
            <template #default="{ row }">
              <el-tag
                :type="rowOf(row).active !== false ? 'success' : 'info'"
                size="small"
              >
                {{ rowOf(row).active !== false ? '启用' : '停用' }}
              </el-tag>
            </template>
          </el-table-column>
          <el-table-column label="操作" width="240" fixed="right">
            <template #default="{ row }">
              <el-button
                v-permission="ProjectPermission.CATEGORY_EDIT"
                link
                type="primary"
                @click="openEdit(rowOf(row))"
              >
                编辑
              </el-button>
              <el-button
                v-if="
                  hasEditPermission &&
                  isFirstLevel(rowOf(row)) &&
                  rowOf(row).active !== false
                "
                link
                type="primary"
                @click="openCreateChild(rowOf(row))"
              >
                新增二级
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
          v-if="!loading && !listError && treeData.length === 0"
          title="暂无项目分类"
          description="可点击「新增一级分类」开始维护"
        />
      </template>
    </div>

    <el-dialog
      v-model="formVisible"
      :title="formMode === 'create' ? '新增分类' : '编辑分类'"
      width="480px"
      destroy-on-close
      :close-on-click-modal="false"
    >
      <div v-loading="formLoading">
        <AppError v-if="formError" :description="formError" />
        <el-form label-width="100px" @submit.prevent>
          <el-form-item label="分类名称" required>
            <el-input
              v-model="form.name"
              maxlength="50"
              show-word-limit
              placeholder="请输入分类名称"
            />
          </el-form-item>
          <el-form-item label="父级分类">
            <el-select
              v-model="form.parentId"
              style="width: 100%"
              :disabled="formMode === 'create' && form.parentId !== 0 && editingId == null ? false : false"
            >
              <el-option label="无（一级分类）" :value="0" />
              <el-option
                v-for="opt in firstLevelOptions.filter((o) => o.id !== editingId)"
                :key="opt.id"
                :label="opt.name"
                :value="opt.id"
              />
            </el-select>
            <p class="field-hint">最多两级；二级须挂在启用中的一级分类下</p>
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
          <el-form-item v-if="formMode === 'edit'" label="启用状态">
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
.category-manage {
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
