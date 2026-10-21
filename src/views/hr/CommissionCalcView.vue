<script setup lang="ts">
import { computed, ref } from 'vue'

import {
  calculateCommission,
  fetchCommissionDetails as fetchDetails,
  fetchCommissionResult,
  fetchOrganizationTree,
  previewCommission,
  type OrganizationTreeNode,
} from '@/api/hr'
import type { CommissionDetailRecord, CommissionResultRecord } from '@/types/hr'
import { usePermissionStore } from '@/stores/permission'
import { getUserFriendlyErrorMessage, notifyError, runExclusive, uiConfirm, uiMessage } from '@/utils/ui'

/**
 * 人事绩效 → 业绩提成 → 提成计算（C2-5）。
 * 试算（不落库） / 正式计算（重算幂等，月快照整体重建）+ 展开明细计算解释。
 */
defineOptions({ name: 'CommissionCalcView' })

const permissionStore = usePermissionStore()
const hasViewPermission = computed(() => permissionStore.hasPermission('commission:view'))
const hasCalculatePermission = computed(() => permissionStore.hasPermission('commission:calculate'))

const month = ref<string>(new Date().toISOString().slice(0, 7))
const stores = ref<OrganizationTreeNode[]>([])
const storeId = ref<number | null>(null)
const storeError = ref<string | null>(null)
const loadError = ref<string | null>(null)
const loading = ref(false)

const result = ref<CommissionResultRecord | null>(null)
const details = ref<CommissionDetailRecord[]>([])
const detailsEmployeeId = ref<string>('')
const detailsLoading = ref(false)

const employeeRows = computed(() => result.value?.employees ?? [])

async function loadStores(): Promise<void> {
  try {
    const tree = await fetchOrganizationTree()
    const found: OrganizationTreeNode[] = []
    const walk = (nodes: OrganizationTreeNode[]): void => {
      for (const n of nodes) {
        if (n.store) {
          found.push(n)
        }
        if (n.children?.length) {
          walk(n.children)
        }
      }
    }
    walk(tree)
    stores.value = found
    if (found.length > 0 && storeId.value == null) {
      storeId.value = found[0].id
    }
    if (found.length === 0) {
      storeError.value = '当前账号没有可用门店，请联系管理员检查数据权限'
    }
  } catch (error) {
    storeError.value = getUserFriendlyErrorMessage(error)
  }
}

if (hasViewPermission.value) {
  void loadStores()
}

function assertReady(): boolean {
  if (storeId.value == null || !month.value) {
    notifyError('请选择月份和门店')
    return false
  }
  return true
}

async function loadSnapshot(): Promise<void> {
  if (!assertReady()) return
  await runExclusive(loading, async () => {
    loadError.value = null
    try {
      const [r, d] = await Promise.all([
        fetchCommissionResult(month.value, storeId.value!),
        fetchDetails({ month: month.value, storeId: storeId.value! }),
      ])
      result.value = r
      details.value = d
    } catch (error) {
      result.value = null
      details.value = []
      loadError.value = getUserFriendlyErrorMessage(error)
    }
  })
}

async function handlePreview(): Promise<void> {
  if (!assertReady()) return
  await runExclusive(loading, async () => {
    loadError.value = null
    try {
      result.value = await previewCommission({ month: month.value, storeId: storeId.value! })
      await loadDetails()
      uiMessage.success('试算完成（不落库，不修改正式快照）')
    } catch (error) {
      result.value = null
      loadError.value = getUserFriendlyErrorMessage(error)
    }
  })
}

async function handleCalculate(): Promise<void> {
  if (!assertReady()) return
  const confirmed = await uiConfirm({
    title: '正式计算提成',
    message: `将重建 ${month.value} 门店 ${storeId.value} 的月提成快照（同月重复计算结果一致；本月原有快照会被整体替换）。`,
  })
  if (!confirmed) return
  await runExclusive(loading, async () => {
    loadError.value = null
    try {
      result.value = await calculateCommission({ month: month.value, storeId: storeId.value! })
      await loadDetails()
      uiMessage.success('正式计算完成（快照已重建）')
    } catch (error) {
      loadError.value = getUserFriendlyErrorMessage(error)
    }
  })
}

