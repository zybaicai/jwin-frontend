<script setup lang="ts">
import { computed, reactive, ref, watch } from 'vue'

import AppEmpty from '@/components/common/AppEmpty.vue'
import AppError from '@/components/common/AppError.vue'
import {
  createBasicDictionary,
  deactivateBasicDictionary,
  fetchBasicDictionary,
  updateBasicDictionary,
} from '@/api/basicSetting'
import {
  BasicSettingPermission,
  type BasicDictionaryItem,
  type BasicSettingType,
  type SaveBasicDictionaryBody,
} from '@/types/basicSetting'
import { usePermissionStore } from '@/stores/permission'
import {
  getUserFriendlyErrorMessage,
  notifyError,
  runExclusive,
  uiConfirm,
  uiMessage,
} from '@/utils/ui'

const props = withDefaults(
  defineProps<{
    type: BasicSettingType
    title: string
    createLabel: string
    /** 商品分类为两级结构，需显示上级分类与上级选择 */
    hierarchical?: boolean
  }>(),
  { hierarchical: false },
)

defineOptions({ name: 'BasicDictionaryPane' })

const permissionStore = usePermissionStore()

const hasViewPermission = computed(() =>
  permissionStore.hasPermission(BasicSettingPermission.VIEW),
)
const hasEditPermission = computed(() =>
  permissionStore.hasPermission(BasicSettingPermission.EDIT),
)

const loading = ref(false)
const listError = ref<string | null>(null)
const records = ref<BasicDictionaryItem[]>([])

/** 筛选条件 */
const filters = reactive({
  keyword: '',
  /** 'all' | 'active' | 'inactive' */
  active: 'all' as 'all' | 'active' | 'inactive',
})
/** 查询按钮触发时复制一份快照传给 API */
const appliedFilters = reactive({ keyword: '', active: 'all' as 'all' | 'active' | 'inactive' })

const formVisible = ref(false)
const formMode = ref<'create' | 'edit'>('create')
const formSaving = ref(false)
const formError = ref<string | null>(null)
const editingId = ref<number | null>(null)
const form = reactive({
  name: '',
  sequence: null as number | null,
  parentId: 0 as number,
})

/** 一级分类，作为上级分类候选（编辑时排除自身） */
const parentOptions = computed(() =>
  records.value.filter(
    (item) => (item.parentId ?? 0) === 0 && item.id !== editingId.value,
  ),
)

const parentNameMap = computed(() => {
  const map = new Map<number, string>()
  for (const item of records.value) {
    map.set(item.id, item.name ?? `#${item.id}`)
  }
  return map
})

function parentLabel(row: BasicDictionaryItem): string {
  const parentId = row.parentId ?? 0
  if (parentId === 0) {
    return '—'
  }
  return parentNameMap.value.get(parentId) ?? `#${parentId}`
}

/** 同组（同一上级）记录，按当前排序号顺序 */
function siblingGroup(row: BasicDictionaryItem): BasicDictionaryItem[] {
  const parentId = row.parentId ?? 0
  return records.value.filter((item) => (item.parentId ?? 0) === parentId)
}

function rowPosition(row: BasicDictionaryItem): number {
  return siblingGroup(row).findIndex((item) => item.id === row.id)
}

/** 用上下箭头把该行移动 delta 位（-1 上移，1 下移） */
async function moveRow(row: BasicDictionaryItem, delta: number): Promise<void> {
  const group = siblingGroup(row)
  const index = group.findIndex((item) => item.id === row.id)
  const target = index + delta + 1
  if (index < 0 || target < 1 || target > group.length) {
    return
  }
  await handleMove(row, target)
}

const moving = ref(false)

/**
 * 点击圆点把该行移动到目标位置，并把整个序列重排为连续的 1..N。
 * 商品分类只在同一上级分组内重排。
 */
