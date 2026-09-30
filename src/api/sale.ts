import request from '@/utils/request'
import type { ApiResponse } from '@/types/response'
import type {
  CreateSaleOrderRequest,
  PayMethodOption,
  PaySaleOrderRequest,
  SaleOrderDetail,
  SaleOrderPageData,
  SaleOrderPageQuery,
} from '@/types/sale'

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

function normalizeOrder(data: SaleOrderDetail): SaleOrderDetail {
  return {
    ...data,
    items: data.items ?? [],
    payments: data.payments ?? [],
  }
}

/**
 * GET /v1/sales/orders/{id} —— 销售订单详情（含明细与支付渠道）
 * 权限：sale:order:view
 */
export async function fetchSaleOrderDetail(id: string): Promise<SaleOrderDetail> {
  const response = await request.get<ApiResponse<SaleOrderDetail>>(
    `/v1/sales/orders/${encodeURIComponent(id)}`,
  )
  return normalizeOrder(response.data.data)
}

/**
 * GET /v1/sales/orders —— 销售订单分页（当前登录门店）
 * 权限：sale:order:view
 */
export async function fetchSaleOrderPage(
  query: SaleOrderPageQuery = {},
): Promise<SaleOrderPageData> {
  const response = await request.get<ApiResponse<SaleOrderPageData>>('/v1/sales/orders', {
    params: buildParams({
      customerId: query.customerId,
      status: query.status,
      page: query.page,
      size: query.size,
    }),
  })
  const data = response.data.data
  return {
    ...data,
    records: (data.records ?? []).map(normalizeOrder),
  }
}

/**
 * POST /v1/sales/orders —— 创建销售订单
 * 权限：sale:order:create（补单另需 sale:order:backdate）
 * 本阶段仅封装 API，不在收银台提交完整收银。
 */
export async function createSaleOrder(body: CreateSaleOrderRequest): Promise<SaleOrderDetail> {
  const response = await request.post<ApiResponse<SaleOrderDetail>>('/v1/sales/orders', body)
  return normalizeOrder(response.data.data)
}

/**
 * POST /v1/sales/orders/{id}/pay —— 补记收款
 * 权限：sale:order:pay
 */
export async function paySaleOrder(
  id: string,
  body: PaySaleOrderRequest,
): Promise<SaleOrderDetail> {
  const response = await request.post<ApiResponse<SaleOrderDetail>>(
    `/v1/sales/orders/${encodeURIComponent(id)}/pay`,
    body,
  )
  return normalizeOrder(response.data.data)
}

/**
 * POST /v1/sales/orders/{id}/close —— 关闭未支付订单
 * 权限：sale:order:close
 */
export async function closeSaleOrder(id: string): Promise<SaleOrderDetail> {
  const response = await request.post<ApiResponse<SaleOrderDetail>>(
    `/v1/sales/orders/${encodeURIComponent(id)}/close`,
  )
  return normalizeOrder(response.data.data)
}

/**
 * GET /v1/payments/methods —— 支付方式列表
 * 权限：sale:order:view
 */
export async function fetchPayMethods(): Promise<PayMethodOption[]> {
  const response = await request.get<ApiResponse<PayMethodOption[]>>('/v1/payments/methods')
  return response.data.data ?? []
}
