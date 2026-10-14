<script setup lang="ts">
import { computed, onMounted, onUnmounted, ref, watch } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessageBox } from 'element-plus'

import AppEmpty from '@/components/common/AppEmpty.vue'
import AppError from '@/components/common/AppError.vue'
import AppointmentDetailDrawer from '@/components/appointment/AppointmentDetailDrawer.vue'
import AppointmentFormDialog from '@/components/appointment/AppointmentFormDialog.vue'
import {
  arriveAppointment,
  cancelAppointment,
  fetchAppointmentBoard,
  fetchAppointmentConfig,
  fetchAppointmentEmployees,
  fetchInviteAssist,
  openTreatFromAppointment,
} from '@/api/appointment'
import {
  APPOINTMENT_STATUS_OPTIONS,
  AppointmentPermission,
  appointmentStatusLabel,
  canArriveAppointment,
  canCancelAppointment,
  canModifyAppointment,
  canOpenTreatAppointment,
  projectSummary,
  type AppointmentBoard,
  type AppointmentEmployeeOption,
  type AppointmentItem,
  type InviteAssistItem,
} from '@/types/appointment'
import { usePermissionStore } from '@/stores/permission'
import { STORE_CONTEXT_CHANGED_EVENT, useStoreStore } from '@/stores/store'
import { getUserFriendlyErrorMessage, runExclusive, uiMessage } from '@/utils/ui'

defineOptions({ name: 'AppointmentBoardView' })

const router = useRouter()
const permissionStore = usePermissionStore()
const storeStore = useStoreStore()

const SLOT_HEIGHT = 44
const EMP_COL_WIDTH = 168
const TIME_COL_WIDTH = 64
const MAX_VISIBLE_PER_GROUP = 2
const INVITE_WIDTH = 280

const loading = ref(false)
const error = ref<string | null>(null)
const board = ref<AppointmentBoard | null>(null)
const employees = ref<AppointmentEmployeeOption[]>([])
const inviteList = ref<InviteAssistItem[]>([])
const filterEmployeeId = ref('')
const filterStatus = ref('')
const selectedDate = ref(formatDateYmd(new Date()))
const nowTick = ref(Date.now())

const axisStartMinutes = ref(9 * 60)
const axisEndMinutes = ref(21 * 60)
const slotMinutes = ref(15)

const formVisible = ref(false)
const formAppointmentId = ref<string | null>(null)
const formDefaultEmployeeId = ref<string | null>(null)
const formDefaultStartTime = ref<string | null>(null)
const detailVisible = ref(false)
const detailAppointmentId = ref<string | null>(null)
const overflowVisible = ref(false)
const overflowTitle = ref('')
const overflowList = ref<AppointmentItem[]>([])
const hoverSlot = ref<{ employeeId: string; minutes: number } | null>(null)
const hoverAptId = ref<string | null>(null)

const canView = computed(() => permissionStore.hasPermission(AppointmentPermission.VIEW))
const canEdit = computed(() => permissionStore.hasPermission(AppointmentPermission.EDIT))
const canStatus = computed(() =>
  permissionStore.hasPermission(AppointmentPermission.STATUS),
)

interface BoardRow {
  employeeId: string
  employeeName: string
}

interface BoardCardPlacement {
  appointment: AppointmentItem
  top: number
  height: number
  lane: number
  laneCount: number
  overflowCount: number
  overflowGroup: AppointmentItem[]
}

const timeLabels = computed(() => {
  const labels: { minutes: number; label: string }[] = []
  for (let m = axisStartMinutes.value; m < axisEndMinutes.value; m += slotMinutes.value) {
    labels.push({ minutes: m, label: minutesToHm(m) })
  }
  return labels
})

const boardHeight = computed(() => timeLabels.value.length * SLOT_HEIGHT)

const isToday = computed(() => selectedDate.value === formatDateYmd(new Date()))

const nowLineTop = computed(() => {
  if (!isToday.value) return null
  const d = new Date(nowTick.value)
  const mins = d.getHours() * 60 + d.getMinutes()
  if (mins < axisStartMinutes.value || mins > axisEndMinutes.value) return null
  return ((mins - axisStartMinutes.value) / slotMinutes.value) * SLOT_HEIGHT
})

