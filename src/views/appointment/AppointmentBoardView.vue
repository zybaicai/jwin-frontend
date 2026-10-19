<script setup lang="ts">
import { computed, onMounted, onUnmounted, ref, watch } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessageBox } from 'element-plus'

import AppEmpty from '@/components/common/AppEmpty.vue'
import AppError from '@/components/common/AppError.vue'
import AppointmentFormDialog from '@/components/appointment/AppointmentFormDialog.vue'
import {
  arriveAppointment,
  cancelAppointment,
  fetchAppointmentBoard,
  fetchAppointmentCapacities,
  fetchAppointmentConfig,
  fetchAppointmentEmployees,
  fetchInviteAssist,
  openTreatFromAppointment,
} from '@/api/appointment'
import {
  APPOINTMENT_STATUS_OPTIONS,
  AppointmentPermission,
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

/** 虚拟列：未分派护理师的到店确认登记 */
const WALK_IN_ID = '__WALK_IN__'

const SLOT_HEIGHT = 48
const EMP_COL_WIDTH = 176
const WALK_IN_COL_WIDTH = 152
const TIME_COL_WIDTH = 68
const INVITE_WIDTH = 280
const DEFAULT_MAX_CONCURRENT = 2

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
const allowMultiBooking = ref(true)
const capacityByEmployee = ref<Map<string, number>>(new Map())

const formVisible = ref(false)
const formAppointmentId = ref<string | null>(null)
const formDefaultEmployeeId = ref<string | null>(null)
const formDefaultStartTime = ref<string | null>(null)
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
  rest: boolean
  walkIn: boolean
  colWidth: number
}

interface BoardCardPlacement {
  appointment: AppointmentItem
  top: number
  height: number
  lane: number
  laneCount: number
}

interface TimedApt {
  appointment: AppointmentItem
  startMin: number
  endMin: number
  lane: number
  laneCount: number
}

const restEmployeeIds = computed(() => {
  const set = new Set<string>()
  for (const d of board.value?.onDuty ?? []) {
    if (d.employeeId && d.rest) set.add(d.employeeId)
  }
  return set
})

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
  const walkIn: BoardRow = {
    employeeId: WALK_IN_ID,
    employeeName: '到店确认',
    rest: false,
    walkIn: true,
    colWidth: WALK_IN_COL_WIDTH,
  }

  const map = new Map<string, BoardRow>()
  for (const emp of employees.value) {
    if (!emp.employeeId) continue
    map.set(emp.employeeId, {
      employeeId: emp.employeeId,
      employeeName: emp.employeeName?.trim() || emp.employeeId,
      rest: restEmployeeIds.value.has(emp.employeeId),
      walkIn: false,
      colWidth: empColWidth(emp.employeeId),
    })
  }
  for (const d of board.value?.onDuty ?? []) {
    if (!d.employeeId) continue
    const existing = map.get(d.employeeId)
    if (existing) {
      existing.rest = !!d.rest
    } else {
      map.set(d.employeeId, {
        employeeId: d.employeeId,
        employeeName: d.employeeId,
        rest: !!d.rest,
        walkIn: false,
        colWidth: empColWidth(d.employeeId),
      })
    }
  }
  for (const apt of board.value?.appointments ?? []) {
    if (!apt.employeeId) continue
    const existing = map.get(apt.employeeId)
    if (!existing) {
      map.set(apt.employeeId, {
        employeeId: apt.employeeId,
        employeeName: apt.employeeName?.trim() || apt.employeeId,
        rest: restEmployeeIds.value.has(apt.employeeId),
        walkIn: false,
        colWidth: empColWidth(apt.employeeId),
      })
    } else if (apt.employeeName?.trim()) {
      existing.employeeName = apt.employeeName.trim()
    }
  }

  let list = [...map.values()]
  if (filterEmployeeId.value) {
    list = list.filter((r) => r.employeeId === filterEmployeeId.value)
  }
  list.sort((a, b) => a.employeeName.localeCompare(b.employeeName, 'zh-CN'))
  return [walkIn, ...list]
})

const boardMinWidth = computed(
  () => TIME_COL_WIDTH + rows.value.reduce((s, r) => s + r.colWidth, 0),
)

/** 看板不展示终态：已取消 / 爽约（避免占格；列表/筛选仍可查） */
function isHiddenOnBoard(status: string | null | undefined): boolean {
  const s = (status || '').trim().toUpperCase()
  return s === 'CANC' || s === 'CANCELLED' || s === 'NOSH' || s === 'NO_SHOW'
}

