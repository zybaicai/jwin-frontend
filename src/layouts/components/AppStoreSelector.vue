<script setup lang="ts">
import { computed, nextTick, ref } from 'vue'
import type { ElTree } from 'element-plus'

import { useStoreStore } from '@/stores/store'
import type { OrgScopeTreeNode } from '@/types/auth'
import { notifyError } from '@/utils/ui'

const storeStore = useStoreStore()
const popoverVisible = ref(false)
const treeRef = ref<InstanceType<typeof ElTree>>()

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

const hasOrgTree = computed(() => storeStore.orgScopeTree.length > 0)

const treeProps = {
  label: 'name',
  children: 'children',
}

async function selectStore(targetStoreId: number): Promise<void> {
  if (!Number.isInteger(targetStoreId) || storeStore.switching) {
    return
  }
  if (targetStoreId === storeStore.currentStoreId) {
    popoverVisible.value = false
    return
  }
  try {
    await storeStore.switchStore(targetStoreId)
    popoverVisible.value = false
  } catch (error) {
    notifyError(error)
  }
}

function onTreeNodeClick(data: OrgScopeTreeNode): void {
  if (!data.store) {
    void nextTick(() => {
      treeRef.value?.setCurrentKey(storeStore.currentStoreId)
    })
    return
  }
  void selectStore(data.id)
}
</script>

<template>
  <el-popover
    v-model:visible="popoverVisible"
    placement="bottom-start"
    :width="280"
    trigger="click"
    :disabled="storeStore.switching"
    popper-class="app-store-selector-popper"
  >
    <template #reference>
      <button type="button" class="store-trigger" :disabled="storeStore.switching">
        <span class="store-name">{{ currentLabel }}</span>
        <span aria-hidden="true">▼</span>
      </button>
    </template>

    <div class="store-panel" v-loading="storeStore.switching">
      <el-tree
        v-if="hasOrgTree"
        ref="treeRef"
        :data="storeStore.orgScopeTree"
        :props="treeProps"
        node-key="id"
        highlight-current
        default-expand-all
        :expand-on-click-node="false"
        :current-node-key="storeStore.currentStoreId ?? undefined"
        @node-click="onTreeNodeClick"
      >
        <template #default="{ data }">
          <span
            class="store-tree-node"
            :class="{
              'is-store': data.store,
              'is-current': data.store && data.id === storeStore.currentStoreId,
              'is-org': !data.store,
            }"
          >
            {{ data.name }}
          </span>
        </template>
      </el-tree>

      <ul v-else class="store-flat-list">
        <li
          v-for="store in storeStore.availableStores"
          :key="store.id"
          class="store-flat-item"
          :class="{
            'is-current': store.id === storeStore.currentStoreId,
            'is-disabled': store.id === storeStore.currentStoreId || storeStore.switching,
          }"
        >
          <button
            type="button"
            :disabled="store.id === storeStore.currentStoreId || storeStore.switching"
            @click="selectStore(store.id)"
          >
            {{ store.name }}
          </button>
        </li>
        <li v-if="storeStore.availableStores.length === 0" class="store-empty">暂无可切换门店</li>
      </ul>
    </div>
  </el-popover>
</template>

<style scoped>
.store-trigger {
  display: inline-flex;
  align-items: center;
  max-width: 220px;
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

.store-panel {
  max-height: 360px;
  overflow: auto;
}

.store-tree-node {
  flex: 1;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
  font-size: 13px;
  line-height: 22px;
}

.store-tree-node.is-org {
  color: var(--el-text-color-secondary);
  cursor: default;
}

.store-tree-node.is-store {
  color: var(--el-text-color-primary);
  cursor: pointer;
}

.store-tree-node.is-current {
  color: var(--el-color-primary);
  font-weight: 600;
}

.store-flat-list {
  margin: 0;
  padding: 0;
  list-style: none;
}

.store-flat-item button {
  display: block;
  width: 100%;
  padding: 8px 12px;
  border: 0;
  background: transparent;
  color: inherit;
  text-align: left;
  cursor: pointer;
  font: inherit;
}

.store-flat-item button:hover:not(:disabled) {
  background: var(--el-fill-color-light);
}

.store-flat-item.is-current button,
.store-flat-item.is-disabled button {
  color: var(--el-color-primary);
  cursor: default;
}

.store-empty {
  padding: 12px;
  color: var(--el-text-color-secondary);
  font-size: 13px;
  text-align: center;
}
</style>
