<script setup lang="ts">
withDefaults(
  defineProps<{
    title?: string
    description?: string
  }>(),
  {
    title: '暂无数据',
    description: '',
  },
)
</script>

<template>
  <div class="app-empty">
    <p class="title">{{ title }}</p>
    <p v-if="description" class="description">{{ description }}</p>
    <div v-if="$slots.action" class="action">
      <slot name="action" />
    </div>
  </div>
</template>

<style scoped>
.app-empty {
  padding: 24px 16px;
  text-align: center;
  color: #909399;
}

.title {
  margin: 0;
  color: #606266;
  font-size: 14px;
}

.description {
  margin: 8px 0 0;
  font-size: 13px;
}

.action {
  margin-top: 12px;
}
</style>
