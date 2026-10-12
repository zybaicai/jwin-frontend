<script setup lang="ts">
import { computed } from 'vue'

import type { CustomerAvailableAssets, TreatOrderDetail } from '@/types/treat'
import { formatAmountDisplay } from '@/utils/amount'

defineOptions({ name: 'TreatOrderResultDialog' })

const props = defineProps<{
  modelValue: boolean
  order: TreatOrderDetail | null
  assets: CustomerAvailableAssets | null
  loading?: boolean
}>()

const emit = defineEmits<{
  'update:modelValue': [boolean]
  nextOrder: []
  refresh: []
  refreshAssets: []
}>()

const visible = computed({
  get: () => props.modelValue,
  set: (v: boolean) => emit('update:modelValue', v),
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
</script>

<template>
  <el-dialog
    v-model="visible"
    title="消耗单结果"
    width="640px"
    append-to-body
    :close-on-click-modal="false"
    destroy-on-close
  >
    <div v-loading="loading">
      <template v-if="order">
        <div class="status-row">
          <el-tag type="success" size="large">{{ order.billStatus || '已完成' }}</el-tag>
          <span class="hint">开单成功即扣减权益（非草稿）</span>
        </div>

        <el-descriptions :column="2" border size="small" class="desc">
          <el-descriptions-item label="消耗单号">{{ order.id }}</el-descriptions-item>
          <el-descriptions-item label="业务时间">{{ order.billDate || '—' }}</el-descriptions-item>
          <el-descriptions-item label="客户 ID">{{ order.customerId ?? '—' }}</el-descriptions-item>
          <el-descriptions-item label="合计金额">
            ¥{{ formatAmountDisplay(order.amount) }}
          </el-descriptions-item>
        </el-descriptions>

        <div class="block-title">消耗明细</div>
        <el-table :data="order.items || []" size="small" border max-height="240">
          <el-table-column prop="itemType" label="类型" width="110" />
          <el-table-column label="账户" width="88" align="right">
            <template #default="{ row }">{{ row.accountId ?? '—' }}</template>
          </el-table-column>
          <el-table-column label="名称/项目" min-width="140" show-overflow-tooltip>
            <template #default="{ row }">
              {{ row.itemName || row.projectName || (row.projectId ? `项目#${row.projectId}` : '—') }}
            </template>
          </el-table-column>
          <el-table-column prop="quantity" label="数量" width="64" align="right" />
          <el-table-column label="扣次" width="64" align="right">
            <template #default="{ row }">{{ row.cardTreatTimes ?? '—' }}</template>
          </el-table-column>
          <el-table-column label="金额" width="96" align="right">
            <template #default="{ row }">¥{{ formatAmountDisplay(row.totalAmount) }}</template>
          </el-table-column>
        </el-table>

        <div class="block-title">提交后客户可用权益（刷新）</div>
        <div v-if="assetSummary" class="asset-chips">
          <span>项目账户 {{ assetSummary.projects }}</span>
          <span>通用次卡 {{ assetSummary.general }}</span>
          <span>时效卡 {{ assetSummary.time }}</span>
          <span>储值卡 {{ assetSummary.saving }}</span>
          <span>套餐卡 {{ assetSummary.packages }}</span>
        </div>
        <p v-else class="fine">点击下方「刷新权益」重新加载 available-assets。</p>
      </template>
      <el-empty v-else description="无消耗单数据" />
    </div>

    <template #footer>
      <el-button :loading="loading" @click="emit('refresh')">刷新单据</el-button>
      <el-button :loading="loading" @click="emit('refreshAssets')">刷新权益</el-button>
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
  margin: 0;
  font-size: 12px;
  color: #666;
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
