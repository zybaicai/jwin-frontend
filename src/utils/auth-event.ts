export const AUTH_EXPIRED_EVENT = 'auth-expired'

let authExpiredHandled = false

/**
 * Token 失效周期内只广播一次，避免并发请求重复通知。
 */
export function emitAuthExpired(): void {
  if (authExpiredHandled) {
    return
  }
  authExpiredHandled = true
  window.dispatchEvent(new CustomEvent(AUTH_EXPIRED_EVENT))
}

/**
 * 新 Token 写入后重置，允许下一轮失效再通知。
 */
export function resetAuthExpiredState(): void {
  authExpiredHandled = false
}

let authExpiredListenerBound = false

/**
 * 全局只注册一次，避免 Store / App 重复监听导致多次跳转。
 */
export function onAuthExpiredOnce(handler: () => void): void {
  if (authExpiredListenerBound) {
    return
  }
  authExpiredListenerBound = true
  window.addEventListener(AUTH_EXPIRED_EVENT, handler)
}
