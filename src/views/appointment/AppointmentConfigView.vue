<script setup lang="ts">
import { computed, onMounted, onUnmounted, reactive, ref, watch } from 'vue'
import { useRoute } from 'vue-router'
import { ElMessage, ElMessageBox } from 'element-plus'

import AppError from '@/components/common/AppError.vue'
import {
  batchAssignScheduleDay,
  createAppointmentSchedule,
  createAppointmentType,
  deactivateAppointmentType,
  fetchAppointmentCapacities,
  fetchAppointmentConfig,
  fetchAppointmentEmployees,
  fetchAppointmentSchedules,
  fetchAppointmentTypes,
  fetchRemindTasks,
  fetchScheduleDayAssignments,
  saveAppointmentCapacity,
  saveAppointmentConfig,
  updateAppointmentSchedule,
  updateAppointmentType,
} from '@/api/appointment'
import {
  AppointmentPermission,
  type AppointmentConfig,
  type AppointmentEmployeeCapacity,
  type AppointmentEmployeeOption,
  type AppointmentScheduleDayEmployee,
  type AppointmentScheduleItem,
  type AppointmentTypeItem,
  type BatchAssignScheduleItem,
  type RemindTaskItem,
} from '@/types/appointment'
import { usePermissionStore } from '@/stores/permission'
import { STORE_CONTEXT_CHANGED_EVENT, useStoreStore } from '@/stores/store'
import { getUserFriendlyErrorMessage, runExclusive, uiMessage } from '@/utils/ui'

defineOptions({ name: 'AppointmentConfigView' })

const route = useRoute()
const permissionStore = usePermissionStore()
const storeStore = useStoreStore()

type TabKey =
  | 'shifts'
  | 'roster'
  | 'rules'
  | 'settings'
  | 'capacity'
  | 'types'
  | 'remind'

const activeTab = ref<TabKey>(
  (route.meta.defaultTab as TabKey | undefined) || 'rules',
)
const loading = ref(false)
const error = ref<string | null>(null)
const capacities = ref<AppointmentEmployeeCapacity[]>([])
const typeOptions = ref<AppointmentTypeItem[]>([])
const remindTasks = ref<RemindTaskItem[]>([])
const capacityDraft = reactive({
  employeeId: '',
  maxConcurrent: 2,
})

const canEdit = computed(() =>
  permissionStore.hasPermission(AppointmentPermission.EDIT),
)
const canView = computed(() =>
  permissionStore.hasPermission(AppointmentPermission.VIEW),
)
/** 预约类型 / 提醒配置：需 appointment:edit（门店管理员） */
const canAdminConfig = computed(() => canEdit.value)

const typeDialogVisible = ref(false)
const typeSaving = ref(false)
const editingTypeId = ref<number | null>(null)
const typeForm = reactive({
  name: '',
  sequence: 10,
  active: true,
})

const storeId = computed(() => storeStore.currentStoreId ?? null)

const TIME_OPTIONS = buildHmOptions(6, 23, 30)

function buildHmOptions(fromHour: number, toHour: number, step: number): string[] {
  const list: string[] = []
  for (let h = fromHour; h <= toHour; h++) {
    for (let m = 0; m < 60; m += step) {
      if (h === toHour && m > 0) break
      list.push(`${String(h).padStart(2, '0')}:${String(m).padStart(2, '0')}`)
    }
  }
  return list
}

function formatDateYmd(d: Date): string {
  const y = d.getFullYear()
  const m = String(d.getMonth() + 1).padStart(2, '0')
  const day = String(d.getDate()).padStart(2, '0')
  return `${y}-${m}-${day}`
}

// ——— 班次 ———
const schedules = ref<AppointmentScheduleItem[]>([])
const shiftDialogVisible = ref(false)
const shiftSaving = ref(false)
const editingShiftId = ref<number | null>(null)
const shiftForm = reactive({
  name: '',
  startTime: '09:00',
  endTime: '18:00',
})

async function loadSchedules(): Promise<void> {
  if (storeId.value == null) {
    schedules.value = []
    return
  }
  schedules.value = await fetchAppointmentSchedules(storeId.value)
}

function openCreateShift(): void {
  editingShiftId.value = null
  shiftForm.name = ''
  shiftForm.startTime = '09:00'
  shiftForm.endTime = '18:00'
  shiftDialogVisible.value = true
}

function openEditShift(row: AppointmentScheduleItem): void {
  if (row.id == null) return
  editingShiftId.value = row.id
  shiftForm.name = row.name?.trim() || ''
  shiftForm.startTime = row.startTime || '09:00'
  shiftForm.endTime = row.endTime || '18:00'
  shiftDialogVisible.value = true
}

async function submitShift(): Promise<void> {
  if (storeId.value == null) {
    uiMessage.warning('请先选择门店')
    return
  }
  const name = shiftForm.name.trim()
  if (!name) {
    uiMessage.warning('请填写班次名称')
    return
  }
  if (!shiftForm.startTime || !shiftForm.endTime) {
    uiMessage.warning('请选择起止时间')
    return
  }
  if (shiftForm.startTime >= shiftForm.endTime) {
    uiMessage.warning('结束时间须晚于开始时间')
    return
  }
  const body = {
    storeId: storeId.value,
    name,
    startTime: shiftForm.startTime,
    endTime: shiftForm.endTime,
  }
  await runExclusive(shiftSaving, async () => {
    try {
      if (editingShiftId.value != null) {
        await updateAppointmentSchedule(editingShiftId.value, body)
        ElMessage.success('班次已更新')
      } else {
        await createAppointmentSchedule(body)
        ElMessage.success('班次已创建')
      }
      shiftDialogVisible.value = false
      await loadSchedules()
    } catch (e) {
      ElMessage.error(getUserFriendlyErrorMessage(e))
    }
  })
}

