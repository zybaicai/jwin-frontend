<script setup lang="ts">
import { computed, reactive, ref, watch } from 'vue'

import {
  deleteCommissionRule,
  fetchCommissionRuleMeta,
  fetchCommissionRules,
  fetchHandlerRoles,
  fetchJobTypePage,
  upsertCommissionRule,
} from '@/api/hr'
import { fetchGoodsList } from '@/api/catalog'
import type {
  CommissionRuleMeta,
  CommissionRuleRecord,
  HandlerRoleRecord,
  JobTypeRecord,
} from '@/types/hr'
import type { GoodsItem } from '@/types/catalog'
import { getUserFriendlyErrorMessage, notifyError, uiConfirm, uiMessage } from '@/utils/ui'

/**
 * 提成规则四级费率链面板（C2-4）。
 * meta 驱动真实字段：只展示该品类真实存在的桶/层级配置维度，不伪造字段。
 * 规则表无启停列（真实结构）→ 用删除/重建（upsert=替换）。
 */
defineOptions({ name: 'CommissionRuleChainPane' })

const props = defineProps<{
  scene: 'SALE' | 'TREAT'
  itemType: string
  storeId: number
}>()

const LEVEL_LABELS: Record<string, string> = {
  HANDLER_JOB_TYPE: '经手角色 + 职务',
  HANDLER: '经手角色',
  ITEM: '商品/卡项',
  SCHEME: '门店默认',
}

const loading = ref(false)
const listError = ref<string | null>(null)
const meta = ref<CommissionRuleMeta | null>(null)
const level = ref('ITEM')
const records = ref<CommissionRuleRecord[]>([])

const formVisible = ref(false)
const formSaving = ref(false)
const formError = ref<string | null>(null)
const goodsOptions = ref<GoodsItem[]>([])
const handlerRoles = ref<HandlerRoleRecord[]>([])
const jobTypes = ref<JobTypeRecord[]>([])

const form = reactive({
  itemId: null as number | null,
  handlerRoleId: null as number | null,
  jobTypeId: null as number | null,
  rates: {} as Record<string, { ratePct: number; fixed: number }>,
})

const metaBuckets = computed(() => meta.value?.buckets ?? [])
const needHandler = computed(() => level.value === 'HANDLER' || level.value === 'HANDLER_JOB_TYPE')
const needJobType = computed(() => level.value === 'HANDLER_JOB_TYPE')

async function loadMeta(): Promise<void> {
  try {
    meta.value = await fetchCommissionRuleMeta(props.scene, props.itemType)
    if (!meta.value.levels.includes(level.value)) {
      level.value = meta.value.levels.includes('ITEM') ? 'ITEM' : meta.value.levels[0]
    }
  } catch (error) {
    meta.value = null
    listError.value = getUserFriendlyErrorMessage(error)
  }
}

async function loadList(): Promise<void> {
  listError.value = null
  await Promise.all([loadMeta()])
  if (!meta.value) {
    records.value = []
    return
  }
  loading.value = true
  try {
    records.value = await fetchCommissionRules({
      scene: props.scene,
      itemType: props.itemType,
      level: level.value,
      storeId: props.storeId,
    })
  } catch (error) {
    records.value = []
    listError.value = getUserFriendlyErrorMessage(error)
  } finally {
    loading.value = false
  }
}

async function loadFormOptions(): Promise<void> {
  const m = meta.value
  if (!m) return
  const tasks: Promise<unknown>[] = []
  if (m.itemCatalogType) {
    tasks.push(
      fetchGoodsList({ itemType: m.itemCatalogType }).then((rows) => {
        goodsOptions.value = rows
      }),
    )
  }
  if (m.handlerBizType) {
    tasks.push(
      fetchHandlerRoles({ bizType: m.handlerBizType, storeId: props.storeId, onlyActive: false }).then(
        (rows) => {
          handlerRoles.value = rows
        },
      ),
    )
  }
  tasks.push(
    fetchJobTypePage({ size: 500 }).then((p) => {
      jobTypes.value = p.records ?? []
    }),
  )
  await Promise.all(tasks)
}

watch(
  () => [props.itemType, props.storeId],
  () => {
    void loadList()
  },
  { immediate: true },
)

watch(level, () => {
  void loadList()
})

function openCreate(): void {
  form.itemId = null
  form.handlerRoleId = null
  form.jobTypeId = null
  form.rates = {}
  for (const b of metaBuckets.value) {
    form.rates[b.code] = { ratePct: 0, fixed: 0 }
  }
  formError.value = null
  void loadFormOptions().then(() => {
    formVisible.value = true
  })
}

