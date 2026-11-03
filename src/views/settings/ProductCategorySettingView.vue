<script setup lang="ts">
import { computed, reactive, ref, watch } from 'vue'

import AppEmpty from '@/components/common/AppEmpty.vue'
import AppError from '@/components/common/AppError.vue'
import { createCardCategory, fetchCardCategoryList, updateCardCategory } from '@/api/card'
import { createProjectCategory, fetchProjectCategoryTree, updateProjectCategory } from '@/api/project'
import { CardPermission, type CardCategoryKind } from '@/types/card'
import { ProjectPermission } from '@/types/project'
import { usePermissionStore } from '@/stores/permission'
import {
  getUserFriendlyErrorMessage,
  notifyError,
  runExclusive,
  uiMessage,
} from '@/utils/ui'

defineOptions({ name: 'ProductCategorySettingView' })

type TabKind = 'project' | CardCategoryKind

interface TabDef {
  key: TabKind
  title: string
}

interface CategoryRow {
  id: number
  name: string | null
  parentId: number | null
  sequence: number | null
  active: boolean | null
  children?: CategoryRow[]
}

const TABS: TabDef[] = [
  { key: 'project', title: '项目分类' },
  { key: 'general', title: '通用次卡分类' },
  { key: 'time', title: '时效卡分类' },
  { key: 'saving', title: '储值卡分类' },
  { key: 'package', title: '套餐卡分类' },
]

const CARD_EDIT_PERMISSION: Record<CardCategoryKind, string> = {
  general: CardPermission.GENERAL_EDIT,
  time: CardPermission.TIME_EDIT,
  saving: CardPermission.SAVING_EDIT,
  package: CardPermission.PACKAGE_EDIT,
}

const permissionStore = usePermissionStore()

const activeTab = ref<TabDef>(TABS[0]!)
const loading = ref(false)
const listError = ref<string | null>(null)
const rows = ref<CategoryRow[]>([])
const expandAll = ref(true)

const filters = reactive({
  keyword: '',
  active: 'all' as 'all' | 'active' | 'inactive',
})
const applied = reactive({ keyword: '', active: 'all' as 'all' | 'active' | 'inactive' })

const isProject = computed(() => activeTab.value.key === 'project')
const canEdit = computed(() => {
  const key = activeTab.value.key
  return permissionStore.hasPermission(
    key === 'project' ? ProjectPermission.CATEGORY_EDIT : CARD_EDIT_PERMISSION[key],
  )
})

function matchRow(row: CategoryRow): boolean {
  const kw = applied.keyword.trim()
  const keywordOk = kw === '' || (row.name ?? '').includes(kw)
  const activeOk =
    applied.active === 'all' ? true
    : applied.active === 'active' ? row.active === true
    : row.active !== true
  return keywordOk && activeOk
}

function filterTree(list: CategoryRow[]): CategoryRow[] {
  const result: CategoryRow[] = []
  for (const row of list) {
    const children = row.children ? filterTree(row.children) : []
    if (matchRow(row) || children.length > 0) {
      result.push({ ...row, children: row.children ? children : undefined })
    }
  }
  return result
}

const displayRows = computed(() =>
  isProject.value ? filterTree(rows.value) : rows.value.filter((row) => matchRow(row)),
)

function findAll(list: CategoryRow[], id: number): CategoryRow | null {
  for (const row of list) {
    if (row.id === id) {
      return row
    }
    if (row.children) {
      const found = findAll(row.children, id)
      if (found != null) {
        return found
      }
    }
  }
  return null
}

/** 同父级兄弟列表（用于排序） */
function siblingsOf(row: CategoryRow): CategoryRow[] {
  if (!isProject.value) {
    return rows.value
  }
  const parentId = row.parentId ?? 0
  if (parentId === 0) {
    return rows.value
  }
  return findAll(rows.value, parentId)?.children ?? []
}

function positionOf(row: CategoryRow): number {
  return siblingsOf(row).findIndex((item) => item.id === row.id)
}