const filteredAppointments = computed(() => {
  let list = (board.value?.appointments ?? []).filter((a) => !isHiddenOnBoard(a.status))
  if (filterStatus.value) {
    // 若主动筛选已取消/爽约，仍允许看（便于核对）；默认不展示
    if (!isHiddenOnBoard(filterStatus.value)) {
      list = list.filter((a) => a.status === filterStatus.value)
    } else {
      list = (board.value?.appointments ?? []).filter((a) => a.status === filterStatus.value)
    }
  }
  if (filterEmployeeId.value) {
    list = list.filter((a) => a.employeeId === filterEmployeeId.value)
  }
  return list
})

const placementsByEmployee = computed(() => {
  const result = new Map<string, BoardCardPlacement[]>()
  const byEmp = new Map<string, AppointmentItem[]>()
  for (const apt of filteredAppointments.value) {
    if (!apt.startDateTime) continue
    const empId = apt.employeeId?.trim() ? apt.employeeId : WALK_IN_ID
    if (filterEmployeeId.value && empId === WALK_IN_ID) continue
    const arr = byEmp.get(empId) ?? []
    arr.push(apt)
    byEmp.set(empId, arr)
  }
  for (const [empId, apts] of byEmp) {
    result.set(empId, packOverlappingLanes(apts))
  }
  return result
})

function empColWidth(employeeId: string): number {
  const max = maxConcurrentFor(employeeId)
  return Math.max(EMP_COL_WIDTH, Math.min(max, 3) * 100)
}

function maxConcurrentFor(employeeId: string): number {
  if (employeeId === WALK_IN_ID) return 4
  if (!allowMultiBooking.value) return 1
  return capacityByEmployee.value.get(employeeId) ?? DEFAULT_MAX_CONCURRENT
}

function isCountableStatus(status: string | null | undefined): boolean {
  return status === 'WAIT' || status === 'CONF' || status === 'ARRV' || status === 'SERV'
}

function aptTimeRange(apt: AppointmentItem): { startMin: number; endMin: number } | null {
  if (!apt.startDateTime) return null
  const start = parseLocalDateTime(apt.startDateTime)
  if (!start) return null
  const startMin = start.getHours() * 60 + start.getMinutes()
  let endMin = startMin + (apt.durationMinutes ?? slotMinutes.value)
  if (apt.endDateTime) {
    const end = parseLocalDateTime(apt.endDateTime)
    if (end) {
      endMin = end.getHours() * 60 + end.getMinutes()
      if (endMin <= startMin) endMin = startMin + (apt.durationMinutes ?? slotMinutes.value)
    }
  }
  return { startMin, endMin }
}

/** 按真实时间重叠分轨并排，禁止叠盖；连通分量内 laneCount 一致 */
function packOverlappingLanes(apts: AppointmentItem[]): BoardCardPlacement[] {
  const timed: TimedApt[] = []
  for (const apt of apts) {
    const range = aptTimeRange(apt)
    if (!range) continue
    timed.push({
      appointment: apt,
      startMin: range.startMin,
      endMin: range.endMin,
      lane: 0,
      laneCount: 1,
    })
  }
  timed.sort((a, b) => a.startMin - b.startMin || a.endMin - b.endMin)

  const laneEnds: number[] = []
  for (const item of timed) {
    let lane = 0
    while (lane < laneEnds.length && laneEnds[lane]! > item.startMin) lane++
    if (lane === laneEnds.length) laneEnds.push(item.endMin)
    else laneEnds[lane] = item.endMin
    item.lane = lane
  }

  const n = timed.length
  const parent = Array.from({ length: n }, (_, i) => i)
  const find = (i: number): number => (parent[i] === i ? i : (parent[i] = find(parent[i]!)))
  const union = (a: number, b: number) => {
    const ra = find(a)
    const rb = find(b)
    if (ra !== rb) parent[ra] = rb
  }
  for (let i = 0; i < n; i++) {
    for (let j = i + 1; j < n; j++) {
      const a = timed[i]!
      const b = timed[j]!
      if (a.startMin < b.endMin && b.startMin < a.endMin) union(i, j)
    }
  }
  const maxLaneByRoot = new Map<number, number>()
  for (let i = 0; i < n; i++) {
    const root = find(i)
    maxLaneByRoot.set(root, Math.max(maxLaneByRoot.get(root) ?? 0, timed[i]!.lane))
  }
  for (let i = 0; i < n; i++) {
    timed[i]!.laneCount = (maxLaneByRoot.get(find(i)) ?? 0) + 1
  }

  const placements: BoardCardPlacement[] = []
  for (const item of timed) {
    const clampedStart = Math.max(item.startMin, axisStartMinutes.value)
    const clampedEnd = Math.min(item.endMin, axisEndMinutes.value)
    if (clampedEnd <= axisStartMinutes.value || clampedStart >= axisEndMinutes.value) continue
    const top =
      ((clampedStart - axisStartMinutes.value) / slotMinutes.value) * SLOT_HEIGHT
    const height = Math.max(
      SLOT_HEIGHT * 0.72,
      ((clampedEnd - clampedStart) / slotMinutes.value) * SLOT_HEIGHT,
    )
    placements.push({
      appointment: item.appointment,
      top,
      height,
      lane: item.lane,
      laneCount: item.laneCount,
    })
  }
  return placements
}

