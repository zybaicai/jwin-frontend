<script setup lang="ts">
import { computed, ref, watch } from 'vue'

import AppEmpty from '@/components/common/AppEmpty.vue'
import AppError from '@/components/common/AppError.vue'
import {
  fetchEmployeePage,
  fetchTreatPerformance,
  fetchTreatPerformanceLines,
} from '@/api/hr'
import {
  PerformancePermission,
  type EmployeeRecord,
  type PerformanceEmployeeRow,
  type PerformanceLineResult,
  type PerformanceLineRow,
  type PerformanceQueryResult,
} from '@/types/hr'
import { usePermissionStore } from '@/stores/permission'
import { useStoreStore } from '@/stores/store'
import {
  getUserFriendlyErrorMessage,
  notifyError,
  runExclusive,
} from '@/utils/ui'

defineOptions({ name: 'TreatPerformanceView' })

const permissionStore = usePermissionStore()
const storeStore = useStoreStore()

const hasViewPermission = computed(() =>
  permissionStore.hasPermission(PerformancePermission.VIEW),
)

const loading = ref(false)
const listError = ref<string | null>(null)
const dateRange = ref<[string, string] | null>(null)
const employeeId = ref<string | null>(null)
const itemType = ref<string | null>(null)
const employeeOptions = ref<EmployeeRecord[]>([])
const result = ref<PerformanceQueryResult | null>(null)
const linesResult = ref<PerformanceLineResult | null>(null)

const ITEM_TYPE_OPTIONS = [
  { value: 'PROJECT', label: '项目' },
  { value: 'GENERAL_CARD', label: '次卡' },
  { value: 'TIME_CARD', label: '时效卡' },
  { value: 'SAVING_CARD', label: '储值卡' },
]

function formatAmount(v: number | null | undefined): string {
  if (v == null || Number.isNaN(Number(v))) return '—'
  return Number(v).toFixed(2)
}

function rowOf(row: unknown): PerformanceEmployeeRow {
  return row as PerformanceEmployeeRow
}

function lineOf(row: unknown): PerformanceLineRow {
  return row as PerformanceLineRow
}

function itemTypeLabel(t: string | null | undefined): string {
  return ITEM_TYPE_OPTIONS.find((x) => x.value === t)?.label || t || '—'
}

async function loadEmployees(): Promise<void> {
  const storeId = storeStore.currentStoreId
  if (storeId == null) {
    employeeOptions.value = []
    return
  }
  try {
    const data = await fetchEmployeePage({
      entityId: storeId,
      state: true,
      page: 1,
      size: 200,
    })
    employeeOptions.value = data.records ?? []
  } catch {
    employeeOptions.value = []
  }
}

async function loadData(): Promise<void> {
  if (!hasViewPermission.value) {
    result.value = null
    listError.value = '暂无权限查看业绩（performance:view）'
    return
  }
  await runExclusive(loading, async () => {
    listError.value = null
    try {
      const params = {
        from: dateRange.value?.[0],
        to: dateRange.value?.[1],
        employeeId: employeeId.value || undefined,
      }
      const [summary, lines] = await Promise.all([
        fetchTreatPerformance(params),
        fetchTreatPerformanceLines({
          ...params,
          itemType: itemType.value || undefined,
        }),
      ])
      result.value = summary
      linesResult.value = lines
    } catch (error) {
      result.value = null
      linesResult.value = null
      listError.value = getUserFriendlyErrorMessage(error)
      notifyError(error)
    }
  })
}

function handleReset(): void {
  dateRange.value = null
  employeeId.value = null
  itemType.value = null
  void loadData()
}

watch(
  hasViewPermission,
  async (ok) => {
    if (ok) await loadEmployees()
    void loadData()
  },
  { immediate: true },
)

watch(
  () => storeStore.currentStoreId,
  () => {
    void loadEmployees()
  },
)
</script>

