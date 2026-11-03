import request from '@/utils/request'
import type { ApiResponse } from '@/types/response'
import type { GoodsScopeVo, ReplaceGoodsScopeBody } from '@/types/goods-scope'

/** GET /v1/projects/{id}/sale-entities */
export async function fetchProjectSaleEntities(projectId: number): Promise<GoodsScopeVo> {
  const response = await request.get<ApiResponse<GoodsScopeVo>>(
    `/v1/projects/${projectId}/sale-entities`,
  )
  return response.data.data
}

/** PUT /v1/projects/{id}/sale-entities —— 全量替换；空列表=全部可用 */
export async function replaceProjectSaleEntities(
  projectId: number,
  body: ReplaceGoodsScopeBody,
): Promise<GoodsScopeVo> {
  const response = await request.put<ApiResponse<GoodsScopeVo>>(
    `/v1/projects/${projectId}/sale-entities`,
    body,
  )
  return response.data.data
}

/** GET /v1/projects/{id}/consume-entities */
export async function fetchProjectConsumeEntities(projectId: number): Promise<GoodsScopeVo> {
  const response = await request.get<ApiResponse<GoodsScopeVo>>(
    `/v1/projects/${projectId}/consume-entities`,
  )
  return response.data.data
}

/** PUT /v1/projects/{id}/consume-entities —— 全量替换；空列表=全部可用 */
export async function replaceProjectConsumeEntities(
  projectId: number,
  body: ReplaceGoodsScopeBody,
): Promise<GoodsScopeVo> {
  const response = await request.put<ApiResponse<GoodsScopeVo>>(
    `/v1/projects/${projectId}/consume-entities`,
    body,
  )
  return response.data.data
}

/** GET /v1/projects/{id}/modify-price-stores —— 项目可改价门店白名单 */
export async function fetchProjectModifyPriceStores(projectId: number): Promise<number[]> {
  const response = await request.get<ApiResponse<number[]>>(
    `/v1/projects/${projectId}/modify-price-stores`,
  )
  return response.data.data ?? []
}

/** PUT /v1/projects/{id}/modify-price-stores —— 全量替换；空列表=不限制 */
export async function replaceProjectModifyPriceStores(
  projectId: number,
  storeIds: number[],
): Promise<number[]> {
  const response = await request.put<ApiResponse<number[]>>(
    `/v1/projects/${projectId}/modify-price-stores`,
    { storeIds },
  )
  return response.data.data ?? []
}

type CardScopeKind = 'general' | 'time' | 'saving' | 'package'

function cardScopeBase(kind: CardScopeKind, id: number): string {
  return `/v1/cards/${kind}/${id}`
}

/** GET /v1/cards/{kind}/{id}/sale-entities */
export async function fetchCardSaleEntities(
  kind: CardScopeKind,
  id: number,
): Promise<GoodsScopeVo> {
  const response = await request.get<ApiResponse<GoodsScopeVo>>(
    `${cardScopeBase(kind, id)}/sale-entities`,
  )
  return response.data.data
}

/** PUT /v1/cards/{kind}/{id}/sale-entities */
export async function replaceCardSaleEntities(
  kind: CardScopeKind,
  id: number,
  body: ReplaceGoodsScopeBody,
): Promise<GoodsScopeVo> {
  const response = await request.put<ApiResponse<GoodsScopeVo>>(
    `${cardScopeBase(kind, id)}/sale-entities`,
    body,
  )
  return response.data.data
}

/**
 * GET /v1/cards/{kind}/{id}/consume-entities
 * 套餐卡无 ConsumeEntity，勿调用。
 */
export async function fetchCardConsumeEntities(
  kind: Exclude<CardScopeKind, 'package'>,
  id: number,
): Promise<GoodsScopeVo> {
  const response = await request.get<ApiResponse<GoodsScopeVo>>(
    `${cardScopeBase(kind, id)}/consume-entities`,
  )
  return response.data.data
}

/** PUT /v1/cards/{kind}/{id}/consume-entities —— 套餐卡无此接口 */
export async function replaceCardConsumeEntities(
  kind: Exclude<CardScopeKind, 'package'>,
  id: number,
  body: ReplaceGoodsScopeBody,
): Promise<GoodsScopeVo> {
  const response = await request.put<ApiResponse<GoodsScopeVo>>(
    `${cardScopeBase(kind, id)}/consume-entities`,
    body,
  )
  return response.data.data
}
