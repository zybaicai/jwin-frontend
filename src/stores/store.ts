import { ref, watch } from 'vue'
import { defineStore } from 'pinia'

import { switchStore as switchStoreRequest } from '@/api/auth'
import { useAuthStore } from '@/stores/auth'
import { usePermissionStore } from '@/stores/permission'
import type { CurrentUserVo, OrgScopeTreeNode, StoreBrief } from '@/types/auth'
import { setToken } from '@/utils/token'

/** 切店成功后通知后续业务清缓存。本阶段没有业务缓存可清。 */
export const STORE_CONTEXT_CHANGED_EVENT = 'store-context-changed'

export interface StoreContextSnapshot {
  currentStoreId: number | null
  currentStoreName: string | null
  availableStoreIds: number[]
  availableStores: StoreBrief[]
  orgScopeTree: OrgScopeTreeNode[]
}

/**
 * 当前门店只认 /me 的 storeId。
 * 展示优先 orgScopeTree / stores 名称，storeIds 仅作兼容与切店校验。
 */
export function resolveStoreContext(user: CurrentUserVo | null): StoreContextSnapshot {
  if (user == null) {
    return {
      currentStoreId: null,
      currentStoreName: null,
      availableStoreIds: [],
      availableStores: [],
      orgScopeTree: [],
    }
  }

  const availableStores =
    user.stores != null && user.stores.length > 0
      ? user.stores.map((item) => ({ id: item.id, name: item.name }))
      : (user.storeIds ?? []).map((id) => ({
          id,
          name:
            id === user.storeId && user.storeName != null && user.storeName !== ''
              ? user.storeName
              : String(id),
        }))

  const availableStoreIds =
    user.storeIds != null && user.storeIds.length > 0
      ? [...user.storeIds]
      : availableStores.map((item) => item.id)

  return {
    currentStoreId: user.storeId ?? null,
    currentStoreName: user.storeName ?? null,
    availableStoreIds,
    availableStores,
    orgScopeTree: [...(user.orgScopeTree ?? [])],
  }
}

export class StoreSwitchError extends Error {
  constructor(message: string) {
    super(message)
    this.name = 'StoreSwitchError'
  }
}

/**
 * 当前门店上下文。只封装 Auth Store 的 /me 门店字段，不负责界面和路由。
 * 依赖方向：Store Store → Auth Store、Permission Store。二者都不引用本 Store。
 */
export const useStoreStore = defineStore('storeContext', () => {
  const authStore = useAuthStore()
  const permissionStore = usePermissionStore()

  const currentStoreId = ref<number | null>(null)
  const currentStoreName = ref<string | null>(null)
  const availableStoreIds = ref<number[]>([])
  const availableStores = ref<StoreBrief[]>([])
  const orgScopeTree = ref<OrgScopeTreeNode[]>([])
  const initialized = ref(false)
  const switching = ref(false)

  function applyUser(user: CurrentUserVo | null): void {
    const next = resolveStoreContext(user)
    currentStoreId.value = next.currentStoreId
    currentStoreName.value = next.currentStoreName
    availableStoreIds.value = next.availableStoreIds
    availableStores.value = next.availableStores
    orgScopeTree.value = next.orgScopeTree
  }

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

  async function switchStore(targetStoreId: number): Promise<void> {
    if (targetStoreId === currentStoreId.value) {
      return
    }
    if (switching.value) {
      throw new StoreSwitchError('正在切换门店，请稍后再试')
    }
    if (!availableStoreIds.value.includes(targetStoreId)) {
      throw new StoreSwitchError('无权切换到该门店')
    }

    const previousStoreId = currentStoreId.value
    switching.value = true
    let tokenReplaced = false
    try {
      const loginVo = await switchStoreRequest(targetStoreId)
      if (loginVo.token === '') {
        throw new StoreSwitchError('切换门店未返回 Token')
      }
      // 后端已作废旧 Token。必须先写入新 Token，/me 才会带上新门店。
      setToken(loginVo.token)
      authStore.token = loginVo.token
      tokenReplaced = true
      await authStore.fetchCurrentUser()
      permissionStore.initialize()
      applyUser(authStore.currentUser)
      if (authStore.currentUser?.storeId !== previousStoreId) {
        window.dispatchEvent(new CustomEvent(STORE_CONTEXT_CHANGED_EVENT))
      }
    } catch (error) {
      // switch-store 失败时还没换 Token，原用户和原门店保持不变。
      // 10001 由请求层清 Token，currentUser 变空后上面的 watch 会清掉门店上下文。
      // 新 Token 已保存但 /me 失败时，不能写回已作废的旧 Token。
      if (!tokenReplaced) {
        applyUser(authStore.currentUser)
      }
      throw error
    } finally {
      switching.value = false
    }
  }

  return {
    currentStoreId,
    currentStoreName,
    availableStoreIds,
    availableStores,
    orgScopeTree,
    initialized,
    switching,
    initialize,
    clear,
    switchStore,
  }
})