// ——— 整月整店排班 ———
const employees = ref<AppointmentEmployeeOption[]>([])
const dayAssignments = ref<AppointmentScheduleDayEmployee[]>([])
const rosterMonth = ref(formatMonthYm(new Date()))
const rosterSaving = ref(false)

const WEEKDAY_LABELS = ['日', '一', '二', '三', '四', '五', '六'] as const

interface MonthDayCol {
  date: string
  day: number
  weekday: number
  weekdayLabel: string
  weekend: boolean
  today: boolean
  expired: boolean
}

type CellKind = 'work' | 'rest' | 'empty'

interface CellState {
  kind: CellKind
  scheduleId: number | null
  scheduleName: string | null
  startTime: string | null
  endTime: string | null
}

function formatMonthYm(d: Date): string {
  return `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, '0')}`
}

function toDateOnly(raw: string | null | undefined): string {
  if (!raw) return ''
  return raw.length >= 10 ? raw.slice(0, 10) : raw
}

function cellKey(employeeId: string, date: string): string {
  return `${employeeId}|${date}`
}

const monthDays = computed<MonthDayCol[]>(() => {
  const [ys, ms] = rosterMonth.value.split('-')
  const y = Number(ys)
  const m = Number(ms)
  if (!Number.isFinite(y) || !Number.isFinite(m)) return []
  const daysInMonth = new Date(y, m, 0).getDate()
  const today = formatDateYmd(new Date())
  const list: MonthDayCol[] = []
  for (let d = 1; d <= daysInMonth; d++) {
    const date = `${ys}-${String(m).padStart(2, '0')}-${String(d).padStart(2, '0')}`
    const wd = new Date(y, m - 1, d).getDay()
    list.push({
      date,
      day: d,
      weekday: wd,
      weekdayLabel: WEEKDAY_LABELS[wd],
      weekend: wd === 0 || wd === 6,
      today: date === today,
      expired: date < today,
    })
  }
  return list
})

const monthRange = computed(() => {
  const days = monthDays.value
  if (!days.length) return { from: '', to: '' }
  return { from: days[0].date, to: days[days.length - 1].date }
})

const assignmentMap = computed(() => {
  const map = new Map<string, AppointmentScheduleDayEmployee>()
  for (const a of dayAssignments.value) {
    if (!a.employeeId) continue
    const date = toDateOnly(a.scheduleDate)
    if (!date) continue
    map.set(cellKey(a.employeeId, date), a)
  }
  return map
})

function cellState(employeeId: string, date: string): CellState {
  const hit = assignmentMap.value.get(cellKey(employeeId, date))
  if (!hit) {
    return { kind: 'empty', scheduleId: null, scheduleName: null, startTime: null, endTime: null }
  }
  if (hit.rest === true) {
    return { kind: 'rest', scheduleId: null, scheduleName: null, startTime: null, endTime: null }
  }
  if (hit.scheduleId != null) {
    return {
      kind: 'work',
      scheduleId: hit.scheduleId,
      scheduleName: hit.scheduleName,
      startTime: hit.startTime,
      endTime: hit.endTime,
    }
  }
  return { kind: 'empty', scheduleId: null, scheduleName: null, startTime: null, endTime: null }
}

function cellTitle(employeeId: string, date: string): string {
  const st = cellState(employeeId, date)
  if (st.kind === 'rest') return '休息'
  if (st.kind === 'work') {
    const range =
      st.startTime && st.endTime ? `${st.startTime}-${st.endTime}` : ''
    return `${st.scheduleName || '已排班'}${range ? `（${range}）` : ''}`
  }
  return '未排班'
}

/** 拖选 / 点选 */
const selecting = ref(false)
const selectAnchor = ref<{ empIdx: number; dayIdx: number } | null>(null)
const selectFocus = ref<{ empIdx: number; dayIdx: number } | null>(null)
const selectedKeys = ref<Set<string>>(new Set())

const applyDialogVisible = ref(false)
const applyMode = ref<'work' | 'rest' | 'clear'>('work')
const applyScheduleId = ref<number | null>(null)
const applyTargets = ref<Array<{ employeeId: string; scheduleDate: string }>>([])

const settingsPopoverVisible = ref(false)
const defaultScheduleId = ref<number | null>(null)

function isCellSelected(employeeId: string, date: string): boolean {
  return selectedKeys.value.has(cellKey(employeeId, date))
}

function buildSelectionKeys(
  a: { empIdx: number; dayIdx: number },
  b: { empIdx: number; dayIdx: number },
): Set<string> {
  const empMin = Math.min(a.empIdx, b.empIdx)
  const empMax = Math.max(a.empIdx, b.empIdx)
  const dayMin = Math.min(a.dayIdx, b.dayIdx)
  const dayMax = Math.max(a.dayIdx, b.dayIdx)
  const keys = new Set<string>()
  for (let ei = empMin; ei <= empMax; ei++) {
    const emp = employees.value[ei]
    if (!emp) continue
    for (let di = dayMin; di <= dayMax; di++) {
      const col = monthDays.value[di]
      if (!col || col.expired) continue
      keys.add(cellKey(emp.employeeId, col.date))
    }
  }
  return keys
}

function clearSelection(): void {
  selecting.value = false
  selectAnchor.value = null
  selectFocus.value = null
  selectedKeys.value = new Set()
}

