<script setup lang="ts">
import { reactive, ref, watch } from 'vue'

import AppEmpty from '@/components/common/AppEmpty.vue'
import AppError from '@/components/common/AppError.vue'
import {
  fetchCustomerPayments,
  fetchCustomerSales,
  fetchCustomerTreats,
} from '@/api/customer'
import type {
  CustomerPaymentItem,
  CustomerSaleOrder,
  CustomerTreatOrderItem,
} from '@/types/customer'
import { getUserFriendlyErrorMessage, runExclusive } from '@/utils/ui'
import { formatDateTime, formatMoney } from '@/views/customer/customer-format'
import SaleOrderDetailDialog from '@/views/customer/SaleOrderDetailDialog.vue'

defineOptions({ name: 'CustomerOrderInfo' })

const props = defineProps<{
  customerId: number
}>()

type OrderSubTab = 'sales' | 'payments' | 'treats' | 'transfers' | 'extensions'

const ORDER_TABS: Array<{ key: OrderSubTab; label: string }> = [
  { key: 'sales', label: '销售订单' },
  { key: 'payments', label: '支付明细' },
  { key: 'treats', label: '消耗明细' },
  { key: 'transfers', label: '转账记录' },
  { key: 'extensions', label: '延期记录' },
]

interface PageListState<T> {
  page: number
  size: number
  total: number
  records: T[]
  loaded: boolean
  error: string | null
}

function createPageState<T>(): PageListState<T> {
  return {
    page: 1,
    size: 20,
    total: 0,
    records: [],
    loaded: false,
    error: null,
  }
}

const activeTab = ref<OrderSubTab>('sales')
const salesLoading = ref(false)
const paymentsLoading = ref(false)
const treatsLoading = ref(false)
const salesState = reactive(createPageState<CustomerSaleOrder>())
const paymentsState = reactive(createPageState<CustomerPaymentItem>())
const treatsState = reactive(createPageState<CustomerTreatOrderItem>())

const detailVisible = ref(false)
const detailOrderId = ref<string | null>(null)

async function loadSales(force = false): Promise<void> {
  if (!force && salesState.loaded) {
    return
  }
  await runExclusive(salesLoading, async () => {
    salesState.error = null
    try {
      const data = await fetchCustomerSales(props.customerId, {
        page: salesState.page,
        size: salesState.size,
      })
      salesState.records = data.records ?? []
      salesState.total = data.total ?? 0
      salesState.page = data.page || salesState.page
      salesState.size = data.size || salesState.size
      salesState.loaded = true
    } catch (error) {
      salesState.records = []
      salesState.total = 0
      salesState.loaded = false
      salesState.error = getUserFriendlyErrorMessage(error)
    }
  })
}

async function loadPayments(force = false): Promise<void> {
  if (!force && paymentsState.loaded) {
    return
  }
  await runExclusive(paymentsLoading, async () => {
    paymentsState.error = null
    try {
      const data = await fetchCustomerPayments(props.customerId, {
        page: paymentsState.page,
        size: paymentsState.size,
      })
      paymentsState.records = data.records ?? []
      paymentsState.total = data.total ?? 0
      paymentsState.page = data.page || paymentsState.page
      paymentsState.size = data.size || paymentsState.size
      paymentsState.loaded = true
    } catch (error) {
      paymentsState.records = []
      paymentsState.total = 0
      paymentsState.loaded = false
      paymentsState.error = getUserFriendlyErrorMessage(error)
    }
  })
}

async function loadTreats(force = false): Promise<void> {
  if (!force && treatsState.loaded) {
    return
  }
  await runExclusive(treatsLoading, async () => {
    treatsState.error = null
    try {
      const data = await fetchCustomerTreats(props.customerId, {
        page: treatsState.page,
        size: treatsState.size,
      })
      treatsState.records = data.records ?? []
      treatsState.total = data.total ?? 0
      treatsState.page = data.page || treatsState.page
      treatsState.size = data.size || treatsState.size
      treatsState.loaded = true
    } catch (error) {
      treatsState.records = []
      treatsState.total = 0
      treatsState.loaded = false
      treatsState.error = getUserFriendlyErrorMessage(error)
    }
  })
}

