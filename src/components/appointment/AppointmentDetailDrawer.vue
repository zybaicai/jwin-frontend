<script setup lang="ts">
import { computed, ref, watch } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessageBox } from 'element-plus'

import AppEmpty from '@/components/common/AppEmpty.vue'
import AppError from '@/components/common/AppError.vue'
import {
  arriveAppointment,
  cancelAppointment,
  confirmAppointment,
  fetchAppointmentDetail,
  noShowAppointment,
  openTreatFromAppointment,
} from '@/api/appointment'
import {
  AppointmentPermission,
  appointmentStatusLabel,
  canArriveAppointment,
  canCancelAppointment,
  canConfirmAppointment,
  canModifyAppointment,
  canNoShowAppointment,
  canOpenTreatAppointment,
  projectSummary,
  type AppointmentDetail,
  type AppointmentProcessLine,
} from '@/types/appointment'
import { usePermissionStore } from '@/stores/permission'
import { getUserFriendlyErrorMessage, runExclusive, uiMessage } from '@/utils/ui'

defineOptions({ name: 'AppointmentDetailDrawer' })

const visible = defineModel<boolean>({ default: false })

const props = defineProps<{
  appointmentId: string | null
}>()

const emit = defineEmits<{
  edit: [id: string]
  changed: []
}>()

const router = useRouter()
const permissionStore = usePermissionStore()

const loading = ref(false)
const actionLoading = ref(false)
const error = ref<string | null>(null)
const detail = ref<AppointmentDetail | null>(null)

const canEditPerm = computed(() =>
  permissionStore.hasPermission(AppointmentPermission.EDIT),
)
const canStatusPerm = computed(() =>
  permissionStore.hasPermission(AppointmentPermission.STATUS),
)

const status = computed(() => detail.value?.status ?? null)

const showConfirm = computed(
  () => canStatusPerm.value && canConfirmAppointment(status.value),
)
const showArrive = computed(
  () => canStatusPerm.value && canArriveAppointment(status.value),
)
const showNoShow = computed(
  () => canStatusPerm.value && canNoShowAppointment(status.value),
)
const showCancel = computed(
  () => canEditPerm.value && canCancelAppointment(status.value),
)
const showEdit = computed(
  () => canEditPerm.value && canModifyAppointment(status.value),
)
const showOpenTreat = computed(
  () => canStatusPerm.value && canOpenTreatAppointment(status.value),
)

const processes = computed<AppointmentProcessLine[]>(
  () => detail.value?.processes ?? [],
)

function formatDateTime(raw: string | null | undefined): string {
  if (!raw) {
    return '—'
  }
  return raw.replace('T', ' ').slice(0, 19)
}

function formatTimeRange(item: AppointmentDetail | null): string {
  if (!item?.startDateTime) {
    return '—'
  }
  const start = formatDateTime(item.startDateTime)
  const end = item.endDateTime
    ? item.endDateTime.replace('T', ' ').slice(11, 16)
    : ''
  return end ? `${start} ~ ${end}` : start
}

async function loadDetail(): Promise<void> {
  const id = props.appointmentId
  if (!id) {
    detail.value = null
    return
  }
  await runExclusive(loading, async () => {
    error.value = null
    try {
      detail.value = await fetchAppointmentDetail(id)
    } catch (err) {
      detail.value = null
      error.value = getUserFriendlyErrorMessage(err)
    }
  })
}

async function runAction(
  label: string,
  fn: () => Promise<unknown>,
): Promise<void> {
  await runExclusive(actionLoading, async () => {
    try {
      await fn()
      uiMessage.success(`${label}成功`)
      await loadDetail()
      emit('changed')
    } catch (err) {
      uiMessage.error(getUserFriendlyErrorMessage(err))
    }
  })
}

function onConfirm(): void {
  if (!props.appointmentId) return
  void runAction('确认', () => confirmAppointment(props.appointmentId!))
}

function onArrive(): void {
  if (!props.appointmentId) return
  void runAction('到店', () => arriveAppointment(props.appointmentId!))
}

async function onNoShow(): Promise<void> {
  if (!props.appointmentId) return
  try {
    const { value } = await ElMessageBox.prompt('可选填写爽约原因', '标记爽约', {
      confirmButtonText: '确定',
      cancelButtonText: '取消',
      inputPlaceholder: '原因（可选）',
      inputValue: '',
    })
    await runAction('爽约', () =>
      noShowAppointment(props.appointmentId!, {
        reason: String(value ?? '').trim() || null,
      }),
    )
  } catch {
    /* cancel */
  }
}

async function onCancel(): Promise<void> {
  if (!props.appointmentId) return
  try {
    const { value } = await ElMessageBox.prompt('请填写取消原因（可选）', '取消预约', {
      confirmButtonText: '确定取消',
      cancelButtonText: '返回',
      inputPlaceholder: '原因',
      inputValue: '',
      type: 'warning',
    })
    await runAction('取消', () =>
      cancelAppointment(props.appointmentId!, {
        reason: String(value ?? '').trim() || null,
      }),
    )
  } catch {
    /* cancel */
  }
}

function onEdit(): void {
  if (!props.appointmentId || !showEdit.value) return
  emit('edit', props.appointmentId)
}

