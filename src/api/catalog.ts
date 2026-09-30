import request from '@/utils/request'
import type { ApiResponse } from '@/types/response'
import type { GoodsItem, GoodsSearchQuery } from '@/types/catalog'

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
 * GET /v1/goods —— 可售目录检索
 * 权限：catalog:view
 */
export async function fetchGoodsList(query: GoodsSearchQuery = {}): Promise<GoodsItem[]> {
  const response = await request.get<ApiResponse<GoodsItem[]>>('/v1/goods', {
    params: buildParams({
      itemType: query.itemType,
      keyword: query.keyword,
      saleChannelId: query.saleChannelId,
    }),
  })
  return response.data.data ?? []
}

/**
 * GET /v1/goods/{itemType}/{itemId} —— 可售目录详情
 * 权限：catalog:view
 */
export async function fetchGoodsDetail(itemType: string, itemId: number): Promise<GoodsItem> {
  const response = await request.get<ApiResponse<GoodsItem>>(
    `/v1/goods/${encodeURIComponent(itemType)}/${encodeURIComponent(String(itemId))}`,
  )
  return response.data.data
}
