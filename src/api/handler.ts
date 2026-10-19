import request from '@/utils/request'
import type { ApiResponse } from '@/types/response'
import type {
  HandlerCandidateResult,
  HandlerCandidatesQuery,
  HandlerReadinessMode,
  HandlerReadinessResult,
} from '@/types/handler'

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
 * GET /v1/handler-candidates —— 开单可选经手人
 * 权限（OR）：handler:candidates:view | sale:order:create | treat:order:create
 */
export async function fetchHandlerCandidates(
  query: HandlerCandidatesQuery,
): Promise<HandlerCandidateResult> {
  const response = await request.get<ApiResponse<HandlerCandidateResult>>(
    '/v1/handler-candidates',
    {
      params: buildParams({
        bizType: query.bizType,
        storeId: query.storeId,
        keyword: query.keyword,
      }),
    },
  )
  const data = response.data.data
  return {
    ...data,
    allowedJobTypeIds: data.allowedJobTypeIds ?? [],
    employees: data.employees ?? [],
  }
}

/**
 * GET /v1/handler-readiness —— 开单/消耗前经手人角色就绪检查
 */
export async function fetchHandlerReadiness(query: {
  storeId?: number | null
  mode?: HandlerReadinessMode | null
}): Promise<HandlerReadinessResult> {
  const response = await request.get<ApiResponse<HandlerReadinessResult>>(
    '/v1/handler-readiness',
    {
      params: buildParams({
        storeId: query.storeId,
        mode: query.mode,
      }),
    },
  )
  const data = response.data.data
  return {
    ...data,
    missing: data.missing ?? [],
    ready: Boolean(data.ready),
  }
}