async function onOpenTreat(): Promise<void> {
  if (!props.appointmentId) return
  await runExclusive(actionLoading, async () => {
    try {
      const result = await openTreatFromAppointment(props.appointmentId!)
      if (result.alreadyOpened) {
        uiMessage.warning(
          result.treatBillId
            ? `该预约已开过消耗单（${result.treatBillId}），请勿重复开单`
            : '该预约已开过消耗单，请勿重复开单',
        )
        await loadDetail()
        emit('changed')
        return
      }
      const customerId = result.customerId
      if (customerId == null) {
        uiMessage.error('开消耗失败：缺少顾客信息')
        return
      }
      visible.value = false
      await router.push({
        path: '/sales/cashier',
        query: {
          customerId: String(customerId),
          mode: 'consume',
          appointmentId: result.appointmentId || props.appointmentId!,
        },
      })
    } catch (err) {
      uiMessage.error(getUserFriendlyErrorMessage(err))
    }
  })
}

watch(
  () => [visible.value, props.appointmentId] as const,
  ([open, id]) => {
    if (open && id) {
      void loadDetail()
    }
    if (!open) {
      detail.value = null
      error.value = null
    }
  },
)
</script>

<template>
  <el-drawer
    v-model="visible"
    title="预约详情"
    size="560px"
    destroy-on-close
  >
    <div v-loading="loading || actionLoading" class="drawer-body">
      <AppError v-if="error && !loading" :description="error" @retry="loadDetail" />
      <template v-else-if="detail">
        <div class="detail-meta">
          <div>单号：{{ detail.id }}</div>
          <div>
            状态：
            <el-tag size="small">
              {{ detail.statusName || appointmentStatusLabel(detail.status) }}
            </el-tag>
          </div>
          <div>
            顾客：{{ detail.customerName || '—' }}
            <span v-if="detail.customerMobile" class="sub">
              （{{ detail.customerMobile }}）
            </span>
          </div>
          <div>护理师：{{ detail.employeeName || detail.employeeId || '—' }}</div>
          <div>项目：{{ projectSummary(detail) }}</div>
          <div>时间：{{ formatTimeRange(detail) }}</div>
          <div>时长：{{ detail.durationMinutes != null ? `${detail.durationMinutes} 分钟` : '—' }}</div>
          <div>备注：{{ detail.remark || '—' }}</div>
          <div v-if="detail.treatBillId">消耗单：{{ detail.treatBillId }}</div>
          <div>创建：{{ formatDateTime(detail.createdOn) }}</div>
        </div>

        <div v-if="detail.projects?.length" class="section">
          <div class="section-title">项目明细</div>
          <el-table :data="detail.projects" border size="small">
            <el-table-column prop="sequence" label="#" width="50" />
            <el-table-column prop="projectName" label="项目" min-width="140" show-overflow-tooltip />
            <el-table-column label="时长" width="80">
              <template #default="{ row }">
                {{ row.durationMinutes != null ? `${row.durationMinutes}分` : '—' }}
              </template>
            </el-table-column>
          </el-table>
        </div>

        <div class="section">
          <div class="section-title">过程日志</div>
          <el-timeline v-if="processes.length">
            <el-timeline-item
              v-for="p in processes"
              :key="p.id ?? `${p.actionType}-${p.createdOn}`"
              :timestamp="formatDateTime(p.createdOn)"
              placement="top"
            >
              <div>
                {{ p.actionType || '—' }}
                <span v-if="p.fromStatusName || p.toStatusName" class="sub">
                  （{{ p.fromStatusName || p.fromStatus || '—' }} →
                  {{ p.toStatusName || p.toStatus || '—' }}）
                </span>
              </div>
              <div v-if="p.createdByName || p.createdBy" class="sub">
                操作人：{{ p.createdByName || p.createdBy }}
              </div>
              <div v-if="p.remark" class="sub">备注：{{ p.remark }}</div>
            </el-timeline-item>
          </el-timeline>
          <AppEmpty v-else title="暂无过程记录" />
        </div>

        <div class="actions">
          <el-button v-if="showConfirm" type="primary" @click="onConfirm">确认</el-button>
          <el-button v-if="showEdit" @click="onEdit">编辑</el-button>
          <el-button v-if="showArrive" type="success" @click="onArrive">到店</el-button>
          <el-button v-if="showOpenTreat" type="warning" @click="onOpenTreat">开消耗</el-button>
          <el-button v-if="showNoShow" @click="onNoShow">爽约</el-button>
          <el-button v-if="showCancel" type="danger" plain @click="onCancel">取消</el-button>
        </div>
      </template>
      <AppEmpty v-else-if="!loading" title="暂无预约详情" />
    </div>
  </el-drawer>
</template>

<style scoped>
.drawer-body {
  min-height: 200px;
}

.detail-meta {
  display: grid;
  gap: 8px;
  font-size: 13px;
  color: #303133;
  margin-bottom: 16px;
}

.sub {
  color: #909399;
  font-size: 12px;
}

.section {
  margin-top: 16px;
}

.section-title {
  font-weight: 600;
  margin-bottom: 8px;
  font-size: 13px;
}

.actions {
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
  margin-top: 20px;
  padding-top: 12px;
  border-top: 1px solid #ebeef5;
}
</style>
