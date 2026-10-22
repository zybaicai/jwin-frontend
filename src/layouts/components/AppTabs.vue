<script setup lang="ts">
import { ref } from 'vue'
import { RefreshRight } from '@element-plus/icons-vue'
import { useRouter } from 'vue-router'

import { useNavigationStore } from '@/stores/navigation'
import { useTabsStore } from '@/stores/tabs'
import { canCloseTab } from '@/utils/ui'

const router = useRouter()
const tabsStore = useTabsStore()
const navigationStore = useNavigationStore()

async function openTab(path: string): Promise<void> {
  navigationStore.syncFromPath(path)
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

const draggingKey = ref<string | null>(null)
const scrollRef = ref<HTMLElement | null>(null)
const dragMoved = ref(false)
let suppressClick = false
let dragStartX = 0

function onWheel(event: WheelEvent): void {
  const el = event.currentTarget
  if (!(el instanceof HTMLElement)) return
  if (el.scrollWidth <= el.clientWidth) return
  el.scrollLeft += event.deltaY !== 0 ? event.deltaY : event.deltaX
}

function onPointerDown(key: string, event: PointerEvent): void {
  if (event.button !== 0) return
  const target = event.target
  if (target instanceof Element && target.closest('.tab-refresh, .tab-close')) return
  draggingKey.value = key
  dragMoved.value = false
  dragStartX = event.clientX
  window.addEventListener('pointermove', onPointerMove)
  window.addEventListener('pointerup', onPointerUp)
}

function onPointerMove(event: PointerEvent): void {
  if (draggingKey.value == null) return
  if (!dragMoved.value && Math.abs(event.clientX - dragStartX) < 4) return
  dragMoved.value = true
  const root = scrollRef.value
  if (root == null) return
  const tabs = root.querySelectorAll<HTMLElement>('.tab')
  let nearestKey: string | null = null
  let nearestDistance = Number.POSITIVE_INFINITY
  tabs.forEach((el) => {
    const key = el.dataset.key
    if (key == null) return
    const rect = el.getBoundingClientRect()
    const distance = Math.abs(event.clientX - (rect.left + rect.width / 2))
    if (distance < nearestDistance) {
      nearestDistance = distance
      nearestKey = key
    }
  })
  if (nearestKey != null && nearestKey !== draggingKey.value) {
    tabsStore.moveTab(draggingKey.value, nearestKey)
  }
}

function onPointerUp(): void {
  if (dragMoved.value) suppressClick = true
  draggingKey.value = null
  dragMoved.value = false
  window.removeEventListener('pointermove', onPointerMove)
  window.removeEventListener('pointerup', onPointerUp)
}

function onTitleClick(path: string): void {
  if (suppressClick) {
    suppressClick = false
    return
  }
  void openTab(path)
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
    <div ref="scrollRef" class="tabs-scroll" @wheel.prevent="onWheel">
      <div class="tabs-track">
        <div
          v-for="tab in tabsStore.tabs"
          :key="tab.key"
          class="tab"
          :data-key="tab.key"
          :class="{
            'is-active': tab.key === tabsStore.activeKey,
            'is-dragging': draggingKey === tab.key && dragMoved,
          }"
          @pointerdown="onPointerDown(tab.key, $event)"
        >
          <button type="button" class="tab-title" @click="onTitleClick(tab.path)">
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
    <div class="tabs-actions">
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
  </div>
</template>

<style scoped>
.tabs-bar {
  display: flex;
  flex: 0 0 40px;
  align-items: stretch;
  height: 40px;
  min-width: 0;
  overflow: hidden;
  border-bottom: 1px solid #e4e7ed;
  background: #fff;
}

.tabs-scroll {
  flex: 1 1 auto;
  min-width: 0;
  overflow-x: auto;
  overflow-y: hidden;
  scrollbar-width: none;
}

.tabs-scroll::-webkit-scrollbar {
  display: none;
  height: 0;
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
  cursor: grab;
}

.tab.is-dragging {
  opacity: 0.72;
  cursor: grabbing;
  box-shadow: 0 0 0 1px var(--el-color-primary);
}

.tab.is-drop {
  border-color: var(--el-color-primary);
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

.tabs-actions {
  position: relative;
  z-index: 1;
  display: flex;
  flex: 0 0 auto;
  align-items: center;
  height: 100%;
  padding: 0 10px;
  border-left: 1px solid #e4e7ed;
  background: #fff;
}

.tabs-actions::before {
  content: '';
  position: absolute;
  top: 0;
  bottom: 0;
  left: -16px;
  width: 16px;
  background: linear-gradient(90deg, rgba(255, 255, 255, 0), #fff);
  pointer-events: none;
}

.tabs-actions .tab-action {
  height: 28px;
  padding: 0 12px;
  border: 1px solid var(--el-color-primary);
  border-radius: 4px;
  background: var(--el-color-primary);
  color: #fff;
  font-size: 13px;
  line-height: 26px;
  white-space: nowrap;
}

.tabs-actions .tab-action:hover:not(:disabled) {
  border-color: var(--el-color-primary-dark-2);
  background: var(--el-color-primary-dark-2);
  color: #fff;
}

.tabs-actions .tab-action:disabled {
  border-color: #dcdfe6;
  background: #f5f7fa;
  color: #c0c4cc;
  cursor: not-allowed;
}
</style>