const rows = computed<BoardRow[]>(() => {
  const map = new Map<string, string>()
  for (const emp of employees.value) {
    if (!emp.employeeId) continue
    map.set(emp.employeeId, emp.employeeName?.trim() || emp.employeeId)
  }
  for (const d of board.value?.onDuty ?? []) {
    if (!d.employeeId || d.rest) continue
    if (!map.has(d.employeeId)) map.set(d.employeeId, d.employeeId)
  }
  for (const apt of board.value?.appointments ?? []) {
    if (!apt.employeeId) continue
    if (!map.has(apt.employeeId)) {
      map.set(apt.employeeId, apt.employeeName?.trim() || apt.employeeId)
    } else if (apt.employeeName?.trim()) {
      map.set(apt.employeeId, apt.employeeName.trim())
    }
  }
  let list = [...map.entries()].map(([employeeId, employeeName]) => ({
    employeeId,
    employeeName,
  }))
  if (filterEmployeeId.value) {
    list = list.filter((r) => r.employeeId === filterEmployeeId.value)
  }
  list.sort((a, b) => a.employeeName.localeCompare(b.employeeName, 'zh-CN'))
  return list
})

const filteredAppointments = computed(() => {
  let list = board.value?.appointments ?? []
  if (filterStatus.value) list = list.filter((a) => a.status === filterStatus.value)
  if (filterEmployeeId.value) {
    list = list.filter((a) => a.employeeId === filterEmployeeId.value)
  }
  return list
})

const placementsByEmployee = computed(() => {
  const result = new Map<string, BoardCardPlacement[]>()
  const byEmp = new Map<string, AppointmentItem[]>()
  for (const apt of filteredAppointments.value) {
    const empId = apt.employeeId
    if (!empId || !apt.startDateTime) continue
    const arr = byEmp.get(empId) ?? []
    arr.push(apt)
    byEmp.set(empId, arr)
  }
  for (const [empId, apts] of byEmp) {
    const sorted = [...apts].sort((a, b) => {
      const sa = parseLocalDateTime(a.startDateTime!)?.getTime() ?? 0
      const sb = parseLocalDateTime(b.startDateTime!)?.getTime() ?? 0
      return sa - sb
    })
    const groups = new Map<number, AppointmentItem[]>()
    for (const apt of sorted) {
      const start = parseLocalDateTime(apt.startDateTime!)
      if (!start) continue
      const startMin = start.getHours() * 60 + start.getMinutes()
      const slotKey = Math.floor(startMin / slotMinutes.value) * slotMinutes.value
      const g = groups.get(slotKey) ?? []
      g.push(apt)
      groups.set(slotKey, g)
    }
    const placements: BoardCardPlacement[] = []
    for (const [, group] of groups) {
      const visible = group.slice(0, MAX_VISIBLE_PER_GROUP)
      const overflow = group.slice(MAX_VISIBLE_PER_GROUP)
      const laneCount = Math.min(group.length, MAX_VISIBLE_PER_GROUP)
      visible.forEach((apt, lane) => {
        const start = parseLocalDateTime(apt.startDateTime!)
        if (!start) return
        const startMin = start.getHours() * 60 + start.getMinutes()
        let endMin = startMin + (apt.durationMinutes ?? slotMinutes.value)
        if (apt.endDateTime) {
          const end = parseLocalDateTime(apt.endDateTime)
          if (end) {
            endMin = end.getHours() * 60 + end.getMinutes()
            if (endMin <= startMin) endMin = startMin + (apt.durationMinutes ?? slotMinutes.value)
          }
        }
        const clampedStart = Math.max(startMin, axisStartMinutes.value)
        const clampedEnd = Math.min(endMin, axisEndMinutes.value)
        if (clampedEnd <= axisStartMinutes.value || clampedStart >= axisEndMinutes.value) return
        const top =
          ((clampedStart - axisStartMinutes.value) / slotMinutes.value) * SLOT_HEIGHT
        const height = Math.max(
          SLOT_HEIGHT * 0.7,
          ((clampedEnd - clampedStart) / slotMinutes.value) * SLOT_HEIGHT,
        )
        const stackHeight = Math.min(height, SLOT_HEIGHT)
        const laneHeight = stackHeight / laneCount
        placements.push({
          appointment: apt,
          top: top + lane * laneHeight,
          height: Math.max(laneHeight, height - lane * laneHeight),
          lane,
          laneCount,
          overflowCount: lane === 0 ? overflow.length : 0,
          overflowGroup: group,
        })
      })
    }
    result.set(empId, placements)
  }
  return result
})

