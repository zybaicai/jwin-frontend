import request from '@/utils/request'
import type { ApiResponse } from '@/types/response'
import { ApiCode } from '@/types/response'
import { ApiBusinessError, ApiHttpError } from '@/utils/api-error'
import type {
  CreateCustomerBody,
  CreateCustomerLevelBody,
  CustomerCardItem,
  CustomerCardQuery,
  CustomerCreateFieldSchema,
  CustomerDetail,
  CustomerLevelItem,
  CustomerProfileField,
  CustomerListItem,
  CustomerListQuery,
  MembershipEntryRule,
  CustomerPaymentItem,
  CustomerPaymentQuery,
  CustomerTreatItem,
  CustomerTreatItemQuery,
  CustomerTreatOrderItem,
  CustomerTreatOrderQuery,
  CustomerExtensionItem,
  CustomerExtensionQuery,
  CustomerFollowUpItem,
  CustomerFollowUpQuery,
  CustomerServiceLogItem,
  CustomerServiceLogQuery,
  CustomerTransferItem,
  CustomerTransferQuery,
  CustomerSaleItem,
  CustomerSaleItemQuery,
  CustomerSaleOrder,
  CustomerSaleQuery,
  CustomerSourceOption,
  CustomerSourceMoveDirection,
  CustomerTagItem,
  OverrideCustomerMemberLevelBody,
  PageData,
  ServicerOption,
  UpdateCustomerBody,
  UpdateCustomerLevelBody,
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
 * 用列表接口按 keyword 定位指定客户（CustomerVo 含介绍人/地址/备注等详情 VO 未返回的字段）。
 * keyword 建议传客户编号或手机号以提高命中率。
 */
export async function findCustomerListItemById(
  customerId: number,
  keyword?: string | null,
): Promise<CustomerListItem | null> {
  const query: CustomerListQuery = {
    page: 1,
    size: 50,
  }
  if (keyword != null && keyword.trim() !== '') {
    query.keyword = keyword.trim()
  }
  const data = await fetchCustomerPage(query)
  const hit = (data.records ?? []).find((item) => item.id === customerId)
  if (hit != null) {
    return hit
  }
  if (query.keyword == null) {
    return null
  }
  // keyword 未命中时再退回无 keyword 翻页查找（本店列表可能较短）
  const fallback = await fetchCustomerPage({ page: 1, size: 100 })
  return (fallback.records ?? []).find((item) => item.id === customerId) ?? null
}

export interface CustomerExportResult {
  blob: Blob
  fileName: string
}

/**
 * GET /v1/customers/export —— XLSX 文件流，权限 customer:list:view。
 * 筛选条件与列表相同；忽略 page/size；最多 10000 条。
 */
export async function exportCustomers(query: CustomerListQuery): Promise<CustomerExportResult> {
  const params = toParams({
    ...query,
    page: undefined,
    size: undefined,
  })
  const response = await request.get<Blob>('/v1/customers/export', {
    params,
    responseType: 'blob',
    timeout: 60000,
  })
  const blob = response.data
  const contentType = String(response.headers['content-type'] ?? blob.type ?? '')
  if (contentType.includes('application/json') || contentType.includes('text/json')) {
    const text = await blob.text()
    let payload: unknown
    try {
      payload = JSON.parse(text) as unknown
    } catch {
      throw new ApiHttpError(0, '导出失败')
    }
    if (
      typeof payload === 'object' &&
      payload !== null &&
      typeof Reflect.get(payload, 'code') === 'number'
    ) {
      const code = Reflect.get(payload, 'code') as number
      if (code !== ApiCode.SUCCESS) {
        throw ApiBusinessError.fromResponse(payload as ApiResponse)
      }
    }
    throw new ApiHttpError(0, '导出失败')
  }
  const disposition = String(response.headers['content-disposition'] ?? '')
  const fileName = parseExportFileName(disposition) ?? defaultExportFileName()
  return { blob, fileName }
}

function defaultExportFileName(): string {
  const d = new Date()
  const y = d.getFullYear()
  const m = String(d.getMonth() + 1).padStart(2, '0')
  const day = String(d.getDate()).padStart(2, '0')
  return `customers-${y}${m}${day}.xlsx`
}

function parseExportFileName(disposition: string): string | null {
  const star = /filename\*\s*=\s*UTF-8''([^;]+)/i.exec(disposition)
  if (star?.[1]) {
    try {
      return decodeURIComponent(star[1].trim().replace(/^["']|["']$/g, ''))
    } catch {
      return star[1].trim()
    }
  }
  const plain = /filename\s*=\s*([^;]+)/i.exec(disposition)
  if (plain?.[1]) {
    return plain[1].trim().replace(/^["']|["']$/g, '')
  }
  return null
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
 * GET /v1/customer-sources/options —— 需 customer:create；仅返回 active=true
 */
export async function fetchCustomerSourceOptions(): Promise<CustomerSourceOption[]> {
  const response = await request.get<ApiResponse<CustomerSourceOption[]>>('/v1/customer-sources/options')
  return response.data.data ?? []
}

/**
 * GET /v1/customer-sources —— 来源分页（管理端）
 * 权限：customer:source:view
 */
export async function fetchCustomerSourcePage(params: {
  keyword?: string
  active?: boolean
  parentId?: number
  page?: number
  size?: number
} = {}): Promise<PageData<CustomerSourceOption>> {
  const query: Record<string, string | number | boolean> = {}
  if (params.keyword != null && params.keyword.trim() !== '') {
    query.keyword = params.keyword.trim()
  }
  if (params.active != null) {
    query.active = params.active
  }
  if (params.parentId != null) {
    query.parentId = params.parentId
  }
  if (params.page != null) {
    query.page = params.page
  }
  if (params.size != null) {
    query.size = params.size
  }
  const response = await request.get<ApiResponse<PageData<CustomerSourceOption>>>('/v1/customer-sources', {
    params: query,
  })
  return response.data.data
}

/**
 * GET /v1/customer-sources/{id} —— 来源详情
 * 权限：customer:source:view
 */
export async function fetchCustomerSourceDetail(id: number): Promise<CustomerSourceOption> {
  const response = await request.get<ApiResponse<CustomerSourceOption>>(
    `/v1/customer-sources/${encodeURIComponent(String(id))}`,
  )
  return response.data.data
}

/**
 * POST /v1/customer-sources —— 新增来源
 * 权限：customer:source:edit
 */
export async function createCustomerSource(body: {
  name: string
  parentId?: number
  sequence?: number
  active?: boolean
}): Promise<CustomerSourceOption> {
  const response = await request.post<ApiResponse<CustomerSourceOption>>('/v1/customer-sources', body)
  return response.data.data
}

/**
 * PUT /v1/customer-sources/{id} —— 修改来源
 * 权限：customer:source:edit
 */
export async function updateCustomerSource(
  id: number,
  body: {
    name: string
    parentId: number
    sequence: number
    active: boolean
  },
): Promise<CustomerSourceOption> {
  const response = await request.put<ApiResponse<CustomerSourceOption>>(
    `/v1/customer-sources/${encodeURIComponent(String(id))}`,
    body,
  )
  return response.data.data
}

/**
 * PUT /v1/customer-sources/{id}/move —— 同级排序（置顶/上移/下移/置底）
 * 权限：customer:source:edit
 */
export async function moveCustomerSource(
  id: number,
  direction: CustomerSourceMoveDirection,
): Promise<void> {
  await request.put<ApiResponse<null>>(
    `/v1/customer-sources/${encodeURIComponent(String(id))}/move`,
    { direction },
  )
}

/**
 * DELETE /v1/customer-sources/{id} —— 删除来源
 * 权限：customer:source:edit
 * 后端拒绝：有子级 / 仍有顾客引用
 */
export async function deleteCustomerSource(id: number): Promise<void> {
  await request.delete<ApiResponse<null>>(
    `/v1/customer-sources/${encodeURIComponent(String(id))}`,
  )
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
 * 权限：customer:list:view
 */
export async function fetchCustomerTags(customerId: number): Promise<CustomerTagItem[]> {
  const response = await request.get<ApiResponse<CustomerTagItem[]>>(`/v1/customers/${customerId}/tags`)
  return response.data.data ?? []
}

/**
 * GET /v1/customer-tags —— 系统标签库分页
 * 权限：customer:tag:view
 */
export async function fetchCustomerTagPage(query: {
  keyword?: string
  page?: number
  size?: number
} = {}): Promise<PageData<CustomerTagItem>> {
  const params: Record<string, string | number> = {}
  if (query.keyword != null && query.keyword.trim() !== '') {
    params.keyword = query.keyword.trim()
  }
  if (query.page != null) {
    params.page = query.page
  }
  if (query.size != null) {
    params.size = query.size
  }
  const response = await request.get<ApiResponse<PageData<CustomerTagItem>>>('/v1/customer-tags', {
    params,
  })
  return response.data.data
}

/**
 * GET /v1/customer-tags/all —— 标签库全量（贴标选择用）
 * 权限：customer:list:view
 */
export async function fetchAllCustomerTags(): Promise<CustomerTagItem[]> {
  const response = await request.get<ApiResponse<CustomerTagItem[]>>('/v1/customer-tags/all')
  return response.data.data ?? []
}

/**
 * GET /v1/customer-tags/{id} —— 系统标签详情
 * 权限：customer:tag:view
 */
export async function fetchCustomerTagDetail(id: number): Promise<CustomerTagItem> {
  const response = await request.get<ApiResponse<CustomerTagItem>>(
    `/v1/customer-tags/${encodeURIComponent(String(id))}`,
  )
  return response.data.data
}

/**
 * POST /v1/customer-tags —— 新增系统标签
 * 权限：customer:tag:edit
 */
export async function createCustomerTag(body: { name: string }): Promise<CustomerTagItem> {
  const response = await request.post<ApiResponse<CustomerTagItem>>('/v1/customer-tags', body)
  return response.data.data
}

/**
 * PUT /v1/customer-tags/{id} —— 修改系统标签
 * 权限：customer:tag:edit
 */
export async function updateCustomerTag(
  id: number,
  body: { name: string },
): Promise<CustomerTagItem> {
  const response = await request.put<ApiResponse<CustomerTagItem>>(
    `/v1/customer-tags/${encodeURIComponent(String(id))}`,
    body,
  )
  return response.data.data
}

/**
 * DELETE /v1/customer-tags/{id} —— 删除系统标签（并解除所有顾客贴标关系）
 * 权限：customer:tag:edit
 */
export async function deleteCustomerTag(id: number): Promise<void> {
  await request.delete<ApiResponse<null>>(`/v1/customer-tags/${encodeURIComponent(String(id))}`)
}

/**
 * POST /v1/customers/{id}/tags —— 批量贴标
 * 权限：customer:edit
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
 * DELETE /v1/customers/{id}/tags/{tagId} —— 仅取消该客户贴标关系
 * 权限：customer:edit
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
 * GET /v1/customers/{id}/sale-items —— 顾客销售明细分页（一行一个销售项目）
 */
export async function fetchCustomerSaleItems(
  customerId: number,
  query: CustomerSaleItemQuery = {},
): Promise<PageData<CustomerSaleItem>> {
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
  const response = await request.get<ApiResponse<PageData<CustomerSaleItem>>>(
    `/v1/customers/${customerId}/sale-items`,
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

/**
 * GET /v1/customers/{id}/treat-items —— 顾客消耗明细分页（一行一个消耗项目）
 */
export async function fetchCustomerTreatItems(
  customerId: number,
  query: CustomerTreatItemQuery = {},
): Promise<PageData<CustomerTreatItem>> {
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
  const response = await request.get<ApiResponse<PageData<CustomerTreatItem>>>(
    `/v1/customers/${customerId}/treat-items`,
    { params },
  )
  return response.data.data
}

/**
 * GET /v1/customers/{id}/transfers —— 顾客卡项转账记录分页（转出或转入）
 */
export async function fetchCustomerTransfers(
  customerId: number,
  query: CustomerTransferQuery = {},
): Promise<PageData<CustomerTransferItem>> {
  const params: Record<string, string | number> = {}
  if (query.keyword != null && query.keyword !== '') {
    params.keyword = query.keyword
  }
  if (query.employeeId != null && query.employeeId !== '') {
    params.employeeId = query.employeeId
  }
  if (query.employeeName != null && query.employeeName !== '') {
    params.employeeName = query.employeeName
  }
  if (query.createdOnFrom != null && query.createdOnFrom !== '') {
    params.createdOnFrom = query.createdOnFrom
  }
  if (query.createdOnTo != null && query.createdOnTo !== '') {
    params.createdOnTo = query.createdOnTo
  }
  if (query.page != null) {
    params.page = query.page
  }
  if (query.size != null) {
    params.size = query.size
  }
  const response = await request.get<ApiResponse<PageData<CustomerTransferItem>>>(
    `/v1/customers/${customerId}/transfers`,
    { params },
  )
  return response.data.data
}

/**
 * GET /v1/customers/{id}/extensions —— 顾客延期记录分页（一行 = 延期单下的一个卡项账户明细）
 */
export async function fetchCustomerExtensions(
  customerId: number,
  query: CustomerExtensionQuery = {},
): Promise<PageData<CustomerExtensionItem>> {
  const params: Record<string, string | number> = {}
  if (query.keyword != null && query.keyword !== '') {
    params.keyword = query.keyword
  }
  if (query.employeeId != null && query.employeeId !== '') {
    params.employeeId = query.employeeId
  }
  if (query.employeeName != null && query.employeeName !== '') {
    params.employeeName = query.employeeName
  }
  if (query.createdOnFrom != null && query.createdOnFrom !== '') {
    params.createdOnFrom = query.createdOnFrom
  }
  if (query.createdOnTo != null && query.createdOnTo !== '') {
    params.createdOnTo = query.createdOnTo
  }
  if (query.page != null) {
    params.page = query.page
  }
  if (query.size != null) {
    params.size = query.size
  }
  const response = await request.get<ApiResponse<PageData<CustomerExtensionItem>>>(
    `/v1/customers/${customerId}/extensions`,
    { params },
  )
  return response.data.data
}

/**
 * GET /v1/customers/{id}/follow-ups —— 顾客跟进记录分页
 */
export async function fetchCustomerFollowUps(
  customerId: number,
  query: CustomerFollowUpQuery = {},
): Promise<PageData<CustomerFollowUpItem>> {
  const params: Record<string, string | number> = {}
  if (query.keyword != null && query.keyword !== '') {
    params.keyword = query.keyword
  }
  if (query.followUpStatusId != null) {
    params.followUpStatusId = query.followUpStatusId
  }
  if (query.followUpMethodId != null) {
    params.followUpMethodId = query.followUpMethodId
  }
  if (query.followUpBy != null && query.followUpBy !== '') {
    params.followUpBy = query.followUpBy
  }
  if (query.plannedOnFrom != null && query.plannedOnFrom !== '') {
    params.plannedOnFrom = query.plannedOnFrom
  }
  if (query.plannedOnTo != null && query.plannedOnTo !== '') {
    params.plannedOnTo = query.plannedOnTo
  }
  if (query.followUpOnFrom != null && query.followUpOnFrom !== '') {
    params.followUpOnFrom = query.followUpOnFrom
  }
  if (query.followUpOnTo != null && query.followUpOnTo !== '') {
    params.followUpOnTo = query.followUpOnTo
  }
  if (query.page != null) {
    params.page = query.page
  }
  if (query.size != null) {
    params.size = query.size
  }
  const response = await request.get<ApiResponse<PageData<CustomerFollowUpItem>>>(
    `/v1/customers/${customerId}/follow-ups`,
    { params },
  )
  return response.data.data
}

/**
 * GET /v1/customers/{id}/service-logs —— 顾客服务（护理）日志分页
 */
export async function fetchCustomerServiceLogs(
  customerId: number,
  query: CustomerServiceLogQuery = {},
): Promise<PageData<CustomerServiceLogItem>> {
  const params: Record<string, string | number> = {}
  if (query.createdOnFrom != null && query.createdOnFrom !== '') {
    params.createdOnFrom = query.createdOnFrom
  }
  if (query.createdOnTo != null && query.createdOnTo !== '') {
    params.createdOnTo = query.createdOnTo
  }
  if (query.page != null) {
    params.page = query.page
  }
  if (query.size != null) {
    params.size = query.size
  }
  const response = await request.get<ApiResponse<PageData<CustomerServiceLogItem>>>(
    `/v1/customers/${customerId}/service-logs`,
    { params },
  )
  return response.data.data
}

/**
 * GET /v1/customer-levels —— 会员等级分页
 * 权限：customer:level:view
 */
export async function fetchCustomerLevelPage(params: {
  keyword?: string
  active?: boolean
  activeOnly?: boolean
  sortBy?: string
  sortOrder?: string
  page?: number
  size?: number
} = {}): Promise<PageData<CustomerLevelItem>> {
  const query: Record<string, string | number | boolean> = {}
  if (params.keyword != null && params.keyword.trim() !== '') {
    query.keyword = params.keyword.trim()
  }
  if (params.active != null) {
    query.active = params.active
  }
  if (params.activeOnly != null) {
    query.activeOnly = params.activeOnly
  }
  if (params.sortBy != null && params.sortBy.trim() !== '') {
    query.sortBy = params.sortBy.trim()
  }
  if (params.sortOrder != null && params.sortOrder.trim() !== '') {
    query.sortOrder = params.sortOrder.trim()
  }
  if (params.page != null) {
    query.page = params.page
  }
  if (params.size != null) {
    query.size = params.size
  }
  const response = await request.get<ApiResponse<PageData<CustomerLevelItem>>>('/v1/customer-levels', {
    params: query,
  })
  return response.data.data
}

/**
 * GET /v1/customer-levels/options —— 启用等级下拉（列表筛选等）
 * 权限：customer:list:view
 */
export async function fetchCustomerLevelOptions(): Promise<CustomerLevelItem[]> {
  const response = await request.get<ApiResponse<CustomerLevelItem[]>>('/v1/customer-levels/options')
  return response.data.data ?? []
}

/**
 * GET /v1/customer-levels/{id} —— 等级详情
 * 权限：customer:level:view
 */
export async function fetchCustomerLevelDetail(id: number): Promise<CustomerLevelItem> {
  const response = await request.get<ApiResponse<CustomerLevelItem>>(
    `/v1/customer-levels/${encodeURIComponent(String(id))}`,
  )
  return response.data.data
}

/**
 * POST /v1/customer-levels —— 新增等级
 * 权限：customer:level:edit
 */
export async function createCustomerLevel(body: CreateCustomerLevelBody): Promise<CustomerLevelItem> {
  const response = await request.post<ApiResponse<CustomerLevelItem>>('/v1/customer-levels', body)
  return response.data.data
}

/**
 * PUT /v1/customer-levels/{id} —— 修改等级
 * 权限：customer:level:edit
 */
export async function updateCustomerLevel(
  id: number,
  body: UpdateCustomerLevelBody,
): Promise<CustomerLevelItem> {
  const response = await request.put<ApiResponse<CustomerLevelItem>>(
    `/v1/customer-levels/${encodeURIComponent(String(id))}`,
    body,
  )
  return response.data.data
}

/**
 * DELETE /v1/customer-levels/{id} —— 删除等级（仍有顾客使用时后端拒绝）
 * 权限：customer:level:edit
 */
export async function deleteCustomerLevel(id: number): Promise<void> {
  await request.delete<ApiResponse<null>>(
    `/v1/customer-levels/${encodeURIComponent(String(id))}`,
  )
}

/**
 * PUT /v1/customers/{id}/member-level —— 管理员覆盖等级 / 锁定
 * 权限：customer:level:override
 */
export async function fetchCustomerProfileSettings(): Promise<CustomerProfileField[]> {
  const response = await request.get<ApiResponse<CustomerProfileField[]>>(
    '/v1/customer-profile-settings/create',
  )
  return response.data.data ?? []
}

export async function saveCustomerProfileSettings(
  fields: Array<{ fieldCode: string; requirement: string }>,
): Promise<CustomerProfileField[]> {
  const response = await request.put<ApiResponse<CustomerProfileField[]>>(
    '/v1/customer-profile-settings/create',
    { fields },
  )
  return response.data.data ?? []
}

export async function fetchCustomerCreateSchema(): Promise<CustomerCreateFieldSchema[]> {
  const response = await request.get<ApiResponse<CustomerCreateFieldSchema[]>>(
    '/v1/customer-form-fields/create-schema',
  )
  return response.data.data ?? []
}

export async function fetchMembershipEntryRule(): Promise<MembershipEntryRule> {
  const response = await request.get<ApiResponse<MembershipEntryRule>>(
    '/v1/customer-membership/entry-rule',
  )
  return response.data.data
}

export async function saveMembershipEntryRule(body: MembershipEntryRule): Promise<MembershipEntryRule> {
  const response = await request.put<ApiResponse<MembershipEntryRule>>(
    '/v1/customer-membership/entry-rule',
    body,
  )
  return response.data.data
}

export async function overrideCustomerMemberLevel(
  customerId: number,
  body: OverrideCustomerMemberLevelBody,
): Promise<void> {
  await request.put<ApiResponse<null>>(
    `/v1/customers/${encodeURIComponent(String(customerId))}/member-level`,
    body,
  )
}
