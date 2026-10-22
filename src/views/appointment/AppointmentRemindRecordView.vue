<script setup lang="ts">
import { computed, onMounted, onUnmounted, reactive, ref } from 'vue'

import AppError from '@/components/common/AppError.vue'
import { dispatchRemindTasks, fetchRemindTasks } from '@/api/appointment'
import {
  AppointmentPermission,
  REMIND_CHANNEL_OPTIONS,
  REMIND_STATUS_OPTIONS,
  REMIND_TYPE_OPTIONS,
  type RemindTaskItem,
} from '@/types/appointment'
import { usePermissionStore } from '@/stores/permission'
import { STORE_CONTEXT_CHANGED_EVENT, useStoreStore } from '@/stores/store'
import { getUserFriendlyErrorMessage, runExclusive, uiMessage } from '@/utils/ui'
import { ElMessage } from 'element-plus'

defineOptions({ name: 'AppointmentRemindRecordView' })

const permissionStore = usePermissionStore()
const storeStore = useStoreStore()

const loading = ref(false)
const dispatching = ref(false)
const error = ref<string | null>(null)
const rows = ref<RemindTaskItem[]>([])

const canView = computed(() =>
  permissionStore.hasPermission(AppointmentPermission.VIEW),
)
const canEdit = computed(() =>
  permissionStore.hasPermission(AppointmentPermission.EDIT),
)
const storeId = computed(() => storeStore.currentStoreId ?? null)

const filters = reactive({
  planDate: '' as string,
  appointmentId: '',
  status: '' as string,
  channel: '' as string,
  taskType: '' as string,
})

function statusLabel(code: string | null | undefined): string {
  const hit = REMIND_STATUS_OPTIONS.find((o) => o.value === code)
  return hit?.label || code || '—'
}

function channelLabel(code: string | null | undefined): string {
  const hit = REMIND_CHANNEL_OPTIONS.find((o) => o.value === code)
  return hit?.label || code || '—'
}

function typeLabel(code: string | null | undefined): string {
  const hit = REMIND_TYPE_OPTIONS.find((o) => o.value === code)
  return hit?.label || code || '—'
}

function statusTagType(
  code: string | null | undefined,
): 'success' | 'warning' | 'info' | 'danger' | 'primary' {
  switch (code) {
    case 'SENT':
      return 'success'
    case 'MOCK_SENT':
      return 'warning'
    case 'WAIT_CONFIG':
    case 'WAIT_AUTH':
    case 'WAIT_VERIFY':
      return 'info'
    case 'FAILED':
    case 'DEAD':
      return 'danger'
    case 'CANCELLED':
      return 'info'
    default:
      return 'primary'
  }
}

async function loadRows(): Promise<void> {
  if (!canView.value) {
    error.value = '无预约查看权限'
    return
  }
  if (storeId.value == null) {
    error.value = '请先选择门店'
    return
  }
  error.value = null
  await runExclusive(loading, async () => {
    try {
      let planFrom: string | undefined
      let planTo: string | undefined
      if (filters.planDate) {
        planFrom = `${filters.planDate}T00:00:00`
        planTo = `${filters.planDate}T23:59:59`
      }
      rows.value = await fetchRemindTasks({
        storeId: storeId.value!,
        appointmentId: filters.appointmentId.trim() || undefined,
        status: filters.status || undefined,
        channel: filters.channel || undefined,
        taskType: filters.taskType || undefined,
        planFrom,
        planTo,
      })
    } catch (e) {
      error.value = getUserFriendlyErrorMessage(e)
    }
  })
}

async function onDispatch(): Promise<void> {
  if (!canEdit.value) {
    uiMessage.warning('无编辑权限')
    return
  }
  dispatching.value = true
  try {
    const n = await dispatchRemindTasks()
    ElMessage.success(`已扫描处理 ${n} 条到期任务（未配置渠道不会标发送成功）`)
    await loadRows()
  } catch (e) {
    ElMessage.error(getUserFriendlyErrorMessage(e))
  } finally {
    dispatching.value = false
  }
}

