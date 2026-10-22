<script setup lang="ts">
import { computed, nextTick, onMounted, onUnmounted, reactive, ref } from 'vue'

import AppEmpty from '@/components/common/AppEmpty.vue'
import AppError from '@/components/common/AppError.vue'
import {
  exportCustomers,
  fetchCustomerLevelOptions,
  fetchCustomerPage,
  fetchCustomerSourceOptions,
  fetchCustomerSourcePage,
  fetchServicerOptions,
} from '@/api/customer'
import {
  CustomerPermission,
  type CustomerLevelItem,
  type CustomerListItem,
  type CustomerListQuery,
  type CustomerSourceOption,
} from '@/types/customer'
import { STORE_CONTEXT_CHANGED_EVENT } from '@/stores/store'
import { usePermissionStore } from '@/stores/permission'
import { getUserFriendlyErrorMessage, notifyError, runExclusive, uiMessage } from '@/utils/ui'
import CustomerCreateDialog from '@/views/customer/CustomerCreateDialog.vue'
import CustomerDetailDrawer from '@/views/customer/CustomerDetailDrawer.vue'
import CustomerEditDialog from '@/views/customer/CustomerEditDialog.vue'
import {
  formatCustomerPickerLabel,
  formatDate,
  formatDateTime,
  formatGender,
  pickCaregiverEmployees,
  pickMainNurseEmployees,
} from '@/views/customer/customer-format'

defineOptions({ name: 'CustomerListView' })

/** 表头可排序列，对齐后端 sortBy 白名单 */
const TABLE_SORTABLE_PROPS = new Set(['createdOn', 'lastTreatTime', 'memberOn'])

const permissionStore = usePermissionStore()

const createVisible = ref(false)
const detailVisible = ref(false)
const editVisible = ref(false)
const activeCustomerId = ref<number | null>(null)
const detailDrawerRef = ref<{ reload: () => Promise<void> } | null>(null)

const loading = ref(false)
const exportLoading = ref(false)
const loadError = ref<string | null>(null)
const exportError = ref<string | null>(null)
const list = ref<CustomerListItem[]>([])
const total = ref(0)
const page = ref(1)
const pageSize = ref(20)
const moreFiltersOpen = ref(false)

const queryForm = reactive({
  keyword: '',
  sourceId: undefined as number | undefined,
  levelId: undefined as number | undefined,
  nurseEmployeeId: '' as string,
  caregiverEmployeeId: '' as string,
  introducerCustomerId: undefined as number | undefined,
  memberOnRange: null as [string, string] | null,
  birthdayRange: null as [string, string] | null,
  createdOnRange: null as [string, string] | null,
  sortBy: 'createdOn' as string,
  sortOrder: 'desc' as string,
})

const sourceOptions = ref<CustomerSourceOption[]>([])
const levelOptions = ref<CustomerLevelItem[]>([])
const nurseOptions = ref<{ id: string; name: string }[]>([])
const caregiverOptions = ref<{ id: string; name: string }[]>([])
const introducerOptions = ref<CustomerListItem[]>([])
const introducerSearching = ref(false)
let introducerSearchTimer: ReturnType<typeof setTimeout> | null = null
let introducerSearchSeq = 0

const hasListPermission = computed(() => permissionStore.hasPermission(CustomerPermission.LIST_VIEW))

const hasActiveFilters = computed(() => {
  return (
    !!queryForm.keyword.trim() ||
    queryForm.sourceId != null ||
    queryForm.levelId != null ||
    !!queryForm.nurseEmployeeId ||
    !!queryForm.caregiverEmployeeId ||
    queryForm.introducerCustomerId != null ||
    queryForm.memberOnRange != null ||
    queryForm.birthdayRange != null ||
    queryForm.createdOnRange != null
  )
})

const hasActiveMoreFilters = computed(() => {
  return (
    queryForm.sourceId != null ||
    queryForm.levelId != null ||
    !!queryForm.caregiverEmployeeId ||
    queryForm.introducerCustomerId != null ||
    queryForm.memberOnRange != null ||
    queryForm.birthdayRange != null ||
    queryForm.createdOnRange != null
  )
})

