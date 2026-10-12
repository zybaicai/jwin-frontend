<script setup lang="ts">
import { computed, ref, watch } from 'vue'

import AppEmpty from '@/components/common/AppEmpty.vue'
import AppError from '@/components/common/AppError.vue'
import SaleOrderDetailContent from '@/components/sale/SaleOrderDetailContent.vue'
import SaleOrderHandlersDialog from '@/components/sale/SaleOrderHandlersDialog.vue'
import { closeSaleOrder, createSaleRefund, fetchSaleOrderDetail } from '@/api/sale'
import {
  RefundPermission,
  SalePermission,
  type SaleOrderDetail,
} from '@/types/sale'
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

const canClose = computed(() => permissionStore.hasPermission(SalePermission.ORDER_CLOSE))
const canRefund = computed(() => permissionStore.hasPermission(RefundPermission.ORDER_CREATE))
const canEditHandler = computed(() =>
  permissionStore.hasPermission(SalePermission.ORDER_EDIT_HANDLER),
)

const status = computed(() => detail.value?.billStatus ?? '')
const unpaid = computed(() => status.value === '草稿' || status.value === '待支付')
const paid = computed(() => status.value === '已支付')
const showCancel = computed(() => {
  if (unpaid.value) {
    return canClose.value
  }
  if (paid.value) {
    return canRefund.value
  }
  return false
})
const showEditHandler = computed(() => {
  if (!canEditHandler.value || !detail.value) {
    return false
  }
  return status.value !== '已关闭' && status.value !== '已退款'
})

function resetState(): void {
  detail.value = null
  loadError.value = null
  handlersVisible.value = false
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
  if (!order?.id) {
    return
  }
  if (paid.value && order.hasConsumedAssets) {
    uiMessage.warning('卡项已产生消耗，无法取消')
    return
  }
  const ok = await uiConfirm({
    title: '取消订单',
    message: unpaid.value
      ? '确认取消该未支付订单？取消后订单将关闭。'
      : '确认取消该已支付订单？将提交销售退款申请（需审批后执行入账冲回）。',
    confirmText: '确认取消',
  })
  if (!ok) {
    return
  }
  await runExclusive(actionLoading, async () => {
    try {
      if (unpaid.value) {
        detail.value = await closeSaleOrder(order.id)
        uiMessage.success('订单已取消（关闭）')
      } else {
        // 再次以服务端详情为准，避免列表缓存导致误提交退款
        const latest = await fetchSaleOrderDetail(order.id)
        if (latest.hasConsumedAssets) {
          detail.value = latest
          uiMessage.warning('卡项已产生消耗，无法取消')
          return
        }
        await createSaleRefund({ sourceOrderId: order.id, reason: '取消订单' })
        detail.value = await fetchSaleOrderDetail(order.id)
        uiMessage.success('已提交退款申请，请在退款审批通过后执行')
      }
      emit('changed')
    } catch (error) {
      uiMessage.error(getUserFriendlyErrorMessage(error))
    }
  })
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