function countCoveringAt(employeeId: string, atMinutes: number): number {
  let count = 0
  for (const apt of board.value?.appointments ?? []) {
    if (apt.employeeId !== employeeId) continue
    if (!isCountableStatus(apt.status)) continue
    const range = aptTimeRange(apt)
    if (!range) continue
    if (range.startMin <= atMinutes && atMinutes < range.endMin) count++
  }
  return count
}

/** 该护理师该时刻已达同时预约上限（并排满员时缝隙也不再提示新增） */
function isSlotAtCapacity(employeeId: string, atMinutes: number): boolean {
  if (employeeId === WALK_IN_ID) return false
  return countCoveringAt(employeeId, atMinutes) >= maxConcurrentFor(employeeId)
}

function canShowSlotAdd(employeeId: string, atMinutes: number, rest: boolean): boolean {
  return canEdit.value && !rest && !isSlotAtCapacity(employeeId, atMinutes)
}

let hoverClearTimer: ReturnType<typeof setTimeout> | null = null

function onCardMouseEnter(aptId: string): void {
  if (hoverClearTimer) {
    clearTimeout(hoverClearTimer)
    hoverClearTimer = null
  }
  hoverAptId.value = aptId
  hoverSlot.value = null
}

function scheduleClearHoverApt(): void {
  if (hoverClearTimer) clearTimeout(hoverClearTimer)
  hoverClearTimer = setTimeout(() => {
    hoverAptId.value = null
    hoverClearTimer = null
  }, 120)
}

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

function isAppointmentPast(apt: AppointmentItem): boolean {
  if (!isToday.value) {
    const sel = parseLocalDateTime(`${selectedDate.value}T00:00:00`)
    if (!sel) return false
    const today = new Date()
    today.setHours(0, 0, 0, 0)
    return sel.getTime() < today.getTime()
  }
  const range = aptTimeRange(apt)
  if (!range) return false
  const d = new Date(nowTick.value)
  const nowMin = d.getHours() * 60 + d.getMinutes()
  return range.endMin <= nowMin
}

function openCreate(prefill?: { employeeId?: string; startMinutes?: number }): void {
  formAppointmentId.value = null
  const emp = prefill?.employeeId
  formDefaultEmployeeId.value =
    emp && emp !== WALK_IN_ID ? emp : null
  formDefaultStartTime.value =
    prefill?.startMinutes != null ? minutesToHm(prefill.startMinutes) : null
  formVisible.value = true
}

function openEdit(id: string): void {
  formAppointmentId.value = id
  formDefaultEmployeeId.value = null
  formDefaultStartTime.value = null
  formVisible.value = true
}

function tryOpenCreate(employeeId: string, minutes: number): void {
  if (employeeId !== WALK_IN_ID) {
    const max = maxConcurrentFor(employeeId)
    const covering = countCoveringAt(employeeId, minutes)
    if (covering >= max) {
      uiMessage.warning(
        allowMultiBooking.value
          ? `该护理师此时段同时预约已达上限（${max}），请改选其他时间或护理师`
          : '本店已禁止多人同时预约，该护理师此时段已有预约',
      )
      return
    }
  }
  openCreate({ employeeId, startMinutes: minutes })
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
      .then(() => tryOpenCreate(employeeId, minutes))
      .catch(() => undefined)
    return
  }
  tryOpenCreate(employeeId, minutes)
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
    const query: Record<string, string> = {
      mode: 'consume',
      appointmentId: id,
    }
    if (result.customerId != null) {
      query.customerId = String(result.customerId)
    }
    if (result.projectIds?.length) {
      query.projectIds = result.projectIds.join(',')
    }
    await router.push({
      path: '/sales/cashier',
      query,
    })
  } catch (e) {
    uiMessage.error(getUserFriendlyErrorMessage(e))
  }
}

function cardRemark(apt: AppointmentItem): string {
  const r = apt.remark?.trim()
  return r || ''
}

function maskPhone(mobile: string | null | undefined): string {
  const m = (mobile || '').trim()
  if (m.length < 7) return m || '—'
  return `${m.slice(0, 3)}****${m.slice(-4)}`
}

function statusTone(status: string | null | undefined): 'pending' | 'arrived' | 'done' | 'cancel' {
  if (status === 'ARRV' || status === 'SERV') return 'arrived'
  if (status === 'DONE') return 'done'
  if (status === 'CANC' || status === 'NOSH') return 'cancel'
  return 'pending'
}

