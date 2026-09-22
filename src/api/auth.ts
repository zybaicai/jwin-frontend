import type { CurrentUserVo, LoginRequest, LoginVo, SwitchStoreRequest, SwitchStoreResponse } from '@/types/auth'
import type { ApiResponse } from '@/types/response'
import { ApiBusinessError } from '@/utils/api-error'
import request from '@/utils/request'

function unwrap<T>(payload: ApiResponse<T>, fallbackMessage: string): T {
  if (payload.data == null) {
    throw new ApiBusinessError(payload.code, payload.message || fallbackMessage, payload.requestId)
  }
  return payload.data
}

export async function login(data: LoginRequest): Promise<LoginVo> {
  const response = await request.post<ApiResponse<LoginVo>>('/v1/auth/login', data)
  return unwrap(response.data, '登录失败')
}

export async function getCurrentUser(): Promise<CurrentUserVo> {
  const response = await request.get<ApiResponse<CurrentUserVo>>('/v1/auth/me')
  return unwrap(response.data, '获取当前用户失败')
}

export async function logout(): Promise<void> {
  await request.post<ApiResponse<null>>('/v1/auth/logout')
}

export async function switchStore(storeId: number): Promise<SwitchStoreResponse> {
  const body: SwitchStoreRequest = { storeId }
  const response = await request.post<ApiResponse<SwitchStoreResponse>>('/v1/auth/switch-store', body)
  return unwrap(response.data, '切换门店失败')
}

export const authApi = {
  login,
  getCurrentUser,
  logout,
  switchStore,
}
