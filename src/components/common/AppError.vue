<script setup lang="ts">
withDefaults(
  defineProps<{
    title?: string
    description?: string
  }>(),
  {
    title: '加载失败',
    description: '网络异常，请稍后重试',
  },
)

const emit = defineEmits<{
  retry: []
}>()
</script>

<template>
  <div class="app-error">
    <p class="title">{{ title }}</p>
    <p v-if="description" class="description">{{ description }}</p>
    <el-button class="retry" @click="emit('retry')">重新加载</el-button>
  </div>
</template>

<style scoped>
.app-error {
  padding: 24px 16px;
  text-align: center;
}

.title {
  margin: 0;
  color: #303133;
  font-size: 14px;
}

.description {
  margin: 8px 0 0;
  color: #909399;
  font-size: 13px;
}

.retry {
  margin-top: 12px;
}
</style>
