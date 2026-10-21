<script setup lang="ts">
import { computed, reactive, ref, watch } from 'vue'

import CommissionRuleChainPane from '@/views/hr/CommissionRuleChainPane.vue'
import {
  createTierScheme,
  deleteTier,
  deleteTierScheme,
  fetchOrganizationTree,
  fetchTierSchemes,
  updateTierSchemeState,
  upsertTier,
  type OrganizationTreeNode,
} from '@/api/hr'
import type { TierSchemeRecord } from '@/types/hr'
import { usePermissionStore } from '@/stores/permission'
import { getUserFriendlyErrorMessage, notifyError, uiConfirm, uiMessage } from '@/utils/ui'

/**
 * 人事绩效 → 业绩提成 → 划卡提成规则（C2-4）。
 * 项目 = 月阶梯（TK_EmployeeCommission 真实生效路径），次卡/时效卡/储值卡 = 四级费率链。
 * 按任务书不展示产品 Tab（PRODUCT_TREAT = NOT_APPLICABLE）。
 */
defineOptions({ name: 'TreatCommissionRulesView' })

const permissionStore = usePermissionStore()
const hasViewPermission = computed(() => permissionStore.hasPermission('commission:rule:view'))
const hasEditPermission = computed(() => permissionStore.hasPermission('commission:rule:edit'))

const CHAIN_TABS = [
  { itemType: 'GENERAL_CARD', label: '次卡' },
  { itemType: 'TIME_CARD', label: '时效卡' },
  { itemType: 'SAVING_CARD', label: '储值卡' },
]

const activeTab = ref('PROJECT')
const storeTree = ref<OrganizationTreeNode[]>([])
const stores = ref<OrganizationTreeNode[]>([])
const storeId = ref<number | null>(null)
const storeError = ref<string | null>(null)

// —— 阶梯方案状态 ——
const tierLoading = ref(false)
const tierError = ref<string | null>(null)
const schemes = ref<TierSchemeRecord[]>([])

const schemeFormVisible = ref(false)
const schemeSaving = ref(false)
const schemeFormError = ref<string | null>(null)
const schemeForm = reactive({ name: '' })

const tierFormVisible = ref(false)
const tierSaving = ref(false)
const tierFormError = ref<string | null>(null)
const tierForm = reactive({
  schemeId: null as number | null,
  id: null as number | null,
  beginPerformance: 0,
  endPerformance: null as number | null,
  ratePct: 0,
  fixed: 0,
})

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

watch([storeId, activeTab], ([sid, tab]) => {
  if (sid != null && tab === 'PROJECT') {
    void loadSchemes()
  }
}, { immediate: true })

async function loadSchemes(): Promise<void> {
  const sid = storeId.value
  if (sid == null) return
  tierLoading.value = true
  tierError.value = null
  try {
    schemes.value = await fetchTierSchemes(sid)
  } catch (error) {
    schemes.value = []
    tierError.value = getUserFriendlyErrorMessage(error)
  } finally {
    tierLoading.value = false
  }
}

function openSchemeCreate(): void {
  schemeForm.name = ''
  schemeFormError.value = null
  schemeFormVisible.value = true
}

async function submitSchemeCreate(): Promise<void> {
  const sid = storeId.value
  if (sid == null || !schemeForm.name.trim()) {
    schemeFormError.value = '请填写方案名称'
    return
  }
  schemeSaving.value = true
  try {
    await createTierScheme({ storeId: sid, name: schemeForm.name.trim(), active: true })
    uiMessage.success('方案已创建')
    schemeFormVisible.value = false
    await loadSchemes()
  } catch (error) {
    schemeFormError.value = getUserFriendlyErrorMessage(error)
  } finally {
    schemeSaving.value = false
  }
}

async function toggleScheme(s: TierSchemeRecord, active: boolean): Promise<void> {
  try {
    await updateTierSchemeState(s.id, active)
    uiMessage.success(active ? '方案已启用（立即参与月阶梯匹配）' : '方案已停用（不参与计算）')
    await loadSchemes()
  } catch (error) {
    notifyError(getUserFriendlyErrorMessage(error))
  }
}

async function removeScheme(s: TierSchemeRecord): Promise<void> {
  const confirmed = await uiConfirm({ title: '删除阶梯方案', message: `确认删除方案「${s.name}」及其全部档位？` })
  if (!confirmed) return
  try {
    await deleteTierScheme(s.id)
    uiMessage.success('已删除')
    await loadSchemes()
  } catch (error) {
    notifyError(getUserFriendlyErrorMessage(error))
  }
}