const emptyTitle = computed(() =>
  hasActiveFilters.value ? '暂无符合条件的客户' : '暂无客户',
)

const tableDefaultSort = computed(() => ({
  prop: queryForm.sortBy,
  order: (queryForm.sortOrder === 'asc' ? 'ascending' : 'descending') as 'ascending' | 'descending',
}))

function buildListQuery(includePage: boolean): CustomerListQuery {
  const query: CustomerListQuery = {
    keyword: queryForm.keyword.trim() || undefined,
    sourceId: queryForm.sourceId,
    levelId: queryForm.levelId,
    nurseEmployeeId: queryForm.nurseEmployeeId || undefined,
    caregiverEmployeeId: queryForm.caregiverEmployeeId || undefined,
    introducerCustomerId: queryForm.introducerCustomerId,
    memberOnFrom: queryForm.memberOnRange?.[0] || undefined,
    memberOnTo: queryForm.memberOnRange?.[1] || undefined,
    birthdayFrom: queryForm.birthdayRange?.[0] || undefined,
    birthdayTo: queryForm.birthdayRange?.[1] || undefined,
    createdOnFrom: queryForm.createdOnRange?.[0] || undefined,
    createdOnTo: queryForm.createdOnRange?.[1] || undefined,
    sortBy: queryForm.sortBy || undefined,
    sortOrder: queryForm.sortOrder || undefined,
  }
  if (includePage) {
    query.page = page.value
    query.size = pageSize.value
  }
  return query
}

async function loadFilterOptions(): Promise<void> {
  if (hasListPermission.value) {
    try {
      levelOptions.value = await fetchCustomerLevelOptions()
    } catch {
      levelOptions.value = []
    }
  } else {
    levelOptions.value = []
  }
  if (permissionStore.hasPermission(CustomerPermission.CREATE)) {
    try {
      const sources = await fetchCustomerSourceOptions()
      sourceOptions.value = sources.filter((item) => item.active !== false)
    } catch {
      sourceOptions.value = []
    }
    try {
      const roles = await fetchServicerOptions()
      nurseOptions.value = pickMainNurseEmployees(roles).map((emp) => ({
        id: emp.id,
        name: emp.name?.trim() || emp.id,
      }))
      caregiverOptions.value = pickCaregiverEmployees(roles).map((emp) => ({
        id: emp.id,
        name: emp.name?.trim() || emp.id,
      }))
    } catch {
      nurseOptions.value = []
      caregiverOptions.value = []
    }
    return
  }
  nurseOptions.value = []
  caregiverOptions.value = []
  if (permissionStore.hasPermission(CustomerPermission.SOURCE_VIEW)) {
    try {
      const pageData = await fetchCustomerSourcePage({ page: 1, size: 100, active: true })
      sourceOptions.value = pageData.records ?? []
    } catch {
      sourceOptions.value = []
    }
  }
}

async function loadCustomers(): Promise<void> {
  if (!hasListPermission.value) {
    loadError.value = '暂无权限查看客户列表'
    list.value = []
    total.value = 0
    return
  }
  await runExclusive(loading, async () => {
    loadError.value = null
    try {
      const data = await fetchCustomerPage(buildListQuery(true))
      list.value = data.records ?? []
      total.value = data.total ?? 0
      page.value = data.page || page.value
      pageSize.value = data.size || pageSize.value
    } catch (error) {
      list.value = []
      total.value = 0
      loadError.value = getUserFriendlyErrorMessage(error)
      notifyError(error)
    }
  })
}

async function handleSearch(): Promise<void> {
  page.value = 1
  await loadCustomers()
}

async function handleReset(): Promise<void> {
  queryForm.keyword = ''
  queryForm.sourceId = undefined
  queryForm.levelId = undefined
  queryForm.nurseEmployeeId = ''
  queryForm.caregiverEmployeeId = ''
  queryForm.introducerCustomerId = undefined
  queryForm.memberOnRange = null
  queryForm.birthdayRange = null
  queryForm.createdOnRange = null
  queryForm.sortBy = 'createdOn'
  queryForm.sortOrder = 'desc'
  introducerOptions.value = []
  page.value = 1
  await loadCustomers()
}

