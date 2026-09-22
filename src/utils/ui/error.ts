import { ApiCode } from '@/types/response'
import { ApiBusinessError, ApiHttpError } from '@/utils/api-error'
import { StoreSwitchError } from '@/stores/store'
import { uiMessage } from '@/utils/ui/message'

const NETWORK_MESSAGE = '网络异常，请检查网络连接'
const TIMEOUT_MESSAGE = '请求超时，请稍后重试'
const UNAVAILABLE_MESSAGE = '系统暂时不可用，请稍后重试'
const FORBIDDEN_MESSAGE = '暂无权限执行该操作'
const STORE_FORBIDDEN_MESSAGE = '暂无该门店权限'
const FALLBACK_MESSAGE = '操作失败，请稍后重试'

export function getUserFriendlyErrorMessage(error: unknown): string {
  if (error instanceof StoreSwitchError) {
    return error.message || FALLBACK_MESSAGE
  }
  if (error instanceof ApiBusinessError) {
    if (error.code === ApiCode.FORBIDDEN) {
      return FORBIDDEN_MESSAGE
    }
    if (error.code === ApiCode.STORE_FORBIDDEN) {
      return STORE_FORBIDDEN_MESSAGE
    }
    if (error.code === ApiCode.SYSTEM) {
      return UNAVAILABLE_MESSAGE
    }
    if (error.code === ApiCode.UNAUTHORIZED) {
      return FALLBACK_MESSAGE
    }
    return FALLBACK_MESSAGE
  }
  if (error instanceof ApiHttpError) {
    if (error.message === '请求超时') {
      return TIMEOUT_MESSAGE
    }
    if (error.status === 0) {
      return NETWORK_MESSAGE
    }
    if (error.status === 500 || error.status === 502 || error.status === 503) {
      return UNAVAILABLE_MESSAGE
    }
    return FALLBACK_MESSAGE
  }
  return FALLBACK_MESSAGE
}

/**
 * 页面层展示错误。10001 已由 auth-expired 处理，这里不再提示、也不跳转。
 */
export function notifyError(error: unknown): void {
  if (error instanceof ApiBusinessError && error.code === ApiCode.UNAUTHORIZED) {
    return
  }
  uiMessage.error(getUserFriendlyErrorMessage(error))
}
