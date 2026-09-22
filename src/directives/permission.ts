import { watch, type Directive, type WatchStopHandle } from 'vue'

import { usePermissionStore } from '@/stores/permission'

interface PermissionState {
  value: string | readonly string[]
  stop: WatchStopHandle
}

const states = new WeakMap<HTMLElement, PermissionState>()

function isAllowed(value: string | readonly string[] | undefined): boolean {
  const store = usePermissionStore()
  if (typeof value === 'string') {
    return store.hasPermission(value)
  }
  if (Array.isArray(value)) {
    return store.hasAnyPermission(value)
  }
  return false
}

function syncVisibility(el: HTMLElement, allowed: boolean): void {
  if (allowed) {
    el.style.display = el.dataset.permissionPrevDisplay ?? ''
    delete el.dataset.permissionPrevDisplay
    el.removeAttribute('hidden')
    return
  }
  if (el.dataset.permissionPrevDisplay == null) {
    el.dataset.permissionPrevDisplay = el.style.display
  }
  el.style.display = 'none'
  el.setAttribute('hidden', '')
}

function apply(el: HTMLElement, value: string | readonly string[] | undefined): void {
  syncVisibility(el, isAllowed(value))
}

/**
 * 按钮或区域的界面权限。无权限时隐藏，不代替后端鉴权。
 * 字符串表示单个权限码；数组表示拥有其中任一权限即可显示。
 *
 * v-permission="'org:store:view'"
 * v-permission="['customer:create', 'customer:edit']"
 */
export const permissionDirective: Directive<HTMLElement, string | readonly string[]> = {
  mounted(el, binding) {
    const store = usePermissionStore()
    const state: PermissionState = {
      value: binding.value,
      stop: () => {},
    }
    state.stop = watch(
      () => store.permissionCodes,
      () => {
        apply(el, state.value)
      },
      { immediate: true },
    )
    states.set(el, state)
  },
  updated(el, binding) {
    const state = states.get(el)
    if (state == null) {
      return
    }
    state.value = binding.value
    apply(el, state.value)
  },
  unmounted(el) {
    const state = states.get(el)
    state?.stop()
    states.delete(el)
  },
}