function cardLayoutStyle(place: BoardCardPlacement): Record<string, string> {
  const laneCount = Math.max(1, place.laneCount)
  // 列两侧留白，并排卡片贴缝无中间空隙，避免鼠标从缝里点到底层格子
  const outer = 3
  const widthPct = 100 / laneCount
  const leftPct = (place.lane / laneCount) * 100
  const isFirst = place.lane === 0
  const isLast = place.lane === laneCount - 1
  const leftPad = isFirst ? outer : 1
  const rightPad = isLast ? outer : 1
  return {
    top: `${place.top}px`,
    height: `${Math.max(place.height, SLOT_HEIGHT * 0.88)}px`,
    left: `calc(${leftPct}% + ${leftPad}px)`,
    width: `calc(${widthPct}% - ${leftPad + rightPad}px)`,
  }
}

/** 相对卡片定位（勿用看板绝对 top，下午时段会整块甩出视野） */
function hoverPopoverStyle(_place: BoardCardPlacement): Record<string, string> {
  return {
    top: '0',
    left: 'calc(100% + 6px)',
  }
}

function inviteCreate(item: InviteAssistItem): void {
  formAppointmentId.value = null
  formDefaultEmployeeId.value = filterEmployeeId.value || null
  formDefaultStartTime.value = null
  formVisible.value = true
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
    const storeId = storeStore.currentStoreId ?? undefined
    const [cfg, caps] = await Promise.all([
      fetchAppointmentConfig(storeId),
      fetchAppointmentCapacities(storeId).catch(() => []),
    ])
    if (cfg?.startTime) axisStartMinutes.value = parseHmToMinutes(cfg.startTime, 9 * 60)
    if (cfg?.endTime) axisEndMinutes.value = parseHmToMinutes(cfg.endTime, 21 * 60)
    if (cfg?.period && cfg.period > 0) slotMinutes.value = cfg.period
    else slotMinutes.value = 15
    allowMultiBooking.value = cfg?.allowMultiBooking !== false
    const map = new Map<string, number>()
    for (const c of caps) {
      if (c.employeeId && c.maxConcurrent > 0) map.set(c.employeeId, c.maxConcurrent)
    }
    capacityByEmployee.value = map
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
        <div class="toolbar-right">
          <div class="legend" aria-label="看板图例">
            <span class="legend-item">
              <i class="swatch swatch-pending" />
              未到店
            </span>
            <span class="legend-item">
              <i class="swatch swatch-arrived" />
              已到店
            </span>
            <span class="legend-item">
              <i class="swatch swatch-free" />
              空闲
            </span>
            <span class="legend-item">
              <i class="swatch swatch-rest" />
              休息
            </span>
            <span class="legend-item">
              <i class="swatch swatch-past" />
              已过时段
            </span>
          </div>
          <el-button v-if="canEdit" type="primary" @click="openCreate()">新增预约</el-button>
        </div>
      </div>
      <!-- <p class="axis-hint">
        时间粒度 {{ slotMinutes }} 分钟 · 最左「到店确认」列用于未分派护理师的登记 · 过期格子变暗仍可操作
      </p> -->
    </div>

    <div v-loading="loading" class="main-row">
      <div class="board-pane">
        <AppError v-if="error && !loading" :description="error" @retry="loadBoard" />
        <template v-else>
          <div v-if="rows.length <= 1 && employees.length === 0" class="empty-wrap">
            <AppEmpty title="当日暂无护理师或预约" />
          </div>
          <div v-else class="board-scroll">
            <div class="board" :style="{ minWidth: `${boardMinWidth}px` }">
              <div class="board-header">
                <div class="time-head" :style="{ width: `${TIME_COL_WIDTH}px` }">时间</div>
                <div
                  v-for="row in rows"
                  :key="row.employeeId"
                  class="emp-head"
                  :class="{ 'rest-head': row.rest }"
                  :style="{ width: `${row.colWidth}px` }"
                >
                  <span class="emp-name">{{ row.employeeName }}</span>
                  <span v-if="row.rest" class="rest-badge">休息</span>
                  <span v-else-if="row.walkIn" class="walk-badge">登记</span>
                </div>
              </div>
              <div class="board-body" :style="{ height: `${boardHeight}px` }">
                <div
                  v-if="nowLineTop != null"
                  class="board-now-overlay"
                  :style="{ left: `${TIME_COL_WIDTH}px` }"
                >
                  <div class="past-mask" :style="{ height: `${nowLineTop}px` }" />
                  <div class="now-line" :style="{ top: `${nowLineTop}px` }">
                    <span class="now-label">当前时间</span>
                  </div>
                </div>
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
                  :class="{ 'walk-in-col': row.walkIn, 'rest-col': row.rest }"
                  :style="{ width: `${row.colWidth}px`, height: `${boardHeight}px` }"
                >
                  <div
                    v-for="slot in timeLabels"
                    :key="`${row.employeeId}-${slot.minutes}`"
                    class="grid-cell"
                    :class="{
                      past: isPastSlot(slot.minutes),
                      hover:
                        hoverSlot?.employeeId === row.employeeId &&
                        hoverSlot?.minutes === slot.minutes &&
                        canShowSlotAdd(row.employeeId, slot.minutes, row.rest),
                      rest: row.rest,
                      full: isSlotAtCapacity(row.employeeId, slot.minutes),
                    }"
                    :style="{ height: `${SLOT_HEIGHT}px` }"
                    @mouseenter="hoverSlot = { employeeId: row.employeeId, minutes: slot.minutes }"
                    @mouseleave="hoverSlot = null"
                    @click="onSlotClick(row.employeeId, slot.minutes, isPastSlot(slot.minutes))"
                  >
                    <button
                      v-if="
                        canShowSlotAdd(row.employeeId, slot.minutes, row.rest) &&
                        hoverSlot?.employeeId === row.employeeId &&
                        hoverSlot?.minutes === slot.minutes
                      "
                      type="button"
                      class="slot-add"
                      @click.stop="
                        onSlotClick(row.employeeId, slot.minutes, isPastSlot(slot.minutes))
                      "
                    >
                      {{ row.walkIn ? '登记预约' : '新增预约' }}
                    </button>
                    <span v-else-if="row.rest" class="rest-mark">休</span>
                  </div>

                  <div
                    v-for="place in placementsByEmployee.get(row.employeeId) || []"
                    :key="place.appointment.id + '-' + place.lane"
                    class="apt-card"
                    :class="[
                      `tone-${statusTone(place.appointment.status)}`,
                      `st-${place.appointment.status || 'UNK'}`,
                      { 'is-past': isAppointmentPast(place.appointment) },
                    ]"
                    :style="cardLayoutStyle(place)"
                    @mouseenter="onCardMouseEnter(place.appointment.id)"
                    @mouseleave="scheduleClearHoverApt"
                    @click.stop
                  >
                    <div class="apt-name">
                      {{ place.appointment.customerName || '顾客' }}
                    </div>
                    <div class="apt-line">{{ formatCardTime(place.appointment) }}</div>
                    <div class="apt-line">{{ projectSummary(place.appointment) || '未选项目' }}</div>
                    <div v-if="cardRemark(place.appointment)" class="apt-line apt-remark">
                      {{ cardRemark(place.appointment) }}
                    </div>

                    <div
                      v-if="hoverAptId === place.appointment.id"
                      class="apt-popover"
                      :style="hoverPopoverStyle(place)"
                      @mouseenter="onCardMouseEnter(place.appointment.id)"
                      @mouseleave="scheduleClearHoverApt"
                      @click.stop
                    >
                      <div class="pop-head">
                        <strong>{{ place.appointment.customerName || '顾客' }}</strong>
                      </div>
                      <div class="pop-phone">
                        {{ maskPhone(place.appointment.customerMobile) }}
                      </div>
                      <div class="pop-row">
                        <span class="pop-label">预约时间</span>
                        <span>{{ formatCardTime(place.appointment) }}</span>
                      </div>
                      <div class="pop-row">
                        <span class="pop-label">商家备注</span>
                        <span>{{ cardRemark(place.appointment) || '—' }}</span>
                      </div>
                      <div class="pop-actions">
                        <el-button
                          v-if="canEdit && canModifyAppointment(place.appointment.status)"
                          type="primary"
                          size="small"
                          plain
                          class="pop-btn"
                          @click="openEdit(place.appointment.id)"
                        >
                          修改预约
                        </el-button>
                        <el-button
                          v-if="canStatus && canArriveAppointment(place.appointment.status)"
                          type="success"
                          size="small"
                          class="pop-btn"
                          @click="quickArrive(place.appointment.id)"
                        >
                          到店确认
                        </el-button>
                        <el-button
                          v-if="canStatus && canOpenTreatAppointment(place.appointment.status)"
                          type="success"
                          size="small"
                          class="pop-btn"
                          @click="quickOpenTreat(place.appointment.id)"
                        >
                          开消耗
                        </el-button>
                        <el-button
                          v-if="canEdit && canCancelAppointment(place.appointment.status)"
                          type="danger"
                          size="small"
                          class="pop-btn"
                          @click="quickCancel(place.appointment.id)"
                        >
                          取消预约
                        </el-button>
                      </div>
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

  </div>
