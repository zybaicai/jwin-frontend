<script setup lang="ts">
import { businessCenters } from '@/config/menu'
import { useNavigationStore } from '@/stores/navigation'

const navigationStore = useNavigationStore()

function selectCenter(id: (typeof businessCenters)[number]['id']): void {
  navigationStore.setActiveTopModule(id)
}
</script>

<template>
  <nav class="top-nav" aria-label="业务中心">
    <button
      v-for="center in businessCenters"
      :key="center.id"
      type="button"
      class="top-nav-item"
      :class="{ 'is-active': center.id === navigationStore.activeTopModule }"
      :aria-current="center.id === navigationStore.activeTopModule ? 'true' : undefined"
      @click="selectCenter(center.id)"
    >
      {{ center.title }}
    </button>
  </nav>
</template>

<style scoped>
.top-nav {
  display: flex;
  flex: 1 1 auto;
  align-items: stretch;
  min-width: 0;
  overflow-x: auto;
  scrollbar-width: none;
}

.top-nav::-webkit-scrollbar {
  display: none;
}

.top-nav-item {
  flex: 0 0 auto;
  height: 100%;
  padding: 0 14px;
  border: 0;
  border-bottom: 2px solid transparent;
  background: transparent;
  color: #606266;
  font-size: 14px;
  line-height: 46px;
  white-space: nowrap;
  cursor: pointer;
}

.top-nav-item:hover {
  color: var(--el-color-primary);
}

.top-nav-item.is-active {
  color: var(--el-color-primary);
  font-weight: 600;
  border-bottom-color: var(--el-color-primary);
}
</style>
