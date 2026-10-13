<script setup lang="ts">
import { computed, ref, watch } from 'vue'

import AppEmpty from '@/components/common/AppEmpty.vue'
import AppError from '@/components/common/AppError.vue'
import SaleOrderDetailContent from '@/components/sale/SaleOrderDetailContent.vue'
import SaleOrderHandlersDialog from '@/components/sale/SaleOrderHandlersDialog.vue'
import SaleRefundPreviewDialog from '@/components/refund/SaleRefundPreviewDialog.vue'
import { closeSaleOrder, fetchSaleOrderDetail } from '@/api/sale'
import { SalePermission, type SaleOrderDetail } from '@/types/sale'
import { RefundPermission } from '@/types/refund'
import { usePermissionStore } from '@/stores/permission'
import {
  getUserFriendlyErrorMessage,
  runExclusive,
  uiConfirm,
  uiMessage,
} from '@/utils/ui'

defineOptions({ name: 'SaleOrderDetailDialog' })

const visible = defineModel<boolean>({ default: false })

const props = defineProps<{
  orderId: string | null
}>()

const emit = defineEmits<{
  changed: []
}>()

const permissionStore = usePermissionStore()

const loading = ref(false)
const actionLoading = ref(false)
const loadError = ref<string | null>(null)
const detail = ref<SaleOrderDetail | null>(null)
const handlersVisible = ref(false)
const refundPreviewVisible = ref(false)

const canClose = computed(() => permissionStore.hasPermission(SalePermission.ORDER_CLOSE))
const canRefund = computed(() => permissionStore.hasPermission(RefundPermission.ORDER_CREATE))
const canEditHandler = computed(() =>
  permissionStore.hasPermission(SalePermission.ORDER_EDIT_HANDLER),
)

const status = computed(() => detail.value?.billStatus ?? '')
const unpaid = computed(() => status.value === '草稿' || status.value === '待支付')
const refundableStatus = computed(
  () =>
    status.value === '已支付' ||
    status.value === '已完成' ||
    status.value === '部分退款',
)
/** 未支付：取消订单（关单） */
const showCancel = computed(() => unpaid.value && canClose.value)
/** 已支付/部分退款：申请退款（预览勾选） */
const showApplyRefund = computed(() => refundableStatus.value && canRefund.value)
const showEditHandler = computed(() => {
  if (!canEditHandler.value || !detail.value) {
    return false
  }
  return (
    status.value !== '已关闭' &&
    status.value !== '已取消' &&
    status.value !== '已退款' &&
    status.value !== '退款申请中'
  )
})

function resetState(): void {
  detail.value = null
  loadError.value = null
  handlersVisible.value = false
  refundPreviewVisible.value = false
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
      detail.value = await fetchSaleOrderDetail(props.orderId!)
    } catch (error) {
      detail.value = null
      loadError.value = getUserFriendlyErrorMessage(error)
    }
  })
}

async function onCancelOrder(): Promise<void> {
  const order = detail.value
  if (!order?.id || !unpaid.value) {
    return
  }
  const ok = await uiConfirm({
    title: '取消订单',
    message: '确认取消该未支付订单？取消后订单将关闭。',
    confirmText: '确认取消',
  })
  if (!ok) {
    return
  }
  await runExclusive(actionLoading, async () => {
    try {
      detail.value = await closeSaleOrder(order.id)
      uiMessage.success('订单已取消（关闭）')
      emit('changed')
    } catch (error) {
      uiMessage.error(getUserFriendlyErrorMessage(error))
    }
  })
}

function onApplyRefund(): void {
  if (!detail.value?.id || !refundableStatus.value) {
    return
  }
  refundPreviewVisible.value = true
}

async function onRefundSubmitted(): Promise<void> {
  await loadDetail()
  emit('changed')
}

function onOpenHandlers(): void {
  handlersVisible.value = true
}

function onHandlersSaved(order: SaleOrderDetail): void {
  detail.value = order
  emit('changed')
}

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
    class="sale-order-detail-dialog"
    title="销售订单详情"
    width="820px"
    append-to-body
    destroy-on-close
    :close-on-click-modal="false"
  >
    <template #header="{ titleId, titleClass }">
      <div class="dialog-header">
        <span :id="titleId" :class="titleClass">销售订单详情</span>
        <div class="header-actions">
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
            :loading="actionLoading"
            :disabled="loading"
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
            修改经手人业绩提成
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
      <SaleOrderDetailContent v-if="detail" :detail="detail" />
      <AppEmpty v-else-if="!loading" title="暂无订单详情" />
    </div>

    <SaleOrderHandlersDialog
      v-model="handlersVisible"
      :detail="detail"
      @saved="onHandlersSaved"
    />

    <SaleRefundPreviewDialog
      v-model="refundPreviewVisible"
      :order-id="detail?.id ?? orderId"
      @success="onRefundSubmitted"
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
}

.detail-body {
  min-height: 160px;
}
</style>
