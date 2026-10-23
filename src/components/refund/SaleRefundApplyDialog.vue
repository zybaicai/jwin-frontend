<script setup lang="ts">
import { computed, reactive, ref, watch } from 'vue'

import { createRefund, previewRefund } from '@/api/refund'
import { fetchSaleOrderPage } from '@/api/sale'
import SaleRefundSettleConfirmDialog from '@/components/refund/SaleRefundSettleConfirmDialog.vue'
import type { SettleLine } from '@/components/refund/SaleRefundSettleConfirmDialog.vue'
import { useInfiniteList } from '@/composables/useInfiniteList'
import type { RefundPreview, RefundPreviewLine } from '@/types/refund'
import { RefundPermission } from '@/types/refund'
import type { SaleOrderDetail } from '@/types/sale'
import { usePermissionStore } from '@/stores/permission'
import {
  getUserFriendlyErrorMessage,
  runExclusive,
  uiMessage,
} from '@/utils/ui'
import { formatDateTime, formatMoney, maskMobile } from '@/views/customer/customer-format'

defineOptions({ name: 'SaleRefundApplyDialog' })

const visible = defineModel<boolean>({ default: false })

const emit = defineEmits<{
  success: []
}>()

const permissionStore = usePermissionStore()
const canSpecial = computed(() => permissionStore.hasPermission(RefundPermission.SPECIAL))

const BLOCKED_SALE_STATUS = new Set(['草稿', '待支付', '已关闭', '已退款'])

const list = useInfiniteList<SaleOrderDetail>({
  pageSize: 15,
  debounceMs: 300,
  visible,
  onError: (e) => uiMessage.error(getUserFriendlyErrorMessage(e)),
  fetcher: async ({ keyword: kw, page, size }) => {
    const data = await fetchSaleOrderPage({
      keyword: kw || undefined,
      billId: kw && /^XS/i.test(kw) ? kw : undefined,
      page,
      size,
    })
    const all = data.records ?? []
    const filtered = all.filter((o) => !o.billStatus || !BLOCKED_SALE_STATUS.has(o.billStatus))
    return {
      records: filtered,
      total: data.total ?? 0,
      pageSize: size,
      rawCount: all.length,
    }
  },
})

const keyword = list.keyword
const orders = list.records
const searching = list.loading
const loadingMore = list.loadingMore
const hasMore = list.hasMore
const selectedOrderId = ref<string | null>(null)

const loadingPreview = ref(false)
const submitting = ref(false)
const preview = ref<RefundPreview | null>(null)
const specialRefund = ref(false)
const reason = ref('')
const specialReason = ref('')
const holderCustomerId = ref<number | null>(null)
const selectedQty = reactive<Record<string, number>>({})
const checkedKeys = ref<string[]>([])

const settleVisible = ref(false)

