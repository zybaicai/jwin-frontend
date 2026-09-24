/**
 * 预约类型。字段对齐后端 AppointmentVo / AppointmentPageQuery /
 * CreateAppointmentCommand / AvailableSlotVo。
 */

export interface AppointmentItem {
  id: string
  storeId: number | null
  customerId: number | null
  employeeId: string | null
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
}

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

/** 对齐后端 CreateAppointmentCommand */
export interface CreateAppointmentRequest {
  customerId: number
  storeId: number
  projectId: number
  employeeId: string
  /** LocalDateTime，如 2026-09-25T10:00:00 */
  startTime: string
  appointmentTypeId?: number | null
  remark?: string | null
}

/** 对齐后端 AvailableSlotVo */
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
