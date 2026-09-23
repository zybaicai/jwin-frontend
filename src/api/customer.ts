import request from '@/utils/request'
import type { ApiResponse } from '@/types/response'
import type {
  CreateCustomerBody,
  CustomerCardItem,
  CustomerCardQuery,
  CustomerDetail,
  CustomerListItem,
  CustomerListQuery,
  CustomerPaymentItem,
  CustomerPaymentQuery,
  CustomerTreatOrderItem,
  CustomerTreatOrderQuery,
  CustomerSaleOrder,
  CustomerSaleQuery,
  CustomerSourceOption,
  CustomerTagItem,
  PageData,
  ServicerOption,
  UpdateCustomerBody,
} from '@/types/customer'

function toParams(query: CustomerListQuery): Record<string, string | number> {
  const params: Record<string, string | number> = {}
  const entries = Object.entries(query) as Array<[keyof CustomerListQuery, CustomerListQuery[keyof CustomerListQuery]]>
  for (const [key, value] of entries) {
    if (value === undefined || value === null || value === '') {
      continue
    }
    params[key] = value
  }
  return params
}

/**
 * GET /v1/customers
 */
export async function fetchCustomerPage(query: CustomerListQuery): Promise<PageData<CustomerListItem>> {
  const response = await request.get<ApiResponse<PageData<CustomerListItem>>>('/v1/customers', {
    params: toParams(query),
  })
  return response.data.data
}

/**
 * GET /v1/customers/{id} —— 客户详情（明文手机号 + 汇总指标）
 */
export async function fetchCustomerDetail(id: number): Promise<CustomerDetail> {
  const response = await request.get<ApiResponse<CustomerDetail>>(`/v1/customers/${id}`)
  return response.data.data
}

/**
 * POST /v1/customers
 */
export async function createCustomer(body: CreateCustomerBody): Promise<CustomerDetail> {
  const response = await request.post<ApiResponse<CustomerDetail>>('/v1/customers', body)
  return response.data.data
}

/**
 * PUT /v1/customers/{id}
 */
export async function updateCustomer(id: number, body: UpdateCustomerBody): Promise<CustomerDetail> {
  const response = await request.put<ApiResponse<CustomerDetail>>(`/v1/customers/${id}`, body)
  return response.data.data
}

/**
 * GET /v1/customer-sources/options —— 需 customer:create
 */
export async function fetchCustomerSourceOptions(): Promise<CustomerSourceOption[]> {
  const response = await request.get<ApiResponse<CustomerSourceOption[]>>('/v1/customer-sources/options')
  return response.data.data ?? []
}

/**
 * GET /v1/customer-sources —— 列表筛选用来源时，有 source:view 可用
 */
export async function fetchCustomerSourcePage(params: {
  page?: number
  size?: number
  active?: boolean
}): Promise<PageData<CustomerSourceOption>> {
  const response = await request.get<ApiResponse<PageData<CustomerSourceOption>>>('/v1/customer-sources', {
    params,
  })
  return response.data.data
}

/**
 * GET /v1/servicers/options —— 需 customer:create
 */
export async function fetchServicerOptions(storeId?: number): Promise<ServicerOption[]> {
  const response = await request.get<ApiResponse<ServicerOption[]>>('/v1/servicers/options', {
    params: storeId == null ? undefined : { storeId },
  })
  return response.data.data ?? []
}

/**
 * GET /v1/customers/{id}/tags —— 顾客已贴标签
 */
export async function fetchCustomerTags(customerId: number): Promise<CustomerTagItem[]> {
  const response = await request.get<ApiResponse<CustomerTagItem[]>>(`/v1/customers/${customerId}/tags`)
  return response.data.data ?? []
}

/**
 * GET /v1/customer-tags/all —— 标签库全量（贴标选择用）
 */
export async function fetchAllCustomerTags(): Promise<CustomerTagItem[]> {
  const response = await request.get<ApiResponse<CustomerTagItem[]>>('/v1/customer-tags/all')
  return response.data.data ?? []
}

