<script setup lang="ts">
import { RefreshRight } from '@element-plus/icons-vue'
import { useRouter } from 'vue-router'

import { useTabsStore } from '@/stores/tabs'
import { canCloseTab } from '@/utils/ui'

const router = useRouter()
const tabsStore = useTabsStore()

async function openTab(path: string): Promise<void> {
  if (router.currentRoute.value.fullPath === path || router.currentRoute.value.path === path) {
    return
  }
  await router.push(path)
}

async function refreshTab(key: string): Promise<void> {
  // 非当前页先切过去再刷，避免只刷缓存看不见效果
  if (tabsStore.activeKey !== key) {
    const tab = tabsStore.tabs.find((t) => t.key === key)
    if (tab) {
      await router.push(tab.path)
    }
  }
  tabsStore.refreshTab(key)
}

async function closeTab(key: string): Promise<void> {
  const allowed = await canCloseTab(key)
  if (!allowed) {
    return
  }
  const nextPath = tabsStore.removeTab(key)
  if (nextPath != null && router.currentRoute.value.path !== nextPath) {
    await router.push(nextPath)
  }
}

async function closeOtherTabs(): Promise<void> {
  const current = tabsStore.activeTab
  if (current == null) {
    return
  }
  const others = tabsStore.tabs.filter((tab) => tab.closable && tab.key !== current.key)
  for (const tab of others) {
    const allowed = await canCloseTab(tab.key)
    if (!allowed) {
      return
    }
  }
  tabsStore.closeOtherTabs(current.key)
  if (router.currentRoute.value.path !== current.path) {
    await router.push(current.path)
  }
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
            type="button"
            class="tab-refresh"
            :aria-label="`刷新${tab.title}`"
            :title="`刷新${tab.title}`"
            @click.stop="refreshTab(tab.key)"
          >
            <el-icon :size="12"><RefreshRight /></el-icon>
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
    <button
      type="button"
      class="tab-action"
      title="关闭其它窗口"
      :disabled="tabsStore.tabs.filter((t) => t.closable && t.key !== tabsStore.activeKey).length === 0"
      @click="closeOtherTabs"
    >
      关闭其它
    </button>
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
  border-color: var(--el-color-primary);
  background: var(--el-color-primary-light-9);
  color: var(--el-color-primary);
}

.tab-title,
.tab-refresh,
.tab-close,
.tab-action {
  border: 0;
  background: transparent;
  color: inherit;
  cursor: pointer;
  font: inherit;
}

.tab-title {
  max-width: 160px;
  overflow: hidden;
  padding: 0 6px 0 8px;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.tab-refresh {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  width: 18px;
  height: 18px;
  margin-right: 2px;
  border-radius: 3px;
  opacity: 0.55;
  color: inherit;
}

.tab-refresh:hover {
  opacity: 1;
  background: rgba(0, 0, 0, 0.06);
}

.tab.is-active .tab-refresh:hover {
  background: var(--el-color-primary-light-8);
}

.tab-close {
  padding: 0 6px 0 0;
  line-height: 1;
}

.tab-action {
  flex: 0 0 auto;
  padding: 0 12px;
  color: #606266;
  font-size: 13px;
  white-space: nowrap;
}

.tab-action:hover:not(:disabled) {
  color: var(--el-color-primary);
}

.tab-action:disabled {
  color: #c0c4cc;
  cursor: not-allowed;
}
</style>