type RuleRowLike = CommissionRuleRecord | Record<string, any>

function openEdit(row: RuleRowLike): void {
  form.itemId = row.itemId
  form.handlerRoleId = row.handlerRoleId
  form.jobTypeId = row.jobTypeId
  form.rates = {}
  for (const b of metaBuckets.value) {
    const hit = (row.rates ?? []).find((x: { bucket: string }) => x.bucket === b.code)
    form.rates[b.code] = {
      ratePct: Number(hit?.rate ?? 0) * 100,
      fixed: Number(hit?.fixed ?? 0),
    }
  }
  formError.value = null
  void loadFormOptions().then(() => {
    formVisible.value = true
  })
}

async function submitForm(): Promise<void> {
  const m = meta.value
  if (!m) return
  if (level.value !== 'SCHEME' && form.itemId == null) {
    formError.value = '请选择商品/卡项（该层级规则按商品维度生效）'
    return
  }
  if (needHandler.value && form.handlerRoleId == null) {
    formError.value = '请选择经手角色'
    return
  }
  if (needJobType.value && form.jobTypeId == null) {
    formError.value = '请选择职务'
    return
  }
  formSaving.value = true
  formError.value = null
  try {
    await upsertCommissionRule({
      scene: props.scene,
      itemType: props.itemType,
      level: level.value,
      storeId: props.storeId,
      itemId: level.value === 'SCHEME' ? undefined : form.itemId,
      handlerRoleId: needHandler.value ? form.handlerRoleId : undefined,
      jobTypeId: needJobType.value ? form.jobTypeId : undefined,
      rates: metaBuckets.value.map((b) => {
        const r = form.rates[b.code] ?? { ratePct: 0, fixed: 0 }
        return {
          bucket: b.code,
          rate: r.ratePct / 100,
          fixed: r.fixed,
        }
      }),
    })
    uiMessage.success('提成规则已保存')
    formVisible.value = false
    await loadList()
  } catch (error) {
    formError.value = getUserFriendlyErrorMessage(error)
  } finally {
    formSaving.value = false
  }
}

async function handleDelete(row: RuleRowLike): Promise<void> {
  const confirmed = await uiConfirm({
    title: '删除提成规则',
    message: '删除影响未来计算及人工重新计算的历史月份；已保存的既有提成快照不会自动改变。',
  })
  if (!confirmed) return
  try {
    await deleteCommissionRule({
      scene: props.scene,
      itemType: props.itemType,
      level: row.level,
      storeId: row.storeId,
      itemId: row.itemId,
      handlerRoleId: row.handlerRoleId,
      jobTypeId: row.jobTypeId,
    })
    uiMessage.success('已删除')
    await loadList()
  } catch (error) {
    notifyError(getUserFriendlyErrorMessage(error))
  }
}

function rateOf(row: RuleRowLike, bucket: string): number {
  return Number((row.rates ?? []).find((x: { bucket: string; rate?: number | null }) => x.bucket === bucket)?.rate ?? 0) * 100
}

function fixedOf(row: RuleRowLike, bucket: string): number {
  return Number((row.rates ?? []).find((x: { bucket: string; fixed?: number | null }) => x.bucket === bucket)?.fixed ?? 0)
}
</script>

