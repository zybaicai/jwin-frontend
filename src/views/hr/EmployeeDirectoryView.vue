<script setup lang="ts">
import { computed, nextTick, reactive, ref, watch } from 'vue'
import type { CascaderOption, ElTree } from 'element-plus'
import { Plus, ArrowDown } from '@element-plus/icons-vue'
import { codeToText, regionData } from 'element-china-area-data'

import AppEmpty from '@/components/common/AppEmpty.vue'
import AppError from '@/components/common/AppError.vue'
import { fetchPriceAreaList } from '@/api/card'
import {
  createEmployee,
  createOrganization,
  fetchEmployeeDetail,
  fetchEmployeeFullMobile,
  fetchEmployeePage,
  fetchJobTypePage,
  fetchOrganizationTree,
  updateEmployee,
  updateOrganization,
  type OrganizationTreeNode,
} from '@/api/hr'
import type { PriceAreaItem } from '@/types/card'
import {
  OrgPermission,
  type EmployeeRecord,
  type JobTypeRecord,
} from '@/types/hr'
import { useAuthStore } from '@/stores/auth'
import { usePermissionStore } from '@/stores/permission'
import {
  getUserFriendlyErrorMessage,
  notifyError,
  runExclusive,
  uiMessage,
} from '@/utils/ui'

defineOptions({ name: 'EmployeeDirectoryView' })

interface EntityTag {
  entityId: number
  entityName: string
  primary: boolean
}

const permissionStore = usePermissionStore()
const authStore = useAuthStore()

const hasViewPermission = computed(() =>
  permissionStore.hasPermission(OrgPermission.EMPLOYEE_VIEW),
)
const hasEditPermission = computed(() =>
  permissionStore.hasPermission(OrgPermission.EMPLOYEE_EDIT),
)
const hasMobilePermission = computed(() =>
  permissionStore.hasPermission(OrgPermission.MOBILE_VIEW_FULL),
)
const hasOrgEditPermission = computed(() =>
  permissionStore.hasPermission(OrgPermission.STORE_EDIT),
)

const loading = ref(false)
const listError = ref<string | null>(null)
const treeError = ref<string | null>(null)
const orgTree = ref<OrganizationTreeNode[]>([])
const jobTypes = ref<JobTypeRecord[]>([])
const treeRef = ref<InstanceType<typeof ElTree>>()
const treeKeyword = ref('')

const entityId = ref<number | null>(null)
const nameInput = ref('')
const mobileInput = ref('')
const nameKeyword = ref('')
const mobileKeyword = ref('')
const jobId = ref<number | null>(null)
const stateFilter = ref<'' | 'true' | 'false'>('true')
const page = ref(1)
const size = ref(10)
const total = ref(0)
const records = ref<EmployeeRecord[]>([])

const formVisible = ref(false)
const formMode = ref<'create' | 'edit'>('create')
const formLoading = ref(false)
const formSaving = ref(false)
const formError = ref<string | null>(null)
const editingId = ref<string | null>(null)
const formEntities = ref<EntityTag[]>([])

const form = reactive({
  id: '',
  name: '',
  alias: '',
  phoneNumber: '',
  gender: '0',
  jobId: null as number | null,
  idNumber: '',
  address: '',
  birthdate: '',
  entryDate: '',
  trialExpiryDate: '',
  contractStartDate: '',
  contractEndDate: '',
  socialSecurityPaymentDate: '',
  remark: '',
  state: true,
})

const orgPickVisible = ref(false)
const orgPickTreeRef = ref<InstanceType<typeof ElTree>>()

const orgFormVisible = ref(false)
const orgFormMode = ref<'create' | 'edit'>('create')
const orgFormSaving = ref(false)
const orgFormError = ref<string | null>(null)
const orgTab = ref<'base' | 'store'>('base')
const mapSearching = ref(false)
const priceAreas = ref<PriceAreaItem[]>([])
const orgForm = reactive({
  parentId: null as number | null,
  name: '',
  store: false,
  warehouse: false,
  active: true,
  region: [] as string[],
  addressDetail: '',
  longitude: null as number | null,
  latitude: null as number | null,
  remark: '',
  priceAreaId: null as number | null,
})

const selectedNode = computed(() =>
  entityId.value == null ? null : findNode(orgTree.value, entityId.value),
)
const selectedName = computed(() =>
  selectedNode.value ? nodeLabel(selectedNode.value) : '请选择组织',
)

const parentTree = computed(() => {
  const blocked = new Set<number>()
  if (orgFormMode.value === 'edit' && entityId.value != null) {
    collectNodeIds(findNode(orgTree.value, entityId.value), blocked)
  }
  return markOrgDisabled(orgTree.value, blocked)
})

const mapEmbedUrl = computed(() => {
  const lng = orgForm.longitude
  const lat = orgForm.latitude
  if (lng == null || lat == null) return ''
  const pad = 0.01
  const bbox = [lng - pad, lat - pad, lng + pad, lat + pad].join(',')
  return `https://www.openstreetmap.org/export/embed.html?bbox=${bbox}&layer=mapnik&marker=${lat},${lng}`
})

function rowOf(row: unknown): EmployeeRecord {
  return row as EmployeeRecord
}

function nodeLabel(node: OrganizationTreeNode): string {
  return node.entityName?.trim() || `组织#${node.id}`
}

