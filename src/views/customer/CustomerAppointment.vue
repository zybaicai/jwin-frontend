<script setup lang="ts">
import { reactive, ref, watch } from 'vue'

import AppEmpty from '@/components/common/AppEmpty.vue'
import AppError from '@/components/common/AppError.vue'
import { fetchAppointmentPage } from '@/api/appointment'
import { AppointmentPermission, type AppointmentItem } from '@/types/appointment'
import { usePermissionStore } from '@/stores/permission'
import { getUserFriendlyErrorMessage, runExclusive } from '@/utils/ui'
import { formatDateTime } from '@/views/customer/customer-format'

defineOptions({ name: 'CustomerAppointment' })

const props = defineProps<{
  customerId: number
}>()

interface AppointmentPageState {
  page: number
  size: number
  total: number
  records: AppointmentItem[]
  loaded: boolean
  error: string | null
}

function createPageState(): AppointmentPageState {
  return {
    page: 1,
    size: 20,
    total: 0,
    records: [],
    loaded: false,
    error: null,
  }
}

const permissionStore = usePermissionStore()
const appointmentsLoading = ref(false)
const appointmentsState = reactive(createPageState())

function formatTimeRange(start: string | null | undefined, end: string | null | undefined): string {
  const from = formatDateTime(start)
  const to = formatDateTime(end)
  if (from === '—' && to === '—') {
    return '—'
  }
  if (to === '—') {
    return from
  }
  if (from === '—') {
    return to
  }
  return `${from} ~ ${to}`
}

async function loadAppointments(force = false): Promise<void> {
  if (!force && appointmentsState.loaded) {
    return
  }
  if (!permissionStore.hasPermission(AppointmentPermission.VIEW)) {
    appointmentsState.records = []
    appointmentsState.total = 0
    appointmentsState.loaded = true
    appointmentsState.error = '暂无权限查看预约记录'
    return
  }
  await runExclusive(appointmentsLoading, async () => {
    appointmentsState.error = null
    try {
      const data = await fetchAppointmentPage({
        customerId: props.customerId,
        page: appointmentsState.page,
        size: appointmentsState.size,
      })
      appointmentsState.records = data.records ?? []
      appointmentsState.total = data.total ?? 0
      appointmentsState.page = data.page || appointmentsState.page
      appointmentsState.size = data.size || appointmentsState.size
      appointmentsState.loaded = true
    } catch (error) {
      appointmentsState.records = []
      appointmentsState.total = 0
      appointmentsState.loaded = false
      appointmentsState.error = getUserFriendlyErrorMessage(error)
    }
  })
}

async function handlePageChange(nextPage: number): Promise<void> {
  appointmentsState.page = nextPage
  appointmentsState.loaded = false
  await loadAppointments(true)
}

async function handleSizeChange(size: number): Promise<void> {
  appointmentsState.size = size
  appointmentsState.page = 1
  appointmentsState.loaded = false
  await loadAppointments(true)
}

async function reloadCurrent(): Promise<void> {
  await loadAppointments(true)
}

watch(
  () => props.customerId,
  () => {
    Object.assign(appointmentsState, createPageState())
    void loadAppointments(true)
  },
  { immediate: true },
)

defineExpose({
  reloadCurrent,
})
</script>

<template>
  <div class="customer-appointment" v-loading="appointmentsLoading">
    <AppError
      v-if="appointmentsState.error && !appointmentsLoading"
      :description="appointmentsState.error"
      @retry="reloadCurrent"
    />
    <template v-else>
      <el-table :data="appointmentsState.records" border stripe size="small" empty-text=" ">
        <el-table-column label="预约时间" min-width="280" show-overflow-tooltip>
          <template #default="{ row }">
            {{ formatTimeRange(row.startDateTime, row.endDateTime) }}
          </template>
        </el-table-column>
        <el-table-column prop="projectNameSnapshot" label="项目" min-width="140" show-overflow-tooltip>
          <template #default="{ row }">
            {{ row.projectNameSnapshot || '—' }}
          </template>
        </el-table-column>
        <el-table-column label="状态" min-width="90">
          <template #default="{ row }">
            {{ row.statusName || row.status || '—' }}
          </template>
        </el-table-column>
        <el-table-column prop="employeeId" label="护理师" min-width="110" show-overflow-tooltip>
          <template #default="{ row }">
            {{ row.employeeId || '—' }}
          </template>
        </el-table-column>
        <el-table-column label="预约类型" min-width="90" align="right">
          <template #default="{ row }">
            {{ row.appointmentTypeId ?? '—' }}
          </template>
        </el-table-column>
        <el-table-column label="时长(分)" min-width="80" align="right">
          <template #default="{ row }">
            {{ row.durationMinutes ?? '—' }}
          </template>
        </el-table-column>
        <el-table-column prop="remark" label="备注" min-width="120" show-overflow-tooltip>
          <template #default="{ row }">
            {{ row.remark || '—' }}
          </template>
        </el-table-column>
        <el-table-column label="创建时间" min-width="160">
          <template #default="{ row }">
            {{ formatDateTime(row.createdOn) }}
          </template>
        </el-table-column>
      </el-table>

      <AppEmpty
        v-if="!appointmentsLoading && !appointmentsState.error && appointmentsState.loaded && appointmentsState.records.length === 0"
        title="暂无预约记录"
      />

      <div v-if="appointmentsState.total > 0" class="pager">
        <el-pagination
          background
          layout="total, sizes, prev, pager, next"
          :total="appointmentsState.total"
          :current-page="appointmentsState.page"
          :page-size="appointmentsState.size"
          :page-sizes="[10, 20, 50, 100]"
          @current-change="handlePageChange"
          @size-change="handleSizeChange"
        />
      </div>
    </template>
  </div>
</template>

<style scoped>
.customer-appointment {
  min-height: 180px;
}

.pager {
  display: flex;
  justify-content: flex-end;
  margin-top: 12px;
}
</style>