function onCellPointerDown(empIdx: number, dayIdx: number, e: MouseEvent): void {
  if (!canEdit.value) return
  if (e.button !== 0) return
  const col = monthDays.value[dayIdx]
  if (!col || col.expired) return
  e.preventDefault()
  selecting.value = true
  selectAnchor.value = { empIdx, dayIdx }
  selectFocus.value = { empIdx, dayIdx }
  selectedKeys.value = buildSelectionKeys(selectAnchor.value, selectFocus.value)
}

function onCellPointerEnter(empIdx: number, dayIdx: number): void {
  if (!selecting.value || !selectAnchor.value) return
  const col = monthDays.value[dayIdx]
  if (!col || col.expired) return
  selectFocus.value = { empIdx, dayIdx }
  selectedKeys.value = buildSelectionKeys(selectAnchor.value, selectFocus.value)
}

function onCellPointerUp(): void {
  if (!selecting.value) return
  selecting.value = false
  if (selectedKeys.value.size === 0) return
  openApplyDialog([...selectedKeys.value])
}

function openApplyDialog(keys: string[]): void {
  const targets: Array<{ employeeId: string; scheduleDate: string }> = []
  for (const key of keys) {
    const [employeeId, scheduleDate] = key.split('|')
    if (!employeeId || !scheduleDate) continue
    targets.push({ employeeId, scheduleDate })
  }
  if (!targets.length) return
  applyTargets.value = targets
  applyMode.value = 'work'
  applyScheduleId.value =
    defaultScheduleId.value ??
    (schedules.value[0]?.id != null ? Number(schedules.value[0].id) : null)
  applyDialogVisible.value = true
}

function onApplyDialogClose(): void {
  applyDialogVisible.value = false
  clearSelection()
}

function onEscCancelSelection(e: KeyboardEvent): void {
  if (e.key !== 'Escape') return
  if (applyDialogVisible.value) return
  if (selectedKeys.value.size > 0 || selecting.value) {
    clearSelection()
  }
}

async function loadRoster(): Promise<void> {
  if (storeId.value == null) {
    employees.value = []
    dayAssignments.value = []
    return
  }
  const { from, to } = monthRange.value
  const [emps, assigns] = await Promise.all([
    fetchAppointmentEmployees(storeId.value),
    from && to
      ? fetchScheduleDayAssignments({ storeId: storeId.value, from, to })
      : Promise.resolve([] as AppointmentScheduleDayEmployee[]),
  ])
  employees.value = emps
  dayAssignments.value = assigns
  if (defaultScheduleId.value == null && schedules.value[0]?.id != null) {
    defaultScheduleId.value = Number(schedules.value[0].id)
  }
}

async function submitBatchApply(): Promise<void> {
  if (storeId.value == null) {
    uiMessage.warning('请先选择门店')
    return
  }
  if (!canEdit.value) {
    uiMessage.warning('无编辑权限')
    return
  }
  if (!applyTargets.value.length) return
  if (applyMode.value === 'work' && applyScheduleId.value == null) {
    uiMessage.warning('请选择班次')
    return
  }
  const items: BatchAssignScheduleItem[] = applyTargets.value.map((t) => {
    if (applyMode.value === 'clear') {
      return { employeeId: t.employeeId, scheduleDate: t.scheduleDate, clear: true }
    }
    if (applyMode.value === 'rest') {
      return { employeeId: t.employeeId, scheduleDate: t.scheduleDate, rest: true }
    }
    return {
      employeeId: t.employeeId,
      scheduleDate: t.scheduleDate,
      rest: false,
      scheduleId: applyScheduleId.value,
    }
  })
  rosterSaving.value = true
  try {
    await batchAssignScheduleDay({
      storeId: storeId.value,
      items,
      source: 'MANUAL',
    })
    ElMessage.success(`已更新 ${items.length} 格排班`)
    applyDialogVisible.value = false
    clearSelection()
    await loadRoster()
  } catch (e) {
    ElMessage.error(getUserFriendlyErrorMessage(e))
  } finally {
    rosterSaving.value = false
  }
}

// ——— 预约设置 ———
const settingsSaving = ref(false)
const settingsForm = reactive({
  startTime: '09:00',
  endTime: '21:00',
  period: 15,
  appointmentServicerIsRequired: true,
  canChooseRestEmployee: false,
  allowMultiBooking: true,
  remindOnCreate: true,
  remindLeadMinutes: 60,
  remindEnabled: true,
  remindBeforeArriveEnabled: true,
  remindSmsEnabled: false,
  remindWechatEnabled: false,
  remindCancelNotifyEnabled: false,
})
const smsProviderConfigured = ref(false)
const wechatProviderConfigured = ref(false)

async function loadSettings(): Promise<void> {
  if (storeId.value == null) return
  const cfg: AppointmentConfig | null = await fetchAppointmentConfig(storeId.value)
  settingsForm.startTime = cfg?.startTime || '09:00'
  settingsForm.endTime = cfg?.endTime || '21:00'
  settingsForm.period = cfg?.period && cfg.period > 0 ? cfg.period : 15
  settingsForm.appointmentServicerIsRequired = cfg?.appointmentServicerIsRequired !== false
  settingsForm.canChooseRestEmployee = cfg?.canChooseRestEmployee === true
  settingsForm.allowMultiBooking = cfg?.allowMultiBooking !== false
  settingsForm.remindOnCreate = cfg?.remindOnCreate !== false
  settingsForm.remindLeadMinutes =
    cfg?.remindLeadMinutes != null && cfg.remindLeadMinutes >= 0
      ? cfg.remindLeadMinutes
      : 60
  settingsForm.remindEnabled = cfg?.remindEnabled !== false
  settingsForm.remindBeforeArriveEnabled = cfg?.remindBeforeArriveEnabled !== false
  settingsForm.remindSmsEnabled = cfg?.remindSmsEnabled === true
  settingsForm.remindWechatEnabled = cfg?.remindWechatEnabled === true
  settingsForm.remindCancelNotifyEnabled = cfg?.remindCancelNotifyEnabled === true
  smsProviderConfigured.value = cfg?.smsProviderConfigured === true
  wechatProviderConfigured.value = cfg?.wechatProviderConfigured === true
}

