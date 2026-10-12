<script setup lang="ts">
import { computed, ref, watch } from 'vue'

import { fetchHandlerCandidates } from '@/api/handler'
import type { HandlerCandidateEmployee } from '@/types/handler'
import { getUserFriendlyErrorMessage, runExclusive, uiMessage } from '@/utils/ui'

defineOptions({ name: 'CashierHandlerEditor' })

export interface HandlerDraftRow {
  employeeId: string
  employeeName: string
  ratio: number | null
}

const props = defineProps<{
  bizType: string
  storeId: number | null
  disabled?: boolean
  /** chips：行内点击弹出；panel：底部展开区 */
  variant?: 'chips' | 'panel'
  emptyText?: string
}>()

const model = defineModel<HandlerDraftRow[]>({ default: () => [] })

const dialogVisible = ref(false)
const loading = ref(false)
const candidates = ref<HandlerCandidateEmployee[]>([])
const keyword = ref('')
const draft = ref<HandlerDraftRow[]>([])

const ratioSum = computed(() => {
  let sum = 0
  let filled = 0
  for (const row of model.value) {
    if (row.ratio != null && Number.isFinite(row.ratio)) {
      sum += row.ratio
      filled += 1
    }
  }
  return { sum: Number(sum.toFixed(2)), filled, allEmpty: filled === 0 }
})

const ratioValid = computed(() => {
  if (model.value.length === 0) {
    return false
  }
  if (ratioSum.value.allEmpty) {
    return true
  }
  return Math.abs(ratioSum.value.sum - 100) < 0.0001
})

function equalRatios(count: number): number[] {
  if (count <= 0) {
    return []
  }
  const base = Math.floor((10000 / count)) / 100
  const ratios = Array.from({ length: count }, () => base)
  const drift = Number((100 - base * count).toFixed(2))
  ratios[count - 1] = Number((base + drift).toFixed(2))
  return ratios
}

function applyEqualRatios(rows: HandlerDraftRow[]): HandlerDraftRow[] {
  const ratios = equalRatios(rows.length)
  return rows.map((row, i) => ({ ...row, ratio: ratios[i] ?? null }))
}

async function loadCandidates(): Promise<void> {
  if (!props.bizType) {
    candidates.value = []
    return
  }
  await runExclusive(loading, async () => {
    try {
      const data = await fetchHandlerCandidates({
        bizType: props.bizType,
        storeId: props.storeId,
        keyword: keyword.value.trim() || undefined,
      })
      candidates.value = data.employees ?? []
    } catch (error) {
      candidates.value = []
      uiMessage.error(getUserFriendlyErrorMessage(error))
    }
  })
}

function openPicker(): void {
  if (props.disabled) {
    return
  }
  draft.value = model.value.map((r) => ({ ...r }))
  keyword.value = ''
  dialogVisible.value = true
  void loadCandidates()
}

function toggleCandidate(emp: HandlerCandidateEmployee): void {
  const id = emp.employeeId?.trim()
  if (!id) {
    return
  }
  const exists = draft.value.some((r) => r.employeeId === id)
  if (exists) {
    draft.value = draft.value.filter((r) => r.employeeId !== id)
  } else {
    draft.value = [
      ...draft.value,
      {
        employeeId: id,
        employeeName: emp.name?.trim() || id,
        ratio: null,
      },
    ]
  }
  draft.value = applyEqualRatios(draft.value)
}

function removeDraft(employeeId: string): void {
  draft.value = applyEqualRatios(draft.value.filter((r) => r.employeeId !== employeeId))
}

function onDraftRatio(employeeId: string, value: number | null): void {
  draft.value = draft.value.map((row) =>
    row.employeeId === employeeId ? { ...row, ratio: value } : row,
  )
}

function confirmDraft(): void {
  if (!draft.value.length) {
    uiMessage.warning('请至少选择一位经手人')
    return
  }
  let sum = 0
  let filled = 0
  for (const row of draft.value) {
    if (row.ratio != null && Number.isFinite(row.ratio)) {
      sum += row.ratio
      filled += 1
    }
  }
  if (filled > 0 && Math.abs(sum - 100) > 0.0001) {
    uiMessage.warning('经手人比例合计须为 100%')
    return
  }
  model.value = draft.value.map((r) => ({ ...r }))
  dialogVisible.value = false
}

function removeHandler(employeeId: string): void {
  if (props.disabled) {
    return
  }
  model.value = applyEqualRatios(model.value.filter((row) => row.employeeId !== employeeId))
}

function onRatioChange(employeeId: string, value: number | null): void {
  model.value = model.value.map((row) =>
    row.employeeId === employeeId ? { ...row, ratio: value } : row,
  )
}

watch(
  () => [props.bizType, props.storeId] as const,
  () => {
    if (dialogVisible.value) {
      void loadCandidates()
    }
  },
)

defineExpose({ ratioValid, ratioSum, openPicker, reload: loadCandidates })
</script>

