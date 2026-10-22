<script setup lang="ts">
import AppStoreSelector from '@/layouts/components/AppStoreSelector.vue'
import AppTopNav from '@/layouts/components/AppTopNav.vue'
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
    <AppTopNav />
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
  align-items: stretch;
  height: 48px;
  min-width: 0;
  padding: 0 12px 0 4px;
  gap: 4px;
  border-bottom: 1px solid #e4e7ed;
  background: #fff;
}

.collapse-btn {
  flex: 0 0 auto;
  align-self: center;
  font-size: 18px;
}

.header-actions {
  display: flex;
  flex: 0 0 auto;
  align-items: center;
  align-self: center;
  gap: 16px;
  margin-left: auto;
}
</style>
