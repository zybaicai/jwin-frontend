<script setup lang="ts">
import { computed, ref, watch } from 'vue'

import { createRefund, previewRefund } from '@/api/refund'
import { fetchTreatOrderPage } from '@/api/treat'
import { useInfiniteList } from '@/composables/useInfiniteList'
import type { RefundPreview } from '@/types/refund'
import type { TreatOrderDetail } from '@/types/treat'
import { formatTreatBillStatus } from '@/types/treat'
import {
  getUserFriendlyErrorMessage,
  runExclusive,
  uiMessage,
} from '@/utils/ui'
import { formatDateTime, formatMoney, maskMobile } from '@/views/customer/customer-format'

defineOptions({ name: 'TreatRefundApplyDialog' })

const visible = defineModel<boolean>({ default: false })

const emit = defineEmits<{
  success: []
}>()

const list = useInfiniteList<TreatOrderDetail>({
  pageSize: 15,
  debounceMs: 300,
  visible,
  onError: (e) => uiMessage.error(getUserFriendlyErrorMessage(e)),
  fetcher: async ({ keyword: kw, page, size }) => {
    const data = await fetchTreatOrderPage({
      keyword: kw || undefined,
      billId: kw && /^XH/i.test(kw) ? kw : undefined,
      status: '1',
      page,
      size,
    })
    return {
      records: data.records ?? [],
      total: data.total ?? 0,
      pageSize: size,
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
const reason = ref('')

const lines = computed(() => preview.value?.lines ?? [])
const totalAmount = computed(() => Number(preview.value?.saleAmount ?? 0))

watch(visible, (open) => {
  if (!open) {
    list.clearTimer()
    resetAll()
    return
  }
  resetAll()
  void list.load(true).catch(() => undefined)
})

watch(keyword, () => list.onKeywordChange())

function resetAll(): void {
  list.resetKeywordSilent()
  selectedOrderId.value = null
  preview.value = null
  reason.value = ''
}

function flushSearch(): void {
  list.flushSearch()
}

function onOrderListScroll(e: Event): void {
  list.onScroll(e)
}

async function selectOrder(order: TreatOrderDetail): Promise<void> {
  selectedOrderId.value = order.id
  await loadPreview(order.id)
}

async function loadPreview(orderId: string): Promise<void> {
  await runExclusive(loadingPreview, async () => {
    try {
      preview.value = await previewRefund({
        refundType: 'TREAT',
        sourceOrderId: orderId,
      })
    } catch (e) {
      preview.value = null
      uiMessage.error(getUserFriendlyErrorMessage(e))
    }
  })
}

function clearDraft(): void {
  selectedOrderId.value = null
  preview.value = null
  reason.value = ''
}

async function onSubmit(): Promise<void> {
  if (!selectedOrderId.value || !preview.value) {
    uiMessage.warning('请先选择消耗订单')
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
        sourceOrderId: selectedOrderId.value!,
        reason: reason.value.trim() || '申请消耗退款',
      })
      uiMessage.success('已提交消耗退款申请，审批通过后将自动恢复权益')
      visible.value = false
      emit('success')
    } catch (e) {
      uiMessage.error(getUserFriendlyErrorMessage(e))
    }
  })
}

function orderLabel(order: TreatOrderDetail): string {
  const name = order.customerName || `客户#${order.customerId ?? '—'}`
  return `${name} ${maskMobile(order.customerMobile)}`
}

function firstItemName(order: TreatOrderDetail): string {
  const item = order.items?.[0]
  return item?.itemName || item?.projectName || '消耗明细'
}
</script>