async function loadCapacities(): Promise<void> {
  if (storeId.value == null) {
    capacities.value = []
    return
  }
  capacities.value = await fetchAppointmentCapacities(storeId.value)
}

async function loadTypes(): Promise<void> {
  typeOptions.value = await fetchAppointmentTypes(canAdminConfig.value)
}

function openCreateType(): void {
  editingTypeId.value = null
  typeForm.name = ''
  typeForm.sequence = (typeOptions.value[typeOptions.value.length - 1]?.sequence ?? 0) + 10
  typeForm.active = true
  typeDialogVisible.value = true
}

function openEditType(row: AppointmentTypeItem): void {
  editingTypeId.value = row.id
  typeForm.name = row.name?.trim() || ''
  typeForm.sequence = row.sequence ?? 10
  typeForm.active = row.active !== false
  typeDialogVisible.value = true
}

async function submitType(): Promise<void> {
  const name = typeForm.name.trim()
  if (!name) {
    uiMessage.warning('请填写类型名称')
    return
  }
  await runExclusive(typeSaving, async () => {
    try {
      if (editingTypeId.value != null) {
        await updateAppointmentType(editingTypeId.value, {
          name,
          sequence: typeForm.sequence,
          active: typeForm.active,
        })
        ElMessage.success('预约类型已更新')
      } else {
        await createAppointmentType({
          name,
          sequence: typeForm.sequence,
          active: typeForm.active,
        })
        ElMessage.success('预约类型已创建')
      }
      typeDialogVisible.value = false
      await loadTypes()
    } catch (e) {
      ElMessage.error(getUserFriendlyErrorMessage(e))
    }
  })
}

async function removeType(row: AppointmentTypeItem): Promise<void> {
  try {
    await ElMessageBox.confirm(`停用类型「${row.name}」？停用后新建预约将不可选。`, '停用确认', {
      type: 'warning',
    })
    await deactivateAppointmentType(row.id)
    ElMessage.success('已停用')
    await loadTypes()
  } catch (e) {
    if (e !== 'cancel' && e !== 'close') {
      ElMessage.error(getUserFriendlyErrorMessage(e))
    }
  }
}

async function loadRemindTasks(): Promise<void> {
  if (storeId.value == null) {
    remindTasks.value = []
    return
  }
  remindTasks.value = await fetchRemindTasks({ storeId: storeId.value })
}

async function submitCapacity(): Promise<void> {
  if (storeId.value == null || !capacityDraft.employeeId) {
    uiMessage.warning('请选择护理师')
    return
  }
  try {
    await saveAppointmentCapacity({
      storeId: storeId.value,
      employeeId: capacityDraft.employeeId,
      maxConcurrent: capacityDraft.maxConcurrent,
    })
    ElMessage.success('护理师预约能力已保存')
    await loadCapacities()
  } catch (e) {
    ElMessage.error(getUserFriendlyErrorMessage(e))
  }
}

async function submitSettings(): Promise<void> {
  if (storeId.value == null) {
    uiMessage.warning('请先选择门店')
    return
  }
  if (settingsForm.startTime >= settingsForm.endTime) {
    uiMessage.warning('营业结束时间须晚于开始时间')
    return
  }
  if (!settingsForm.period || settingsForm.period <= 0) {
    uiMessage.warning('时段步长须大于 0')
    return
  }
  await runExclusive(settingsSaving, async () => {
    try {
      await saveAppointmentConfig({
        storeId: storeId.value!,
        startTime: settingsForm.startTime,
        endTime: settingsForm.endTime,
        period: settingsForm.period,
        appointmentServicerIsRequired: settingsForm.appointmentServicerIsRequired,
        canChooseRestEmployee: settingsForm.canChooseRestEmployee,
        allowMultiBooking: settingsForm.allowMultiBooking,
        remindOnCreate: settingsForm.remindOnCreate,
        remindLeadMinutes: settingsForm.remindLeadMinutes,
        remindEnabled: settingsForm.remindEnabled,
        remindBeforeArriveEnabled: settingsForm.remindBeforeArriveEnabled,
        remindSmsEnabled: settingsForm.remindSmsEnabled,
        remindWechatEnabled: settingsForm.remindWechatEnabled,
        remindCancelNotifyEnabled: settingsForm.remindCancelNotifyEnabled,
      })
      ElMessage.success('预约设置已保存')
      await loadSettings()
    } catch (e) {
      ElMessage.error(getUserFriendlyErrorMessage(e))
    }
  })
}

// ——— 加载 ———
async function loadAll(): Promise<void> {
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
      await Promise.all([
        loadSchedules(),
        loadRoster(),
        loadSettings(),
        loadCapacities(),
        loadTypes(),
        loadRemindTasks(),
      ])
    } catch (e) {
      error.value = getUserFriendlyErrorMessage(e)
    }
  })
}

watch(
  () => route.meta.defaultTab,
  (tab) => {
    if (typeof tab === 'string' && tab) {
      activeTab.value = tab as TabKey
    }
  },
  { immediate: true },
)

watch(rosterMonth, () => {
  if (activeTab.value === 'roster') {
    void runExclusive(loading, async () => {
      try {
        clearSelection()
        await loadRoster()
      } catch (e) {
        ElMessage.error(getUserFriendlyErrorMessage(e))
      }
    })
  }
})

