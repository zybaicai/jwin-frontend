<script setup lang="ts">
import { computed, reactive, ref, watch } from 'vue'

import { createRefund, previewRefund } from '@/api/refund'
import type { RefundPreview, RefundPreviewLine } from '@/types/refund'
import { RefundPermission } from '@/types/refund'
import { usePermissionStore } from '@/stores/permission'
import {
  getUserFriendlyErrorMessage,
  runExclusive,
  uiMessage,
} from '@/utils/ui'
import { formatDateTime, formatMoney } from '@/views/customer/customer-format'

defineOptions({ name: 'SaleRefundPreviewDialog' })

const visible = defineModel<boolean>({ default: false })

const props = defineProps<{
  orderId: string | null
}>()

const emit = defineEmits<{
  success: []
}>()

const permissionStore = usePermissionStore()
const loading = ref(false)
const submitting = ref(false)
const preview = ref<RefundPreview | null>(null)
const specialRefund = ref(false)
const reason = ref('')
const specialReason = ref('')
/** R3：当前选中的权益持有人；多持有人时必选 */
const holderCustomerId = ref<number | null>(null)
/** accountType:accountId -> 勾选数量 */
const selectedQty = reactive<Record<string, number>>({})
const checkedKeys = ref<string[]>([])

const canSpecial = computed(() => permissionStore.hasPermission(RefundPermission.SPECIAL))

const holders = computed(() => preview.value?.holders ?? [])
const transfers = computed(() => preview.value?.transfers ?? [])
const multiHolder = computed(() => holders.value.filter((h) => (h.selectableCount ?? 0) > 0).length > 1)
const lines = computed(() => {
  const all = preview.value?.lines ?? []
  if (holderCustomerId.value == null) {
    return all
  }
  return all.filter(
    (l) =>
      l.holderCustomerId === holderCustomerId.value ||
      (l.accountType === 'PACKAGE_CARD' &&
        preview.value?.customerId === holderCustomerId.value),
  )
})

const selectedAmount = computed(() => {
  let sum = 0
  for (const key of checkedKeys.value) {
    const line = lines.value.find((l) => lineKey(l) === key)
    if (!line) continue
    const qty = selectedQty[key] ?? line.maxRefundableQty ?? 0
    const unit = Number(line.unitPrice ?? 0)
    if (line.accountType === 'SAVING_CARD') {
      sum += Number(line.maxRefundableAmount ?? 0)
    } else {
      sum += unit * qty
    }
  }
  return Math.round(sum * 100) / 100
})

watch(visible, (open) => {
  if (!open) {
    reset()
    return
  }
  reset()
  void loadPreview()
})

watch(specialRefund, () => {
  if (visible.value) {
    void loadPreview()
  }
})

watch(holderCustomerId, () => {
  checkedKeys.value = []
  for (const k of Object.keys(selectedQty)) {
    delete selectedQty[k]
  }
  for (const line of lines.value) {
    if (line.selectable && line.accountId != null) {
      selectedQty[lineKey(line)] = line.maxRefundableQty ?? 0
    }
  }
})

function reset(): void {
  preview.value = null
  specialRefund.value = false
  reason.value = ''
  specialReason.value = ''
  holderCustomerId.value = null
  checkedKeys.value = []
  for (const k of Object.keys(selectedQty)) {
    delete selectedQty[k]
  }
}

function lineKey(line: RefundPreviewLine): string {
  return `${line.accountType}:${line.accountId}`
}

async function loadPreview(): Promise<void> {
  if (!props.orderId) {
    return
  }
  await runExclusive(loading, async () => {
    try {
      const data = await previewRefund({
        refundType: 'SALE',
        sourceOrderId: props.orderId!,
        specialRefund: specialRefund.value && canSpecial.value,
      })
      preview.value = data
      const selectableHolders = (data.holders ?? []).filter((h) => (h.selectableCount ?? 0) > 0)
      if (selectableHolders.length === 1 && selectableHolders[0].holderCustomerId != null) {
        holderCustomerId.value = selectableHolders[0].holderCustomerId
      } else if (
        holderCustomerId.value != null &&
        !selectableHolders.some((h) => h.holderCustomerId === holderCustomerId.value)
      ) {
        holderCustomerId.value = null
      }
      checkedKeys.value = []
      for (const k of Object.keys(selectedQty)) {
        delete selectedQty[k]
      }
      for (const line of data.lines ?? []) {
        if (line.selectable && line.accountId != null) {
          selectedQty[lineKey(line)] = line.maxRefundableQty ?? 0
        }
      }
    } catch (error) {
      preview.value = null
      uiMessage.error(getUserFriendlyErrorMessage(error))
    }
  })
}

