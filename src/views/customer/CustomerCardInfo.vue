<script setup lang="ts">
import { computed, reactive, ref, watch } from 'vue'

import AppEmpty from '@/components/common/AppEmpty.vue'
import AppError from '@/components/common/AppError.vue'
import PostponeApplyDialog from '@/components/customer/PostponeApplyDialog.vue'
import TransferApplyDialog from '@/components/customer/TransferApplyDialog.vue'
import { fetchCustomerCards } from '@/api/customer'
import type { CustomerCardItem, CustomerCardItemType } from '@/types/customer'
import { PostponePermission, TransferPermission } from '@/types/asset-ops'
import { usePermissionStore } from '@/stores/permission'
import { getUserFriendlyErrorMessage, runExclusive } from '@/utils/ui'
import {
  formatCardBalance,
  formatDateTime,
  formatMoney,
} from '@/views/customer/customer-format'

defineOptions({ name: 'CustomerCardInfo' })

const props = defineProps<{
  customerId: number
  customerName?: string | null
}>()

const permissionStore = usePermissionStore()
const canPostpone = computed(() =>
  permissionStore.hasPermission(PostponePermission.ORDER_CREATE),
)
const canTransfer = computed(() =>
  permissionStore.hasPermission(TransferPermission.ORDER_CREATE),
)
const postponeVisible = ref(false)
const postponeAccount = ref<CustomerCardItem | null>(null)
const postponeAccountType = ref<CustomerCardItemType | null>(null)
const transferVisible = ref(false)
const transferAccount = ref<CustomerCardItem | null>(null)
const transferAccountType = ref<CustomerCardItemType | null>(null)

const POSTPONE_TYPES = new Set<CustomerCardItemType>([
  'GENERAL_CARD',
  'TIME_CARD',
  'SAVING_CARD',
  'PACKAGE_CARD',
  'PROJECT',
])

const TRANSFER_TYPES = new Set<CustomerCardItemType>([
  'GENERAL_CARD',
  'TIME_CARD',
  'SAVING_CARD',
  'PACKAGE_CARD',
  'PROJECT',
])

function canPostponeRow(type: CustomerCardItemType): boolean {
  return canPostpone.value && POSTPONE_TYPES.has(type)
}

function canTransferRow(type: CustomerCardItemType): boolean {
  return canTransfer.value && TRANSFER_TYPES.has(type)
}

const showOpsColumn = computed(
  () => canPostponeRow(activeType.value) || canTransferRow(activeType.value),
)

function openPostpone(row: CustomerCardItem): void {
  postponeAccount.value = row
  postponeAccountType.value = activeType.value
  postponeVisible.value = true
}

function openTransfer(row: CustomerCardItem): void {
  transferAccount.value = row
  transferAccountType.value = activeType.value
  transferVisible.value = true
}

function isOpsDisabled(row: CustomerCardItem): boolean {
  return (
    row.displayStatus === 'POSTPONE_PENDING' ||
    row.displayStatus === 'TRANSFER_PENDING' ||
    row.displayStatus === 'REFUNDED'
  )
}

/** Prompt / 原系统顺序：产品 → 储值卡 → 套餐卡 → 时效卡 → 通用次卡 → 项目 */
const CARD_TABS: Array<{ type: CustomerCardItemType; label: string; emptyTitle: string }> = [
  { type: 'PRODUCT', label: '产品', emptyTitle: '暂无产品' },
  { type: 'SAVING_CARD', label: '储值卡', emptyTitle: '暂无储值卡' },
  { type: 'PACKAGE_CARD', label: '套餐卡', emptyTitle: '暂无套餐卡' },
  { type: 'TIME_CARD', label: '时效卡', emptyTitle: '暂无时效卡' },
  { type: 'GENERAL_CARD', label: '通用次卡', emptyTitle: '暂无通用次卡' },
  { type: 'PROJECT', label: '项目', emptyTitle: '暂无项目' },
]

interface CardPageState {
  page: number
  size: number
  total: number
  records: CustomerCardItem[]
  loaded: boolean
  error: string | null
}

function createEmptyState(): CardPageState {
  return {
    page: 1,
    size: 20,
    total: 0,
    records: [],
    loaded: false,
    error: null,
  }
}