function findNode(nodes: OrganizationTreeNode[], id: number): OrganizationTreeNode | null {
  for (const node of nodes) {
    if (node.id === id) return node
    if (node.children?.length) {
      const hit = findNode(node.children, id)
      if (hit) return hit
    }
  }
  return null
}

function firstSelectable(nodes: OrganizationTreeNode[]): OrganizationTreeNode | null {
  let first: OrganizationTreeNode | null = null
  const walk = (list: OrganizationTreeNode[]): OrganizationTreeNode | null => {
    for (const node of list) {
      if (first == null) first = node
      if (node.store === true) return node
      if (node.children?.length) {
        const hit = walk(node.children)
        if (hit) return hit
      }
    }
    return null
  }
  return walk(nodes) ?? first
}

function entityNameOf(id: number): string {
  const node = findNode(orgTree.value, id)
  return node ? nodeLabel(node) : `组织#${id}`
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

function displayMobile(row: EmployeeRecord | null | undefined): string {
  if (!row) return '—'
  return row.maskedMobile || row.phoneNumber || '—'
}

function genderCode(value: string | null | undefined): string {
  if (value === '1' || value === '男' || value === 'M') return '1'
  if (value === '2' || value === '女' || value === 'F') return '2'
  return '0'
}

function dateOrNull(value: string): string | null {
  return value ? value : null
}

function collectNodeIds(node: OrganizationTreeNode | null, acc: Set<number>): void {
  if (node == null) return
  acc.add(node.id)
  for (const child of node.children ?? []) collectNodeIds(child, acc)
}

function markOrgDisabled(
  nodes: OrganizationTreeNode[],
  blocked: Set<number>,
): Array<OrganizationTreeNode & { disabled?: boolean }> {
  return nodes.map((node) => ({
    ...node,
    disabled: blocked.has(node.id),
    children: markOrgDisabled(node.children ?? [], blocked),
  }))
}

function regionCodesOf(province?: string | null, city?: string | null, area?: string | null): string[] {
  const cut = (code: string | null | undefined, length: number): string => {
    const digits = (code ?? '').replace(/\D/g, '')
    if (!digits) return ''
    return digits.length >= length ? digits.slice(0, length) : digits
  }
  const provinceCode = cut(province, 2)
  const cityCode = cut(city, 4)
  const areaDigits = (area ?? '').replace(/\D/g, '')
  const areaCode = areaDigits.length >= 6 ? areaDigits.slice(0, 6) : areaDigits
  return [provinceCode, cityCode, areaCode].filter((item) => item.length > 0)
}

function regionText(): string {
  return orgForm.region.map((code) => codeToText[code] || '').join('')
}

function syncCurrentAccount(employeeId: string | null, name: string, jobId: number): void {
  const me = authStore.currentUser
  if (me == null || employeeId == null || employeeId !== me.employeeId) return
  me.employeeName = name
  me.jobId = jobId
  me.jobName = jobTypes.value.find((job) => job.id === jobId)?.name ?? me.jobName
}

async function loadPriceAreas(): Promise<void> {
  try {
    priceAreas.value = await fetchPriceAreaList(true)
  } catch {
    priceAreas.value = []
  }
}

function filterOrgNode(value: string, data: { entityName?: string | null }): boolean {
  if (!value) return true
  return (data.entityName ?? '').includes(value.trim())
}

async function loadOrgTree(): Promise<void> {
  treeError.value = null
  try {
    orgTree.value = await fetchOrganizationTree(false)
    await nextTick()
    if (entityId.value == null) {
      const node = firstSelectable(orgTree.value)
      if (node) entityId.value = node.id
    }
    if (entityId.value != null) {
      treeRef.value?.setCurrentKey(entityId.value)
    }
  } catch (error) {
    orgTree.value = []
    treeError.value = getUserFriendlyErrorMessage(error)
  }
}

async function loadJobTypes(): Promise<void> {
  try {
    const data = await fetchJobTypePage({ active: true, page: 1, size: 200 })
    jobTypes.value = data.records ?? []
  } catch {
    jobTypes.value = []
  }
}

async function loadList(): Promise<void> {
  if (!hasViewPermission.value) {
    records.value = []
    total.value = 0
    listError.value = '暂无权限查看员工（org:employee:view）'
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
        name: nameKeyword.value.trim() || undefined,
        mobile: mobileKeyword.value.trim() || undefined,
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

function handleNodeClick(data: OrganizationTreeNode): void {
  entityId.value = data.id
}

function handleOrgCommand(command: string): void {
  if (command === 'child') openCreateOrg(false)
  else if (command === 'edit') openEditOrg()
}

function allowDropOrg(
  draggingNode: { data: unknown },
  dropNode: { data: unknown },
  type: 'inner' | 'prev' | 'next',
): boolean {
  if (!hasOrgEditPermission.value) return false
  if (type !== 'inner') return false
  const dragging = draggingNode.data as OrganizationTreeNode
  const target = dropNode.data as OrganizationTreeNode
  if (target.id === dragging.id) return false
  if (target.store === true) return false
  const subtree = findNode(orgTree.value, dragging.id)
  return subtree == null || findNode(subtree.children ?? [], target.id) == null
}

async function handleOrgNodeDrop(
  draggingNode: { data: unknown },
  dropNode: { data: unknown },
  dropType: string,
): Promise<void> {
  if (dropType !== 'inner' || !hasOrgEditPermission.value) return
  const node = draggingNode.data as OrganizationTreeNode
  const target = dropNode.data as OrganizationTreeNode
  try {
    await updateOrganization(node.id, {
      parentId: target.id,
      name: nodeLabel(node),
      store: node.store === true,
      warehouse: node.warehouse === true,
      active: node.active !== false,
      provinceCode: node.provinceCode ?? null,
      cityCode: node.cityCode ?? null,
      areaCode: node.areaCode ?? null,
      addressDetail: node.addressDetail ?? null,
      longitude: node.longitude ?? null,
      latitude: node.latitude ?? null,
      remark: node.remark ?? null,
      priceAreaId: node.priceAreaId ?? null,
    })
    uiMessage.success(`已将「${nodeLabel(node)}」移动到「${nodeLabel(target)}」下`)
  } catch (error) {
    notifyError(error)
  }
  await loadOrgTree()
}

function handleSearch(): void {
  nameKeyword.value = nameInput.value.trim()
  mobileKeyword.value = mobileInput.value.trim()
  page.value = 1
  void loadList()
}

function handleReset(): void {
  nameInput.value = ''
  mobileInput.value = ''
  nameKeyword.value = ''
  mobileKeyword.value = ''
  jobId.value = null
  stateFilter.value = 'true'
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

function resetForm(): void {
  form.id = ''
  form.name = ''
  form.alias = ''
  form.phoneNumber = ''
  form.gender = '0'
  form.jobId = null
  form.idNumber = ''
  form.address = ''
  form.birthdate = ''
  form.entryDate = ''
  form.trialExpiryDate = ''
  form.contractStartDate = ''
  form.contractEndDate = ''
  form.socialSecurityPaymentDate = ''
  form.remark = ''
  form.state = true
  formEntities.value = []
}

function tagsFromSelection(): EntityTag[] {
  if (entityId.value == null) return []
  return [{
    entityId: entityId.value,
    entityName: selectedName.value,
    primary: true,
  }]
}

function openCreate(): void {
  if (entityId.value == null) {
    uiMessage.warning('请先选择组织')
    return
  }
  formMode.value = 'create'
  editingId.value = null
  resetForm()
  formEntities.value = tagsFromSelection()
  formError.value = null
  formVisible.value = true
}

async function openDetail(row: EmployeeRecord): Promise<void> {
  formMode.value = 'edit'
  editingId.value = row.id
  formError.value = null
  formVisible.value = true
  formLoading.value = true
  resetForm()
  try {
    const detail = await fetchEmployeeDetail(row.id)
    form.id = detail.id
    form.name = detail.name ?? ''
    form.alias = detail.alias ?? ''
    form.phoneNumber = detail.maskedMobile || detail.phoneNumber || ''
    if (hasMobilePermission.value) {
      try {
        form.phoneNumber = await fetchEmployeeFullMobile(row.id)
      } catch {
        // 无完整号码权限时保留脱敏号
      }
    }
    form.gender = genderCode(detail.gender)
    form.jobId = detail.jobId
    form.idNumber = detail.idNumber ?? ''
    form.address = detail.address ?? ''
    form.birthdate = detail.birthdate ?? ''
    form.entryDate = detail.entryDate ?? ''
    form.trialExpiryDate = detail.trialExpiryDate ?? ''
    form.contractStartDate = detail.contractStartDate ?? ''
    form.contractEndDate = detail.contractEndDate ?? ''
    form.socialSecurityPaymentDate = detail.socialSecurityPaymentDate ?? ''
    form.remark = detail.remark ?? ''
    form.state = detail.state !== false
    const entities = detail.entities ?? []
    if (entities.length === 0 && entityId.value != null) {
      formEntities.value = tagsFromSelection()
    } else {
      const hasPrimary = entities.some((item) => item.primaryEntity === true)
      formEntities.value = entities.map((item, index) => ({
        entityId: item.entityId,
        entityName: item.entityName?.trim() || entityNameOf(item.entityId),
        primary: hasPrimary ? item.primaryEntity === true : index === 0,
      }))
    }
  } catch (error) {
    notifyError(error)
    formVisible.value = false
  } finally {
    formLoading.value = false
  }
}

function setPrimary(entity: EntityTag): void {
  formEntities.value = formEntities.value.map((item) => ({
    ...item,
    primary: item.entityId === entity.entityId,
  }))
}

function removeEntity(entity: EntityTag): void {
  if (formEntities.value.length <= 1) {
    uiMessage.warning('至少保留一个所属单位')
    return
  }
  const next = formEntities.value.filter((item) => item.entityId !== entity.entityId)
  if (entity.primary && next.length > 0) next[0] = { ...next[0], primary: true }
  formEntities.value = next
}

async function openOrgPick(): Promise<void> {
  orgPickVisible.value = true
  await nextTick()
  orgPickTreeRef.value?.setCheckedKeys(formEntities.value.map((item) => item.entityId))
}

function confirmOrgPick(): void {
  const keys = (orgPickTreeRef.value?.getCheckedKeys(false) ?? []) as number[]
  if (keys.length === 0) {
    uiMessage.warning('请至少选择一个所属单位')
    return
  }
  const currentPrimary = formEntities.value.find((item) => item.primary)?.entityId
  const primary = currentPrimary != null && keys.includes(currentPrimary) ? currentPrimary : keys[0]
  formEntities.value = keys.map((id) => ({
    entityId: id,
    entityName: entityNameOf(id),
    primary: id === primary,
  }))
  orgPickVisible.value = false
}

async function handleSubmit(): Promise<void> {
  if (!hasEditPermission.value) return
  if (!form.name.trim()) {
    uiMessage.warning('请填写员工姓名')
    return
  }
  if (!form.phoneNumber.trim()) {
    uiMessage.warning('请填写手机号')
    return
  }
  if (form.jobId == null) {
    uiMessage.warning('请选择职务')
    return
  }
  if (!form.entryDate) {
    uiMessage.warning('请选择入职日期')
    return
  }
  const primary = formEntities.value.find((item) => item.primary) ?? formEntities.value[0]
  if (primary == null) {
    uiMessage.warning('请选择所属单位')
    return
  }
  await runExclusive(formSaving, async () => {
    formError.value = null
    const entityIds = formEntities.value.map((item) => item.entityId)
    const shared = {
      name: form.name.trim(),
      alias: form.alias.trim() || undefined,
      phoneNumber: form.phoneNumber.trim(),
      gender: form.gender,
      jobId: form.jobId!,
      entityId: primary.entityId,
      entityIds,
      idNumber: form.idNumber.trim() || undefined,
      address: form.address.trim() || undefined,
      birthdate: dateOrNull(form.birthdate),
      entryDate: dateOrNull(form.entryDate),
      trialExpiryDate: dateOrNull(form.trialExpiryDate),
      contractStartDate: dateOrNull(form.contractStartDate),
      contractEndDate: dateOrNull(form.contractEndDate),
      socialSecurityPaymentDate: dateOrNull(form.socialSecurityPaymentDate),
      remark: form.remark.trim() || undefined,
      state: form.state,
    }
    try {
      if (formMode.value === 'create') {
        const created = await createEmployee(shared)
        uiMessage.success(`员工已创建，编号 ${created.id}`)
        syncCurrentAccount(created.id, shared.name, shared.jobId)
      } else if (editingId.value) {
        await updateEmployee(editingId.value, shared)
        uiMessage.success('员工已更新')
        syncCurrentAccount(editingId.value, shared.name, shared.jobId)
      }
      formVisible.value = false
      await loadList()
    } catch (error) {
      formError.value = getUserFriendlyErrorMessage(error)
      notifyError(error)
    }
  })
}

function resetOrgForm(parentId: number | null): void {
  orgForm.parentId = parentId != null && parentId !== 0 ? parentId : null
  orgForm.name = ''
  orgForm.store = false
  orgForm.warehouse = false
  orgForm.active = true
  orgForm.region = []
  orgForm.addressDetail = ''
  orgForm.longitude = null
  orgForm.latitude = null
  orgForm.remark = ''
  orgForm.priceAreaId = null
}

function openCreateOrg(asRoot: boolean): void {
  if (!asRoot && entityId.value == null) {
    uiMessage.warning('请先选择上级组织')
    return
  }
  orgFormMode.value = 'create'
  orgTab.value = 'base'
  resetOrgForm(asRoot ? null : entityId.value)
  orgFormError.value = null
  orgFormVisible.value = true
  void loadPriceAreas()
}

function openEditOrg(): void {
  const node = selectedNode.value
  if (node == null) {
    uiMessage.warning('请先选择组织')
    return
  }
  orgFormMode.value = 'edit'
  orgTab.value = 'base'
  resetOrgForm(node.parentId)
  orgForm.name = node.entityName ?? ''
  orgForm.store = node.store === true
  orgForm.warehouse = node.warehouse === true
  orgForm.active = node.active !== false
  orgForm.region = regionCodesOf(node.provinceCode, node.cityCode, node.areaCode)
  orgForm.addressDetail = node.addressDetail ?? ''
  orgForm.longitude = node.longitude ?? null
  orgForm.latitude = node.latitude ?? null
  orgForm.remark = node.remark ?? ''
  orgForm.priceAreaId = node.priceAreaId ?? null
  orgFormError.value = null
  orgFormVisible.value = true
  void loadPriceAreas()
}

async function searchOrgMap(): Promise<void> {
  const query = `${regionText()}${orgForm.addressDetail.trim()}`
  if (!query) {
    uiMessage.warning('请先填写地址')
    return
  }
  mapSearching.value = true
  try {
    const response = await fetch(
      `https://nominatim.openstreetmap.org/search?format=jsonv2&limit=1&q=${encodeURIComponent(query)}`,
      { headers: { 'Accept-Language': 'zh-CN' } },
    )
    if (!response.ok) {
      uiMessage.warning('地图搜索失败，请直接填写经纬度')
      return
    }
    const rows = (await response.json()) as Array<{ lon?: string; lat?: string }>
    const hit = rows[0]
    if (hit?.lon == null || hit.lat == null) {
      uiMessage.warning('没有定位到该地址，请直接填写经纬度')
      return
    }
    orgForm.longitude = Number(hit.lon)
    orgForm.latitude = Number(hit.lat)
  } catch {
    uiMessage.warning('地图搜索失败，请直接填写经纬度')
  } finally {
    mapSearching.value = false
  }
}

function orgPayload() {
  const [provinceCode, cityCode, areaCode] = orgForm.region
  return {
    parentId: orgForm.parentId,
    name: orgForm.name.trim(),
    store: orgForm.store,
    warehouse: orgForm.warehouse,
    active: orgForm.active,
    provinceCode: provinceCode || null,
    cityCode: cityCode || null,
    areaCode: areaCode || null,
    addressDetail: orgForm.addressDetail.trim() || null,
    longitude: orgForm.longitude,
    latitude: orgForm.latitude,
    remark: orgForm.remark.trim() || null,
    priceAreaId: orgForm.priceAreaId,
  }
}

async function handleOrgSubmit(): Promise<void> {
  if (!hasOrgEditPermission.value) return
  if (!orgForm.name.trim()) {
    uiMessage.warning('请填写单位名称')
    orgTab.value = 'base'
    return
  }
  if (orgForm.region.length < 3) {
    uiMessage.warning('请选择省市区')
    orgTab.value = 'base'
    return
  }
  if (!orgForm.addressDetail.trim()) {
    uiMessage.warning('请填写详细地址')
    orgTab.value = 'base'
    return
  }
  await runExclusive(orgFormSaving, async () => {
    orgFormError.value = null
    try {
      const payload = orgPayload()
      if (orgFormMode.value === 'create') {
        await createOrganization(payload)
        uiMessage.success('组织已创建')
      } else if (entityId.value != null) {
        await updateOrganization(entityId.value, payload)
        uiMessage.success('组织已更新')
      }
      orgFormVisible.value = false
      await loadOrgTree()
    } catch (error) {
      orgFormError.value = getUserFriendlyErrorMessage(error)
      notifyError(error)
    }
  })
}

watch(treeKeyword, (value) => {
  treeRef.value?.filter(value.trim())
})

watch(entityId, () => {
  page.value = 1
  void loadList()
  if (entityId.value != null) {
    void nextTick(() => treeRef.value?.setCurrentKey(entityId.value!))
  }
})

watch(
  hasViewPermission,
  async (ok) => {
    if (!ok) {
      void loadList()
      return
    }
    await Promise.all([loadOrgTree(), loadJobTypes()])
    if (entityId.value == null) void loadList()
  },
  { immediate: true },
)
</script>

<template>
  <section class="directory-page">
    <aside class="tree-pane">
      <div class="tree-tools">
        <el-input v-model="treeKeyword" clearable placeholder="搜索部门名称" />
        <el-dropdown v-if="hasOrgEditPermission" trigger="click">
          <el-button :icon="Plus" circle />
          <template #dropdown>
            <el-dropdown-menu>
              <el-dropdown-item @click="openCreateOrg(false)">新增下级</el-dropdown-item>
              <el-dropdown-item @click="openCreateOrg(true)">新增顶级</el-dropdown-item>
              <el-dropdown-item :disabled="entityId == null" @click="openEditOrg">
                编辑当前组织
              </el-dropdown-item>
            </el-dropdown-menu>
          </template>
        </el-dropdown>
      </div>
      <div v-loading="false" class="tree-scroll">
        <AppError v-if="treeError" :description="treeError" @retry="loadOrgTree" />
        <el-tree
          v-else-if="orgTree.length"
          ref="treeRef"
          :data="orgTree"
          node-key="id"
          highlight-current
          default-expand-all
          :draggable="hasOrgEditPermission"
          :allow-drop="allowDropOrg"
          :expand-on-click-node="false"
          :filter-node-method="filterOrgNode"
          :props="{ label: 'entityName', children: 'children' }"
          @node-click="handleNodeClick"
          @node-drop="handleOrgNodeDrop"
        >
          <template #default="{ data }">
            <span class="tree-node">
              <span class="tree-label">{{ nodeLabel(data) }}</span>
              <span v-if="data.employeeCount > 0" class="tree-count">
                （{{ data.employeeCount }}人）
              </span>
              <el-tag v-if="data.store === true" size="small" type="success" effect="plain">门店</el-tag>
              <el-tag v-if="data.active === false" size="small" type="info" effect="plain">停用</el-tag>
            </span>
          </template>
        </el-tree>
        <AppEmpty v-else title="暂无组织" description="有组织维护权限时可在上方新增" />
      </div>
    </aside>

    <div class="list-pane">
      <div class="list-head">
        <div class="head-title">
          <h1>
            {{ selectedName }}
            <span v-if="entityId != null" class="head-count">（{{ total }}人）</span>
          </h1>
          <el-dropdown
            v-if="hasOrgEditPermission && selectedNode"
            trigger="click"
            @command="handleOrgCommand"
          >
            <span class="org-more" title="组织操作">
              <el-icon><ArrowDown /></el-icon>
            </span>
            <template #dropdown>
              <el-dropdown-menu>
                <el-dropdown-item command="child">添加子部门</el-dropdown-item>
                <el-dropdown-item command="edit">修改</el-dropdown-item>
              </el-dropdown-menu>
            </template>
          </el-dropdown>
        </div>
        <el-button
          v-if="hasEditPermission"
          type="primary"
          @click="openCreate"
        >
          新增
        </el-button>
      </div>

      <el-form :inline="true" class="filter-form" @submit.prevent="handleSearch">
        <el-form-item label="姓名">
          <el-input
            v-model="nameInput"
            clearable
            placeholder="请输入姓名"
            style="width: 160px"
          />
        </el-form-item>
        <el-form-item label="手机号">
          <el-input
            v-model="mobileInput"
            clearable
            placeholder="请输入手机号"
            style="width: 180px"
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
        <el-form-item>
          <el-button type="primary" native-type="submit" :loading="loading">
            查询
          </el-button>
          <el-button native-type="button" :disabled="loading" @click="handleReset">重置</el-button>
        </el-form-item>
      </el-form>

      <div v-loading="loading" class="table-wrap">
        <AppError v-if="listError && !loading" :description="listError" @retry="loadList" />
        <template v-else>
          <el-alert
            v-if="entityId == null"
            type="info"
            :closable="false"
            show-icon
            title="请先在左侧选择组织"
            style="margin-bottom: 12px"
          />
          <el-table :data="records" stripe size="small" empty-text="暂无员工">
            <el-table-column prop="id" label="员工编号" width="120" show-overflow-tooltip />
            <el-table-column prop="name" label="员工姓名" min-width="100" show-overflow-tooltip />
            <el-table-column label="员工手机号" width="140" show-overflow-tooltip>
              <template #default="{ row }">
                {{ displayMobile(rowOf(row)) }}
              </template>
            </el-table-column>
            <el-table-column label="所属单位" min-width="220" show-overflow-tooltip>
              <template #default="{ row }">
                {{ unitText(rowOf(row)) }}
              </template>
            </el-table-column>
            <el-table-column prop="jobName" label="职务" min-width="110" show-overflow-tooltip>
              <template #default="{ row }">
                {{ rowOf(row).jobName || '—' }}
              </template>
            </el-table-column>
            <el-table-column label="在职状态" width="100">
              <template #default="{ row }">
                <span :class="['state-text', rowOf(row).state !== false ? 'is-active' : 'is-inactive']">
                  {{ rowOf(row).state !== false ? '在职' : '离职' }}
                </span>
              </template>
            </el-table-column>
            <el-table-column label="操作" width="100" fixed="right">
              <template #default="{ row }">
                <el-button type="primary" size="small" @click="openDetail(rowOf(row))">
                  查看
                </el-button>
              </template>
            </el-table-column>
          </el-table>
          <div v-if="total > 0" class="pager">
            <el-pagination
              background
              layout="total, prev, pager, next, jumper"
              :total="total"
              :current-page="page"
              :page-size="size"
              @current-change="handlePageChange"
              @size-change="handleSizeChange"
            />
          </div>
        </template>
      </div>
    </div>

    <el-dialog
      v-model="formVisible"
      :title="formMode === 'create' ? '新增员工' : '员工详情'"
      width="980px"
      destroy-on-close
      :close-on-click-modal="false"
      class="employee-dialog"
    >
      <div v-loading="formLoading">
        <AppError v-if="formError" :description="formError" />
        <el-form label-width="108px" :disabled="!hasEditPermission" @submit.prevent>
          <div class="form-section">基础档案</div>
          <div class="form-grid">
            <el-form-item label="员工编号">
              <el-input
                v-model="form.id"
                disabled
                maxlength="50"
                :placeholder="formMode === 'create' ? '系统自动生成' : ''"
              />
            </el-form-item>
            <el-form-item label="员工姓名" required>
              <el-input v-model="form.name" maxlength="20" placeholder="请输入员工姓名" />
            </el-form-item>
            <el-form-item label="员工花名">
              <el-input v-model="form.alias" maxlength="50" placeholder="请输入员工花名" />
            </el-form-item>
            <el-form-item label="手机号" required>
              <el-input
                v-model="form.phoneNumber"
                maxlength="20"
                placeholder="请输入手机号"
                :readonly="formMode === 'edit' && !hasMobilePermission"
              />
            </el-form-item>
            <el-form-item label="性别" required>
              <el-radio-group v-model="form.gender">
                <el-radio value="2">女</el-radio>
                <el-radio value="1">男</el-radio>
                <el-radio value="0">未知</el-radio>
              </el-radio-group>
            </el-form-item>
            <el-form-item label="出生日期">
              <el-date-picker
                v-model="form.birthdate"
                type="date"
                value-format="YYYY-MM-DD"
                placeholder="选择日期"
                style="width: 100%"
              />
            </el-form-item>
            <el-form-item label="证件号码">
              <el-input v-model="form.idNumber" maxlength="50" placeholder="请输入证件号码" />
            </el-form-item>
            <el-form-item label="地址" class="span-2">
              <el-input v-model="form.address" maxlength="100" placeholder="请输入地址信息" />
            </el-form-item>
          </div>

          <div class="form-section">聘用信息</div>
          <div class="form-grid">
            <el-form-item label="职务" required>
              <el-select v-model="form.jobId" filterable placeholder="请选择职务" style="width: 100%">
                <el-option v-for="job in jobTypes" :key="job.id" :label="job.name" :value="job.id" />
              </el-select>
            </el-form-item>
            <el-form-item label="入职日期" required>
              <el-date-picker
                v-model="form.entryDate"
                type="date"
                value-format="YYYY-MM-DD"
                placeholder="选择日期"
                style="width: 100%"
              />
            </el-form-item>
            <el-form-item label="试用期到期日">
              <el-date-picker
                v-model="form.trialExpiryDate"
                type="date"
                value-format="YYYY-MM-DD"
                placeholder="选择日期"
                style="width: 100%"
              />
            </el-form-item>
            <el-form-item label="在职状态" required>
              <el-radio-group v-model="form.state">
                <el-radio :value="true">在职</el-radio>
                <el-radio :value="false">离职</el-radio>
              </el-radio-group>
            </el-form-item>
            <el-form-item label="合同日期" class="span-2">
              <div class="date-range">
                <el-date-picker
                  v-model="form.contractStartDate"
                  type="date"
                  value-format="YYYY-MM-DD"
                  placeholder="开始日期"
                />
                <span>至</span>
                <el-date-picker
                  v-model="form.contractEndDate"
                  type="date"
                  value-format="YYYY-MM-DD"
                  placeholder="结束日期"
                />
              </div>
            </el-form-item>
            <el-form-item label="社保缴纳日期">
              <el-date-picker
                v-model="form.socialSecurityPaymentDate"
                type="date"
                value-format="YYYY-MM-DD"
                placeholder="选择日期"
                style="width: 100%"
              />
            </el-form-item>
            <el-form-item label="所属单位" required class="span-3">
              <div class="entity-tags">
                <el-tag
                  v-for="item in formEntities"
                  :key="item.entityId"
                  :closable="formEntities.length > 1"
                  :type="item.primary ? 'primary' : 'info'"
                  effect="plain"
                  class="entity-tag"
                  @click="setPrimary(item)"
                  @close="removeEntity(item)"
                >
                  {{ item.entityName }}<template v-if="item.primary">[主]</template>
                </el-tag>
                <el-button link type="primary" @click="openOrgPick">
                  修改
                </el-button>
              </div>
              <p class="field-hint">点击标签把该单位设为主组织</p>
            </el-form-item>
            <el-form-item label="备注" class="span-3">
              <el-input
                v-model="form.remark"
                type="textarea"
                :rows="4"
                maxlength="200"
                placeholder="请填写备注"
              />
            </el-form-item>
          </div>
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

    <el-dialog
      v-model="orgPickVisible"
      title="选择所属单位"
      width="420px"
      append-to-body
      :close-on-click-modal="false"
    >
      <el-tree
        ref="orgPickTreeRef"
        class="pick-tree"
        :data="orgTree"
        node-key="id"
        show-checkbox
        check-strictly
        default-expand-all
        :props="{ label: 'entityName', children: 'children' }"
      />
      <template #footer>
        <el-button @click="orgPickVisible = false">取消</el-button>
        <el-button type="primary" @click="confirmOrgPick">确定</el-button>
      </template>
    </el-dialog>

    <el-dialog
      v-model="orgFormVisible"
      :title="orgFormMode === 'create' ? '新增组织' : '编辑组织'"
      width="860px"
      append-to-body
      destroy-on-close
      :close-on-click-modal="false"
    >
      <AppError v-if="orgFormError" :description="orgFormError" />
      <el-tabs v-model="orgTab">
        <el-tab-pane label="基础信息" name="base">
          <el-form label-width="108px" @submit.prevent>
            <el-form-item label="上级单位" required>
              <el-tree-select
                v-model="orgForm.parentId"
                :data="parentTree"
                check-strictly
                filterable
                clearable
                node-key="id"
                :props="{ label: 'entityName', children: 'children', disabled: 'disabled' }"
                placeholder="不选则为顶级单位"
                style="width: 320px"
              />
            </el-form-item>
            <el-form-item label="单位名称" required>
              <el-input v-model="orgForm.name" maxlength="50" placeholder="单位名称" style="width: 320px" />
            </el-form-item>
            <el-form-item label="是否门店" required>
              <el-radio-group v-model="orgForm.store">
                <el-radio :value="true">是</el-radio>
                <el-radio :value="false">否</el-radio>
              </el-radio-group>
              <span class="field-aside">当前单位可为部门、区域、市场等</span>
            </el-form-item>
            <el-form-item label="是否仓库" required>
              <el-radio-group v-model="orgForm.warehouse">
                <el-radio :value="true">是</el-radio>
                <el-radio :value="false">否</el-radio>
              </el-radio-group>
              <span class="field-aside">当前单位既是仓库也是单位（门店或非门店）</span>
            </el-form-item>
            <el-form-item label="是否有效" required>
              <el-radio-group v-model="orgForm.active">
                <el-radio :value="true">是</el-radio>
                <el-radio :value="false">否</el-radio>
              </el-radio-group>
            </el-form-item>
            <el-form-item label="地址" required>
              <el-cascader
                v-model="orgForm.region"
                :options="regionData as unknown as CascaderOption[]"
                clearable
                filterable
                placeholder="省 / 市 / 区"
                style="width: 320px"
              />
            </el-form-item>
            <el-form-item label="详细地址" required>
              <div class="address-line">
                <el-input v-model="orgForm.addressDetail" maxlength="200" placeholder="详细地址" />
                <el-button :loading="mapSearching" @click="searchOrgMap">搜索地图</el-button>
              </div>
            </el-form-item>
            <el-form-item label="地图定位">
              <div class="map-box">
                <iframe v-if="mapEmbedUrl" class="map-frame" :src="mapEmbedUrl" title="地图定位" />
                <div v-else class="map-empty">填写地址后点「搜索地图」，或直接填写经纬度</div>
                <div class="coord-row">
                  <el-input-number
                    v-model="orgForm.longitude"
                    :precision="6"
                    :step="0.000001"
                    :controls="false"
                    placeholder="经度"
                  />
                  <el-input-number
                    v-model="orgForm.latitude"
                    :precision="6"
                    :step="0.000001"
                    :controls="false"
                    placeholder="纬度"
                  />
                </div>
              </div>
            </el-form-item>
            <el-form-item label="备注">
              <el-input
                v-model="orgForm.remark"
                type="textarea"
                :rows="3"
                maxlength="200"
                placeholder="请填写备注"
              />
            </el-form-item>
          </el-form>
        </el-tab-pane>
        <el-tab-pane label="门店信息" name="store">
          <el-form label-width="108px" @submit.prevent>
            <el-form-item label="价格区域">
              <el-select
                v-model="orgForm.priceAreaId"
                clearable
                filterable
                placeholder="可选，用于门店渠道价格"
                style="width: 320px"
              >
                <el-option
                  v-for="area in priceAreas"
                  :key="area.id"
                  :label="area.name || `区域#${area.id}`"
                  :value="area.id"
                />
              </el-select>
              <p class="field-hint">门店渠道价格使用的价格区域。不选则保持原来的区域。</p>
            </el-form-item>
          </el-form>
        </el-tab-pane>
      </el-tabs>
      <template #footer>
        <el-button :disabled="orgFormSaving" @click="orgFormVisible = false">取消</el-button>
        <el-button
          type="primary"
          :loading="orgFormSaving"
          :disabled="!hasOrgEditPermission"
          @click="handleOrgSubmit"
        >
          保存
        </el-button>
      </template>
    </el-dialog>
  </section>
</template>

<style scoped>
.directory-page {
  display: flex;
  height: 100%;
  min-height: 560px;
  background: #fff;
}

.tree-pane {
  display: flex;
  flex-direction: column;
  width: 280px;
  flex-shrink: 0;
  border-right: 1px solid #ebeef5;
}

.tree-tools {
  display: flex;
  gap: 8px;
  align-items: center;
  padding: 12px;
  border-bottom: 1px solid #f2f3f5;
}

.tree-scroll {
  flex: 1;
  min-height: 0;
  overflow: auto;
  padding: 8px 8px 16px;
}

.tree-node {
  display: inline-flex;
  align-items: center;
  gap: 6px;
  min-width: 0;
  padding-right: 8px;
}

.tree-label {
  overflow: hidden;
  text-overflow: ellipsis;
}

.list-pane {
  flex: 1;
  min-width: 0;
  display: flex;
  flex-direction: column;
  padding: 16px 20px 20px;
}

.list-head {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 12px;
  margin-bottom: 12px;
}

.head-title {
  display: flex;
  align-items: center;
  gap: 2px;
  min-width: 0;
}

.org-more {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  width: 20px;
  height: 20px;
  color: #909399;
  cursor: pointer;
  border-radius: 4px;
}

.org-more:hover {
  color: #ff7a00;
  background: #fff3e8;
}

.list-head h1 {
  margin: 0;
  font-size: 18px;
  font-weight: 600;
  color: #303133;
}

.head-count {
  font-weight: 500;
  color: #606266;
}

.filter-form {
  margin-bottom: 8px;
}

.table-wrap {
  flex: 1;
  min-height: 240px;
}

.pager {
  display: flex;
  justify-content: flex-end;
  margin-top: 12px;
}

.form-section {
  display: flex;
  align-items: center;
  gap: 8px;
  margin: 4px 0 14px;
  font-size: 15px;
  font-weight: 600;
  color: #303133;
}

.form-section::before {
  content: '';
  width: 3px;
  height: 14px;
  border-radius: 2px;
  background: var(--el-color-primary);
}

.form-grid {
  display: grid;
  grid-template-columns: repeat(3, minmax(0, 1fr));
  column-gap: 18px;
}

.span-2 {
  grid-column: span 2;
}

.span-3 {
  grid-column: span 3;
}

.date-range,
.entity-tags {
  display: flex;
  align-items: center;
  gap: 8px;
  width: 100%;
  flex-wrap: wrap;
}

.entity-tag {
  cursor: pointer;
}

.field-hint {
  margin: 4px 0 0;
  font-size: 12px;
  line-height: 1.4;
  color: #909399;
}

.pick-tree {
  max-height: 420px;
  overflow: auto;
}

.field-aside {
  margin-left: 12px;
  color: #909399;
  font-size: 13px;
}

.address-line,
.coord-row {
  display: flex;
  gap: 8px;
  width: 100%;
}

.address-line .el-input {
  flex: 1;
}

.map-box {
  width: 100%;
}

.map-frame,
.map-empty {
  width: 100%;
  height: 220px;
  border: 1px solid #ebeef5;
  border-radius: 4px;
  background: #f5f7fa;
}

.map-empty {
  display: flex;
  align-items: center;
  justify-content: center;
  color: #909399;
}

.coord-row {
  margin-top: 8px;
}

@media (max-width: 900px) {
  .directory-page {
    flex-direction: column;
    height: auto;
  }

  .tree-pane {
    width: 100%;
    max-height: 320px;
    border-right: 0;
    border-bottom: 1px solid #ebeef5;
  }
}

.tree-count {
  font-size: 12px;
  color: #909399;
  white-space: nowrap;
}

.state-text {
  font-size: 12px;
}

.state-text.is-active {
  color: #52c41a;
}

.state-text.is-inactive {
  color: #909399;
}

.directory-page :deep(.el-button--primary:not(.is-link):not(.is-text)) {
  --el-button-bg-color: #ff7a00;
  --el-button-border-color: #ff7a00;
  --el-button-hover-bg-color: #ff9333;
  --el-button-hover-border-color: #ff9333;
  --el-button-active-bg-color: #e56b00;
  --el-button-active-border-color: #e56b00;
}

.directory-page :deep(.el-pagination.is-background .el-pager li.is-active) {
  background-color: #ff7a00;
}

.directory-page :deep(.el-table th.el-table__cell) {
  background: #f5f7fa;
  color: #303133;
  font-weight: 600;
}
</style>
