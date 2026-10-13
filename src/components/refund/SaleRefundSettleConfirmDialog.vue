<script setup lang="ts">
import { computed, ref, watch } from 'vue'

import { fetchPayMethods } from '@/api/sale'
import type { PayMethodOption } from '@/types/sale'
import type { RefundPreview, RefundPreviewLine } from '@/types/refund'
import { formatAmountDisplay } from '@/utils/amount'
import { getUserFriendlyErrorMessage, runExclusive, uiMessage } from '@/utils/ui'

defineOptions({ name: 'SaleRefundSettleConfirmDialog' })

export interface SettleLine {
  line: RefundPreviewLine
  quantity: number
  amount: number
}

const visible = defineModel<boolean>({ default: false })

const props = defineProps<{
  preview: RefundPreview | null
  lines: SettleLine[]
  refundAmount: number
  reason?: string
  submitting?: boolean
}>()

const emit = defineEmits<{
  confirm: [payments: Array<{ method: string; amount: number }>]
}>()

const methodsLoading = ref(false)
const payMethods = ref<PayMethodOption[]>([])

interface PayRow {
  key: string
  method: string
  amount: number | null
}

const payRows = ref<PayRow[]>([{ key: 'P1', method: '', amount: null }])

const cashMethods = computed(() =>
  payMethods.value.filter((m) => {
    const code = (m.code || '').toUpperCase()
    const name = m.name || ''
    return !code.includes('SAVING') && !name.includes('储值')
  }),
)

const paySum = computed(() => {
  let sum = 0
  for (const row of payRows.value) {
    const a = Number(row.amount)
    if (Number.isFinite(a) && a > 0) sum += a
  }
  return Number(sum.toFixed(2))
})

watch(visible, (open) => {
  if (!open) return
  payRows.value = [
    {
      key: 'P1',
      method: '',
      amount: Number(props.refundAmount.toFixed(2)),
    },
  ]
  void loadMethods()
})

async function loadMethods(): Promise<void> {
  await runExclusive(methodsLoading, async () => {
    try {
      payMethods.value = await fetchPayMethods()
      const first = cashMethods.value[0]
      if (first && !payRows.value[0]?.method) {
        payRows.value[0].method = first.code || first.name || ''
      }
    } catch (e) {
      payMethods.value = []
      uiMessage.error(getUserFriendlyErrorMessage(e))
    }
  })
}

function addRow(): void {
  const remain = Number((props.refundAmount - paySum.value).toFixed(2))
  const first = cashMethods.value[0]
  payRows.value.push({
    key: `P${Date.now()}`,
    method: first?.code || first?.name || '',
    amount: remain > 0 ? remain : null,
  })
}

function removeRow(key: string): void {
  if (payRows.value.length <= 1) return
  payRows.value = payRows.value.filter((r) => r.key !== key)
}

function onConfirm(): void {
  if (props.refundAmount <= 0) {
    uiMessage.warning('退款金额须大于 0')
    return
  }
  const payments: Array<{ method: string; amount: number }> = []
  for (const row of payRows.value) {
    if (!row.method) {
      uiMessage.warning('请选择退款渠道')
      return
    }
    const amt = Number(row.amount)
    if (!Number.isFinite(amt) || amt <= 0) {
      uiMessage.warning('请填写退款渠道金额')
      return
    }
    payments.push({ method: row.method, amount: Number(amt.toFixed(2)) })
  }
  if (Math.abs(paySum.value - props.refundAmount) > 0.009) {
    uiMessage.warning(
      `退款渠道合计须等于退款金额 ¥${formatAmountDisplay(props.refundAmount)}（当前 ¥${formatAmountDisplay(paySum.value)}）`,
    )
    return
  }
  emit('confirm', payments)
}
</script>