function handleTabChange(name: string | number): void {
  activeTab.value = String(name) as OrderSubTab
  if (activeTab.value === 'sales') {
    void loadSales()
  } else if (activeTab.value === 'payments') {
    void loadPayments()
  } else if (activeTab.value === 'treats') {
    void loadTreats()
  }
}

async function handleSalesPageChange(nextPage: number): Promise<void> {
  salesState.page = nextPage
  salesState.loaded = false
  await loadSales(true)
}

async function handleSalesSizeChange(size: number): Promise<void> {
  salesState.size = size
  salesState.page = 1
  salesState.loaded = false
  await loadSales(true)
}

async function handlePaymentsPageChange(nextPage: number): Promise<void> {
  paymentsState.page = nextPage
  paymentsState.loaded = false
  await loadPayments(true)
}

async function handlePaymentsSizeChange(size: number): Promise<void> {
  paymentsState.size = size
  paymentsState.page = 1
  paymentsState.loaded = false
  await loadPayments(true)
}

async function handleTreatsPageChange(nextPage: number): Promise<void> {
  treatsState.page = nextPage
  treatsState.loaded = false
  await loadTreats(true)
}

async function handleTreatsSizeChange(size: number): Promise<void> {
  treatsState.size = size
  treatsState.page = 1
  treatsState.loaded = false
  await loadTreats(true)
}

function openDetailById(orderId: string | null | undefined): void {
  if (orderId == null || orderId === '') {
    return
  }
  detailOrderId.value = orderId
  detailVisible.value = true
}

function openSaleDetail(row: CustomerSaleOrder): void {
  openDetailById(row.id)
}

function openPaymentOrder(row: CustomerPaymentItem): void {
  openDetailById(row.billId)
}

function saleRowOf(row: unknown): CustomerSaleOrder {
  return row as CustomerSaleOrder
}

function paymentRowOf(row: unknown): CustomerPaymentItem {
  return row as CustomerPaymentItem
}

function treatRowOf(row: unknown): CustomerTreatOrderItem {
  return row as CustomerTreatOrderItem
}

function treatStatusText(row: unknown): string {
  const item = treatRowOf(row)
  if (item.billStatusName != null && item.billStatusName !== '') {
    return item.billStatusName
  }
  if (item.billStatus != null && item.billStatus !== '') {
    return item.billStatus
  }
  return '—'
}

async function reloadCurrent(): Promise<void> {
  if (activeTab.value === 'sales') {
    await loadSales(true)
    return
  }
  if (activeTab.value === 'payments') {
    await loadPayments(true)
    return
  }
  if (activeTab.value === 'treats') {
    await loadTreats(true)
  }
}

function resetState(): void {
  activeTab.value = 'sales'
  Object.assign(salesState, createPageState<CustomerSaleOrder>())
  Object.assign(paymentsState, createPageState<CustomerPaymentItem>())
  Object.assign(treatsState, createPageState<CustomerTreatOrderItem>())
  detailVisible.value = false
  detailOrderId.value = null
}

watch(
  () => props.customerId,
  () => {
    resetState()
    void loadSales(true)
  },
  { immediate: true },
)

defineExpose({
  reloadCurrent,
})
</script>

