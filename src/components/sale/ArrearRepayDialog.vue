<script setup lang="ts">
import { computed, ref, watch } from 'vue'

import { fetchCustomerArrears, fetchPayMethods, settleCustomerArrears } from '@/api/sale'
import type { ArrearItem, PayMethodOption, SettleArrearResult } from '@/types/sale'
import { formatAmountDisplay } from '@/utils/amount'
import { getUserFriendlyErrorMessage, runExclusive, uiMessage } from '@/utils/ui'

defineOptions({ name: 'ArrearRepayDialog' })

const ITEM_TYPE_LABEL: Record<string, string> = {
  SAVING_CARD: '储值卡',
  GENERAL_CARD: '次卡',
  TIME_CARD: '时效卡',
  PROJECT: '项目',
  PACKAGE_CARD: '套餐',
}

const props = defineProps<{
  modelValue: boolean
  customerId: number | null
  customerName: string | null
  storeId: number | null
}>()

const emit = defineEmits<{
  'update:modelValue': [boolean]
  success: [SettleArrearResult]
}>()

const visible = computed({
  get: () => props.modelValue,
  set: (v: boolean) => emit('update:modelValue', v),
})

const loading = ref(false)
const submitting = ref(false)
const loadError = ref<string | null>(null)
const items = ref<ArrearItem[]>([])
const payAmountByKey = ref<Record<string, number>>({})
const selected = ref<Set<string>>(new Set())

const payMethods = ref<PayMethodOption[]>([])
const payMethod = ref('')

function lineKey(it: ArrearItem): string {
  return `${it.itemType}:${it.sourceSaleLineId}`
}

const selectedRows = computed(() =>
  items.value.filter((it) => selected.value.has(lineKey(it)) && it.repayable),
)

const payTotal = computed(() => {
  let sum = 0
  for (const it of selectedRows.value) {
    const k = lineKey(it)
    const amt = Number(payAmountByKey.value[k] ?? 0)
    if (Number.isFinite(amt) && amt > 0) sum += amt
  }
  return Number(sum.toFixed(2))
})

async function load(): Promise<void> {
  if (!props.customerId || !props.storeId) {
    items.value = []
    return
  }
  loading.value = true
  loadError.value = null
  try {
    const [list, methods] = await Promise.all([
      fetchCustomerArrears(props.customerId, props.storeId),
      fetchPayMethods(),
    ])
    items.value = list
    payMethods.value = (methods ?? []).filter((m) => {
      const code = (m.code || '').toUpperCase()
      const name = m.name || ''
      return !code.includes('SAVING') && name !== '储值'
    })
    const nextAmt: Record<string, number> = {}
    const nextSel = new Set<string>()
    for (const it of list) {
      if (!it.repayable) continue
      const k = lineKey(it)
      nextAmt[k] = Number(Number(it.arrearAmount).toFixed(2))
      nextSel.add(k)
    }
    payAmountByKey.value = nextAmt
    selected.value = nextSel
    if (!payMethod.value && payMethods.value.length) {
      payMethod.value = payMethods.value[0].code || payMethods.value[0].name || ''
    }
  } catch (e) {
    loadError.value = getUserFriendlyErrorMessage(e)
    items.value = []
  } finally {
    loading.value = false
  }
}

watch(
  () => [props.modelValue, props.customerId, props.storeId] as const,
  ([open]) => {
    if (open) void load()
  },
)

function toggleRow(it: ArrearItem, checked: boolean): void {
  if (!it.repayable) return
  const k = lineKey(it)
  const next = new Set(selected.value)
  if (checked) next.add(k)
  else next.delete(k)
  selected.value = next
}

function onAmountChange(it: ArrearItem, val: number | undefined): void {
  const k = lineKey(it)
  const max = Number(it.arrearAmount)
  let n = Number(val ?? 0)
  if (!Number.isFinite(n) || n < 0) n = 0
  if (n > max) n = max
  payAmountByKey.value = { ...payAmountByKey.value, [k]: Number(n.toFixed(2)) }
}

async function onConfirm(): Promise<void> {
  if (!props.customerId || !props.storeId) {
    uiMessage.warning('请先选择客户与门店')
    return
  }
  if (!selectedRows.value.length) {
    uiMessage.warning('请选择待补欠款明细')
    return
  }
  if (payTotal.value <= 0) {
    uiMessage.warning('补缴合计须大于 0')
    return
  }
  if (!payMethod.value) {
    uiMessage.warning('请选择支付方式')
    return
  }
  for (const it of selectedRows.value) {
    const amt = Number(payAmountByKey.value[lineKey(it)] ?? 0)
    if (amt <= 0) {
      uiMessage.warning(`请填写「${it.itemName || it.sourceSaleBillId}」补缴金额`)
      return
    }
    if (amt - Number(it.arrearAmount) > 0.001) {
      uiMessage.warning(`补缴不能超过欠款：${it.sourceSaleBillId}`)
      return
    }
  }

  await runExclusive(submitting, async () => {
    const arrearAllocations = selectedRows.value.map((it) => ({
      sourceSaleBillId: it.sourceSaleBillId,
      itemType: it.itemType,
      sourceSaleLineId: it.sourceSaleLineId,
      amount: Number(Number(payAmountByKey.value[lineKey(it)]).toFixed(2)),
    }))
    const idempotencyKey =
      typeof crypto !== 'undefined' && crypto.randomUUID
        ? crypto.randomUUID()
        : `ARREAR-${Date.now()}-${Math.random().toString(16).slice(2)}`
    try {
      const result = await settleCustomerArrears({
        idempotencyKey,
        storeId: props.storeId!,
        customerId: props.customerId!,
        arrearAllocations,
        payments: [
          {
            paymentKey: 'P1',
            method: payMethod.value,
            amount: payTotal.value,
          },
        ],
        paymentAllocations: arrearAllocations.map((a) => ({
          paymentKey: 'P1',
          targetLineKey: `${a.itemType}:${a.sourceSaleLineId}`,
          amount: a.amount,
        })),
      })
      uiMessage.success(`补欠款成功：${result.repayBillId}，实收 ¥${formatAmountDisplay(result.payAmount)}`)
      visible.value = false
      emit('success', result)
    } catch (e) {
      uiMessage.error(getUserFriendlyErrorMessage(e))
    }
  })
}
</script>