watch(activeTab, (tab) => {
  if (tab === 'roster' && !loading.value) {
    void loadRoster()
  }
})

function onStoreChanged(): void {
  void loadAll()
}

function onWindowMouseUp(): void {
  if (selecting.value) onCellPointerUp()
}

onMounted(() => {
  void loadAll()
  window.addEventListener(STORE_CONTEXT_CHANGED_EVENT, onStoreChanged)
  window.addEventListener('mouseup', onWindowMouseUp)
  window.addEventListener('keydown', onEscCancelSelection)
})

onUnmounted(() => {
  window.removeEventListener(STORE_CONTEXT_CHANGED_EVENT, onStoreChanged)
  window.removeEventListener('mouseup', onWindowMouseUp)
  window.removeEventListener('keydown', onEscCancelSelection)
})
</script>

<template>
  <div class="page">
    <header class="page-header">
      <el-button :loading="loading" @click="loadAll">刷新</el-button>
    </header>

    <AppError v-if="error" :message="error" @retry="loadAll" />

    <div v-else v-loading="loading" class="body">
      <el-tabs v-model="activeTab">
        <el-tab-pane label="班次" name="shifts">
          <div class="tab-toolbar">
            <span class="hint">班次供日排班选用，例如早班 / 晚班。</span>
            <el-button
              type="primary"
              :disabled="!canEdit || storeId == null"
              @click="openCreateShift"
            >
              新增班次
            </el-button>
          </div>
          <el-table :data="schedules" stripe border empty-text="暂无班次">
            <el-table-column prop="name" label="班次名称" min-width="140" />
            <el-table-column prop="startTime" label="开始" width="100" />
            <el-table-column prop="endTime" label="结束" width="100" />
            <el-table-column label="操作" width="100" fixed="right">
              <template #default="{ row }">
                <el-button
                  link
                  type="primary"
                  :disabled="!canEdit"
                  @click="openEditShift(row)"
                >
                  编辑
                </el-button>
              </template>
            </el-table-column>
          </el-table>
        </el-tab-pane>

        <el-tab-pane label="排班" name="roster">
          <div class="tab-toolbar">
            <div class="roster-filters">
              <span>月份</span>
              <el-date-picker
                v-model="rosterMonth"
                type="month"
                value-format="YYYY-MM"
                :clearable="false"
                style="width: 140px"
              />
              <el-button
                type="primary"
                :loading="loading"
                @click="loadRoster"
              >
                搜索
              </el-button>
            </div>
            <el-popover
              v-model:visible="settingsPopoverVisible"
              placement="bottom-end"
              :width="280"
              trigger="click"
            >
              <div class="roster-settings">
                <div class="roster-settings-title">默认班次（批量应用预选）</div>
                <el-select
                  v-model="defaultScheduleId"
                  placeholder="选择班次"
                  style="width: 100%"
                  :disabled="!canEdit"
                >
                  <el-option
                    v-for="s in schedules"
                    :key="s.id!"
                    :label="`${s.name}（${s.startTime}-${s.endTime}）`"
                    :value="s.id!"
                  />
                </el-select>
                <p class="hint" style="margin-top: 8px">
                  点选或拖选格子后，弹窗会预填此班次，可再改休息/清除。
                </p>
              </div>
              <template #reference>
                <el-button type="warning" plain :disabled="!canEdit">排班设置</el-button>
              </template>
            </el-popover>
          </div>

          <div class="roster-legend">
            <span><i class="dot work" />已排班</span>
            <span><i class="dot rest" />休息</span>
            <span><i class="dot empty" />未排班</span>
            <span><i class="dot expired" />已过期（不可编辑）</span>
            <span class="legend-tip">
              点击格子编辑；按住左键拖选可跨员工、跨日期批量排班（Esc 取消选区）
            </span>
          </div>

          <div v-if="employees.length === 0" class="roster-empty">本店暂无可排班护理师</div>
          <div v-else class="roster-matrix-wrap" @dragstart.prevent>
            <table class="roster-matrix">
              <thead>
                <tr>
                  <th class="sticky-col role-col">角色</th>
                  <th class="sticky-col name-col">接待人</th>
                  <th
                    v-for="col in monthDays"
                    :key="col.date"
                    class="day-col"
                    :class="{ weekend: col.weekend, today: col.today }"
                  >
                    <div class="day-num">{{ String(col.day).padStart(2, '0') }}</div>
                    <div class="day-wd" :class="{ weekend: col.weekend }">
                      周{{ col.weekdayLabel }}
                    </div>
                  </th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="(emp, empIdx) in employees" :key="emp.employeeId">
                  <td class="sticky-col role-col">养发师</td>
                  <td class="sticky-col name-col">
                    {{ emp.employeeName?.trim() || emp.employeeId }}
                  </td>
                  <td
                    v-for="(col, dayIdx) in monthDays"
                    :key="col.date"
                    class="day-cell"
                    :class="{
                      work: cellState(emp.employeeId, col.date).kind === 'work',
                      rest: cellState(emp.employeeId, col.date).kind === 'rest',
                      empty: cellState(emp.employeeId, col.date).kind === 'empty',
                      expired: col.expired,
                      today: col.today,
                      selected: isCellSelected(emp.employeeId, col.date),
                    }"
                    :title="
                      col.expired
                        ? `${col.date} 已过期不可编辑`
                        : `${col.date} ${cellTitle(emp.employeeId, col.date)}`
                    "
                    @mousedown="onCellPointerDown(empIdx, dayIdx, $event)"
                    @mouseenter="onCellPointerEnter(empIdx, dayIdx)"
                  >
                    <template v-if="cellState(emp.employeeId, col.date).kind === 'work'">
                      <span class="cell-text">
                        {{ cellState(emp.employeeId, col.date).scheduleName || '班' }}
                      </span>
                    </template>
                    <template v-else-if="cellState(emp.employeeId, col.date).kind === 'rest'">
                      <span class="cell-text">休</span>
                    </template>
                    <template v-else>
                      <span class="cell-dash">-</span>
                    </template>
                  </td>
                </tr>
              </tbody>
            </table>
          </div>
        </el-tab-pane>

        <el-tab-pane label="门店规则" name="rules">
          <el-form label-width="180px" class="settings-form" style="max-width: 560px">
            <el-form-item label="预约开始时间">
              <el-select v-model="settingsForm.startTime" :disabled="!canEdit" style="width: 160px">
                <el-option v-for="t in TIME_OPTIONS" :key="t" :label="t" :value="t" />
              </el-select>
            </el-form-item>
            <el-form-item label="预约结束时间">
              <el-select v-model="settingsForm.endTime" :disabled="!canEdit" style="width: 160px">
                <el-option v-for="t in TIME_OPTIONS" :key="t" :label="t" :value="t" />
              </el-select>
            </el-form-item>
            <el-form-item label="时间粒度（分钟）">
              <el-input-number
                v-model="settingsForm.period"
                :min="5"
                :max="120"
                :step="5"
                :disabled="!canEdit"
              />
              <span class="field-hint">默认 15</span>
            </el-form-item>
            <el-form-item label="允许多人同时预约">
              <el-switch v-model="settingsForm.allowMultiBooking" :disabled="!canEdit" />
              <span class="field-hint">关闭后同护理师重叠时段上限=1</span>
            </el-form-item>
            <el-form-item label="必须指定护理师">
              <el-switch
                v-model="settingsForm.appointmentServicerIsRequired"
                :disabled="!canEdit"
              />
            </el-form-item>
            <el-form-item label="可选休息员工">
              <el-switch
                v-model="settingsForm.canChooseRestEmployee"
                :disabled="!canEdit"
              />
            </el-form-item>
            <el-form-item>
              <el-button
                type="primary"
                :loading="settingsSaving"
                :disabled="!canEdit"
                @click="submitSettings"
              >
                保存门店规则
              </el-button>
            </el-form-item>
          </el-form>
        </el-tab-pane>

        <el-tab-pane label="护理师能力" name="capacity">
          <div class="tab-toolbar">
            <el-select
              v-model="capacityDraft.employeeId"
              filterable
              placeholder="选择护理师"
              style="width: 200px"
              :disabled="!canEdit"
            >
              <el-option
                v-for="emp in employees"
                :key="emp.employeeId"
                :label="emp.employeeName || emp.employeeId"
                :value="emp.employeeId"
              />
            </el-select>
            <el-input-number
              v-model="capacityDraft.maxConcurrent"
              :min="1"
              :max="20"
              :disabled="!canEdit"
            />
            <el-button type="primary" :disabled="!canEdit" @click="submitCapacity">
              保存上限
            </el-button>
          </div>
          <p class="hint">门店禁止多人时，护理师上限不会绕过门店规则。</p>
          <el-table :data="capacities" stripe border empty-text="尚未配置，默认上限 2">
            <el-table-column prop="employeeId" label="护理师ID" min-width="120" />
            <el-table-column prop="maxConcurrent" label="最大同时预约" width="140" />
          </el-table>
        </el-tab-pane>

        <el-tab-pane v-if="canAdminConfig" label="预约类型" name="types">
          <div class="tab-toolbar">
            <span class="hint">管理员可增删改预约类型（停用后新建不可选）。</span>
            <el-button type="primary" @click="openCreateType">新增类型</el-button>
          </div>
          <el-table :data="typeOptions" stripe border>
            <el-table-column prop="id" label="ID" width="80" />
            <el-table-column prop="name" label="名称" min-width="160" />
            <el-table-column prop="sequence" label="排序" width="80" />
            <el-table-column label="状态" width="90">
              <template #default="{ row }">
                <el-tag :type="row.active === false ? 'info' : 'success'" size="small">
                  {{ row.active === false ? '停用' : '启用' }}
                </el-tag>
              </template>
            </el-table-column>
            <el-table-column label="操作" width="140" fixed="right">
              <template #default="{ row }">
                <el-button link type="primary" @click="openEditType(row)">编辑</el-button>
                <el-button
                  v-if="row.active !== false"
                  link
                  type="danger"
                  @click="removeType(row)"
                >
                  停用
                </el-button>
              </template>
            </el-table-column>
          </el-table>
        </el-tab-pane>

        <el-tab-pane v-if="canAdminConfig" label="提醒配置" name="remind">
          <el-alert
            type="warning"
            :closable="false"
            show-icon
            class="remind-alert"
            title="业务提醒规则可保存；当前未开通短信服务商、未注册微信小程序，不会真实发送，也不会显示虚假成功。"
          />
          <el-form label-width="200px" class="settings-form" style="max-width: 640px">
            <el-form-item label="启用提醒任务">
              <el-switch v-model="settingsForm.remindEnabled" />
            </el-form-item>
            <el-form-item label="创建后立即提醒">
              <el-switch v-model="settingsForm.remindOnCreate" />
            </el-form-item>
            <el-form-item label="到店前提醒">
              <el-switch v-model="settingsForm.remindBeforeArriveEnabled" />
            </el-form-item>
            <el-form-item label="到店前提前（分钟）">
              <el-input-number
                v-model="settingsForm.remindLeadMinutes"
                :min="0"
                :max="7 * 24 * 60"
                :disabled="!settingsForm.remindBeforeArriveEnabled"
              />
              <span class="field-hint">例如 60=提前1小时，1440=提前1天</span>
            </el-form-item>
            <el-form-item label="取消预约客户通知">
              <el-switch v-model="settingsForm.remindCancelNotifyEnabled" />
              <span class="field-hint">默认关闭，避免取消后默认骚扰客户</span>
            </el-form-item>
            <el-divider content-position="left">发送渠道（门店开关）</el-divider>
            <el-form-item label="启用短信渠道">
              <el-switch v-model="settingsForm.remindSmsEnabled" />
              <el-tag
                class="channel-tag"
                size="small"
                :type="smsProviderConfigured ? 'success' : 'info'"
              >
                {{ smsProviderConfigured ? '平台短信已配置' : '短信渠道未配置' }}
              </el-tag>
            </el-form-item>
            <el-form-item label="启用微信小程序">
              <el-switch v-model="settingsForm.remindWechatEnabled" />
              <el-tag
                class="channel-tag"
                size="small"
                :type="wechatProviderConfigured ? 'success' : 'info'"
              >
                {{ wechatProviderConfigured ? '微信小程序已配置' : '微信小程序未配置' }}
              </el-tag>
            </el-form-item>
            <el-form-item>
              <el-button type="primary" :loading="settingsSaving" @click="submitSettings">
                保存提醒配置
              </el-button>
              <el-button @click="$router.push('/appointments/remind-records')">
                查看提醒记录
              </el-button>
            </el-form-item>
          </el-form>
          <h4>最近提醒任务（本店，最多展示近期）</h4>
          <el-table :data="remindTasks" stripe border max-height="360" empty-text="暂无提醒任务">
            <el-table-column prop="customerName" label="客户" min-width="100" />
            <el-table-column prop="appointmentBillId" label="预约单" min-width="130" />
            <el-table-column prop="taskType" label="类型" width="110" />
            <el-table-column prop="channel" label="渠道" width="100" />
            <el-table-column prop="planTime" label="计划时间" min-width="160" />
            <el-table-column prop="status" label="状态" width="110" />
            <el-table-column prop="resultMsg" label="说明" min-width="160" show-overflow-tooltip />
          </el-table>
        </el-tab-pane>

        <el-tab-pane label="预约设置(兼容)" name="settings">
          <p class="hint">已合并到「门店规则 / 提醒配置」，此页保留兼容入口。</p>
          <el-button type="primary" @click="activeTab = 'rules'">前往门店规则</el-button>
        </el-tab-pane>
      </el-tabs>
    </div>

    <el-dialog
      v-model="typeDialogVisible"
      :title="editingTypeId != null ? '编辑预约类型' : '新增预约类型'"
      width="420px"
      destroy-on-close
    >
      <el-form label-width="80px">
        <el-form-item label="名称" required>
          <el-input v-model="typeForm.name" maxlength="40" placeholder="如：会员预约" />
        </el-form-item>
        <el-form-item label="排序">
          <el-input-number v-model="typeForm.sequence" :min="0" :max="9999" />
        </el-form-item>
        <el-form-item label="启用">
          <el-switch v-model="typeForm.active" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="typeDialogVisible = false">取消</el-button>
        <el-button type="primary" :loading="typeSaving" @click="submitType">保存</el-button>
      </template>
    </el-dialog>

    <el-dialog
      v-model="shiftDialogVisible"
      :title="editingShiftId != null ? '编辑班次' : '新增班次'"
      width="420px"
      destroy-on-close
    >
      <el-form label-width="90px">
        <el-form-item label="名称" required>
          <el-input v-model="shiftForm.name" maxlength="40" placeholder="如：早班" />
        </el-form-item>
        <el-form-item label="开始" required>
          <el-select v-model="shiftForm.startTime" style="width: 100%">
            <el-option v-for="t in TIME_OPTIONS" :key="t" :label="t" :value="t" />
          </el-select>
        </el-form-item>
        <el-form-item label="结束" required>
          <el-select v-model="shiftForm.endTime" style="width: 100%">
            <el-option v-for="t in TIME_OPTIONS" :key="t" :label="t" :value="t" />
          </el-select>
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="shiftDialogVisible = false">取消</el-button>
        <el-button type="primary" :loading="shiftSaving" @click="submitShift">保存</el-button>
      </template>
    </el-dialog>

    <el-dialog
      v-model="applyDialogVisible"
      title="批量排班"
      width="420px"
      destroy-on-close
      @closed="onApplyDialogClose"
    >
      <p class="apply-count">已选 {{ applyTargets.length }} 格</p>
      <el-radio-group v-model="applyMode" class="apply-mode">
        <el-radio-button value="work">上班</el-radio-button>
        <el-radio-button value="rest">休息</el-radio-button>
        <el-radio-button value="clear">清除</el-radio-button>
      </el-radio-group>
      <el-form v-if="applyMode === 'work'" label-width="72px" style="margin-top: 16px">
        <el-form-item label="班次" required>
          <el-select v-model="applyScheduleId" placeholder="选择班次" style="width: 100%">
            <el-option
              v-for="s in schedules"
              :key="s.id!"
              :label="`${s.name}（${s.startTime}-${s.endTime}）`"
              :value="s.id!"
            />
          </el-select>
        </el-form-item>
      </el-form>
      <p v-else-if="applyMode === 'rest'" class="hint" style="margin-top: 12px">
        将所选日期标记为全天休息。
      </p>
      <p v-else class="hint" style="margin-top: 12px">将清除所选日期的排班，恢复为未排班。</p>
      <template #footer>
        <el-button @click="onApplyDialogClose">取消</el-button>
        <el-button type="primary" :loading="rosterSaving" @click="submitBatchApply">
          应用
        </el-button>
      </template>
    </el-dialog>
  </div>
