<script setup lang="ts">
import { computed, ref, watch } from 'vue'

import CashierHandlerEditor, {
  type HandlerDraftRow,
} from '@/components/sale/CashierHandlerEditor.vue'
import { updateTreatOrderHandlers } from '@/api/treat'
import { HandlerTreatBizTypes } from '@/types/handler'
import type { TreatOrderDetail, TreatOrderItem } from '@/types/treat'
import { getUserFriendlyErrorMessage, runExclusive, uiMessage } from '@/utils/ui'

defineOptions({ name: 'TreatOrderHandlersDialog' })

const visible = defineModel<boolean>({ default: false })

const props = defineProps<{
  detail: TreatOrderDetail | null
}>()

const emit = defineEmits<{
  saved: [order: TreatOrderDetail]
}>()

const submitting = ref(false)
const handlers = ref<HandlerDraftRow[]>([])
const editorRef = ref<InstanceType<typeof CashierHandlerEditor> | null>(null)

const storeId = computed(() => props.detail?.storeId ?? null)

const bizType = computed(() => {
  const items = props.detail?.items ?? []
  for (const item of items) {
    const t = resolveTreatBizType(item)
    if (t) {
      return t
    }
  }
  return HandlerTreatBizTypes.PROJECT_TREAT
})

const lineSummary = computed(() => {
  const items = (props.detail?.items ?? []).filter((i) => i.itemType && i.itemType !== '')
  if (!items.length) {
    return '本单无可改经手人的消耗明细'
  }
  return items
    .map((i) => i.projectName || i.itemName || i.itemType || '—')
    .filter(Boolean)
    .slice(0, 6)
    .join('、')
})

function resolveTreatBizType(item: TreatOrderItem): string | null {
  switch (item.itemType) {
    case 'PROJECT':
      return HandlerTreatBizTypes.PROJECT_TREAT
    case 'GENERAL_CARD':
      return HandlerTreatBizTypes.GENERAL_TREAT
    case 'TIME_CARD':
      return HandlerTreatBizTypes.TIME_TREAT
    case 'SAVING_CARD':
      return HandlerTreatBizTypes.SAVING_TREAT
    default:
      return null
  }
}

function scaleToRatio(scale: number | string | null | undefined): number | null {
  if (scale == null || scale === '') {
    return null
  }
  const n = Number(scale)
  if (!Number.isFinite(n)) {
    return null
  }
  return Math.round(n * 10000) / 100
}

function syncFromDetail(): void {
  const list = props.detail?.handlers ?? []
  handlers.value = list
    .filter((h) => h.employeeId)
    .map((h) => ({
      employeeId: String(h.employeeId),
      employeeName: h.employeeName?.trim() || String(h.employeeId),
      ratio:
        h.ratio != null && h.ratio !== ''
          ? Number(h.ratio)
          : scaleToRatio(h.scale),
    }))
}

watch(visible, (open) => {
  if (open) {
    syncFromDetail()
  }
})

async function onConfirm(): Promise<void> {
  const orderId = props.detail?.id
  if (!orderId) {
    uiMessage.warning('订单无效')
    return
  }
  if (!handlers.value.length) {
    uiMessage.warning('请至少选择一名经手人')
    return
  }
  if (editorRef.value && !editorRef.value.ratioValid) {
    uiMessage.warning('经手人比例合计须为 100%')
    return
  }
  await runExclusive(submitting, async () => {
    try {
      const updated = await updateTreatOrderHandlers(
        orderId,
        handlers.value.map((h) => ({
          employeeId: h.employeeId,
          ratio: h.ratio,
        })),
      )
      uiMessage.success('经手人已更新')
      visible.value = false
      emit('saved', updated)
    } catch (error) {
      uiMessage.error(getUserFriendlyErrorMessage(error))
    }
  })
}
</script>

<template>
  <el-dialog
    v-model="visible"
    title="修改经手人"
    width="520px"
    append-to-body
    destroy-on-close
    :close-on-click-modal="false"
  >
    <p class="scope-hint">仅调整本单消耗经手人（不计算提成）：{{ lineSummary }}</p>
    <CashierHandlerEditor
      ref="editorRef"
      v-model="handlers"
      :biz-type="bizType"
      :store-id="storeId"
      :disabled="submitting"
    />
    <template #footer>
      <el-button :disabled="submitting" @click="visible = false">取消</el-button>
      <el-button type="primary" :loading="submitting" @click="onConfirm">保存</el-button>
    </template>
  </el-dialog>
</template>

<style scoped>
.scope-hint {
  margin: 0 0 12px;
  font-size: 12px;
  color: #909399;
  line-height: 1.4;
}
</style>
