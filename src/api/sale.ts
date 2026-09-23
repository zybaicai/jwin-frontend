import request from '@/utils/request'
import type { ApiResponse } from '@/types/response'
import type { SaleOrderDetail } from '@/types/sale'

/**
 * GET /v1/sales/orders/{id} —— 销售订单详情（含明细与支付渠道）
 * 权限：sale:order:view
 */
export async function fetchSaleOrderDetail(id: string): Promise<SaleOrderDetail> {
  const response = await request.get<ApiResponse<SaleOrderDetail>>(`/v1/sales/orders/${encodeURIComponent(id)}`)
  const data = response.data.data
  return {
    ...data,
    items: data.items ?? [],
    payments: data.payments ?? [],
  }
}
