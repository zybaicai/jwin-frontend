<script setup lang="ts">
import { computed } from 'vue'
import { useRoute } from 'vue-router'

import {
  appMenu,
  findOpenMenuIndexes,
  type AppMenuItem,
} from '@/config/menu'
import { usePermissionStore } from '@/stores/permission'

defineProps<{
  collapsed: boolean
}>()

const route = useRoute()
const permissionStore = usePermissionStore()
const activePath = computed(() => route.path)

function isLeafVisible(item: AppMenuItem): boolean {
  if (item.permission == null) {
    return true
  }
  return permissionStore.hasPermission(item.permission)
}

/** 父级无权限码：有任意可见子项则显示；无子项则隐藏 */
function filterMenu(items: AppMenuItem[]): AppMenuItem[] {
  const result: AppMenuItem[] = []
  for (const item of items) {
    if (item.children && item.children.length > 0) {
      const children = filterMenu(item.children)
      if (children.length === 0) {
        continue
      }
      result.push({ ...item, children })
      continue
    }
    if (isLeafVisible(item) && item.path) {
      result.push(item)
    }
  }
  return result
}

const visibleMenu = computed(() => filterMenu(appMenu))

const defaultOpeneds = computed(() => {
  const indexes = findOpenMenuIndexes(activePath.value)
  return indexes.length ? [indexes[0]!] : []
})

/** 路由变化时强制同步展开态（default-openeds 仅首次生效） */
const menuKey = computed(
  () => `${activePath.value}|${defaultOpeneds.value.join(',')}`,
)
</script>

<template>
  <div class="sidebar-scroll">
    <el-menu
      :key="menuKey"
      class="sidebar-menu"
      :collapse="collapsed"
      :default-active="activePath"
      :default-openeds="defaultOpeneds"
      unique-opened
      router
      background-color="transparent"
      text-color="#94a3b8"
      active-text-color="#f8fafc"
    >
      <template v-for="item in visibleMenu" :key="item.name">
        <el-sub-menu v-if="item.children && item.children.length > 0" :index="item.name">
          <template #title>
            <el-icon v-if="item.icon">
              <component :is="item.icon" />
            </el-icon>
            <span class="menu-title" :title="item.title">{{ item.title }}</span>
          </template>
          <el-menu-item
            v-for="child in item.children"
            :key="child.path"
            :index="child.path!"
          >
            <span class="menu-title" :title="child.title">{{ child.title }}</span>
          </el-menu-item>
        </el-sub-menu>
        <el-menu-item v-else-if="item.path" :index="item.path">
          <el-icon v-if="item.icon">
            <component :is="item.icon" />
          </el-icon>
          <template #title>
            <span class="menu-title" :title="item.title">{{ item.title }}</span>
          </template>
        </el-menu-item>
      </template>
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
  background: transparent !important;
}

.sidebar-menu:not(.el-menu--collapse) {
  width: 100%;
}

.sidebar-menu:not(.el-menu--collapse) :deep(.el-menu-item),
.sidebar-menu:not(.el-menu--collapse) :deep(.el-sub-menu__title) {
  overflow: hidden;
  margin: 2px 8px;
  border-radius: 8px;
  height: 44px;
  line-height: 44px;
}

.menu-title {
  display: inline-block;
  max-width: 100%;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
  vertical-align: middle;
}

.sidebar-menu :deep(.el-menu-item:hover),
.sidebar-menu :deep(.el-sub-menu__title:hover) {
  background-color: rgba(148, 163, 184, 0.12) !important;
  color: #e2e8f0 !important;
}

.sidebar-menu :deep(.el-menu-item.is-active) {
  background: linear-gradient(90deg, rgba(56, 189, 248, 0.22), rgba(56, 189, 248, 0.08)) !important;
  color: #f8fafc !important;
  font-weight: 600;
}

.sidebar-menu :deep(.el-sub-menu .el-menu) {
  background: transparent !important;
}

.sidebar-menu :deep(.el-sub-menu .el-menu-item) {
  background-color: transparent;
  min-width: 0;
  padding-left: 48px !important;
  height: 40px;
  line-height: 40px;
}

.sidebar-menu :deep(.el-sub-menu .el-menu-item:hover) {
  background-color: rgba(148, 163, 184, 0.1) !important;
}

.sidebar-menu :deep(.el-sub-menu .el-menu-item.is-active) {
  background: linear-gradient(90deg, rgba(56, 189, 248, 0.2), transparent) !important;
  color: #f8fafc !important;
}

.sidebar-menu :deep(.el-sub-menu.is-active > .el-sub-menu__title) {
  color: #e2e8f0 !important;
}
</style>
