/**
 * 预约类型。对齐后端 AppointmentVo / AppointmentBoardVo / Command / OpenTreatVo。
 * 状态：WAIT 待确认 / CONF 已预约 / ARRV 已到店 / SERV 服务中 / DONE 已完成 / CANC 已取消 / NOSH 爽约
 */

export const AppointmentStatus = {
  WAIT: 'WAIT',
  CONF: 'CONF',
  ARRV: 'ARRV',
  SERV: 'SERV',
  DONE: 'DONE',
  CANC: 'CANC',
  NOSH: 'NOSH',
} as const

export type AppointmentStatusCode =
  (typeof AppointmentStatus)[keyof typeof AppointmentStatus]

export const APPOINTMENT_STATUS_OPTIONS: ReadonlyArray<{
  value: AppointmentStatusCode
  label: string
}> = [
  { value: 'WAIT', label: '待确认' },
  { value: 'CONF', label: '已预约' },
  { value: 'ARRV', label: '已到店' },
  { value: 'SERV', label: '服务中' },
  { value: 'DONE', label: '已完成' },
  { value: 'CANC', label: '已取消' },
  { value: 'NOSH', label: '爽约' },
]

export function appointmentStatusLabel(code: string | null | undefined): string {
  if (!code) {
    return '—'
  }
  const hit = APPOINTMENT_STATUS_OPTIONS.find((o) => o.value === code)
  return hit?.label ?? code
}

/** 对齐 AppointmentVo.ProjectLine */
export interface AppointmentProjectLine {
  projectId: number | null
  projectName: string | null
  sequence: number | null
  durationMinutes: number | null
}

/** 对齐 AppointmentVo.ProcessLine */
export interface AppointmentProcessLine {
  id: number | null
  actionType: string | null
  fromStatus: string | null
  fromStatusName: string | null
  toStatus: string | null
  toStatusName: string | null
  remark: string | null
  createdBy: string | null
  createdByName: string | null
  createdOn: string | null
}

/** 对齐 AppointmentVo（列表/看板卡片/详情共用） */
export interface AppointmentItem {
  id: string
  storeId: number | null
  customerId: number | null
  customerName: string | null
  customerMobile: string | null
  employeeId: string | null
  employeeName: string | null
  projectId: number | null
  projectNameSnapshot: string | null
  durationMinutes: number | null
  startDateTime: string | null
  endDateTime: string | null
  status: string | null
  statusName: string | null
  appointmentTypeId: number | null
  remark: string | null
  createdOn: string | null
  createdBy?: string | null
  updatedOn?: string | null
  version?: number | null
  treatBillId?: string | null
  projects?: AppointmentProjectLine[]
  processes?: AppointmentProcessLine[]
}

/** 详情 = 完整 AppointmentVo（含 projects / processes / version / treatBillId） */
export type AppointmentDetail = AppointmentItem

export interface AppointmentPageQuery {
  storeId?: number
  date?: string
  dateFrom?: string
  dateTo?: string
  status?: string
  employeeId?: string
  customerId?: number
  page?: number
  size?: number
}

/** 对齐 ScheduleDayEmployeeVo */
export interface AppointmentScheduleDayEmployee {
  id: number | null
  storeId: number | null
  employeeId: string | null
  scheduleDate: string | null
  scheduleId: number | null
  rest: boolean | null
  scheduleName: string | null
  startTime: string | null
  endTime: string | null
  restStartTime?: string | null
  restEndTime?: string | null
}

/** 对齐 AppointmentBoardVo */
export interface AppointmentBoard {
  date: string | null
  storeId: number | null
  appointments: AppointmentItem[]
  onDuty: AppointmentScheduleDayEmployee[]
}

/** 对齐 AppointmentEmployeeOptionVo */
export interface AppointmentEmployeeOption {
  employeeId: string
  employeeName: string | null
  primaryStore: boolean | null
  onDuty: boolean | null
}

/** 对齐 AppointmentConfigVo */
export interface AppointmentConfig {
  id: number | null
  storeId: number | null
  startTime: string | null
  endTime: string | null
  period: number | null
  appointmentServicerIsRequired?: boolean | null
  canChooseRestEmployee?: boolean | null
  allowMultiBooking?: boolean | null
  remindOnCreate?: boolean | null
  remindLeadMinutes?: number | null
  remindEnabled?: boolean | null
}

export interface AppointmentTypeItem {
  id: number
  name: string | null
  sequence: number | null
  active: boolean | null
}

export interface AppointmentEmployeeCapacity {
  id: number | null
  entityId?: number | null
  storeId?: number | null
  employeeId: string
  maxConcurrent: number
  active?: boolean | null
}

