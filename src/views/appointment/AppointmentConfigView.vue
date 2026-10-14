<script setup lang="ts">
import { computed, onMounted, onUnmounted, reactive, ref, watch } from 'vue'
import { useRoute } from 'vue-router'
import { ElMessage, ElMessageBox } from 'element-plus'

import AppError from '@/components/common/AppError.vue'
import {
  assignScheduleDay,
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

// ——— 排班 ———
const rosterDate = ref(formatDateYmd(new Date()))
const employees = ref<AppointmentEmployeeOption[]>([])
const dayAssignments = ref<AppointmentScheduleDayEmployee[]>([])
const rosterSavingKey = ref<string | null>(null)

interface RosterRow {
  employeeId: string
  employeeName: string
  scheduleId: number | null
  rest: boolean
  scheduleName: string | null
  startTime: string | null
  endTime: string | null
  restStartTime: string | null
  restEndTime: string | null
}

const rosterRows = computed<RosterRow[]>(() => {
  const map = new Map<string, AppointmentScheduleDayEmployee>()
  for (const a of dayAssignments.value) {
    if (a.employeeId) map.set(a.employeeId, a)
  }
  return employees.value.map((emp) => {
    const hit = map.get(emp.employeeId)
    return {
      employeeId: emp.employeeId,
      employeeName: emp.employeeName?.trim() || emp.employeeId,
      scheduleId: hit?.scheduleId ?? null,
      rest: hit?.rest === true,
      scheduleName: hit?.scheduleName ?? null,
      startTime: hit?.startTime ?? null,
      endTime: hit?.endTime ?? null,
      restStartTime: hit?.restStartTime ?? null,
      restEndTime: hit?.restEndTime ?? null,
    }
  })
})

async function loadRoster(): Promise<void> {
  if (storeId.value == null) {
    employees.value = []
    dayAssignments.value = []
    return
  }
  const [emps, assigns] = await Promise.all([
    fetchAppointmentEmployees(storeId.value),
    fetchScheduleDayAssignments({ storeId: storeId.value, date: rosterDate.value }),
  ])
  employees.value = emps
  dayAssignments.value = assigns
}

async function saveRosterRow(row: RosterRow): Promise<void> {
  if (storeId.value == null) {
    uiMessage.warning('请先选择门店')
    return
  }
  if (!canEdit.value) {
    uiMessage.warning('无编辑权限')
    return
  }
  if (!row.rest && row.scheduleId == null) {
    uiMessage.warning('上班须选择班次，或勾选休息/请假')
    return
  }
  if (
    !row.rest &&
    row.restStartTime &&
    row.restEndTime &&
    row.restStartTime >= row.restEndTime
  ) {
    uiMessage.warning('休息结束时间须晚于开始时间')
    return
  }
  const key = row.employeeId
  rosterSavingKey.value = key
  try {
    await assignScheduleDay({
      storeId: storeId.value,
      employeeId: row.employeeId,
      scheduleDate: rosterDate.value,
      scheduleId: row.rest ? null : row.scheduleId,
      rest: row.rest,
      restStartTime: row.rest ? null : row.restStartTime || null,
      restEndTime: row.rest ? null : row.restEndTime || null,
      source: 'MANUAL',
    })
    ElMessage.success('排班已保存')
    await loadRoster()
  } catch (e) {
    ElMessage.error(getUserFriendlyErrorMessage(e))
  } finally {
    rosterSavingKey.value = null
  }
}

async function onRestChange(row: RosterRow, rest: boolean): Promise<void> {
  row.rest = rest
  if (rest) {
    row.scheduleId = null
    row.restStartTime = null
    row.restEndTime = null
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
})

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

watch(rosterDate, () => {
  if (activeTab.value === 'roster') {
    void runExclusive(loading, async () => {
      try {
        await loadRoster()
      } catch (e) {
        ElMessage.error(getUserFriendlyErrorMessage(e))
      }
    })
  }
})

watch(activeTab, (tab) => {
  if (tab === 'roster' && employees.value.length === 0 && !loading.value) {
    void loadRoster()
  }
})

function onStoreChanged(): void {
  void loadAll()
}

onMounted(() => {
  void loadAll()
  window.addEventListener(STORE_CONTEXT_CHANGED_EVENT, onStoreChanged)
})

onUnmounted(() => {
  window.removeEventListener(STORE_CONTEXT_CHANGED_EVENT, onStoreChanged)
})
</script>

<template>
  <div class="page">
    <header class="page-header">
      <div>
        <h1>预约配置</h1>
        <p class="desc">
          维护本店班次、日排班、门店规则与护理师能力；预约类型与提醒由管理员配置。
        </p>
      </div>
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
              <span>排班日期</span>
              <el-date-picker
                v-model="rosterDate"
                type="date"
                value-format="YYYY-MM-DD"
                :clearable="false"
                style="width: 160px"
              />
            </div>
            <span class="hint">为护理师指定当日班次或休息；无排班时看板仍可预约。</span>
          </div>
          <el-table :data="rosterRows" stripe border empty-text="本店暂无可排班护理师">
            <el-table-column prop="employeeName" label="护理师" min-width="140" />
            <el-table-column label="请假/停排" width="100" align="center">
              <template #default="{ row }">
                <el-switch
                  :model-value="row.rest"
                  :disabled="!canEdit"
                  @change="(v: string | number | boolean) => onRestChange(row, !!v)"
                />
              </template>
            </el-table-column>
            <el-table-column label="班次" min-width="180">
              <template #default="{ row }">
                <el-select
                  v-model="row.scheduleId"
                  clearable
                  placeholder="选择班次"
                  :disabled="!canEdit || row.rest"
                  style="width: 100%"
                >
                  <el-option
                    v-for="s in schedules"
                    :key="s.id!"
                    :label="`${s.name}（${s.startTime}-${s.endTime}）`"
                    :value="s.id!"
                  />
                </el-select>
              </template>
            </el-table-column>
            <el-table-column label="上班时段" width="130">
              <template #default="{ row }">
                <span v-if="row.rest">全天请假</span>
                <span v-else-if="row.startTime && row.endTime">
                  {{ row.startTime }}-{{ row.endTime }}
                </span>
                <span v-else class="muted">—</span>
              </template>
            </el-table-column>
            <el-table-column label="休息开始" width="120">
              <template #default="{ row }">
                <el-select
                  v-model="row.restStartTime"
                  clearable
                  placeholder="可选"
                  :disabled="!canEdit || row.rest"
                  style="width: 100%"
                >
                  <el-option v-for="t in TIME_OPTIONS" :key="t" :label="t" :value="t" />
                </el-select>
              </template>
            </el-table-column>
            <el-table-column label="休息结束" width="120">
              <template #default="{ row }">
                <el-select
                  v-model="row.restEndTime"
                  clearable
                  placeholder="可选"
                  :disabled="!canEdit || row.rest"
                  style="width: 100%"
                >
                  <el-option v-for="t in TIME_OPTIONS" :key="t" :label="t" :value="t" />
                </el-select>
              </template>
            </el-table-column>
            <el-table-column label="操作" width="100" fixed="right">
              <template #default="{ row }">
                <el-button
                  link
                  type="primary"
                  :loading="rosterSavingKey === row.employeeId"
                  :disabled="!canEdit"
                  @click="saveRosterRow(row)"
                >
                  保存
                </el-button>
              </template>
            </el-table-column>
          </el-table>
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
          <el-form label-width="180px" class="settings-form" style="max-width: 560px">
            <el-form-item label="启用提醒任务">
              <el-switch v-model="settingsForm.remindEnabled" />
            </el-form-item>
            <el-form-item label="创建后立即提醒">
              <el-switch v-model="settingsForm.remindOnCreate" />
            </el-form-item>
            <el-form-item label="到店前提前（分钟）">
              <el-input-number
                v-model="settingsForm.remindLeadMinutes"
                :min="0"
                :max="7 * 24 * 60"
              />
            </el-form-item>
            <el-form-item>
              <el-button type="primary" :loading="settingsSaving" @click="submitSettings">
                保存提醒配置
              </el-button>
            </el-form-item>
          </el-form>
          <h4>提醒记录（渠道未接入，状态保持 PENDING，不会标发送成功）</h4>
          <el-table :data="remindTasks" stripe border max-height="360" empty-text="暂无提醒任务">
            <el-table-column prop="appointmentBillId" label="预约单" min-width="140" />
            <el-table-column prop="taskType" label="类型" width="120" />
            <el-table-column prop="planTime" label="计划时间" min-width="160" />
            <el-table-column prop="status" label="状态" width="100" />
            <el-table-column prop="channel" label="渠道" width="90" />
            <el-table-column prop="resultMsg" label="说明" min-width="140" show-overflow-tooltip />
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
