/**
 * 后端统一响应外壳，对齐 com.yudao.erp.common.api.ApiResult。
 */
export interface ApiResponse<T = unknown> {
  code: number
  message: string
  data: T
  requestId?: string
}

/** 分页结果，对齐后端 PageResult / 前端 PageData */
export interface PageResult<T> {
  total: number
  page: number
  size: number
  records: T[]
}

export const ApiCode = {
  SUCCESS: 0,
  UNAUTHORIZED: 10001,
  FORBIDDEN: 10002,
  STORE_FORBIDDEN: 10003,
  SYSTEM: 50000,
} as const

export type ApiCodeValue = (typeof ApiCode)[keyof typeof ApiCode]
