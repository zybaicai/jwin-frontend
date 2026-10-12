<script setup lang="ts">
import { computed, onMounted, onUnmounted, reactive, ref, watch } from 'vue'
import { useRoute, useRouter } from 'vue-router'

import AppEmpty from '@/components/common/AppEmpty.vue'
import AppError from '@/components/common/AppError.vue'
import TreatOrderDetailDialog from '@/components/sale/TreatOrderDetailDialog.vue'
import { fetchHandlerCandidates } from '@/api/handler'
import { fetchTreatOrderPage } from '@/api/treat'
import { HandlerTreatBizTypes } from '@/types/handler'
import {
  TREAT_ORDER_STATUS_OPTIONS,
  TREAT_ORDER_TYPE_OPTIONS,
  TreatPermission,
  formatTreatBillStatus,
  formatTreatBillType,
  type TreatOrderDetail,
} from '@/types/treat'
import { STORE_CONTEXT_CHANGED_EVENT, useStoreStore } from '@/stores/store'
import { usePermissionStore } from '@/stores/permission'
import { formatMoney, formatDateTime, maskMobile } from '@/views/customer/customer-format'
import { getUserFriendlyErrorMessage, runExclusive } from '@/utils/ui'

defineOptions({ name: 'TreatOrderListView' })

const route = useRoute()
const router = useRouter()
const permissionStore = usePermissionStore()
const storeStore = useStoreStore()

const hasViewPermission = computed(() =>
  permissionStore.hasPermission(TreatPermission.ORDER_VIEW),
)

const loading = ref(false)
const loadError = ref<string | null>(null)
const list = ref<TreatOrderDetail[]>([])
const total = ref(0)
const page = ref(1)
const pageSize = ref(20)
const moreFiltersOpen = ref(false)

const detailVisible = ref(false)
const detailOrderId = ref<string | null>(null)

const handlerOptions = ref<{ employeeId: string; name: string }[]>([])
const handlerLoading = ref(false)

const queryForm = reactive({
  keyword: '',
  handlerEmployeeId: '' as string,
  billDateRange: null as [string, string] | null,
  billId: '',
  status: '' as string,
  billType: '' as string,
})

const hasActiveFilters = computed(() => {
  return (
    !!queryForm.keyword.trim() ||
    !!queryForm.handlerEmployeeId ||
    queryForm.billDateRange != null ||
    !!queryForm.billId.trim() ||
    !!queryForm.status ||
    !!queryForm.billType
  )
})

const hasActiveMoreFilters = computed(() => {
  return (
    !!queryForm.billId.trim() ||
    !!queryForm.status ||
    !!queryForm.billType
  )
})

const emptyTitle = computed(() =>
  hasActiveFilters.value ? '暂无符合条件的消耗订单' : '暂无消耗订单',
)

const currentStoreLabel = computed(() => {
  const name = storeStore.currentStoreName
  const id = storeStore.currentStoreId
  if (name && id != null) {
    return `${name}（ID ${id}）`
  }
  if (id != null) {
    return `门店 ID ${id}`
  }
  return '当前登录门店'
})

function syncFormFromRoute(): void {
  const q = route.query
  queryForm.keyword = typeof q.keyword === 'string' ? q.keyword : ''
  queryForm.handlerEmployeeId =
    typeof q.handlerEmployeeId === 'string' ? q.handlerEmployeeId : ''
  queryForm.billId = typeof q.billId === 'string' ? q.billId : ''
  queryForm.status = typeof q.status === 'string' ? q.status : ''
  queryForm.billType = typeof q.billType === 'string' ? q.billType : ''
  const from = typeof q.billDateFrom === 'string' ? q.billDateFrom : ''
  const to = typeof q.billDateTo === 'string' ? q.billDateTo : ''
  queryForm.billDateRange = from && to ? [from, to] : null
  const p = Number(q.page)
  page.value = Number.isFinite(p) && p > 0 ? p : 1
  const s = Number(q.size)
  pageSize.value = Number.isFinite(s) && s > 0 ? s : 20
  moreFiltersOpen.value = hasActiveMoreFilters.value

  const detail = typeof q.detail === 'string' ? q.detail : ''
  if (detail) {
    detailOrderId.value = detail
    detailVisible.value = true
  }
}

