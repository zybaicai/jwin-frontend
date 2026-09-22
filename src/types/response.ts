/**
 * 后端统一响应外壳，对齐 com.yudao.erp.common.api.ApiResult。
 */
export interface ApiResponse<T = unknown> {
  code: number
  message: string
  data: T
  requestId?: string
}

export const ApiCode = {
  SUCCESS: 0,
  UNAUTHORIZED: 10001,
  FORBIDDEN: 10002,
  STORE_FORBIDDEN: 10003,
  SYSTEM: 50000,
} as const

export type ApiCodeValue = (typeof ApiCode)[keyof typeof ApiCode]
