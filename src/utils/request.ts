import axios, { type AxiosResponse, type InternalAxiosRequestConfig } from 'axios'

import { ApiCode, type ApiResponse } from '@/types/response'
import { ApiBusinessError, ApiHttpError } from '@/utils/api-error'
import { emitAuthExpired } from '@/utils/auth-event'
import { getToken, removeToken } from '@/utils/token'

const request = axios.create({
  baseURL: import.meta.env.VITE_API_BASE_URL,
  timeout: 15000,
})

function isApiResponse(value: unknown): value is ApiResponse {
  if (typeof value !== 'object' || value === null) {
    return false
  }
  return typeof Reflect.get(value, 'code') === 'number'
}

function rejectBusiness(payload: ApiResponse): never {
  if (payload.code === ApiCode.UNAUTHORIZED) {
    removeToken()
    emitAuthExpired()
  }
  throw ApiBusinessError.fromResponse(payload)
}

function applyAuthHeader(config: InternalAxiosRequestConfig): InternalAxiosRequestConfig {
  const url = config.url ?? ''
  // 调用方若直接传 /api/v1/...，避免与 baseURL=/api 叠成 /api/api/v1
  if (url.startsWith('/api/')) {
    config.baseURL = ''
  }

  const token = getToken()
  if (token) {
    config.headers.Authorization = `Bearer ${token}`
  }
  return config
}

function handleSuccess(response: AxiosResponse): AxiosResponse {
  const payload = response.data
  if (!isApiResponse(payload) || payload.code === ApiCode.SUCCESS) {
    return response
  }
  rejectBusiness(payload)
}

function handleFailure(error: unknown): never {
  if (axios.isAxiosError(error)) {
    if (error.response) {
      const payload = error.response.data
      if (isApiResponse(payload) && payload.code !== ApiCode.SUCCESS) {
        rejectBusiness(payload)
      }
      const status = error.response.status
      throw new ApiHttpError(status, httpMessage(status, error.message))
    }
    if (error.code === 'ECONNABORTED') {
      throw new ApiHttpError(0, '请求超时')
    }
    throw new ApiHttpError(0, '网络异常')
  }
  throw error
}

function httpMessage(status: number, fallback: string): string {
  if (status === 500 || status === 502 || status === 503) {
    return '服务暂不可用'
  }
  return fallback || '请求失败'
}

request.interceptors.request.use(applyAuthHeader)

request.interceptors.response.use(handleSuccess, handleFailure)

export default request