<template>
  <div class="rule-chain-pane">
    <div class="pane-toolbar">
      <span v-if="meta" class="pane-meta">规则模型：四级费率链（HJT → 经手 → 商品 → 门店默认，最具体优先）</span>
      <span v-else class="pane-meta pane-meta-error">{{ listError ?? '未加载到规则元数据' }}</span>
      <div class="pane-actions">
        <el-select v-model="level" style="width: 190px" size="default">
          <el-option
            v-for="lv in meta?.levels ?? []"
            :key="lv"
            :value="lv"
            :label="LEVEL_LABELS[lv] ?? lv"
          />
        </el-select>
        <el-button type="primary" :disabled="!meta" @click="openCreate">新增规则</el-button>
      </div>
    </div>

    <el-alert
      v-if="listError && records.length === 0"
      :title="listError"
      type="error"
      show-icon
      :closable="false"
    />

    <el-table v-loading="loading" :data="records" border stripe>
      <el-table-column prop="itemId" label="商品/卡项ID" width="110" />
      <el-table-column prop="itemName" label="名称" min-width="150" show-overflow-tooltip>
        <template #default="{ row }">
          <span v-if="row.itemName">{{ row.itemName }}</span>
          <el-tag v-else type="info" size="small">全店默认</el-tag>
        </template>
      </el-table-column>
      <el-table-column prop="handlerRoleName" label="经手角色" min-width="120">
        <template #default="{ row }">
          <span v-if="row.handlerRoleName">{{ row.handlerRoleName }}</span>
          <span v-else class="cell-muted">—</span>
        </template>
      </el-table-column>
      <el-table-column prop="jobTypeName" label="职务" min-width="100">
        <template #default="{ row }">
          <span v-if="row.jobTypeName">{{ row.jobTypeName }}</span>
          <span v-else class="cell-muted">—</span>
        </template>
      </el-table-column>
      <el-table-column
        v-for="b in metaBuckets"
        :key="b.code"
        :label="`${b.label}`"
        min-width="170"
      >
        <template #default="{ row }">
          <div class="bucket-cell">
            <span>率 {{ rateOf(row, b.code).toFixed(2) }}%</span>
            <span>固定 {{ fixedOf(row, b.code).toFixed(2) }}</span>
          </div>
        </template>
      </el-table-column>
      <el-table-column label="操作" width="130" fixed="right">
        <template #default="{ row }">
          <el-button link type="primary" @click="openEdit(row)">编辑</el-button>
          <el-button link type="danger" @click="handleDelete(row)">删除</el-button>
        </template>
      </el-table-column>
      <template #empty>
        <el-empty description="未配置提成规则，该类型提成为 0（不会回退到项目费率，也不会报错）" />
      </template>
    </el-table>

    <el-dialog
      v-model="formVisible"
      :title="`新增/编辑提成规则（${meta?.label ?? ''}）`"
      width="620px"
      destroy-on-close
    >
      <el-form label-width="130px" @submit.prevent>
        <el-form-item v-if="level === 'SCHEME'" label="范围">
          <el-tag>门店默认（该品类所有单据兜底）</el-tag>
        </el-form-item>
        <el-form-item v-else label="商品/卡项">
          <el-select
            v-model="form.itemId"
            filterable
            placeholder="选择商品/卡项"
            style="width: 100%"
          >
            <el-option
              v-for="g in goodsOptions"
              :key="g.itemId ?? 0"
              :value="g.itemId ?? 0"
              :label="`[${g.itemId}] ${g.name ?? ''}`"
            />
          </el-select>
        </el-form-item>
        <el-form-item v-if="needHandler" label="经手角色">
          <el-select v-model="form.handlerRoleId" placeholder="选择经手角色" style="width: 100%">
            <el-option
              v-for="r in handlerRoles"
              :key="r.id"
              :value="r.id"
              :label="r.name"
            />
          </el-select>
        </el-form-item>
        <el-form-item v-if="needJobType" label="职务">
          <el-select v-model="form.jobTypeId" placeholder="选择职务" style="width: 100%">
            <el-option
              v-for="j in jobTypes"
              :key="j.id"
              :value="j.id"
              :label="j.name"
            />
          </el-select>
        </el-form-item>
        <el-divider content-position="left">费率（按该品类真实存在的计提桶配置）</el-divider>
        <el-form-item v-for="b in metaBuckets" :key="b.code" :label="b.label">
          <div class="rate-input-row">
            <el-input-number v-model="form.rates[b.code]!.ratePct" :min="0" :max="999.99" :precision="2" controls-position="right" />
            <span class="rate-unit">% ×基数</span>
            <el-input-number v-model="form.rates[b.code]!.fixed" :min="0" :precision="2" controls-position="right" />
            <span class="rate-unit">固定元（不乘 Scale）</span>
          </div>
        </el-form-item>
        <el-alert v-if="formError" :title="formError" type="error" show-icon :closable="false" />
      </el-form>
      <template #footer>
        <el-button @click="formVisible = false">取消</el-button>
        <el-button type="primary" :loading="formSaving" @click="submitForm">保存</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<style scoped>
.rule-chain-pane {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.pane-toolbar {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 12px;
  flex-wrap: wrap;
}

.pane-meta {
  color: var(--el-text-color-secondary);
  font-size: 13px;
}

.pane-meta-error {
  color: var(--el-color-danger);
}

.pane-actions {
  display: flex;
  gap: 8px;
  align-items: center;
}

.bucket-cell {
  display: flex;
  gap: 10px;
  font-variant-numeric: tabular-nums;
}

.cell-muted {
  color: var(--el-text-color-placeholder);
}

.rate-input-row {
  display: flex;
  align-items: center;
  gap: 6px;
  flex-wrap: wrap;
}

.rate-unit {
  color: var(--el-text-color-secondary);
  font-size: 12px;
}
</style>