</template>

<style scoped>
.page {
  --board-bg: #f3f5f8;
  --board-surface: #ffffff;
  --board-line: #e8ecf1;
  --board-line-soft: #f0f3f7;
  --board-ink: #1f2a37;
  --board-muted: #8b95a5;
  --accent: var(--el-color-primary);
  --pending: #ff8646;
  --arrived: #45c57b;
  --free: #ffffff;
  --rest: #cbd5e1;
  padding: 12px 16px;
  height: 100%;
  display: flex;
  flex-direction: column;
  min-height: 0;
  box-sizing: border-box;
  background: linear-gradient(180deg, #eef1f6 0%, #f7f8fb 120px, #f7f8fb 100%);
}
.filter-bar {
  background: var(--board-surface);
  border: 1px solid var(--board-line);
  border-radius: 12px;
  padding: 12px 16px 8px;
  margin-bottom: 12px;
  flex-shrink: 0;
  box-shadow: 0 1px 2px rgba(31, 42, 55, 0.04);
}
.filter-toolbar {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
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
.toolbar-right {
  display: flex;
  align-items: center;
  gap: 14px;
  flex-wrap: wrap;
}
.legend {
  display: flex;
  align-items: center;
  gap: 12px;
  flex-wrap: wrap;
  padding: 6px 10px;
  background: #f7f9fc;
  border: 1px solid var(--board-line-soft);
  border-radius: 999px;
}
.legend-item {
  display: inline-flex;
  align-items: center;
  gap: 6px;
  font-size: 12px;
  color: #4b5565;
  white-space: nowrap;
}
.swatch {
  width: 14px;
  height: 14px;
  border-radius: 4px;
  border: 1px solid transparent;
  display: inline-block;
  box-sizing: border-box;
}
.swatch-pending {
  background: #ff8646;
  border-color: #e86f2f;
}
.swatch-arrived {
  background: #45c57b;
  border-color: #36b068;
}
.swatch-free {
  background: #fff;
  border-color: #d1d5db;
  box-shadow: inset 0 0 0 1px #f3f4f6;
}
.swatch-rest {
  background: repeating-linear-gradient(
    -45deg,
    #e2e8f0,
    #e2e8f0 3px,
    #f8fafc 3px,
    #f8fafc 6px
  );
  border-color: #cbd5e1;
}
.swatch-past {
  background: linear-gradient(135deg, #e8eef5 0%, #c5d0dc 100%);
  border-color: #94a3b8;
}
.axis-hint {
  margin: 4px 0 2px;
  font-size: 12px;
  color: var(--board-muted);
}
.main-row {
  flex: 1;
  min-height: 0;
  min-width: 0;
  width: 100%;
  display: flex;
  flex-wrap: wrap;
  gap: 12px;
  align-items: stretch;
}
.board-pane {
  flex: 1 1 520px;
  min-width: 0;
  background: var(--board-surface);
  border: 1px solid var(--board-line);
  border-radius: 12px;
  overflow: hidden;
  position: relative;
  box-shadow: 0 8px 24px rgba(31, 42, 55, 0.05);
}
.invite-pane {
  flex: 0 1 280px;
  width: 280px;
  min-width: 220px;
  background: var(--board-surface);
  border: 1px solid var(--board-line);
  border-radius: 12px;
  padding: 14px;
  overflow: auto;
  max-height: calc(100vh - 210px);
  box-shadow: 0 8px 24px rgba(31, 42, 55, 0.04);
}
.invite-pane h3 {
  margin: 0 0 6px;
  font-size: 15px;
  color: var(--board-ink);
}
.invite-desc {
  margin: 0 0 10px;
  font-size: 12px;
  color: var(--board-muted);
  line-height: 1.4;
}
.invite-empty {
  font-size: 12px;
  color: #c0c4cc;
  padding: 16px 0;
}
.invite-item {
  border-top: 1px solid var(--board-line-soft);
  padding: 10px 0;
}
.invite-name {
  font-weight: 600;
  font-size: 13px;
  color: var(--board-ink);
}
.invite-meta {
  font-size: 12px;
  color: var(--board-muted);
  margin: 4px 0 8px;
}
.empty-wrap {
  padding: 48px 16px;
}
.board-scroll {
  overflow: auto;
  height: 100%;
  max-height: calc(100vh - 210px);
  background: linear-gradient(180deg, #fafbfc 0%, #fff 40px);
}
.board-header {
  display: flex;
  position: sticky;
  top: 0;
  /* 高于预约卡片（5/20）与悬浮预览（30），避免下滑时卡片盖住护理师表头 */
  z-index: 40;
  background: linear-gradient(180deg, #f8fafc 0%, #f1f5f9 100%);
  border-bottom: 1px solid var(--board-line);
  box-shadow: 0 1px 0 rgba(15, 23, 42, 0.04);
}
.time-head,
.emp-head {
  flex-shrink: 0;
  padding: 12px 8px;
  font-size: 13px;
  font-weight: 600;
  text-align: center;
  border-right: 1px solid var(--board-line);
  box-sizing: border-box;
  color: var(--board-ink);
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 6px;
  background: #f1f5f9;
}
.time-head {
  position: sticky;
  left: 0;
  z-index: 41;
  background: #f8fafc;
}
.rest-head {
  background: #e8eef4;
  color: #64748b;
}
.emp-name {
  max-width: 100%;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}
.rest-badge,
.walk-badge {
  font-size: 10px;
  font-weight: 600;
  padding: 1px 6px;
  border-radius: 999px;
  flex-shrink: 0;
  background: #e2e8f0;
  color: #64748b;
}
.board-body {
  display: flex;
  position: relative;
}
.time-col {
  flex-shrink: 0;
  background: #f8fafc;
  border-right: 1px solid var(--board-line);
  position: sticky;
  left: 0;
  /* 低于表头，高于格子内卡片，保证横滑时时间列不被卡片盖住 */
  z-index: 6;
}
.time-cell {
  box-sizing: border-box;
  border-bottom: 1px solid var(--board-line-soft);
  font-size: 12px;
  color: #64748b;
  display: flex;
  justify-content: center;
  padding-top: 6px;
  font-variant-numeric: tabular-nums;
}
.time-cell.past {
  background: #e8eef4;
  color: #64748b;
}
.emp-col {
  position: relative;
  flex-shrink: 0;
  border-right: 1px solid var(--board-line);
  box-sizing: border-box;
  background: #fff;
}
.walk-in-col {
  background: linear-gradient(180deg, #f8fbff 0%, #fff 80px);
}
.rest-col {
  background: repeating-linear-gradient(
    -45deg,
    #f8fafc,
    #f8fafc 8px,
    #f1f5f9 8px,
    #f1f5f9 16px
  );
}
.grid-cell {
  box-sizing: border-box;
  border-bottom: 1px dashed #eef2f6;
  position: relative;
  cursor: pointer;
  transition: background 0.15s ease;
}
.grid-cell:nth-child(4n) {
  border-bottom-style: solid;
  border-bottom-color: var(--board-line);
}
.grid-cell.past {
  background: rgba(100, 116, 139, 0.07);
}
.grid-cell.hover:not(.past) {
  background: rgba(59, 130, 246, 0.08);
}
.grid-cell.hover.past {
  background: rgba(59, 130, 246, 0.06);
}
.grid-cell.rest,
.grid-cell.full {
  cursor: default;
}
.slot-add {
  position: absolute;
  left: 50%;
  top: 50%;
  transform: translate(-50%, -50%);
  border: 1px dashed var(--accent);
  border-radius: 6px;
  background: var(--el-color-primary-light-9);
  color: var(--accent);
  cursor: pointer;
  font-size: 12px;
  padding: 3px 12px;
  white-space: nowrap;
  /* 必须低于预约卡片，避免从缝隙触发后按钮盖在卡片上 */
  z-index: 1;
  pointer-events: auto;
  box-shadow: 0 2px 8px rgba(59, 130, 246, 0.12);
}
.rest-mark {
  position: absolute;
  inset: 0;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 11px;
  color: #94a3b8;
  pointer-events: none;
  opacity: 0.55;
}
.board-now-overlay {
  position: absolute;
  top: 0;
  right: 0;
  bottom: 0;
  pointer-events: none;
  z-index: 4;
}
.past-mask {
  position: absolute;
  left: 0;
  right: 0;
  top: 0;
  background: linear-gradient(
    180deg,
    rgba(100, 116, 139, 0.14) 0%,
    rgba(148, 163, 184, 0.08) 65%,
    rgba(148, 163, 184, 0.03) 100%
  );
}
.now-line {
  position: absolute;
  left: 0;
  right: 0;
  height: 2px;
  background: linear-gradient(90deg, #ef4444, #f97316);
  box-shadow: 0 0 6px rgba(239, 68, 68, 0.35);
}
.now-line::before {
  content: '';
  position: absolute;
  left: -4px;
  top: -4px;
  width: 10px;
  height: 10px;
  border-radius: 50%;
  background: #ef4444;
}
.now-label {
  position: absolute;
  left: 6px;
  top: -11px;
  font-size: 11px;
  font-weight: 600;
  color: #fff;
  background: #ef4444;
  padding: 1px 8px;
  border-radius: 999px;
  line-height: 1.4;
  white-space: nowrap;
  box-shadow: 0 2px 6px rgba(239, 68, 68, 0.35);
}
.apt-card {
  position: absolute;
  border-radius: 8px;
  padding: 6px 8px 6px 10px;
  box-sizing: border-box;
  overflow: visible;
  cursor: pointer;
  z-index: 5;
  border: 1px solid transparent;
  background: #eff6ff;
  box-shadow: 0 2px 8px rgba(31, 42, 55, 0.06);
  transition:
    box-shadow 0.15s ease,
    transform 0.15s ease;
}
.apt-card::before {
  content: '';
  position: absolute;
  left: 0;
  top: 6px;
  bottom: 6px;
  width: 3px;
  border-radius: 3px;
  background: var(--pending);
}
.apt-card:hover {
  z-index: 20;
  box-shadow: 0 8px 20px rgba(31, 42, 55, 0.12);
  transform: translateY(-1px);
}
.apt-card.tone-pending::before {
  background: var(--pending);
}
.apt-card.tone-arrived::before {
  background: var(--arrived);
}
.apt-card.tone-done::before {
  background: #94a3b8;
}
.apt-card.tone-cancel::before {
  background: #f87171;
}
.apt-card.st-WAIT,
.apt-card.st-CONF,
.apt-card.tone-pending {
  background: linear-gradient(135deg, #fff4ec 0%, #ffe0cc 100%);
  border-color: #ffc9a3;
  color: #9a4a1a;
}
.apt-card.st-ARRV,
.apt-card.st-SERV,
.apt-card.tone-arrived {
  background: linear-gradient(135deg, #eaf9f1 0%, #c9f0da 100%);
  border-color: #9ad9b5;
  color: #1f6b42;
}
.apt-card.st-DONE {
  background: #f8fafc;
  border-color: #e2e8f0;
  color: #64748b;
}
.apt-card.st-NOSH {
  background: #fef2f2;
  border-color: #fecaca;
  opacity: 0.88;
}
/*
 * 已过时段：改冷灰蓝底，与未到店暖橙拉开对比；
 * 左侧色条仍保留原状态色，方便辨认未到店/已到店。
 */
.apt-card.is-past {
  opacity: 1;
  box-shadow: none;
  filter: none;
  background: linear-gradient(135deg, #eef2f6 0%, #dce3eb 100%) !important;
  border-color: #b8c4d1 !important;
  color: #475569 !important;
}
.apt-card.is-past.tone-pending::before,
.apt-card.is-past.st-WAIT::before,
.apt-card.is-past.st-CONF::before {
  background: #ff8646;
  opacity: 0.75;
}
.apt-card.is-past.tone-arrived::before,
.apt-card.is-past.st-ARRV::before,
.apt-card.is-past.st-SERV::before {
  background: #45c57b;
  opacity: 0.75;
}
.apt-card.is-past:hover {
  background: linear-gradient(135deg, #e8eef4 0%, #d4dde8 100%) !important;
  border-color: #a8b6c6 !important;
}
.apt-name {
  font-size: 12px;
  font-weight: 700;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
  letter-spacing: 0.01em;
}
.apt-line {
  font-size: 11px;
  color: inherit;
  opacity: 0.82;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
  line-height: 1.35;
}
.apt-remark {
  opacity: 0.65;
}
.apt-popover {
  position: absolute;
  z-index: 30;
  width: 300px;
  background: #fff;
  border-radius: 10px;
  box-shadow: 0 12px 32px rgba(15, 23, 42, 0.16);
  padding: 14px;
  border: 1px solid #e5e7eb;
}
.apt-popover::before {
  content: '';
  position: absolute;
  left: -6px;
  top: 18px;
  border-top: 6px solid transparent;
  border-bottom: 6px solid transparent;
  border-right: 6px solid #fff;
  filter: drop-shadow(-1px 0 0 #e5e7eb);
}
.pop-head {
  font-size: 15px;
  margin-bottom: 4px;
  color: var(--board-ink);
}
.pop-phone {
  font-size: 13px;
  color: #4b5565;
  margin-bottom: 10px;
}
.pop-row {
  display: grid;
  grid-template-columns: 64px 1fr;
  gap: 8px;
  font-size: 12px;
  margin-bottom: 6px;
  color: #303133;
  align-items: start;
}
.pop-label {
  color: #909399;
}
.pop-actions {
  display: flex;
  flex-wrap: wrap;
  gap: 6px;
  margin-top: 12px;
}
.pop-actions .pop-btn {
  margin: 0 !important;
  flex: 1 1 calc(33.33% - 6px);
  min-width: 84px;
  padding: 5px 4px;
}
.pop-actions :deep(.el-button + .el-button) {
  margin-left: 0;
}
.pop-actions :deep(.el-button > span) {
  font-size: 12px;
}
</style>