<template>
  <div class="customer-order-info">
    <el-tabs
      v-model="activeTab"
      type="card"
      class="order-type-tabs"
      @tab-change="handleTabChange"
    >
      <el-tab-pane
        v-for="tab in ORDER_TABS"
        :key="tab.key"
        :label="tab.label"
        :name="tab.key"
      />
    </el-tabs>

    <div v-if="activeTab === 'sales'" class="order-content" v-loading="salesLoading">
      <AppError
        v-if="salesState.error && !salesLoading"
        :description="salesState.error"
        @retry="reloadCurrent"
      />
      <template v-else>
        <el-table :data="salesState.records" border stripe size="small" empty-text=" ">
          <el-table-column label="订单编号" min-width="160" show-overflow-tooltip>
            <template #default="{ row }">
              <el-button link type="primary" @click="openSaleDetail(saleRowOf(row))">
                {{ row.id || '—' }}
              </el-button>
            </template>
          </el-table-column>
          <el-table-column label="订单金额" min-width="110" align="right">
            <template #default="{ row }">
              {{ formatMoney(row.totalAmount) }}
            </template>
          </el-table-column>
          <el-table-column prop="billType" label="订单类型" min-width="90">
            <template #default="{ row }">
              {{ row.billType || '—' }}
            </template>
          </el-table-column>
          <el-table-column prop="billStatus" label="订单状态" min-width="90">
            <template #default="{ row }">
              {{ row.billStatus || '—' }}
            </template>
          </el-table-column>
          <el-table-column prop="storeName" label="开单门店" min-width="120" show-overflow-tooltip>
            <template #default="{ row }">
              {{ row.storeName || '—' }}
            </template>
          </el-table-column>
          <el-table-column prop="employeeName" label="开单人" min-width="100" show-overflow-tooltip>
            <template #default="{ row }">
              {{ row.employeeName || '—' }}
            </template>
          </el-table-column>
          <el-table-column label="订单时间" min-width="160">
            <template #default="{ row }">
              {{ formatDateTime(row.billDate) }}
            </template>
          </el-table-column>
          <el-table-column label="录单时间" min-width="160">
            <template #default="{ row }">
              {{ formatDateTime(row.createdOn) }}
            </template>
          </el-table-column>
          <el-table-column label="操作" width="80" fixed="right">
            <template #default="{ row }">
              <el-button link type="primary" @click="openSaleDetail(saleRowOf(row))">查看</el-button>
            </template>
          </el-table-column>
        </el-table>

        <AppEmpty
          v-if="!salesLoading && !salesState.error && salesState.loaded && salesState.records.length === 0"
          title="暂无销售订单"
        />

        <div v-if="salesState.total > 0" class="pager">
          <el-pagination
            background
            layout="total, sizes, prev, pager, next"
            :total="salesState.total"
            :current-page="salesState.page"
            :page-size="salesState.size"
            :page-sizes="[10, 20, 50, 100]"
            @current-change="handleSalesPageChange"
            @size-change="handleSalesSizeChange"
          />
        </div>
      </template>
    </div>

    <div v-else-if="activeTab === 'payments'" class="order-content" v-loading="paymentsLoading">
      <AppError
        v-if="paymentsState.error && !paymentsLoading"
        :description="paymentsState.error"
        @retry="reloadCurrent"
      />
      <template v-else>
        <el-table :data="paymentsState.records" border stripe size="small" empty-text=" ">
          <el-table-column label="订单编号" min-width="160" show-overflow-tooltip>
            <template #default="{ row }">
              <el-button link type="primary" @click="openPaymentOrder(paymentRowOf(row))">
                {{ row.billId || '—' }}
              </el-button>
            </template>
          </el-table-column>
          <el-table-column prop="billType" label="订单类型" min-width="90">
            <template #default="{ row }">
              {{ row.billType || '—' }}
            </template>
          </el-table-column>
          <el-table-column prop="storeName" label="开单门店" min-width="120" show-overflow-tooltip>
            <template #default="{ row }">
              {{ row.storeName || '—' }}
            </template>
          </el-table-column>
          <el-table-column prop="employeeName" label="开单人" min-width="100" show-overflow-tooltip>
            <template #default="{ row }">
              {{ row.employeeName || '—' }}
            </template>
          </el-table-column>
          <el-table-column label="订单金额" min-width="110" align="right">
            <template #default="{ row }">
              {{ formatMoney(row.totalAmount) }}
            </template>
          </el-table-column>
          <el-table-column label="下单金额" min-width="110" align="right">
            <template #default="{ row }">
              {{ formatMoney(row.orderAmount) }}
            </template>
          </el-table-column>
          <el-table-column prop="payType" label="支付类型" min-width="100">
            <template #default="{ row }">
              {{ row.payType || '—' }}
            </template>
          </el-table-column>
          <el-table-column prop="payMethodName" label="支付方式" min-width="110" show-overflow-tooltip>
            <template #default="{ row }">
              {{ row.payMethodName || '—' }}
            </template>
          </el-table-column>
          <el-table-column label="支付金额" min-width="110" align="right">
            <template #default="{ row }">
              {{ formatMoney(row.payAmount) }}
            </template>
          </el-table-column>
          <el-table-column label="录单时间" min-width="160">
            <template #default="{ row }">
              {{ formatDateTime(row.createdOn) }}
            </template>
          </el-table-column>
        </el-table>

        <AppEmpty
          v-if="!paymentsLoading && !paymentsState.error && paymentsState.loaded && paymentsState.records.length === 0"
          title="暂无支付明细"
        />

        <div v-if="paymentsState.total > 0" class="pager">
          <el-pagination
            background
            layout="total, sizes, prev, pager, next"
            :total="paymentsState.total"
            :current-page="paymentsState.page"
            :page-size="paymentsState.size"
            :page-sizes="[10, 20, 50, 100]"
            @current-change="handlePaymentsPageChange"
            @size-change="handlePaymentsSizeChange"
          />
        </div>
      </template>
    </div>

    <div v-else-if="activeTab === 'treats'" class="order-content" v-loading="treatsLoading">
      <AppError
        v-if="treatsState.error && !treatsLoading"
        :description="treatsState.error"
        @retry="reloadCurrent"
      />
      <template v-else>
        <el-table :data="treatsState.records" border stripe size="small" empty-text=" ">
          <el-table-column prop="id" label="订单编号" min-width="160" show-overflow-tooltip>
            <template #default="{ row }">
              {{ row.id || '—' }}
            </template>
          </el-table-column>
          <el-table-column label="消耗金额" min-width="110" align="right">
            <template #default="{ row }">
              {{ formatMoney(row.amount) }}
            </template>
          </el-table-column>
          <el-table-column prop="billType" label="订单类型" min-width="90">
            <template #default="{ row }">
              {{ row.billType || '—' }}
            </template>
          </el-table-column>
          <el-table-column label="订单状态" min-width="100">
            <template #default="{ row }">
              {{ treatStatusText(row) }}
            </template>
          </el-table-column>
          <el-table-column prop="storeName" label="消耗门店" min-width="120" show-overflow-tooltip>
            <template #default="{ row }">
              {{ row.storeName || '—' }}
            </template>
          </el-table-column>
          <el-table-column prop="employeeName" label="开单人" min-width="100" show-overflow-tooltip>
            <template #default="{ row }">
              {{ row.employeeName || '—' }}
            </template>
          </el-table-column>
          <el-table-column label="录单时间" min-width="160">
            <template #default="{ row }">
              {{ formatDateTime(row.createdOn) }}
            </template>
          </el-table-column>
          <el-table-column label="订单时间" min-width="160">
            <template #default="{ row }">
              {{ formatDateTime(row.billDate) }}
            </template>
          </el-table-column>
        </el-table>

        <AppEmpty
          v-if="!treatsLoading && !treatsState.error && treatsState.loaded && treatsState.records.length === 0"
          title="暂无消耗订单"
        />

        <div v-if="treatsState.total > 0" class="pager">
          <el-pagination
            background
            layout="total, sizes, prev, pager, next"
            :total="treatsState.total"
            :current-page="treatsState.page"
            :page-size="treatsState.size"
            :page-sizes="[10, 20, 50, 100]"
            @current-change="handleTreatsPageChange"
            @size-change="handleTreatsSizeChange"
          />
        </div>
      </template>
    </div>

    <div v-else class="order-content">
      <AppEmpty title="功能建设中" description="转账记录与延期记录后续接入。" />
    </div>

    <SaleOrderDetailDialog v-model="detailVisible" :order-id="detailOrderId" />
  </div>
</template>

<style scoped>
.customer-order-info {
  min-height: 200px;
}

.order-type-tabs {
  margin-bottom: 8px;
}

.order-content {
  min-height: 180px;
}

.pager {
  display: flex;
  justify-content: flex-end;
  margin-top: 12px;
}
</style>
