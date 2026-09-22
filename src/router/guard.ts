import type { Router } from 'vue-router'

import { useAuthStore } from '@/stores/auth'
import { usePermissionStore } from '@/stores/permission'
import { useStoreStore } from '@/stores/store'

function safeRedirect(value: unknown): string {
  if (typeof value !== 'string' || !value.startsWith('/') || value.startsWith('//')) {
    return '/'
  }
  if (value.startsWith('/auth-init-error')) {
    return '/'
  }
  return value
}

/**
 * 只做认证态路由保护。
 * 初始化成功后才放行受保护页面；失败去重试页，不删 Token，也不当成未登录。
 * 同一次初始化的多个导航共用一个 Promise，不重复 GET /me。
 */
export function setupRouterGuard(router: Router): void {
  router.beforeEach(async (to) => {
    const authStore = useAuthStore()
    const permissionStore = usePermissionStore()
    const storeStore = useStoreStore()

    // 失败态不在每次导航里重跑 /me，只由失败页的重试按钮再次 initialize。
    if (authStore.initStatus !== 'failed') {
      await authStore.initialize()
    }

    if (authStore.initStatus === 'failed') {
      if (to.name === 'auth-init-error') {
        return true
      }
      const redirect = safeRedirect(to.fullPath)
      return { name: 'auth-init-error', query: { redirect } }
    }

    if (!permissionStore.initialized) {
      permissionStore.initialize()
    }
    if (!storeStore.initialized) {
      storeStore.initialize()
    }

    if (to.name === 'auth-init-error') {
      if (authStore.isAuthenticated) {
        return safeRedirect(to.query.redirect)
      }
      return { name: 'login' }
    }

    if (to.name === 'login' && authStore.isAuthenticated) {
      return { name: 'home' }
    }

    if (to.meta.requiresAuth === true && !authStore.isAuthenticated) {
      return { name: 'login' }
    }

    return true
  })
}