function buildQueryParams(includePage: boolean): Record<string, string> {
  const params: Record<string, string> = {}
  if (queryForm.keyword.trim()) {
    params.keyword = queryForm.keyword.trim()
  }
  if (queryForm.handlerEmployeeId) {
    params.handlerEmployeeId = queryForm.handlerEmployeeId
  }
  if (queryForm.billId.trim()) {
    params.billId = queryForm.billId.trim()
  }
  if (queryForm.status) {
    params.status = queryForm.status
  }
  if (queryForm.billType) {
    params.billType = queryForm.billType
  }
  if (queryForm.billDateRange?.[0] && queryForm.billDateRange?.[1]) {
    params.billDateFrom = queryForm.billDateRange[0]
    params.billDateTo = queryForm.billDateRange[1]
  }
  if (includePage) {
    params.page = String(page.value)
    params.size = String(pageSize.value)
  }
  return params
}

async function replaceRouteQuery(): Promise<void> {
  await router.replace({
    name: 'treat-orders',
    query: buildQueryParams(true),
  })
}

async function loadHandlerOptions(keyword?: string): Promise<void> {
  await runExclusive(handlerLoading, async () => {
    try {
      const data = await fetchHandlerCandidates({
        bizType: HandlerTreatBizTypes.PROJECT_TREAT,
        storeId: storeStore.currentStoreId,
        keyword: keyword?.trim() || undefined,
      })
      handlerOptions.value = (data.employees ?? [])
        .filter((e) => e.employeeId)
        .map((e) => ({
          employeeId: String(e.employeeId),
          name: e.name?.trim() || String(e.employeeId),
        }))
    } catch {
      handlerOptions.value = []
    }
  })
}

async function loadList(): Promise<void> {
  if (!hasViewPermission.value) {
    list.value = []
    total.value = 0
    loadError.value = '无消耗订单查看权限（treat:order:view）'
    return
  }
  await runExclusive(loading, async () => {
    loadError.value = null
    try {
      const data = await fetchTreatOrderPage({
        keyword: queryForm.keyword.trim() || null,
        handlerEmployeeId: queryForm.handlerEmployeeId || null,
        status: queryForm.status || null,
        billId: queryForm.billId.trim() || null,
        billType: queryForm.billType || null,
        billDateFrom: queryForm.billDateRange?.[0] ?? null,
        billDateTo: queryForm.billDateRange?.[1] ?? null,
        page: page.value,
        size: pageSize.value,
      })
      list.value = data.records ?? []
      total.value = Number(data.total ?? 0)
    } catch (error) {
      list.value = []
      total.value = 0
      loadError.value = getUserFriendlyErrorMessage(error)
    }
  })
}

async function onSearch(): Promise<void> {
  page.value = 1
  await replaceRouteQuery()
  await loadList()
}

async function onReset(): Promise<void> {
  queryForm.keyword = ''
  queryForm.handlerEmployeeId = ''
  queryForm.billId = ''
  queryForm.status = ''
  queryForm.billType = ''
  queryForm.billDateRange = null
  page.value = 1
  await replaceRouteQuery()
  await loadList()
}

function toggleMoreFilters(): void {
  moreFiltersOpen.value = !moreFiltersOpen.value
}

async function onPageChange(p: number): Promise<void> {
  page.value = p
  await replaceRouteQuery()
  await loadList()
}

async function onSizeChange(s: number): Promise<void> {
  pageSize.value = s
  page.value = 1
  await replaceRouteQuery()
  await loadList()
}

function openDetail(row: TreatOrderDetail): void {
  if (!row.id) {
    return
  }
  detailOrderId.value = row.id
  detailVisible.value = true
}