export interface InviteAssistItem {
  customerId: number
  customerName: string | null
  customerMobile: string | null
  weekdayVisitCount: number | null
  lastVisitAt: string | null
  weekday: number | null
}

export interface RemindTaskItem {
  id: number | null
  appointmentBillId: string | null
  storeId: number | null
  taskType: string | null
  channel: string | null
  planTime: string | null
  status: string | null
  content: string | null
  resultMsg: string | null
  createdOn: string | null
  cancelledOn: string | null
}

/** 对齐 ScheduleVo（班次） */
export interface AppointmentScheduleItem {
  id: number | null
  storeId: number | null
  name: string | null
  startTime: string | null
  endTime: string | null
}

export interface UpsertAppointmentScheduleRequest {
  storeId: number
  name: string
  startTime: string
  endTime: string
}

export interface AssignScheduleDayRequest {
  storeId: number
  employeeId: string
  scheduleDate: string
  scheduleId?: number | null
  rest: boolean
  restStartTime?: string | null
  restEndTime?: string | null
  source?: string | null
}

export interface UpsertAppointmentConfigRequest {
  storeId: number
  startTime: string
  endTime: string
  period: number
  appointmentServicerIsRequired?: boolean | null
  canChooseRestEmployee?: boolean | null
  allowMultiBooking?: boolean | null
  remindOnCreate?: boolean | null
  remindLeadMinutes?: number | null
  remindEnabled?: boolean | null
}

/** 对齐 CreateAppointmentCommand */
export interface CreateAppointmentRequest {
  customerId: number
  storeId: number
  /** 兼容旧版单项目；与 projectIds 二选一，优先 projectIds */
  projectId?: number | null
  projectIds?: number[]
  /** 可空：到店确认列未分派护理师 */
  employeeId?: string | null
  /** LocalDateTime，如 2026-09-25T10:00:00 */
  startTime: string
  durationMinutes?: number | null
  appointmentTypeId?: number | null
  remark?: string | null
}

/** 对齐 UpdateAppointmentCommand */
export interface UpdateAppointmentRequest {
  customerId?: number | null
  projectId?: number | null
  /** 显式提交时可为空数组（无项目） */
  projectIds?: number[] | null
  employeeId?: string | null
  startTime?: string | null
  durationMinutes?: number | null
  appointmentTypeId?: number | null
  remark?: string | null
  /** 乐观锁：带回详情 version */
  version?: number | null
}

export interface CancelAppointmentRequest {
  reason?: string | null
}

export interface StatusRemarkRequest {
  reason?: string | null
}

/** 对齐 OpenTreatVo */
export interface OpenTreatResult {
  appointmentId: string
  storeId: number | null
  customerId: number | null
  customerName: string | null
  employeeId: string | null
  employeeName: string | null
  status: string | null
  treatBillId: string | null
  alreadyOpened: boolean | null
  projectIds: number[]
  projectNames: string[]
}

/** 对齐 AvailableSlotVo（客户档案快捷预约仍用） */
export interface AvailableSlotItem {
  startDateTime: string
  endDateTime: string
  employeeIds: string[]
}

export interface AvailableSlotsQuery {
  storeId?: number
  date?: string
  projectId?: number
  employeeId?: string
}

export const AppointmentPermission = {
  VIEW: 'appointment:view',
  EDIT: 'appointment:edit',
  STATUS: 'appointment:status',
} as const

/** 到店后禁编辑/取消；仅 WAIT|CONF 可改 */
export function canModifyAppointment(status: string | null | undefined): boolean {
  return status === AppointmentStatus.WAIT || status === AppointmentStatus.CONF
}

export function canConfirmAppointment(status: string | null | undefined): boolean {
  return status === AppointmentStatus.WAIT
}

export function canArriveAppointment(status: string | null | undefined): boolean {
  return status === AppointmentStatus.CONF || status === AppointmentStatus.WAIT
}

export function canNoShowAppointment(status: string | null | undefined): boolean {
  return status === AppointmentStatus.WAIT || status === AppointmentStatus.CONF
}

export function canCancelAppointment(status: string | null | undefined): boolean {
  return status === AppointmentStatus.WAIT || status === AppointmentStatus.CONF
}

export function canOpenTreatAppointment(status: string | null | undefined): boolean {
  return status === AppointmentStatus.ARRV || status === AppointmentStatus.SERV
}

export function projectSummary(item: AppointmentItem | null | undefined): string {
  if (!item) {
    return '—'
  }
  const names = (item.projects ?? [])
    .map((p) => p.projectName?.trim())
    .filter((n): n is string => !!n)
  if (names.length > 0) {
    return names.join('、')
  }
  return item.projectNameSnapshot?.trim() || '—'
}
