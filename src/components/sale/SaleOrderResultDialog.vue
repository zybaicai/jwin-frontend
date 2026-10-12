<script setup lang="ts">
import { computed } from 'vue'

import type { SaleOrderDetail } from '@/types/sale'
import type { CustomerAvailableAssets } from '@/types/treat'
import { formatAmountDisplay } from '@/utils/amount'

defineOptions({ name: 'SaleOrderResultDialog' })

const props = defineProps<{
  modelValue: boolean
  order: SaleOrderDetail | null
  /** 收款后拉取的客户可用资产摘要（可选） */
  assets: CustomerAvailableAssets | null
  assetsNote: string | null
  loading?: boolean
}>()

const emit = defineEmits<{
  'update:modelValue': [boolean]
  nextOrder: []
  refresh: []
  viewConsume: []
  /** 对待支付订单继续登记收款 */
  registerPay: []
  /** 跳转销售订单详情页 */
  viewOrder: []
}>()

const visible = computed({
  get: () => props.modelValue,
  set: (v: boolean) => emit('update:modelValue', v),
})

const unpaid = computed(() => {
  const s = props.order?.billStatus
  return s === '待支付' || s === '草稿'
})

const assetSummary = computed(() => {
  const a = props.assets
  if (!a) {
    return null
  }
  return {
    projects: a.projects?.length ?? 0,
    general: a.generalCards?.length ?? 0,
    time: a.timeCards?.length ?? 0,
    saving: a.saving?.length ?? 0,
    packages: a.packageCards?.length ?? 0,
  }
})

/** 仅汇总项目明细渠道；纯卡/产品为空 */
const projectChannelSummary = computed(() => {
  const codes = (props.order?.items || [])
    .filter((it) => String(it.itemType || '').toUpperCase() === 'PROJECT')
    .map((it) => it.saleChannelCode?.trim() || null)
    .filter((c): c is string => !!c)
  const uniq = [...new Set(codes)]
  if (uniq.length === 0) return null
  if (uniq.length === 1) return uniq[0]!
  return uniq.join(' / ')
})
</script>

<template>
  <el-dialog
    v-model="visible"
    title="销售单结果"
    width="640px"
    append-to-body
    :close-on-click-modal="false"
    destroy-on-close
  >
    <div v-loading="loading">
      <template v-if="order">
        <div class="status-row">
          <el-tag :type="unpaid ? 'warning' : 'success'" size="large">
            {{ order.billStatus || '—' }}
          </el-tag>
          <span class="hint">登记收款为人工记账，非第三方在线扣款</span>
        </div>

        <el-descriptions :column="2" border size="small" class="desc">
          <el-descriptions-item label="订单号">{{ order.id }}</el-descriptions-item>
          <el-descriptions-item label="业务时间">{{ order.billDate || '—' }}</el-descriptions-item>
          <el-descriptions-item label="客户">
            {{ order.customerName || order.customerId || '—' }}
          </el-descriptions-item>
          <el-descriptions-item label="销售渠道">
            {{ projectChannelSummary || '—' }}
          </el-descriptions-item>
          <el-descriptions-item label="开单门店">
            {{ order.saleStoreName || order.storeId || '—' }}
          </el-descriptions-item>
          <el-descriptions-item label="应收">
            ¥{{ formatAmountDisplay(order.totalAmount ?? order.amount) }}
          </el-descriptions-item>
          <el-descriptions-item label="已收">
            ¥{{ formatAmountDisplay(order.payAmount) }}
          </el-descriptions-item>
          <el-descriptions-item label="未收/欠款">
            ¥{{ formatAmountDisplay(order.arrearAmount) }}
          </el-descriptions-item>
        </el-descriptions>

        <div class="block-title">销售明细</div>
        <el-table :data="order.items || []" size="small" border max-height="220">
          <el-table-column prop="itemType" label="类型" width="100" />
          <el-table-column prop="itemName" label="名称" min-width="140" show-overflow-tooltip />
          <el-table-column label="渠道" width="88" show-overflow-tooltip>
            <template #default="{ row }">
              {{
                String(row.itemType || '').toUpperCase() === 'PROJECT'
                  ? row.saleChannelCode || '—'
                  : '—'
              }}
            </template>
          </el-table-column>
          <el-table-column prop="quantity" label="数量" width="64" align="right" />
          <el-table-column label="单价" width="88" align="right">
            <template #default="{ row }">¥{{ formatAmountDisplay(row.price) }}</template>
          </el-table-column>
          <el-table-column label="小计" width="96" align="right">
            <template #default="{ row }">¥{{ formatAmountDisplay(row.totalAmount) }}</template>
          </el-table-column>
          <el-table-column label="赠送" width="64" align="center">
            <template #default="{ row }">{{ row.gift ? '是' : '—' }}</template>
          </el-table-column>
        </el-table>

        <div class="block-title">收款记录</div>
        <el-table
          :data="order.payments || []"
          size="small"
          border
          empty-text="暂无收款记录"
          max-height="140"
        >
          <el-table-column prop="payMethodName" label="方式" min-width="120" />
          <el-table-column label="金额" width="120" align="right">
            <template #default="{ row }">¥{{ formatAmountDisplay(row.amount) }}</template>
          </el-table-column>
        </el-table>

        <div class="block-title">权益到账</div>
        <p v-if="unpaid" class="fine">待支付订单尚未发放客户权益；登记收款成功后由后端开户入账。</p>
        <template v-else>
          <p class="fine">
            后端在收款记账成功后发放权益（含欠款场景也会开户；储值按实收本金入账）。
          </p>
          <p v-if="assetsNote" class="fine">{{ assetsNote }}</p>
          <div v-if="assetSummary" class="asset-chips">
            <span>项目账户 {{ assetSummary.projects }}</span>
            <span>通用次卡 {{ assetSummary.general }}</span>
            <span>时效卡 {{ assetSummary.time }}</span>
            <span>储值卡 {{ assetSummary.saving }}</span>
            <span>套餐卡 {{ assetSummary.packages }}</span>
          </div>
        </template>
      </template>
      <el-empty v-else description="无订单数据" />
    </div>

    <template #footer>
      <el-button :loading="loading" @click="emit('refresh')">刷新订单</el-button>
      <el-button v-if="order?.id" @click="emit('viewOrder')">查看订单详情</el-button>
      <el-button v-if="unpaid" type="warning" @click="emit('registerPay')">登记收款</el-button>
      <el-button v-if="!unpaid" @click="emit('viewConsume')">去消耗查看权益</el-button>
      <el-button type="primary" @click="emit('nextOrder')">开始下一单</el-button>
    </template>
  </el-dialog>
</template>

<style scoped>
.status-row {
  display: flex;
  gap: 12px;
  align-items: center;
  margin-bottom: 12px;
}
.hint {
  font-size: 12px;
  color: #999;
}
.desc {
  margin-bottom: 12px;
}
.block-title {
  margin: 12px 0 6px;
  font-weight: 600;
  font-size: 13px;
}
.fine {
  margin: 0 0 8px;
  font-size: 12px;
  color: #666;
  line-height: 1.5;
}
.asset-chips {
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
  font-size: 12px;
}
.asset-chips span {
  padding: 2px 8px;
  background: #f5f5f5;
  border: 1px solid #e8e8e8;
}
</style>
