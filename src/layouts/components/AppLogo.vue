<script setup lang="ts">
defineProps<{
  collapsed: boolean
}>()
</script>

<template>
  <div class="logo">{{ collapsed ? 'U' : 'UDAO' }}</div>
</template>

<style scoped>
.logo {
  display: flex;
  flex: 0 0 48px;
  align-items: center;
  justify-content: center;
  height: 48px;
  overflow: hidden;
  color: #fff;
  font-weight: 700;
  letter-spacing: 1px;
  white-space: nowrap;
}
</style>