const activeType = ref<CustomerCardItemType>('PRODUCT')
const loading = ref(false)
const cache = reactive<Record<CustomerCardItemType, CardPageState>>({
  PRODUCT: createEmptyState(),
  SAVING_CARD: createEmptyState(),
  PACKAGE_CARD: createEmptyState(),
  TIME_CARD: createEmptyState(),
  GENERAL_CARD: createEmptyState(),
  PROJECT: createEmptyState(),
})

const current = computed(() => cache[activeType.value])
const emptyTitle = computed(
  () => CARD_TABS.find((item) => item.type === activeType.value)?.emptyTitle ?? '暂无卡项',
)

const balanceColumnLabel = computed(() => {
  switch (activeType.value) {
    case 'SAVING_CARD':
      return '余额'
    case 'PACKAGE_CARD':
      return '剩余金额'
    case 'PRODUCT':
      return '剩余数量'
    default:
      return '剩余次数'
  }
})

const showPriceColumns = computed(() => {
  return (
    activeType.value === 'SAVING_CARD' ||
    activeType.value === 'PACKAGE_CARD' ||
    activeType.value === 'PRODUCT' ||
    activeType.value === 'TIME_CARD' ||
    activeType.value === 'GENERAL_CARD' ||
    activeType.value === 'PROJECT'
  )
})

async function loadType(type: CustomerCardItemType, force = false): Promise<void> {
  const state = cache[type]
  if (!force && state.loaded) {
    return
  }
  await runExclusive(loading, async () => {
    state.error = null
    try {
      const data = await fetchCustomerCards(props.customerId, {
        itemType: type,
        page: state.page,
        size: state.size,
      })
      state.records = data.records ?? []
      state.total = data.total ?? 0
      state.page = data.page || state.page
      state.size = data.size || state.size
      state.loaded = true
    } catch (error) {
      state.records = []
      state.total = 0
      state.loaded = false
      state.error = getUserFriendlyErrorMessage(error)
    }
  })
}

function handleTypeChange(name: string | number): void {
  const type = String(name) as CustomerCardItemType
  activeType.value = type
  void loadType(type)
}

async function handlePageChange(page: number): Promise<void> {
  const state = cache[activeType.value]
  state.page = page
  state.loaded = false
  await loadType(activeType.value, true)
}

async function handleSizeChange(size: number): Promise<void> {
  const state = cache[activeType.value]
  state.size = size
  state.page = 1
  state.loaded = false
  await loadType(activeType.value, true)
}

async function reloadCurrent(): Promise<void> {
  await loadType(activeType.value, true)
}

function resetAll(): void {
  activeType.value = 'PRODUCT'
  for (const tab of CARD_TABS) {
    cache[tab.type] = createEmptyState()
  }
}

watch(
  () => props.customerId,
  () => {
    resetAll()
    void loadType('PRODUCT', true)
  },
  { immediate: true },
)

defineExpose({
  reloadCurrent,
  loading,
})
</script>