</template>

<style scoped>
.page {
  display: flex;
  flex-direction: column;
  gap: 16px;
  height: 100%;
  min-height: 0;
  box-sizing: border-box;
  padding: 4px 0 16px;
}

.page-header {
  display: flex;
  align-items: flex-start;
  justify-content: space-between;
  gap: 16px;
}

.page-header h1 {
  margin: 0;
  font-size: 20px;
  font-weight: 600;
  color: #303133;
}

.desc {
  margin: 6px 0 0;
  font-size: 13px;
  color: #909399;
}

.body {
  flex: 1;
  min-height: 0;
  background: #fff;
  border: 1px solid #ebeef5;
  border-radius: 8px;
  padding: 8px 16px 16px;
}

.tab-toolbar {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 12px;
  margin-bottom: 12px;
  flex-wrap: wrap;
}

.roster-filters {
  display: flex;
  align-items: center;
  gap: 8px;
  font-size: 13px;
  color: #606266;
}

.roster-settings-title {
  font-size: 13px;
  font-weight: 600;
  margin-bottom: 8px;
  color: #303133;
}

.roster-legend {
  display: flex;
  flex-wrap: wrap;
  align-items: center;
  gap: 14px;
  margin-bottom: 10px;
  font-size: 12px;
  color: #606266;
}