async function handleMove(row: BasicDictionaryItem, target: number): Promise<void> {
  if (!hasEditPermission.value || moving.value) {
    return
  }
  const parentId = row.parentId ?? 0
  const group = records.value
    .filter((item) => (item.parentId ?? 0) === parentId)
    .slice()
  const currentIndex = group.findIndex((item) => item.id === row.id)
  if (currentIndex < 0 || currentIndex === target - 1 || target > group.length) {
    return
  }
  group.splice(currentIndex, 1)
  group.splice(target - 1, 0, row)
  await runExclusive(moving, async () => {
    try {
      for (let i = 0; i < group.length; i++) {
        const item = group[i]!
        const sequence = i + 1
        if ((item.sequence ?? 0) === sequence) {
          continue
        }
        await updateBasicDictionary(props.type, item.id, {
          name: item.name ?? '',
          sequence,
          active: item.active,
          parentId: props.hierarchical ? (item.parentId ?? 0) : undefined,
        })
        item.sequence = sequence
      }
      await loadList()
    } catch (error) {
      notifyError(error)
    }
  })
}

/** 商品分类等层级数据使用数字输入直接改排序号 */
async function handleSequenceChange(
  row: BasicDictionaryItem,
  value: number | null | undefined,
): Promise<void> {
  if (!hasEditPermission.value) {
    return
  }
  try {
    await updateBasicDictionary(props.type, row.id, {
      name: row.name ?? '',
      sequence: value ?? null,
      active: row.active,
      parentId: row.parentId ?? 0,
    })
    await loadList()
  } catch (error) {
    notifyError(error)
    await loadList()
  }
}

function resetFilters(): void {
  filters.keyword = ''
  filters.active = 'all'
  appliedFilters.keyword = ''
  appliedFilters.active = 'all'
  void loadList()
}

async function loadList(): Promise<void> {
  if (!hasViewPermission.value) {
    records.value = []
    listError.value = '暂无权限查看基础设置（system:setting:view）'
    return
  }
  await runExclusive(loading, async () => {
    listError.value = null
    try {
      const kw = appliedFilters.keyword.trim() || undefined
      const act =
        appliedFilters.active === 'active' ? true
        : appliedFilters.active === 'inactive' ? false
        : undefined
      records.value = await fetchBasicDictionary(props.type, { keyword: kw, active: act })
    } catch (error) {
      records.value = []
      listError.value = getUserFriendlyErrorMessage(error)
    }
  })
}

async function applyFilters(): Promise<void> {
  appliedFilters.keyword = filters.keyword
  appliedFilters.active = filters.active
  await loadList()
}

function openCreate(): void {
  formMode.value = 'create'
  editingId.value = null
  form.name = ''
  form.sequence = null
  form.parentId = 0
  formError.value = null
  formVisible.value = true
}

function openEdit(row: BasicDictionaryItem): void {
  formMode.value = 'edit'
  editingId.value = row.id
  form.name = row.name ?? ''
  form.sequence = row.sequence
  form.parentId = row.parentId ?? 0
  formError.value = null
  formVisible.value = true
}

async function handleSubmit(): Promise<void> {
  const name = form.name.trim()
  if (!name) {
    uiMessage.warning('请填写名称')
    return
  }
  if (name.length > 50) {
    uiMessage.warning('名称最多 50 个字符')
    return
  }
  await runExclusive(formSaving, async () => {
    formError.value = null
    try {
      const body: SaveBasicDictionaryBody = {
        name,
        sequence: form.sequence,
        parentId: props.hierarchical ? form.parentId : undefined,
      }
      if (formMode.value === 'create') {
        await createBasicDictionary(props.type, body)
        uiMessage.success('已新增，自动绑定所有门店')
      } else if (editingId.value != null) {
        await updateBasicDictionary(props.type, editingId.value, body)
        uiMessage.success('已保存')
      }
      formVisible.value = false
      await loadList()
    } catch (error) {
      formError.value = getUserFriendlyErrorMessage(error)
      notifyError(error)
    }
  })
}