function openTierCreate(s: TierSchemeRecord): void {
  tierForm.schemeId = s.id
  tierForm.id = null
  tierForm.beginPerformance = 0
  tierForm.endPerformance = null
  tierForm.ratePct = 0
  tierForm.fixed = 0
  tierFormError.value = null
  tierFormVisible.value = true
}

function openTierEdit(schemeId: number, tierId: number): void {
  const s = schemes.value.find((x) => x.id === schemeId)
  const t = s?.tiers.find((x) => x.id === tierId)
  if (!t) return
  tierForm.schemeId = schemeId
  tierForm.id = t.id
  tierForm.beginPerformance = t.beginPerformance
  tierForm.endPerformance = t.endPerformance ?? null
  tierForm.ratePct = Number(t.rate ?? 0) * 100
  tierForm.fixed = Number(t.fixed ?? 0)
  tierFormError.value = null
  tierFormVisible.value = true
}

async function submitTier(): Promise<void> {
  if (tierForm.schemeId == null) return
  if (tierForm.endPerformance != null && tierForm.endPerformance <= tierForm.beginPerformance) {
    tierFormError.value = '上界必须大于下界（留空表示无上界）'
    return
  }
  tierSaving.value = true
  tierFormError.value = null
  try {
    await upsertTier({
      id: tierForm.id,
      schemeId: tierForm.schemeId,
      beginPerformance: tierForm.beginPerformance,
      endPerformance: tierForm.endPerformance,
      rate: tierForm.ratePct / 100,
      fixed: tierForm.fixed,
    })
    uiMessage.success('档位已保存')
    tierFormVisible.value = false
    await loadSchemes()
  } catch (error) {
    tierFormError.value = getUserFriendlyErrorMessage(error)
  } finally {
    tierSaving.value = false
  }
}

async function removeTier(tierId: number): Promise<void> {
  const confirmed = await uiConfirm({ title: '删除档位', message: '确认删除该档位？' })
  if (!confirmed) return
  try {
    await deleteTier(tierId)
    uiMessage.success('已删除')
    await loadSchemes()
  } catch (error) {
    notifyError(getUserFriendlyErrorMessage(error))
  }
}
</script>

