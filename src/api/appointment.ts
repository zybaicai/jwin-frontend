import request from '@/utils/request'
import type { ApiResponse } from '@/types/response'
import type {
  AppointmentBoard,
  AppointmentConfig,
  AppointmentDetail,
  AppointmentEmployeeCapacity,
  AppointmentEmployeeOption,
  AppointmentItem,
  AppointmentPageQuery,
  AppointmentProcessLine,
  AppointmentScheduleDayEmployee,
  AppointmentScheduleItem,
  AppointmentTypeItem,
  AssignScheduleDayRequest,
  BatchAssignScheduleRequest,
  AvailableSlotItem,
  AvailableSlotsQuery,
  CancelAppointmentRequest,
  CreateAppointmentRequest,
  InviteAssistItem,
  OpenTreatResult,
  RemindTaskItem,
  StatusRemarkRequest,
  UpdateAppointmentRequest,
  UpsertAppointmentConfigRequest,
  UpsertAppointmentScheduleRequest,
} from '@/types/appointment'
import type { PageData } from '@/types/customer'

function buildParams(
  query: Record<string, string | number | boolean | undefined | null>,
): Record<string, string | number | boolean> {
  const params: Record<string, string | number | boolean> = {}
  for (const [key, value] of Object.entries(query)) {
    if (value === undefined || value === null || value === '') {
      continue
    }
    params[key] = value
  }
  return params
}

/**
 * GET /v1/appointments —— 预约分页
 */
export async function fetchAppointmentPage(
  query: AppointmentPageQuery = {},
): Promise<PageData<AppointmentItem>> {
  const response = await request.get<ApiResponse<PageData<AppointmentItem>>>('/v1/appointments', {
    params: buildParams({
      storeId: query.storeId,
      date: query.date,
      dateFrom: query.dateFrom,
      dateTo: query.dateTo,
      status: query.status,
      employeeId: query.employeeId,
      customerId: query.customerId,
      page: query.page,
      size: query.size,
    }),
  })
  return response.data.data
}

/**
 * GET /v1/appointments/board —— 当日看板
 */
export async function fetchAppointmentBoard(query: {
  storeId?: number
  date?: string
}): Promise<AppointmentBoard> {
  const response = await request.get<ApiResponse<AppointmentBoard>>('/v1/appointments/board', {
    params: buildParams({
      storeId: query.storeId,
      date: query.date,
    }),
  })
  const data = response.data.data
  return {
    date: data?.date ?? null,
    storeId: data?.storeId ?? null,
    appointments: data?.appointments ?? [],
    onDuty: data?.onDuty ?? [],
  }
}

/**
 * GET /v1/appointments/{id} —— 详情
 */
export async function fetchAppointmentDetail(id: string): Promise<AppointmentDetail> {
  const response = await request.get<ApiResponse<AppointmentDetail>>(`/v1/appointments/${id}`)
  return response.data.data
}

/**
 * GET /v1/appointments/employees —— 护理师下拉
 */
export async function fetchAppointmentEmployees(
  storeId?: number,
): Promise<AppointmentEmployeeOption[]> {
  const response = await request.get<ApiResponse<AppointmentEmployeeOption[]>>(
    '/v1/appointments/employees',
    { params: buildParams({ storeId }) },
  )
  return response.data.data ?? []
}

/**
 * GET /v1/appointments/{id}/processes —— 过程日志
 */
export async function fetchAppointmentProcesses(
  id: string,
): Promise<AppointmentProcessLine[]> {
  const response = await request.get<ApiResponse<AppointmentProcessLine[]>>(
    `/v1/appointments/${id}/processes`,
  )
  return response.data.data ?? []
}

/**
 * GET /v1/appointments/available-slots —— 可预约时段
 */
export async function fetchAvailableSlots(
  query: AvailableSlotsQuery = {},
): Promise<AvailableSlotItem[]> {
  const response = await request.get<ApiResponse<AvailableSlotItem[]>>(
    '/v1/appointments/available-slots',
    {
      params: buildParams({
        storeId: query.storeId,
        date: query.date,
        projectId: query.projectId,
        employeeId: query.employeeId,
      }),
    },
  )
  return response.data.data ?? []
}

/**
 * GET /v1/appointment-schedules/config —— 预约设置
 */
export async function fetchAppointmentConfig(
  storeId?: number,
): Promise<AppointmentConfig | null> {
  const response = await request.get<ApiResponse<AppointmentConfig>>(
    '/v1/appointment-schedules/config',
    { params: buildParams({ storeId }) },
  )
  return response.data.data ?? null
}