function formatDateYmd(d: Date): string {
  return `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, '0')}-${String(d.getDate()).padStart(2, '0')}`
}

function minutesToHm(total: number): string {
  return `${String(Math.floor(total / 60)).padStart(2, '0')}:${String(total % 60).padStart(2, '0')}`
}

function parseHmToMinutes(raw: string | null | undefined, fallback: number): number {
  if (!raw) return fallback
  const m = raw.trim().match(/^(\d{1,2}):(\d{2})/)
  if (!m) return fallback
  return Number(m[1]) * 60 + Number(m[2])
}

function parseLocalDateTime(isoLike: string): Date | null {
  const m = isoLike.match(/^(\d{4})-(\d{2})-(\d{2})[T ](\d{2}):(\d{2})(?::(\d{2}))?/)
  if (!m) return null
  const d = new Date(
    Number(m[1]),
    Number(m[2]) - 1,
    Number(m[3]),
    Number(m[4]),
    Number(m[5]),
    Number(m[6] ?? 0),
  )
  return Number.isNaN(d.getTime()) ? null : d
}

function shiftDate(delta: number): void {
  const d = parseLocalDateTime(`${selectedDate.value}T00:00:00`)
  if (!d) return
  d.setDate(d.getDate() + delta)
  selectedDate.value = formatDateYmd(d)
}

function goToday(): void {
  selectedDate.value = formatDateYmd(new Date())
}

function formatCardTime(apt: AppointmentItem): string {
  const start = apt.startDateTime ? apt.startDateTime.replace('T', ' ').slice(11, 16) : ''
  const end = apt.endDateTime ? apt.endDateTime.replace('T', ' ').slice(11, 16) : ''
  if (start && end) return `${start}-${end}`
  return start || '—'
}

function isPastSlot(minutes: number): boolean {
  if (!isToday.value) {
    const sel = parseLocalDateTime(`${selectedDate.value}T00:00:00`)
    if (!sel) return false
    const today = new Date()
    today.setHours(0, 0, 0, 0)
    return sel.getTime() < today.getTime()
  }
  const d = new Date(nowTick.value)
  return minutes + slotMinutes.value <= d.getHours() * 60 + d.getMinutes()
}

function openDetail(id: string): void {
  detailAppointmentId.value = id
  detailVisible.value = true
}

function openCreate(prefill?: { employeeId?: string; startMinutes?: number }): void {
  formAppointmentId.value = null
  formDefaultEmployeeId.value = prefill?.employeeId ?? null
  formDefaultStartTime.value =
    prefill?.startMinutes != null ? minutesToHm(prefill.startMinutes) : null
  formVisible.value = true
}

function openEdit(id: string): void {
  detailVisible.value = false
  formAppointmentId.value = id
  formDefaultEmployeeId.value = null
  formDefaultStartTime.value = null
  formVisible.value = true
}

function openOverflow(group: AppointmentItem[], empName: string): void {
  overflowTitle.value = `${empName} · 同格预约（${group.length}）`
  overflowList.value = group
  overflowVisible.value = true
}

function onSlotClick(employeeId: string, minutes: number, past: boolean): void {
  if (!canEdit.value) {
    uiMessage.warning(past ? '历史时段仅可查看；无新增权限' : '无新增预约权限')
    return
  }
  if (past) {
    void ElMessageBox.confirm('该时段已过，仍要新增预约吗？', '提示', {
      type: 'warning',
      confirmButtonText: '继续新增',
      cancelButtonText: '取消',
    })
      .then(() => openCreate({ employeeId, startMinutes: minutes }))
      .catch(() => undefined)
    return
  }
  openCreate({ employeeId, startMinutes: minutes })
}