<template>
  <el-dialog
    v-model="visible"
    title="退款结账确认"
    width="920px"
    append-to-body
    destroy-on-close
    :close-on-click-modal="false"
  >
    <div class="settle">
      <section class="left">
        <h4>订单信息</h4>
        <div class="meta">
          <div>会员姓名：{{ preview?.customerName || preview?.customerId || '—' }}</div>
          <div>销售单号：{{ preview?.sourceOrderId || '—' }}</div>
          <div v-if="reason">备注：{{ reason }}</div>
        </div>
        <h4 class="mt">退款明细</h4>
        <el-table :data="lines" border size="small" max-height="280" empty-text="无明细">
          <el-table-column label="项目" min-width="140" show-overflow-tooltip>
            <template #default="{ row }">
              {{ row.line.itemName || row.line.itemId || '—' }}
            </template>
          </el-table-column>
          <el-table-column label="退款数量" width="90" align="right">
            <template #default="{ row }">
              {{ row.line.accountType === 'SAVING_CARD' ? '—' : row.quantity }}
            </template>
          </el-table-column>
          <el-table-column label="退款金额" width="110" align="right">
            <template #default="{ row }">¥ {{ formatAmountDisplay(row.amount) }}</template>
          </el-table-column>
        </el-table>
        <div class="total">合计：¥ {{ formatAmountDisplay(refundAmount) }}</div>
      </section>

      <section class="right" v-loading="methodsLoading">
        <div class="order-amt">
          订单金额
          <strong>¥ {{ formatAmountDisplay(refundAmount) }}</strong>
        </div>
        <el-alert
          type="info"
          :closable="false"
          show-icon
          title="提示：系统只记录退款渠道，不接第三方支付；财务实际退款线下处理。储值抵扣金额退回对应储值卡。"
          class="mb8"
        />
        <h4>退回现金</h4>
        <div v-for="row in payRows" :key="row.key" class="pay-row">
          <el-select v-model="row.method" placeholder="退款方式" style="width: 140px">
            <el-option
              v-for="m in cashMethods"
              :key="m.id"
              :label="m.name || m.code || String(m.id)"
              :value="m.code || m.name || String(m.id)"
            />
          </el-select>
          <el-input-number
            v-model="row.amount"
            :min="0"
            :precision="2"
            :step="1"
            controls-position="right"
            style="width: 140px"
          />
          <el-button type="danger" link :disabled="payRows.length <= 1" @click="removeRow(row.key)">
            删除
          </el-button>
        </div>
        <el-button type="primary" plain size="small" @click="addRow">+ 添加渠道</el-button>
        <div class="pay-sum">已填合计 ¥ {{ formatAmountDisplay(paySum) }}</div>
      </section>
    </div>

    <template #footer>
      <el-button :disabled="submitting" @click="visible = false">取消</el-button>
      <el-button type="primary" :loading="submitting" @click="onConfirm">提交申请</el-button>
    </template>
  </el-dialog>
</template>

<style scoped>
.settle {
  display: grid;
  grid-template-columns: 1.1fr 0.9fr;
  gap: 16px;
  min-height: 320px;
}
.left,
.right {
  min-width: 0;
}
h4 {
  margin: 0 0 8px;
  font-size: 14px;
}
.mt {
  margin-top: 14px;
}
.mb8 {
  margin-bottom: 8px;
}
.meta {
  display: grid;
  gap: 4px;
  font-size: 13px;
  color: #303133;
  margin-bottom: 8px;
}
.total {
  margin-top: 10px;
  text-align: right;
  font-weight: 600;
}
.order-amt {
  display: flex;
  justify-content: space-between;
  align-items: baseline;
  margin-bottom: 10px;
  font-size: 14px;
}
.order-amt strong {
  color: var(--el-color-danger);
  font-size: 20px;
}
.pay-row {
  display: flex;
  align-items: center;
  gap: 8px;
  margin-bottom: 8px;
}
.pay-sum {
  margin-top: 10px;
  font-size: 13px;
  color: #606266;
}
</style>
