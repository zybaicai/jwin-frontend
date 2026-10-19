<script setup lang="ts">
import { computed, nextTick, reactive, ref, watch } from 'vue'
import type { ElTree } from 'element-plus'

import AppEmpty from '@/components/common/AppEmpty.vue'
import AppError from '@/components/common/AppError.vue'
import {
  createOrganization,
  fetchOrganizationTree,
  updateOrganization,
  type OrganizationTreeNode,
} from '@/api/hr'
import { OrgPermission } from '@/types/hr'
import { usePermissionStore } from '@/stores/permission'
import {
  getUserFriendlyErrorMessage,
  notifyError,
  runExclusive,
  uiMessage,
} from '@/utils/ui'

defineOptions({ name: 'OrgStructureView' })

const permissionStore = usePermissionStore()

const hasViewPermission = computed(() =>
  permissionStore.hasPermission(OrgPermission.STORE_VIEW),
)
const hasEditPermission = computed(() =>
  permissionStore.hasPermission(OrgPermission.STORE_EDIT),
)

const loading = ref(false)
const listError = ref<string | null>(null)
const treeData = ref<OrganizationTreeNode[]>([])
const activeOnly = ref(false)
const treeRef = ref<InstanceType<typeof ElTree>>()
const selectedId = ref<number | null>(null)
const selectedNode = ref<OrganizationTreeNode | null>(null)

const formVisible = ref(false)
const formMode = ref<'create' | 'edit'>('create')
const formSaving = ref(false)
const formError = ref<string | null>(null)

const form = reactive({
  parentId: null as number | null,
  name: '',
  store: false,
  warehouse: false,
  active: true,
  sequence: 0,
  addressDetail: '',
})

function nodeLabel(node: OrganizationTreeNode): string {
  return node.entityName?.trim() || `组织#${node.id}`
}

function findNode(
  nodes: OrganizationTreeNode[],
  id: number,
): OrganizationTreeNode | null {
  for (const n of nodes) {
    if (n.id === id) return n
    if (n.children?.length) {
      const hit = findNode(n.children, id)
      if (hit) return hit
    }
  }
  return null
}

async function loadTree(): Promise<void> {
  if (!hasViewPermission.value) {
    treeData.value = []
    selectedId.value = null
    selectedNode.value = null
    listError.value = '暂无权限查看组织（org:store:view）'
    return
  }
  await runExclusive(loading, async () => {
    listError.value = null
    try {
      treeData.value = await fetchOrganizationTree(activeOnly.value)
      await nextTick()
      if (selectedId.value != null) {
        const node = findNode(treeData.value, selectedId.value)
        selectedNode.value = node
        if (node) {
          treeRef.value?.setCurrentKey(selectedId.value)
        } else {
          selectedId.value = null
        }
      }
    } catch (error) {
      treeData.value = []
      listError.value = getUserFriendlyErrorMessage(error)
    }
  })
}

function handleNodeClick(data: OrganizationTreeNode): void {
  selectedId.value = data.id
  selectedNode.value = data
}

function openCreate(parent: OrganizationTreeNode | null): void {
  formMode.value = 'create'
  form.parentId = parent?.id ?? null
  form.name = ''
  form.store = false
  form.warehouse = false
  form.active = true
  form.sequence = 0
  form.addressDetail = ''
  formError.value = null
  formVisible.value = true
}

function openEdit(node: OrganizationTreeNode): void {
  formMode.value = 'edit'
  form.parentId = node.parentId
  form.name = node.entityName ?? ''
  form.store = node.store === true
  form.warehouse = false
  form.active = node.active !== false
  form.sequence = node.sequence ?? 0
  form.addressDetail = ''
  formError.value = null
  formVisible.value = true
}

async function handleSubmit(): Promise<void> {
  if (!hasEditPermission.value) return
  const name = form.name.trim()
  if (!name) {
    uiMessage.warning('请填写组织名称')
    return
  }
  await runExclusive(formSaving, async () => {
    formError.value = null
    try {
      if (formMode.value === 'create') {
        await createOrganization({
          parentId: form.parentId,
          name,
          store: form.store,
          warehouse: form.warehouse,
          addressDetail: form.addressDetail.trim() || undefined,
        })
        uiMessage.success('组织已创建')
      } else if (selectedId.value != null) {
        await updateOrganization(selectedId.value, {
          name,
          store: form.store,
          warehouse: form.warehouse,
          active: form.active,
          addressDetail: form.addressDetail.trim() || undefined,
        })
        uiMessage.success('组织已更新')
      }
      formVisible.value = false
      await loadTree()
    } catch (error) {
      formError.value = getUserFriendlyErrorMessage(error)
      notifyError(error)
    }
  })
}

watch(hasViewPermission, () => void loadTree(), { immediate: true })
</script>

