<script setup lang="ts">
import { computed, ref, watch } from 'vue'
import { useRouter } from 'vue-router'

import AppEmpty from '@/components/common/AppEmpty.vue'
import AppError from '@/components/common/AppError.vue'
import TreatRefundPreviewDialog from '@/components/refund/TreatRefundPreviewDialog.vue'
import TreatOrderDetailContent from '@/components/sale/TreatOrderDetailContent.vue'
import TreatOrderHandlersDialog from '@/components/sale/TreatOrderHandlersDialog.vue'
import { cancelTreatOrder, fetchTreatOrderDetail } from '@/api/treat'
import {
  formatTreatBillStatus,
  TreatPermission,
  type TreatOrderDetail,
} from '@/types/treat'
import { RefundPermission } from '@/types/refund'
import { usePermissionStore } from '@/stores/permission'
import {
  formatDateTime,
  formatMoney,
} from '@/views/customer/customer-format'
import {
  getUserFriendlyErrorMessage,
  runExclusive,
  uiConfirm,
  uiMessage,
} from '@/utils/ui'

defineOptions({ name: 'TreatOrderDetailDialog' })

const visible = defineModel<boolean>({ default: false })

const props = defineProps<{
  orderId: string | null
}>()

const emit = defineEmits<{
  changed: []
}>()

const router = useRouter()
const permissionStore = usePermissionStore()

const loading = ref(false)
const actionLoading = ref(false)
const loadError = ref<string | null>(null)
const detail = ref<TreatOrderDetail | null>(null)
const handlersVisible = ref(false)
const refundVisible = ref(false)
const activeTab = ref('detail')

const canCancel = computed(() => permissionStore.hasPermission(TreatPermission.ORDER_CANCEL))
const canRefund = computed(() => permissionStore.hasPermission(RefundPermission.ORDER_CREATE))
const canEditHandler = computed(() =>
  permissionStore.hasPermission(TreatPermission.ORDER_EDIT_HANDLER),
)

const statusLabel = computed(() => formatTreatBillStatus(detail.value?.billStatus))
const isCancelled = computed(() => statusLabel.value === '已取消')
const isCompleted = computed(() => statusLabel.value === '已完成')
const isRefundApplying = computed(() => statusLabel.value === '退款申请中')
const isRefunded = computed(() => statusLabel.value === '已退款')

const showCancel = computed(() => {
  if (!canCancel.value || !detail.value) {
    return false
  }
  return isCompleted.value
})

/** R2：仅已完成可申请整单消耗退款 */
const showApplyRefund = computed(() => {
  if (!canRefund.value || !detail.value) {
    return false
  }
  return isCompleted.value
})

const showEditHandler = computed(() => {
  if (!canEditHandler.value || !detail.value) {
    return false
  }
  return isCompleted.value && !isRefundApplying.value && !isRefunded.value && !isCancelled.value
})

const signatures = computed(() => detail.value?.signatures ?? [])
const consumables = computed(() => detail.value?.consumables ?? [])

function resetState(): void {
  detail.value = null
  loadError.value = null
  handlersVisible.value = false
  refundVisible.value = false
  activeTab.value = 'detail'
}

async function loadDetail(): Promise<void> {
  if (props.orderId == null || props.orderId === '') {
    loadError.value = '订单编号无效'
    detail.value = null
    return
  }
  await runExclusive(loading, async () => {
    loadError.value = null
    try {
      detail.value = await fetchTreatOrderDetail(props.orderId!)
    } catch (error) {
      detail.value = null
      loadError.value = getUserFriendlyErrorMessage(error)
    }
  })
}

async function onCancelOrder(): Promise<void> {
  const order = detail.value
  if (!order?.id) {
    return
  }
  const ok = await uiConfirm({
    title: '取消订单',
    message: '确认取消该消耗订单？将按现有消耗取消规则回滚权益，不产生退款。',
    confirmText: '确认取消',
  })
  if (!ok) {
    return
  }
  await runExclusive(actionLoading, async () => {
    try {
      detail.value = await cancelTreatOrder(order.id, '取消订单')
      uiMessage.success('消耗订单已取消')
      emit('changed')
    } catch (error) {
      uiMessage.error(getUserFriendlyErrorMessage(error))
    }
  })
}

function onApplyRefund(): void {
  refundVisible.value = true
}

function onRefundSuccess(): void {
  void loadDetail()
  emit('changed')
}

function onOpenHandlers(): void {
  handlersVisible.value = true
}

function onHandlersSaved(order: TreatOrderDetail): void {
  detail.value = order
  emit('changed')
}

function onJumpCustomer(): void {
  const order = detail.value
  if (order?.customerId == null) {
    uiMessage.warning('无关联客户')
    return
  }
  const keyword =
    order.customerCode?.trim() ||
    order.customerMobile?.trim() ||
    order.customerName?.trim() ||
    String(order.customerId)
  void router.push({
    name: 'customer-list',
    query: { keyword },
  })
}

function onJumpSourceSale(billId: string | null | undefined): void {
  if (!billId) {
    return
  }
  void router.push({
    name: 'sale-orders',
    query: { detail: billId },
  })
}