<template>
  <el-dialog
    v-model="visible"
    title="退消耗申请"
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
          placeholder="输入订单号 / 客户 / 项目关键字，自动搜索"
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
              <el-tag
                v-if="selectedOrderId === order.id"
                size="small"
                type="warning"
              >
                已选
              </el-tag>
              <el-tag v-else size="small" effect="plain">
                {{ formatTreatBillStatus(order.billStatus) }}
              </el-tag>
            </div>
            <div class="row2">{{ order.id }}</div>
            <div class="row3">{{ orderLabel(order) }}</div>
            <div class="row4">
              {{ firstItemName(order) }}
              · {{ formatMoney(order.amount) }}
            </div>
          </button>
          <div v-if="loadingMore" class="list-foot">加载中…</div>
          <div v-else-if="hasMore && orders.length" class="list-foot">下拉加载更多</div>
          <div v-else-if="!searching && orders.length" class="list-foot">已全部加载</div>
          <div v-if="!searching && orders.length === 0" class="empty">
            请搜索已完成的消耗订单
          </div>
        </div>
      </aside>

      <main class="right" v-loading="loadingPreview">
        <template v-if="preview">
          <section class="section">
            <div class="meta">
              <div>消耗订单：{{ preview.sourceOrderId }}</div>
              <div>客户：{{ preview.customerName || preview.customerId || '—' }}</div>
              <div>消耗时间：{{ formatDateTime(preview.saleTime) }}</div>
              <div>消耗金额：{{ formatMoney(preview.saleAmount) }}</div>
            </div>
            <el-alert
              type="info"
              :closable="false"
              show-icon
              class="mb8"
              title="消耗退款仅支持整单，审批通过后自动恢复权益；不处理库存、不冲业绩。"
            />
          </section>

          <section class="section">
            <h4>退款明细（整单）</h4>
            <el-table :data="lines" border size="small" max-height="320" empty-text="无明细">
              <el-table-column label="类型" width="90">
                <template #default="{ row }">{{ row.accountTypeName || row.accountType }}</template>
              </el-table-column>
              <el-table-column label="名称" min-width="140" show-overflow-tooltip>
                <template #default="{ row }">{{ row.itemName || row.itemId || '—' }}</template>
              </el-table-column>
              <el-table-column label="持有人" min-width="110" show-overflow-tooltip>
                <template #default="{ row }">
                  {{ row.holderCustomerName || row.holderCustomerId || '—' }}
                </template>
              </el-table-column>
              <el-table-column label="数量" width="80" align="right" prop="originalQty" />
              <el-table-column label="金额" width="100" align="right">
                <template #default="{ row }">
                  <template v-if="row.accountType === 'SAVING_CARD'">
                    本金 {{ formatMoney(row.principalAmount) }} /
                    赠送 {{ formatMoney(row.bonusAmount) }}
                  </template>
                  <template v-else>{{ formatMoney(row.maxRefundableAmount ?? row.originalAmount) }}</template>
                </template>
              </el-table-column>
              <el-table-column label="有效期" min-width="120">
                <template #default="{ row }">
                  {{ row.validDate ? formatDateTime(row.validDate) : '—' }}
                </template>
              </el-table-column>
            </el-table>
          </section>

          <section class="section">
            <el-input
              v-model="reason"
              type="textarea"
              :rows="3"
              maxlength="200"
              show-word-limit
              placeholder="请输入备注信息"
            />
          </section>
        </template>
        <div v-else class="empty-right">从左侧选择消耗订单后，在此确认整单退款</div>
      </main>
    </div>

    <template #footer>
      <div class="footer">
        <div class="amt">
          待退款金额：
          <strong>¥ {{ totalAmount.toFixed(2) }}</strong>
        </div>
        <div class="btns">
          <el-button :disabled="submitting" @click="clearDraft">清空</el-button>
          <el-button
            type="primary"
            :loading="submitting"
            :disabled="loadingPreview || !preview"
            @click="onSubmit"
          >
            提交申请
          </el-button>
        </div>
      </div>
    </template>
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

<style>
.refund-apply-dialog.el-dialog .el-dialog__body,
.el-dialog.refund-apply-dialog .el-dialog__body {
  overflow: hidden;
  padding-top: 12px;
  padding-bottom: 8px;
}
</style>