async function quickArrive(id: string): Promise<void> {
  try {
    await arriveAppointment(id)
    uiMessage.success('已到店')
    void loadBoard()
  } catch (e) {
    uiMessage.error(getUserFriendlyErrorMessage(e))
  }
}

async function quickCancel(id: string): Promise<void> {
  try {
    await ElMessageBox.prompt('请输入取消原因（可选）', '取消预约', {
      confirmButtonText: '确认取消',
      cancelButtonText: '返回',
      inputPlaceholder: '原因',
    }).then(async ({ value }) => {
      await cancelAppointment(id, { reason: value || null })
      uiMessage.success('已取消')
      void loadBoard()
    })
  } catch (e) {
    if (e !== 'cancel' && e !== 'close') {
      uiMessage.error(getUserFriendlyErrorMessage(e))
    }
  }
}

async function quickOpenTreat(id: string): Promise<void> {
  try {
    const result = await openTreatFromAppointment(id)
    if (result.alreadyOpened && result.treatBillId) {
      uiMessage.warning(`已关联消耗单 ${result.treatBillId}，将打开消耗台`)
    }
    await router.push({
      path: '/sales/cashier',
      query: { mode: 'consume', appointmentId: id },
    })
  } catch (e) {
    uiMessage.error(getUserFriendlyErrorMessage(e))
  }
}

function inviteCreate(item: InviteAssistItem): void {
  formAppointmentId.value = null
  formDefaultEmployeeId.value = filterEmployeeId.value || null
  formDefaultStartTime.value = null
  formVisible.value = true
  // 弹窗打开后通过事件不够直接；用 sessionStorage 轻量传递
  sessionStorage.setItem(
    'appt.invite.customer',
    JSON.stringify({
      id: item.customerId,
      name: item.customerName,
      mobile: item.customerMobile,
    }),
  )
}

async function loadAxisConfig(): Promise<void> {
  try {
    const cfg = await fetchAppointmentConfig(storeStore.currentStoreId ?? undefined)
    if (cfg?.startTime) axisStartMinutes.value = parseHmToMinutes(cfg.startTime, 9 * 60)
    if (cfg?.endTime) axisEndMinutes.value = parseHmToMinutes(cfg.endTime, 21 * 60)
    if (cfg?.period && cfg.period > 0) slotMinutes.value = cfg.period
    else slotMinutes.value = 15
  } catch {
    slotMinutes.value = 15
  }
}

async function loadBoard(): Promise<void> {
  if (!canView.value) {
    error.value = '无预约查看权限'
    return
  }
  error.value = null
  await runExclusive(loading, async () => {
    try {
      const storeId = storeStore.currentStoreId
      const [b, emps, invite] = await Promise.all([
        fetchAppointmentBoard({ storeId: storeId ?? undefined, date: selectedDate.value }),
        fetchAppointmentEmployees(storeId ?? undefined),
        fetchInviteAssist({ storeId: storeId ?? undefined, date: selectedDate.value }),
      ])
      board.value = b
      employees.value = emps
      inviteList.value = invite
    } catch (e) {
      error.value = getUserFriendlyErrorMessage(e)
    }
  })
}

function onFormSuccess(): void {
  sessionStorage.removeItem('appt.invite.customer')
  void loadBoard()
}

function onStoreChanged(): void {
  void loadAxisConfig().then(() => loadBoard())
}

let timer: ReturnType<typeof setInterval> | null = null

onMounted(() => {
  void loadAxisConfig().then(() => loadBoard())
  window.addEventListener(STORE_CONTEXT_CHANGED_EVENT, onStoreChanged)
  timer = setInterval(() => {
    nowTick.value = Date.now()
  }, 30_000)
})

onUnmounted(() => {
  window.removeEventListener(STORE_CONTEXT_CHANGED_EVENT, onStoreChanged)
  if (timer) clearInterval(timer)
})

