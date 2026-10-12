<script setup lang="ts">
import { computed, ref, watch } from 'vue'

import { fetchPayMethods } from '@/api/sale'
import type { PayMethodOption, SalePaymentInput } from '@/types/sale'
import { formatAmountDisplay } from '@/utils/amount'
import { getUserFriendlyErrorMessage, runExclusive, uiMessage } from '@/utils/ui'

defineOptions({ name: 'CashierSettleDialog' })

export interface SettleLineOption {
  clientLineKey: string
  itemType: string
  name: string
  /** 成交金额（含赠送则为 0） */
  saleAmount: number
  /** 本行欠款 */
  arrearAmount?: number
  /** 本行储值抵扣合计 */
  savingDeductAmount?: number
  /** 本行现金类应收 */
  cashDueAmount?: number
}

export interface SettleConfirmPayload {
  /** 仅创建待支付订单，不登记收款 */
  createOnly: boolean
  /** 整单欠款（开单明细已确定，结账只读回传） */
  arrearAmount: number
  payments: SalePaymentInput[]
  /** 普通收银不再传；兼容旧调用保留空数组 */
  paymentAllocations: []
}

const props = defineProps<{
  modelValue: boolean
  /** 现金类应收（成交 − 欠款 − 储值抵扣） */
  payableAmount: string | number
  /** 成交合计 */
  goodsAmount?: string | number
  /** 储值抵扣合计（开单明细已定） */
  savingDeductAmount?: string | number
  /** 欠款合计（开单明细已定） */
  arrearAmount?: string | number
  customerName: string | null
  channelName: string | null
  lineCount: number
  settleLines: SettleLineOption[]
  submitting?: boolean
  /** 对待支付订单补记收款：隐藏「仅创建」 */
  payOnlyMode?: boolean
}>()

const emit = defineEmits<{
  'update:modelValue': [boolean]
  confirm: [SettleConfirmPayload]
}>()

const visible = computed({
  get: () => props.modelValue,
  set: (v: boolean) => emit('update:modelValue', v),
})

const methodsLoading = ref(false)
const methodsError = ref<string | null>(null)
const payMethods = ref<PayMethodOption[]>([])

interface PayRow {
  key: string
  method: string
  amount: number | null
}

const payRows = ref<PayRow[]>([{ key: 'P1', method: '', amount: null }])
const createOnly = ref(false)

const cashDueNum = computed(() => {
  const n = Number(props.payableAmount)
  return Number.isFinite(n) ? Math.max(0, n) : 0
})

const goodsNum = computed(() => {
  const n = Number(props.goodsAmount ?? 0)
  return Number.isFinite(n) ? Math.max(0, n) : 0
})

const savingNum = computed(() => {
  const n = Number(props.savingDeductAmount ?? 0)
  return Number.isFinite(n) ? Math.max(0, n) : 0
})

const arrearNum = computed(() => {
  const n = Number(props.arrearAmount ?? 0)
  return Number.isFinite(n) ? Math.max(0, n) : 0
})

const lines = computed(() => props.settleLines ?? [])

function isSavingMethod(method: string): boolean {
  const m = (method || '').toUpperCase()
  return m.includes('SAVING') || method.includes('储值')
}

/** 结账弹窗只展示现金类渠道 */
const cashPayMethods = computed(() =>
  payMethods.value.filter((m) => !isSavingMethod(m.code || '') && !isSavingMethod(m.name || '')),
)

const paySum = computed(() => {
  let sum = 0
  for (const row of payRows.value) {
    const a = Number(row.amount)
    if (Number.isFinite(a) && a > 0) sum += a
  }
  return Number(sum.toFixed(2))
})

async function loadMethods(): Promise<void> {
  await runExclusive(methodsLoading, async () => {
    methodsError.value = null
    try {
      payMethods.value = await fetchPayMethods()
      const cash = cashPayMethods.value
      if (cash.length && !payRows.value[0]?.method) {
        const first = cash[0]!
        payRows.value[0]!.method = first.code || first.name || String(first.id)
        payRows.value[0]!.amount = cashDueNum.value
      }
    } catch (error) {
      payMethods.value = []
      methodsError.value = getUserFriendlyErrorMessage(error)
    }
  })
}

