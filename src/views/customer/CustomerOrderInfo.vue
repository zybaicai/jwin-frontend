<script setup lang="ts">
import { reactive, ref, watch } from 'vue'

import AppEmpty from '@/components/common/AppEmpty.vue'
import AppError from '@/components/common/AppError.vue'
import {
  fetchCustomerExtensions,
  fetchCustomerPayments,
  fetchCustomerSaleItems,
  fetchCustomerSales,
  fetchCustomerTreatItems,
  fetchCustomerTreats,
  fetchCustomerTransfers,
} from '@/api/customer'
import type {
  CustomerExtensionItem,
  CustomerPaymentItem,
  CustomerSaleItem,
  CustomerSaleOrder,
  CustomerTreatItem,
  CustomerTreatOrderItem,
  CustomerTransferItem,
} from '@/types/customer'
import { getUserFriendlyErrorMessage, runExclusive } from '@/utils/ui'
import { formatDateTime, formatMoney } from '@/views/customer/customer-format'
import SaleOrderDetailDialog from '@/views/customer/SaleOrderDetailDialog.vue'

defineOptions({ name: 'CustomerOrderInfo' })

const props = defineProps<{
  customerId: number
}>()

type OrderSubTab =
  | 'sales'
  | 'saleItems'
  | 'payments'
  | 'treats'
  | 'treatItems'
  | 'transfers'
  | 'extensions'

