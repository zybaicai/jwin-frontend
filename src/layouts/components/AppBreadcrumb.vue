<script setup lang="ts">
import { computed } from 'vue'
import { useRoute } from 'vue-router'

import { findMenuBreadcrumb } from '@/config/menu'

interface Crumb {
  path: string
  title: string
}

const route = useRoute()

const items = computed<Crumb[]>(() => {
  const fromMenu = findMenuBreadcrumb(route.path)
  if (fromMenu.length > 0) {
    return fromMenu.map((c, index) => ({
      path: `${route.path}#${index}`,
      title: c.title,
    }))
  }
  return route.matched.flatMap((record) => {
    if (record.meta.breadcrumb === false || typeof record.meta.title !== 'string') {
      return []
    }
    if (record.meta.title === '') {
      return []
    }
    return [{ path: record.path, title: record.meta.title }]
  })
})
</script>

<template>
  <el-breadcrumb class="breadcrumb" separator="/">
    <el-breadcrumb-item v-for="item in items" :key="item.path">
      {{ item.title }}
    </el-breadcrumb-item>
  </el-breadcrumb>
</template>

<style scoped>
.breadcrumb {
  min-width: 0;
  overflow: hidden;
  white-space: nowrap;
}

.breadcrumb :deep(.el-breadcrumb__item) {
  float: none;
  display: inline-flex;
}
</style>
