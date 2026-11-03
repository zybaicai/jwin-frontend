<script setup lang="ts">
import BasicDictionaryPane from '@/views/settings/BasicDictionaryPane.vue'

defineOptions({ name: 'ProjectBrandSettingView' })
</script>

<template>
  <BasicDictionaryPane
    type="project-brands"
    title="项目品牌"
    create-label="新增项目品牌"
  />
</template>
