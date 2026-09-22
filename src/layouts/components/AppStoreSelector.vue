<script setup lang="ts">
import { computed } from 'vue'

import { useStoreStore } from '@/stores/store'
import { notifyError } from '@/utils/ui'

const storeStore = useStoreStore()

const currentLabel = computed(() => {
  if (storeStore.switching) {
    return '切换中...'
  }
  if (storeStore.currentStoreName) {
    return storeStore.currentStoreName
  }
  if (storeStore.currentStoreId != null) {
    return String(storeStore.currentStoreId)
  }
  return '未选择门店'
})

function storeLabel(storeId: number): string {
  if (storeId === storeStore.currentStoreId && storeStore.currentStoreName) {
    return storeStore.currentStoreName
  }
  return String(storeId)
}

async function onSelectStore(command: string | number | object): Promise<void> {
  if (typeof command !== 'string' && typeof command !== 'number') {
    return
  }
  const targetStoreId = Number(command)
  if (!Number.isInteger(targetStoreId) || storeStore.switching) {
    return
  }
  if (targetStoreId === storeStore.currentStoreId) {
    return
  }
  try {
    await storeStore.switchStore(targetStoreId)
  } catch (error) {
    notifyError(error)
  }
}
</script>

<template>
  <el-dropdown trigger="click" :disabled="storeStore.switching" @command="onSelectStore">
    <button type="button" class="store-trigger" :disabled="storeStore.switching">
      <span class="store-name">{{ currentLabel }}</span>
      <span aria-hidden="true">▼</span>
    </button>
    <template #dropdown>
      <el-dropdown-menu>
        <el-dropdown-item
          v-for="storeId in storeStore.availableStoreIds"
          :key="storeId"
          :command="storeId"
          :disabled="storeId === storeStore.currentStoreId || storeStore.switching"
        >
          {{ storeLabel(storeId) }}
        </el-dropdown-item>
      </el-dropdown-menu>
    </template>
  </el-dropdown>
</template>

<style scoped>
.store-trigger {
  display: inline-flex;
  align-items: center;
  max-width: 180px;
  gap: 4px;
  padding: 0;
  border: 0;
  background: transparent;
  color: inherit;
  cursor: pointer;
  font: inherit;
}

.store-trigger:disabled {
  cursor: not-allowed;
}

.store-name {
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}
</style>