<template>
  <div class="customer-card-info">
    <el-tabs
      v-model="activeType"
      type="card"
      class="card-type-tabs"
      @tab-change="handleTypeChange"
    >
      <el-tab-pane
        v-for="tab in CARD_TABS"
        :key="tab.type"
        :label="tab.label"
        :name="tab.type"
      />
    </el-tabs>

    <div class="card-content" v-loading="loading">
      <AppError
        v-if="current.error && !loading"
        :description="current.error"
        @retry="reloadCurrent"
      />
      <template v-else>
        <el-table
          :data="current.records"
          border
          stripe
          size="small"
          empty-text=" "
        >
          <el-table-column prop="name" label="名称" min-width="140" show-overflow-tooltip />
          <el-table-column prop="storeName" label="开卡门店" min-width="120" show-overflow-tooltip>
            <template #default="{ row }">
              {{ row.storeName || '—' }}
            </template>
          </el-table-column>
          <el-table-column label="开单时间" min-width="160">
            <template #default="{ row }">
              {{ formatDateTime(row.buyDate) }}
            </template>
          </el-table-column>
          <el-table-column v-if="showPriceColumns" label="卡售价" min-width="100" align="right">
            <template #default="{ row }">
              {{ formatMoney(row.price) }}
            </template>
          </el-table-column>
          <el-table-column v-if="showPriceColumns" label="实付" min-width="100" align="right">
            <template #default="{ row }">
              {{ formatMoney(row.payAmount) }}
            </template>
          </el-table-column>
          <el-table-column
            v-if="activeType === 'SAVING_CARD'"
            label="卡扣"
            min-width="100"
            align="right"
          >
            <template #default="{ row }">
              {{ formatMoney(row.cardDeductionAmount) }}
            </template>
          </el-table-column>
          <el-table-column :label="balanceColumnLabel" min-width="110" align="right">
            <template #default="{ row }">
              {{ formatCardBalance(activeType, row.balance) }}
            </template>
          </el-table-column>
          <el-table-column label="有效金额" min-width="110" align="right">
            <template #default="{ row }">
              {{ formatMoney(row.balanceAmount) }}
            </template>
          </el-table-column>
          <el-table-column label="有效期" min-width="160">
            <template #default="{ row }">
              {{ formatDateTime(row.validDate) }}
            </template>
          </el-table-column>
          <el-table-column prop="source" label="来源" min-width="90" show-overflow-tooltip>
            <template #default="{ row }">
              {{ row.source || '—' }}
            </template>
          </el-table-column>
          <el-table-column label="赠送" width="70" align="center">
            <template #default="{ row }">
              <el-tag v-if="row.largess === true" size="small" type="warning">赠送</el-tag>
              <span v-else>—</span>
            </template>
          </el-table-column>
          <el-table-column label="状态" min-width="110">
            <template #default="{ row }">
              <el-tag
                v-if="row.displayStatus === 'POSTPONE_PENDING'"
                size="small"
                type="warning"
              >
                {{ row.displayStatusName || '延期申请中' }}
              </el-tag>
              <el-tag
                v-else-if="row.displayStatus === 'TRANSFER_PENDING'"
                size="small"
                type="warning"
              >
                {{ row.displayStatusName || '转账冻结中' }}
              </el-tag>
              <el-tag
                v-else-if="row.displayStatus === 'EXPIRED'"
                size="small"
                type="info"
              >
                {{ row.displayStatusName || '已过期' }}
              </el-tag>
              <el-tag
                v-else-if="row.displayStatus === 'REFUNDED'"
                size="small"
                type="danger"
              >
                {{ row.displayStatusName || '已退款' }}
              </el-tag>
              <span v-else>{{ row.displayStatusName || '正常' }}</span>
            </template>
          </el-table-column>
          <el-table-column
            v-if="showOpsColumn"
            label="操作"
            :width="canPostponeRow(activeType) && canTransferRow(activeType) ? 168 : 100"
            fixed="right"
          >
            <template #default="{ row }">
              <el-button
                v-if="canPostponeRow(activeType)"
                v-permission="PostponePermission.ORDER_CREATE"
                link
                type="primary"
                :disabled="isOpsDisabled(row as CustomerCardItem)"
                @click="openPostpone(row as CustomerCardItem)"
              >
                申请延期
              </el-button>
              <el-button
                v-if="canTransferRow(activeType)"
                v-permission="TransferPermission.ORDER_CREATE"
                link
                type="primary"
                :disabled="isOpsDisabled(row as CustomerCardItem)"
                @click="openTransfer(row as CustomerCardItem)"
              >
                权益转账
              </el-button>
            </template>
          </el-table-column>
        </el-table>

        <AppEmpty
          v-if="!loading && !current.error && current.loaded && current.records.length === 0"
          :title="emptyTitle"
        />

        <div v-if="current.total > 0" class="pager">
          <el-pagination
            background
            layout="total, sizes, prev, pager, next"
            :total="current.total"
            :current-page="current.page"
            :page-size="current.size"
            :page-sizes="[10, 20, 50, 100]"
            @current-change="handlePageChange"
            @size-change="handleSizeChange"
          />
        </div>
      </template>
    </div>

    <PostponeApplyDialog
      v-model="postponeVisible"
      :customer-id="customerId"
      :customer-name="customerName"
      :account="postponeAccount"
      :account-type="postponeAccountType"
      @success="reloadCurrent"
    />
    <TransferApplyDialog
      v-model="transferVisible"
      :customer-id="customerId"
      :customer-name="customerName"
      :account="transferAccount"
      :account-type="transferAccountType"
      @success="reloadCurrent"
    />
  </div>
</template>

<style scoped>
.customer-card-info {
  min-height: 200px;
}

.card-type-tabs {
  margin-bottom: 8px;
}

.card-content {
  min-height: 180px;
}

.pager {
  display: flex;
  justify-content: flex-end;
  margin-top: 12px;
}
</style>