function addPayRow(): void {
  const key = `P${Date.now()}`
  const first = cashPayMethods.value[0]
  payRows.value.push({
    key,
    method: first?.code || first?.name || '',
    amount: null,
  })
}

function removePayRow(key: string): void {
  if (payRows.value.length <= 1) return
  payRows.value = payRows.value.filter((r) => r.key !== key)
}

function fillFullAmount(): void {
  if (payRows.value[0]) {
    payRows.value[0].amount = cashDueNum.value
    for (let i = 1; i < payRows.value.length; i++) {
      payRows.value[i]!.amount = 0
    }
  }
}

function onConfirm(): void {
  if (createOnly.value) {
    if (savingNum.value > 0.001) {
      uiMessage.warning('含储值抵扣时请直接结账收款，不能仅创建待支付订单')
      return
    }
    emit('confirm', {
      createOnly: true,
      arrearAmount: arrearNum.value,
      payments: [],
      paymentAllocations: [],
    })
    return
  }
  if (!cashPayMethods.value.length) {
    uiMessage.warning('暂无可用现金类收款方式，请检查门店支付方式配置')
    return
  }
  if (!lines.value.length) {
    uiMessage.warning('无销售明细，无法登记收款')
    return
  }

  const payments: SalePaymentInput[] = []
  for (const row of payRows.value) {
    const method = row.method?.trim()
    if (!method) {
      uiMessage.warning('请选择收款方式')
      return
    }
    if (isSavingMethod(method)) {
      uiMessage.warning('储值抵扣请在开单明细中设置，结账弹窗只登记现金类渠道')
      return
    }
    const amount = row.amount == null ? null : Number(row.amount)
    if (amount != null && (!Number.isFinite(amount) || amount < 0)) {
      uiMessage.warning('收款金额无效')
      return
    }
    if (amount != null && amount === 0) continue
    payments.push({ paymentKey: row.key, method, amount })
  }

  if (cashDueNum.value > 0.001 && !payments.length) {
    uiMessage.warning('请填写本次现金类收款金额')
    return
  }
  if (Math.abs(paySum.value - cashDueNum.value) > 0.01) {
    uiMessage.warning(
      `现金类收款合计须等于现金应收 ¥${formatAmountDisplay(cashDueNum.value)}（当前 ¥${formatAmountDisplay(paySum.value)}）`,
    )
    return
  }

  emit('confirm', {
    createOnly: false,
    arrearAmount: arrearNum.value,
    payments,
    paymentAllocations: [],
  })
}

watch(
  () => props.modelValue,
  (open) => {
    if (open) {
      createOnly.value = false
      payRows.value = [{ key: 'P1', method: '', amount: cashDueNum.value }]
      void loadMethods()
    }
  },
)
</script>

