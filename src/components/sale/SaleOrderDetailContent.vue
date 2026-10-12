<script setup lang="ts">
import type { SaleOrderDetail } from '@/types/sale'
import { formatDateTime, formatMoney } from '@/views/customer/customer-format'

defineOptions({ name: 'SaleOrderDetailContent' })

defineProps<{
  detail: SaleOrderDetail
}>()
</script>

<template>
  <div class="sale-order-detail-content">
    <section class="section">
      <h3 class="section-title">订单基本信息</h3>
      <dl class="field-grid">
        <div class="field-row">
          <dt>销售单号</dt>
          <dd>{{ detail.id || '—' }}</dd>
        </div>
        <div class="field-row">
          <dt>订单状态</dt>
          <dd>{{ detail.billStatus || '—' }}</dd>
        </div>
        <div class="field-row">
          <dt>订单类型</dt>
          <dd>{{ detail.billType || '—' }}</dd>
        </div>
        <div class="field-row">
          <dt>销售时间</dt>
          <dd>{{ formatDateTime(detail.billDate) }}</dd>
        </div>
        <div class="field-row">
          <dt>客户</dt>
          <dd>
            {{ detail.customerName || '—' }}
            <span v-if="detail.customerId != null" class="muted">（ID {{ detail.customerId }}）</span>
          </dd>
        </div>
        <div class="field-row">
          <dt>开单人</dt>
          <dd>{{ detail.employeeName || detail.employeeId || '—' }}</dd>
        </div>
        <div class="field-row">
          <dt>销售经手人</dt>
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
        <div class="field-row">
          <dt>备注</dt>
          <dd>{{ detail.remark || '—' }}</dd>
        </div>
      </dl>
    </section>

    <section class="section">
      <h3 class="section-title">门店信息</h3>
      <dl class="field-grid">
        <div class="field-row">
          <dt>开单门店</dt>
          <dd>{{ detail.saleStoreName || detail.storeId || '—' }}</dd>
        </div>
        <div class="field-row">
          <dt>顾客归属门店</dt>
          <dd>{{ detail.customerBelongStoreName || '—' }}</dd>
        </div>
      </dl>
    </section>

    <section class="section">
      <h3 class="section-title">金额</h3>
      <p class="hint">销售渠道仅项目明细有值（≠ 支付方式）。欠款以金额字段为准。</p>
      <dl class="field-grid">
        <div class="field-row">
          <dt>应收金额</dt>
          <dd>{{ formatMoney(detail.totalAmount ?? detail.amount) }}</dd>
        </div>
        <div class="field-row">
          <dt>已收金额</dt>
          <dd>{{ formatMoney(detail.payAmount) }}</dd>
        </div>
        <div class="field-row">
          <dt>欠款金额</dt>
          <dd class="is-danger">{{ formatMoney(detail.arrearAmount) }}</dd>
        </div>
      </dl>
    </section>

    <section class="section">
      <h3 class="section-title">销售明细</h3>
      <el-table :data="detail.items || []" border stripe size="small" empty-text="暂无明细">
        <el-table-column prop="itemName" label="名称" min-width="140" show-overflow-tooltip>
          <template #default="{ row }">
            {{ row.itemName || '—' }}
          </template>
        </el-table-column>
        <el-table-column prop="itemType" label="类型" min-width="110" show-overflow-tooltip>
          <template #default="{ row }">
            {{ row.itemType || '—' }}
          </template>
        </el-table-column>
        <el-table-column label="销售渠道" min-width="100" show-overflow-tooltip>
          <template #default="{ row }">
            {{
              String(row.itemType || '').toUpperCase() === 'PROJECT'
                ? row.saleChannelCode || '—'
                : '—'
            }}
          </template>
        </el-table-column>
        <el-table-column label="数量" width="80" align="right">
          <template #default="{ row }">
            {{ row.quantity != null ? row.quantity : '—' }}
          </template>
        </el-table-column>
        <el-table-column label="单价" min-width="100" align="right">
          <template #default="{ row }">
            {{ formatMoney(row.price) }}
          </template>
        </el-table-column>
        <el-table-column label="金额" min-width="100" align="right">
          <template #default="{ row }">
            {{ formatMoney(row.totalAmount) }}
          </template>
        </el-table-column>
        <el-table-column label="赠送" width="70" align="center">
          <template #default="{ row }">
            {{ row.gift === true ? '是' : '否' }}
          </template>
        </el-table-column>
      </el-table>
    </section>

    <section class="section">
      <h3 class="section-title">收款记录（支付方式）</h3>
      <el-table
        :data="detail.payments || []"
        border
        stripe
        size="small"
        empty-text="暂无收款记录"
      >
        <el-table-column prop="payMethodName" label="支付方式" min-width="140">
          <template #default="{ row }">
            {{ row.payMethodName || '—' }}
          </template>
        </el-table-column>
        <el-table-column label="金额" min-width="120" align="right">
          <template #default="{ row }">
            {{ formatMoney(row.amount) }}
          </template>
        </el-table-column>
      </el-table>
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

.hint {
  margin: 0 0 8px;
  color: #909399;
  font-size: 12px;
  line-height: 1.5;
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

.muted {
  color: #909399;
  font-size: 12px;
}

.is-danger {
  color: #f56c6c;
}
</style>
