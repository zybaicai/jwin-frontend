<script setup lang="ts">
import { computed, ref, watch } from 'vue'

import CommissionRuleChainPane from '@/views/hr/CommissionRuleChainPane.vue'
import { fetchOrganizationTree, type OrganizationTreeNode } from '@/api/hr'
import { usePermissionStore } from '@/stores/permission'
import { getUserFriendlyErrorMessage } from '@/utils/ui'

/**
 * 人事绩效 → 业绩提成 → 销售提成规则（C2-4）。
 * 销售六品类：项目 / 产品 / 储值卡 / 次卡 / 时效卡 / 套餐。
 * 字段维度完全由后端 meta 驱动（真实存在的桶才展示）。
 */
defineOptions({ name: 'SaleCommissionRulesView' })

const permissionStore = usePermissionStore()
const hasViewPermission = computed(() => permissionStore.hasPermission('commission:rule:view'))
const hasEditPermission = computed(() => permissionStore.hasPermission('commission:rule:edit'))

const TABS = [
  { itemType: 'PROJECT', label: '项目' },
  { itemType: 'PRODUCT', label: '产品' },
  { itemType: 'SAVING_CARD', label: '储值卡' },
  { itemType: 'GENERAL_CARD', label: '次卡' },
  { itemType: 'TIME_CARD', label: '时效卡' },
  { itemType: 'PACKAGE_CARD', label: '套餐' },
]

const activeTab = ref('PROJECT')
const storeTree = ref<OrganizationTreeNode[]>([])
const stores = ref<OrganizationTreeNode[]>([])
const storeId = ref<number | null>(null)
const storeError = ref<string | null>(null)

async function loadStores(): Promise<void> {
  try {
    storeTree.value = await fetchOrganizationTree()
    const found: OrganizationTreeNode[] = []
    const walk = (nodes: OrganizationTreeNode[]): void => {
      for (const n of nodes) {
        if (n.store) {
          found.push(n)
        }
        if (n.children?.length) {
          walk(n.children)
        }
      }
    }
    walk(storeTree.value)
    stores.value = found
    if (found.length > 0 && storeId.value == null) {
      storeId.value = found[0].id
    }
    if (found.length === 0) {
      storeError.value = '当前账号没有可用门店，请联系管理员检查数据权限'
    }
  } catch (error) {
    storeError.value = getUserFriendlyErrorMessage(error)
  }
}

watch(
  () => hasViewPermission.value,
  (v) => {
    if (v && stores.value.length === 0) {
      void loadStores()
    }
  },
  { immediate: true },
)
</script>

<template>
  <div class="page commission-rules-page">
    <div class="page-toolbar">
      <div class="toolbar-item">
        <span class="toolbar-label">门店</span>
        <el-select v-model="storeId" placeholder="选择门店" style="width: 220px" :disabled="!hasViewPermission">
          <el-option v-for="s in stores" :key="s.id" :value="s.id" :label="`${s.entityName ?? ''}（${s.id}）`" />
        </el-select>
      </div>
      <div class="toolbar-tip">
        套餐销售按母套餐规则计提一次；子项目/产品不重复销售计提（套餐后续划卡按对应划卡规则计算）。
        未配置提成规则时，该类型提成为 0。
      </div>
    </div>

    <el-alert
      v-if="!hasViewPermission"
      title="暂无权限查看提成规则（commission:rule:view）"
      type="warning"
      show-icon
      :closable="false"
    />
    <el-alert v-else-if="storeError" :title="storeError" type="error" show-icon :closable="false" />

    <template v-else>
      <el-tabs v-model="activeTab" type="border-card">
        <el-tab-pane v-for="t in TABS" :key="t.itemType" :name="t.itemType" :label="t.label" lazy>
          <template v-if="storeId != null">
            <commission-rule-chain-pane
              :scene="'SALE'"
              :item-type="t.itemType"
              :store-id="storeId"
            />
          </template>
        </el-tab-pane>
      </el-tabs>
      <div v-if="!hasEditPermission" class="read-only-tip">当前账号仅可查看（编辑需 commission:rule:edit 权限）</div>
    </template>
  </div>
</template>

<style scoped>
.page {
  display: flex;
  flex-direction: column;
  gap: 12px;
  height: 100%;
  overflow-y: auto;
}

.page-toolbar {
  display: flex;
  align-items: center;
  gap: 16px;
  flex-wrap: wrap;
}

.toolbar-item {
  display: flex;
  align-items: center;
  gap: 8px;
}

.toolbar-label {
  color: var(--el-text-color-regular);
  font-weight: 600;
}

.toolbar-tip {
  color: var(--el-text-color-secondary);
  font-size: 12px;
}

.read-only-tip {
  color: var(--el-text-color-secondary);
  font-size: 12px;
}
</style>