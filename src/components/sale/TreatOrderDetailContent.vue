<script setup lang="ts">
import { computed } from 'vue'

import {
  formatTreatBillStatus,
  formatTreatBillType,
  TreatItemType,
  type TreatOrderDetail,
  type TreatOrderItem,
} from '@/types/treat'
import { formatDateTime, formatMoney, maskMobile } from '@/views/customer/customer-format'

defineOptions({ name: 'TreatOrderDetailContent' })

const props = defineProps<{
  detail: TreatOrderDetail
}>()

function customerLabel(detail: TreatOrderDetail): string {
  const name = detail.customerName?.trim() || '—'
  const mobile = maskMobile(detail.customerMobile)
  if (mobile && mobile !== '—') {
    return `${name} (${mobile})`
  }
  return name
}

function itemTitle(row: {
  projectName?: string | null
  itemName?: string | null
  itemCode?: string | null
}): string {
  const name = row.projectName || row.itemName || '—'
  if (row.itemCode) {
    return `${name}（${row.itemCode}）`
  }
  return name
}

/** 按明细类型汇总「结算方式」只读口径（当前无独立现金流水时，现金视为 0） */
const settlementSummary = computed(() => {
  const items = props.detail.items ?? []
  let equity = 0
  let saving = 0
  for (const item of items) {
    const amt = Number(item.totalAmount ?? 0)
    if (!Number.isFinite(amt)) {
      continue
    }
    if (item.itemType === TreatItemType.SAVING_CARD) {
      saving += amt
    } else {
      // PROJECT / GENERAL_CARD / TIME_CARD：权益抵扣（次数/项目余额）
      equity += amt
    }
  }
  return {
    equity,
    saving,
    cash: 0,
  }
})

function settlementLabel(item: TreatOrderItem): string {
  if (item.itemType === TreatItemType.SAVING_CARD) {
    return '储值支付'
  }
  if (
    item.itemType === TreatItemType.PROJECT ||
    item.itemType === TreatItemType.GENERAL_CARD ||
    item.itemType === TreatItemType.TIME_CARD
  ) {
    return '权益抵扣'
  }
  return '—'
}
</script>

<template>
  <div class="treat-order-detail-content">
    <section class="section">
      <h3 class="section-title">订单信息</h3>
      <dl class="field-grid">
        <div class="field-row">
          <dt>订单编号</dt>
          <dd>{{ detail.id || '—' }}</dd>
        </div>
        <div class="field-row">
          <dt>订单类型</dt>
          <dd>{{ formatTreatBillType(detail.billType) }}</dd>
        </div>
        <div class="field-row">
          <dt>订单状态</dt>
          <dd>{{ formatTreatBillStatus(detail.billStatus) }}</dd>
        </div>
        <div class="field-row">
          <dt>顾客信息</dt>
          <dd>{{ customerLabel(detail) }}</dd>
        </div>
        <div class="field-row">
          <dt>录单人</dt>
          <dd>{{ detail.employeeName || detail.employeeId || '—' }}</dd>
        </div>
        <div class="field-row">
          <dt>消耗金额</dt>
          <dd>{{ formatMoney(detail.amount) }}</dd>
        </div>
        <div class="field-row">
          <dt>下单时间</dt>
          <dd>{{ formatDateTime(detail.billDate) }}</dd>
        </div>
        <div class="field-row">
          <dt>录单时间</dt>
          <dd>{{ formatDateTime(detail.createdOn) }}</dd>
        </div>
        <div class="field-row">
          <dt>订单备注</dt>
          <dd>{{ detail.remark || '—' }}</dd>
        </div>
      </dl>
    </section>

    <section class="section">
      <h3 class="section-title">消耗信息</h3>
      <el-table :data="detail.items || []" border stripe size="small" empty-text="暂无消耗明细">
        <el-table-column label="项目" min-width="200" show-overflow-tooltip>
          <template #default="{ row }">
            <div class="item-cell">
              <span>{{ itemTitle(row) }}</span>
              <span v-if="row.itemType" class="muted">{{ row.itemType }}</span>
              <span v-if="row.sourceSaleBillId" class="muted">
                来源销售单：{{ row.sourceSaleBillId }}
              </span>
            </div>
          </template>
        </el-table-column>
        <el-table-column label="数量" width="80" align="right">
          <template #default="{ row }">
            x{{ row.quantity != null ? row.quantity : '—' }}
          </template>
        </el-table-column>
        <el-table-column label="优惠金额" min-width="100" align="right">
          <template #default="{ row }">
            {{ formatMoney(row.preferentialAmount) }}
          </template>
        </el-table-column>
        <el-table-column label="结算方式" min-width="100">
          <template #default="{ row }">
            {{ settlementLabel(row) }}
          </template>
        </el-table-column>
        <el-table-column label="小计" min-width="100" align="right">
          <template #default="{ row }">
            {{ formatMoney(row.totalAmount) }}
          </template>
        </el-table-column>
      </el-table>
    </section>

    <section class="section">
      <h3 class="section-title">消耗金额与结算方式</h3>
      <p class="hint">
        「消耗金额」为本次消耗对应的权益价值，不等于本次现金收款。销售时已付款的套餐/项目再次消耗时，现金支付通常为 0。
      </p>
      <dl class="field-grid">
        <div class="field-row">
          <dt>消耗金额</dt>
          <dd>{{ formatMoney(detail.amount) }}</dd>
        </div>
        <div class="field-row">
          <dt>权益抵扣</dt>
          <dd>{{ formatMoney(settlementSummary.equity) }}</dd>
        </div>
        <div class="field-row">
          <dt>储值支付</dt>
          <dd>{{ formatMoney(settlementSummary.saving) }}</dd>
        </div>
        <div class="field-row">
          <dt>现金支付</dt>
          <dd>
            {{ formatMoney(settlementSummary.cash) }}
            <span class="muted">（当前无独立现金流水，只读占位）</span>
          </dd>
        </div>
      </dl>
    </section>

    <section class="section">
      <h3 class="section-title">消耗经手人</h3>
      <dl class="field-grid">
        <div class="field-row">
          <dt>经手人</dt>
          <dd>
            <template v-if="detail.handlers && detail.handlers.length">
              <span
                v-for="(h, idx) in detail.handlers"
                :key="h.employeeId || idx"
              >
                {{ h.employeeName || h.employeeId || '—' }}
                <template v-if="h.ratio != null && h.ratio !== ''">
                  （{{ h.ratio }}%）
                </template>
                <template v-if="idx < detail.handlers.length - 1">、</template>
              </span>
            </template>
            <template v-else>—</template>
          </dd>
        </div>
      </dl>
    </section>
  </div>
</template>

<style scoped>
.section {
  margin-bottom: 16px;
}

.section-title {
  margin: 0 0 8px;
  color: #303133;
  font-size: 14px;
  font-weight: 600;
}

.field-grid {
  margin: 0;
  border-top: 1px solid #ebeef5;
}

.field-row {
  display: grid;
  grid-template-columns: 110px 1fr;
  gap: 8px;
  padding: 8px 0;
  border-bottom: 1px solid #ebeef5;
}

.field-row dt {
  color: #909399;
  font-size: 13px;
}

.field-row dd {
  margin: 0;
  color: #303133;
  font-size: 14px;
  word-break: break-all;
}

.item-cell {
  display: flex;
  flex-direction: column;
  gap: 2px;
  line-height: 1.35;
}

.muted {
  color: #909399;
  font-size: 12px;
}

.hint {
  margin: 0 0 8px;
  color: #909399;
  font-size: 12px;
  line-height: 1.5;
}
</style>
