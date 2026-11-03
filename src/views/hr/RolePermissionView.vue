<script setup lang="ts">
import { computed, onMounted, ref } from 'vue'

import AppEmpty from '@/components/common/AppEmpty.vue'
import AppError from '@/components/common/AppError.vue'
import {
  businessCenters,
  menusByCenter,
  type AppMenuItem,
} from '@/config/menu'
import {
  createJobType,
  fetchJobTypePage,
  fetchJobTypePermissions,
  fetchPermissionTree,
  replaceJobTypePermissions,
  updateJobType,
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
const records = ref<JobTypeRecord[]>([])
const total = ref(0)
const page = ref(1)
const size = ref(10)
const nameInput = ref('')
const nameKeyword = ref('')

const permissionTree = ref<MenuPermissionNode[]>([])
const permissionLoaded = ref(false)
const checkedCodes = ref<string[]>([])
const sections = ref<PermSection[]>([])
const activeSectionId = ref('')
const permKeyword = ref('')
const onlyChecked = ref(false)
const permTab = ref<'pc' | 'mini'>('pc')

const formVisible = ref(false)
const formMode = ref<'create' | 'edit'>('create')
const formName = ref('')
const formError = ref<string | null>(null)
const formSaving = ref(false)
const permLoading = ref(false)
const editingJob = ref<JobTypeRecord | null>(null)

interface PermPage {
  key: string
  title: string
  codes: string[]
}

interface PermGroup {
  key: string
  title: string
  pages: PermPage[]
}

interface PermSection {
  id: string
  title: string
  groups: PermGroup[]
}

const checkedSet = computed(() => new Set(checkedCodes.value))

function walkNodes(
  nodes: MenuPermissionNode[],
  visit: (node: MenuPermissionNode, depth: number) => void,
  depth = 0,
): void {
  for (const node of nodes) {
    visit(node, depth)
    if (node.children?.length) walkNodes(node.children, visit, depth + 1)
  }
}

function isActionNode(node: MenuPermissionNode): boolean {
  const type = (node.type ?? '').toUpperCase()
  return type !== 'M' && type !== 'P'
}

/** 菜单页面对应的权限码覆盖表（菜单本身未声明 permission 的页面）。 */
const PAGE_CODE_OVERRIDES: Record<string, string[]> = {
  '/customers': [
    'customer:mobile:view',
    'customer:mobile:edit',
    'customer:tag:custom',
    'customer:level:override',
    'customer:cross-store:edit',
    'customer:edit',
    'customer:servicer:edit',
    'customer:service-log:delete',
    'customer:owner-store:edit',
    'customer:file:delete',
    'customer:export:masked',
    'customer:export:full',
    'customer:list:view',
    'customer:create',
  ],
}

/** 权限矩阵中的二级分组标题覆盖（与业务中心命名保持一致）。 */
const GROUP_TITLE_OVERRIDES: Record<string, string> = {
  'group-store-customers': '客户管理',
}

function buildSectionData(): void {
  const nodeMap = new Map<string, MenuPermissionNode>()
  const actionMap = new Map<string, MenuPermissionNode>()
  walkNodes(permissionTree.value, (node) => {
    nodeMap.set(node.code, node)
    if (isActionNode(node) && !node.children?.length) actionMap.set(node.code, node)
  })

  const collectActions = (node: MenuPermissionNode): string[] => {
    if (!node.children?.length) return actionMap.has(node.code) ? [node.code] : []
    const result: string[] = []
    for (const child of node.children) result.push(...collectActions(child))
    return result
  }

  const resolveCodes = (code: string): string[] => {
    const node = nodeMap.get(code)
    if (!node) return []
    if (node.children?.length) return collectActions(node)
    const parent = node.parentCode ? nodeMap.get(node.parentCode) : null
    if (parent && (parent.type ?? '').toUpperCase() === 'P') {
      return collectActions(parent)
    }
    const segments = code.split(':')
    const stem = segments.slice(0, -1).join(':')
    const depth = segments.length
    return [...actionMap.keys()].filter(
      (item) => item.startsWith(stem + ':') && item.split(':').length === depth,
    )
  }

  const codesForPage = (item: AppMenuItem): string[] => {
    const override = item.path ? PAGE_CODE_OVERRIDES[item.path] : undefined
    const source = override ?? (item.permission ? resolveCodes(item.permission) : [])
    return [...new Set(source)].filter((code) => actionMap.has(code))
  }

  const used = new Set<string>()
  const built: PermSection[] = []
  for (const center of businessCenters) {
    const groups: PermGroup[] = []
    for (const item of menusByCenter[center.id]) {
      if (item.placeholder) continue
      const leaves = item.children?.length
        ? item.children.filter((child) => !child.children?.length)
        : [item]
      if (leaves.length === 0) continue
      const pages: PermPage[] = leaves.map((leaf) => {
        const codes = codesForPage(leaf)
        for (const code of codes) used.add(code)
        return {
          key: `${center.id}:${leaf.name}`,
          title: leaf.title,
          codes,
        }
      })
      groups.push({
        key: `${center.id}:${item.name}`,
        title: GROUP_TITLE_OVERRIDES[item.name] ?? item.title,
        pages,
      })
    }
    if (groups.length) {
      built.push({ id: center.id, title: center.title, groups })
    }
  }

  const leftovers = [...actionMap.keys()].filter((code) => !used.has(code))
  if (leftovers.length) {
    const groups: PermGroup[] = []
    walkNodes(permissionTree.value, (node, depth) => {
      if (depth !== 0) return
      const codes = collectActions(node).filter((code) => leftovers.includes(code))
      if (codes.length) {
        groups.push({
          key: `other:${node.code}`,
          title: node.name || node.code,
          pages: [
            {
              key: `other:${node.code}`,
              title: node.name || node.code,
              codes,
            },
          ],
        })
      }
    })
    if (groups.length) {
      built.push({ id: 'other', title: '其他权限', groups })
    }
  }

  sections.value = built
  if (!built.some((section) => section.id === activeSectionId.value)) {
    activeSectionId.value = built[0]?.id ?? ''
  }
}

const labelMap = computed(() => {
  const map = new Map<string, string>()
  walkNodes(permissionTree.value, (node) => map.set(node.code, node.name || node.code))
  return map
})

function codeLabel(code: string): string {
  return labelMap.value.get(code) ?? code
}

const activeSection = computed(() =>
  sections.value.find((section) => section.id === activeSectionId.value) ?? null,
)

function pageMatches(pageItem: PermPage, keyword: string): boolean {
  if (!keyword) return true
  if (pageItem.title.toLowerCase().includes(keyword)) return true
  return pageItem.codes.some((code) => codeLabel(code).toLowerCase().includes(keyword))
}

function visibleActions(pageItem: PermPage): string[] {
  const keyword = permKeyword.value.trim().toLowerCase()
  return pageItem.codes.filter((code) => {
    if (onlyChecked.value && !checkedSet.value.has(code)) return false
    if (!keyword) return true
    if (pageItem.title.toLowerCase().includes(keyword)) return true
    return codeLabel(code).toLowerCase().includes(keyword)
  })
}

function visiblePages(group: PermGroup): PermPage[] {
  const keyword = permKeyword.value.trim().toLowerCase()
  return group.pages.filter((pageItem) => {
    if (!pageMatches(pageItem, keyword)) return false
    if (onlyChecked.value && !pageItem.codes.some((code) => checkedSet.value.has(code))) {
      return false
    }
    if (keyword && pageItem.codes.length > 0 && visibleActions(pageItem).length === 0) {
      return false
    }
    return true
  })
}

const visibleGroups = computed(() => {
  const section = activeSection.value
  if (!section) return []
  return section.groups.filter((group) => visiblePages(group).length > 0)
})

function groupCodes(group: PermGroup): string[] {
  return [...new Set(group.pages.flatMap((pageItem) => pageItem.codes))]
}

function groupStats(group: PermGroup): { checked: boolean; indeterminate: boolean } {
  const codes = groupCodes(group)
  const selected = codes.filter((code) => checkedSet.value.has(code)).length
  return {
    checked: codes.length > 0 && selected === codes.length,
    indeterminate: selected > 0 && selected < codes.length,
  }
}

function pageState(pageItem: PermPage): { checked: boolean; indeterminate: boolean; disabled: boolean } {
  const selected = pageItem.codes.filter((code) => checkedSet.value.has(code)).length
  return {
    checked: pageItem.codes.length > 0 && selected === pageItem.codes.length,
    indeterminate: selected > 0 && selected < pageItem.codes.length,
    disabled: pageItem.codes.length === 0,
  }
}

function sectionCodes(section: PermSection): string[] {
  return [...new Set(section.groups.flatMap((group) => groupCodes(group)))]
}

function sectionSelected(section: PermSection): number {
  return sectionCodes(section).filter((code) => checkedSet.value.has(code)).length
}

function addCodes(codes: string[]): void {
  const next = new Set(checkedCodes.value)
  for (const code of codes) next.add(code)
  checkedCodes.value = [...next]
}

function removeCodes(codes: string[]): void {
  const next = new Set(checkedCodes.value)
  for (const code of codes) next.delete(code)
  checkedCodes.value = [...next]
}

function toggleCodes(codes: string[], checked: boolean): void {
  if (checked) addCodes(codes)
  else removeCodes(codes)
}

function selectVisible(): void {
  const section = activeSection.value
  if (!section) return
  const codes: string[] = []
  for (const group of visibleGroups.value) {
    for (const pageItem of visiblePages(group)) {
      codes.push(...visibleActions(pageItem))
    }
  }
  addCodes([...new Set(codes)])
}

function clearAll(): void {
  checkedCodes.value = []
}

const leafCodeList = computed(() => {
  const result: string[] = []
  walkNodes(permissionTree.value, (node) => {
    if (!node.children?.length && isActionNode(node) && node.code) result.push(node.code)
  })
  return result
})

const pcSelected = computed(() =>
  leafCodeList.value.filter((code) => checkedSet.value.has(code)).length,
)
const pcTotal = computed(() => leafCodeList.value.length)

function hasSelectedLeaf(node: MenuPermissionNode): boolean {
  if (!node.children?.length) return checkedSet.value.has(node.code)
  return node.children.some((child) => hasSelectedLeaf(child))
}

const pageStats = computed(() => {
  const all: MenuPermissionNode[] = []
  walkNodes(permissionTree.value, (node) => {
    if ((node.type ?? '').toUpperCase() === 'P') all.push(node)
  })
  const selected = all.filter((node) => hasSelectedLeaf(node)).length
  return { selected, total: all.length }
})

const buttonStats = computed(() => {
  const all: MenuPermissionNode[] = []
  walkNodes(permissionTree.value, (node) => {
    const type = (node.type ?? '').toUpperCase()
    if (!node.children?.length && (type === 'B' || type === 'A')) all.push(node)
  })
  const selected = all.filter((node) => checkedSet.value.has(node.code)).length
  return { selected, total: all.length }
})

async function loadPage(): Promise<void> {
  if (!hasViewPermission.value) {
    records.value = []
    total.value = 0
    listError.value = '暂无权限查看角色权限（org:role:view）'
    return
  }
  await runExclusive(loading, async () => {
    listError.value = null
    try {
      const data = await fetchJobTypePage({
        keyword: nameKeyword.value || undefined,
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
  nameKeyword.value = nameInput.value.trim()
  page.value = 1
  void loadPage()
}

function handlePageChange(value: number): void {
  page.value = value
  void loadPage()
}

async function ensurePermissionTree(): Promise<void> {
  if (permissionLoaded.value) return
  permissionTree.value = await fetchPermissionTree()
  permissionLoaded.value = true
  buildSectionData()
}

function resetForm(): void {
  formError.value = null
  permKeyword.value = ''
  onlyChecked.value = false
  permTab.value = 'pc'
  checkedCodes.value = []
  activeSectionId.value = ''
  editingJob.value = null
}

async function openCreate(): Promise<void> {
  if (!hasEditPermission.value) return
  resetForm()
  formMode.value = 'create'
  formName.value = ''
  formVisible.value = true
  permLoading.value = true
  try {
    await ensurePermissionTree()
    activeSectionId.value = sections.value[0]?.id ?? ''
  } catch (error) {
    formError.value = getUserFriendlyErrorMessage(error)
  } finally {
    permLoading.value = false
  }
}

async function openEdit(row: JobTypeRecord): Promise<void> {
  if (!hasEditPermission.value) return
  resetForm()
  formMode.value = 'edit'
  editingJob.value = row
  formName.value = row.name ?? ''
  formVisible.value = true
  permLoading.value = true
  try {
    await ensurePermissionTree()
    const codes = await fetchJobTypePermissions(row.id)
    const known = new Set(leafCodeList.value)
    checkedCodes.value = [...new Set(codes)].filter((code) => known.has(code))
    activeSectionId.value = sections.value[0]?.id ?? ''
  } catch (error) {
    formError.value = getUserFriendlyErrorMessage(error)
  } finally {
    permLoading.value = false
  }
}

function withAncestors(codes: string[]): string[] {
  const parentMap = new Map<string, string | null>()
  walkNodes(permissionTree.value, (node) => parentMap.set(node.code, node.parentCode))
  const result = new Set(codes)
  for (const code of codes) {
    let parent = parentMap.get(code) ?? null
    while (parent) {
      result.add(parent)
      parent = parentMap.get(parent) ?? null
    }
  }
  return [...result]
}

async function handleSubmit(): Promise<void> {
  const name = formName.value.trim()
  if (!name) {
    uiMessage.warning('请输入角色名称')
    return
  }
  formError.value = null
  await runExclusive(formSaving, async () => {
    try {
      const codes = withAncestors(checkedCodes.value)
      if (formMode.value === 'create') {
        const created = await createJobType({ name, active: true })
        await replaceJobTypePermissions(created.id, codes)
        uiMessage.success('角色已创建')
      } else if (editingJob.value != null) {
        await updateJobType(editingJob.value.id, {
          name,
          description: editingJob.value.description ?? undefined,
          active: editingJob.value.active !== false,
        })
        await replaceJobTypePermissions(editingJob.value.id, codes)
        uiMessage.success('角色权限已保存，相关员工需重新登录后生效')
      }
      formVisible.value = false
      await loadPage()
    } catch (error) {
      formError.value = getUserFriendlyErrorMessage(error)
      notifyError(error)
    }
  })
}

onMounted(() => {
  void loadPage()
})
</script>

<template>
  <section class="role-page">
    <el-form :inline="true" class="filter-bar" @submit.prevent="handleSearch">
      <el-form-item label="角色名称">
        <el-input
          v-model="nameInput"
          clearable
          placeholder="输入角色名称搜索"
          style="width: 220px"
          @keyup.enter="handleSearch"
          @clear="handleSearch"
        />
      </el-form-item>
      <el-form-item>
        <el-button type="primary" @click="handleSearch">搜索</el-button>
      </el-form-item>
      <div class="filter-spacer"></div>
      <el-button v-if="hasEditPermission" type="primary" @click="openCreate">新增</el-button>
    </el-form>

    <div v-loading="loading" class="table-panel">
      <AppError
        v-if="listError && !loading"
        :description="listError"
        @retry="loadPage"
      />
      <template v-else>
        <el-table :data="records" class="role-table" empty-text="暂无角色">
          <el-table-column prop="name" label="角色名称" min-width="200" />
          <el-table-column label="操作" width="120" align="right">
            <template #default="{ row }">
              <el-button
                v-if="hasEditPermission"
                type="primary"
                size="small"
                @click="openEdit(row as JobTypeRecord)"
              >
                编辑
              </el-button>
              <span v-else class="muted">—</span>
            </template>
          </el-table-column>
        </el-table>
        <div class="pager">
          <el-pagination
            v-model:current-page="page"
            background
            :page-size="size"
            :total="total"
            layout="total, prev, pager, next, jumper"
            @current-change="handlePageChange"
          />
        </div>
      </template>
    </div>

    <el-dialog
      v-model="formVisible"
      :title="formMode === 'create' ? '新增角色' : '编辑角色'"
      width="980px"
      top="6vh"
      destroy-on-close
      :close-on-click-modal="false"
    >
      <div v-loading="permLoading" class="role-form">
        <div class="name-row">
          <span class="required">*</span>
          <span class="name-label">角色名称</span>
          <el-input
            v-model="formName"
            maxlength="50"
            show-word-limit
            style="width: 300px"
          />
        </div>

        <div class="perm-head">
          <div class="perm-tabs">
            <button
              type="button"
              class="perm-tab"
              :class="{ active: permTab === 'pc' }"
              @click="permTab = 'pc'"
            >
              PC权限设置
              <span class="tab-count">{{ pcSelected }}/{{ pcTotal }}</span>
            </button>
            <button
              type="button"
              class="perm-tab"
              :class="{ active: permTab === 'mini' }"
              @click="permTab = 'mini'"
            >
              小程序权限设置
              <span class="tab-count">0/0</span>
            </button>
          </div>
          <span class="summary">
            已选 {{ pageStats.selected }}/{{ pageStats.total }} 个页面，{{ buttonStats.selected }}/{{ buttonStats.total }} 个按钮权限
          </span>
        </div>

        <template v-if="permTab === 'pc'">
          <div class="matrix-toolbar">
            <el-input
              v-model="permKeyword"
              clearable
              placeholder="搜索页面或权限名称"
              style="width: 220px"
            />
            <el-checkbox v-model="onlyChecked" size="small">只看已选</el-checkbox>
            <el-button size="small" @click="selectVisible">本页全选</el-button>
            <el-button size="small" @click="clearAll">清空</el-button>
          </div>

          <div class="matrix">
            <aside class="rail">
              <div
                v-for="section in sections"
                :key="section.id"
                class="rail-item"
                :class="{ active: activeSection?.id === section.id }"
                @click="activeSectionId = section.id"
              >
                <span class="rail-name">{{ section.title }}</span>
                <span class="rail-count">{{ sectionSelected(section) }}/{{ sectionCodes(section).length }}</span>
              </div>
            </aside>

            <div v-if="activeSection" class="groups">
              <div
                v-for="group in visibleGroups"
                :key="group.key"
                class="group-block"
              >
                <div class="group-main">
                  <el-checkbox
                    size="small"
                    :model-value="groupStats(group).checked"
                    :indeterminate="groupStats(group).indeterminate"
                    @change="(value: string | number | boolean) => toggleCodes(groupCodes(group), Boolean(value))"
                  >
                    {{ group.title }}
                  </el-checkbox>
                </div>
                <div class="group-pages">
                  <div
                    v-for="pageItem in visiblePages(group)"
                    :key="pageItem.key"
                    class="page-row"
                  >
                    <el-checkbox
                      size="small"
                      class="page-title"
                      :model-value="pageState(pageItem).checked"
                      :indeterminate="pageState(pageItem).indeterminate"
                      :disabled="pageState(pageItem).disabled"
                      @change="(value: string | number | boolean) => toggleCodes(pageItem.codes, Boolean(value))"
                    >
                      {{ pageItem.title }}
                    </el-checkbox>
                    <div class="page-actions">
                      <el-checkbox
                        v-for="code in visibleActions(pageItem)"
                        :key="code"
                        size="small"
                        :model-value="checkedSet.has(code)"
                        @change="(value: string | number | boolean) => toggleCodes([code], Boolean(value))"
                      >
                        {{ codeLabel(code) }}
                      </el-checkbox>
                      <span v-if="pageItem.codes.length === 0" class="dash">—</span>
                    </div>
                  </div>
                </div>
              </div>
              <div v-if="visibleGroups.length === 0" class="matrix-empty">
                没有匹配的权限
              </div>
            </div>
            <div v-else class="matrix-empty">暂无权限数据</div>
          </div>
        </template>

        <div v-else class="mini-empty">
          <AppEmpty title="暂无小程序权限配置" description="当前版本仅支持 PC 端权限设置" />
        </div>

        <p v-if="formError" class="form-error">{{ formError }}</p>
      </div>

      <template #footer>
        <div class="dialog-footer">
          <el-button @click="formVisible = false">取消</el-button>
          <el-button type="primary" :loading="formSaving" @click="handleSubmit">保存</el-button>
        </div>
      </template>
    </el-dialog>
  </section>
</template>

<style scoped>
.role-page {
  display: flex;
  flex-direction: column;
  gap: 12px;
  min-height: 100%;
  padding: 16px 20px 24px;
  background: #f5f7fa;
}

.filter-bar {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 14px 16px;
  background: #fff;
  border-radius: 4px;
}

.filter-bar :deep(.el-form-item) {
  margin-bottom: 0;
  margin-right: 8px;
}

.filter-spacer {
  flex: 1;
}

.table-panel {
  min-height: 420px;
  padding: 0 16px 16px;
  background: #fff;
  border-radius: 4px;
}

.role-table :deep(.el-table__inner-wrapper::before) {
  display: none;
}

.role-table :deep(.el-table__cell) {
  padding: 10px 0;
}

.role-table :deep(th.el-table__cell) {
  background: #f5f7fa;
  color: #303133;
  font-weight: 600;
}

.role-table :deep(.el-table__row:hover > td.el-table__cell) {
  background: #fafafa;
}

.pager {
  display: flex;
  justify-content: flex-end;
  padding-top: 14px;
}

.muted {
  color: #909399;
}

.name-row {
  display: flex;
  align-items: center;
  gap: 8px;
  margin-bottom: 14px;
}

.required {
  color: #f56c6c;
}

.name-label {
  font-size: 14px;
  color: #303133;
}

.perm-head {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 16px;
  margin-bottom: 12px;
}

.perm-tabs {
  display: flex;
  gap: 6px;
}

.perm-tab {
  padding: 6px 14px;
  font-size: 13px;
  color: #606266;
  background: #f2f3f5;
  border: none;
  border-radius: 2px;
  cursor: pointer;
}

.perm-tab.active {
  color: #fff;
  background: #ff7a00;
}

.tab-count {
  margin-left: 4px;
  color: inherit;
}

.perm-tab:not(.active) .tab-count {
  color: #ff7a00;
}

.summary {
  font-size: 12px;
  color: #909399;
}

.matrix-toolbar {
  display: flex;
  align-items: center;
  gap: 12px;
  margin-bottom: 8px;
}

.matrix {
  display: grid;
  grid-template-columns: 180px 1fr;
  height: 440px;
  border: 1px solid #e4e7ed;
  overflow: hidden;
}

.rail {
  overflow-y: auto;
  background: #fafafa;
  border-right: 1px solid #e4e7ed;
}

.rail-item {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 8px;
  padding: 10px 12px;
  font-size: 13px;
  color: #606266;
  cursor: pointer;
  border-bottom: 1px solid #f0f0f0;
}

.rail-item:hover {
  color: #ff7a00;
}

.rail-item.active {
  color: #ff7a00;
  background: #fff;
  border-left: 3px solid #ff7a00;
  padding-left: 9px;
}

.rail-count {
  font-size: 12px;
  color: #909399;
}

.groups {
  overflow-y: auto;
}

.group-block {
  display: grid;
  grid-template-columns: 200px 1fr;
  border-bottom: 1px dashed #ebeef5;
}

.group-main {
  display: flex;
  align-items: flex-start;
  padding: 10px 12px;
  border-right: 1px dashed #ebeef5;
}

.group-pages {
  display: flex;
  flex-direction: column;
}

.page-row {
  display: flex;
  align-items: flex-start;
  gap: 10px;
  padding: 7px 12px;
  min-height: 34px;
  border-bottom: 1px dashed #f2f2f2;
}

.page-row:last-child {
  border-bottom: none;
}

.page-title {
  flex: 0 0 130px;
}

.page-actions {
  display: flex;
  flex-wrap: wrap;
  align-items: center;
  gap: 4px 16px;
  min-width: 0;
}

.page-actions :deep(.el-checkbox) {
  margin-right: 0;
}

.dash {
  color: #c0c4cc;
  font-size: 12px;
}

.matrix-empty {
  padding: 24px;
  text-align: center;
  font-size: 13px;
  color: #909399;
}

.mini-empty {
  display: flex;
  align-items: center;
  justify-content: center;
  height: 460px;
  border: 1px solid #e4e7ed;
}

.form-error {
  margin: 10px 0 0;
  font-size: 12px;
  color: #f56c6c;
}

.dialog-footer {
  display: flex;
  justify-content: flex-end;
  gap: 8px;
}

.role-page :deep(.el-button--primary:not(.is-link):not(.is-text)) {
  --el-button-bg-color: #ff7a00;
  --el-button-border-color: #ff7a00;
  --el-button-hover-bg-color: #ff9333;
  --el-button-hover-border-color: #ff9333;
  --el-button-active-bg-color: #e56b00;
  --el-button-active-border-color: #e56b00;
}

.role-form :deep(.el-button--primary:not(.is-link):not(.is-text)) {
  --el-button-bg-color: #ff7a00;
  --el-button-border-color: #ff7a00;
  --el-button-hover-bg-color: #ff9333;
  --el-button-hover-border-color: #ff9333;
  --el-button-active-bg-color: #e56b00;
  --el-button-active-border-color: #e56b00;
}

.role-page :deep(.el-pagination.is-background .el-pager li.is-active) {
  background-color: #ff7a00;
  color: #fff;
}
</style>