function siblingCount(row: CategoryRow): number {
  return siblingsOf(row).length
}

async function loadRows(): Promise<void> {
  await runExclusive(loading, async () => {
    listError.value = null
    try {
      if (isProject.value) {
        const tree = await fetchProjectCategoryTree()
        rows.value = tree as CategoryRow[]
      } else {
        const list = await fetchCardCategoryList(activeTab.value.key as CardCategoryKind)
        rows.value = list.map((item) => ({
          id: item.id,
          name: item.name,
          parentId: null,
          sequence: item.sequence,
          active: item.active,
        }))
      }
    } catch (error) {
      rows.value = []
      listError.value = getUserFriendlyErrorMessage(error)
    }
  })
}

async function applyFilters(): Promise<void> {
  applied.keyword = filters.keyword
  applied.active = filters.active
}

function resetFilters(): void {
  filters.keyword = ''
  filters.active = 'all'
  applied.keyword = ''
  applied.active = 'all'
}

async function persistOrder(list: CategoryRow[]): Promise<void> {
  for (let i = 0; i < list.length; i++) {
    const item = list[i]!
    const sequence = i + 1
    if ((item.sequence ?? 0) === sequence) {
      continue
    }
    if (isProject.value) {
      await updateProjectCategory(item.id, {
        name: item.name ?? '',
        parentId: item.parentId ?? 0,
        sequence,
        active: item.active === true,
      })
    } else {
      await updateCardCategory(activeTab.value.key as CardCategoryKind, item.id, {
        name: item.name ?? '',
        sequence,
        active: item.active === true,
      })
    }
    item.sequence = sequence
  }
}

const moving = ref(false)

async function moveRow(row: CategoryRow, mode: 'top' | 'up' | 'down' | 'bottom'): Promise<void> {
  if (!canEdit.value || moving.value) {
    return
  }
  const list = siblingsOf(row)
  const index = list.findIndex((item) => item.id === row.id)
  if (index < 0) {
    return
  }
  const target =
    mode === 'top' ? 0
    : mode === 'bottom' ? list.length - 1
    : mode === 'up' ? index - 1
    : index + 1
  if (target < 0 || target >= list.length || target === index) {
    return
  }
  const next = [...list]
  next.splice(index, 1)
  next.splice(target, 0, row)
  await runExclusive(moving, async () => {
    try {
      await persistOrder(next)
      await loadRows()
    } catch (error) {
      notifyError(error)
      await loadRows()
    }
  })
}

const dialogVisible = ref(false)
const dialogMode = ref<'create' | 'edit'>('create')
const dialogSaving = ref(false)
const dialogError = ref<string | null>(null)
const editingId = ref<number | null>(null)

const form = reactive({
  name: '',
  parentId: 0,
  sequence: null as number | null,
  active: true,
})

const parentOptions = computed(() => {
  if (!isProject.value) {
    return []
  }
  return rows.value.filter(
    (row) => (row.parentId ?? 0) === 0 && row.id !== editingId.value,
  )
})

function openCreate(parentId = 0): void {
  dialogMode.value = 'create'
  editingId.value = null
  form.name = ''
  form.parentId = parentId
  form.sequence = null
  form.active = true
  dialogError.value = null
  dialogVisible.value = true
}

function openEdit(row: CategoryRow): void {
  dialogMode.value = 'edit'
  editingId.value = row.id
  form.name = row.name ?? ''
  form.parentId = row.parentId ?? 0
  form.sequence = row.sequence
  form.active = row.active === true
  dialogError.value = null
  dialogVisible.value = true
}

