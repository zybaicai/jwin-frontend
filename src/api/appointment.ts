import request from '@/utils/request'
import type { ApiResponse } from '@/types/response'
import type {
  AppointmentItem,
  AppointmentPageQuery,
  AvailableSlotItem,
  AvailableSlotsQuery,
  CreateAppointmentRequest,
} from '@/types/appointment'
import type { PageData } from '@/types/customer'

/**
 * GET /v1/appointments —— 预约分页（可按 customerId 过滤）
 */
export async function fetchAppointmentPage(
  query: AppointmentPageQuery = {},
): Promise<PageData<AppointmentItem>> {
  const params: Record<string, string | number> = {}
  if (query.storeId != null) {
    params.storeId = query.storeId
  }
  if (query.date != null && query.date !== '') {
    params.date = query.date
  }
  if (query.dateFrom != null && query.dateFrom !== '') {
    params.dateFrom = query.dateFrom
  }
  if (query.dateTo != null && query.dateTo !== '') {
    params.dateTo = query.dateTo
  }
  if (query.status != null && query.status !== '') {
    params.status = query.status
  }
  if (query.employeeId != null && query.employeeId !== '') {
    params.employeeId = query.employeeId
  }
  if (query.customerId != null) {
    params.customerId = query.customerId
  }
  if (query.page != null) {
    params.page = query.page
  }
  if (query.size != null) {
    params.size = query.size
  }
  const response = await request.get<ApiResponse<PageData<AppointmentItem>>>('/v1/appointments', {
    params,
  })
  return response.data.data
}

/**
 * GET /v1/appointments/available-slots —— 可预约时段（含可用护理师）
 */
export async function fetchAvailableSlots(
  query: AvailableSlotsQuery = {},
): Promise<AvailableSlotItem[]> {
  const params: Record<string, string | number> = {}
  if (query.storeId != null) {
    params.storeId = query.storeId
  }
  if (query.date != null && query.date !== '') {
    params.date = query.date
  }
  if (query.projectId != null) {
    params.projectId = query.projectId
  }
  if (query.employeeId != null && query.employeeId !== '') {
    params.employeeId = query.employeeId
  }
  const response = await request.get<ApiResponse<AvailableSlotItem[]>>(
    '/v1/appointments/available-slots',
    { params },
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
