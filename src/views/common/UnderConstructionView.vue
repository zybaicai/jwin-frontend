<script setup lang="ts">
import { computed } from 'vue'
import { useRoute } from 'vue-router'

defineOptions({ name: 'UnderConstructionView' })

const route = useRoute()

const title = computed(() =>
  typeof route.meta.title === 'string' && route.meta.title !== ''
    ? route.meta.title
    : '建设中',
)
</script>

<template>
  <section class="under-construction">
    <h1>{{ title }}</h1>
    <p class="hint">功能建设中，暂未开放业务操作。</p>
  </section>
</template>

<style scoped>
.under-construction {
  display: flex;
  flex-direction: column;
  gap: 8px;
  min-height: 100%;
  padding: 20px 24px 24px;
}

.under-construction h1 {
  margin: 0;
  font-size: 20px;
  font-weight: 600;
  color: #303133;
}

.hint {
  margin: 0;
  font-size: 14px;
  color: #909399;
}
</style>