function onStoreChanged(): void {
  void loadRows()
}

onMounted(() => {
  void loadRows()
  window.addEventListener(STORE_CONTEXT_CHANGED_EVENT, onStoreChanged)
})

onUnmounted(() => {
  window.removeEventListener(STORE_CONTEXT_CHANGED_EVENT, onStoreChanged)
})
</script>

<template>
  <div class="page">
    <header class="page-header">
      <el-button
        v-if="canEdit"
        type="primary"
        plain
        :loading="dispatching"
        @click="onDispatch"
      >
        立即扫描到期任务
      </el-button>
    </header>

    <div class="filters">
      <el-date-picker
        v-model="filters.planDate"
        type="date"
        value-format="YYYY-MM-DD"
        placeholder="计划发送日期"
        clearable
        style="width: 160px"
      />
      <el-input
        v-model="filters.appointmentId"
        clearable
        placeholder="预约单号"
        style="width: 180px"
      />
      <el-select v-model="filters.taskType" clearable placeholder="提醒类型" style="width: 140px">
        <el-option
          v-for="o in REMIND_TYPE_OPTIONS"
          :key="o.value"
          :label="o.label"
          :value="o.value"
        />
      </el-select>
      <el-select v-model="filters.channel" clearable placeholder="渠道" style="width: 140px">
        <el-option
          v-for="o in REMIND_CHANNEL_OPTIONS"
          :key="o.value"
          :label="o.label"
          :value="o.value"
        />
      </el-select>
      <el-select v-model="filters.status" clearable placeholder="状态" style="width: 150px">
        <el-option
          v-for="o in REMIND_STATUS_OPTIONS"
          :key="o.value"
          :label="o.label"
          :value="o.value"
        />
      </el-select>
      <el-button type="primary" :loading="loading" @click="loadRows">查询</el-button>
    </div>

    <AppError v-if="error && !loading" :description="error" @retry="loadRows" />
    <el-table
      v-else
      v-loading="loading"
      :data="rows"
      stripe
      border
      empty-text="暂无提醒记录"
      class="table"
    >
      <el-table-column label="客户" min-width="120">
        <template #default="{ row }">
          <div>{{ row.customerName || '—' }}</div>
          <div class="sub">{{ row.customerMobileMask || '—' }}</div>
        </template>
      </el-table-column>
      <el-table-column prop="appointmentBillId" label="预约单" min-width="140" />
      <el-table-column label="预约时间" min-width="150">
        <template #default="{ row }">
          {{ row.startDateTimeSnapshot || '—' }}
        </template>
      </el-table-column>
      <el-table-column label="提醒类型" width="110">
        <template #default="{ row }">{{ typeLabel(row.taskType) }}</template>
      </el-table-column>
      <el-table-column label="渠道" width="110">
        <template #default="{ row }">{{ channelLabel(row.channel) }}</template>
      </el-table-column>
      <el-table-column prop="planTime" label="计划发送" min-width="160" />
      <el-table-column prop="sentOn" label="实际发送" min-width="160">
        <template #default="{ row }">{{ row.sentOn || '—' }}</template>
      </el-table-column>
      <el-table-column label="状态" width="120">
        <template #default="{ row }">
          <el-tag :type="statusTagType(row.status)" size="small">
            {{ statusLabel(row.status) }}
          </el-tag>
        </template>
      </el-table-column>
      <el-table-column prop="resultMsg" label="说明/失败原因" min-width="200" show-overflow-tooltip />
    </el-table>
  </div>
</template>

<style scoped>
.page {
  display: flex;
  flex-direction: column;
  gap: 12px;
  padding: 4px 0 16px;
  height: 100%;
  box-sizing: border-box;
}
.page-header {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  gap: 12px;
}
.page-header h1 {
  margin: 0;
  font-size: 20px;
}
.desc {
  margin: 6px 0 0;
  font-size: 13px;
  color: #909399;
}
.filters {
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
  align-items: center;
}
.table {
  flex: 1;
}
.sub {
  font-size: 12px;
  color: #909399;
}
</style>
