<script setup lang="ts">
import { computed, onMounted, onUnmounted, reactive, ref } from 'vue'

import AppEmpty from '@/components/common/AppEmpty.vue'
import AppError from '@/components/common/AppError.vue'
import {
  fetchCustomerPage,
  fetchCustomerSourceOptions,
  fetchCustomerSourcePage,
  fetchServicerOptions,
} from '@/api/customer'
import { CustomerPermission, type CustomerListItem, type CustomerSourceOption } from '@/types/customer'
import { STORE_CONTEXT_CHANGED_EVENT } from '@/stores/store'
import { usePermissionStore } from '@/stores/permission'
import { getUserFriendlyErrorMessage, notifyError, runExclusive } from '@/utils/ui'
import CustomerCreateDialog from '@/views/customer/CustomerCreateDialog.vue'
import CustomerDetailDrawer from '@/views/customer/CustomerDetailDrawer.vue'
import CustomerEditDialog from '@/views/customer/CustomerEditDialog.vue'
import { formatDateTime, pickMainNurseEmployees } from '@/views/customer/customer-format'

defineOptions({ name: 'CustomerListView' })

const permissionStore = usePermissionStore()

const createVisible = ref(false)
const detailVisible = ref(false)
const editVisible = ref(false)
const activeCustomerId = ref<number | null>(null)
const detailDrawerRef = ref<{ reload: () => Promise<void> } | null>(null)

const loading = ref(false)
const loadError = ref<string | null>(null)
const list = ref<CustomerListItem[]>([])
const total = ref(0)
const page = ref(1)
const pageSize = ref(20)

const queryForm = reactive({
  keyword: '',
  mobile: '',
  sourceId: undefined as number | undefined,
  nurseEmployeeId: '' as string,
})

const sourceOptions = ref<CustomerSourceOption[]>([])
const nurseOptions = ref<{ id: string; name: string }[]>([])

const hasListPermission = computed(() => permissionStore.hasPermission(CustomerPermission.LIST_VIEW))

async function loadFilterOptions(): Promise<void> {
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
    } catch {
      nurseOptions.value = []
    }
    return
  }
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
      const data = await fetchCustomerPage({
        keyword: queryForm.keyword.trim() || undefined,
        mobile: queryForm.mobile.trim() || undefined,
        sourceId: queryForm.sourceId,
        nurseEmployeeId: queryForm.nurseEmployeeId || undefined,
        page: page.value,
        size: pageSize.value,
      })
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
  queryForm.mobile = ''
  queryForm.sourceId = undefined
  queryForm.nurseEmployeeId = ''
  page.value = 1
  await loadCustomers()
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
  window.addEventListener(STORE_CONTEXT_CHANGED_EVENT, onStoreChanged)
  void (async () => {
    await loadFilterOptions()
    await loadCustomers()
  })()
})

onUnmounted(() => {
  window.removeEventListener(STORE_CONTEXT_CHANGED_EVENT, onStoreChanged)
})
</script>

<template>
  <div class="customer-list-page">
    <header class="page-header">
      <h1>客户管理</h1>
      <p class="subtitle">本店已关联客户。跨店开单请走销售/耗卡选客，不在本列表浏览全连锁。</p>
    </header>

    <section class="query-panel">
      <el-form :inline="true" class="query-form" @submit.prevent>
        <el-form-item label="关键字">
          <el-input
            v-model="queryForm.keyword"
            clearable
            placeholder="姓名 / 编号 / 手机号"
            style="width: 200px"
            @keyup.enter="handleSearch"
          />
        </el-form-item>
        <el-form-item label="手机号">
          <el-input
            v-model="queryForm.mobile"
            clearable
            placeholder="手机号"
            style="width: 160px"
            @keyup.enter="handleSearch"
          />
        </el-form-item>
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
          <el-button type="primary" :loading="loading" @click="handleSearch">查询</el-button>
          <el-button :disabled="loading" @click="handleReset">重置</el-button>
        </el-form-item>
      </el-form>
    </section>

    <section class="action-panel">
      <el-button
        v-permission="CustomerPermission.CREATE"
        type="primary"
        @click="openCreate"
      >
        新增客户
      </el-button>
    </section>

    <section class="table-panel">
      <AppError
        v-if="loadError && !loading"
        :description="loadError"
        @retry="loadCustomers"
      />
      <template v-else>
        <el-table v-loading="loading" :data="list" border stripe empty-text=" ">
          <el-table-column prop="name" label="客户姓名" min-width="110" show-overflow-tooltip />
          <el-table-column prop="code" label="客户编号" min-width="110" show-overflow-tooltip />
          <el-table-column prop="mobile" label="手机号" min-width="120" />
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
          <el-table-column label="成为会员" min-width="160">
            <template #default="{ row }">
              {{ formatDateTime(row.memberOn) }}
            </template>
          </el-table-column>
          <el-table-column label="上次消耗" min-width="160">
            <template #default="{ row }">
              {{ formatDateTime(row.lastTreatTime) }}
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
        <AppEmpty v-if="!loading && !loadError && list.length === 0" title="暂无客户" />
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
.action-panel,
.table-panel {
  margin-top: 12px;
  padding: 12px 14px;
  background: #fff;
  border: 1px solid #e4e7ed;
  border-radius: 4px;
}

.query-form {
  margin-bottom: -8px;
}

.action-panel {
  display: flex;
  align-items: center;
  gap: 8px;
}

.pager {
  display: flex;
  justify-content: flex-end;
  margin-top: 12px;
}
</style>
