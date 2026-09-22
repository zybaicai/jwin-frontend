import { defineComponent, h, type Component } from 'vue'

const wrappers = new Map<string, Component>()

export function resolveCachedView(source: Component, cacheName: string): Component {
  const existing = wrappers.get(cacheName)
  if (existing) {
    return existing
  }
  const wrapped = defineComponent({
    name: cacheName,
    setup() {
      return () => h(source)
    },
  })
  wrappers.set(cacheName, wrapped)
  return wrapped
}

export function retainCachedViews(activeNames: readonly string[]): void {
  const keep = new Set(activeNames)
  for (const name of wrappers.keys()) {
    if (!keep.has(name)) {
      wrappers.delete(name)
    }
  }
}