<template>
  <el-dialog
    v-model="visible"
    title="合并补欠款"
    width="920px"
    destroy-on-close
    :close-on-click-modal="false"
  >
    <p class="hint">
      客户：{{ customerName || '—' }}。补欠款收回原销售应收账款，不生成新销售成交；可多选明细一次付款。
    </p>
    <el-alert v-if="loadError" type="error" :title="loadError" show-icon :closable="false" />
    <el-table
      v-loading="loading"
      :data="items"
      size="small"
      border
      max-height="360"
      empty-text="当前客户在本店无可补欠款"
    >
      <el-table-column label="选" width="52" align="center">
        <template #default="{ row }">
          <el-checkbox
            :model-value="selected.has(lineKey(row as ArrearItem))"
            :disabled="!row.repayable"
            @change="(v: boolean | string | number) => toggleRow(row as ArrearItem, !!v)"
          />
        </template>
      </el-table-column>
      <el-table-column prop="sourceSaleBillId" label="原销售单" width="140" />
      <el-table-column label="日期" width="110">
        <template #default="{ row }">
          {{ row.saleDate ? String(row.saleDate).slice(0, 10) : '—' }}
        </template>
      </el-table-column>
      <el-table-column label="类型" width="80">
        <template #default="{ row }">
          {{ ITEM_TYPE_LABEL[row.itemType] || row.itemType }}
        </template>
      </el-table-column>
      <el-table-column prop="itemName" label="商品/卡项" min-width="120" show-overflow-tooltip />
      <el-table-column label="成交" width="90" align="right">
        <template #default="{ row }">¥{{ formatAmountDisplay(row.saleAmount) }}</template>
      </el-table-column>
      <el-table-column label="已付" width="90" align="right">
        <template #default="{ row }">¥{{ formatAmountDisplay(row.paidAmount) }}</template>
      </el-table-column>
      <el-table-column label="欠款" width="90" align="right">
        <template #default="{ row }">¥{{ formatAmountDisplay(row.arrearAmount) }}</template>
      </el-table-column>
      <el-table-column label="本次补缴" width="120">
        <template #default="{ row }">
          <el-input-number
            :model-value="payAmountByKey[lineKey(row as ArrearItem)] ?? 0"
            :min="0"
            :max="Number(row.arrearAmount)"
            :precision="2"
            :step="1"
            :disabled="!row.repayable || !selected.has(lineKey(row as ArrearItem))"
            controls-position="right"
            size="small"
            style="width: 100%"
            @update:model-value="(v: number | undefined) => onAmountChange(row as ArrearItem, v)"
          />
        </template>
      </el-table-column>
      <el-table-column label="补后剩余" width="90" align="right">
        <template #default="{ row }">
          ¥{{
            formatAmountDisplay(
              Math.max(
                0,
                Number(row.arrearAmount) - Number(payAmountByKey[lineKey(row as ArrearItem)] ?? 0),
              ),
            )
          }}
        </template>
      </el-table-column>
      <el-table-column label="说明" min-width="100" show-overflow-tooltip>
        <template #default="{ row }">
          <span v-if="!row.repayable" class="blocked">{{ row.blockReason || '不可补' }}</span>
          <span v-else>—</span>
        </template>
      </el-table-column>
    </el-table>

    <div class="footer-bar">
      <div class="pay-method">
        <span>支付方式</span>
        <el-select v-model="payMethod" placeholder="选择支付方式" style="width: 160px">
          <el-option
            v-for="m in payMethods"
            :key="m.id"
            :label="m.name || m.code || String(m.id)"
            :value="m.code || m.name || ''"
          />
        </el-select>
      </div>
      <div class="total">
        已选 {{ selectedRows.length }} 条，本次实收
        <strong>¥{{ formatAmountDisplay(payTotal) }}</strong>
      </div>
    </div>

    <template #footer>
      <el-button @click="visible = false">取消</el-button>
      <el-button type="primary" :loading="submitting" :disabled="loading" @click="onConfirm">
        确认补缴
      </el-button>
    </template>
  </el-dialog>
</template>

<style scoped>
.hint {
  margin: 0 0 12px;
  color: #606266;
  font-size: 13px;
}
.footer-bar {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-top: 14px;
  gap: 16px;
}
.pay-method {
  display: flex;
  align-items: center;
  gap: 8px;
}
.total strong {
  color: #c45656;
  margin-left: 4px;
}
.blocked {
  color: #e6a23c;
  font-size: 12px;
}
</style>
