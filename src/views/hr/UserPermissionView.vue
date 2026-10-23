<script setup lang="ts">
import { computed, nextTick, ref, watch } from 'vue'
import type { ElTree, TableInstance } from 'element-plus'

import AppEmpty from '@/components/common/AppEmpty.vue'
import AppError from '@/components/common/AppError.vue'
import {
  batchReplaceEmployeeRoleAccess,
  fetchEmployeePage,
  fetchEmployeeRoleAccess,
  fetchJobTypePage,
  fetchOrganizationTree,
  replaceEmployeeRoleAccess,
  type OrganizationTreeNode,
} from '@/api/hr'
import {
  OrgPermission,
  type EmployeeRecord,
  type JobTypeRecord,
} from '@/types/hr'
import { usePermissionStore } from '@/stores/permission'
import {
  getUserFriendlyErrorMessage,
  notifyError,
  runExclusive,
  uiMessage,
} from '@/utils/ui'

defineOptions({ name: 'UserPermissionView' })

const permissionStore = usePermissionStore()

const hasViewPermission = computed(() =>
  permissionStore.hasPermission(OrgPermission.ROLE_VIEW),
)
const hasEditPermission = computed(() =>
  permissionStore.hasPermission(OrgPermission.ROLE_EDIT),
)

const loading = ref(false)
const listError = ref<string | null>(null)
const orgTree = ref<OrganizationTreeNode[]>([])
const jobTypes = ref<JobTypeRecord[]>([])
const tableRef = ref<TableInstance>()

const entityId = ref<number | null>(null)
const keywordInput = ref('')
const keyword = ref('')
const jobId = ref<number | null>(null)
const stateFilter = ref<'' | 'true' | 'false'>('true')
const page = ref(1)
const size = ref(10)
const total = ref(0)
const records = ref<EmployeeRecord[]>([])
const selectedRows = ref<EmployeeRecord[]>([])

const dialogVisible = ref(false)
const dialogLoading = ref(false)
const dialogSaving = ref(false)
const dialogError = ref<string | null>(null)
const dialogTab = ref<'roles' | 'scope'>('roles')
const targets = ref<EmployeeRecord[]>([])
const roleKeyword = ref('')
const selectedRoleIds = ref<number[]>([])
const orgKeyword = ref('')
const cascadeChildren = ref(true)
const orgCheckedCount = ref(0)
const pendingOrgKeys = ref<number[]>([])
const orgTreeRef = ref<InstanceType<typeof ElTree>>()

const visibleRoles = computed(() => {
  const keywordText = roleKeyword.value.trim()
  if (!keywordText) return jobTypes.value
  return jobTypes.value.filter((job) => (job.name ?? '').includes(keywordText))
})

const orgTotal = computed(() => countNodes(orgTree.value))

const settingLabel = computed(() => {
  if (targets.value.length === 1) {
    const row = targets.value[0]
    return `${row.name || '未命名'}（${row.id}）`
  }
  return `已选 ${targets.value.length} 人`
})

function countNodes(nodes: OrganizationTreeNode[]): number {
  let totalCount = 0
  const walk = (list: OrganizationTreeNode[]) => {
    for (const node of list) {
      totalCount += 1
      if (node.children?.length) walk(node.children)
    }
  }
  walk(nodes)
  return totalCount
}

function collectOrgIds(nodes: OrganizationTreeNode[]): number[] {
  const ids: number[] = []
  const walk = (list: OrganizationTreeNode[]) => {
    for (const node of list) {
      ids.push(node.id)
      if (node.children?.length) walk(node.children)
    }
  }
  walk(nodes)
  return ids
}

function rowOf(row: unknown): EmployeeRecord {
  return row as EmployeeRecord
}

function displayMobile(row: EmployeeRecord): string {
  return row.maskedMobile || row.phoneNumber || '—'
}

function unitText(row: EmployeeRecord): string {
  const list = row.entities ?? []
  if (list.length === 0) return '—'
  return list
    .map((item) => {
      const name = item.entityName?.trim() || `组织#${item.entityId}`
      return item.primaryEntity ? `${name}[主]` : name
    })
    .join('，')
}

function filterOrgNode(value: string, data: { entityName?: string | null }): boolean {
  if (!value) return true
  return (data.entityName ?? '').includes(value.trim())
}

