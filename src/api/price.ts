import request from '@/utils/request'
import type { ApiResponse } from '@/types/response'
import type {
  PriceByChannelsQuery,
  PriceChangeCheckResult,
  PriceQuote,
  PriceQuoteQuery,
  ProjectChannelPriceItem,
  UpsertProjectChannelPriceBody,
  ValidatePriceChangeRequest,
} from '@/types/price'

/**
 * GET /v1/prices/by-channels —— 各销售渠道报价列表
 * 权限：price:quote
 */
export async function fetchPricesByChannels(query: PriceByChannelsQuery): Promise<PriceQuote[]> {
  const response = await request.get<ApiResponse<PriceQuote[]>>('/v1/prices/by-channels', {
    params: {
      storeId: query.storeId,
      itemType: query.itemType,
      itemId: query.itemId,
    },
  })
  return response.data.data ?? []
}

/**
 * GET /v1/prices/quote —— 选定渠道后报价
 * 权限：price:quote
 * 注意：当前后端无 billDate 参数，补单预览业务日≠今天时报价可能不准（待甲方确认，勿臆造参数）。
 */
export async function fetchPriceQuote(query: PriceQuoteQuery): Promise<PriceQuote> {
  const response = await request.get<ApiResponse<PriceQuote>>('/v1/prices/quote', {
    params: {
      storeId: query.storeId,
      itemType: query.itemType,
      itemId: query.itemId,
      saleChannelId: query.saleChannelId,
    },
  })
  return response.data.data
}

/**
 * POST /v1/prices/change/validate —— 临时改价预检
 * 权限：price:change
 */
export async function validatePriceChange(
  body: ValidatePriceChangeRequest,
): Promise<PriceChangeCheckResult> {
  const response = await request.post<ApiResponse<PriceChangeCheckResult>>(
    '/v1/prices/change/validate',
    body,
  )
  return response.data.data
}

/** ---------- 项目渠道总部价（管理端） ---------- */

/** GET /v1/projects/{id}/channel-prices —— 权限 project:view */
export async function fetchProjectChannelPrices(
  projectId: number,
): Promise<ProjectChannelPriceItem[]> {
  const response = await request.get<ApiResponse<ProjectChannelPriceItem[]>>(
    `/v1/projects/${projectId}/channel-prices`,
  )
  return response.data.data ?? []
}

/** POST /v1/projects/{id}/channel-prices —— 须 project:edit + price:channel:edit */
export async function createProjectChannelPrice(
  projectId: number,
  body: UpsertProjectChannelPriceBody,
): Promise<ProjectChannelPriceItem> {
  const response = await request.post<ApiResponse<ProjectChannelPriceItem>>(
    `/v1/projects/${projectId}/channel-prices`,
    body,
  )
  return response.data.data
}

/** PUT /v1/projects/{id}/channel-prices/{saleChannelId} */
export async function updateProjectChannelPrice(
  projectId: number,
  saleChannelId: number,
  body: UpsertProjectChannelPriceBody,
): Promise<ProjectChannelPriceItem> {
  const response = await request.put<ApiResponse<ProjectChannelPriceItem>>(
    `/v1/projects/${projectId}/channel-prices/${saleChannelId}`,
    body,
  )
  return response.data.data
}

/** DELETE /v1/projects/{id}/channel-prices/{saleChannelId} —— 停用 */
export async function deactivateProjectChannelPrice(
  projectId: number,
  saleChannelId: number,
): Promise<ProjectChannelPriceItem> {
  const response = await request.delete<ApiResponse<ProjectChannelPriceItem>>(
    `/v1/projects/${projectId}/channel-prices/${saleChannelId}`,
  )
  return response.data.data
}
