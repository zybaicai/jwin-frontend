import { computed, ref } from 'vue'
import { defineStore } from 'pinia'
import type { RouteLocationNormalized } from 'vue-router'

export interface AppTab {
  key: string
  path: string
  title: string
  closable: boolean
  keepAlive: boolean
}

export const HOME_PATH = '/'
export const HOME_TITLE = '首页'

const EXCLUDED_ROUTE_NAMES = new Set(['login', 'auth-init-error'])
const UNTITLED_PAGE = '未命名页面'

function createHomeTab(): AppTab {
  return {
    key: HOME_PATH,
    path: HOME_PATH,
    title: HOME_TITLE,
    closable: false,
    keepAlive: false,
  }
}

function isHomeRoute(route: RouteLocationNormalized): boolean {
  return route.name === 'home' || route.path === HOME_PATH
}

function titleOf(route: RouteLocationNormalized): string {
  if (typeof route.meta.title === 'string' && route.meta.title !== '') {
    return route.meta.title
  }
  if (typeof route.name === 'string' && route.name !== '') {
    return route.name
  }
  return UNTITLED_PAGE
}

function toTab(route: RouteLocationNormalized): AppTab {
  const home = isHomeRoute(route)
  return {
    key: route.fullPath,
    path: route.fullPath,
    title: home ? HOME_TITLE : titleOf(route),
    closable: home ? false : route.meta.tabClosable !== false,
    keepAlive: route.meta.keepAlive === true,
  }
}

/**
 * 工作区标签。只记录已打开页面，不负责跳转，也不写入 localStorage。
 */
export const useTabsStore = defineStore('tabs', () => {
  const tabs = ref<AppTab[]>([createHomeTab()])
  const activeKey = ref(HOME_PATH)
  const refreshVersion = ref<Record<string, number>>({})

  const activeTab = computed(() => tabs.value.find((tab) => tab.key === activeKey.value) ?? null)

  const aliveNames = computed(() =>
    tabs.value.filter((tab) => tab.keepAlive).map((tab) => cacheName(tab.key)),
  )

  function cacheName(key: string): string {
    const version = refreshVersion.value[key] ?? 0
    const safe = key.replace(/[^A-Za-z0-9]/g, '')
    return `WorkspaceTab${safe}${version}`
  }

  function ensureHomeTab(): void {
    if (!tabs.value.some((tab) => tab.key === HOME_PATH)) {
      tabs.value.unshift(createHomeTab())
    }
  }

  function activateTab(key: string): void {
    if (tabs.value.some((tab) => tab.key === key)) {
      activeKey.value = key
    }
  }

  function addTab(tab: AppTab): void {
    const existing = tabs.value.find((item) => item.key === tab.key)
    if (existing) {
      activeKey.value = existing.key
      return
    }
    tabs.value.push(tab)
    activeKey.value = tab.key
  }

  function syncFromRoute(route: RouteLocationNormalized): void {
    if (typeof route.name === 'string' && EXCLUDED_ROUTE_NAMES.has(route.name)) {
      return
    }
    ensureHomeTab()
    addTab(toTab(route))
  }

  function removeTab(key: string): string | null {
    const current = tabs.value.find((tab) => tab.key === key)
    if (current == null || !current.closable) {
      return null
    }
    const index = tabs.value.findIndex((tab) => tab.key === key)
    const closingActive = activeKey.value === key
    tabs.value.splice(index, 1)
    ensureHomeTab()
    if (!closingActive) {
      return null
    }
    const fallback = tabs.value[index - 1] ?? tabs.value[index] ?? tabs.value[0]
    activeKey.value = fallback.key
    return fallback.path
  }

  function closeCurrentTab(): string | null {
    return removeTab(activeKey.value)
  }

  function closeOtherTabs(key: string): void {
    tabs.value = tabs.value.filter((tab) => !tab.closable || tab.key === key)
    ensureHomeTab()
    if (!tabs.value.some((tab) => tab.key === activeKey.value)) {
      activeKey.value = tabs.value.some((tab) => tab.key === key) ? key : HOME_PATH
    }
  }

  function closeTabsToRight(key: string): void {
    const index = tabs.value.findIndex((tab) => tab.key === key)
    if (index < 0) {
      return
    }
    tabs.value = tabs.value.filter((tab, tabIndex) => tabIndex <= index || !tab.closable)
    ensureHomeTab()
    if (!tabs.value.some((tab) => tab.key === activeKey.value)) {
      activeKey.value = key
    }
  }

  function closeAllTabs(): string {
    tabs.value = [createHomeTab()]
    activeKey.value = HOME_PATH
    return HOME_PATH
  }

  function refreshTab(key: string): void {
    if (!tabs.value.some((tab) => tab.key === key)) {
      return
    }
    refreshVersion.value = {
      ...refreshVersion.value,
      [key]: (refreshVersion.value[key] ?? 0) + 1,
    }
  }

  function clear(): void {
    tabs.value = [createHomeTab()]
    activeKey.value = HOME_PATH
    refreshVersion.value = {}
  }

  return {
    tabs,
    activeKey,
    activeTab,
    aliveNames,
    cacheName,
    syncFromRoute,
    addTab,
    activateTab,
    removeTab,
    closeCurrentTab,
    closeOtherTabs,
    closeTabsToRight,
    closeAllTabs,
    refreshTab,
    clear,
  }
})