watch(selectedDate, () => {
  void loadBoard()
})
</script>

<template>
  <div class="page">
    <div class="filter-bar">
      <div class="filter-toolbar">
        <el-form :inline="true" class="filter-form" @submit.prevent>
          <el-form-item label="日期">
            <div class="date-nav">
              <el-button @click="shiftDate(-1)">前一天</el-button>
              <el-date-picker
                v-model="selectedDate"
                type="date"
                value-format="YYYY-MM-DD"
                :clearable="false"
                style="width: 150px"
              />
              <el-button @click="shiftDate(1)">后一天</el-button>
              <el-button @click="goToday">今天</el-button>
            </div>
          </el-form-item>
          <el-form-item label="护理师">
            <el-select
              v-model="filterEmployeeId"
              clearable
              filterable
              placeholder="全部"
              style="width: 140px"
            >
              <el-option
                v-for="emp in employees"
                :key="emp.employeeId"
                :label="emp.employeeName || emp.employeeId"
                :value="emp.employeeId"
              />
            </el-select>
          </el-form-item>
          <el-form-item label="状态">
            <el-select v-model="filterStatus" clearable placeholder="全部" style="width: 120px">
              <el-option
                v-for="opt in APPOINTMENT_STATUS_OPTIONS"
                :key="opt.value"
                :label="opt.label"
                :value="opt.value"
              />
            </el-select>
          </el-form-item>
          <el-form-item>
            <el-button type="primary" :loading="loading" @click="loadBoard">刷新</el-button>
          </el-form-item>
        </el-form>
        <el-button v-if="canEdit" type="primary" @click="openCreate()">新增预约</el-button>
      </div>
      <p class="axis-hint">
        时间粒度 {{ slotMinutes }} 分钟 · 历史日期可查 · 过期格子变暗但仍可操作（会确认）
      </p>
    </div>

    <div v-loading="loading" class="main-row">
      <div class="board-pane">
        <AppError v-if="error && !loading" :description="error" @retry="loadBoard" />
        <template v-else>
          <div v-if="rows.length === 0" class="empty-wrap">
            <AppEmpty title="当日暂无护理师或预约" />
          </div>
          <div v-else class="board-scroll">
            <div
              class="board"
              :style="{ minWidth: `${TIME_COL_WIDTH + rows.length * EMP_COL_WIDTH}px` }"
            >
              <div class="board-header">
                <div class="time-head" :style="{ width: `${TIME_COL_WIDTH}px` }">时间</div>
                <div
                  v-for="row in rows"
                  :key="row.employeeId"
                  class="emp-head"
                  :style="{ width: `${EMP_COL_WIDTH}px` }"
                >
                  {{ row.employeeName }}
                </div>
              </div>
              <div class="board-body" :style="{ height: `${boardHeight}px` }">
                <div class="time-col" :style="{ width: `${TIME_COL_WIDTH}px` }">
                  <div
                    v-for="slot in timeLabels"
                    :key="slot.minutes"
                    class="time-cell"
                    :class="{ past: isPastSlot(slot.minutes) }"
                    :style="{ height: `${SLOT_HEIGHT}px` }"
                  >
                    {{ slot.label }}
                  </div>
                </div>
                <div
                  v-for="row in rows"
                  :key="row.employeeId"
                  class="emp-col"
                  :style="{ width: `${EMP_COL_WIDTH}px`, height: `${boardHeight}px` }"
                >
                  <div
                    v-for="slot in timeLabels"
                    :key="`${row.employeeId}-${slot.minutes}`"
                    class="grid-cell"
                    :class="{
                      past: isPastSlot(slot.minutes),
                      hover:
                        hoverSlot?.employeeId === row.employeeId &&
                        hoverSlot?.minutes === slot.minutes,
                    }"
                    :style="{ height: `${SLOT_HEIGHT}px` }"
                    @mouseenter="hoverSlot = { employeeId: row.employeeId, minutes: slot.minutes }"
                    @mouseleave="hoverSlot = null"
                    @click="onSlotClick(row.employeeId, slot.minutes, isPastSlot(slot.minutes))"
                  >
                    <button
                      v-if="
                        canEdit &&
                        hoverSlot?.employeeId === row.employeeId &&
                        hoverSlot?.minutes === slot.minutes
                      "
                      type="button"
                      class="slot-add"
                      @click.stop="
                        onSlotClick(row.employeeId, slot.minutes, isPastSlot(slot.minutes))
                      "
                    >
                      +
                    </button>
                  </div>

                  <div
                    v-if="nowLineTop != null"
                    class="now-line"
                    :style="{ top: `${nowLineTop}px` }"
                  />

                  <div
                    v-for="place in placementsByEmployee.get(row.employeeId) || []"
                    :key="place.appointment.id + '-' + place.lane"
                    class="apt-card"
                    :class="[`st-${place.appointment.status || 'UNK'}`]"
                    :style="{
                      top: `${place.top}px`,
                      height: `${place.height}px`,
                      width: 'calc(100% - 6px)',
                    }"
                    @mouseenter="hoverAptId = place.appointment.id"
                    @mouseleave="hoverAptId = null"
                    @click.stop="openDetail(place.appointment.id)"
                  >
                    <div class="apt-name">
                      {{ place.appointment.customerName || '顾客' }}
                    </div>
                    <div class="apt-proj">{{ projectSummary(place.appointment) }}</div>
                    <div class="apt-meta">
                      <span>{{ formatCardTime(place.appointment) }}</span>
                      <el-tag size="small" effect="plain">
                        {{
                          place.appointment.statusName ||
                          appointmentStatusLabel(place.appointment.status)
                        }}
                      </el-tag>
                    </div>
                    <button
                      v-if="place.overflowCount > 0"
                      type="button"
                      class="overflow-btn"
                      @click.stop="openOverflow(place.overflowGroup, row.employeeName)"
                    >
                      +{{ place.overflowCount }}
                    </button>
                    <div
                      v-if="hoverAptId === place.appointment.id"
                      class="apt-actions"
                      @click.stop
                    >
                      <el-button
                        v-if="canEdit && canModifyAppointment(place.appointment.status)"
                        link
                        type="primary"
                        size="small"
                        @click="openEdit(place.appointment.id)"
                      >
                        修改
                      </el-button>
                      <el-button
                        v-if="canEdit && canCancelAppointment(place.appointment.status)"
                        link
                        type="danger"
                        size="small"
                        @click="quickCancel(place.appointment.id)"
                      >
                        取消
                      </el-button>
                      <el-button
                        v-if="canStatus && canArriveAppointment(place.appointment.status)"
                        link
                        type="success"
                        size="small"
                        @click="quickArrive(place.appointment.id)"
                      >
                        到店
                      </el-button>
                      <el-button
                        v-if="canStatus && canOpenTreatAppointment(place.appointment.status)"
                        link
                        type="success"
                        size="small"
                        @click="quickOpenTreat(place.appointment.id)"
                      >
                        开消耗
                      </el-button>
                      <el-button
                        link
                        type="info"
                        size="small"
                        @click="openDetail(place.appointment.id)"
                      >
                        详情
                      </el-button>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </template>
      </div>

      <aside class="invite-pane" :style="{ width: `${INVITE_WIDTH}px` }">
        <h3>邀约辅助</h3>
        <p class="invite-desc">
          历史上常在「星期{{
            ['一', '二', '三', '四', '五', '六', '日'][
              (parseLocalDateTime(selectedDate + 'T00:00:00')?.getDay() || 1) === 0
                ? 6
                : (parseLocalDateTime(selectedDate + 'T00:00:00')?.getDay() || 1) - 1
            ]
          }}」到店的顾客
        </p>
        <div v-if="inviteList.length === 0" class="invite-empty">
          暂无足够历史到店数据，无法生成邀约建议。
        </div>
        <div v-else class="invite-list">
          <div v-for="item in inviteList" :key="item.customerId" class="invite-item">
            <div class="invite-name">{{ item.customerName || item.customerId }}</div>
            <div class="invite-meta">
              {{ item.customerMobile || '—' }} · 同星期到店
              {{ item.weekdayVisitCount || 0 }} 次
            </div>
            <el-button
              v-if="canEdit"
              size="small"
              type="primary"
              plain
              @click="inviteCreate(item)"
            >
              快速预约
            </el-button>
          </div>
        </div>
      </aside>
    </div>

    <AppointmentFormDialog
      v-model="formVisible"
      :appointment-id="formAppointmentId"
      :default-date="selectedDate"
      :default-employee-id="formDefaultEmployeeId"
      :default-start-time="formDefaultStartTime"
      @success="onFormSuccess"
    />

    <AppointmentDetailDrawer
      v-model="detailVisible"
      :appointment-id="detailAppointmentId"
      @edit="openEdit"
      @changed="loadBoard"
    />

    <el-dialog v-model="overflowVisible" :title="overflowTitle" width="520px" destroy-on-close>
      <el-table :data="overflowList" border size="small" max-height="360">
        <el-table-column label="顾客" min-width="100">
          <template #default="{ row }">{{ row.customerName || '—' }}</template>
        </el-table-column>
        <el-table-column label="项目" min-width="140">
          <template #default="{ row }">{{ projectSummary(row) }}</template>
        </el-table-column>
        <el-table-column label="时间" width="110">
          <template #default="{ row }">{{ formatCardTime(row) }}</template>
        </el-table-column>
        <el-table-column label="状态" width="90">
          <template #default="{ row }">
            {{ row.statusName || appointmentStatusLabel(row.status) }}
          </template>
        </el-table-column>
        <el-table-column label="操作" width="80">
          <template #default="{ row }">
            <el-button
              link
              type="primary"
              @click="
                () => {
                  overflowVisible = false
                  openDetail(row.id)
                }
              "
            >
              详情
            </el-button>
          </template>
        </el-table-column>
      </el-table>
      <template #footer>
        <el-button
          v-if="canEdit"
          type="primary"
          @click="
            () => {
              overflowVisible = false
              openCreate()
            }
          "
        >
          继续新增
        </el-button>
      </template>
    </el-dialog>
  </div>