function searchIntroducers(keyword: string): void {
  if (introducerSearchTimer != null) {
    clearTimeout(introducerSearchTimer)
  }
  const trimmed = keyword.trim()
  if (trimmed === '') {
    introducerSearching.value = false
    return
  }
  introducerSearchTimer = setTimeout(() => {
    void runIntroducerSearch(trimmed)
  }, 300)
}

async function runIntroducerSearch(keyword: string): Promise<void> {
  const seq = ++introducerSearchSeq
  introducerSearching.value = true
  try {
    const data = await fetchCustomerPage({
      keyword,
      page: 1,
      size: 20,
    })
    if (seq !== introducerSearchSeq) {
      return
    }
    const records = data.records ?? []
    const selectedId = queryForm.introducerCustomerId
    const selected = selectedId == null
      ? null
      : introducerOptions.value.find((item) => item.id === selectedId) ?? null
    if (selected != null && !records.some((item) => item.id === selected.id)) {
      introducerOptions.value = [selected, ...records]
    } else {
      introducerOptions.value = records
    }
  } catch (error) {
    if (seq !== introducerSearchSeq) {
      return
    }
    introducerOptions.value = introducerOptions.value.filter(
      (item) => item.id === queryForm.introducerCustomerId,
    )
    notifyError(error)
  } finally {
    if (seq === introducerSearchSeq) {
      introducerSearching.value = false
    }
  }
}

function handleIntroducerClear(): void {
  queryForm.introducerCustomerId = undefined
}

async function handleSortChange(payload: {
  prop: string | null
  order: 'ascending' | 'descending' | null
}): Promise<void> {
  const prop = payload.prop ?? ''
  if (!TABLE_SORTABLE_PROPS.has(prop) || payload.order == null) {
    queryForm.sortBy = 'createdOn'
    queryForm.sortOrder = 'desc'
  } else {
    queryForm.sortBy = prop
    queryForm.sortOrder = payload.order === 'ascending' ? 'asc' : 'desc'
  }
  page.value = 1
  await loadCustomers()
}

function toggleMoreFilters(): void {
  moreFiltersOpen.value = !moreFiltersOpen.value
}

async function handlePageChange(nextPage: number): Promise<void> {
  page.value = nextPage
  await loadCustomers()
}

async function handleSizeChange(size: number): Promise<void> {
  pageSize.value = size
  page.value = 1
  await loadCustomers()
}

/**
 * 触发本地下载。须在 exportLoading 已关闭后调用：
 * Windows「另存为」会阻塞 click，若仍处在 loading 中，取消保存后按钮会一直转圈。
 */
function triggerBlobDownload(blob: Blob, fileName: string): void {
  const url = URL.createObjectURL(blob)
  const anchor = document.createElement('a')
  anchor.href = url
  anchor.download = fileName
  anchor.rel = 'noopener'
  anchor.style.display = 'none'
  document.body.appendChild(anchor)
  anchor.click()
  // 延迟释放，避免另存为对话框未结束就 revoke 导致异常挂起
  window.setTimeout(() => {
    URL.revokeObjectURL(url)
    anchor.remove()
  }, 60_000)
}

async function handleExport(): Promise<void> {
  if (!hasListPermission.value) {
    exportError.value = '暂无权限导出客户列表'
    return
  }
  if (exportLoading.value) {
    return
  }
  exportLoading.value = true
  exportError.value = null
  try {
    const { blob, fileName } = await exportCustomers(buildListQuery(false))
    // 先结束 loading 并让出主线程，再触发另存为（另存为会阻塞 click，取消时否则一直转圈）
    exportLoading.value = false
    await nextTick()
    window.setTimeout(() => {
      triggerBlobDownload(blob, fileName)
      uiMessage.success('导出成功')
    }, 0)
  } catch (error) {
    exportError.value = getUserFriendlyErrorMessage(error)
    notifyError(error)
  } finally {
    exportLoading.value = false
  }
}

