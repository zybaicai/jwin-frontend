import type { ApiResponse } from '@/types/response'

/**
 * 后端业务异常（HTTP 多为 200，以 body.code 为准）。
 */
export class ApiBusinessError extends Error {
  readonly code: number
  readonly requestId?: string
  readonly data?: unknown

  constructor(code: number, message: string, requestId?: string, data?: unknown) {
    super(message)
    this.name = 'ApiBusinessError'
    this.code = code
    this.requestId = requestId
    this.data = data
  }

  static fromResponse(payload: ApiResponse): ApiBusinessError {
    return new ApiBusinessError(
      payload.code,
      payload.message || '请求失败',
      payload.requestId,
      payload.data,
    )
  }
}

/**
 * HTTP / 网络层异常。不是 ERP 鉴权的主要判断依据。
 */
export class ApiHttpError extends Error {
  readonly status: number
  readonly requestId?: string

  constructor(status: number, message: string, requestId?: string) {
    super(message)
    this.name = 'ApiHttpError'
    this.status = status
    this.requestId = requestId
  }
}
