<script setup lang="ts">
import { useRouter } from 'vue-router'

import { useTabsStore } from '@/stores/tabs'
import { canCloseTab } from '@/utils/ui'

const router = useRouter()
const tabsStore = useTabsStore()

async function openTab(path: string): Promise<void> {
  if (router.currentRoute.value.fullPath === path) {
    return
  }
  await router.push(path)
}

async function closeTab(key: string): Promise<void> {
  const allowed = await canCloseTab(key)
  if (!allowed) {
    return
  }
  const nextPath = tabsStore.removeTab(key)
  if (nextPath != null && router.currentRoute.value.fullPath !== nextPath) {
    await router.push(nextPath)
  }
}

function refreshCurrent(): void {
  const current = tabsStore.activeTab
  if (current == null) {
    return
  }
  tabsStore.refreshTab(current.key)
}
</script>

<template>
  <div class="tabs-bar">
    <div class="tabs-scroll">
      <div class="tabs-track">
        <div
          v-for="tab in tabsStore.tabs"
          :key="tab.key"
          class="tab"
          :class="{ 'is-active': tab.key === tabsStore.activeKey }"
        >
          <button type="button" class="tab-title" @click="openTab(tab.path)">
            {{ tab.title }}
          </button>
          <button
            v-if="tab.closable"
            type="button"
            class="tab-close"
            :aria-label="`关闭${tab.title}`"
            @click="closeTab(tab.key)"
          >
            ×
          </button>
        </div>
      </div>
    </div>
    <button type="button" class="tab-refresh" @click="refreshCurrent">刷新</button>
  </div>
</template>

<style scoped>
.tabs-bar {
  display: flex;
  flex: 0 0 40px;
  align-items: center;
  height: 40px;
  min-width: 0;
  border-bottom: 1px solid #e4e7ed;
  background: #fff;
}

.tabs-scroll {
  flex: 1;
  min-width: 0;
  overflow-x: auto;
  overflow-y: hidden;
}

.tabs-track {
  display: inline-flex;
  align-items: center;
  height: 40px;
  padding: 0 8px;
  gap: 4px;
  white-space: nowrap;
}

.tab {
  display: inline-flex;
  align-items: center;
  height: 28px;
  border: 1px solid #dcdfe6;
  border-radius: 4px;
  background: #f5f7fa;
}

.tab.is-active {
  border-color: #409eff;
  background: #ecf5ff;
  color: #409eff;
}

.tab-title,
.tab-close,
.tab-refresh {
  border: 0;
  background: transparent;
  color: inherit;
  cursor: pointer;
  font: inherit;
}

.tab-title {
  max-width: 160px;
  overflow: hidden;
  padding: 0 8px;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.tab-close {
  padding: 0 6px 0 0;
  line-height: 1;
}

.tab-refresh {
  flex: 0 0 auto;
  padding: 0 12px;
  color: #606266;
}
</style>