.roster-legend .dot {
  display: inline-block;
  width: 10px;
  height: 10px;
  border-radius: 50%;
  margin-right: 4px;
  vertical-align: -1px;
}

.roster-legend .dot.work {
  background: #ff8a3d;
}

.roster-legend .dot.rest {
  background: #6b7280;
}

.roster-legend .dot.empty {
  background: #d1d5db;
}

.roster-legend .dot.expired {
  background: #e5e7eb;
  box-shadow: inset 0 0 0 1px #9ca3af;
  background-image: repeating-linear-gradient(
    -45deg,
    #e5e7eb,
    #e5e7eb 2px,
    #f3f4f6 2px,
    #f3f4f6 4px
  );
}

.legend-tip {
  color: #909399;
}

.roster-empty {
  padding: 48px 16px;
  text-align: center;
  color: #909399;
  font-size: 13px;
}

.roster-matrix-wrap {
  overflow: auto;
  max-height: calc(100vh - 280px);
  border: 1px solid #e5e7eb;
  border-radius: 6px;
  user-select: none;
}

.roster-matrix {
  border-collapse: separate;
  border-spacing: 0;
  min-width: 100%;
  font-size: 12px;
}

.roster-matrix th,
.roster-matrix td {
  border-right: 1px solid #eef2f6;
  border-bottom: 1px solid #eef2f6;
  box-sizing: border-box;
}