/**
 * PUT /v1/appointment-schedules/config
 */
export async function saveAppointmentConfig(
  body: UpsertAppointmentConfigRequest,
): Promise<AppointmentConfig> {
  const response = await request.put<ApiResponse<AppointmentConfig>>(
    '/v1/appointment-schedules/config',
    body,
  )
  return response.data.data
}

/**
 * GET /v1/appointment-schedules —— 班次列表
 */
export async function fetchAppointmentSchedules(
  storeId?: number,
): Promise<AppointmentScheduleItem[]> {
  const response = await request.get<ApiResponse<AppointmentScheduleItem[]>>(
    '/v1/appointment-schedules',
    { params: buildParams({ storeId }) },
  )
  return response.data.data ?? []
}

/**
 * POST /v1/appointment-schedules
 */
export async function createAppointmentSchedule(
  body: UpsertAppointmentScheduleRequest,
): Promise<AppointmentScheduleItem> {
  const response = await request.post<ApiResponse<AppointmentScheduleItem>>(
    '/v1/appointment-schedules',
    body,
  )
  return response.data.data
}

/**
 * PUT /v1/appointment-schedules/{id}
 */
export async function updateAppointmentSchedule(
  id: number,
  body: UpsertAppointmentScheduleRequest,
): Promise<AppointmentScheduleItem> {
  const response = await request.put<ApiResponse<AppointmentScheduleItem>>(
    `/v1/appointment-schedules/${id}`,
    body,
  )
  return response.data.data
}

/**
 * GET /v1/appointment-schedules/day-assignments —— 日排班 / 整月区间
 */
export async function fetchScheduleDayAssignments(query: {
  storeId?: number
  date?: string
  from?: string
  to?: string
}): Promise<AppointmentScheduleDayEmployee[]> {
  const response = await request.get<ApiResponse<AppointmentScheduleDayEmployee[]>>(
    '/v1/appointment-schedules/day-assignments',
    {
      params: buildParams({
        storeId: query.storeId,
        date: query.date,
        from: query.from,
        to: query.to,
      }),
    },
  )
  return response.data.data ?? []
}

/**
 * POST /v1/appointment-schedules/day-assignments
 */
export async function assignScheduleDay(
  body: AssignScheduleDayRequest,
): Promise<AppointmentScheduleDayEmployee> {
  const response = await request.post<ApiResponse<AppointmentScheduleDayEmployee>>(
    '/v1/appointment-schedules/day-assignments',
    body,
  )
  return response.data.data
}

/**
 * POST /v1/appointment-schedules/day-assignments/batch —— 整店批量排班
 */
export async function batchAssignScheduleDay(
  body: BatchAssignScheduleRequest,
): Promise<AppointmentScheduleDayEmployee[]> {
  const response = await request.post<ApiResponse<AppointmentScheduleDayEmployee[]>>(
    '/v1/appointment-schedules/day-assignments/batch',
    body,
  )
  return response.data.data ?? []
}

/**
 * POST /v1/appointments —— 创建预约
 */
export async function createAppointment(
  body: CreateAppointmentRequest,
): Promise<AppointmentItem> {
  const response = await request.post<ApiResponse<AppointmentItem>>('/v1/appointments', body)
  return response.data.data
}

/**
 * PUT /v1/appointments/{id} —— 修改预约
 */
export async function updateAppointment(
  id: string,
  body: UpdateAppointmentRequest,
): Promise<AppointmentItem> {
  const response = await request.put<ApiResponse<AppointmentItem>>(
    `/v1/appointments/${id}`,
    body,
  )
  return response.data.data
}

/**
 * POST /v1/appointments/{id}/confirm
 */
export async function confirmAppointment(id: string): Promise<AppointmentItem> {
  const response = await request.post<ApiResponse<AppointmentItem>>(
    `/v1/appointments/${id}/confirm`,
  )
  return response.data.data
}

/**
 * POST /v1/appointments/{id}/arrive
 */
export async function arriveAppointment(id: string): Promise<AppointmentItem> {
  const response = await request.post<ApiResponse<AppointmentItem>>(
    `/v1/appointments/${id}/arrive`,
  )
  return response.data.data
}

/**
 * POST /v1/appointments/{id}/no-show
 */
export async function noShowAppointment(
  id: string,
  body?: StatusRemarkRequest,
): Promise<AppointmentItem> {
  const response = await request.post<ApiResponse<AppointmentItem>>(
    `/v1/appointments/${id}/no-show`,
    body ?? {},
  )
  return response.data.data
}

