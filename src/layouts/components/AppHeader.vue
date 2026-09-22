<script setup lang="ts">
import AppBreadcrumb from '@/layouts/components/AppBreadcrumb.vue'
import AppStoreSelector from '@/layouts/components/AppStoreSelector.vue'
import AppUserDropdown from '@/layouts/components/AppUserDropdown.vue'

defineProps<{
  collapsed: boolean
}>()

const emit = defineEmits<{
  toggle: []
}>()
</script>

<template>
  <header class="header">
    <el-button
      class="collapse-btn"
      text
      :aria-label="collapsed ? '展开侧边栏' : '折叠侧边栏'"
      @click="emit('toggle')"
    >
      ☰
    </el-button>
    <AppBreadcrumb />
    <div class="header-actions">
      <AppStoreSelector />
      <AppUserDropdown />
    </div>
  </header>
</template>

<style scoped>
.header {
  display: flex;
  flex: 0 0 48px;
  align-items: center;
  height: 48px;
  min-width: 0;
  padding: 0 12px;
  gap: 12px;
  border-bottom: 1px solid #e4e7ed;
  background: #fff;
}

.collapse-btn {
  flex: 0 0 auto;
  font-size: 18px;
}

.header-actions {
  display: flex;
  flex: 0 0 auto;
  align-items: center;
  gap: 16px;
  margin-left: auto;
}
</style>
