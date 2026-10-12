import request from '@/utils/request'
import type { ApiResponse } from '@/types/response'
import type {
  CreateSaleOrderHandler,
  CreateSaleOrderRequest,
  PayMethodOption,
  PaySaleOrderRequest,
  SaleOrderDetail,
  SaleOrderPageData,
  SaleOrderPageQuery,
} from '@/types/sale'
import { normalizeSaleOrderDetail } from '@/utils/sale/normalizeSaleOrder'

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
  return normalizeSaleOrderDetail(data)
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
      billId: query.billId,
      billType: query.billType,
      keyword: query.keyword,
      billDateFrom: query.billDateFrom,
      billDateTo: query.billDateTo,
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
 * 可附带 payments 在同一事务内登记收款并完成入账（人工记账，非第三方扣款）。
 */
export async function createSaleOrder(body: CreateSaleOrderRequest): Promise<SaleOrderDetail> {
  const response = await request.post<ApiResponse<SaleOrderDetail>>('/v1/sales/orders', body)
  return normalizeOrder(response.data.data)
}

/**
 * POST /v1/sales/orders/{id}/pay —— 人工登记收款（记账）
 * 权限：sale:order:pay
 * 不对接微信/支付宝等外部支付；成功后后端更新已收/欠款并发放权益。
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
 * PUT /v1/sales/orders/{id}/handlers —— 修改销售经手人
 * 权限：sale:order:edit-handler
 */
export async function updateSaleOrderHandlers(
  id: string,
  handlers: CreateSaleOrderHandler[],
): Promise<SaleOrderDetail> {
  const response = await request.put<ApiResponse<SaleOrderDetail>>(
    `/v1/sales/orders/${encodeURIComponent(id)}/handlers`,
    { handlers },
  )
  return normalizeOrder(response.data.data)
}

/**
 * POST /v1/refunds —— 创建销售退款申请（取消已支付且未消耗订单）
 * 权限：refund:order:create
 */
export async function createSaleRefund(body: {
  sourceOrderId: string
  reason?: string
}): Promise<{ id: string }> {
  const response = await request.post<ApiResponse<{ id: string }>>('/v1/refunds', {
    refundType: 'SALE',
    sourceOrderId: body.sourceOrderId,
    reason: body.reason ?? '取消订单',
    payments: [],
  })
  return response.data.data
}

/**
 * GET /v1/payments/methods —— 支付方式列表
 * 权限：sale:order:view
 */
export async function fetchPayMethods(): Promise<PayMethodOption[]> {
  const response = await request.get<ApiResponse<PayMethodOption[]>>('/v1/payments/methods')
  return response.data.data ?? []
}
