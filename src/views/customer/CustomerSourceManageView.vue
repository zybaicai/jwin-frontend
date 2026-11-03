<script setup lang="ts">
import { computed, reactive, ref, watch } from 'vue'
import { ArrowDown, ArrowUp, Bottom, Top } from '@element-plus/icons-vue'

import AppEmpty from '@/components/common/AppEmpty.vue'
import AppError from '@/components/common/AppError.vue'
import {
  createCustomerSource,
  fetchCustomerSourceDetail,
  fetchCustomerSourcePage,
  moveCustomerSource,
  updateCustomerSource,
} from '@/api/customer'
import {
  CustomerPermission,
  type CustomerSource,
  type CustomerSourceMoveDirection,
} from '@/types/customer'
import { usePermissionStore } from '@/stores/permission'
import {
  getUserFriendlyErrorMessage,
  notifyError,
  runExclusive,
  uiMessage,
} from '@/utils/ui'

defineOptions({ name: 'CustomerSourceManageView' })

const permissionStore = usePermissionStore()

const hasViewPermission = computed(() =>
  permissionStore.hasPermission(CustomerPermission.SOURCE_VIEW),
)
const hasEditPermission = computed(() =>
  permissionStore.hasPermission(CustomerPermission.SOURCE_EDIT),
)

const loading = ref(false)
const listError = ref<string | null>(null)
const keywordInput = ref('')
const keyword = ref('')
/** '' = 全部, 'true' = 有效, 'false' = 无效 */
const activeFilter = ref<'' | 'true' | 'false'>('')
const records = ref<CustomerSource[]>([])

const formVisible = ref(false)
const formMode = ref<'create' | 'edit'>('create')
const formLoading = ref(false)
const formSaving = ref(false)
const formError = ref<string | null>(null)
const editingId = ref<number | null>(null)
const parentCandidates = ref<CustomerSource[]>([])

const form = reactive({
  name: '',
  parentId: 0 as number,
  sequence: 0 as number,
  active: true,
})

const parentSelectOptions = computed(() => {
  const excludeId = formMode.value === 'edit' ? editingId.value : null
  return parentCandidates.value.filter((item) => item.id !== excludeId)
})

/** 按 ParentID 分组并按 Sequence 排序，用于移动按钮的边界判断 */
const siblingGroups = computed(() => {
  const groups = new Map<number, CustomerSource[]>()
  for (const item of records.value) {
    const key = item.parentId ?? 0
    const list = groups.get(key) ?? []
    list.push(item)
    groups.set(key, list)
  }
  for (const list of groups.values()) {
    list.sort((a, b) => (a.sequence ?? 0) - (b.sequence ?? 0) || a.id - b.id)
  }
  return groups
})

/** 展示顺序：按 (ParentID, Sequence, ID) 排序的平铺列表 */
const sortedRecords = computed(() => {
  return [...records.value].sort(
    (a, b) =>
      (a.parentId ?? 0) - (b.parentId ?? 0) ||
      (a.sequence ?? 0) - (b.sequence ?? 0) ||
      a.id - b.id,
  )
})

function siblingPosition(row: CustomerSource): { index: number; length: number } {
  const list = siblingGroups.value.get(row.parentId ?? 0) ?? [row]
  const index = list.findIndex((item) => item.id === row.id)
  return { index: index < 0 ? 0 : index, length: list.length }
}

function canMoveUp(row: CustomerSource): boolean {
  return siblingPosition(row).index > 0
}

function canMoveDown(row: CustomerSource): boolean {
  const { index, length } = siblingPosition(row)
  return index < length - 1
}

async function loadList(): Promise<void> {
  if (!hasViewPermission.value) {
    records.value = []
    listError.value = '暂无权限查看来源（customer:source:view）'
    return
  }
  await runExclusive(loading, async () => {
    listError.value = null
    try {
      const data = await fetchCustomerSourcePage({
        keyword: keyword.value.trim() || undefined,
        active:
          activeFilter.value === 'true'
            ? true
            : activeFilter.value === 'false'
              ? false
              : undefined,
        page: 1,
        size: 500,
      })
      records.value = data.records ?? []
    } catch (error) {
      records.value = []
      listError.value = getUserFriendlyErrorMessage(error)
    }
  })
}

async function loadParentCandidates(): Promise<void> {
  try {
    const data = await fetchCustomerSourcePage({ page: 1, size: 500 })
    parentCandidates.value = data.records ?? []
  } catch {
    parentCandidates.value = []
  }
}

function handleSearch(): void {
  keyword.value = keywordInput.value.trim()
  void loadList()
}

function handleReset(): void {
  keywordInput.value = ''
  keyword.value = ''
  activeFilter.value = ''
  void loadList()
}