/** 另存为取消后偶发 loading 未复位；获焦时兜底清掉导出转圈 */
function onWindowFocus(): void {
  if (exportLoading.value) {
    exportLoading.value = false
  }
}

function openCreate(): void {
  createVisible.value = true
}

function openDetail(row: CustomerListItem): void {
  activeCustomerId.value = row.id
  detailVisible.value = true
}

function openEdit(row: CustomerListItem): void {
  activeCustomerId.value = row.id
  editVisible.value = true
}

function openEditFromDetail(customerId: number): void {
  activeCustomerId.value = customerId
  editVisible.value = true
}

async function onDialogSuccess(): Promise<void> {
  await loadCustomers()
  if (detailVisible.value) {
    await detailDrawerRef.value?.reload()
  }
}

function rowOf(row: unknown): CustomerListItem {
  return row as CustomerListItem
}

function onStoreChanged(): void {
  detailVisible.value = false
  editVisible.value = false
  createVisible.value = false
  page.value = 1
  void loadCustomers()
}

onMounted(() => {
  exportLoading.value = false
  window.addEventListener(STORE_CONTEXT_CHANGED_EVENT, onStoreChanged)
  window.addEventListener('focus', onWindowFocus)
  void (async () => {
    await loadFilterOptions()
    await loadCustomers()
  })()
})

onUnmounted(() => {
  window.removeEventListener(STORE_CONTEXT_CHANGED_EVENT, onStoreChanged)
  window.removeEventListener('focus', onWindowFocus)
  if (introducerSearchTimer != null) {
    clearTimeout(introducerSearchTimer)
    introducerSearchTimer = null
  }
})
</script>