</template>

<style scoped>
.page {
  padding: 12px 16px;
  height: 100%;
  display: flex;
  flex-direction: column;
  min-height: 0;
  box-sizing: border-box;
}
.filter-bar {
  background: #fff;
  border: 1px solid #ebeef5;
  border-radius: 4px;
  padding: 10px 14px 6px;
  margin-bottom: 10px;
  flex-shrink: 0;
}
.filter-toolbar {
  display: flex;
  justify-content: space-between;
  gap: 12px;
  flex-wrap: wrap;
}
.filter-form {
  margin-bottom: 0;
}
.date-nav {
  display: flex;
  align-items: center;
  gap: 8px;
}
.axis-hint {
  margin: 0 0 4px;
  font-size: 12px;
  color: #909399;
}
.main-row {
  flex: 1;
  min-height: 0;
  min-width: 0;
  width: 100%;
  display: flex;
  flex-wrap: wrap;
  gap: 10px;
  align-items: stretch;
}
.board-pane {
  flex: 1 1 520px;
  min-width: 0;
  background: #fff;
  border: 1px solid #ebeef5;
  border-radius: 4px;
  overflow: hidden;
  position: relative;
}
.invite-pane {
  flex: 0 1 280px;
  width: 280px;
  min-width: 220px;
  background: #fff;
  border: 1px solid #ebeef5;
  border-radius: 4px;
  padding: 12px;
  overflow: auto;
  max-height: calc(100vh - 210px);
}
.invite-pane h3 {
  margin: 0 0 6px;
  font-size: 15px;
}
.invite-desc {
  margin: 0 0 10px;
  font-size: 12px;
  color: #909399;
  line-height: 1.4;
}
.invite-empty {
  font-size: 12px;
  color: #c0c4cc;
  padding: 16px 0;
}
.invite-item {
  border-top: 1px solid #f0f2f5;
  padding: 10px 0;
}
.invite-name {
  font-weight: 600;
  font-size: 13px;
}
.invite-meta {
  font-size: 12px;
  color: #909399;
  margin: 4px 0 8px;
}
.empty-wrap {
  padding: 48px 16px;
}
.board-scroll {
  overflow: auto;
  height: 100%;
  max-height: calc(100vh - 210px);
}
.board-header {
  display: flex;
  position: sticky;
  top: 0;
  z-index: 3;
  background: #f5f7fa;
  border-bottom: 1px solid #e4e7ed;
}
.time-head,
.emp-head {
  flex-shrink: 0;
  padding: 10px 8px;
  font-size: 13px;
  font-weight: 600;
  text-align: center;
  border-right: 1px solid #ebeef5;
  box-sizing: border-box;
}
.board-body {
  display: flex;
  position: relative;
}
.time-col {
  flex-shrink: 0;
  background: #fafafa;
  border-right: 1px solid #ebeef5;
  position: sticky;
  left: 0;
  z-index: 2;
}
.time-cell {
  box-sizing: border-box;
  border-bottom: 1px solid #ebeef5;
  font-size: 12px;
  color: #606266;
  display: flex;
  justify-content: center;
  padding-top: 4px;
}
.time-cell.past {
  background: #f0f0f0;
  color: #a8abb2;
}
.emp-col {
  position: relative;
  flex-shrink: 0;
  border-right: 1px solid #ebeef5;
  box-sizing: border-box;
}
.grid-cell {
  box-sizing: border-box;
  border-bottom: 1px solid #ebeef5;
  position: relative;
  cursor: pointer;
}
.grid-cell.past {
  background: rgba(0, 0, 0, 0.04);
}
.grid-cell.hover {
  background: rgba(64, 158, 255, 0.08);
}
.slot-add {
  position: absolute;
  right: 6px;
  top: 6px;
  width: 22px;
  height: 22px;
  border: 1px dashed #409eff;
  border-radius: 4px;
  background: #ecf5ff;
  color: #409eff;
  cursor: pointer;
  line-height: 20px;
  z-index: 4;
}
.now-line {
  position: absolute;
  left: 0;
  right: 0;
  height: 2px;
  background: #f56c6c;
  z-index: 5;
  pointer-events: none;
}
.apt-card {
  position: absolute;
  left: 3px;
  border-radius: 4px;
  padding: 4px 6px;
  box-sizing: border-box;
  overflow: hidden;
  cursor: pointer;
  z-index: 3;
  border: 1px solid transparent;
  background: #e8f3ff;
}
.apt-card.st-WAIT {
  background: #fdf6ec;
  border-color: #f5dab1;
}
.apt-card.st-CONF {
  background: #ecf5ff;
  border-color: #b3d8ff;
}
.apt-card.st-ARRV {
  background: #e8f8ef;
  border-color: #95d5b2;
}
.apt-card.st-SERV {
  background: #d8f3dc;
  border-color: #74c69d;
}
.apt-card.st-DONE {
  background: #f4f4f5;
  border-color: #d3d4d6;
}
.apt-card.st-CANC,
.apt-card.st-NOSH {
  background: #fef0f0;
  border-color: #fbc4c4;
  opacity: 0.85;
}
.apt-name {
  font-size: 12px;
  font-weight: 600;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}
.apt-proj,
.apt-meta {
  font-size: 11px;
  color: #606266;
  display: flex;
  justify-content: space-between;
  gap: 4px;
  white-space: nowrap;
  overflow: hidden;
}
.overflow-btn {
  position: absolute;
  right: 4px;
  bottom: 2px;
  border: none;
  background: rgba(0, 0, 0, 0.55);
  color: #fff;
  border-radius: 10px;
  font-size: 11px;
  padding: 0 6px;
  cursor: pointer;
  z-index: 4;
}
.apt-actions {
  position: absolute;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(255, 255, 255, 0.95);
  display: flex;
  flex-wrap: wrap;
  gap: 0 4px;
  padding: 2px 4px;
  z-index: 6;
}
</style>
