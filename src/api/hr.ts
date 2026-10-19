import request from '@/utils/request'
import type { ApiResponse, PageResult } from '@/types/response'
import type {
  CreateEmployeeBody,
  CrossStoreEmployee,
  EmployeePageQuery,
  EmployeeRecord,
  EmployeeRoleAccess,
  HandlerRoleRecord,
  JobTypeRecord,
  MenuPermissionNode,
  PerformanceLineResult,
  PerformanceQueryResult,
  UpdateEmployeeBody,
} from '@/types/hr'
import {
  fetchOrganizationTree,
  type OrganizationTreeNode,
} from '@/api/organization'

export { fetchOrganizationTree }
export type { OrganizationTreeNode }

function pageOf<T>(data: PageResult<T> | null | undefined): PageResult<T> {
  return {
    total: data?.total ?? 0,
    page: data?.page ?? 1,
    size: data?.size ?? 20,
    records: data?.records ?? [],
  }
}

/** —— 组织 —— */
export async function createOrganization(body: {
  parentId?: number | null
  name: string
  store: boolean
  warehouse: boolean
  provinceCode?: string
  cityCode?: string
  areaCode?: string
  addressDetail?: string
}): Promise<OrganizationTreeNode> {
  const res = await request.post<ApiResponse<OrganizationTreeNode>>('/v1/organizations', body)
  return res.data.data
}

export async function updateOrganization(
  id: number,
  body: {
    parentId?: number | null
    name: string
    store: boolean
    warehouse: boolean
    active: boolean
    provinceCode?: string
    cityCode?: string
    areaCode?: string
    addressDetail?: string
  },
): Promise<OrganizationTreeNode> {
  const res = await request.put<ApiResponse<OrganizationTreeNode>>(`/v1/organizations/${id}`, body)
  return res.data.data
}

/** —— 员工 —— */
export async function fetchEmployeePage(query: EmployeePageQuery): Promise<PageResult<EmployeeRecord>> {
  const res = await request.get<ApiResponse<PageResult<EmployeeRecord>>>('/v1/employees', {
    params: query,
  })
  return pageOf(res.data.data)
}

export async function fetchEmployeeDetail(id: string): Promise<EmployeeRecord> {
  const res = await request.get<ApiResponse<EmployeeRecord>>(`/v1/employees/${id}`)
  return res.data.data
}

export async function createEmployee(body: CreateEmployeeBody): Promise<EmployeeRecord> {
  const res = await request.post<ApiResponse<EmployeeRecord>>('/v1/employees', body)
  return res.data.data
}

export async function updateEmployee(id: string, body: UpdateEmployeeBody): Promise<EmployeeRecord> {
  const res = await request.put<ApiResponse<EmployeeRecord>>(`/v1/employees/${id}`, body)
  return res.data.data
}

/** —— 跨店 —— */
export async function fetchCrossStoreEmployees(
  storeId: number,
  keyword?: string,
): Promise<CrossStoreEmployee[]> {
  const res = await request.get<ApiResponse<CrossStoreEmployee[]>>(
    `/v1/stores/${storeId}/cross-store-employees`,
    { params: keyword ? { keyword } : undefined },
  )
  return res.data.data ?? []
}

export async function addCrossStoreEmployee(
  storeId: number,
  employeeId: string,
): Promise<CrossStoreEmployee> {
  const res = await request.post<ApiResponse<CrossStoreEmployee>>(
    `/v1/stores/${storeId}/cross-store-employees`,
    { employeeId },
  )
  return res.data.data
}

export async function removeCrossStoreEmployee(storeId: number, employeeId: string): Promise<void> {
  await request.delete(`/v1/stores/${storeId}/cross-store-employees/${employeeId}`)
}

/** —— 职务 —— */
export async function fetchJobTypePage(params?: {
  keyword?: string
  active?: boolean
  page?: number
  size?: number
}): Promise<PageResult<JobTypeRecord>> {
  const res = await request.get<ApiResponse<PageResult<JobTypeRecord>>>('/v1/job-types', { params })
  return pageOf(res.data.data)
}

export async function createJobType(body: {
  name: string
  description?: string
  active?: boolean
}): Promise<JobTypeRecord> {
  const res = await request.post<ApiResponse<JobTypeRecord>>('/v1/job-types', body)
  return res.data.data
}

export async function updateJobType(
  id: number,
  body: { name: string; description?: string; active?: boolean },
): Promise<JobTypeRecord> {
  const res = await request.put<ApiResponse<JobTypeRecord>>(`/v1/job-types/${id}`, body)
  return res.data.data
}

