import type { Ref } from 'vue'

/**
 * 按钮级防重复提交。已经在执行时直接返回，不叠第二次请求。
 */
export async function runExclusive<T>(
  busy: Ref<boolean>,
  action: () => Promise<T>,
): Promise<T | undefined> {
  if (busy.value) {
    return undefined
  }
  busy.value = true
  try {
    return await action()
  } finally {
    busy.value = false
  }
}