<template>
  <div class="handler-editor" :class="variant === 'panel' ? 'is-panel' : 'is-chips'">
    <div
      class="handler-trigger"
      :class="{ disabled }"
      role="button"
      tabindex="0"
      @click="openPicker"
      @keyup.enter="openPicker"
    >
      <template v-if="model.length">
        <span v-for="row in model" :key="row.employeeId" class="handler-chip" @click.stop>
          <em>{{ row.employeeName }}</em>
          <el-input-number
            :model-value="row.ratio"
            :min="0"
            :max="100"
            :precision="2"
            :controls="false"
            size="small"
            class="ratio-input"
            :disabled="disabled"
            @update:model-value="(v) => onRatioChange(row.employeeId, v == null ? null : Number(v))"
          />
          <span class="pct">%</span>
          <button
            type="button"
            class="chip-x"
            :disabled="disabled"
            @click.stop="removeHandler(row.employeeId)"
          >
            ×
          </button>
        </span>
        <button type="button" class="add-link" :disabled="disabled" @click.stop="openPicker">
          + 添加
        </button>
      </template>
      <template v-else>
        <span class="placeholder">{{ emptyText || '点击选择销售经手人' }}</span>
      </template>
    </div>
    <div v-if="model.length && !ratioSum.allEmpty && !ratioValid" class="ratio-warn">
      比例合计 {{ ratioSum.sum }}%，须为 100%
    </div>

    <el-dialog
      v-model="dialogVisible"
      title="选择经手人"
      width="520px"
      append-to-body
      destroy-on-close
      :close-on-click-modal="false"
    >
      <div class="picker-toolbar">
        <el-input
          v-model="keyword"
          clearable
          size="small"
          placeholder="搜索姓名 / 工号"
          @keyup.enter="loadCandidates"
        />
        <el-button size="small" :loading="loading" @click="loadCandidates">查询</el-button>
      </div>
      <div v-loading="loading" class="candidate-grid">
        <button
          v-for="emp in candidates"
          :key="emp.employeeId || emp.name"
          type="button"
          class="candidate-btn"
          :class="{ active: draft.some((d) => d.employeeId === emp.employeeId) }"
          @click="toggleCandidate(emp)"
        >
          {{ emp.name || emp.employeeId }}
        </button>
        <div v-if="!loading && !candidates.length" class="empty-hint">无可选经手人</div>
      </div>
      <div class="draft-list">
        <div v-for="row in draft" :key="row.employeeId" class="draft-row">
          <span>{{ row.employeeName }}</span>
          <el-input-number
            :model-value="row.ratio"
            :min="0"
            :max="100"
            :precision="2"
            :controls="false"
            size="small"
            @update:model-value="(v) => onDraftRatio(row.employeeId, v == null ? null : Number(v))"
          />
          <span>%</span>
          <el-button link type="danger" @click="removeDraft(row.employeeId)">移除</el-button>
        </div>
        <p class="hint">选择后默认均分比例，可再修改；合计须为 100%。</p>
      </div>
      <template #footer>
        <el-button @click="dialogVisible = false">取消</el-button>
        <el-button type="primary" @click="confirmDraft">确定</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<style scoped>
.handler-editor.is-chips {
  min-height: 28px;
}
.handler-trigger {
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
  align-items: center;
  min-height: 32px;
  padding: 4px 0;
  cursor: pointer;
}
.handler-trigger.disabled {
  cursor: not-allowed;
  opacity: 0.6;
}
.placeholder {
  color: var(--el-color-primary);
  font-size: 13px;
}
.handler-chip {
  display: inline-flex;
  gap: 4px;
  align-items: center;
  padding: 2px 6px;
  font-size: 13px;
  background: #f5f7fa;
  border: 1px solid #e4e7ed;
  border-radius: 4px;
}
.handler-chip em {
  font-style: normal;
  max-width: 88px;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}
.ratio-input {
  width: 64px;
}
.pct {
  color: #909399;
  font-size: 12px;
}
.chip-x {
  padding: 0 2px;
  color: #909399;
  font-size: 14px;
  line-height: 1;
  cursor: pointer;
  background: none;
  border: 0;
}
.chip-x:hover {
  color: #f56c6c;
}
.add-link {
  padding: 0;
  color: var(--el-color-primary);
  font-size: 13px;
  cursor: pointer;
  background: none;
  border: 0;
}
.ratio-warn {
  margin-top: 2px;
  color: #f56c6c;
  font-size: 12px;
}
.picker-toolbar {
  display: flex;
  gap: 8px;
  margin-bottom: 12px;
}
.candidate-grid {
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
  min-height: 72px;
  max-height: 160px;
  margin-bottom: 12px;
  overflow: auto;
}
.candidate-btn {
  padding: 4px 10px;
  color: #606266;
  font-size: 13px;
  cursor: pointer;
  background: #fff;
  border: 1px solid #dcdfe6;
  border-radius: 4px;
}
.candidate-btn.active {
  color: var(--el-color-primary);
  background: var(--el-color-primary-light-9);
  border-color: var(--el-color-primary-light-5);
}
.draft-list {
  padding-top: 8px;
  border-top: 1px solid #ebeef5;
}
.draft-row {
  display: flex;
  gap: 8px;
  align-items: center;
  margin-bottom: 8px;
}
.hint,
.empty-hint {
  color: #909399;
  font-size: 12px;
}
</style>