<template>
  <div class="customer-list-page">

    <section class="query-panel">
      <div class="query-toolbar">
        <el-form :inline="true" class="query-form" @submit.prevent>
          <el-form-item label="客户信息">
            <el-input
              v-model="queryForm.keyword"
              clearable
              placeholder="姓名 / 编号 / 手机号"
              style="width: 200px"
              @keyup.enter="handleSearch"
            />
          </el-form-item>
          <el-form-item v-if="nurseOptions.length > 0" label="主护理师">
            <el-select
              v-model="queryForm.nurseEmployeeId"
              clearable
              filterable
              placeholder="全部"
              style="width: 160px"
            >
              <el-option
                v-for="item in nurseOptions"
                :key="item.id"
                :label="item.name"
                :value="item.id"
              />
            </el-select>
          </el-form-item>
          <el-form-item>
            <el-button native-type="button" type="primary" :loading="loading" @click="handleSearch">
              查询
            </el-button>
            <el-button native-type="button" :disabled="loading" @click="handleReset">重置</el-button>
            <el-button
              v-permission="CustomerPermission.LIST_VIEW"
              native-type="button"
              :loading="exportLoading"
              :disabled="exportLoading"
              @click="handleExport"
            >
              导出
            </el-button>
            <el-button native-type="button" link type="primary" @click="toggleMoreFilters">
              {{ moreFiltersOpen ? '收起筛选' : '更多筛选' }}
              <span v-if="!moreFiltersOpen && hasActiveMoreFilters" class="more-dot" />
            </el-button>
          </el-form-item>
        </el-form>
        <el-button
          v-permission="CustomerPermission.CREATE"
          class="create-btn"
          type="primary"
          native-type="button"
          @click="openCreate"
        >
          新增客户
        </el-button>
      </div>

      <el-form
        v-show="moreFiltersOpen"
        :inline="true"
        class="query-form more-filters"
        @submit.prevent
      >
        <el-form-item v-if="sourceOptions.length > 0" label="首次来源">
          <el-select
            v-model="queryForm.sourceId"
            clearable
            filterable
            placeholder="全部"
            style="width: 160px"
          >
            <el-option
              v-for="item in sourceOptions"
              :key="item.id"
              :label="item.name"
              :value="item.id"
            />
          </el-select>
        </el-form-item>
        <el-form-item v-if="levelOptions.length > 0" label="会员等级">
          <el-select
            v-model="queryForm.levelId"
            clearable
            filterable
            placeholder="全部"
            style="width: 160px"
          >
            <el-option
              v-for="item in levelOptions"
              :key="item.id"
              :label="item.name"
              :value="item.id"
            />
          </el-select>
        </el-form-item>
        <el-form-item v-if="caregiverOptions.length > 0" label="护理师">
          <el-select
            v-model="queryForm.caregiverEmployeeId"
            clearable
            filterable
            placeholder="全部"
            style="width: 160px"
          >
            <el-option
              v-for="item in caregiverOptions"
              :key="item.id"
              :label="item.name"
              :value="item.id"
            />
          </el-select>
        </el-form-item>
        <el-form-item label="介绍人">
          <el-select
            v-model="queryForm.introducerCustomerId"
            filterable
            remote
            clearable
            reserve-keyword
            :remote-method="searchIntroducers"
            :loading="introducerSearching"
            placeholder="姓名/编号/手机号"
            style="width: 220px"
            @clear="handleIntroducerClear"
          >
            <el-option
              v-for="item in introducerOptions"
              :key="item.id"
              :label="formatCustomerPickerLabel(item)"
              :value="item.id"
            />
          </el-select>
        </el-form-item>
        <el-form-item label="成为会员">
          <el-date-picker
            v-model="queryForm.memberOnRange"
            type="daterange"
            value-format="YYYY-MM-DD"
            start-placeholder="开始日期"
            end-placeholder="结束日期"
            clearable
            style="width: 240px"
          />
        </el-form-item>
        <el-form-item label="生日">
          <el-date-picker
            v-model="queryForm.birthdayRange"
            type="daterange"
            value-format="YYYY-MM-DD"
            start-placeholder="开始日期"
            end-placeholder="结束日期"
            clearable
            style="width: 240px"
          />
        </el-form-item>
        <el-form-item label="注册日期">
          <el-date-picker
            v-model="queryForm.createdOnRange"
            type="daterange"
            value-format="YYYY-MM-DD"
            start-placeholder="开始日期"
            end-placeholder="结束日期"
            clearable
            style="width: 240px"
          />
        </el-form-item>
      </el-form>
    </section>

    <AppError
      v-if="exportError && !exportLoading"
      class="export-error"
      title="导出失败"
      :description="exportError"
      @retry="handleExport"
    />

    <section class="table-panel">
      <AppError
        v-if="loadError && !loading"
        :description="loadError"
        @retry="loadCustomers"
      />
      <template v-else>
        <el-table
          v-loading="loading"
          :data="list"
          border
          stripe
          empty-text=" "
          :default-sort="tableDefaultSort"
          @sort-change="handleSortChange"
        >
          <el-table-column prop="name" label="客户姓名" min-width="110" show-overflow-tooltip />
          <el-table-column prop="code" label="客户编号" min-width="110" show-overflow-tooltip />
          <el-table-column prop="mobile" label="手机号" min-width="120" />
          <el-table-column label="性别" width="70" align="center">
            <template #default="{ row }">
              {{ formatGender(rowOf(row).gender, rowOf(row).genderName) }}
            </template>
          </el-table-column>
          <el-table-column label="生日" min-width="110">
            <template #default="{ row }">
              {{ formatDate(rowOf(row).birthday) }}
            </template>
          </el-table-column>
          <el-table-column prop="levelName" label="会员等级" min-width="100" show-overflow-tooltip>
            <template #default="{ row }">
              {{ row.levelName || '—' }}
            </template>
          </el-table-column>
          <el-table-column prop="sourceName" label="首次来源" min-width="100" show-overflow-tooltip>
            <template #default="{ row }">
              {{ row.sourceName || '—' }}
            </template>
          </el-table-column>
          <el-table-column prop="introducerName" label="介绍人" min-width="100" show-overflow-tooltip>
            <template #default="{ row }">
              {{ row.introducerName || '—' }}
            </template>
          </el-table-column>
          <el-table-column prop="nurseName" label="主护理师" min-width="100" show-overflow-tooltip>
            <template #default="{ row }">
              {{ row.nurseName || '—' }}
            </template>
          </el-table-column>
          <el-table-column prop="storeName" label="归属门店" min-width="120" show-overflow-tooltip>
            <template #default="{ row }">
              {{ row.storeName || '—' }}
            </template>
          </el-table-column>
          <el-table-column
            prop="memberOn"
            label="成为会员"
            min-width="160"
            sortable="custom"
          >
            <template #default="{ row }">
              {{ formatDateTime(row.memberOn) }}
            </template>
          </el-table-column>
          <el-table-column label="上次购买" min-width="160">
            <template #default="{ row }">
              {{ formatDateTime(rowOf(row).lastSaleTime) }}
            </template>
          </el-table-column>
          <el-table-column
            prop="lastTreatTime"
            label="上次消耗"
            min-width="160"
            sortable="custom"
          >
            <template #default="{ row }">
              {{ formatDateTime(row.lastTreatTime) }}
            </template>
          </el-table-column>
          <el-table-column
            prop="createdOn"
            label="注册日期"
            min-width="160"
            sortable="custom"
          >
            <template #default="{ row }">
              {{ formatDateTime(rowOf(row).createdOn) }}
            </template>
          </el-table-column>
          <el-table-column label="操作" width="160" fixed="right">
            <template #default="{ row }">
              <el-button
                v-permission="CustomerPermission.LIST_VIEW"
                link
                type="primary"
                @click="openDetail(rowOf(row))"
              >
                查看
              </el-button>
              <el-button
                v-permission="CustomerPermission.EDIT"
                link
                type="primary"
                @click="openEdit(rowOf(row))"
              >
                编辑
              </el-button>
            </template>
          </el-table-column>
        </el-table>
        <AppEmpty v-if="!loading && !loadError && list.length === 0" :title="emptyTitle" />
        <div v-if="total > 0" class="pager">
          <el-pagination
            background
            layout="total, sizes, prev, pager, next"
            :total="total"
            :current-page="page"
            :page-size="pageSize"
            :page-sizes="[10, 20, 50, 100]"
            @current-change="handlePageChange"
            @size-change="handleSizeChange"
          />
        </div>
      </template>
    </section>

    <CustomerCreateDialog v-model="createVisible" @success="onDialogSuccess" />
    <CustomerDetailDrawer
      ref="detailDrawerRef"
      v-model="detailVisible"
      :customer-id="activeCustomerId"
      @edit="openEditFromDetail"
      @updated="loadCustomers"
    />
    <CustomerEditDialog
      v-model="editVisible"
      :customer-id="activeCustomerId"
      @success="onDialogSuccess"
    />
  </div>
