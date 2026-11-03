import { computed, ref, watch } from 'vue'
import { defineStore } from 'pinia'

import { useAuthStore } from '@/stores/auth'
import type { CurrentUserVo } from '@/types/auth'
import type { RoleBrief } from '@/types/user'
import { DEV_MOCK_AUTH } from '@/mock/dev-auth'

/**
 * 前端权限上下文。只读 Auth Store 里的 /me 结果，不请求接口、不推导角色权限。
 * 依赖方向只有 Permission Store → Auth Store，避免循环引用。
 */
export const usePermissionStore = defineStore('permission', () => {
  const authStore = useAuthStore()

  const permissionCodes = ref<string[]>([])
  const roles = ref<RoleBrief[]>([])
  const dataScope = ref<string | null>(null)
  const initialized = ref(false)

  const permissionSet = computed(() => new Set(permissionCodes.value))

  function applyUser(user: CurrentUserVo | null): void {
    if (user == null) {
      permissionCodes.value = []
      roles.value = []
      dataScope.value = null
      return
    }
    permissionCodes.value = [...(user.permissionCodes ?? [])]
    roles.value = (user.roles ?? []).map((role) => ({ id: role.id, name: role.name }))
    dataScope.value = user.dataScope ?? null
  }

  // 未 initialize 前不跟随，避免启动过程中的中间状态覆盖最终 /me 结果。
  watch(
    () => authStore.currentUser,
    (user) => {
      if (!initialized.value) {
        return
      }
      applyUser(user)
    },
  )

  function initialize(): void {
    applyUser(authStore.currentUser)
    initialized.value = true
  }

  function clear(): void {
    applyUser(null)
  }

  function hasPermission(permissionCode: string): boolean {
    // 本地调试旁路：全部放行，便于浏览所有页面。
    if (DEV_MOCK_AUTH) {
      return true
    }
    if (permissionCode === '') {
      return false
    }
    return permissionSet.value.has(permissionCode)
  }

  /** 空列表表示一个都不满足。 */
  function hasAnyPermission(required: readonly string[]): boolean {
    return required.some((code) => hasPermission(code))
  }

  /**
   * 必须全部拥有。
   * 空列表按“没有不满足的条件”处理，返回 true，与 Array.every 一致。
   */
  function hasAllPermissions(required: readonly string[]): boolean {
    return required.every((code) => hasPermission(code))
  }

  return {
    permissionCodes,
    roles,
    dataScope,
    initialized,
    initialize,
    clear,
    hasPermission,
    hasAnyPermission,
    hasAllPermissions,
  }
})