async function loadDetails(): Promise<void> {
  detailsLoading.value = true
  try {
    details.value = await fetchDetails({
      month: month.value,
      storeId: storeId.value!,
      employeeId: detailsEmployeeId.value || undefined,
    })
  } catch {
    details.value = []
  } finally {
    detailsLoading.value = false
  }
}

function handleQueryDetails(): void {
  if (!assertReady()) return
  void loadDetails()
}

function fmt(v: number | null | undefined): string {
  return (v ?? 0).toLocaleString('zh-CN', { minimumFractionDigits: 2, maximumFractionDigits: 2 })
}
</script>

<template>
  <div class="page">
    <div class="calc-toolbar">
      <div class="toolbar-item">
        <span class="toolbar-label">月份</span>
        <el-date-picker v-model="month" type="month" value-format="YYYY-MM" :clearable="false" style="width: 140px" />
      </div>
      <div class="toolbar-item">
        <span class="toolbar-label">门店</span>
        <el-select v-model="storeId" placeholder="选择门店" style="width: 220px">
          <el-option v-for="s in stores" :key="s.id" :value="s.id" :label="`${s.entityName ?? ''}（${s.id}）`" />
        </el-select>
      </div>
      <el-button :loading="loading" @click="loadSnapshot">查询快照</el-button>
      <el-button type="primary" :loading="loading" :disabled="!hasViewPermission" @click="handlePreview">
        试算（不落库）
      </el-button>
      <el-button
        type="danger"
        :loading="loading"
        :disabled="!hasCalculatePermission"
        @click="handleCalculate"
      >正式计算</el-button>
    </div>

    <el-alert
      v-if="!hasViewPermission"
      title="暂无权限查看提成（commission:view）"
      type="warning"
      show-icon
      :closable="false"
    />
    <el-alert v-else-if="storeError" :title="storeError" type="error" show-icon :closable="false" />
    <el-alert v-else-if="loadError" :title="loadError" type="error" show-icon :closable="false" />
    <el-alert
      v-if="hasViewPermission && (result?.anomalies?.length ?? 0) > 0"
      title="存在无法匹配原销售行的退款，提成无法准确计算"
      type="error"
      show-icon
      :closable="false"
    />

    <template v-if="hasViewPermission && !storeError && !loadError">
      <div v-if="result" class="calc-summary">
        <span>销售行数：{{ result.saleLineCount ?? '—' }}</span>
        <span>划卡行数：{{ result.treatLineCount ?? '—' }}</span>
        <span>员工数：{{ employeeRows.length }}</span>
      </div>

      <el-card shadow="never">
        <template #header><span class="card-title">员工提成汇总</span></template>
        <el-table :data="employeeRows" border stripe :loading="loading">
          <el-table-column prop="employeeId" label="员工ID" width="120" />
          <el-table-column label="销售业绩基数" align="right" width="140">
            <template #default="{ row }">{{ fmt(row.saleBase) }}</template>
          </el-table-column>
          <el-table-column label="销售提成" align="right" width="130">
            <template #default="{ row }">{{ fmt(row.saleCommission) }}</template>
          </el-table-column>
          <el-table-column label="划卡业绩基数" align="right" width="140">
            <template #default="{ row }">{{ fmt(row.treatBase) }}</template>
          </el-table-column>
          <el-table-column label="划卡提成" align="right" width="130">
            <template #default="{ row }">{{ fmt(row.treatCommission) }}</template>
          </el-table-column>
          <el-table-column label="合计提成" align="right" width="140">
            <template #default="{ row }">
              <span class="total-cell">{{ fmt(row.totalCommission) }}</span>
            </template>
          </el-table-column>
          <template #empty>
            <el-empty description="暂无数据：未配置提成规则时各类型提成为 0；请先 选择月份/门店 → 查询快照 或 试算" />
          </template>
        </el-table>
      </el-card>

      <el-card shadow="never">
        <template #header>
          <div class="details-header">
            <span class="card-title">计算明细与解释</span>
            <div class="details-filter">
              <el-input
                v-model="detailsEmployeeId"
                placeholder="按员工ID过滤（可空）"
                clearable
                style="width: 200px"
              />
              <el-button :loading="detailsLoading" @click="handleQueryDetails">刷新明细</el-button>
            </div>
          </div>
        </template>
        <el-alert
          type="info"
          :closable="false"
          title="每行=一笔业务单据×员工：业绩基数先按经手人 Scale 拆分，再匹配该品类规则链/月阶梯计提；无规则行提成=0"
        />
        <el-table :data="details" border stripe size="small" style="margin-top: 10px">
          <el-table-column label="场景" width="90">
            <template #default="{ row }">{{ row.scene === 'SALE' ? '销售' : '划卡' }}</template>
          </el-table-column>
          <el-table-column prop="categoryLabel" label="品类" width="110" />
          <el-table-column prop="billDate" label="单据日期" width="100">
            <template #default="{ row }">{{ (row.billDate ?? '').slice(0, 10) }}</template>
          </el-table-column>
          <el-table-column prop="billId" label="单号" width="160" show-overflow-tooltip />
          <el-table-column label="商品/卡项" min-width="140" show-overflow-tooltip>
            <template #default="{ row }">
              <span v-if="row.masterItemName">【{{ row.masterItemName }}】</span>{{ row.itemName ?? '—' }}
            </template>
          </el-table-column>
          <el-table-column prop="employeeId" label="员工" width="90" />
          <el-table-column label="Scale" width="80" align="right">
            <template #default="{ row }">{{ (Number(row.scale ?? 1) * 100).toFixed(0) }}%</template>
          </el-table-column>
          <el-table-column min-width="260" show-overflow-tooltip>
            <template #header>规则（计算解释）</template>
            <template #default="{ row }">{{ row.ruleDesc ?? '—' }}</template>
          </el-table-column>
          <el-table-column label="计提明细（基数×率 + 固定）" min-width="330">
            <template #default="{ row }">
              <div v-for="p in row.parts" :key="p.bucket" class="part-row">
                <template v-if="Number(p.amount ?? 0) > 0">
                  <span class="part-bucket">{{ p.bucketLabel ?? p.bucket }}</span>
                  <span>基数 {{ fmt(p.base) }}</span>
                  <span>率 {{ (Number(p.rate ?? 0) * 100).toFixed(2) }}%</span>
                  <span v-if="Number(p.fixed ?? 0) > 0">固定 {{ fmt(p.fixed) }}</span>
                  <span class="part-amount">{{ fmt(p.amount) }}</span>
                </template>
              </div>
            </template>
          </el-table-column>
          <el-table-column label="提成金额" width="110" align="right" fixed="right">
            <template #default="{ row }">
              <span class="total-cell">{{ fmt(row.totalAmount) }}</span>
            </template>
          </el-table-column>
          <template #empty>
            <el-empty :description="detailsLoading ? '加载中…' : '暂无明细（试算或正式计算后展示）'" />
          </template>
        </el-table>
      </el-card>
    </template>
  </div>
</template>

<style scoped>
.page {
  display: flex;
  flex-direction: column;
  gap: 12px;
  height: 100%;
  overflow-y: auto;
}

.calc-toolbar {
  display: flex;
  align-items: center;
  gap: 12px;
  flex-wrap: wrap;
}

.toolbar-item {
  display: flex;
  align-items: center;
  gap: 8px;
}

.toolbar-label {
  color: var(--el-text-color-regular);
  font-weight: 600;
}

.calc-summary {
  display: flex;
  gap: 18px;
  color: var(--el-text-color-secondary);
  font-size: 13px;
}

.card-title {
  font-weight: 600;
}

.details-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  flex-wrap: wrap;
  gap: 10px;
}

.details-filter {
  display: flex;
  gap: 8px;
  align-items: center;
}

.total-cell {
  font-weight: 600;
  color: var(--el-color-primary);
  font-variant-numeric: tabular-nums;
}

.part-row {
  display: flex;
  gap: 10px;
  font-variant-numeric: tabular-nums;
  font-size: 12px;
  color: var(--el-text-color-regular);
  padding: 1px 0;
}

.part-bucket {
  color: var(--el-text-color-secondary);
}

.part-amount {
  color: var(--el-color-primary);
  font-weight: 600;
}
</style>