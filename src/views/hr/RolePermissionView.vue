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
const jobKeyword = ref('')
const selectedJobId = ref<number | null>(null)

const permLoading = ref(false)
const permError = ref<string | null>(null)
const permissionTree = ref<MenuPermissionNode[]>([])
const permKeyword = ref('')
const checkedCodes = ref<string[]>([])
const treeRef = ref<InstanceType<typeof ElTree>>()
const saving = ref(false)

const visibleJobs = computed(() => {
  const keyword = jobKeyword.value.trim()
  if (!keyword) return jobTypes.value
  return jobTypes.value.filter((job) => {
    const name = job.name ?? ''
    return name.includes(keyword) || String(job.id).includes(keyword)
  })
})

const selectedJob = computed(() =>
  jobTypes.value.find((job) => job.id === selectedJobId.value) ?? null,
)

function collectLeafCodes(nodes: MenuPermissionNode[]): string[] {
  const result: string[] = []
  const walk = (list: MenuPermissionNode[]) => {
    for (const node of list) {
      if (node.children?.length) {
        walk(node.children)
      } else if (node.code) {
        result.push(node.code)
      }
    }
  }
  walk(nodes)
  return result
}

function permTypeLabel(node: MenuPermissionNode): string {
  const type = (node.type ?? '').toUpperCase()
  if (type === 'B') return '操作'
  if (type === 'A') return '接口'
  if (type === 'P') return '页面'
  if (type === 'M' || node.menu === true) return '菜单'
  return ''
}

function filterPermNode(value: string, data: { name?: string | null; code?: string }): boolean {
  if (!value) return true
  const keyword = value.trim().toLowerCase()
  const name = (data.name ?? '').toLowerCase()
  const code = (data.code ?? '').toLowerCase()
  return name.includes(keyword) || code.includes(keyword)
}

async function loadAllJobTypes(): Promise<JobTypeRecord[]> {
  const size = 100
  const all: JobTypeRecord[] = []
  for (let page = 1; page <= 10; page += 1) {
    const data = await fetchJobTypePage({ page, size })
    const records = data.records ?? []
    all.push(...records)
    if (records.length < size || all.length >= (data.total ?? 0)) break
  }
  return all
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
      jobTypes.value = await loadAllJobTypes()
      if (
        selectedJobId.value != null &&
        !jobTypes.value.some((job) => job.id === selectedJobId.value)
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
      const leafChecked = codes.filter((code) => leafSet.has(code))
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

function setPermExpanded(expanded: boolean): void {
  const walk = (list: MenuPermissionNode[]) => {
    for (const node of list) {
      const treeNode = treeRef.value?.getNode(node.code)
      if (treeNode) treeNode.expanded = expanded
      if (node.children?.length) walk(node.children)
    }
  }
  walk(permissionTree.value)
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
      uiMessage.success('权限已保存，相关员工需重新登录后生效')
    } catch (error) {
      notifyError(error)
    }
  })
}

watch(permKeyword, (value) => {
  treeRef.value?.filter(value.trim())
})

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

    <el-alert
      type="info"
      :closable="false"
      show-icon
      title="选择左侧职务后勾选功能权限；保存将整表替换该职务的权限码集合。员工需重新登录后生效。"
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
          <el-input
            v-model="jobKeyword"
            clearable
            placeholder="搜索职务名称"
            class="job-search"
          />
          <div class="job-count">{{ visibleJobs.length }} / {{ jobTypes.length }}</div>
          <el-table
            :data="visibleJobs"
            border
            size="small"
            highlight-current-row
            empty-text="没有匹配的职务"
            max-height="520"
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
              <span v-if="selectedJob" class="muted">（{{ selectedJob.name }}）</span>
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
          <AppError
            v-if="permError"
            :description="permError"
            @retry="() => selectedJobId != null && loadJobPermissions(selectedJobId)"
          />
          <template v-else-if="selectedJobId == null">
            <AppEmpty title="请选择职务" description="点击左侧列表中的职务以配置权限" />
          </template>
          <template v-else>
            <div class="tree-tools">
              <el-input
                v-model="permKeyword"
                clearable
                placeholder="搜索权限名称或编码"
                class="perm-search"
              />
              <el-button size="small" @click="setPermExpanded(true)">展开全部</el-button>
              <el-button size="small" @click="setPermExpanded(false)">收起全部</el-button>
            </div>
            <el-tree
              ref="treeRef"
              class="perm-tree"
              :data="permissionTree"
              node-key="code"
              show-checkbox
              default-expand-all
              :filter-node-method="filterPermNode"
              :props="{ label: 'name', children: 'children' }"
            >
              <template #default="{ data }">
                <span class="perm-node" :class="{ 'is-parent': data.children?.length }">
                  <span class="perm-name">{{ data.name || data.code }}</span>
                  <el-tag
                    v-if="permTypeLabel(data)"
                    size="small"
                    effect="plain"
                    :type="permTypeLabel(data) === '菜单' ? 'primary' : permTypeLabel(data) === '页面' ? 'success' : 'info'"
                  >
                    {{ permTypeLabel(data) }}
                  </el-tag>
                  <span class="perm-code">{{ data.code }}</span>
                </span>
              </template>
            </el-tree>
          </template>
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
  grid-template-columns: minmax(240px, 320px) 1fr;
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

.pane-head .pane-title {
  margin-bottom: 0;
}

.job-search {
  margin-bottom: 8px;
}

.job-count {
  margin-bottom: 8px;
  font-size: 12px;
  color: #909399;
}

.tree-tools {
  display: flex;
  align-items: center;
  gap: 8px;
  margin-bottom: 10px;
}

.perm-search {
  flex: 1;
}

.perm-tree {
  max-height: 560px;
  overflow: auto;
  padding: 4px;
  border: 1px solid #ebeef5;
  border-radius: 6px;
}

.perm-tree :deep(.el-tree-node__content) {
  height: 36px;
  border-radius: 6px;
}

.perm-tree :deep(.el-tree-node__content:hover) {
  background: var(--el-color-primary-light-9);
}

.perm-node {
  display: flex;
  align-items: center;
  gap: 8px;
  width: 100%;
  min-width: 0;
  padding-right: 8px;
}

.perm-name {
  color: #303133;
}

.is-parent .perm-name {
  font-weight: 600;
}

.perm-code {
  margin-left: auto;
  color: #909399;
  font-size: 12px;
  font-family: ui-monospace, SFMono-Regular, Menlo, Consolas, monospace;
  background: #f4f4f5;
  border-radius: 4px;
  padding: 0 6px;
  line-height: 20px;
}

.muted {
  color: #909399;
  font-weight: 400;
  font-size: 12px;
}

@media (max-width: 900px) {
  .body-panel {
    grid-template-columns: 1fr;
  }
}
</style>
