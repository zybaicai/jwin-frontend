import { defineStore } from 'pinia'
import { computed, ref } from 'vue'

import { getCurrentUser, login as loginRequest, logout as logoutRequest } from '@/api/auth'
import type {
  CurrentUserVo,
  LoginRequest,
  OrgEntityBrief,
  OrgScopeTreeNode,
  StoreBrief,
} from '@/types/auth'
import type { EmployeeInfo } from '@/types/user'
import { ApiCode } from '@/types/response'
import { ApiBusinessError } from '@/utils/api-error'
import { getToken, removeToken, setToken } from '@/utils/token'
import { DEV_MOCK_AUTH, DEV_MOCK_TOKEN, createMockCurrentUser } from '@/mock/dev-auth'

export type AuthInitStatus = 'idle' | 'initializing' | 'success' | 'failed'

function normalizeOrgEntities(raw: OrgEntityBrief[] | undefined): OrgEntityBrief[] {
  if (raw == null) {
    return []
  }
  return raw.map((item) => ({
    id: item.id,
    name: item.name ?? String(item.id),
    store: Boolean(item.store),
    parentId: item.parentId ?? null,
  }))
}

function normalizeOrgScopeTree(raw: OrgScopeTreeNode[] | undefined): OrgScopeTreeNode[] {
  if (raw == null) {
    return []
  }
  return raw.map((node) => ({
    id: node.id,
    name: node.name ?? String(node.id),
    parentId: node.parentId ?? null,
    store: Boolean(node.store),
    sequence: node.sequence ?? null,
    children: normalizeOrgScopeTree(node.children),
  }))
}

function normalizeStores(raw: StoreBrief[] | undefined): StoreBrief[] {
  if (raw == null) {
    return []
  }
  return raw.map((item) => ({
    id: item.id,
    name: item.name ?? String(item.id),
  }))
}

function normalizeCurrentUser(raw: CurrentUserVo): CurrentUserVo {
  const stores = normalizeStores(raw.stores)
  const storeIds =
    raw.storeIds != null && raw.storeIds.length > 0
      ? [...raw.storeIds]
      : stores.map((item) => item.id)
  return {
    employeeId: raw.employeeId,
    employeeName: raw.employeeName,
    jobId: raw.jobId ?? null,
    jobName: raw.jobName ?? null,
    jobTypeIds: raw.jobTypeIds ?? [],
    orgEntityIds: raw.orgEntityIds ?? [],
    orgEntities: normalizeOrgEntities(raw.orgEntities),
    orgScopeTree: normalizeOrgScopeTree(raw.orgScopeTree),
    storeId: raw.storeId ?? null,
    storeName: raw.storeName ?? null,
    storeIds,
    stores,
    roles: raw.roles ?? [],
    permissionCodes: raw.permissionCodes ?? [],
    dataScope: raw.dataScope ?? null,
  }
}

/**
 * 认证上下文。只保存 /me 字段，不做权限判断或门店切换。
 */
export const useAuthStore = defineStore('auth', () => {
  const token = ref<string | null>(getToken())
  const currentUser = ref<CurrentUserVo | null>(null)
  const initStatus = ref<AuthInitStatus>('idle')
  const loading = ref(false)

  const isAuthenticated = computed(() => token.value != null && currentUser.value != null)
  const initialized = computed(() => initStatus.value === 'success')

  const employee = computed<EmployeeInfo | null>(() => {
    if (currentUser.value == null) {
      return null
    }
    return {
      id: currentUser.value.employeeId,
      name: currentUser.value.employeeName,
      jobId: currentUser.value.jobId,
      jobName: currentUser.value.jobName,
    }
  })

  async function fetchCurrentUser(): Promise<CurrentUserVo> {
    const me = normalizeCurrentUser(await getCurrentUser())
    currentUser.value = me
    return me
  }

  async function login(payload: LoginRequest): Promise<CurrentUserVo> {
    loading.value = true
    try {
      const loginVo = await loginRequest(payload)
      setToken(loginVo.token)
      token.value = loginVo.token
      return await fetchCurrentUser()
    } finally {
      loading.value = false
    }
  }

  let initializePromise: Promise<void> | null = null

  function initialize(): Promise<void> {
    if (initStatus.value === 'success') {
      return Promise.resolve()
    }
    if (initializePromise == null) {
      initializePromise = runInitialize().finally(() => {
        initializePromise = null
      })
    }
    return initializePromise
  }

  async function runInitialize(): Promise<void> {
    initStatus.value = 'initializing'
    loading.value = true
    try {
      // 本地调试旁路：不请求 /me，直接注入全权限账号。
      if (DEV_MOCK_AUTH) {
        token.value = DEV_MOCK_TOKEN
        currentUser.value = createMockCurrentUser()
        initStatus.value = 'success'
        return
      }
      token.value = getToken()
      if (token.value == null) {
        currentUser.value = null
        initStatus.value = 'success'
        return
      }
      try {
        await fetchCurrentUser()
        initStatus.value = 'success'
      } catch (error) {
        if (error instanceof ApiBusinessError && error.code === ApiCode.UNAUTHORIZED) {
          clearAuth()
          initStatus.value = 'success'
          return
        }
        currentUser.value = null
        initStatus.value = 'failed'
      }
    } finally {
      loading.value = false
      if (initStatus.value === 'initializing') {
        currentUser.value = null
        initStatus.value = 'failed'
      }
    }
  }

  function clearAuth(): void {
    removeToken()
    token.value = null
    currentUser.value = null
  }

  async function logout(): Promise<void> {
    try {
      await logoutRequest()
    } finally {
      clearAuth()
    }
  }

  return {
    token,
    currentUser,
    initStatus,
    initialized,
    loading,
    isAuthenticated,
    employee,
    login,
    fetchCurrentUser,
    initialize,
    clearAuth,
    logout,
  }
})