<template>
  <el-dialog
    v-model="visible"
    title="确认收款"
    width="640px"
    append-to-body
    :close-on-click-modal="false"
    :close-on-press-escape="!submitting"
    destroy-on-close
  >
    <div class="settle-hint">
      明细金额、储值抵扣与欠款已在开单页确定；此处仅选择现金类付款渠道并确认收款。支付归属由系统自动生成。
    </div>

    <div class="settle-summary">
      <div><span>客户</span><strong>{{ customerName || '—' }}</strong></div>
      <div v-if="channelName"><span>项目渠道</span><strong>{{ channelName }}</strong></div>
      <div><span>明细</span><strong>{{ lineCount }} 行</strong></div>
    </div>

    <div class="fund-bar">
      <span>成交合计 ¥{{ formatAmountDisplay(goodsNum) }}</span>
      <span>储值抵扣 ¥{{ formatAmountDisplay(savingNum) }}</span>
      <span>欠款 ¥{{ formatAmountDisplay(arrearNum) }}</span>
      <strong>现金类应收 ¥{{ formatAmountDisplay(cashDueNum) }}</strong>
    </div>

    <div class="line-brief">
      <div v-for="line in lines" :key="line.clientLineKey" class="line-row">
        <div class="line-main">
          <strong>{{ line.name }}</strong>
          <span class="muted">{{ line.itemType }}</span>
        </div>
        <div class="line-amt">
          成交 ¥{{ formatAmountDisplay(line.saleAmount) }}
          <template v-if="Number(line.savingDeductAmount) > 0">
            · 储值 ¥{{ formatAmountDisplay(line.savingDeductAmount) }}
          </template>
          <template v-if="Number(line.arrearAmount) > 0">
            · 欠款 ¥{{ formatAmountDisplay(line.arrearAmount) }}
          </template>
          · 现金 ¥{{ formatAmountDisplay(line.cashDueAmount ?? 0) }}
        </div>
      </div>
    </div>

    <el-checkbox
      v-if="!payOnlyMode"
      v-model="createOnly"
      :disabled="submitting || savingNum > 0"
    >
      仅创建待支付订单（稍后再登记收款）
    </el-checkbox>

    <template v-if="!createOnly">
      <div v-if="methodsError" class="err">{{ methodsError }}</div>
      <div v-loading="methodsLoading" class="pay-block">
        <div class="pay-toolbar">
          <span>付款渠道</span>
          <el-button size="small" :disabled="submitting" @click="fillFullAmount">填满现金应收</el-button>
          <el-button
            size="small"
            :disabled="submitting || cashPayMethods.length === 0"
            @click="addPayRow"
          >
            添加方式
          </el-button>
        </div>
        <div v-for="row in payRows" :key="row.key" class="pay-row">
          <el-select
            v-model="row.method"
            filterable
            placeholder="收款方式"
            style="width: 160px"
            :disabled="submitting"
          >
            <el-option
              v-for="m in cashPayMethods"
              :key="m.id"
              :label="m.name || m.code || String(m.id)"
              :value="m.code || m.name || String(m.id)"
            />
          </el-select>
          <el-input-number
            v-model="row.amount"
            :min="0"
            :precision="2"
            :controls="false"
            :disabled="submitting"
            style="width: 140px"
          />
          <el-button
            link
            type="danger"
            :disabled="submitting || payRows.length <= 1"
            @click="removePayRow(row.key)"
          >
            删
          </el-button>
        </div>
        <div class="pay-sum">已填现金类合计 ¥{{ formatAmountDisplay(paySum) }}</div>
      </div>
    </template>

    <template #footer>
      <el-button :disabled="submitting" @click="visible = false">取消</el-button>
      <el-button type="primary" :loading="submitting" @click="onConfirm">
        {{ createOnly ? '创建待支付单' : '确认收款' }}
      </el-button>
    </template>
  </el-dialog>
</template>

<style scoped>
.settle-hint {
  margin-bottom: 12px;
  padding: 8px 10px;
  font-size: 12px;
  line-height: 1.5;
  color: #606266;
  background: #f5f7fa;
  border-radius: 4px;
}
.settle-summary {
  display: grid;
  grid-template-columns: repeat(3, minmax(0, 1fr));
  gap: 8px 12px;
  margin-bottom: 12px;
}
.settle-summary span {
  display: block;
  font-size: 12px;
  color: #909399;
}
.settle-summary strong {
  font-size: 14px;
}
.fund-bar {
  display: flex;
  flex-wrap: wrap;
  gap: 12px 16px;
  margin-bottom: 12px;
  padding: 10px 12px;
  font-size: 13px;
  background: #fafafa;
  border: 1px solid #ebeef5;
  border-radius: 4px;
}
.fund-bar strong {
  color: #409eff;
}
.line-brief {
  max-height: 160px;
  margin-bottom: 12px;
  overflow: auto;
  border: 1px solid #ebeef5;
  border-radius: 4px;
}
.line-row {
  padding: 8px 10px;
  border-bottom: 1px solid #f0f2f5;
}
.line-row:last-child {
  border-bottom: 0;
}
.line-main {
  display: flex;
  gap: 8px;
  align-items: baseline;
}
.muted {
  font-size: 12px;
  color: #909399;
}
.line-amt {
  margin-top: 4px;
  font-size: 12px;
  color: #606266;
}
.pay-block {
  margin-top: 10px;
  min-height: 48px;
}
.pay-toolbar {
  display: flex;
  gap: 8px;
  align-items: center;
  margin-bottom: 8px;
}
.pay-row {
  display: flex;
  gap: 8px;
  align-items: center;
  margin-bottom: 8px;
}
.pay-sum {
  margin-top: 4px;
  font-size: 12px;
  color: #606266;
}
.err {
  color: #f56c6c;
  font-size: 13px;
}
</style>
