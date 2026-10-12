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
  flex: 0 0 52px;
  align-items: center;
  justify-content: center;
  height: 52px;
  overflow: hidden;
  color: #f8fafc;
  font-weight: 700;
  letter-spacing: 1.5px;
  white-space: nowrap;
  border-bottom: 1px solid rgba(148, 163, 184, 0.12);
  background: rgba(15, 23, 42, 0.6);
}
</style>
