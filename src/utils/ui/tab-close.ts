export type TabCloseGuard = (tabKey: string) => boolean | Promise<boolean>

let tabCloseGuard: TabCloseGuard | null = null

/**
 * 预留未保存检查。当前没有业务表单，默认允许关闭。
 */
export function setTabCloseGuard(guard: TabCloseGuard | null): void {
  tabCloseGuard = guard
}

export async function canCloseTab(tabKey: string): Promise<boolean> {
  if (tabCloseGuard == null) {
    return true
  }
  return tabCloseGuard(tabKey)
}
