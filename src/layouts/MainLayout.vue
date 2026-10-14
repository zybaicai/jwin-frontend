<script setup lang="ts">
import { onBeforeUnmount, ref, watch } from 'vue'
import { RouterView, useRoute, type RouteLocationNormalizedLoaded } from 'vue-router'
import type { Component } from 'vue'

import AppHeader from '@/layouts/components/AppHeader.vue'
import AppLogo from '@/layouts/components/AppLogo.vue'
import AppSidebar from '@/layouts/components/AppSidebar.vue'
import AppTabs from '@/layouts/components/AppTabs.vue'
import { resolveCachedView, retainCachedViews } from '@/layouts/tab-cache'
import { useTabsStore } from '@/stores/tabs'

const route = useRoute()
const tabsStore = useTabsStore()
const collapsed = ref(false)

function toggleSidebar() {
  collapsed.value = !collapsed.value
}

watch(
  () => route.fullPath,
  () => {
    tabsStore.syncFromRoute(route)
  },
  { immediate: true },
)

onBeforeUnmount(() => {
  tabsStore.clear()
})

watch(
  () => tabsStore.aliveNames,
  (names) => {
    retainCachedViews(names)
  },
  { immediate: true },
)

/** 与页签 store 的 key 对齐（path，不含 query），保证刷新按钮能踢掉缓存 */
function tabKeyOf(viewRoute: RouteLocationNormalizedLoaded): string {
  if (viewRoute.name === 'home' || viewRoute.path === '/') {
    return '/'
  }
  return viewRoute.path
}

function viewKey(viewRoute: RouteLocationNormalizedLoaded): string {
  const key = tabKeyOf(viewRoute)
  return `${key}#${tabsStore.cacheName(key)}`
}

function viewComponent(
  component: Component | null | undefined,
  viewRoute: RouteLocationNormalizedLoaded,
): Component | null | undefined {
  if (component == null || viewRoute.meta.keepAlive !== true) {
    return component
  }
  return resolveCachedView(component, tabsStore.cacheName(tabKeyOf(viewRoute)))
}
</script>

<template>
  <div class="layout-root">
    <aside class="sidebar-area" :class="{ 'is-collapsed': collapsed }">
      <AppLogo :collapsed="collapsed" />
      <AppSidebar :collapsed="collapsed" />
    </aside>
    <div class="layout-main">
      <AppHeader :collapsed="collapsed" @toggle="toggleSidebar" />
      <AppTabs />
      <main class="layout-content">
        <RouterView v-slot="{ Component, route: viewRoute }">
          <KeepAlive :include="tabsStore.aliveNames">
            <component :is="viewComponent(Component, viewRoute)" :key="viewKey(viewRoute)" />
          </KeepAlive>
        </RouterView>
      </main>
    </div>
  </div>
</template>

<style scoped>
.layout-root {
  display: flex;
  height: 100%;
  overflow: hidden;
  background: #f5f7fa;
}

.sidebar-area {
  display: flex;
  flex: 0 0 220px;
  flex-direction: column;
  width: 220px;
  height: 100%;
  overflow: hidden;
  background: linear-gradient(180deg, #0f172a 0%, #111827 55%, #0b1220 100%);
  border-right: 1px solid rgba(148, 163, 184, 0.12);
  transition:
    flex-basis 0.2s ease,
    width 0.2s ease;
}

.sidebar-area.is-collapsed {
  flex-basis: 64px;
  width: 64px;
}

.layout-main {
  display: flex;
  flex: 1;
  flex-direction: column;
  min-width: 0;
  min-height: 0;
}

.layout-content {
  flex: 1;
  min-height: 0;
  overflow: auto;
}
</style>
