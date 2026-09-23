<script setup lang="ts">
import { ref, watch } from 'vue'

import AppEmpty from '@/components/common/AppEmpty.vue'
import AppError from '@/components/common/AppError.vue'
import { fetchSaleOrderDetail } from '@/api/sale'
import type { SaleOrderDetail } from '@/types/sale'
import { getUserFriendlyErrorMessage, runExclusive } from '@/utils/ui'
import { formatDateTime, formatMoney } from '@/views/customer/customer-format'

defineOptions({ name: 'SaleOrderDetailDialog' })

const visible = defineModel<boolean>({ default: false })

const props = defineProps<{
  orderId: string | null
}>()

const loading = ref(false)
const loadError = ref<string | null>(null)
const detail = ref<SaleOrderDetail | null>(null)

function resetState(): void {
  detail.value = null
  loadError.value = null
}

async function loadDetail(): Promise<void> {
  if (props.orderId == null || props.orderId === '') {
    loadError.value = '订单编号无效'
    detail.value = null
    return
  }
  await runExclusive(loading, async () => {
    loadError.value = null
    try {
      detail.value = await fetchSaleOrderDetail(props.orderId!)
    } catch (error) {
      detail.value = null
      loadError.value = getUserFriendlyErrorMessage(error)
    }
  })
}

watch(visible, (open) => {
  if (!open) {
    resetState()
    return
  }
  resetState()
  void loadDetail()
})
</script>

<template>
  <el-dialog
    v-model="visible"
    class="sale-order-detail-dialog"
    title="销售订单详情"
    width="760px"
    append-to-body
    destroy-on-close
    :close-on-click-modal="false"
  >
    <AppError
      v-if="loadError && !loading"
      :description="loadError"
      @retry="loadDetail"
    />
    <div v-else v-loading="loading" class="detail-body">
      <template v-if="detail">
        <section class="section">
          <h3 class="section-title">订单基础信息</h3>
          <dl class="field-grid">
            <div class="field-row">
              <dt>订单编号</dt>
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
              <dt>订单时间</dt>
              <dd>{{ formatDateTime(detail.billDate) }}</dd>
            </div>
            <div class="field-row">
              <dt>客户</dt>
              <dd>{{ detail.customerName || '—' }}</dd>
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
              <dd>{{ detail.saleStoreName || '—' }}</dd>
            </div>
            <div class="field-row">
              <dt>顾客归属门店</dt>
              <dd>{{ detail.customerBelongStoreName || '—' }}</dd>
            </div>
          </dl>
        </section>

        <section class="section">
          <h3 class="section-title">销售方式与金额</h3>
          <dl class="field-grid">
            <div class="field-row">
              <dt>销售渠道</dt>
              <dd>{{ detail.saleChannelCode || '—' }}</dd>
            </div>
            <div class="field-row">
              <dt>订单总金额</dt>
              <dd>{{ formatMoney(detail.totalAmount) }}</dd>
            </div>
            <div class="field-row">
              <dt>实付金额</dt>
              <dd>{{ formatMoney(detail.payAmount) }}</dd>
            </div>
            <div class="field-row">
              <dt>欠款金额</dt>
              <dd class="is-danger">{{ formatMoney(detail.arrearAmount) }}</dd>
            </div>
          </dl>
        </section>

        <section class="section">
          <h3 class="section-title">商品明细</h3>
          <el-table :data="detail.items" border stripe size="small" empty-text="暂无明细">
            <el-table-column prop="itemName" label="名称" min-width="140" show-overflow-tooltip>
              <template #default="{ row }">
                {{ row.itemName || '—' }}
              </template>
            </el-table-column>
            <el-table-column prop="itemType" label="类型" min-width="100" show-overflow-tooltip>
              <template #default="{ row }">
                {{ row.itemType || '—' }}
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
          <h3 class="section-title">支付渠道</h3>
          <el-table :data="detail.payments" border stripe size="small" empty-text="暂无支付记录">
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
      </template>
      <AppEmpty v-else-if="!loading" title="暂无订单详情" />
    </div>
  </el-dialog>
</template>

<style scoped>
.detail-body {
  min-height: 160px;
}

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

.is-danger {
  color: #f56c6c;
}
</style>
