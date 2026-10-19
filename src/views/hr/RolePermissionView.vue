<script setup lang="ts">
import { computed, nextTick, ref, watch } from 'vue'
import type { ElTree } from 'element-plus'

import AppEmpty from '@/components/common/AppEmpty.vue'
import AppError from '@/components/common/AppError.vue'
import {
  fetchJobTypePage,
  fetchJobTypePermissions,
  fetchPermissionTree,
  replaceJobTypePermissions,
} from '@/api/hr'
import {
  OrgPermission,
  type JobTypeRecord,
  type MenuPermissionNode,
} from '@/types/hr'
import { usePermissionStore } from '@/stores/permission'
import {
  getUserFriendlyErrorMessage,
  notifyError,
  runExclusive,
  uiMessage,
} from '@/utils/ui'

defineOptions({ name: 'RolePermissionView' })

const permissionStore = usePermissionStore()

const hasViewPermission = computed(() =>
  permissionStore.hasPermission(OrgPermission.ROLE_VIEW),
)
const hasEditPermission = computed(() =>
  permissionStore.hasPermission(OrgPermission.ROLE_EDIT),
)

const loading = ref(false)
const listError = ref<string | null>(null)
const jobTypes = ref<JobTypeRecord[]>([])
const selectedJobId = ref<number | null>(null)

const permLoading = ref(false)
const permError = ref<string | null>(null)
const permissionTree = ref<MenuPermissionNode[]>([])
const checkedCodes = ref<string[]>([])
const treeRef = ref<InstanceType<typeof ElTree>>()
const saving = ref(false)

function collectLeafCodes(nodes: MenuPermissionNode[]): string[] {
  const result: string[] = []
  const walk = (list: MenuPermissionNode[]) => {
    for (const n of list) {
      if (n.children?.length) {
        walk(n.children)
      } else if (n.code) {
        result.push(n.code)
      }
    }
  }
  walk(nodes)
  return result
}

async function loadJobTypes(): Promise<void> {
  if (!hasViewPermission.value) {
    jobTypes.value = []
    listError.value = '暂无权限查看角色权限（org:role:view）'
    return
  }
  await runExclusive(loading, async () => {
    listError.value = null
    try {
      const data = await fetchJobTypePage({ page: 1, size: 200 })
      jobTypes.value = data.records ?? []
      if (
        selectedJobId.value != null &&
        !jobTypes.value.some((j) => j.id === selectedJobId.value)
      ) {
        selectedJobId.value = null
        checkedCodes.value = []
      }
    } catch (error) {
      jobTypes.value = []
      listError.value = getUserFriendlyErrorMessage(error)
    }
  })
}

async function loadPermissionTree(): Promise<void> {
  try {
    permissionTree.value = await fetchPermissionTree()
  } catch (error) {
    permissionTree.value = []
    permError.value = getUserFriendlyErrorMessage(error)
  }
}

async function loadJobPermissions(jobId: number): Promise<void> {
  await runExclusive(permLoading, async () => {
    permError.value = null
    try {
      if (!permissionTree.value.length) {
        await loadPermissionTree()
      }
      const codes = await fetchJobTypePermissions(jobId)
      checkedCodes.value = codes
      await nextTick()
      const leafSet = new Set(collectLeafCodes(permissionTree.value))
      const leafChecked = codes.filter((c) => leafSet.has(c))
      treeRef.value?.setCheckedKeys(leafChecked)
    } catch (error) {
      checkedCodes.value = []
      permError.value = getUserFriendlyErrorMessage(error)
    }
  })
}

function selectJob(row: JobTypeRecord): void {
  selectedJobId.value = row.id
  void loadJobPermissions(row.id)
}

async function handleSave(): Promise<void> {
  if (!hasEditPermission.value || selectedJobId.value == null) return
  const half = (treeRef.value?.getHalfCheckedKeys?.() ?? []) as string[]
  const checked = (treeRef.value?.getCheckedKeys?.(false) ?? []) as string[]
  const permissionCodes = [...new Set([...checked, ...half].map(String))]
  await runExclusive(saving, async () => {
    try {
      await replaceJobTypePermissions(selectedJobId.value!, permissionCodes)
      checkedCodes.value = permissionCodes
      uiMessage.success('权限已保存')
    } catch (error) {
      notifyError(error)
    }
  })
}