async function handleSubmit(): Promise<void> {
  const name = form.name.trim()
  if (!name) {
    uiMessage.warning('请填写分类名称')
    return
  }
  if (name.length > 50) {
    uiMessage.warning('分类名称最多 50 个字符')
    return
  }
  await runExclusive(dialogSaving, async () => {
    dialogError.value = null
    try {
      if (isProject.value) {
        const body = {
          name,
          parentId: form.parentId,
          sequence: form.sequence,
          active: form.active,
        }
        if (dialogMode.value === 'create') {
          await createProjectCategory(body)
        } else if (editingId.value != null) {
          await updateProjectCategory(editingId.value, {
            name,
            parentId: form.parentId,
            sequence: form.sequence ?? 0,
            active: form.active,
          })
        }
      } else {
        const body = { name, sequence: form.sequence, active: form.active }
        if (dialogMode.value === 'create') {
          await createCardCategory(activeTab.value.key as CardCategoryKind, body)
        } else if (editingId.value != null) {
          await updateCardCategory(activeTab.value.key as CardCategoryKind, editingId.value, body)
        }
      }
      uiMessage.success(dialogMode.value === 'create' ? '已新增' : '已保存')
      dialogVisible.value = false
      await loadRows()
    } catch (error) {
      dialogError.value = getUserFriendlyErrorMessage(error)
      notifyError(error)
    }
  })
}

watch(activeTab, () => {
  resetFilters()
  void loadRows()
})

void loadRows()
</script>