async function loadAllJobTypes(): Promise<JobTypeRecord[]> {
  const pageSize = 100
  const all: JobTypeRecord[] = []
  for (let pageNo = 1; pageNo <= 10; pageNo += 1) {
    const data = await fetchJobTypePage({ page: pageNo, size: pageSize })
    const rows = data.records ?? []
    all.push(...rows)
    if (rows.length < pageSize || all.length >= (data.total ?? 0)) break
  }
  return all
}

async function loadMeta(): Promise<void> {
  try {
    const [jobs, orgs] = await Promise.all([loadAllJobTypes(), fetchOrganizationTree(false)])
    jobTypes.value = jobs
    orgTree.value = orgs
    if (entityId.value == null && orgs.length > 0) {
      entityId.value = orgs[0].id
    }
  } catch (error) {
    notifyError(error)
  }
}

async function loadList(): Promise<void> {
  if (!hasViewPermission.value) {
    records.value = []
    total.value = 0
    listError.value = '暂无权限查看用户权限（org:role:view）'
    return
  }
  if (entityId.value == null) {
    records.value = []
    total.value = 0
    listError.value = null
    return
  }
  await runExclusive(loading, async () => {
    listError.value = null
    try {
      const data = await fetchEmployeePage({
        entityId: entityId.value!,
        keyword: keyword.value.trim() || undefined,
        jobId: jobId.value ?? undefined,
        state:
          stateFilter.value === 'true'
            ? true
            : stateFilter.value === 'false'
              ? false
              : undefined,
        page: page.value,
        size: size.value,
      })
      records.value = data.records ?? []
      total.value = data.total ?? 0
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
  tableRef.value?.clearSelection()
  selectedRows.value = []
  void loadList()
}

function handleReset(): void {
  keywordInput.value = ''
  keyword.value = ''
  jobId.value = null
  stateFilter.value = 'true'
  page.value = 1
  tableRef.value?.clearSelection()
  selectedRows.value = []
  void loadList()
}

function handlePageChange(next: number): void {
  page.value = next
  void loadList()
}

function onSelectionChange(rows: EmployeeRecord[]): void {
  selectedRows.value = rows
}

function syncOrgCount(): void {
  const keys = orgTreeRef.value?.getCheckedKeys(false) ?? []
  orgCheckedCount.value = keys.length
}

function applyOrgKeys(keys: number[]): void {
  orgTreeRef.value?.setCheckedKeys(keys)
  syncOrgCount()
}

async function openAssign(rows: EmployeeRecord[]): Promise<void> {
  if (!hasEditPermission.value || rows.length === 0) return
  if (rows.length > 100) {
    uiMessage.warning('一次最多设置 100 名员工')
    return
  }
  targets.value = rows
  dialogTab.value = 'roles'
  roleKeyword.value = ''
  orgKeyword.value = ''
  cascadeChildren.value = true
  selectedRoleIds.value = []
  pendingOrgKeys.value = []
  orgCheckedCount.value = 0
  dialogError.value = null
  dialogVisible.value = true
  if (rows.length !== 1) return
  dialogLoading.value = true
  try {
    const data = await fetchEmployeeRoleAccess(rows[0].id)
    selectedRoleIds.value = (data.jobTypes ?? []).map((job) => job.id)
    const keys = data.resolvedOrgEntityIds?.length
      ? data.resolvedOrgEntityIds
      : (data.orgEntityIds ?? [])
    pendingOrgKeys.value = keys
    await nextTick()
    applyOrgKeys(keys)
  } catch (error) {
    dialogError.value = getUserFriendlyErrorMessage(error)
  } finally {
    dialogLoading.value = false
  }
}

function onDialogOpened(): void {
  applyOrgKeys(pendingOrgKeys.value)
  if (orgKeyword.value.trim()) {
    orgTreeRef.value?.filter(orgKeyword.value.trim())
  }
}

function selectVisibleRoles(): void {
  const picked = new Set(selectedRoleIds.value)
  for (const role of visibleRoles.value) picked.add(role.id)
  selectedRoleIds.value = [...picked]
}

function clearRoles(): void {
  selectedRoleIds.value = []
}

function selectAllOrgs(): void {
  applyOrgKeys(collectOrgIds(orgTree.value))
}

function clearOrgs(): void {
  applyOrgKeys([])
}

function setOrgExpanded(expanded: boolean): void {
  const walk = (list: OrganizationTreeNode[]) => {
    for (const node of list) {
      const treeNode = orgTreeRef.value?.getNode(node.id)
      if (treeNode) treeNode.expanded = expanded
      if (node.children?.length) walk(node.children)
    }
  }
  walk(orgTree.value)
}

function currentOrgIds(): number[] {
  const checked = (orgTreeRef.value?.getCheckedKeys(false) ?? []) as Array<string | number>
  return checked.map(Number).filter((id) => Number.isFinite(id))
}

async function handleSave(): Promise<void> {
  if (!hasEditPermission.value || targets.value.length === 0) return
  if (selectedRoleIds.value.length === 0) {
    dialogTab.value = 'roles'
    uiMessage.warning('请至少选择一个角色')
    return
  }
  const orgEntityIds = currentOrgIds()
  if (orgEntityIds.length === 0) {
    dialogTab.value = 'scope'
    uiMessage.warning('请至少勾选一个组织')
    return
  }
  await runExclusive(dialogSaving, async () => {
    dialogError.value = null
    try {
      if (targets.value.length === 1) {
        await replaceEmployeeRoleAccess(targets.value[0].id, {
          jobTypeIds: selectedRoleIds.value,
          orgEntityIds,
        })
        uiMessage.success('角色与权限范围已保存，该员工需重新登录后生效')
      } else {
        const updated = await batchReplaceEmployeeRoleAccess({
          employeeIds: targets.value.map((row) => row.id),
          jobTypeIds: selectedRoleIds.value,
          orgEntityIds,
        })
        uiMessage.success(`已覆盖 ${updated} 人的角色与权限范围，需重新登录后生效`)
        tableRef.value?.clearSelection()
        selectedRows.value = []
      }
      dialogVisible.value = false
    } catch (error) {
      dialogError.value = getUserFriendlyErrorMessage(error)
      notifyError(error)
    }
  })
}

watch(orgKeyword, (value) => {
  orgTreeRef.value?.filter(value.trim())
})

async function onCascadeChange(): Promise<void> {
  const keys = currentOrgIds()
  await nextTick()
  applyOrgKeys(keys)
}

watch(entityId, () => {
  keyword.value = keywordInput.value.trim()
  page.value = 1
  tableRef.value?.clearSelection()
  selectedRows.value = []
  void loadList()
})

watch(
  hasViewPermission,
  async (ok) => {
    if (!ok) {
      void loadList()
      return
    }
    const previous = entityId.value
    await loadMeta()
    if (entityId.value === previous) void loadList()
  },
  { immediate: true },
)
</script>

<template>
  <section class="user-permission">

    <el-form :inline="true" class="filter-bar" @submit.prevent="handleSearch">
      <el-form-item label="员工信息">
        <el-input
          v-model="keywordInput"
          clearable
          placeholder="编号、姓名或电话"
          style="width: 220px"
        />
      </el-form-item>
      <el-form-item label="职务">
        <el-select v-model="jobId" clearable filterable placeholder="全部职务" style="width: 160px">
          <el-option v-for="job in jobTypes" :key="job.id" :label="job.name" :value="job.id" />
        </el-select>
      </el-form-item>
      <el-form-item label="在职状态">
        <el-select v-model="stateFilter" placeholder="全部" style="width: 120px">
          <el-option label="全部" value="" />
          <el-option label="在职" value="true" />
          <el-option label="离职" value="false" />
        </el-select>
      </el-form-item>
      <el-form-item label="所属单位">
        <el-tree-select
          v-model="entityId"
          :data="orgTree"
          check-strictly
          filterable
          clearable
          node-key="id"
          :props="{ label: 'entityName', children: 'children' }"
          placeholder="选择组织，含全部下级"
          style="width: 240px"
        />
      </el-form-item>
      <el-form-item>
        <el-button type="primary" native-type="submit" :loading="loading">搜索</el-button>
        <el-button native-type="button" :disabled="loading" @click="handleReset">重置</el-button>
      </el-form-item>
    </el-form>

    <div class="list-panel">
      <div class="list-tools">
        <el-button
          v-if="hasEditPermission"
          type="primary"
          :disabled="selectedRows.length === 0"
          @click="openAssign(selectedRows)"
        >
          批量设置角色/权限
          <span v-if="selectedRows.length">（{{ selectedRows.length }}）</span>
        </el-button>
        <span class="muted">选择上级组织后，列表包含该组织及全部下级中的员工。</span>
      </div>

      <div v-loading="loading">
        <AppError v-if="listError && !loading" :description="listError" @retry="loadList" />
        <template v-else>
          <el-alert
            v-if="entityId == null"
            type="info"
            :closable="false"
            show-icon
            title="请先选择所属单位"
            style="margin-bottom: 12px"
          />
          <el-table
            ref="tableRef"
            :data="records"
            row-key="id"
            stripe
            size="small"
            empty-text="暂无员工"
            @selection-change="onSelectionChange"
          >
            <el-table-column v-if="hasEditPermission" type="selection" reserve-selection width="48" />
            <el-table-column prop="id" label="员工编号" width="120" show-overflow-tooltip />
            <el-table-column prop="name" label="员工姓名" min-width="100" show-overflow-tooltip />
            <el-table-column label="电话" width="140">
              <template #default="{ row }">{{ displayMobile(rowOf(row)) }}</template>
            </el-table-column>
            <el-table-column label="所属单位" min-width="220" show-overflow-tooltip>
              <template #default="{ row }">{{ unitText(rowOf(row)) }}</template>
            </el-table-column>
            <el-table-column label="职务" min-width="110" show-overflow-tooltip>
              <template #default="{ row }">{{ rowOf(row).jobName || '—' }}</template>
            </el-table-column>
            <el-table-column label="在职状态" width="100">
              <template #default="{ row }">
                <el-tag :type="rowOf(row).state !== false ? 'success' : 'info'" size="small" effect="light">
                  {{ rowOf(row).state !== false ? '在职' : '离职' }}
                </el-tag>
              </template>
            </el-table-column>
            <el-table-column v-if="hasEditPermission" label="操作" width="150" fixed="right">
              <template #default="{ row }">
                <el-button type="primary" size="small" @click="openAssign([rowOf(row)])">
                  角色/权限分配
                </el-button>
              </template>
            </el-table-column>
          </el-table>
          <div v-if="total > 0" class="pager">
            <el-pagination
              background
              layout="total, prev, pager, next"
              :total="total"
              :current-page="page"
              :page-size="size"
              @current-change="handlePageChange"
            />
          </div>
        </template>
      </div>
    </div>

    <el-dialog
      v-model="dialogVisible"
      title="角色分配 / 权限范围"
      width="920px"
      destroy-on-close
      :close-on-click-modal="false"
      @opened="onDialogOpened"
    >
      <div v-loading="dialogLoading" class="assign-dialog">
        <div class="setting-line">
          <strong>正在设置：{{ settingLabel }}</strong>
          <span>调整后员工需要重新登录才生效</span>
        </div>
        <p v-if="targets.length > 1" class="batch-note">
          保存后，所选员工原有的角色和组织范围会被这一套配置覆盖。
        </p>
        <AppError v-if="dialogError" :description="dialogError" />

        <el-tabs v-model="dialogTab">
          <el-tab-pane name="roles">
            <template #label>
              <span class="tab-label">
                角色分配
                <span class="tab-count">{{ selectedRoleIds.length }}</span>
              </span>
            </template>
            <div class="tool-row">
              <el-input v-model="roleKeyword" clearable placeholder="搜索角色名称" style="width: 220px" />
              <el-button @click="selectVisibleRoles">全选</el-button>
              <el-button @click="clearRoles">清空</el-button>
              <span class="muted">已选 {{ selectedRoleIds.length }} / {{ jobTypes.length }} 个角色</span>
            </div>
            <el-checkbox-group v-model="selectedRoleIds" class="role-grid">
              <el-checkbox v-for="role in visibleRoles" :key="role.id" :value="role.id">
                {{ role.name }}
                <el-tag v-if="role.active === false" size="small" type="info" effect="plain">停</el-tag>
              </el-checkbox>
            </el-checkbox-group>
            <AppEmpty
              v-if="visibleRoles.length === 0"
              title="没有匹配的角色"
              description="换个名称再搜"
            />
          </el-tab-pane>

          <el-tab-pane name="scope">
            <template #label>
              <span class="tab-label">
                权限范围
                <span class="tab-count">{{ orgCheckedCount }}</span>
              </span>
            </template>
            <el-alert
              type="info"
              :closable="false"
              show-icon
              title="勾选上级后，该上级及其全部下级组织、门店都会纳入可访问范围。若取消某个下级但仍保留上级，这个下级依然可访问。默认开启「勾选时联动下级」：勾选或取消上级时，下级会一起变化。"
              class="scope-alert"
            />
            <div class="tool-row">
              <el-input v-model="orgKeyword" clearable placeholder="搜索组织名称" style="width: 220px" />
              <el-button @click="setOrgExpanded(true)">展开全部</el-button>
              <el-button @click="setOrgExpanded(false)">收起全部</el-button>
              <el-button @click="selectAllOrgs">全选</el-button>
              <el-button @click="clearOrgs">清空</el-button>
              <el-checkbox v-model="cascadeChildren" @change="onCascadeChange">勾选时联动下级</el-checkbox>
              <span class="muted">已选 {{ orgCheckedCount }} / {{ orgTotal }} 个组织</span>
            </div>
            <el-tree
              ref="orgTreeRef"
              class="scope-tree"
              :data="orgTree"
              node-key="id"
              show-checkbox
              default-expand-all
              :check-strictly="!cascadeChildren"
              :filter-node-method="filterOrgNode"
              :props="{ label: 'entityName', children: 'children' }"
              @check="syncOrgCount"
            >
              <template #default="{ data }">
                <span class="org-node">
                  <span>{{ data.entityName || `组织#${data.id}` }}</span>
                  <el-tag v-if="data.store === true" size="small" type="success" effect="plain">门店</el-tag>
                  <el-tag v-if="data.warehouse === true" size="small" type="info" effect="plain">物资库</el-tag>
                </span>
              </template>
            </el-tree>
          </el-tab-pane>
        </el-tabs>
      </div>
      <template #footer>
        <el-button @click="dialogVisible = false">取消</el-button>
        <el-button type="primary" :loading="dialogSaving" @click="handleSave">保存</el-button>
      </template>
    </el-dialog>
  </section>
</template>

<style scoped>
.user-permission {
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

.filter-bar,
.list-panel {
  background: #fff;
  border: 1px solid #ebeef5;
  border-radius: 8px;
  padding: 14px 16px 4px;
}

.list-panel {
  padding-bottom: 16px;
}

.list-tools {
  display: flex;
  align-items: center;
  gap: 12px;
  margin-bottom: 12px;
}

.pager {
  display: flex;
  justify-content: flex-end;
  margin-top: 12px;
}

.setting-line {
  display: flex;
  align-items: baseline;
  gap: 12px;
  margin-bottom: 8px;
  color: #303133;
}

.setting-line span,
.batch-note,
.muted {
  color: #909399;
  font-size: 13px;
}

.batch-note {
  margin: 0 0 8px;
}

.tab-label {
  display: inline-flex;
  align-items: center;
  gap: 6px;
}

.tab-count {
  min-width: 18px;
  height: 18px;
  padding: 0 6px;
  border-radius: 9px;
  background: var(--el-color-primary-light-9);
  color: var(--el-color-primary);
  font-size: 12px;
  line-height: 18px;
  text-align: center;
}

.tool-row {
  display: flex;
  flex-wrap: wrap;
  align-items: center;
  gap: 8px;
  margin-bottom: 12px;
}

.scope-alert {
  margin-bottom: 12px;
}

.role-grid {
  display: grid;
  grid-template-columns: repeat(3, minmax(0, 1fr));
  gap: 4px 12px;
  max-height: 420px;
  overflow: auto;
  padding: 8px;
  border: 1px solid #ebeef5;
  border-radius: 6px;
}

.role-grid :deep(.el-checkbox) {
  height: 34px;
  margin-right: 0;
  padding: 0 8px;
  border-radius: 4px;
}

.role-grid :deep(.el-checkbox:hover) {
  background: var(--el-color-primary-light-9);
}

.role-grid :deep(.el-checkbox.is-checked .el-checkbox__label) {
  color: var(--el-color-primary);
  font-weight: 600;
}

.scope-tree {
  max-height: 420px;
  overflow: auto;
  padding: 8px;
  border: 1px solid #ebeef5;
  border-radius: 6px;
}

.scope-tree :deep(.el-tree-node__content) {
  height: 34px;
  border-radius: 6px;
}

.scope-tree :deep(.el-tree-node__content:hover) {
  background: var(--el-color-primary-light-9);
}

.org-node {
  display: inline-flex;
  align-items: center;
  gap: 6px;
}

@media (max-width: 900px) {
  .role-grid {
    grid-template-columns: 1fr;
  }
}
</style>