watch(
  hasViewPermission,
  async (ok) => {
    if (ok) {
      await loadPermissionTree()
      await loadJobTypes()
    } else {
      void loadJobTypes()
    }
  },
  { immediate: true },
)
</script>

<template>
  <section class="role-permission">
    <header class="page-header">
      <div>
        <h1>角色权限</h1>
        <p class="subtitle">
          此处为「权限角色」绑定（职务作为角色载体），与人事职务档案共用 TK_JobType
        </p>
      </div>
    </header>

    <el-alert
      type="info"
      :closable="false"
      show-icon
      title="选择左侧职务后勾选功能权限；保存将整表替换该职务的权限码集合。"
      style="margin-bottom: 0"
    />

    <div v-loading="loading" class="body-panel">
      <AppError
        v-if="listError && !loading"
        :description="listError"
        @retry="loadJobTypes"
      />
      <template v-else>
        <aside class="job-pane">
          <div class="pane-title">职务（角色）</div>
          <el-table
            :data="jobTypes"
            border
            size="small"
            highlight-current-row
            empty-text=" "
            max-height="560"
            @row-click="selectJob"
          >
            <el-table-column prop="name" label="名称" min-width="120" show-overflow-tooltip />
            <el-table-column label="状态" width="70">
              <template #default="{ row }">
                <el-tag :type="row.active !== false ? 'success' : 'info'" size="small">
                  {{ row.active !== false ? '启' : '停' }}
                </el-tag>
              </template>
            </el-table-column>
          </el-table>
          <AppEmpty
            v-if="!loading && jobTypes.length === 0"
            title="暂无职务"
            description="请先在职务管理中创建"
          />
        </aside>

        <div v-loading="permLoading" class="perm-pane">
          <div class="pane-head">
            <div class="pane-title">
              功能权限
              <span v-if="selectedJobId != null" class="muted">
                （职务 #{{ selectedJobId }}）
              </span>
            </div>
            <el-button
              v-if="hasEditPermission"
              type="primary"
              size="small"
              :loading="saving"
              :disabled="selectedJobId == null"
              @click="handleSave"
            >
              保存权限
            </el-button>
          </div>
          <AppError v-if="permError" :description="permError" @retry="() => selectedJobId != null && loadJobPermissions(selectedJobId)" />
          <template v-else-if="selectedJobId == null">
            <AppEmpty title="请选择职务" description="点击左侧列表中的职务以配置权限" />
          </template>
          <el-tree
            v-else
            ref="treeRef"
            :data="permissionTree"
            node-key="code"
            show-checkbox
            default-expand-all
            :props="{ label: 'name', children: 'children' }"
            :default-checked-keys="checkedCodes"
          >
            <template #default="{ data }">
              <span class="perm-node">
                <span>{{ data.name || data.code }}</span>
                <span class="muted code">{{ data.code }}</span>
              </span>
            </template>
          </el-tree>
        </div>
      </template>
    </div>
  </section>
</template>

<style scoped>
.role-permission {
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

.body-panel {
  display: grid;
  grid-template-columns: minmax(220px, 300px) 1fr;
  gap: 16px;
  min-height: 420px;
}

.job-pane,
.perm-pane {
  padding: 14px;
  border: 1px solid #ebeef5;
  border-radius: 8px;
  background: #fff;
  min-height: 360px;
}

.pane-title {
  margin-bottom: 10px;
  font-size: 14px;
  font-weight: 600;
  color: #303133;
}

.pane-head {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 8px;
  margin-bottom: 10px;
}

.perm-node {
  display: inline-flex;
  align-items: center;
  gap: 8px;
}

.muted {
  color: #909399;
  font-weight: 400;
  font-size: 12px;
}

.code {
  font-family: ui-monospace, monospace;
}

@media (max-width: 900px) {
  .body-panel {
    grid-template-columns: 1fr;
  }
}
</style>