function openCreate(): void {
  formMode.value = 'create'
  editingId.value = null
  form.name = ''
  form.parentId = 0
  form.sequence = 0
  form.active = true
  formError.value = null
  formVisible.value = true
  void loadParentCandidates()
}

/** 添加子来源：父级默认当前行 */
function openCreateChild(row: CustomerSource): void {
  formMode.value = 'create'
  editingId.value = null
  form.name = ''
  form.parentId = row.id
  form.sequence = 0
  form.active = true
  formError.value = null
  formVisible.value = true
  void loadParentCandidates()
}

async function openEdit(row: CustomerSource): Promise<void> {
  formMode.value = 'edit'
  editingId.value = row.id
  form.name = row.name ?? ''
  form.parentId = row.parentId ?? 0
  form.sequence = row.sequence ?? 0
  form.active = row.active !== false
  formError.value = null
  formVisible.value = true
  formLoading.value = true
  try {
    await loadParentCandidates()
    const detail = await fetchCustomerSourceDetail(row.id)
    form.name = detail.name ?? ''
    form.parentId = detail.parentId ?? 0
    form.sequence = detail.sequence ?? 0
    form.active = detail.active !== false
  } catch (error) {
    notifyError(error)
  } finally {
    formLoading.value = false
  }
}

async function handleSubmit(): Promise<void> {
  const name = form.name.trim()
  if (!name) {
    uiMessage.warning('请填写来源名称')
    return
  }
  if (name.length > 50) {
    uiMessage.warning('来源名称最多 50 个字符')
    return
  }
  await runExclusive(formSaving, async () => {
    formError.value = null
    try {
      if (formMode.value === 'create') {
        await createCustomerSource({
          name,
          parentId: form.parentId ?? 0,
          sequence: Number(form.sequence) || 0,
          active: form.active,
        })
        uiMessage.success('来源已创建')
      } else if (editingId.value != null) {
        await updateCustomerSource(editingId.value, {
          name,
          parentId: form.parentId ?? 0,
          sequence: Number(form.sequence) || 0,
          active: form.active,
        })
        uiMessage.success('来源已更新')
      }
      formVisible.value = false
      await loadList()
      void loadParentCandidates()
    } catch (error) {
      formError.value = getUserFriendlyErrorMessage(error)
      notifyError(error)
    }
  })
}

async function handleMove(row: CustomerSource, direction: CustomerSourceMoveDirection): Promise<void> {
  if (!hasEditPermission.value) {
    return
  }
  try {
    await moveCustomerSource(row.id, direction)
    await loadList()
  } catch (error) {
    notifyError(error)
  }
}

function rowOf(row: unknown): CustomerSource {
  return row as CustomerSource
}

watch(
  hasViewPermission,
  () => {
    void loadList()
  },
  { immediate: true },
)
</script>

