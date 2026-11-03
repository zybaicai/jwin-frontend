<script setup lang="ts">
import { computed, nextTick, ref, watch } from 'vue'
import type { ElTree } from 'element-plus'

import type { OrganizationTreeNode } from '@/api/organization'

const props = withDefaults(
  defineProps<{
    data: OrganizationTreeNode[]
    loading?: boolean
  }>(),
  { loading: false },
)

/** 选中的门店实体 ID（后端仅接受 store=true 的实体） */
const modelValue = defineModel<number[]>({ default: () => [] })
/** 已勾选的节点数（含联动勾选的父节点） */
const checkedCount = defineModel<number>('checkedCount', { default: 0 })

const treeRef = ref<InstanceType<typeof ElTree>>()
const keyword = ref('')
const syncing = ref(false)

const total = computed(() => countNodes(props.data))

function countNodes(nodes: OrganizationTreeNode[]): number {
  let count = 0
  const walk = (list: OrganizationTreeNode[]) => {
    for (const node of list) {
      count += 1
      if (node.children?.length) walk(node.children)
    }
  }
  walk(nodes)
  return count
}

function collectStoreIds(nodes: OrganizationTreeNode[]): number[] {
  const ids: number[] = []
  const walk = (list: OrganizationTreeNode[]) => {
    for (const node of list) {
      if (node.store === true) ids.push(node.id)
      if (node.children?.length) walk(node.children)
    }
  }
  walk(nodes)
  return ids
}

function storeIdsOfChecked(): number[] {
  const nodes = (treeRef.value?.getCheckedNodes(false) ?? []) as OrganizationTreeNode[]
  return nodes.filter((node) => node.store === true).map((node) => node.id)
}

function syncFromTree(): void {
  modelValue.value = storeIdsOfChecked()
  checkedCount.value = treeRef.value?.getCheckedKeys(false).length ?? 0
}

function applyKeys(keys: number[]): void {
  const tree = treeRef.value
  if (!tree) return
  syncing.value = true
  tree.setCheckedKeys(keys)
  syncing.value = false
  syncFromTree()
}

function handleCheck(): void {
  if (syncing.value) return
  syncFromTree()
}

function selectAll(): void {
  applyKeys(collectStoreIds(props.data))
}

function clearAll(): void {
  applyKeys([])
}

function setExpanded(expanded: boolean): void {
  const walk = (list: OrganizationTreeNode[]) => {
    for (const node of list) {
      const treeNode = treeRef.value?.getNode(node.id)
      if (treeNode) treeNode.expanded = expanded
      if (node.children?.length) walk(node.children)
    }
  }
  walk(props.data)
}

/** 默认只展开顶级组织，下级保持收起（与图2一致） */
function resetExpansion(): void {
  const walk = (list: OrganizationTreeNode[], depth: number) => {
    for (const node of list) {
      const treeNode = treeRef.value?.getNode(node.id)
      if (treeNode) treeNode.expanded = depth === 0
      if (node.children?.length) walk(node.children, depth + 1)
    }
  }
  walk(props.data, 0)
}

function filterNode(value: string, data: { entityName?: string | null }): boolean {
  if (!value) return true
  return (data.entityName ?? '').includes(value.trim())
}

watch(keyword, (value) => {
  treeRef.value?.filter(value.trim())
})

function sameIds(left: number[], right: number[]): boolean {
  if (left.length !== right.length) return false
  const set = new Set(left)
  return right.every((id) => set.has(id))
}

async function applyModel(): Promise<void> {
  await nextTick()
  if (sameIds(modelValue.value, storeIdsOfChecked())) return
  applyKeys([...modelValue.value])
}

watch(
  () => [props.data, modelValue.value] as const,
  () => {
    void applyModel()
  },
)

watch(
  () => props.data,
  async () => {
    await nextTick()
    resetExpansion()
  },
  { immediate: true },
)
</script>

<template>
  <div class="org-scope">
    <el-alert
      class="scope-alert"
      type="info"
      :closable="false"
      show-icon
      title="适用于同级所有节点，则只需勾选父节点。比如：适用于所有节点，只需勾选“顶级/第一个”节点。"
    />
    <div class="scope-toolbar">
      <el-input v-model="keyword" clearable placeholder="搜索组织名称" style="width: 200px" />
      <el-button @click="setExpanded(true)">展开全部</el-button>
      <el-button @click="setExpanded(false)">收起全部</el-button>
      <el-button @click="selectAll">全选</el-button>
      <el-button :disabled="checkedCount === 0" @click="clearAll">清空</el-button>
      <span class="scope-count">已选 {{ checkedCount }} / {{ total }} 个组织</span>
    </div>
    <div v-loading="loading" class="scope-tree-wrap">
      <el-tree
        ref="treeRef"
        :data="data"
        node-key="id"
        show-checkbox
        :filter-node-method="filterNode"
        :props="{ label: 'entityName', children: 'children' }"
        empty-text="暂无组织数据"
        @check="handleCheck"
      >
        <template #default="{ data }">
          <span class="org-node">
            <span>{{ data.entityName || `组织#${data.id}` }}</span>
            <el-tag
              v-if="data.store === true"
              size="small"
              type="success"
              effect="plain"
            >
              门店
            </el-tag>
          </span>
        </template>
      </el-tree>
    </div>
  </div>
</template>

<style scoped>
.scope-alert {
  margin-bottom: 12px;
}

.scope-toolbar {
  display: flex;
  flex-wrap: wrap;
  align-items: center;
  gap: 8px;
  margin-bottom: 12px;
}

.scope-count {
  color: #909399;
  font-size: 13px;
}

.scope-tree-wrap {
  max-height: 420px;
  overflow: auto;
  padding: 8px;
  border: 1px solid #ebeef5;
  border-radius: 4px;
}

.scope-tree :deep(.el-tree-node__content) {
  height: 32px;
  border-radius: 4px;
}

.org-node {
  display: inline-flex;
  align-items: center;
  gap: 8px;
  font-size: 13px;
}
</style>