/**
 * POST /v1/customers/{id}/tags —— 批量贴标
 */
export async function attachCustomerTags(
  customerId: number,
  tagIds: number[],
): Promise<CustomerTagItem[]> {
  const response = await request.post<ApiResponse<CustomerTagItem[]>>(
    `/v1/customers/${customerId}/tags`,
    { tagIds },
  )
  return response.data.data ?? []
}

/**
 * DELETE /v1/customers/{id}/tags/{tagId}
 */
export async function detachCustomerTag(customerId: number, tagId: number): Promise<void> {
  await request.delete<ApiResponse<null>>(`/v1/customers/${customerId}/tags/${tagId}`)
}

/**
 * GET /v1/customers/{id}/cards —— 剩余卡项分页（有余量且未过期）
 */
export async function fetchCustomerCards(
  customerId: number,
  query: CustomerCardQuery = {},
): Promise<PageData<CustomerCardItem>> {
  const params: Record<string, string | number> = {}
  if (query.itemType != null && query.itemType !== '') {
    params.itemType = query.itemType
  }
  if (query.page != null) {
    params.page = query.page
  }
  if (query.size != null) {
    params.size = query.size
  }
  const response = await request.get<ApiResponse<PageData<CustomerCardItem>>>(
    `/v1/customers/${customerId}/cards`,
    { params },
  )
  return response.data.data
}

/**
 * GET /v1/customers/{id}/sales —— 顾客销售订单分页
 */
export async function fetchCustomerSales(
  customerId: number,
  query: CustomerSaleQuery = {},
): Promise<PageData<CustomerSaleOrder>> {
  const params: Record<string, string | number> = {}
  if (query.employeeId != null && query.employeeId !== '') {
    params.employeeId = query.employeeId
  }
  if (query.employeeName != null && query.employeeName !== '') {
    params.employeeName = query.employeeName
  }
  if (query.page != null) {
    params.page = query.page
  }
  if (query.size != null) {
    params.size = query.size
  }
  const response = await request.get<ApiResponse<PageData<CustomerSaleOrder>>>(
    `/v1/customers/${customerId}/sales`,
    { params },
  )
  return response.data.data
}

/**
 * GET /v1/customers/{id}/payments —— 顾客支付明细分页（一行一笔支付）
 */
export async function fetchCustomerPayments(
  customerId: number,
  query: CustomerPaymentQuery = {},
): Promise<PageData<CustomerPaymentItem>> {
  const params: Record<string, string | number> = {}
  if (query.employeeId != null && query.employeeId !== '') {
    params.employeeId = query.employeeId
  }
  if (query.employeeName != null && query.employeeName !== '') {
    params.employeeName = query.employeeName
  }
  if (query.page != null) {
    params.page = query.page
  }
  if (query.size != null) {
    params.size = query.size
  }
  const response = await request.get<ApiResponse<PageData<CustomerPaymentItem>>>(
    `/v1/customers/${customerId}/payments`,
    { params },
  )
  return response.data.data
}

/**
 * GET /v1/customers/{id}/treats —— 顾客消耗订单分页（一行一单）
 */
export async function fetchCustomerTreats(
  customerId: number,
  query: CustomerTreatOrderQuery = {},
): Promise<PageData<CustomerTreatOrderItem>> {
  const params: Record<string, string | number> = {}
  if (query.keyword != null && query.keyword !== '') {
    params.keyword = query.keyword
  }
  if (query.billStatus != null && query.billStatus !== '') {
    params.billStatus = query.billStatus
  }
  if (query.employeeId != null && query.employeeId !== '') {
    params.employeeId = query.employeeId
  }
  if (query.employeeName != null && query.employeeName !== '') {
    params.employeeName = query.employeeName
  }
  if (query.page != null) {
    params.page = query.page
  }
  if (query.size != null) {
    params.size = query.size
  }
  const response = await request.get<ApiResponse<PageData<CustomerTreatOrderItem>>>(
    `/v1/customers/${customerId}/treats`,
    { params },
  )
  return response.data.data
}