export async function deleteJobType(id: number): Promise<void> {
  await request.delete(`/v1/job-types/${id}`)
}

export async function fetchJobTypePermissions(id: number): Promise<string[]> {
  const res = await request.get<ApiResponse<string[]>>(`/v1/job-types/${id}/permissions`)
  return res.data.data ?? []
}

export async function replaceJobTypePermissions(
  id: number,
  permissionCodes: string[],
): Promise<string[]> {
  const res = await request.put<ApiResponse<string[]>>(`/v1/job-types/${id}/permissions`, {
    permissionCodes,
  })
  return res.data.data ?? []
}

/** —— 权限目录 / 用户权限 —— */
export async function fetchPermissionTree(): Promise<MenuPermissionNode[]> {
  const res = await request.get<ApiResponse<MenuPermissionNode[]>>('/v1/permissions')
  return res.data.data ?? []
}

export async function fetchEmployeeRoleAccess(employeeId: string): Promise<EmployeeRoleAccess> {
  const res = await request.get<ApiResponse<EmployeeRoleAccess>>(
    `/v1/employees/${employeeId}/role-access`,
  )
  return res.data.data
}

export async function replaceEmployeeRoleAccess(
  employeeId: string,
  body: { jobTypeIds: number[]; orgEntityIds: number[] },
): Promise<EmployeeRoleAccess> {
  const res = await request.put<ApiResponse<EmployeeRoleAccess>>(
    `/v1/employees/${employeeId}/role-access`,
    body,
  )
  return res.data.data
}

/** —— 经手人角色配置 —— */
export async function fetchHandlerRoles(params: {
  bizType: string
  storeId?: number
  onlyActive?: boolean
}): Promise<HandlerRoleRecord[]> {
  const res = await request.get<ApiResponse<HandlerRoleRecord[]>>('/v1/handler-roles', { params })
  return (res.data.data ?? []).map((r) => ({
    ...r,
    jobTypeIds: r.jobTypeIds ?? [],
  }))
}

export async function createHandlerRole(body: {
  bizType: string
  storeId: number
  name: string
  sequence?: number
  jobTypeIds?: number[]
}): Promise<HandlerRoleRecord> {
  const res = await request.post<ApiResponse<HandlerRoleRecord>>('/v1/handler-roles', body)
  return res.data.data
}

export async function updateHandlerRole(
  id: number,
  bizType: string,
  body: { name: string; sequence?: number; active?: boolean; jobTypeIds?: number[] },
): Promise<HandlerRoleRecord> {
  const res = await request.put<ApiResponse<HandlerRoleRecord>>(`/v1/handler-roles/${id}`, body, {
    params: { bizType },
  })
  return res.data.data
}

export async function deactivateHandlerRole(id: number, bizType: string): Promise<HandlerRoleRecord> {
  const res = await request.delete<ApiResponse<HandlerRoleRecord>>(`/v1/handler-roles/${id}`, {
    params: { bizType },
  })
  return res.data.data
}

export async function replaceHandlerRoleJobTypes(
  id: number,
  bizType: string,
  jobTypeIds: number[],
): Promise<HandlerRoleRecord> {
  const res = await request.put<ApiResponse<HandlerRoleRecord>>(
    `/v1/handler-roles/${id}/job-types`,
    { jobTypeIds },
    { params: { bizType } },
  )
  return res.data.data
}

/** —— 业绩汇总 —— */
export async function fetchSalePerformance(params?: {
  from?: string
  to?: string
  employeeId?: string
}): Promise<PerformanceQueryResult> {
  const res = await request.get<ApiResponse<PerformanceQueryResult>>('/v1/performance/sales', {
    params,
  })
  return res.data.data
}

export async function fetchTreatPerformance(params?: {
  from?: string
  to?: string
  employeeId?: string
}): Promise<PerformanceQueryResult> {
  const res = await request.get<ApiResponse<PerformanceQueryResult>>('/v1/performance/treat', {
    params,
  })
  return res.data.data
}

export async function fetchSalePerformanceLines(params?: {
  from?: string
  to?: string
  employeeId?: string
  itemType?: string
}): Promise<PerformanceLineResult> {
  const res = await request.get<ApiResponse<PerformanceLineResult>>('/v1/performance/sales/lines', {
    params,
  })
  return res.data.data
}

export async function fetchTreatPerformanceLines(params?: {
  from?: string
  to?: string
  employeeId?: string
  itemType?: string
}): Promise<PerformanceLineResult> {
  const res = await request.get<ApiResponse<PerformanceLineResult>>('/v1/performance/treat/lines', {
    params,
  })
  return res.data.data
}
