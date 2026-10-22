import { ref } from 'vue'
import { defineStore } from 'pinia'

import {
  BusinessCenter,
  businessCenters,
  findBusinessCenter,
  type BusinessCenterId,
} from '@/config/menu'

const STORAGE_KEY = 'jwin.activeTopModule'

function readStoredCenter(): BusinessCenterId | null {
  try {
    const raw = sessionStorage.getItem(STORAGE_KEY)
    if (businessCenters.some((center) => center.id === raw)) {
      return raw as BusinessCenterId
    }
  } catch {
    // 无痕模式或存储不可用时使用默认中心
  }
  return null
}

function writeStoredCenter(id: BusinessCenterId): void {
  try {
    sessionStorage.setItem(STORAGE_KEY, id)
  } catch {
    // 存储失败不影响当前会话内的导航
  }
}

/**
 * 顶部一级导航。与页签、路由解耦：只切换左侧菜单上下文。
 * 地址真正变化时，再按页面归属同步。
 */
export const useNavigationStore = defineStore('navigation', () => {
  const storedCenter = readStoredCenter()
  const activeTopModule = ref<BusinessCenterId>(storedCenter ?? BusinessCenter.STORE)
  /** 已有会话记录时，刷新先恢复上次选中的中心，不按地址覆盖 */
  const preferStoredOnLoad = storedCenter != null

  function setActiveTopModule(id: BusinessCenterId): void {
    activeTopModule.value = id
    writeStoredCenter(id)
  }

  /** 仅在路由 path 发生变化后调用，不负责跳转 */
  function syncFromPath(path: string): void {
    const center = findBusinessCenter(path)
    if (center == null || center === activeTopModule.value) {
      return
    }
    setActiveTopModule(center)
  }

  /** 第一次进入且没有保存过一级导航时，按当前页归属对齐 */
  function alignInitialRoute(path: string): void {
    if (preferStoredOnLoad) return
    syncFromPath(path)
  }

  return {
    activeTopModule,
    setActiveTopModule,
    syncFromPath,
    alignInitialRoute,
  }
})
