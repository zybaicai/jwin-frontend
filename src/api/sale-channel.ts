import request from '@/utils/request'
import type { ApiResponse } from '@/types/response'
import type { SaleChannelOption } from '@/types/sale-channel'

/**
 * GET /v1/sale-channels/options —— 收银可选有效叶子销售渠道
 * 权限：sale-channel:view
 */
export async function fetchSaleChannelOptions(): Promise<SaleChannelOption[]> {
  const response = await request.get<ApiResponse<SaleChannelOption[]>>('/v1/sale-channels/options')
  return response.data.data ?? []
}