<template>
  <div class="category-settings">
    <aside class="side-nav">
      <button
        v-for="tab in TABS"
        :key="tab.key"
        type="button"
        :class="['side-nav__item', tab.key === activeTab.key ? 'side-nav__item--active' : '']"
        @click="activeTab = tab"
      >
        {{ tab.title }}
      </button>
    </aside>

    <section class="main-panel">
      <div class="toolbar">
        <div class="toolbar__filters">
          <label class="field-label">分类名称</label>
          <el-input
            v-model="filters.keyword"
            placeholder="输入分类名称搜索"
            clearable
            style="width: 220px"
            @keyup.enter="applyFilters"
          />
          <label class="field-label">有效性</label>
          <el-select v-model="filters.active" style="width: 120px">
            <el-option label="全部" value="all" />
            <el-option label="有效" value="active" />
            <el-option label="停用" value="inactive" />
          </el-select>
          <el-button type="primary" @click="applyFilters">搜索</el-button>
          <el-button @click="resetFilters">重置</el-button>
        </div>
        <div class="toolbar__actions">
          <el-button @click="expandAll = !expandAll">
            {{ expandAll ? '收起全部' : '展开全部' }}
          </el-button>
          <el-button v-if="canEdit" type="primary" @click="openCreate(0)">新增</el-button>
        </div>
      </div>

      <AppError
        v-if="listError && !loading"
        :description="listError"
        @retry="loadRows"
      />
      <AppEmpty v-else-if="!loading && displayRows.length === 0" description="暂无分类数据" />
      <el-table
        v-else
        :key="`${activeTab.key}-${expandAll}`"
        v-loading="loading"
        :data="displayRows"
        row-key="id"
        :tree-props="{ children: 'children' }"
        :default-expand-all="expandAll"
        border
        size="small"
      >
        <el-table-column label="分类名称" min-width="220">
          <template #default="{ row }">
            <span class="category-name">{{ row.name || '—' }}</span>
          </template>
        </el-table-column>
        <el-table-column v-if="canEdit" label="移动" width="190" align="center">
          <template #default="{ row }">
            <div class="move-cell">
              <el-button
                circle
                size="small"
                type="warning"
                plain
                :disabled="positionOf(row as CategoryRow) <= 0"
                title="置顶"
                @click="moveRow(row as CategoryRow, 'top')"
              >
                ⇧
              </el-button>
              <el-button
                circle
                size="small"
                type="warning"
                plain
                :disabled="positionOf(row as CategoryRow) <= 0"
                title="上移"
                @click="moveRow(row as CategoryRow, 'up')"
              >
                ↑
              </el-button>
              <el-button
                circle
                size="small"
                type="warning"
                plain
                :disabled="positionOf(row as CategoryRow) >= siblingCount(row as CategoryRow) - 1"
                title="下移"
                @click="moveRow(row as CategoryRow, 'down')"
              >
                ↓
              </el-button>
              <el-button
                circle
                size="small"
                type="warning"
                plain
                :disabled="positionOf(row as CategoryRow) >= siblingCount(row as CategoryRow) - 1"
                title="置底"
                @click="moveRow(row as CategoryRow, 'bottom')"
              >
                ⇩
              </el-button>
            </div>
          </template>
        </el-table-column>
        <el-table-column label="有效性" width="100" align="center">
          <template #default="{ row }">
            <el-tag :type="row.active ? 'success' : 'info'" size="small">
              {{ row.active ? '有效' : '停用' }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column label="操作" width="220" fixed="right" align="center">
          <template #default="{ row }">
            <el-button v-if="canEdit" link type="primary" @click="openEdit(row as CategoryRow)">
              编辑
            </el-button>
            <el-button
              v-if="canEdit && isProject && (row.parentId ?? 0) === 0"
              link
              type="primary"
              @click="openCreate((row as CategoryRow).id)"
            >
              新增子分类
            </el-button>
          </template>
        </el-table-column>
      </el-table>
    </section>

    <el-dialog
      v-model="dialogVisible"
      :title="dialogMode === 'create' ? '新增分类' : '编辑分类'"
      width="460px"
      destroy-on-close
    >
      <el-form label-width="90px">
        <el-form-item label="分类名称" required>
          <el-input v-model="form.name" maxlength="50" placeholder="请输入分类名称" />
        </el-form-item>
        <el-form-item v-if="isProject" label="上级分类">
          <el-select v-model="form.parentId" style="width: 100%">
            <el-option label="（一级分类）" :value="0" />
            <el-option
              v-for="opt in parentOptions"
              :key="opt.id"
              :label="opt.name || `#${opt.id}`"
              :value="opt.id"
            />
          </el-select>
        </el-form-item>
        <el-form-item label="排序号">
          <el-input-number
            v-model="form.sequence"
            :min="1"
            :step="1"
            controls-position="right"
            placeholder="留空自动追加"
            style="width: 160px"
          />
        </el-form-item>
        <el-form-item label="有效性">
          <el-switch v-model="form.active" active-text="有效" inactive-text="停用" />
        </el-form-item>
      </el-form>
      <div v-if="dialogError" class="dialog-error">{{ dialogError }}</div>
      <template #footer>
        <el-button @click="dialogVisible = false">取消</el-button>
        <el-button type="primary" :loading="dialogSaving" @click="handleSubmit">保存</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<style scoped>
.category-settings {
  display: flex;
  gap: 16px;
  align-items: flex-start;
  padding: 16px;
  background: #fff;
}

.side-nav {
  display: flex;
  flex-direction: column;
  gap: 4px;
  min-width: 140px;
  padding: 8px 4px;
}

.side-nav__item {
  border: none;
  background: transparent;
  text-align: left;
  padding: 10px 16px;
  border-radius: 6px;
  font-size: 14px;
  color: #606266;
  cursor: pointer;
}

.side-nav__item:hover {
  background: #f5f7fa;
}

.side-nav__item--active {
  background: #fff2e8;
  color: #f56c2d;
  font-weight: 600;
}

.main-panel {
  flex: 1;
  min-width: 0;
}

.toolbar {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 12px;
  margin-bottom: 12px;
  flex-wrap: wrap;
}

.toolbar__filters {
  display: flex;
  align-items: center;
  gap: 8px;
  flex-wrap: wrap;
}

.toolbar__actions {
  display: flex;
  align-items: center;
  gap: 8px;
}

.field-label {
  font-size: 13px;
  color: #606266;
}

.category-name {
  display: inline-flex;
  align-items: center;
  gap: 6px;
}

.move-cell {
  display: inline-flex;
  align-items: center;
  gap: 4px;
}

.move-cell :deep(.el-button) {
  width: 26px;
  height: 26px;
  padding: 0;
  font-weight: 700;
}

.dialog-error {
  color: #f56c6c;
  font-size: 12px;
  padding-left: 90px;
}
</style>
