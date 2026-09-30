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
}>()

const model = defineModel<HandlerDraftRow[]>({ default: () => [] })

const loading = ref(false)
const candidates = ref<HandlerCandidateEmployee[]>([])
const keyword = ref('')

const ratioSum = computed(() => {
  let sum = 0
  let filled = 0
  for (const row of model.value) {
    if (row.ratio != null && Number.isFinite(row.ratio)) {
      sum += row.ratio
      filled += 1
    }
  }
  return { sum, filled, allEmpty: filled === 0 }
})

const ratioValid = computed(() => {
  if (ratioSum.value.allEmpty) {
    return true
  }
  return Math.abs(ratioSum.value.sum - 100) < 0.0001
})

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

function addHandler(emp: HandlerCandidateEmployee): void {
  if (props.disabled) {
    return
  }
  const id = emp.employeeId?.trim()
  if (!id) {
    return
  }
  if (model.value.some((row) => row.employeeId === id)) {
    uiMessage.warning('该经手人已添加')
    return
  }
  model.value = [
    ...model.value,
    {
      employeeId: id,
      employeeName: emp.name?.trim() || id,
      ratio: null,
    },
  ]
}

function removeHandler(employeeId: string): void {
  if (props.disabled) {
    return
  }
  model.value = model.value.filter((row) => row.employeeId !== employeeId)
}

function onRatioChange(employeeId: string, value: number | null): void {
  model.value = model.value.map((row) =>
    row.employeeId === employeeId ? { ...row, ratio: value } : row,
  )
}

watch(
  () => [props.bizType, props.storeId] as const,
  () => {
    void loadCandidates()
  },
  { immediate: true },
)

defineExpose({ ratioValid, ratioSum, reload: loadCandidates })
</script>

<template>
  <div class="handler-editor">
    <div class="handler-toolbar">
      <el-input
        v-model="keyword"
        clearable
        size="small"
        placeholder="搜索经手人"
        style="max-width: 160px"
        :disabled="disabled"
        @keyup.enter="loadCandidates"
      />
      <el-button size="small" :loading="loading" :disabled="disabled" @click="loadCandidates">
        刷新
      </el-button>
      <span class="hint" :class="{ 'is-bad': !ratioSum.allEmpty && !ratioValid }">
        <template v-if="ratioSum.allEmpty">未填比例时后端按人数均分</template>
        <template v-else>
          比例合计 {{ ratioSum.sum }}%
          <template v-if="!ratioValid">（须为 100%）</template>
        </template>
      </span>
    </div>

    <div v-if="candidates.length" class="candidate-list">
      <el-button
        v-for="emp in candidates"
        :key="emp.employeeId || emp.name || Math.random()"
        size="small"
        text
        type="primary"
        :disabled="disabled"
        @click="addHandler(emp)"
      >
        {{ emp.name || emp.employeeId }}
      </el-button>
    </div>
    <div v-else-if="!loading" class="empty-hint">无可选经手人（请确认门店与 bizType）</div>

    <el-table :data="model" size="small" border empty-text="尚未添加经手人">
      <el-table-column label="经手人" min-width="120" show-overflow-tooltip>
        <template #default="{ row }">{{ row.employeeName }}</template>
      </el-table-column>
      <el-table-column label="比例(%)" width="120">
        <template #default="{ row }">
          <el-input-number
            :model-value="row.ratio"
            :min="0"
            :max="100"
            :precision="2"
            :controls="false"
            size="small"
            :disabled="disabled"
            style="width: 96px"
            @update:model-value="(v) => onRatioChange(row.employeeId, v == null ? null : Number(v))"
          />
        </template>
      </el-table-column>
      <el-table-column label="" width="64" align="center">
        <template #default="{ row }">
          <el-button
            link
            type="danger"
            size="small"
            :disabled="disabled"
            @click="removeHandler(row.employeeId)"
          >
            删除
          </el-button>
        </template>
      </el-table-column>
    </el-table>
  </div>
</template>

<style scoped>
.handler-editor {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.handler-toolbar {
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
  align-items: center;
}

.hint {
  font-size: 12px;
  color: #909399;
}

.hint.is-bad {
  color: #f56c6c;
}

.candidate-list {
  display: flex;
  flex-wrap: wrap;
  gap: 4px;
  max-height: 72px;
  overflow: auto;
}

.empty-hint {
  font-size: 12px;
  color: #c0c4cc;
}
</style>