const ORDER_TABS: Array<{ key: OrderSubTab; label: string }> = [
  { key: 'sales', label: '销售订单' },
  { key: 'saleItems', label: '销售明细' },
  { key: 'payments', label: '支付明细' },
  { key: 'treats', label: '消耗订单' },
  { key: 'treatItems', label: '消耗明细' },
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
const saleItemsLoading = ref(false)
const paymentsLoading = ref(false)
const treatsLoading = ref(false)
const treatItemsLoading = ref(false)
const transfersLoading = ref(false)
const extensionsLoading = ref(false)
const salesState = reactive(createPageState<CustomerSaleOrder>())
const saleItemsState = reactive(createPageState<CustomerSaleItem>())
const paymentsState = reactive(createPageState<CustomerPaymentItem>())
const treatsState = reactive(createPageState<CustomerTreatOrderItem>())
const treatItemsState = reactive(createPageState<CustomerTreatItem>())
const transfersState = reactive(createPageState<CustomerTransferItem>())
const extensionsState = reactive(createPageState<CustomerExtensionItem>())

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

async function loadSaleItems(force = false): Promise<void> {
  if (!force && saleItemsState.loaded) {
    return
  }
  await runExclusive(saleItemsLoading, async () => {
    saleItemsState.error = null
    try {
      const data = await fetchCustomerSaleItems(props.customerId, {
        page: saleItemsState.page,
        size: saleItemsState.size,
      })
      saleItemsState.records = data.records ?? []
      saleItemsState.total = data.total ?? 0
      saleItemsState.page = data.page || saleItemsState.page
      saleItemsState.size = data.size || saleItemsState.size
      saleItemsState.loaded = true
    } catch (error) {
      saleItemsState.records = []
      saleItemsState.total = 0
      saleItemsState.loaded = false
      saleItemsState.error = getUserFriendlyErrorMessage(error)
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

async function loadTreatItems(force = false): Promise<void> {
  if (!force && treatItemsState.loaded) {
    return
  }
  await runExclusive(treatItemsLoading, async () => {
    treatItemsState.error = null
    try {
      const data = await fetchCustomerTreatItems(props.customerId, {
        page: treatItemsState.page,
        size: treatItemsState.size,
      })
      treatItemsState.records = data.records ?? []
      treatItemsState.total = data.total ?? 0
      treatItemsState.page = data.page || treatItemsState.page
      treatItemsState.size = data.size || treatItemsState.size
      treatItemsState.loaded = true
    } catch (error) {
      treatItemsState.records = []
      treatItemsState.total = 0
      treatItemsState.loaded = false
      treatItemsState.error = getUserFriendlyErrorMessage(error)
    }
  })
}

async function loadTransfers(force = false): Promise<void> {
  if (!force && transfersState.loaded) {
    return
  }
  await runExclusive(transfersLoading, async () => {
    transfersState.error = null
    try {
      const data = await fetchCustomerTransfers(props.customerId, {
        page: transfersState.page,
        size: transfersState.size,
      })
      transfersState.records = data.records ?? []
      transfersState.total = data.total ?? 0
      transfersState.page = data.page || transfersState.page
      transfersState.size = data.size || transfersState.size
      transfersState.loaded = true
    } catch (error) {
      transfersState.records = []
      transfersState.total = 0
      transfersState.loaded = false
      transfersState.error = getUserFriendlyErrorMessage(error)
    }
  })
}

async function loadExtensions(force = false): Promise<void> {
  if (!force && extensionsState.loaded) {
    return
  }
  await runExclusive(extensionsLoading, async () => {
    extensionsState.error = null
    try {
      const data = await fetchCustomerExtensions(props.customerId, {
        page: extensionsState.page,
        size: extensionsState.size,
      })
      extensionsState.records = data.records ?? []
      extensionsState.total = data.total ?? 0
      extensionsState.page = data.page || extensionsState.page
      extensionsState.size = data.size || extensionsState.size
      extensionsState.loaded = true
    } catch (error) {
      extensionsState.records = []
      extensionsState.total = 0
      extensionsState.loaded = false
      extensionsState.error = getUserFriendlyErrorMessage(error)
    }
  })
}

function handleTabChange(name: string | number): void {
  activeTab.value = String(name) as OrderSubTab
  if (activeTab.value === 'sales') {
    void loadSales()
  } else if (activeTab.value === 'saleItems') {
    void loadSaleItems()
  } else if (activeTab.value === 'payments') {
    void loadPayments()
  } else if (activeTab.value === 'treats') {
    void loadTreats()
  } else if (activeTab.value === 'treatItems') {
    void loadTreatItems()
  } else if (activeTab.value === 'transfers') {
    void loadTransfers()
  } else if (activeTab.value === 'extensions') {
    void loadExtensions()
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

async function handleSaleItemsPageChange(nextPage: number): Promise<void> {
  saleItemsState.page = nextPage
  saleItemsState.loaded = false
  await loadSaleItems(true)
}

async function handleSaleItemsSizeChange(size: number): Promise<void> {
  saleItemsState.size = size
  saleItemsState.page = 1
  saleItemsState.loaded = false
  await loadSaleItems(true)
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

async function handleTreatItemsPageChange(nextPage: number): Promise<void> {
  treatItemsState.page = nextPage
  treatItemsState.loaded = false
  await loadTreatItems(true)
}

async function handleTreatItemsSizeChange(size: number): Promise<void> {
  treatItemsState.size = size
  treatItemsState.page = 1
  treatItemsState.loaded = false
  await loadTreatItems(true)
}

async function handleTransfersPageChange(nextPage: number): Promise<void> {
  transfersState.page = nextPage
  transfersState.loaded = false
  await loadTransfers(true)
}

async function handleTransfersSizeChange(size: number): Promise<void> {
  transfersState.size = size
  transfersState.page = 1
  transfersState.loaded = false
  await loadTransfers(true)
}

async function handleExtensionsPageChange(nextPage: number): Promise<void> {
  extensionsState.page = nextPage
  extensionsState.loaded = false
  await loadExtensions(true)
}

async function handleExtensionsSizeChange(size: number): Promise<void> {
  extensionsState.size = size
  extensionsState.page = 1
  extensionsState.loaded = false
  await loadExtensions(true)
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

function openSaleItemOrder(row: CustomerSaleItem): void {
  openDetailById(row.billId)
}

function saleRowOf(row: unknown): CustomerSaleOrder {
  return row as CustomerSaleOrder
}

function saleItemRowOf(row: unknown): CustomerSaleItem {
  return row as CustomerSaleItem
}

function saleItemTypeText(row: unknown): string {
  const item = saleItemRowOf(row)
  if (item.itemTypeName != null && item.itemTypeName !== '') {
    return item.itemTypeName
  }
  if (item.itemType != null && item.itemType !== '') {
    return item.itemType
  }
  return '—'
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

function treatItemRowOf(row: unknown): CustomerTreatItem {
  return row as CustomerTreatItem
}

function treatItemStatusText(row: unknown): string {
  const item = treatItemRowOf(row)
  if (item.billStatusName != null && item.billStatusName !== '') {
    return item.billStatusName
  }
  if (item.billStatus != null && item.billStatus !== '') {
    return item.billStatus
  }
  return '—'
}

function giftText(value: boolean | null | undefined): string {
  if (value === true) {
    return '是'
  }
  if (value === false) {
    return '否'
  }
  return '—'
}

function extensionStatusText(row: unknown): string {
  const item = row as CustomerExtensionItem
  if (item.approvalStatusName != null && item.approvalStatusName !== '') {
    return item.approvalStatusName
  }
  if (item.approvalStatus != null && item.approvalStatus !== '') {
    return item.approvalStatus
  }
  return '—'
}

function extensionDaysText(row: unknown): string {
  const item = row as CustomerExtensionItem
  if (item.everlasting === true) {
    return '永久'
  }
  if (item.extensionDays == null) {
    return '—'
  }
  return String(item.extensionDays)
}

async function reloadCurrent(): Promise<void> {
  if (activeTab.value === 'sales') {
    await loadSales(true)
    return
  }
  if (activeTab.value === 'saleItems') {
    await loadSaleItems(true)
    return
  }
  if (activeTab.value === 'payments') {
    await loadPayments(true)
    return
  }
  if (activeTab.value === 'treats') {
    await loadTreats(true)
    return
  }
  if (activeTab.value === 'treatItems') {
    await loadTreatItems(true)
    return
  }
  if (activeTab.value === 'transfers') {
    await loadTransfers(true)
    return
  }
  if (activeTab.value === 'extensions') {
    await loadExtensions(true)
  }
}

function resetState(): void {
  activeTab.value = 'sales'
  Object.assign(salesState, createPageState<CustomerSaleOrder>())
  Object.assign(saleItemsState, createPageState<CustomerSaleItem>())
  Object.assign(paymentsState, createPageState<CustomerPaymentItem>())
  Object.assign(treatsState, createPageState<CustomerTreatOrderItem>())
  Object.assign(treatItemsState, createPageState<CustomerTreatItem>())
  Object.assign(transfersState, createPageState<CustomerTransferItem>())
  Object.assign(extensionsState, createPageState<CustomerExtensionItem>())
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

    <div v-else-if="activeTab === 'saleItems'" class="order-content" v-loading="saleItemsLoading">
      <AppError
        v-if="saleItemsState.error && !saleItemsLoading"
        :description="saleItemsState.error"
        @retry="reloadCurrent"
      />
      <template v-else>
        <el-table :data="saleItemsState.records" border stripe size="small" empty-text=" ">
          <el-table-column label="销售订单号" min-width="160" show-overflow-tooltip>
            <template #default="{ row }">
              <el-button link type="primary" @click="openSaleItemOrder(saleItemRowOf(row))">
                {{ row.billId || '—' }}
              </el-button>
            </template>
          </el-table-column>
          <el-table-column prop="billStatus" label="订单状态" min-width="90">
            <template #default="{ row }">
              {{ row.billStatus || '—' }}
            </template>
          </el-table-column>
          <el-table-column prop="storeName" label="销售门店" min-width="120" show-overflow-tooltip>
            <template #default="{ row }">
              {{ row.storeName || '—' }}
            </template>
          </el-table-column>
          <el-table-column prop="employeeName" label="销售人员" min-width="100" show-overflow-tooltip>
            <template #default="{ row }">
              {{ row.employeeName || '—' }}
            </template>
          </el-table-column>
          <el-table-column label="商品类型" min-width="90">
            <template #default="{ row }">
              {{ saleItemTypeText(row) }}
            </template>
          </el-table-column>
          <el-table-column prop="categoryName" label="商品分类" min-width="100" show-overflow-tooltip>
            <template #default="{ row }">
              {{ row.categoryName || '—' }}
            </template>
          </el-table-column>
          <el-table-column prop="itemName" label="项目/商品名称" min-width="140" show-overflow-tooltip>
            <template #default="{ row }">
              {{ row.itemName || '—' }}
            </template>
          </el-table-column>
          <el-table-column label="原价" min-width="90" align="right">
            <template #default="{ row }">
              {{ formatMoney(row.price) }}
            </template>
          </el-table-column>
          <el-table-column prop="quantity" label="数量" min-width="70" align="right">
            <template #default="{ row }">
              {{ row.quantity ?? '—' }}
            </template>
          </el-table-column>
          <el-table-column label="赠送" min-width="60" align="center">
            <template #default="{ row }">
              {{ giftText(row.gift) }}
            </template>
          </el-table-column>
          <el-table-column label="售价" min-width="100" align="right">
            <template #default="{ row }">
              {{ formatMoney(row.totalAmount) }}
            </template>
          </el-table-column>
          <el-table-column label="赠送金额" min-width="100" align="right">
            <template #default="{ row }">
              {{ formatMoney(row.giftAmount) }}
            </template>
          </el-table-column>
          <el-table-column label="欠款金额" min-width="100" align="right">
            <template #default="{ row }">
              {{ formatMoney(row.arrearAmount) }}
            </template>
          </el-table-column>
          <el-table-column label="实收金额" min-width="100" align="right">
            <template #default="{ row }">
              {{ formatMoney(row.payAmount) }}
            </template>
          </el-table-column>
          <el-table-column label="销售时间" min-width="160">
            <template #default="{ row }">
              {{ formatDateTime(row.billDate) }}
            </template>
          </el-table-column>
        </el-table>

        <AppEmpty
          v-if="!saleItemsLoading && !saleItemsState.error && saleItemsState.loaded && saleItemsState.records.length === 0"
          title="暂无销售明细"
        />

        <div v-if="saleItemsState.total > 0" class="pager">
          <el-pagination
            background
            layout="total, sizes, prev, pager, next"
            :total="saleItemsState.total"
            :current-page="saleItemsState.page"
            :page-size="saleItemsState.size"
            :page-sizes="[10, 20, 50, 100]"
            @current-change="handleSaleItemsPageChange"
            @size-change="handleSaleItemsSizeChange"
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

    <div v-else-if="activeTab === 'treatItems'" class="order-content" v-loading="treatItemsLoading">
      <AppError
        v-if="treatItemsState.error && !treatItemsLoading"
        :description="treatItemsState.error"
        @retry="reloadCurrent"
      />
      <template v-else>
        <el-table :data="treatItemsState.records" border stripe size="small" empty-text=" ">
          <el-table-column prop="billId" label="订单编号" min-width="150" show-overflow-tooltip>
            <template #default="{ row }">
              {{ row.billId || '—' }}
            </template>
          </el-table-column>
          <el-table-column label="订单状态" min-width="90">
            <template #default="{ row }">
              {{ treatItemStatusText(row) }}
            </template>
          </el-table-column>
          <el-table-column prop="billType" label="订单类型" min-width="80">
            <template #default="{ row }">
              {{ row.billType || '—' }}
            </template>
          </el-table-column>
          <el-table-column prop="storeName" label="开单门店" min-width="120" show-overflow-tooltip>
            <template #default="{ row }">
              {{ row.storeName || '—' }}
            </template>
          </el-table-column>
          <el-table-column prop="itemTypeName" label="商品类型" min-width="90">
            <template #default="{ row }">
              {{ row.itemTypeName || '—' }}
            </template>
          </el-table-column>
          <el-table-column prop="cardName" label="卡名称" min-width="120" show-overflow-tooltip>
            <template #default="{ row }">
              {{ row.cardName || '—' }}
            </template>
          </el-table-column>
          <el-table-column prop="categoryName" label="商品分类" min-width="100" show-overflow-tooltip>
            <template #default="{ row }">
              {{ row.categoryName || '—' }}
            </template>
          </el-table-column>
          <el-table-column prop="itemName" label="商品名称" min-width="120" show-overflow-tooltip>
            <template #default="{ row }">
              {{ row.itemName || '—' }}
            </template>
          </el-table-column>
          <el-table-column label="单价" min-width="90" align="right">
            <template #default="{ row }">
              {{ formatMoney(row.price) }}
            </template>
          </el-table-column>
          <el-table-column prop="quantity" label="数量" min-width="70" align="right">
            <template #default="{ row }">
              {{ row.quantity ?? '—' }}
            </template>
          </el-table-column>
          <el-table-column label="赠送" min-width="60" align="center">
            <template #default="{ row }">
              {{ giftText(row.gift) }}
            </template>
          </el-table-column>
          <el-table-column label="合计金额" min-width="100" align="right">
            <template #default="{ row }">
              {{ formatMoney(row.totalAmount) }}
            </template>
          </el-table-column>
          <el-table-column label="现金金额" min-width="100" align="right">
            <template #default="{ row }">
              {{ formatMoney(row.payAmount) }}
            </template>
          </el-table-column>
          <el-table-column label="卡扣金额" min-width="100" align="right">
            <template #default="{ row }">
              {{ formatMoney(row.cardDeductionAmount) }}
            </template>
          </el-table-column>
          <el-table-column label="赠送卡扣" min-width="100" align="right">
            <template #default="{ row }">
              {{ formatMoney(row.largessCardDeductionAmount) }}
            </template>
          </el-table-column>
          <el-table-column label="消费时间" min-width="160">
            <template #default="{ row }">
              {{ formatDateTime(row.billDate) }}
            </template>
          </el-table-column>
        </el-table>

        <AppEmpty
          v-if="!treatItemsLoading && !treatItemsState.error && treatItemsState.loaded && treatItemsState.records.length === 0"
          title="暂无消耗明细"
        />

        <div v-if="treatItemsState.total > 0" class="pager">
          <el-pagination
            background
            layout="total, sizes, prev, pager, next"
            :total="treatItemsState.total"
            :current-page="treatItemsState.page"
            :page-size="treatItemsState.size"
            :page-sizes="[10, 20, 50, 100]"
            @current-change="handleTreatItemsPageChange"
            @size-change="handleTreatItemsSizeChange"
          />
        </div>
      </template>
    </div>

    <div v-else-if="activeTab === 'transfers'" class="order-content" v-loading="transfersLoading">
      <AppError
        v-if="transfersState.error && !transfersLoading"
        :description="transfersState.error"
        @retry="reloadCurrent"
      />
      <template v-else>
        <el-table :data="transfersState.records" border stripe size="small" empty-text=" ">
          <el-table-column prop="id" label="订单编号" min-width="150" show-overflow-tooltip>
            <template #default="{ row }">
              {{ row.id || '—' }}
            </template>
          </el-table-column>
          <el-table-column prop="outCustomerName" label="转出顾客" min-width="110" show-overflow-tooltip>
            <template #default="{ row }">
              {{ row.outCustomerName || '—' }}
            </template>
          </el-table-column>
          <el-table-column prop="inCustomerName" label="转入顾客" min-width="110" show-overflow-tooltip>
            <template #default="{ row }">
              {{ row.inCustomerName || '—' }}
            </template>
          </el-table-column>
          <el-table-column prop="storeName" label="操作门店" min-width="120" show-overflow-tooltip>
            <template #default="{ row }">
              {{ row.storeName || '—' }}
            </template>
          </el-table-column>
          <el-table-column prop="employeeName" label="录单人" min-width="100" show-overflow-tooltip>
            <template #default="{ row }">
              {{ row.employeeName || '—' }}
            </template>
          </el-table-column>
          <el-table-column prop="billStatus" label="状态" min-width="90">
            <template #default="{ row }">
              {{ row.billStatus || '—' }}
            </template>
          </el-table-column>
          <el-table-column label="申请时间" min-width="160">
            <template #default="{ row }">
              {{ formatDateTime(row.createdOn) }}
            </template>
          </el-table-column>
        </el-table>

        <AppEmpty
          v-if="!transfersLoading && !transfersState.error && transfersState.loaded && transfersState.records.length === 0"
          title="暂无转账记录"
        />

        <div v-if="transfersState.total > 0" class="pager">
          <el-pagination
            background
            layout="total, sizes, prev, pager, next"
            :total="transfersState.total"
            :current-page="transfersState.page"
            :page-size="transfersState.size"
            :page-sizes="[10, 20, 50, 100]"
            @current-change="handleTransfersPageChange"
            @size-change="handleTransfersSizeChange"
          />
        </div>
      </template>
    </div>

    <div v-else-if="activeTab === 'extensions'" class="order-content" v-loading="extensionsLoading">
      <AppError
        v-if="extensionsState.error && !extensionsLoading"
        :description="extensionsState.error"
        @retry="reloadCurrent"
      />
      <template v-else>
        <el-table :data="extensionsState.records" border stripe size="small" empty-text=" ">
          <el-table-column prop="billId" label="延期单号" min-width="150" show-overflow-tooltip>
            <template #default="{ row }">
              {{ row.billId || '—' }}
            </template>
          </el-table-column>
          <el-table-column prop="cardName" label="卡名称" min-width="120" show-overflow-tooltip>
            <template #default="{ row }">
              {{ row.cardName || '—' }}
            </template>
          </el-table-column>
          <el-table-column prop="itemTypeName" label="卡项类型" min-width="100">
            <template #default="{ row }">
              {{ row.itemTypeName || '—' }}
            </template>
          </el-table-column>
          <el-table-column label="延期前有效期" min-width="160">
            <template #default="{ row }">
              {{ formatDateTime(row.oldValidDate) }}
            </template>
          </el-table-column>
          <el-table-column label="延期后有效期" min-width="160">
            <template #default="{ row }">
              {{ formatDateTime(row.newValidDate) }}
            </template>
          </el-table-column>
          <el-table-column label="延期天数" min-width="90" align="right">
            <template #default="{ row }">
              {{ extensionDaysText(row) }}
            </template>
          </el-table-column>
          <el-table-column prop="storeName" label="操作门店" min-width="120" show-overflow-tooltip>
            <template #default="{ row }">
              {{ row.storeName || '—' }}
            </template>
          </el-table-column>
          <el-table-column prop="employeeName" label="录单人" min-width="100" show-overflow-tooltip>
            <template #default="{ row }">
              {{ row.employeeName || '—' }}
            </template>
          </el-table-column>
          <el-table-column label="状态" min-width="90">
            <template #default="{ row }">
              {{ extensionStatusText(row) }}
            </template>
          </el-table-column>
          <el-table-column label="申请时间" min-width="160">
            <template #default="{ row }">
              {{ formatDateTime(row.createdOn) }}
            </template>
          </el-table-column>
          <el-table-column prop="remark" label="备注" min-width="120" show-overflow-tooltip>
            <template #default="{ row }">
              {{ row.remark || '—' }}
            </template>
          </el-table-column>
        </el-table>

        <AppEmpty
          v-if="!extensionsLoading && !extensionsState.error && extensionsState.loaded && extensionsState.records.length === 0"
          title="暂无延期记录"
        />

        <div v-if="extensionsState.total > 0" class="pager">
          <el-pagination
            background
            layout="total, sizes, prev, pager, next"
            :total="extensionsState.total"
            :current-page="extensionsState.page"
            :page-size="extensionsState.size"
            :page-sizes="[10, 20, 50, 100]"
            @current-change="handleExtensionsPageChange"
            @size-change="handleExtensionsSizeChange"
          />
        </div>
      </template>
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