const holders = computed(() => preview.value?.holders ?? [])
const transfers = computed(() => preview.value?.transfers ?? [])
const multiHolder = computed(
  () => holders.value.filter((h) => (h.selectableCount ?? 0) > 0).length > 1,
)
const lines = computed(() => {
  const all = preview.value?.lines ?? []
  if (holderCustomerId.value == null) return all
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

const settleLines = computed<SettleLine[]>(() => {
  const result: SettleLine[] = []
  for (const key of checkedKeys.value) {
    const line = lines.value.find((l) => lineKey(l) === key)
    if (!line) continue
    const qty =
      line.accountType === 'SAVING_CARD'
        ? 1
        : selectedQty[key] ?? line.maxRefundableQty ?? 0
    const amount =
      line.accountType === 'SAVING_CARD'
        ? Number(line.maxRefundableAmount ?? 0)
        : Number((Number(line.unitPrice ?? 0) * qty).toFixed(2))
    result.push({ line, quantity: qty, amount })
  }
  return result
})

watch(visible, (open) => {
  if (!open) {
    list.clearTimer()
    resetAll()
    return
  }
  resetAll()
  void loadOrders(true)
})

watch(keyword, () => list.onKeywordChange())

watch(specialRefund, () => {
  if (selectedOrderId.value) void loadPreview(selectedOrderId.value)
})

watch(holderCustomerId, () => {
  checkedKeys.value = []
  for (const k of Object.keys(selectedQty)) delete selectedQty[k]
  for (const line of lines.value) {
    if (line.selectable && line.accountId != null) {
      selectedQty[lineKey(line)] = line.maxRefundableQty ?? 0
    }
  }
})

function resetAll(): void {
  list.resetKeywordSilent()
  selectedOrderId.value = null
  preview.value = null
  specialRefund.value = false
  reason.value = ''
  specialReason.value = ''
  holderCustomerId.value = null
  checkedKeys.value = []
  for (const k of Object.keys(selectedQty)) delete selectedQty[k]
  settleVisible.value = false
}

function lineKey(line: RefundPreviewLine): string {
  return `${line.accountType}:${line.accountId}`
}

async function loadOrders(reset: boolean): Promise<void> {
  await list.load(reset).catch(() => undefined)
}

function flushSearch(): void {
  list.flushSearch()
}

function onOrderListScroll(e: Event): void {
  list.onScroll(e)
}

async function selectOrder(order: SaleOrderDetail): Promise<void> {
  selectedOrderId.value = order.id
  checkedKeys.value = []
  for (const k of Object.keys(selectedQty)) delete selectedQty[k]
  holderCustomerId.value = null
  await loadPreview(order.id)
}

async function loadPreview(orderId: string): Promise<void> {
  await runExclusive(loadingPreview, async () => {
    try {
      const data = await previewRefund({
        refundType: 'SALE',
        sourceOrderId: orderId,
        specialRefund: specialRefund.value && canSpecial.value,
        holderCustomerId: holderCustomerId.value,
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
      for (const line of data.lines ?? []) {
        if (line.selectable && line.accountId != null) {
          selectedQty[lineKey(line)] = line.maxRefundableQty ?? 0
        }
      }
    } catch (e) {
      preview.value = null
      uiMessage.error(getUserFriendlyErrorMessage(e))
    }
  })
}

function onToggleRow(line: RefundPreviewLine, checked: boolean): void {
  const key = lineKey(line)
  if (checked) {
    if (!checkedKeys.value.includes(key)) checkedKeys.value.push(key)
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

function clearDraft(): void {
  selectedOrderId.value = null
  preview.value = null
  checkedKeys.value = []
  for (const k of Object.keys(selectedQty)) delete selectedQty[k]
  reason.value = ''
  specialReason.value = ''
  specialRefund.value = false
  holderCustomerId.value = null
}

function openSettle(): void {
  if (!selectedOrderId.value || !preview.value) {
    uiMessage.warning('请先选择销售订单')
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
  if (selectedAmount.value <= 0) {
    uiMessage.warning('退款金额须大于 0')
    return
  }
  settleVisible.value = true
}

async function onSettleConfirm(payments: Array<{ method: string; amount: number }>): Promise<void> {
  if (!selectedOrderId.value) return
  const items = settleLines.value
    .map((row) => {
      if (!row.line.accountType || row.line.accountId == null) return null
      if (
        holderCustomerId.value != null &&
        row.line.holderCustomerId != null &&
        row.line.holderCustomerId !== holderCustomerId.value
      ) {
        return null
      }
      return {
        accountType: row.line.accountType,
        accountId: row.line.accountId,
        quantity: row.quantity,
      }
    })
    .filter((x): x is { accountType: string; accountId: number; quantity: number } => x != null)

  if (!items.length) {
    uiMessage.warning('请勾选当前持有人下的可退明细')
    return
  }

  await runExclusive(submitting, async () => {
    try {
      await createRefund({
        refundType: 'SALE',
        sourceOrderId: selectedOrderId.value!,
        reason: reason.value.trim() || '申请退款',
        specialRefund: specialRefund.value && canSpecial.value,
        specialReason: specialRefund.value ? specialReason.value.trim() : undefined,
        holderCustomerId: holderCustomerId.value,
        items,
        payments,
      })
      uiMessage.success('已提交退款申请，审批通过后将自动执行')
      settleVisible.value = false
      visible.value = false
      emit('success')
    } catch (e) {
      uiMessage.error(getUserFriendlyErrorMessage(e))
    }
  })
}

function orderLabel(order: SaleOrderDetail): string {
  const name = order.customerName || `客户#${order.customerId ?? '—'}`
  return `${name} ${maskMobile(order.customerMobile)}`
}
</script>

<template>
  <el-dialog
    v-model="visible"
    title="退款申请（销售）"
    width="1100px"
    top="4vh"
    append-to-body
    destroy-on-close
    :close-on-click-modal="false"
    class="refund-apply-dialog"
  >
    <div class="layout">
      <aside class="left">
        <el-input
          v-model="keyword"
          clearable
          placeholder="输入订单号 / 客户姓名 / 手机号，自动搜索"
          @keyup.enter="flushSearch"
          @clear="flushSearch"
        >
          <template #append>
            <el-button :loading="searching" @click="flushSearch">搜索</el-button>
          </template>
        </el-input>
        <div v-loading="searching" class="order-list" @scroll.passive="onOrderListScroll">
          <button
            v-for="order in orders"
            :key="order.id"
            type="button"
            class="order-card"
            :class="{ active: selectedOrderId === order.id }"
            @click="selectOrder(order)"
          >
            <div class="row1">
              <span>{{ formatDateTime(order.billDate || order.createdOn) }}</span>
              <el-tag size="small" effect="plain">{{ order.billStatus || '—' }}</el-tag>
            </div>
            <div class="row2">{{ order.id }}</div>
            <div class="row3">{{ orderLabel(order) }}</div>
            <div class="row4">金额 {{ formatMoney(order.totalAmount ?? order.amount) }}</div>
          </button>
          <div v-if="loadingMore" class="list-foot">加载中…</div>
          <div v-else-if="hasMore && orders.length" class="list-foot">下拉加载更多</div>
          <div v-else-if="!searching && orders.length" class="list-foot">已全部加载</div>
          <div v-if="!searching && orders.length === 0" class="empty">请搜索可退销售订单</div>
        </div>
      </aside>

      <main class="right" v-loading="loadingPreview">
        <template v-if="preview">
          <section class="section">
            <div class="meta">
              <div>销售订单：{{ preview.sourceOrderId }}</div>
              <div>原购买客户：{{ preview.customerName || preview.customerId || '—' }}</div>
              <div>销售时间：{{ formatDateTime(preview.saleTime) }}</div>
              <div>销售金额：{{ formatMoney(preview.saleAmount) }}</div>
              <div>已退款：{{ formatMoney(preview.alreadyRefundedAmount) }}</div>
            </div>
            <el-alert
              v-if="multiHolder"
              type="info"
              :closable="false"
              show-icon
              class="mb8"
              title="权益已分属多个持有人。一次只能退其中一个持有人；不撤销转账、不修改销售客户。"
            />
          </section>

          <section v-if="holders.length" class="section">
            <h4>权益持有人</h4>
            <el-radio-group
              :model-value="holderCustomerId ?? undefined"
              class="holder-group"
              @update:model-value="holderCustomerId = $event as number | null"
            >
              <el-radio
                v-for="h in holders"
                :key="h.holderCustomerId ?? h.holderCustomerName ?? ''"
                :value="h.holderCustomerId as number"
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
            <el-table :data="transfers" border size="small" max-height="140">
              <el-table-column prop="transferBillId" label="转账单" min-width="130" show-overflow-tooltip />
              <el-table-column label="转出→转入" min-width="160" show-overflow-tooltip>
                <template #default="{ row }">
                  {{ row.outCustomerName || row.outCustomerId }} →
                  {{ row.inCustomerName || row.inCustomerId }}
                </template>
              </el-table-column>
              <el-table-column prop="accountType" label="类型" width="100" />
              <el-table-column label="数量" width="80" align="right">
                <template #default="{ row }">{{ row.quantity ?? row.amount ?? '—' }}</template>
              </el-table-column>
            </el-table>
          </section>

          <section class="section">
            <div class="toolbar">
              <el-checkbox v-if="canSpecial" v-model="specialRefund">特殊退款（含已消耗）</el-checkbox>
              <span v-else class="muted">无特殊退权限时仅可退剩余权益</span>
            </div>
            <el-input
              v-model="reason"
              type="textarea"
              :rows="2"
              maxlength="200"
              show-word-limit
              placeholder="请输入备注信息"
            />
            <el-input
              v-if="specialRefund"
              v-model="specialReason"
              class="mt8"
              type="textarea"
              :rows="2"
              maxlength="200"
              show-word-limit
              placeholder="特殊退款原因（必填）"
            />
          </section>

          <section class="section">
            <h4>退款明细</h4>
            <el-table :data="lines" border size="small" max-height="280" empty-text="无可退明细">
              <el-table-column label="选择" width="60" align="center">
                <template #default="{ row }">
                  <el-checkbox
                    :model-value="isChecked(row as RefundPreviewLine)"
                    :disabled="!row.selectable"
                    @change="(v: boolean | string | number) => onToggleRow(row as RefundPreviewLine, Boolean(v))"
                  />
                </template>
              </el-table-column>
              <el-table-column label="类型" width="80">
                <template #default="{ row }">{{ row.accountTypeName || row.accountType }}</template>
              </el-table-column>
              <el-table-column label="名称" min-width="120" show-overflow-tooltip>
                <template #default="{ row }">{{ row.itemName || row.itemId || '—' }}</template>
              </el-table-column>
              <el-table-column label="持有人" min-width="100" show-overflow-tooltip>
                <template #default="{ row }">
                  {{ row.holderCustomerName || row.holderCustomerId || '—' }}
                </template>
              </el-table-column>
              <el-table-column label="剩余" width="70" align="right" prop="remainingQty" />
              <el-table-column label="数量" width="120" align="center">
                <template #default="{ row }">
                  <template v-if="row.accountType === 'SAVING_CARD'">—</template>
                  <el-input-number
                    v-else-if="row.selectable && isChecked(row as RefundPreviewLine)"
                    v-model="selectedQty[lineKey(row as RefundPreviewLine)]"
                    :min="1"
                    :max="row.maxRefundableQty || 1"
                    size="small"
                    controls-position="right"
                  />
                  <span v-else>{{ row.maxRefundableQty ?? 0 }}</span>
                </template>
              </el-table-column>
              <el-table-column label="退款金额" width="100" align="right">
                <template #default="{ row }">{{ formatMoney(row.maxRefundableAmount) }}</template>
              </el-table-column>
            </el-table>
          </section>
        </template>
        <div v-else class="empty-right">从左侧选择销售订单后，在此配置退款明细</div>
      </main>
    </div>

    <template #footer>
      <div class="footer">
        <div class="amt">
          退款金额：
          <strong>¥ {{ selectedAmount.toFixed(2) }}</strong>
        </div>
        <div class="btns">
          <el-button :disabled="submitting" @click="clearDraft">清空</el-button>
          <el-button type="primary" :disabled="loadingPreview || submitting" @click="openSettle">
            结账
          </el-button>
        </div>
      </div>
    </template>

    <SaleRefundSettleConfirmDialog
      v-model="settleVisible"
      :preview="preview"
      :lines="settleLines"
      :refund-amount="selectedAmount"
      :reason="reason"
      :submitting="submitting"
      @confirm="onSettleConfirm"
    />
  </el-dialog>
</template>

<style scoped>
.layout {
  display: grid;
  grid-template-columns: 320px 1fr;
  gap: 12px;
  height: min(560px, calc(100vh - 240px));
  min-height: 360px;
  overflow: hidden;
}
.left,
.right {
  min-width: 0;
  min-height: 0;
  height: 100%;
  display: flex;
  flex-direction: column;
  overflow: hidden;
}
.order-list {
  margin-top: 10px;
  flex: 1 1 auto;
  min-height: 0;
  overflow-x: hidden;
  overflow-y: auto;
  border: 1px solid var(--el-border-color-lighter);
  border-radius: 6px;
  padding: 8px;
  background: #fafafa;
}
.order-card {
  width: 100%;
  text-align: left;
  border: 1px solid transparent;
  background: #fff;
  border-radius: 6px;
  padding: 10px;
  margin-bottom: 8px;
  cursor: pointer;
}
.order-card.active {
  border-color: var(--el-color-primary);
  box-shadow: 0 0 0 1px var(--el-color-primary-light-7);
}
.order-card .row1 {
  display: flex;
  justify-content: space-between;
  align-items: center;
  font-size: 12px;
  color: #606266;
}
.order-card .row2 {
  margin-top: 4px;
  font-weight: 600;
  font-size: 13px;
}
.order-card .row3,
.order-card .row4 {
  margin-top: 2px;
  font-size: 12px;
  color: #909399;
}
.right {
  border: 1px solid var(--el-border-color-lighter);
  border-radius: 6px;
  padding: 12px;
  overflow-x: hidden;
  overflow-y: auto;
  background: #fff;
}
.section {
  margin-bottom: 14px;
}
.section h4 {
  margin: 0 0 8px;
  font-size: 14px;
}
.meta {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 4px 12px;
  font-size: 13px;
}
.mb8 {
  margin-bottom: 8px;
}
.mt8 {
  margin-top: 8px;
}
.holder-group {
  display: flex;
  flex-direction: column;
  align-items: flex-start;
  gap: 4px;
}
.toolbar {
  margin-bottom: 8px;
}
.muted {
  color: #909399;
  font-size: 12px;
}
.empty,
.empty-right {
  color: #909399;
  font-size: 13px;
  padding: 24px 8px;
  text-align: center;
}
.list-foot {
  text-align: center;
  color: #909399;
  font-size: 12px;
  padding: 8px 0 4px;
}
.footer {
  display: flex;
  justify-content: space-between;
  align-items: center;
  width: 100%;
}
.amt strong {
  color: var(--el-color-danger);
  font-size: 18px;
}
.btns {
  display: flex;
  gap: 8px;
}
</style>

<!-- append-to-body 弹窗外挂，需非 scoped 约束 body，避免列表撑破页脚 -->
<style>
.refund-apply-dialog.el-dialog .el-dialog__body,
.el-dialog.refund-apply-dialog .el-dialog__body {
  overflow: hidden;
  padding-top: 12px;
  padding-bottom: 8px;
}
</style>