function onToggleRow(line: RefundPreviewLine, checked: boolean): void {
  const key = lineKey(line)
  if (checked) {
    if (!checkedKeys.value.includes(key)) {
      checkedKeys.value = [...checkedKeys.value, key]
    }
    if (selectedQty[key] == null || selectedQty[key] <= 0) {
      selectedQty[key] = line.maxRefundableQty ?? 0
    }
  } else {
    checkedKeys.value = checkedKeys.value.filter((k) => k !== key)
  }
}

function isChecked(line: RefundPreviewLine): boolean {
  return checkedKeys.value.includes(lineKey(line))
}

async function onSubmit(): Promise<void> {
  if (!props.orderId || !preview.value) {
    return
  }
  if (multiHolder.value && holderCustomerId.value == null) {
    uiMessage.warning('该订单权益分属多个持有人，请先选择本次退款的持有人')
    return
  }
  if (checkedKeys.value.length === 0) {
    uiMessage.warning('请至少勾选一行可退明细')
    return
  }
  if (specialRefund.value) {
    if (!canSpecial.value) {
      uiMessage.error('无特殊退款权限')
      return
    }
    if (!specialReason.value.trim()) {
      uiMessage.warning('特殊退款必须填写原因')
      return
    }
  }
  const items = checkedKeys.value
    .map((key) => {
      const line = lines.value.find((l) => lineKey(l) === key)
      if (!line?.accountType || line.accountId == null) {
        return null
      }
      if (
        holderCustomerId.value != null &&
        line.holderCustomerId != null &&
        line.holderCustomerId !== holderCustomerId.value
      ) {
        return null
      }
      return {
        accountType: line.accountType,
        accountId: line.accountId,
        quantity:
          line.accountType === 'SAVING_CARD'
            ? 1
            : selectedQty[key] ?? line.maxRefundableQty ?? 0,
      }
    })
    .filter((x): x is { accountType: string; accountId: number; quantity: number } => x != null)

  if (items.length === 0) {
    uiMessage.warning('请勾选当前持有人下的可退明细')
    return
  }

  await runExclusive(submitting, async () => {
    try {
      await createRefund({
        refundType: 'SALE',
        sourceOrderId: props.orderId!,
        reason: reason.value.trim() || '申请退款',
        specialRefund: specialRefund.value && canSpecial.value,
        specialReason: specialRefund.value ? specialReason.value.trim() : undefined,
        holderCustomerId: holderCustomerId.value,
        items,
        payments: [],
      })
      uiMessage.success('已提交退款申请，审批通过后将自动执行（按当前持有人权益扣减）')
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
    title="销售退款预览"
    width="960px"
    append-to-body
    destroy-on-close
    :close-on-click-modal="false"
  >
    <div v-loading="loading" class="preview-body">
      <section v-if="preview" class="section">
        <h4>原订单信息</h4>
        <div class="meta">
          <div>销售订单：{{ preview.sourceOrderId }}</div>
          <div>原购买客户：{{ preview.customerName || preview.customerId || '—' }}</div>
          <div>销售时间：{{ formatDateTime(preview.saleTime) }}</div>
          <div>销售金额：{{ formatMoney(preview.saleAmount) }}</div>
          <div>已退款金额：{{ formatMoney(preview.alreadyRefundedAmount) }}</div>
        </div>
        <el-alert
          v-if="multiHolder"
          type="info"
          :closable="false"
          show-icon
          title="该销售单权益已转账至多个持有人。一次申请只能退其中一个持有人的剩余权益；不会撤销转账流水，也不会修改销售客户。"
          class="mb8"
        />
      </section>

      <section v-if="holders.length" class="section">
        <h4>权益持有人</h4>
        <el-radio-group
          v-model="holderCustomerId"
          :disabled="loading || submitting"
          class="holder-group"
        >
          <el-radio
            v-for="h in holders"
            :key="h.holderCustomerId ?? h.holderCustomerName"
            :value="h.holderCustomerId"
            :disabled="(h.selectableCount ?? 0) <= 0"
          >
            {{ h.holderCustomerName || h.holderCustomerId }}
            <span v-if="h.buyer" class="muted">（原购买）</span>
            · 可退 {{ formatMoney(h.maxRefundableAmount) }}
          </el-radio>
        </el-radio-group>
      </section>

      <section v-if="transfers.length" class="section">
        <h4>关联转账流水（只读）</h4>
        <el-table :data="transfers" border size="small" max-height="180">
          <el-table-column label="转账单" min-width="140" prop="transferBillId" show-overflow-tooltip />
          <el-table-column label="转出" min-width="100" show-overflow-tooltip>
            <template #default="{ row }">
              {{ row.outCustomerName || row.outCustomerId || '—' }}
            </template>
          </el-table-column>
          <el-table-column label="转入" min-width="100" show-overflow-tooltip>
            <template #default="{ row }">
              {{ row.inCustomerName || row.inCustomerId || '—' }}
            </template>
          </el-table-column>
          <el-table-column label="类型" width="90" prop="accountType" />
          <el-table-column label="数量/金额" width="100" align="right">
            <template #default="{ row }">
              {{ row.quantity ?? row.amount ?? '—' }}
            </template>
          </el-table-column>
          <el-table-column label="时间" min-width="150">
            <template #default="{ row }">{{ formatDateTime(row.createdOn) }}</template>
          </el-table-column>
        </el-table>
      </section>

      <section class="section">
        <div class="toolbar">
          <el-checkbox
            v-if="canSpecial"
            v-model="specialRefund"
            :disabled="loading || submitting"
          >
            特殊退款（含已消耗）
          </el-checkbox>
          <span v-else class="hint">无特殊退权限时仅可退剩余权益</span>
        </div>
        <el-form label-width="100px" class="form">
          <el-form-item label="退款原因">
            <el-input
              v-model="reason"
              type="textarea"
              :rows="2"
              maxlength="200"
              show-word-limit
              placeholder="选填"
            />
          </el-form-item>
          <el-form-item v-if="specialRefund" label="特殊原因" required>
            <el-input
              v-model="specialReason"
              type="textarea"
              :rows="2"
              maxlength="200"
              show-word-limit
              placeholder="必填：说明为何退已消耗权益"
            />
          </el-form-item>
        </el-form>
      </section>

      <section class="section">
        <h4>可退款明细</h4>
        <el-table :data="lines" border size="small" empty-text="无可退明细">
          <el-table-column label="选择" width="70" align="center">
            <template #default="{ row }">
              <el-checkbox
                :model-value="isChecked(row)"
                :disabled="!row.selectable || loading || submitting"
                @change="(v: boolean | string | number) => onToggleRow(row, Boolean(v))"
              />
            </template>
          </el-table-column>
          <el-table-column label="类型" width="80">
            <template #default="{ row }">{{ row.accountTypeName || row.accountType }}</template>
          </el-table-column>
          <el-table-column label="名称" min-width="140" show-overflow-tooltip>
            <template #default="{ row }">
              {{ row.itemName || row.itemId || '—' }}
              <span v-if="row.packageCardAccountId" class="muted">（套餐子项）</span>
            </template>
          </el-table-column>
          <el-table-column label="持有人" min-width="110" show-overflow-tooltip>
            <template #default="{ row }">
              {{ row.holderCustomerName || row.holderCustomerId || '—' }}
            </template>
          </el-table-column>
          <el-table-column label="原金额" width="90" align="right">
            <template #default="{ row }">{{ formatMoney(row.originalAmount) }}</template>
          </el-table-column>
          <el-table-column label="已消耗" width="70" align="right" prop="consumedQty" />
          <el-table-column label="剩余" width="70" align="right" prop="remainingQty" />
          <el-table-column label="已退" width="70" align="right" prop="alreadyRefundedQty" />
          <el-table-column label="可退数量" width="110" align="center">
            <template #default="{ row }">
              <template v-if="row.accountType === 'SAVING_CARD'">
                —
              </template>
              <el-input-number
                v-else-if="row.selectable && isChecked(row)"
                v-model="selectedQty[lineKey(row)]"
                :min="1"
                :max="row.maxRefundableQty || 1"
                :step="1"
                size="small"
                controls-position="right"
              />
              <span v-else>{{ row.maxRefundableQty ?? 0 }}</span>
            </template>
          </el-table-column>
          <el-table-column label="可退金额" width="100" align="right">
            <template #default="{ row }">{{ formatMoney(row.maxRefundableAmount) }}</template>
          </el-table-column>
          <el-table-column label="说明" min-width="120" show-overflow-tooltip>
            <template #default="{ row }">
              <span v-if="!row.selectable" class="muted">{{ row.unselectableReason || '不可选' }}</span>
            </template>
          </el-table-column>
        </el-table>
        <div class="sum">
          本次预计退款（服务端最终校验）：
          <strong>{{ formatMoney(selectedAmount) }}</strong>
        </div>
      </section>
    </div>

    <template #footer>
      <el-button :disabled="submitting" @click="visible = false">取消</el-button>
      <el-button type="primary" :loading="submitting" :disabled="loading" @click="onSubmit">
        提交退款申请
      </el-button>
    </template>
  </el-dialog>
</template>

<style scoped>
.preview-body {
  min-height: 200px;
}
.mb8 {
  margin-bottom: 8px;
}
.holder-group {
  display: flex;
  flex-direction: column;
  align-items: flex-start;
  gap: 6px;
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
  font-size: 13px;
  color: #303133;
}
.toolbar {
  margin-bottom: 8px;
}
.hint {
  color: #909399;
  font-size: 12px;
}
.form {
  max-width: 640px;
}
.sum {
  margin-top: 10px;
  text-align: right;
  font-size: 13px;
}
.muted {
  color: #909399;
  font-size: 12px;
}
</style>