<template>
  <section class="treat-performance">

    <el-alert
      type="info"
      :closable="false"
      show-icon
      title="汇总来自 /performance/treat；明细来自 /performance/treat/lines（0 DDL）。占比为开单经手 Scale，不是提成率。"
    />

    <div class="filter-bar">
      <el-form :inline="true" class="filter-form" @submit.prevent="loadData">
        <el-form-item label="日期">
          <el-date-picker
            v-model="dateRange"
            type="daterange"
            value-format="YYYY-MM-DD"
            start-placeholder="开始"
            end-placeholder="结束"
            style="width: 260px"
          />
        </el-form-item>
        <el-form-item label="员工">
          <el-select
            v-model="employeeId"
            clearable
            filterable
            placeholder="全部"
            style="width: 200px"
          >
            <el-option
              v-for="e in employeeOptions"
              :key="e.id"
              :label="`${e.name}（${e.id}）`"
              :value="e.id"
            />
          </el-select>
        </el-form-item>
        <el-form-item label="业务类型">
          <el-select v-model="itemType" clearable placeholder="全部" style="width: 140px">
            <el-option
              v-for="opt in ITEM_TYPE_OPTIONS"
              :key="opt.value"
              :label="opt.label"
              :value="opt.value"
            />
          </el-select>
        </el-form-item>
        <el-form-item>
          <el-button type="primary" native-type="submit" :loading="loading">查询</el-button>
          <el-button native-type="button" :disabled="loading" @click="handleReset">重置</el-button>
        </el-form-item>
      </el-form>
    </div>

    <div v-loading="loading" class="table-panel">
      <AppError
        v-if="listError && !loading"
        :description="listError"
        @retry="loadData"
      />
      <template v-else-if="result">
        <el-descriptions :column="3" border size="small" class="store-totals">
          <el-descriptions-item label="区间">
            {{ result.fromDate || '—' }} ~ {{ result.toDate || '—' }}
          </el-descriptions-item>
          <el-descriptions-item label="门店">
            {{ result.storeId ?? storeStore.currentStoreId ?? '—' }}
          </el-descriptions-item>
          <el-descriptions-item label="客数">
            {{ result.guestCount ?? '—' }}
          </el-descriptions-item>
          <el-descriptions-item label="现金/实收">
            {{ formatAmount(result.payAmount) }}
          </el-descriptions-item>
          <el-descriptions-item label="卡耗">
            {{ formatAmount(result.cardAmount) }}
          </el-descriptions-item>
          <el-descriptions-item label="赠送">
            {{ formatAmount(result.largessAmount) }}
          </el-descriptions-item>
          <el-descriptions-item label="合计">
            {{ formatAmount(result.totalAmount) }}
          </el-descriptions-item>
        </el-descriptions>

        <el-table
          :data="result.employees ?? []"
          border
          stripe
          size="small"
          empty-text=" "
          style="margin-top: 14px"
        >
          <el-table-column prop="employeeId" label="工号" width="120" show-overflow-tooltip />
          <el-table-column prop="employeeName" label="姓名" min-width="100" show-overflow-tooltip>
            <template #default="{ row }">
              {{ rowOf(row).employeeName || '—' }}
            </template>
          </el-table-column>
          <el-table-column label="现金/实收" width="110" align="right">
            <template #default="{ row }">
              {{ formatAmount(rowOf(row).payAmount) }}
            </template>
          </el-table-column>
          <el-table-column label="卡耗" width="110" align="right">
            <template #default="{ row }">
              {{ formatAmount(rowOf(row).cardAmount) }}
            </template>
          </el-table-column>
          <el-table-column label="赠送" width="110" align="right">
            <template #default="{ row }">
              {{ formatAmount(rowOf(row).largessAmount) }}
            </template>
          </el-table-column>
          <el-table-column label="合计" width="110" align="right">
            <template #default="{ row }">
              {{ formatAmount(rowOf(row).totalAmount) }}
            </template>
          </el-table-column>
          <el-table-column label="客数" width="80" align="right">
            <template #default="{ row }">
              {{ rowOf(row).guestCount ?? '—' }}
            </template>
          </el-table-column>
        </el-table>

        <AppEmpty
          v-if="!loading && (result.employees ?? []).length === 0"
          title="暂无员工业绩"
          description="调整日期或员工条件后重试"
        />

        <h2 class="section-title">单据明细</h2>
        <el-descriptions
          v-if="linesResult"
          :column="3"
          border
          size="small"
          class="store-totals"
        >
          <el-descriptions-item label="明细行数">
            {{ (linesResult.lines ?? []).length }}
          </el-descriptions-item>
          <el-descriptions-item label="明细合计">
            {{ formatAmount(linesResult.totalAmount) }}
          </el-descriptions-item>
          <el-descriptions-item label="与汇总差额">
            {{
              formatAmount(
                Number(linesResult.totalAmount ?? 0) - Number(result.totalAmount ?? 0),
              )
            }}
          </el-descriptions-item>
        </el-descriptions>
        <el-table
          :data="linesResult?.lines ?? []"
          border
          stripe
          size="small"
          empty-text=" "
          style="margin-top: 12px"
        >
          <el-table-column prop="billId" label="单号" width="150" show-overflow-tooltip />
          <el-table-column prop="billDate" label="日期" width="110" />
          <el-table-column label="类型" width="90">
            <template #default="{ row }">
              {{ itemTypeLabel(lineOf(row).itemType) }}
            </template>
          </el-table-column>
          <el-table-column prop="itemName" label="商品" min-width="120" show-overflow-tooltip />
          <el-table-column prop="customerName" label="客户" width="100" show-overflow-tooltip />
          <el-table-column prop="employeeName" label="经手人" width="100" show-overflow-tooltip />
          <el-table-column label="占比%" width="80" align="right">
            <template #default="{ row }">
              {{ formatAmount(lineOf(row).ratioPercent) }}
            </template>
          </el-table-column>
          <el-table-column label="实收业绩" width="100" align="right">
            <template #default="{ row }">
              {{ formatAmount(lineOf(row).payAmount) }}
            </template>
          </el-table-column>
          <el-table-column label="合计" width="100" align="right">
            <template #default="{ row }">
              {{ formatAmount(lineOf(row).totalAmount) }}
            </template>
          </el-table-column>
          <el-table-column label="业绩门店" width="120" show-overflow-tooltip>
            <template #default="{ row }">
              {{ lineOf(row).performanceStoreName || lineOf(row).performanceStoreId || '—' }}
            </template>
          </el-table-column>
          <el-table-column label="核销门店" width="120" show-overflow-tooltip>
            <template #default="{ row }">
              {{ lineOf(row).billStoreName || lineOf(row).billStoreId || '—' }}
            </template>
          </el-table-column>
        </el-table>
      </template>
      <AppEmpty
        v-else-if="!loading"
        title="暂无数据"
        description="点击查询加载业绩汇总"
      />
    </div>
  </section>
</template>

<style scoped>
.treat-performance {
  display: flex;
  flex-direction: column;
  gap: 16px;
  min-height: 100%;
  padding: 20px 24px 24px;
}

.page-header h1 {
  margin: 0 0 4px;
  font-size: 20px;
  font-weight: 600;
  color: #303133;
}

.subtitle {
  margin: 0;
  font-size: 13px;
  color: #909399;
}

.filter-bar {
  background: #fff;
  border: 1px solid #ebeef5;
  border-radius: 4px;
  padding: 12px 14px;
}

.filter-form {
  margin-bottom: 0;
}

.table-panel {
  min-height: 240px;
  padding: 16px;
  border: 1px solid #ebeef5;
  border-radius: 8px;
  background: #fff;
}

.store-totals {
  max-width: 900px;
}

.section-title {
  margin: 20px 0 10px;
  font-size: 16px;
  font-weight: 600;
  color: #303133;
}
</style>