</template>

<style scoped>
.customer-list-page {
  box-sizing: border-box;
  min-height: 100%;
  padding: 16px 20px 24px;
  background: linear-gradient(180deg, #eef2f6 0%, #f5f7fa 120px);
}

.page-header h1 {
  margin: 0;
  color: #1f2d3d;
  font-size: 20px;
  font-weight: 600;
}

.subtitle {
  margin: 6px 0 0;
  color: #909399;
  font-size: 13px;
}

.query-panel,
.table-panel {
  margin-top: 12px;
  padding: 12px 14px;
  background: #fff;
  border: 1px solid #e4e7ed;
  border-radius: 4px;
}

.query-toolbar {
  display: flex;
  align-items: flex-start;
  justify-content: space-between;
  gap: 12px;
}

.query-form {
  flex: 1;
  margin-bottom: -8px;
}

.create-btn {
  flex-shrink: 0;
  margin-top: 2px;
}

.more-filters {
  margin-top: 4px;
  padding-top: 8px;
  border-top: 1px dashed #ebeef5;
}

.more-dot {
  display: inline-block;
  width: 6px;
  height: 6px;
  margin-left: 4px;
  vertical-align: middle;
  background: #f56c6c;
  border-radius: 50%;
}

.export-error {
  margin-top: 12px;
  background: #fff;
  border: 1px solid #e4e7ed;
  border-radius: 4px;
}

.pager {
  display: flex;
  justify-content: flex-end;
  margin-top: 12px;
}
</style>