<template>
  <div class="page">
    <div class="page-toolbar">
      <div class="toolbar-item">
        <span class="toolbar-label">门店</span>
        <el-select v-model="storeId" placeholder="选择门店" style="width: 220px" :disabled="!hasViewPermission">
          <el-option v-for="s in stores" :key="s.id" :value="s.id" :label="`${s.entityName ?? ''}（${s.id}）`" />
        </el-select>
      </div>
      <div class="toolbar-tip">
        项目划卡执行员工月阶梯（月累计业绩达档计提）；Fixed 每员工每月仅计提一次。产品划卡不适用（无规则模型）。
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
        <!-- 项目 = 月阶梯 -->
        <el-tab-pane name="PROJECT" label="项目（月阶梯）" lazy>
          <div v-loading="tierLoading" class="tier-wrap">
            <div class="tier-toolbar">
              <span class="tier-note">当前真正生效的计算路径（员工月阶梯），修改即时参与下月/重算。</span>
              <el-button type="primary" :disabled="!hasEditPermission || storeId == null" @click="openSchemeCreate">
                新增方案
              </el-button>
            </div>
            <el-alert v-if="tierError" :title="tierError" type="error" show-icon :closable="false" />

            <el-empty v-if="!tierLoading && schemes.length === 0" description="暂无阶梯方案：项目划卡提成为 0" />
            <el-card v-for="s in schemes" :key="s.id" class="scheme-card" shadow="never">
              <template #header>
                <div class="scheme-header">
                  <span class="scheme-name">{{ s.name }}</span>
                  <el-tag :type="s.active ? 'success' : 'info'" size="small">
                    {{ s.active ? '启用（参与计算）' : '停用' }}
                  </el-tag>
                  <div class="scheme-actions">
                    <el-switch
                      :model-value="s.active"
                      :disabled="!hasEditPermission"
                      @change="(v: string | number | boolean) => toggleScheme(s, Boolean(v))"
                    />
                    <el-button
                      v-if="hasEditPermission"
                      size="small"
                      type="primary"
                      @click="openTierCreate(s)"
                    >新增档位</el-button>
                    <el-button size="small" type="danger" plain :disabled="!hasEditPermission" @click="removeScheme(s)">
                      删除方案
                    </el-button>
                  </div>
                </div>
              </template>
              <el-table :data="s.tiers" border stripe size="small">
                <el-table-column label="档位区间（月累计业绩）" min-width="200">
                  <template #default="{ row }">
                    <span v-if="row.endPerformance != null">[{{ row.beginPerformance }}, {{ row.endPerformance }})</span>
                    <span v-else>≥ {{ row.beginPerformance }}（无上界）</span>
                  </template>
                </el-table-column>
                <el-table-column label="提成率" width="120">
                  <template #default="{ row }">{{ (Number(row.rate ?? 0) * 100).toFixed(2) }}%</template>
                </el-table-column>
                <el-table-column label="固定提成" width="120">
                  <template #default="{ row }">{{ Number(row.fixed ?? 0).toFixed(2) }} 元</template>
                </el-table-column>
                <el-table-column label="操作" width="120">
                  <template #default="{ row }">
                    <el-button link type="primary" :disabled="!hasEditPermission" @click="openTierEdit(s.id, row.id)">
                      编辑
                    </el-button>
                    <el-button link type="danger" :disabled="!hasEditPermission" @click="removeTier(row.id)">
                      删除
                    </el-button>
                  </template>
                </el-table-column>
              </el-table>
            </el-card>
          </div>
        </el-tab-pane>

        <el-tab-pane v-for="t in CHAIN_TABS" :key="t.itemType" :name="t.itemType" :label="t.label" lazy>
          <template v-if="storeId != null">
            <commission-rule-chain-pane :scene="'TREAT'" :item-type="t.itemType" :store-id="storeId" />
          </template>
        </el-tab-pane>
      </el-tabs>
      <div v-if="!hasEditPermission" class="read-only-tip">当前账号仅可查看（编辑需 commission:rule:edit 权限）</div>
    </template>

    <el-dialog v-model="schemeFormVisible" title="新增月阶梯方案" width="420px" destroy-on-close>
      <el-form label-width="90px" @submit.prevent>
        <el-form-item label="方案名称">
          <el-input v-model="schemeForm.name" maxlength="50" placeholder="如：美容师月阶梯" />
        </el-form-item>
        <el-alert v-if="schemeFormError" :title="schemeFormError" type="error" show-icon :closable="false" />
      </el-form>
      <template #footer>
        <el-button @click="schemeFormVisible = false">取消</el-button>
        <el-button type="primary" :loading="schemeSaving" @click="submitSchemeCreate">创建</el-button>
      </template>
    </el-dialog>

    <el-dialog v-model="tierFormVisible" :title="tierForm.id == null ? '新增档位' : '编辑档位'" width="520px" destroy-on-close>
      <el-form label-width="140px" @submit.prevent>
        <el-form-item label="月累计业绩 ≥">
          <el-input-number v-model="tierForm.beginPerformance" :min="0" :step="100" controls-position="right" />
        </el-form-item>
        <el-form-item label="月累计业绩 &lt;">
          <el-input-number
            v-model="tierForm.endPerformance"
            :min="0"
            :step="100"
            controls-position="right"
            placeholder="留空=无上界"
          />
          <span class="form-tip">留空表示该档无上界（区间左闭右开；档位之间不允许重叠）</span>
        </el-form-item>
        <el-form-item label="提成率">
          <el-input-number v-model="tierForm.ratePct" :min="0" :max="999.99" :precision="2" controls-position="right" />
          <span class="form-tip">% ×该员工当月划卡个人基数（Scale 已先拆分）</span>
        </el-form-item>
        <el-form-item label="固定提成">
          <el-input-number v-model="tierForm.fixed" :min="0" :precision="2" controls-position="right" />
          <span class="form-tip">元/员工/月（每人每月仅一次，不乘 Scale）</span>
        </el-form-item>
        <el-alert v-if="tierFormError" :title="tierFormError" type="error" show-icon :closable="false" />
      </el-form>
      <template #footer>
        <el-button @click="tierFormVisible = false">取消</el-button>
        <el-button type="primary" :loading="tierSaving" @click="submitTier">保存</el-button>
      </template>
    </el-dialog>
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

.tier-wrap {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.tier-toolbar {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 12px;
  flex-wrap: wrap;
}

.tier-note {
  color: var(--el-text-color-secondary);
  font-size: 13px;
}

.scheme-card {
  border: 1px solid var(--el-border-color-lighter);
}

.scheme-header {
  display: flex;
  align-items: center;
  gap: 10px;
  flex-wrap: wrap;
}

.scheme-name {
  font-weight: 600;
}

.scheme-actions {
  margin-left: auto;
  display: flex;
  align-items: center;
  gap: 8px;
}

.form-tip {
  margin-left: 8px;
  color: var(--el-text-color-secondary);
  font-size: 12px;
}

.read-only-tip {
  color: var(--el-text-color-secondary);
  font-size: 12px;
}
</style>