async function handleDeactivate(row: BasicDictionaryItem): Promise<void> {
  const ok = await uiConfirm({
    title: '停用确认',
    message: `确认停用「${row.name || row.id}」？停用后不再出现在收款可选列表中，历史单据不受影响。`,
    confirmText: '停用',
  })
  if (!ok) {
    return
  }
  try {
    await deactivateBasicDictionary(props.type, row.id)
    uiMessage.success('已停用')
    await loadList()
  } catch (error) {
    notifyError(error)
  }
}

async function handleActivate(row: BasicDictionaryItem): Promise<void> {
  try {
    await updateBasicDictionary(props.type, row.id, {
      name: row.name ?? '',
      sequence: row.sequence,
      active: true,
    })
    uiMessage.success('已启用')
    await loadList()
  } catch (error) {
    notifyError(error)
  }
}

function rowOf(row: unknown): BasicDictionaryItem {
  return row as BasicDictionaryItem
}

/** 回车键快速查询 */
function onKeywordEnter(): void {
  void applyFilters()
}

watch(
  () => [props.type, hasViewPermission.value],
  () => {
    void loadList()
  },
  { immediate: true },
)
</script>

<template>
  <section class="basic-dictionary">
    <!-- 顶部工具条：筛选 + 新增 -->
    <div class="toolbar">
      <div class="toolbar__left">
        <h1 class="toolbar__title">{{ title }}</h1>
        <div class="toolbar__filters">
          <el-input
            v-model="filters.keyword"
            class="filter-input"
            placeholder="输入名称搜索"
            clearable
            @keyup.enter="onKeywordEnter"
          />
          <el-select v-model="filters.active" class="filter-select">
            <el-option label="全部" value="all" />
            <el-option label="有效" value="active" />
            <el-option label="停用" value="inactive" />
          </el-select>
          <el-button type="primary" @click="applyFilters">查询</el-button>
          <el-button @click="resetFilters">重置</el-button>
        </div>
      </div>
      <el-button
        v-permission="BasicSettingPermission.EDIT"
        type="primary"
        class="toolbar__create"
        @click="openCreate"
      >
        {{ createLabel }}
      </el-button>
    </div>

    <!-- 表格区 -->
    <div v-loading="loading" class="table-panel">
      <AppError v-if="listError && !loading" :description="listError" @retry="loadList" />
      <template v-else>
        <el-table :data="records" border stripe size="small" empty-text=" ">
          <el-table-column label="序号" type="index" width="60" align="center" />
          <el-table-column label="名称" min-width="160" show-overflow-tooltip>
            <template #default="{ row }">{{ rowOf(row).name || '—' }}</template>
          </el-table-column>
          <el-table-column v-if="hierarchical" label="上级分类" min-width="140" show-overflow-tooltip>
            <template #default="{ row }">{{ parentLabel(rowOf(row)) }}</template>
          </el-table-column>
          <el-table-column v-if="hierarchical" label="排序号" width="150" align="center">
            <template #default="{ row }">
              <el-input-number
                v-if="hasEditPermission"
                :model-value="rowOf(row).sequence"
                :min="0"
                :step="1"
                controls-position="right"
                size="small"
                style="width: 90px"
                @change="handleSequenceChange(rowOf(row), $event)"
              />
              <span v-else>{{ rowOf(row).sequence ?? '—' }}</span>
            </template>
          </el-table-column>
          <el-table-column v-else-if="hasEditPermission" label="排序" width="110" align="center">
            <template #default="{ row }">
              <div class="move-cell">
                <el-button
                  link
                  type="primary"
                  :disabled="rowPosition(rowOf(row)) <= 0"
                  title="上移"
                  @click="moveRow(rowOf(row), -1)"
                >
                  ↑
                </el-button>
                <el-button
                  link
                  type="primary"
                  :disabled="rowPosition(rowOf(row)) >= siblingGroup(rowOf(row)).length - 1"
                  title="下移"
                  @click="moveRow(rowOf(row), 1)"
                >
                  ↓
                </el-button>
              </div>
            </template>
          </el-table-column>
          <el-table-column v-else label="排序号" width="90" align="center">
            <template #default="{ row }">{{ rowOf(row).sequence ?? '—' }}</template>
          </el-table-column>
          <el-table-column label="有效性" width="90" align="center">
            <template #default="{ row }">
              {{ rowOf(row).active ? '有效' : '停用' }}
            </template>
          </el-table-column>
          <el-table-column label="操作" width="140" fixed="right" align="center">
            <template #default="{ row }">
              <el-button
                v-permission="BasicSettingPermission.EDIT"
                link
                type="primary"
                @click="openEdit(rowOf(row))"
              >
                编辑
              </el-button>
              <el-button
                v-if="hasEditPermission && rowOf(row).active"
                link
                type="warning"
                @click="handleDeactivate(rowOf(row))"
              >
                停用
              </el-button>
              <el-button
                v-if="hasEditPermission && !rowOf(row).active"
                link
                type="success"
                @click="handleActivate(rowOf(row))"
              >
                启用
              </el-button>
            </template>
          </el-table-column>
        </el-table>

        <AppEmpty
          v-if="!loading && !listError && records.length === 0"
          :title="`暂无${title}`"
          :description="`可点击「${createLabel}」新增，或调整筛选条件`"
        />
      </template>
    </div>

    <!-- 编辑弹窗 -->
    <el-dialog
      v-model="formVisible"
      :title="formMode === 'create' ? createLabel : `编辑${title}`"
      width="460px"
      destroy-on-close
      :close-on-click-modal="false"
    >
      <AppError v-if="formError" :description="formError" />
      <el-form label-width="90px" @submit.prevent>
        <el-form-item label="名称" required>
          <el-input
            v-model="form.name"
            maxlength="50"
            show-word-limit
            placeholder="请输入名称"
          />
        </el-form-item>
        <el-form-item v-if="hierarchical" label="上级分类">
          <el-select v-model="form.parentId" placeholder="不选则为一级分类" style="width: 100%">
            <el-option label="（一级分类）" :value="0" />
            <el-option
              v-for="opt in parentOptions"
              :key="opt.id"
              :label="opt.name || String(opt.id)"
              :value="opt.id"
            />
          </el-select>
        </el-form-item>
        <el-form-item label="排序号">
          <el-input-number
            v-model="form.sequence"
            :min="0"
            :step="1"
            controls-position="right"
            placeholder="留空自动追加"
            style="width: 160px"
          />
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
.basic-dictionary {
  display: flex;
  flex-direction: column;
  gap: 16px;
  min-height: 100%;
  padding: 20px 24px 24px;
}

.toolbar {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 12px;
  flex-wrap: wrap;
}

.toolbar__left {
  display: flex;
  align-items: center;
  gap: 16px;
  flex-wrap: wrap;
}

.toolbar__title {
  margin: 0;
  font-size: 20px;
  font-weight: 600;
  color: #303133;
  white-space: nowrap;
}

.toolbar__filters {
  display: flex;
  align-items: center;
  gap: 8px;
  flex-wrap: wrap;
}

.filter-input {
  width: 200px;
}

.filter-select {
  width: 140px;
}

.toolbar__create {
  flex-shrink: 0;
}

.table-panel {
  min-height: 240px;
  padding: 16px;
  border: 1px solid #ebeef5;
  border-radius: 8px;
  background: #fff;
}

/* 排序箭头 */
.move-cell {
  display: inline-flex;
  align-items: center;
  gap: 4px;
}

.move-cell :deep(.el-button) {
  font-size: 16px;
  font-weight: 700;
  padding: 0 4px;
}
</style>
