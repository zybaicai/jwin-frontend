import { onBeforeUnmount, ref, type Ref } from 'vue'

export interface InfinitePageResult<T> {
  records: T[]
  total?: number
  /** 若后端未回 total，可用本页条数判断是否还有下一页 */
  pageSize: number
  /**
   * 原始本页条数（过滤前）。客户端过滤后 records.length 可能变短，
   * 用此字段判断是否还有下一页，避免误判结束。
   */
  rawCount?: number
}

/**
 * 关键字防抖 + 滚动加载更多（首屏 page=1 覆盖，后续 append）。
 */
export function useInfiniteList<T>(options: {
  pageSize?: number
  debounceMs?: number
  /** visible 为 false 时不触发搜索 */
  visible?: Ref<boolean>
  onError?: (error: unknown) => void
  fetcher: (args: {
    keyword: string
    page: number
    size: number
  }) => Promise<InfinitePageResult<T>>
}) {
  const pageSize = options.pageSize ?? 15
  const debounceMs = options.debounceMs ?? 300

  const keyword = ref('')
  const records = ref<T[]>([]) as Ref<T[]>
  const page = ref(1)
  const total = ref(0)
  const loading = ref(false)
  const loadingMore = ref(false)
  const hasMore = ref(false)
  const error = ref<string | null>(null)

  let timer: ReturnType<typeof setTimeout> | null = null
  let seq = 0
  let skipKeywordWatch = false

  function clearTimer(): void {
    if (timer != null) {
      clearTimeout(timer)
      timer = null
    }
  }

  function computeHasMore(loadedLen: number, pageNo: number, totalCount: number): boolean {
    if (totalCount > 0) {
      return loadedLen < totalCount
    }
    return loadedLen >= pageNo * pageSize
  }

  async function load(reset: boolean): Promise<void> {
    const nextPage = reset ? 1 : page.value + 1
    if (!reset && (loading.value || loadingMore.value || !hasMore.value)) {
      return
    }
    const mySeq = ++seq
    if (reset) {
      loading.value = true
      loadingMore.value = false
    } else {
      loadingMore.value = true
    }
    error.value = null
    try {
      const data = await options.fetcher({
        keyword: keyword.value.trim(),
        page: nextPage,
        size: pageSize,
      })
      if (mySeq !== seq) return
      const chunk = data.records ?? []
      const totalCount = data.total ?? 0
      const rawCount = data.rawCount ?? chunk.length
      if (reset) {
        records.value = chunk
        page.value = 1
      } else {
        records.value = [...records.value, ...chunk]
        page.value = nextPage
      }
      total.value = totalCount
      if (totalCount > 0 && data.rawCount == null) {
        hasMore.value = computeHasMore(records.value.length, page.value, totalCount)
      } else {
        // 以原始本页是否满页为准（兼容客户端过滤）
        hasMore.value = rawCount >= pageSize
      }
    } catch (e) {
      if (mySeq !== seq) return
      if (reset) {
        records.value = []
        page.value = 1
        total.value = 0
        hasMore.value = false
      }
      options.onError?.(e)
      throw e
    } finally {
      if (mySeq === seq) {
        loading.value = false
        loadingMore.value = false
      }
    }
  }

  function scheduleSearch(): void {
    if (options.visible && !options.visible.value) return
    clearTimer()
    timer = setTimeout(() => {
      timer = null
      void load(true).catch(() => undefined)
    }, debounceMs)
  }

  function flushSearch(): void {
    clearTimer()
    void load(true).catch(() => undefined)
  }

  function onKeywordChange(): void {
    if (skipKeywordWatch) return
    if (options.visible && !options.visible.value) return
    scheduleSearch()
  }

  function resetKeywordSilent(): void {
    clearTimer()
    skipKeywordWatch = true
    keyword.value = ''
    skipKeywordWatch = false
    records.value = []
    page.value = 1
    total.value = 0
    hasMore.value = false
    error.value = null
  }

  /** 列表滚动触底加载 */
  function onScroll(e: Event): void {
    const el = e.target as HTMLElement | null
    if (!el || loading.value || loadingMore.value || !hasMore.value) return
    const remain = el.scrollHeight - el.scrollTop - el.clientHeight
    if (remain <= 48) {
      void load(false).catch(() => undefined)
    }
  }

  onBeforeUnmount(() => clearTimer())

  return {
    keyword,
    records,
    page,
    total,
    pageSize,
    loading,
    loadingMore,
    hasMore,
    error,
    load,
    flushSearch,
    scheduleSearch,
    onKeywordChange,
    resetKeywordSilent,
    onScroll,
    clearTimer,
  }
}
