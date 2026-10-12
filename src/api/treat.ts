import request from '@/utils/request'
import type { ApiResponse } from '@/types/response'
import type { PageData } from '@/types/customer'
import type {
  CreateTreatOrderHandler,
  CreateTreatOrderRequest,
  CustomerAvailableAssets,
  TreatConfig,
  TreatOrderDetail,
  TreatOrderPageQuery,
} from '@/types/treat'

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

function normalizeAssets(data: CustomerAvailableAssets | null | undefined): CustomerAvailableAssets {
  return {
    projects: data?.projects ?? [],
    products: data?.products ?? [],
    saving: data?.saving ?? [],
    packageCards: data?.packageCards ?? [],
    generalCards: data?.generalCards ?? [],
    timeCards: data?.timeCards ?? [],
  }
}

function normalizeOrder(data: TreatOrderDetail): TreatOrderDetail {
  return {
    ...data,
    items: data.items ?? [],
    handlers: data.handlers ?? [],
    signatures: data.signatures ?? [],
    consumables: data.consumables ?? [],
  }
}

/**
 * GET /v1/treat/customers/{customerId}/available-assets
 * 权限：treat:order:view
 */
export async function fetchCustomerAvailableAssets(
  customerId: number,
): Promise<CustomerAvailableAssets> {
  const response = await request.get<ApiResponse<CustomerAvailableAssets>>(
    `/v1/treat/customers/${customerId}/available-assets`,
  )
  return normalizeAssets(response.data.data)
}

/**
 * GET /v1/treat/config —— 耗卡总部配置（签字要求等）
 * 权限：treat:order:view
 */
export async function fetchTreatConfig(): Promise<TreatConfig> {
  const response = await request.get<ApiResponse<TreatConfig>>('/v1/treat/config')
  const data = response.data.data
  return {
    autoDeductConsumable: data?.autoDeductConsumable !== false,
    requireCustomerSign: data?.requireCustomerSign === true,
  }
}

/**
 * POST /v1/treat/orders —— 创建消耗单（开单即扣减权益并完成）
 * 权限：treat:order:create（补单另需 treat:order:backdate）
 */
export async function createTreatOrder(body: CreateTreatOrderRequest): Promise<TreatOrderDetail> {
  const response = await request.post<ApiResponse<TreatOrderDetail>>('/v1/treat/orders', body)
  return normalizeOrder(response.data.data)
}

/**
 * GET /v1/treat/orders —— 消耗订单分页
 * 权限：treat:order:view
 */
export async function fetchTreatOrderPage(
  query: TreatOrderPageQuery = {},
): Promise<PageData<TreatOrderDetail>> {
  const response = await request.get<ApiResponse<PageData<TreatOrderDetail>>>('/v1/treat/orders', {
    params: buildParams({
      keyword: query.keyword,
      handlerEmployeeId: query.handlerEmployeeId,
      status: query.status,
      billId: query.billId,
      billType: query.billType,
      billDateFrom: query.billDateFrom,
      billDateTo: query.billDateTo,
      page: query.page ?? 1,
      size: query.size ?? 20,
    }),
  })
  const data = response.data.data
  return {
    ...data,
    records: (data?.records ?? []).map(normalizeOrder),
  }
}

/**
 * GET /v1/treat/orders/{id} —— 消耗单详情
 * 权限：treat:order:view
 */
export async function fetchTreatOrderDetail(id: string): Promise<TreatOrderDetail> {
  const response = await request.get<ApiResponse<TreatOrderDetail>>(
    `/v1/treat/orders/${encodeURIComponent(id)}`,
  )
  return normalizeOrder(response.data.data)
}

/**
 * POST /v1/treat/orders/{id}/cancel —— 取消消耗单（本月误操作；不走退款）
 * 权限：treat:order:cancel
 */
export async function cancelTreatOrder(
  id: string,
  remark?: string | null,
): Promise<TreatOrderDetail> {
  const response = await request.post<ApiResponse<TreatOrderDetail>>(
    `/v1/treat/orders/${encodeURIComponent(id)}/cancel`,
    null,
    {
      params: buildParams({ remark }),
    },
  )
  return normalizeOrder(response.data.data)
}

/**
 * PUT /v1/treat/orders/{id}/handlers —— 修改消耗经手人（不涉及提成计算）
 * 权限：treat:order:edit-handler
 */
export async function updateTreatOrderHandlers(
  id: string,
  handlers: CreateTreatOrderHandler[],
): Promise<TreatOrderDetail> {
  const response = await request.put<ApiResponse<TreatOrderDetail>>(
    `/v1/treat/orders/${encodeURIComponent(id)}/handlers`,
    { handlers },
  )
  return normalizeOrder(response.data.data)
}
