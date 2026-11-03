import request from '@/utils/request'
import type { ApiResponse } from '@/types/response'
import type { PageData } from '@/types/customer'
import type { StoreHandlerItem, StoreHandlerMoveDirection } from '@/types/store-handler'

/**
 * GET /v1/handlers —— 经手人分页（按 category 区分数据集）
 * 权限：handler:manage:view
 */
export async function fetchStoreHandlerPage(params: {
  category: string
  keyword?: string
  orgEntityId?: number
  active?: boolean
  page?: number
  size?: number
}): Promise<PageData<StoreHandlerItem>> {
  const query: Record<string, string | number | boolean> = {
    category: params.category,
  }
  if (params.keyword != null && params.keyword.trim() !== '') {
    query.keyword = params.keyword.trim()
  }
  if (params.orgEntityId != null) {
    query.orgEntityId = params.orgEntityId
  }
  if (params.active != null) {
    query.active = params.active
  }
  if (params.page != null) {
    query.page = params.page
  }
  if (params.size != null) {
    query.size = params.size
  }
  const response = await request.get<ApiResponse<PageData<StoreHandlerItem>>>('/v1/handlers', {
    params: query,
  })
  return response.data.data
}

/**
 * POST /v1/handlers —— 新增经手人
 * 权限：handler:manage:edit
 */
export async function createStoreHandler(body: {
  name: string
  category: string
  orgEntityId?: number | null
  jobTypeIds?: number[]
  active?: boolean
}): Promise<StoreHandlerItem> {
  const response = await request.post<ApiResponse<StoreHandlerItem>>('/v1/handlers', body)
  return response.data.data
}

/**
 * PUT /v1/handlers/{id} —— 修改经手人
 * 权限：handler:manage:edit
 */
export async function updateStoreHandler(
  id: number,
  body: {
    name: string
    orgEntityId?: number | null
    jobTypeIds?: number[]
    active?: boolean
  },
): Promise<StoreHandlerItem> {
  const response = await request.put<ApiResponse<StoreHandlerItem>>(
    `/v1/handlers/${encodeURIComponent(String(id))}`,
    body,
  )
  return response.data.data
}

/**
 * PUT /v1/handlers/{id}/move —— 同分类内移动排序
 * 权限：handler:manage:edit
 */
export async function moveStoreHandler(
  id: number,
  direction: StoreHandlerMoveDirection,
): Promise<void> {
  await request.put<ApiResponse<void>>(
    `/v1/handlers/${encodeURIComponent(String(id))}/move`,
    { direction },
  )
}
