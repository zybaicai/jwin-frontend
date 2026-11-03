import request from '@/utils/request'
import type { ApiResponse } from '@/types/response'
import type {
  BasicDictionaryItem,
  BasicSettingType,
  SaveBasicDictionaryBody,
} from '@/types/basicSetting'

function buildPath(type: BasicSettingType): string {
  return `/v1/basic-settings/${type}`
}

/**
 * GET /v1/basic-settings/{type} —— 字典列表
 * 权限：system:setting:view
 */
export async function fetchBasicDictionary(
  type: BasicSettingType,
  params?: { keyword?: string | null; active?: boolean | null },
): Promise<BasicDictionaryItem[]> {
  const response = await request.get<ApiResponse<BasicDictionaryItem[]>>(buildPath(type), {
    params: {
      keyword: params?.keyword || undefined,
      active: params?.active === null ? undefined : params?.active,
    },
  })
  return response.data.data ?? []
}

/**
 * POST /v1/basic-settings/{type} —— 新增字典项
 * 权限：system:setting:edit
 */
export async function createBasicDictionary(
  type: BasicSettingType,
  body: SaveBasicDictionaryBody,
): Promise<BasicDictionaryItem> {
  const response = await request.post<ApiResponse<BasicDictionaryItem>>(buildPath(type), body)
  return response.data.data
}

/**
 * PUT /v1/basic-settings/{type}/{id} —— 修改字典项
 * 权限：system:setting:edit
 */
export async function updateBasicDictionary(
  type: BasicSettingType,
  id: number,
  body: SaveBasicDictionaryBody,
): Promise<BasicDictionaryItem> {
  const response = await request.put<ApiResponse<BasicDictionaryItem>>(
    `${buildPath(type)}/${encodeURIComponent(String(id))}`,
    body,
  )
  return response.data.data
}

/**
 * DELETE /v1/basic-settings/{type}/{id} —— 停用字典项
 * 权限：system:setting:edit
 */
export async function deactivateBasicDictionary(
  type: BasicSettingType,
  id: number,
): Promise<BasicDictionaryItem> {
  const response = await request.delete<ApiResponse<BasicDictionaryItem>>(
    `${buildPath(type)}/${encodeURIComponent(String(id))}`,
  )
  return response.data.data
}