.roster-matrix thead th {
  position: sticky;
  top: 0;
  z-index: 3;
  background: #f8fafc;
  padding: 6px 2px;
  font-weight: 600;
  color: #374151;
}

.roster-matrix .sticky-col {
  position: sticky;
  background: #fff;
  z-index: 2;
}

.roster-matrix thead .sticky-col {
  z-index: 4;
  background: #f8fafc;
}

.roster-matrix .role-col {
  left: 0;
  min-width: 72px;
  max-width: 88px;
  padding: 8px 10px;
  text-align: left;
  color: #6b7280;
}

.roster-matrix .name-col {
  left: 72px;
  min-width: 100px;
  max-width: 140px;
  padding: 8px 10px;
  text-align: left;
  font-weight: 600;
  color: #111827;
  border-right: 1px solid #e5e7eb;
}

.roster-matrix .day-col {
  min-width: 44px;
  width: 44px;
}

.roster-matrix .day-col.today {
  background: #eff6ff;
}

.day-num {
  font-variant-numeric: tabular-nums;
}

.day-wd {
  font-size: 11px;
  font-weight: 500;
  color: #6b7280;
}

.day-wd.weekend {
  color: #ef4444;
}

.day-cell {
  min-width: 44px;
  width: 44px;
  height: 40px;
  text-align: center;
  vertical-align: middle;
  cursor: pointer;
  background: #fafafa;
}

.day-cell.work {
  background: #fff4ec;
  color: #c2410c;
}

.day-cell.rest {
  background: #eceff3;
  color: #4b5563;
}

.day-cell.empty {
  background: #fafafa;
  color: #9ca3af;
}

.day-cell.expired {
  cursor: not-allowed;
  background: repeating-linear-gradient(
    -45deg,
    #f3f4f6,
    #f3f4f6 4px,
    #e5e7eb 4px,
    #e5e7eb 8px
  );
  color: #9ca3af;
}

.day-cell.today:not(.expired) {
  box-shadow: inset 0 0 0 1px #93c5fd;
}

.day-cell.selected:not(.expired) {
  outline: 2px solid #3b82f6;
  outline-offset: -2px;
  background: #dbeafe !important;
}

.day-cell .cell-text {
  display: inline-block;
  max-width: 40px;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
  font-size: 11px;
  font-weight: 600;
}

.day-cell .cell-dash {
  color: #d1d5db;
}

.apply-count {
  margin: 0 0 12px;
  font-size: 13px;
  color: #606266;
}

.apply-mode {
  display: flex;
  flex-wrap: wrap;
}

.remind-alert {
  margin-bottom: 12px;
}

.channel-tag {
  margin-left: 12px;
}

.hint {
  font-size: 12px;
  color: #909399;
}

.field-hint {
  margin-left: 10px;
  font-size: 12px;
  color: #909399;
}

.muted {
  color: #c0c4cc;
}

.settings-form {
  padding-top: 8px;
}
</style>