/**
 * POST /v1/appointments/{id}/cancel
 */
export async function cancelAppointment(
  id: string,
  body?: CancelAppointmentRequest,
): Promise<AppointmentItem> {
  const response = await request.post<ApiResponse<AppointmentItem>>(
    `/v1/appointments/${id}/cancel`,
    body ?? {},
  )
  return response.data.data
}

/**
 * POST /v1/appointments/{id}/open-treat —— 开消耗预填（不建单）
 */
export async function openTreatFromAppointment(id: string): Promise<OpenTreatResult> {
  const response = await request.post<ApiResponse<OpenTreatResult>>(
    `/v1/appointments/${id}/open-treat`,
  )
  return response.data.data
}

export async function fetchAppointmentTypes(
  includeInactive = false,
): Promise<AppointmentTypeItem[]> {
  const response = await request.get<ApiResponse<AppointmentTypeItem[]>>(
    '/v1/appointments/types',
    { params: includeInactive ? { includeInactive: true } : undefined },
  )
  return response.data.data ?? []
}

export async function createAppointmentType(body: {
  name: string
  sequence?: number | null
  active?: boolean | null
}): Promise<AppointmentTypeItem> {
  const response = await request.post<ApiResponse<AppointmentTypeItem>>(
    '/v1/appointments/types',
    body,
  )
  return response.data.data
}

export async function updateAppointmentType(
  id: number,
  body: { name: string; sequence?: number | null; active?: boolean | null },
): Promise<AppointmentTypeItem> {
  const response = await request.put<ApiResponse<AppointmentTypeItem>>(
    `/v1/appointments/types/${id}`,
    body,
  )
  return response.data.data
}

export async function deactivateAppointmentType(id: number): Promise<void> {
  await request.delete(`/v1/appointments/types/${id}`)
}

export async function fetchAppointmentCapacities(
  storeId?: number,
): Promise<AppointmentEmployeeCapacity[]> {
  const response = await request.get<ApiResponse<AppointmentEmployeeCapacity[]>>(
    '/v1/appointments/capacities',
    { params: buildParams({ storeId }) },
  )
  return (response.data.data ?? []).map((row) => ({
    ...row,
    storeId: row.storeId ?? row.entityId ?? null,
    maxConcurrent: row.maxConcurrent ?? 2,
    employeeId: row.employeeId,
  }))
}

export async function saveAppointmentCapacity(body: {
  storeId: number
  employeeId: string
  maxConcurrent: number
}): Promise<AppointmentEmployeeCapacity> {
  const response = await request.put<ApiResponse<AppointmentEmployeeCapacity>>(
    '/v1/appointments/capacities',
    body,
  )
  return response.data.data
}

export async function fetchInviteAssist(query: {
  storeId?: number
  date?: string
}): Promise<InviteAssistItem[]> {
  const response = await request.get<ApiResponse<InviteAssistItem[]>>(
    '/v1/appointments/invite-assist',
    { params: buildParams({ storeId: query.storeId, date: query.date }) },
  )
  return response.data.data ?? []
}

export async function fetchSameDayAppointments(query: {
  storeId?: number
  customerId: number
  date?: string
  excludeId?: string
}): Promise<AppointmentItem[]> {
  const response = await request.get<ApiResponse<AppointmentItem[]>>(
    '/v1/appointments/same-day',
    {
      params: buildParams({
        storeId: query.storeId,
        customerId: query.customerId,
        date: query.date,
        excludeId: query.excludeId,
      }),
    },
  )
  return response.data.data ?? []
}

export async function fetchRemindTasks(query: {
  storeId?: number
  appointmentId?: string
  status?: string
  channel?: string
  taskType?: string
  customerId?: number
  planFrom?: string
  planTo?: string
}): Promise<RemindTaskItem[]> {
  const response = await request.get<ApiResponse<RemindTaskItem[]>>(
    '/v1/appointments/remind-tasks',
    {
      params: buildParams({
        storeId: query.storeId,
        appointmentId: query.appointmentId,
        status: query.status,
        channel: query.channel,
        taskType: query.taskType,
        customerId: query.customerId,
        planFrom: query.planFrom,
        planTo: query.planTo,
      }),
    },
  )
  return response.data.data ?? []
}

/** 手动触发到期扫描（验收/联调） */
export async function dispatchRemindTasks(): Promise<number> {
  const response = await request.post<ApiResponse<number>>(
    '/v1/appointments/remind-tasks/dispatch',
  )
  return response.data.data ?? 0
}
