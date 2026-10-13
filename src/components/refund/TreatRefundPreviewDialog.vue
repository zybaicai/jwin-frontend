<script setup lang="ts">
import { computed, ref, watch } from 'vue'

import { createRefund, previewRefund } from '@/api/refund'
import type { RefundPreview } from '@/types/refund'
import {
  getUserFriendlyErrorMessage,
  runExclusive,
  uiMessage,
} from '@/utils/ui'
import { formatDateTime, formatMoney } from '@/views/customer/customer-format'

defineOptions({ name: 'TreatRefundPreviewDialog' })

const visible = defineModel<boolean>({ default: false })

const props = defineProps<{
  orderId: string | null
}>()

const emit = defineEmits<{
  success: []
}>()

const loading = ref(false)
const submitting = ref(false)
const preview = ref<RefundPreview | null>(null)
const reason = ref('')

const lines = computed(() => preview.value?.lines ?? [])
const totalAmount = computed(() => Number(preview.value?.saleAmount ?? 0))

watch(visible, (open) => {
  if (!open) {
    reset()
    return
  }
  reset()
  void loadPreview()
})

function reset(): void {
  preview.value = null
  reason.value = ''
}

async function loadPreview(): Promise<void> {
  if (!props.orderId) {
    return
  }
  await runExclusive(loading, async () => {
    try {
      preview.value = await previewRefund({
        refundType: 'TREAT',
        sourceOrderId: props.orderId!,
      })
    } catch (error) {
      preview.value = null
      uiMessage.error(getUserFriendlyErrorMessage(error))
    }
  })
}

async function onSubmit(): Promise<void> {
  if (!props.orderId || !preview.value) {
    return
  }
  if (!lines.value.length) {
    uiMessage.warning('该消耗单无明细，不可退款')
    return
  }
  await runExclusive(submitting, async () => {
    try {
      await createRefund({
        refundType: 'TREAT',
        sourceOrderId: props.orderId!,
        reason: reason.value.trim() || '申请消耗退款',
      })
      uiMessage.success('已提交消耗退款申请，审批通过后将自动恢复权益')
      visible.value = false
      emit('success')
    } catch (error) {
      uiMessage.error(getUserFriendlyErrorMessage(error))
    }
  })
}
</script>

<template>
  <el-dialog
    v-model="visible"
    title="消耗退款预览"
    width="920px"
    append-to-body
    destroy-on-close
    :close-on-click-modal="false"
  >
    <div v-loading="loading" class="preview-body">
      <section v-if="preview" class="section">
        <h4>原消耗订单</h4>
        <div class="meta">
          <div>消耗订单：{{ preview.sourceOrderId }}</div>
          <div>客户：{{ preview.customerName || preview.customerId || '—' }}</div>
          <div>消耗时间：{{ formatDateTime(preview.saleTime) }}</div>
          <div>消耗金额：{{ formatMoney(preview.saleAmount) }}</div>
        </div>
        <el-alert
          type="warning"
          :closable="false"
          show-icon
          title="消耗退款仅支持整单；审批通过后自动恢复权益，不产生销售/业绩/提成，不处理库存。"
        />
      </section>

      <section class="section">
        <el-form label-width="100px" class="form">
          <el-form-item label="退款原因">
            <el-input
              v-model="reason"
              type="textarea"
              :rows="2"
              maxlength="200"
              show-word-limit
              placeholder="选填，如：消耗客户选择错误 / 重复消耗"
            />
          </el-form-item>
        </el-form>
      </section>

      <section class="section">
        <h4>将恢复的权益（整单）</h4>
        <el-table :data="lines" border size="small" empty-text="无消耗明细">
          <el-table-column label="类型" width="80">
            <template #default="{ row }">
              {{ row.accountTypeName || row.accountType }}
            </template>
          </el-table-column>
          <el-table-column label="名称" min-width="140" show-overflow-tooltip>
            <template #default="{ row }">
              {{ row.itemName || row.itemId || '—' }}
            </template>
          </el-table-column>
          <el-table-column label="持有人" min-width="110" show-overflow-tooltip>
            <template #default="{ row }">
              {{ row.holderCustomerName || row.holderCustomerId || '—' }}
            </template>
          </el-table-column>
          <el-table-column label="恢复数量" width="90" align="right">
            <template #default="{ row }">
              {{ row.maxRefundableQty ?? row.consumedQty ?? '—' }}
            </template>
          </el-table-column>
          <el-table-column label="金额" width="100" align="right">
            <template #default="{ row }">
              {{ formatMoney(row.originalAmount) }}
            </template>
          </el-table-column>
          <el-table-column label="本金/赠送" min-width="140" align="right">
            <template #default="{ row }">
              <template v-if="row.accountType === 'SAVING_CARD'">
                本金 {{ formatMoney(row.principalAmount) }} /
                赠送 {{ formatMoney(row.bonusAmount) }}
              </template>
              <span v-else>—</span>
            </template>
          </el-table-column>
          <el-table-column label="有效期（保持）" min-width="160">
            <template #default="{ row }">
              <template v-if="row.accountType === 'TIME_CARD'">
                {{ row.validDate ? formatDateTime(row.validDate) : '—' }}
              </template>
              <span v-else>—</span>
            </template>
          </el-table-column>
        </el-table>
        <div class="sum">
          整单金额：
          <strong>{{ formatMoney(totalAmount) }}</strong>
        </div>
        <p v-if="preview?.consumableHint" class="hint">
          {{ preview.consumableHint }}
        </p>
      </section>
    </div>

    <template #footer>
      <el-button :disabled="submitting" @click="visible = false">取消</el-button>
      <el-button
        type="primary"
        :loading="submitting"
        :disabled="loading || !lines.length"
        @click="onSubmit"
      >
        提交退款申请
      </el-button>
    </template>
  </el-dialog>
</template>

<style scoped>
.preview-body {
  min-height: 200px;
}
.section {
  margin-bottom: 16px;
}
.section h4 {
  margin: 0 0 8px;
  font-size: 14px;
}
.meta {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 6px 16px;
  margin-bottom: 12px;
  font-size: 13px;
  color: var(--el-text-color-regular);
}
.form {
  max-width: 640px;
}
.sum {
  margin-top: 10px;
  text-align: right;
  font-size: 13px;
}
.hint {
  margin: 8px 0 0;
  font-size: 12px;
  color: var(--el-text-color-secondary);
}
</style>
