import request from '@/utils/request'
import type { ApiResponse } from '@/types/response'
import type {
  ConsumableCategoryItem,
  ConsumableCategoryListQuery,
  ConsumableTemplateItem,
  ConsumableTemplateListQuery,
  UpsertConsumableCategoryBody,
  UpsertConsumableTemplateBody,
} from '@/types/consumable'

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

/** ---------- 耗材类别 ---------- */

/** GET /v1/consumable-categories */
export async function fetchConsumableCategoryList(
  query: ConsumableCategoryListQuery = {},
): Promise<ConsumableCategoryItem[]> {
  const response = await request.get<ApiResponse<ConsumableCategoryItem[]>>(
    '/v1/consumable-categories',
    {
      params: buildParams({ onlyActive: query.onlyActive }),
    },
  )
  return response.data.data ?? []
}

/** 启用类别下拉（停用项不出现） */
export async function fetchConsumableCategoryOptions(): Promise<ConsumableCategoryItem[]> {
  return fetchConsumableCategoryList({ onlyActive: true })
}

/** GET /v1/consumable-categories/{id} */
export async function fetchConsumableCategoryDetail(
  id: number,
): Promise<ConsumableCategoryItem> {
  const response = await request.get<ApiResponse<ConsumableCategoryItem>>(
    `/v1/consumable-categories/${id}`,
  )
  return response.data.data
}

/** POST /v1/consumable-categories */
export async function createConsumableCategory(
  body: UpsertConsumableCategoryBody,
): Promise<ConsumableCategoryItem> {
  const response = await request.post<ApiResponse<ConsumableCategoryItem>>(
    '/v1/consumable-categories',
    body,
  )
  return response.data.data
}

/** PUT /v1/consumable-categories/{id} */
export async function updateConsumableCategory(
  id: number,
  body: UpsertConsumableCategoryBody,
): Promise<ConsumableCategoryItem> {
  const response = await request.put<ApiResponse<ConsumableCategoryItem>>(
    `/v1/consumable-categories/${id}`,
    body,
  )
  return response.data.data
}

/** DELETE /v1/consumable-categories/{id} —— 停用，非物理删除 */
export async function deactivateConsumableCategory(
  id: number,
): Promise<ConsumableCategoryItem> {
  const response = await request.delete<ApiResponse<ConsumableCategoryItem>>(
    `/v1/consumable-categories/${id}`,
  )
  return response.data.data
}

/** ---------- 耗材模板 ---------- */

/** GET /v1/consumable-templates（列表不含 products/projectIds） */
export async function fetchConsumableTemplateList(
  query: ConsumableTemplateListQuery = {},
): Promise<ConsumableTemplateItem[]> {
  const response = await request.get<ApiResponse<ConsumableTemplateItem[]>>(
    '/v1/consumable-templates',
    {
      params: buildParams({
        onlyActive: query.onlyActive,
        categoryId: query.categoryId,
      }),
    },
  )
  return response.data.data ?? []
}

/** GET /v1/consumable-templates/{id}（含产品明细与适用项目） */
export async function fetchConsumableTemplateDetail(
  id: number,
): Promise<ConsumableTemplateItem> {
  const response = await request.get<ApiResponse<ConsumableTemplateItem>>(
    `/v1/consumable-templates/${id}`,
  )
  return response.data.data
}

/** POST /v1/consumable-templates */
export async function createConsumableTemplate(
  body: UpsertConsumableTemplateBody,
): Promise<ConsumableTemplateItem> {
  const response = await request.post<ApiResponse<ConsumableTemplateItem>>(
    '/v1/consumable-templates',
    body,
  )
  return response.data.data
}

/** PUT /v1/consumable-templates/{id} */
export async function updateConsumableTemplate(
  id: number,
  body: UpsertConsumableTemplateBody,
): Promise<ConsumableTemplateItem> {
  const response = await request.put<ApiResponse<ConsumableTemplateItem>>(
    `/v1/consumable-templates/${id}`,
    body,
  )
  return response.data.data
}

/** DELETE /v1/consumable-templates/{id} —— 停用，非物理删除 */
export async function deactivateConsumableTemplate(
  id: number,
): Promise<ConsumableTemplateItem> {
  const response = await request.delete<ApiResponse<ConsumableTemplateItem>>(
    `/v1/consumable-templates/${id}`,
  )
  return response.data.data
}
