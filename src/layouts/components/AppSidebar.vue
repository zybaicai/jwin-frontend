<script setup lang="ts">
import { computed } from 'vue'
import { useRoute } from 'vue-router'

import { appMenu } from '@/config/menu'
import { usePermissionStore } from '@/stores/permission'

defineProps<{
  collapsed: boolean
}>()

const route = useRoute()
const permissionStore = usePermissionStore()
const activePath = computed(() => route.path)
const visibleMenu = computed(() =>
  appMenu.filter(
    (item) => item.permission == null || permissionStore.hasPermission(item.permission),
  ),
)
</script>

<template>
  <div class="sidebar-scroll">
    <el-menu
      class="sidebar-menu"
      :collapse="collapsed"
      :default-active="activePath"
      router
      background-color="#304156"
      text-color="#bfcbd9"
      active-text-color="#409eff"
    >
      <el-menu-item v-for="item in visibleMenu" :key="item.path" :index="item.path">
        <el-icon>
          <component :is="item.icon" />
        </el-icon>
        <template #title>
          <span class="menu-title" :title="item.title">{{ item.title }}</span>
        </template>
      </el-menu-item>
    </el-menu>
  </div>
</template>

<style scoped>
.sidebar-scroll {
  flex: 1;
  min-height: 0;
  overflow-x: hidden;
  overflow-y: auto;
}

.sidebar-menu {
  border-right: none;
  min-height: 100%;
}

.sidebar-menu:not(.el-menu--collapse) {
  width: 100%;
}

.sidebar-menu:not(.el-menu--collapse) :deep(.el-menu-item) {
  overflow: hidden;
}

.menu-title {
  display: inline-block;
  max-width: 100%;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
  vertical-align: middle;
}

.sidebar-menu :deep(.el-menu-item:hover) {
  background-color: #263445;
}
</style>