<template>
  <section class="org-structure">
    <header class="page-header">
      <div>
        <h1>组织架构</h1>
        <p class="subtitle">维护组织树与门店标识；门店节点用于员工主店/跨店归属</p>
      </div>
    </header>

    <div class="filter-bar">
      <el-checkbox v-model="activeOnly" @change="loadTree">仅显示启用</el-checkbox>
      <el-button type="primary" :loading="loading" @click="loadTree">刷新</el-button>
      <el-button
        v-if="hasEditPermission"
        type="primary"
        @click="openCreate(null)"
      >
        新增顶级
      </el-button>
      <el-button
        v-if="hasEditPermission && selectedNode"
        @click="openCreate(selectedNode)"
      >
        新增下级
      </el-button>
    </div>

    <div v-loading="loading" class="body-panel">
      <AppError
        v-if="listError && !loading"
        :description="listError"
        @retry="loadTree"
      />
      <template v-else>
        <aside class="tree-pane">
          <el-tree
            v-if="treeData.length"
            ref="treeRef"
            :data="treeData"
            node-key="id"
            highlight-current
            default-expand-all
            :props="{ label: 'entityName', children: 'children' }"
            @node-click="handleNodeClick"
          >
            <template #default="{ data }">
              <span class="tree-node">
                <span>{{ nodeLabel(data) }}</span>
                <el-tag
                  v-if="data.store === true"
                  size="small"
                  type="success"
                  effect="plain"
                >
                  门店
                </el-tag>
                <el-tag
                  v-if="data.active === false"
                  size="small"
                  type="info"
                  effect="plain"
                >
                  停用
                </el-tag>
              </span>
            </template>
          </el-tree>
          <AppEmpty
            v-else-if="!loading"
            title="暂无组织"
            description="可点击「新增顶级」创建组织"
          />
        </aside>

        <div class="detail-pane">
          <template v-if="selectedNode">
            <h2>{{ nodeLabel(selectedNode) }}</h2>
            <el-descriptions :column="1" border size="small">
              <el-descriptions-item label="ID">{{ selectedNode.id }}</el-descriptions-item>
              <el-descriptions-item label="父级">
                {{ selectedNode.parentId ?? '—' }}
              </el-descriptions-item>
              <el-descriptions-item label="门店">
                {{ selectedNode.store === true ? '是' : '否' }}
              </el-descriptions-item>
              <el-descriptions-item label="状态">
                {{ selectedNode.active !== false ? '启用' : '停用' }}
              </el-descriptions-item>
              <el-descriptions-item label="排序">
                {{ selectedNode.sequence ?? 0 }}
              </el-descriptions-item>
            </el-descriptions>
            <div v-if="hasEditPermission" class="detail-actions">
              <el-button type="primary" @click="openEdit(selectedNode)">编辑</el-button>
              <el-button @click="openCreate(selectedNode)">新增下级</el-button>
            </div>
          </template>
          <AppEmpty
            v-else
            title="请选择组织节点"
            description="在左侧树中点击节点查看详情"
          />
        </div>
      </template>
    </div>

    <el-dialog
      v-model="formVisible"
      :title="formMode === 'create' ? '新增组织' : '编辑组织'"
      width="480px"
      destroy-on-close
      :close-on-click-modal="false"
    >
      <AppError v-if="formError" :description="formError" />
      <el-form label-width="90px" @submit.prevent>
        <el-form-item v-if="formMode === 'create'" label="上级">
          <span>{{ form.parentId == null ? '（顶级）' : `组织#${form.parentId}` }}</span>
        </el-form-item>
        <el-form-item label="名称" required>
          <el-input v-model="form.name" maxlength="100" show-word-limit placeholder="组织名称" />
        </el-form-item>
        <el-form-item label="门店">
          <el-switch v-model="form.store" active-text="是" inactive-text="否" />
        </el-form-item>
        <el-form-item label="仓库">
          <el-switch v-model="form.warehouse" active-text="是" inactive-text="否" />
        </el-form-item>
        <el-form-item v-if="formMode === 'edit'" label="状态">
          <el-switch v-model="form.active" active-text="启用" inactive-text="停用" />
        </el-form-item>
        <el-form-item v-if="formMode === 'edit'" label="排序">
          <el-input-number v-model="form.sequence" :step="1" controls-position="right" />
        </el-form-item>
        <el-form-item label="地址">
          <el-input v-model="form.addressDetail" maxlength="200" placeholder="可选" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button :disabled="formSaving" @click="formVisible = false">取消</el-button>
        <el-button
          type="primary"
          :loading="formSaving"
          :disabled="!hasEditPermission"
          @click="handleSubmit"
        >
          保存
        </el-button>
      </template>
    </el-dialog>
  </section>
</template>

<style scoped>
.org-structure {
  display: flex;
  flex-direction: column;
  gap: 16px;
  min-height: 100%;
  padding: 20px 24px 24px;
}

.page-header h1 {
  margin: 0 0 4px;
  font-size: 20px;
  font-weight: 600;
  color: #303133;
}

.subtitle {
  margin: 0;
  font-size: 13px;
  color: #909399;
}

.filter-bar {
  display: flex;
  flex-wrap: wrap;
  gap: 10px;
  align-items: center;
  padding: 12px 14px;
  background: #fff;
  border: 1px solid #ebeef5;
  border-radius: 4px;
}

.body-panel {
  display: grid;
  grid-template-columns: minmax(260px, 360px) 1fr;
  gap: 16px;
  min-height: 420px;
}

.tree-pane,
.detail-pane {
  padding: 14px;
  border: 1px solid #ebeef5;
  border-radius: 8px;
  background: #fff;
  min-height: 360px;
}

.tree-node {
  display: inline-flex;
  align-items: center;
  gap: 6px;
}

.detail-pane h2 {
  margin: 0 0 12px;
  font-size: 16px;
  font-weight: 600;
  color: #303133;
}

.detail-actions {
  margin-top: 16px;
  display: flex;
  gap: 8px;
}

@media (max-width: 900px) {
  .body-panel {
    grid-template-columns: 1fr;
  }
}
</style>