function onOpenDetailClick(row: TreatOrderDetail | Record<string, unknown>): void {
  openDetail(row as TreatOrderDetail)
}

function onStoreChanged(): void {
  void loadHandlerOptions()
  void loadList()
}

onMounted(() => {
  syncFormFromRoute()
  void loadHandlerOptions()
  void loadList()
  window.addEventListener(STORE_CONTEXT_CHANGED_EVENT, onStoreChanged)
})

onUnmounted(() => {
  window.removeEventListener(STORE_CONTEXT_CHANGED_EVENT, onStoreChanged)
})

watch(
  () => route.query,
  () => {
    if (route.name !== 'treat-orders') {
      return
    }
    syncFormFromRoute()
  },
)
</script>

<template>
  <div class="page">
    <div class="filter-bar">
      <el-form :inline="true" class="filter-form" @submit.prevent="onSearch">
        <el-form-item label="客户信息">
          <el-input
            v-model="queryForm.keyword"
            clearable
            placeholder="姓名 / 手机号 / 客户编号"
            style="width: 220px"
            @keyup.enter="onSearch"
          />
        </el-form-item>
        <el-form-item label="经手人">
          <el-select
            v-model="queryForm.handlerEmployeeId"
            clearable
            filterable
            remote
            :remote-method="loadHandlerOptions"
            :loading="handlerLoading"
            placeholder="选择员工"
            style="width: 160px"
          >
            <el-option
              v-for="opt in handlerOptions"
              :key="opt.employeeId"
              :label="opt.name"
              :value="opt.employeeId"
            />
          </el-select>
        </el-form-item>
        <el-form-item label="下单时间">
          <el-date-picker
            v-model="queryForm.billDateRange"
            type="daterange"
            value-format="YYYY-MM-DD"
            start-placeholder="开始"
            end-placeholder="结束"
            unlink-panels
          />
        </el-form-item>
        <el-form-item>
          <el-button type="primary" :loading="loading" @click="onSearch">查询</el-button>
          <el-button :disabled="loading" @click="onReset">重置</el-button>
          <el-button link type="primary" @click="toggleMoreFilters">
            {{ moreFiltersOpen ? '收起筛选' : '更多筛选' }}
            <span v-if="!moreFiltersOpen && hasActiveMoreFilters" class="more-dot" />
          </el-button>
        </el-form-item>
      </el-form>

      <el-form
        v-show="moreFiltersOpen"
        :inline="true"
        class="filter-form more-filters"
        @submit.prevent="onSearch"
      >
        <el-form-item label="订单编号">
          <el-input
            v-model="queryForm.billId"
            clearable
            placeholder="如 XHD20260920000005"
            style="width: 200px"
          />
        </el-form-item>
        <el-form-item label="订单状态">
          <el-select
            v-model="queryForm.status"
            clearable
            placeholder="全部"
            style="width: 140px"
          >
            <el-option
              v-for="opt in TREAT_ORDER_STATUS_OPTIONS"
              :key="opt.value"
              :label="opt.label"
              :value="opt.value"
            />
          </el-select>
        </el-form-item>
        <el-form-item label="订单类型">
          <el-select
            v-model="queryForm.billType"
            clearable
            placeholder="全部"
            style="width: 140px"
          >
            <el-option
              v-for="opt in TREAT_ORDER_TYPE_OPTIONS"
              :key="opt.value"
              :label="opt.label"
              :value="opt.value"
            />
          </el-select>
        </el-form-item>
      </el-form>

      <div class="store-hint">
        数据范围：{{ currentStoreLabel }}（由登录门店限定，不可跨店查询）
      </div>
    </div>

    <AppError
      v-if="loadError && !loading"
      :description="loadError"
      @retry="loadList"
    />

    <div v-else v-loading="loading" class="table-wrap">
      <el-table :data="list" border stripe empty-text=" ">
        <el-table-column label="订单编号" min-width="160" show-overflow-tooltip>
          <template #default="{ row }">
            {{ row.id || '—' }}
          </template>
        </el-table-column>
        <el-table-column label="客户信息" min-width="140" show-overflow-tooltip>
          <template #default="{ row }">
            <div class="customer-cell">
              <span>{{ row.customerName || '—' }}</span>
              <span class="mobile">{{ maskMobile(row.customerMobile) }}</span>
            </div>
          </template>
        </el-table-column>
        <el-table-column label="手机号" min-width="120">
          <template #default="{ row }">
            {{ maskMobile(row.customerMobile) }}
          </template>
        </el-table-column>
        <el-table-column label="消耗金额" min-width="110" align="right">
          <template #default="{ row }">
            {{ formatMoney(row.amount) }}
          </template>
        </el-table-column>
        <el-table-column label="订单类型" min-width="100">
          <template #default="{ row }">
            {{ formatTreatBillType(row.billType) }}
          </template>
        </el-table-column>
        <el-table-column label="订单状态" width="100">
          <template #default="{ row }">
            {{ formatTreatBillStatus(row.billStatus) }}
          </template>
        </el-table-column>
        <el-table-column label="录单人" min-width="100" show-overflow-tooltip>
          <template #default="{ row }">
            {{ row.employeeName || row.employeeId || '—' }}
          </template>
        </el-table-column>
        <el-table-column label="经手人" min-width="120" show-overflow-tooltip>
          <template #default="{ row }">
            {{ row.handlerNames || '—' }}
          </template>
        </el-table-column>
        <el-table-column label="下单时间" min-width="160">
          <template #default="{ row }">
            {{ formatDateTime(row.billDate) }}
          </template>
        </el-table-column>
        <el-table-column label="录单时间" min-width="160">
          <template #default="{ row }">
            {{ formatDateTime(row.createdOn) }}
          </template>
        </el-table-column>
        <el-table-column label="操作" width="100" fixed="right">
          <template #default="{ row }">
            <el-button link type="primary" @click="onOpenDetailClick(row)">
              详情
            </el-button>
          </template>
        </el-table-column>
      </el-table>

      <AppEmpty v-if="!loading && list.length === 0" :title="emptyTitle" />

      <div class="pager">
        <el-pagination
          background
          layout="total, sizes, prev, pager, next"
          :total="total"
          :current-page="page"
          :page-size="pageSize"
          :page-sizes="[10, 20, 50]"
          @current-change="onPageChange"
          @size-change="onSizeChange"
        />
      </div>
    </div>

    <TreatOrderDetailDialog
      v-model="detailVisible"
      :order-id="detailOrderId"
      @changed="loadList"
    />
  </div>
</template>

<style scoped>
.page {
  display: flex;
  flex-direction: column;
  gap: 12px;
  padding: 12px 16px 24px;
  min-height: 100%;
}

.filter-bar {
  background: #fff;
  border: 1px solid #ebeef5;
  border-radius: 4px;
  padding: 12px 12px 4px;
}

.filter-form {
  margin-bottom: 0;
}

.more-filters {
  margin-top: 4px;
  padding-top: 4px;
  border-top: 1px dashed #ebeef5;
}

.more-dot {
  display: inline-block;
  width: 6px;
  height: 6px;
  margin-left: 4px;
  border-radius: 50%;
  background: #f56c6c;
  vertical-align: middle;
}

.store-hint {
  margin: 0 0 8px;
  color: #909399;
  font-size: 12px;
}

.table-wrap {
  background: #fff;
  border: 1px solid #ebeef5;
  border-radius: 4px;
  padding: 12px;
  min-height: 280px;
}

.customer-cell {
  display: flex;
  flex-direction: column;
  gap: 2px;
  line-height: 1.3;
}

.customer-cell .mobile {
  color: #909399;
  font-size: 12px;
}

.pager {
  display: flex;
  justify-content: flex-end;
  margin-top: 12px;
}
</style>