const firstSourceSaleId = computed(() => {
  const items = detail.value?.items ?? []
  for (const item of items) {
    if (item.sourceSaleBillId) {
      return item.sourceSaleBillId
    }
  }
  return null
})

watch(visible, (open) => {
  if (!open) {
    resetState()
    return
  }
  resetState()
  void loadDetail()
})
</script>

<template>
  <el-dialog
    v-model="visible"
    class="treat-order-detail-dialog"
    title="消耗订单详情"
    width="860px"
    append-to-body
    destroy-on-close
    :close-on-click-modal="false"
  >
    <template #header="{ titleId, titleClass }">
      <div class="dialog-header">
        <span :id="titleId" :class="titleClass">消耗订单详情</span>
        <div class="header-actions">
          <el-button
            size="small"
            :disabled="loading || actionLoading || !detail?.customerId"
            @click="onJumpCustomer"
          >
            客户档案
          </el-button>
          <el-button
            v-if="firstSourceSaleId"
            size="small"
            :disabled="loading || actionLoading"
            @click="onJumpSourceSale(firstSourceSaleId)"
          >
            来源销售单
          </el-button>
          <el-button
            v-if="showCancel"
            size="small"
            type="danger"
            plain
            :loading="actionLoading"
            :disabled="loading"
            @click="onCancelOrder"
          >
            取消订单
          </el-button>
          <el-button
            v-if="showApplyRefund"
            size="small"
            type="warning"
            plain
            :disabled="loading || actionLoading"
            @click="onApplyRefund"
          >
            申请退款
          </el-button>
          <el-button
            v-if="showEditHandler"
            size="small"
            :disabled="loading || actionLoading"
            @click="onOpenHandlers"
          >
            修改经手人
          </el-button>
        </div>
      </div>
    </template>

    <AppError
      v-if="loadError && !loading"
      :description="loadError"
      @retry="loadDetail"
    />
    <div v-else v-loading="loading || actionLoading" class="detail-body">
      <template v-if="detail">
        <el-tabs v-model="activeTab">
          <el-tab-pane label="消耗单详情" name="detail">
            <TreatOrderDetailContent :detail="detail" />
          </el-tab-pane>
          <el-tab-pane label="客户签字" name="signature">
            <AppEmpty
              v-if="!signatures.length"
              title="暂无签字记录"
            />
            <el-table
              v-else
              :data="signatures"
              border
              stripe
              size="small"
            >
              <el-table-column label="签字时间" min-width="160">
                <template #default="{ row }">
                  {{ formatDateTime(row.createdOn) }}
                </template>
              </el-table-column>
              <el-table-column label="图片" min-width="200" show-overflow-tooltip>
                <template #default="{ row }">
                  <a
                    v-if="row.imageUrl"
                    :href="row.imageUrl"
                    target="_blank"
                    rel="noopener noreferrer"
                  >
                    查看签字
                  </a>
                  <span v-else>—</span>
                </template>
              </el-table-column>
            </el-table>
            <p class="tab-hint">签字由手机端完成；本页仅只读预览，不开发签字流程。</p>
          </el-tab-pane>
          <el-tab-pane label="耗材详情" name="consumable">
            <AppEmpty
              v-if="!consumables.length"
              title="暂无耗材记录"
            />
            <el-table
              v-else
              :data="consumables"
              border
              stripe
              size="small"
            >
              <el-table-column label="项目" min-width="140" show-overflow-tooltip>
                <template #default="{ row }">
                  {{ row.projectName || '—' }}
                </template>
              </el-table-column>
              <el-table-column label="耗材" min-width="140" show-overflow-tooltip>
                <template #default="{ row }">
                  {{ row.productName || '—' }}
                </template>
              </el-table-column>
              <el-table-column label="数量" width="90" align="right">
                <template #default="{ row }">
                  {{ row.quantity != null ? row.quantity : '—' }}
                </template>
              </el-table-column>
              <el-table-column label="已扣库存" width="100" align="center">
                <template #default="{ row }">
                  {{ row.deducted === true ? '是' : '否' }}
                </template>
              </el-table-column>
            </el-table>
            <p class="tab-hint">本阶段只读展示预留数据，不接库存扣减与出库逻辑。</p>
          </el-tab-pane>
        </el-tabs>
        <p v-if="isCompleted" class="status-hint">
          本单状态：已完成 · 消耗金额 {{ formatMoney(detail.amount) }}
        </p>
      </template>
      <AppEmpty v-else-if="!loading" title="暂无订单详情" />
    </div>

    <TreatOrderHandlersDialog
      v-model="handlersVisible"
      :detail="detail"
      @saved="onHandlersSaved"
    />
    <TreatRefundPreviewDialog
      v-model="refundVisible"
      :order-id="detail?.id ?? props.orderId"
      @success="onRefundSuccess"
    />
  </el-dialog>
</template>

<style scoped>
.dialog-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 12px;
  width: 100%;
  padding-right: 4px;
}

.header-actions {
  display: flex;
  align-items: center;
  gap: 8px;
  flex-shrink: 0;
  margin-right: 28px;
  flex-wrap: wrap;
  justify-content: flex-end;
}

.detail-body {
  min-height: 200px;
}

.tab-hint,
.status-hint {
  margin: 10px 0 0;
  color: #909399;
  font-size: 12px;
  line-height: 1.5;
}
</style>