<template>
  <section class="source-manage">
    <div class="filter-bar">
      <div class="filter-toolbar">
        <el-form :inline="true" class="filter-form" @submit.prevent="handleSearch">
          <el-form-item label="名称">
            <el-input
              v-model="keywordInput"
              clearable
              placeholder="来源名称"
              style="max-width: 220px"
            />
          </el-form-item>
          <el-form-item label="有效性">
            <el-select
              v-model="activeFilter"
              clearable
              placeholder="有效性"
              style="width: 140px"
            >
              <el-option label="全部" value="" />
              <el-option label="有效" value="true" />
              <el-option label="无效" value="false" />
            </el-select>
          </el-form-item>
          <el-form-item>
            <el-button type="primary" native-type="submit" :loading="loading">查询</el-button>
            <el-button native-type="button" :disabled="loading" @click="handleReset">重置</el-button>
          </el-form-item>
        </el-form>
        <el-button
          v-permission="CustomerPermission.SOURCE_EDIT"
          class="create-btn"
          color="#ff7a00"
          @click="openCreate"
        >
          新增来源
        </el-button>
      </div>
    </div>

    <div v-loading="loading" class="table-panel">
      <AppError
        v-if="listError && !loading"
        :description="listError"
        @retry="loadList"
      />
      <template v-else>
        <el-table :data="sortedRecords" border stripe size="small" empty-text=" ">
          <el-table-column prop="name" label="来源名称" min-width="260" show-overflow-tooltip>
            <template #default="{ row }">
              {{ rowOf(row).name || '—' }}
            </template>
          </el-table-column>
          <el-table-column label="排序" width="230" align="center">
            <template #default="{ row }">
              <div class="move-btns">
                <el-button
                  v-permission="CustomerPermission.SOURCE_EDIT"
                  class="move-btn"
                  color="#ff7a00"
                  circle
                  :icon="Top"
                  :disabled="!canMoveUp(rowOf(row))"
                  @click="handleMove(rowOf(row), 'TOP')"
                />
                <el-button
                  v-permission="CustomerPermission.SOURCE_EDIT"
                  class="move-btn"
                  color="#ff7a00"
                  circle
                  :icon="ArrowUp"
                  :disabled="!canMoveUp(rowOf(row))"
                  @click="handleMove(rowOf(row), 'UP')"
                />
                <el-button
                  v-permission="CustomerPermission.SOURCE_EDIT"
                  class="move-btn"
                  color="#ff7a00"
                  circle
                  :icon="ArrowDown"
                  :disabled="!canMoveDown(rowOf(row))"
                  @click="handleMove(rowOf(row), 'DOWN')"
                />
                <el-button
                  v-permission="CustomerPermission.SOURCE_EDIT"
                  class="move-btn"
                  color="#ff7a00"
                  circle
                  :icon="Bottom"
                  :disabled="!canMoveDown(rowOf(row))"
                  @click="handleMove(rowOf(row), 'BOTTOM')"
                />
              </div>
            </template>
          </el-table-column>
          <el-table-column label="有效性" width="100" align="center">
            <template #default="{ row }">
              <el-tag
                :type="rowOf(row).active !== false ? 'success' : 'info'"
                effect="plain"
                size="small"
              >
                {{ rowOf(row).active !== false ? '有效' : '无效' }}
              </el-tag>
            </template>
          </el-table-column>
          <el-table-column label="操作" width="210" fixed="right">
            <template #default="{ row }">
              <el-button
                v-permission="CustomerPermission.SOURCE_EDIT"
                size="small"
                color="#ff7a00"
                @click="openEdit(rowOf(row))"
              >
                编辑
              </el-button>
              <el-button
                v-permission="CustomerPermission.SOURCE_EDIT"
                size="small"
                color="#ff7a00"
                @click="openCreateChild(rowOf(row))"
              >
                添加子来源
              </el-button>
            </template>
          </el-table-column>
        </el-table>

        <AppEmpty
          v-if="!loading && !listError && records.length === 0"
          title="暂无来源"
          description="可点击「新增来源」创建信息来源"
        />
      </template>
    </div>

    <el-dialog
      v-model="formVisible"
      :title="formMode === 'create' ? '新增来源' : '编辑来源'"
      width="480px"
      destroy-on-close
      :close-on-click-modal="false"
    >
      <div v-loading="formLoading">
        <AppError v-if="formError" :description="formError" />
        <el-form label-width="90px" @submit.prevent>
          <el-form-item label="来源名称" required>
            <el-input
              v-model="form.name"
              maxlength="50"
              show-word-limit
              placeholder="请输入来源名称"
            />
          </el-form-item>
          <el-form-item label="父级来源">
            <el-select v-model="form.parentId" filterable style="width: 100%">
              <el-option label="无（顶级）" :value="0" />
              <el-option
                v-for="item in parentSelectOptions"
                :key="item.id"
                :label="item.name"
                :value="item.id"
              />
            </el-select>
          </el-form-item>
          <el-form-item label="排序">
            <el-input-number v-model="form.sequence" :step="1" controls-position="right" />
          </el-form-item>
          <el-form-item label="有效性">
            <el-switch v-model="form.active" active-text="有效" inactive-text="无效" />
          </el-form-item>
        </el-form>
      </div>
      <template #footer>
        <el-button :disabled="formSaving" @click="formVisible = false">取消</el-button>
        <el-button
          color="#ff7a00"
          :loading="formSaving"
          :disabled="!hasEditPermission || formLoading"
          @click="handleSubmit"
        >
          保存
        </el-button>
      </template>
    </el-dialog>
  </section>
</template>

<style scoped>
.source-manage {
  display: flex;
  flex-direction: column;
  gap: 16px;
  min-height: 100%;
  padding: 20px 24px 24px;
}

.filter-bar {
  background: #fff;
  border: 1px solid #ebeef5;
  border-radius: 4px;
  padding: 12px 14px;
}

.filter-toolbar {
  display: flex;
  align-items: flex-start;
  justify-content: space-between;
  gap: 12px;
  flex-wrap: wrap;
}

.filter-form {
  flex: 1;
  margin-bottom: 0;
}

.create-btn {
  flex-shrink: 0;
  margin-top: 2px;
}

.table-panel {
  min-height: 240px;
  padding: 16px;
  border: 1px solid #ebeef5;
  border-radius: 8px;
  background: #fff;
}

.move-btns {
  display: inline-flex;
  align-items: center;
  gap: 6px;
}

.move-btn + .move-btn {
  margin-left: 0;
}
</style>
