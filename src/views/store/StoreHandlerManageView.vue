<script setup lang="ts">
import { computed, reactive, ref, watch } from 'vue'
import { ArrowDown, ArrowUp, Bottom, Top } from '@element-plus/icons-vue'

import AppEmpty from '@/components/common/AppEmpty.vue'
import AppError from '@/components/common/AppError.vue'
import { fetchOrganizationTree, type OrganizationTreeNode } from '@/api/organization'
import { fetchJobTypePage } from '@/api/hr'
import {
  createStoreHandler,
  fetchStoreHandlerPage,
  moveStoreHandler,
  updateStoreHandler,
} from '@/api/store-handler'
import {
  STORE_HANDLER_CATEGORIES,
  StoreHandlerPermission,
  type StoreHandlerItem,
  type StoreHandlerMoveDirection,
} from '@/types/store-handler'
import type { JobTypeRecord } from '@/types/hr'
import { usePermissionStore } from '@/stores/permission'
import {
  getUserFriendlyErrorMessage,
  notifyError,
  runExclusive,
  uiMessage,
} from '@/utils/ui'

defineOptions({ name: 'StoreHandlerManageView' })

const permissionStore = usePermissionStore()

const hasViewPermission = computed(() =>
  permissionStore.hasPermission(StoreHandlerPermission.VIEW),
)
const hasEditPermission = computed(() =>
  permissionStore.hasPermission(StoreHandlerPermission.EDIT),
)

/** 左侧分类 */
const activeCategory = ref<string>(STORE_HANDLER_CATEGORIES[0].code)
const activeCategoryLabel = computed(
  () => STORE_HANDLER_CATEGORIES.find((item) => item.code === activeCategory.value)?.label ?? '',
)

const loading = ref(false)
const listError = ref<string | null>(null)
const keywordInput = ref('')
const keyword = ref('')
/** 组织单位筛选 */
const orgFilter = ref<number | null>(null)
/** '' = 全部, 'true' = 有效, 'false' = 无效；按图示默认「有效」 */
const activeFilter = ref<'' | 'true' | 'false'>('true')
const records = ref<StoreHandlerItem[]>([])

/** 组织树（适用组织下拉） */
const orgTree = ref<OrganizationTreeNode[]>([])
/** 职务选项（适用职务多选） */
const jobOptions = ref<JobTypeRecord[]>([])

const formVisible = ref(false)
const formMode = ref<'create' | 'edit'>('create')
const formSaving = ref(false)
const formError = ref<string | null>(null)
const editingId = ref<number | null>(null)

const form = reactive({
  name: '',
  orgEntityId: null as number | null,
  jobTypeIds: [] as number[],
  active: true,
})

const sortedRecords = computed(() => {
  return [...records.value].sort(
    (a, b) => (a.sequence ?? 0) - (b.sequence ?? 0) || a.id - b.id,
  )
})

function canMoveUp(row: StoreHandlerItem): boolean {
  return sortedRecords.value.length > 1 && sortedRecords.value[0].id !== row.id
}

function canMoveDown(row: StoreHandlerItem): boolean {
  const list = sortedRecords.value
  return list.length > 1 && list[list.length - 1].id !== row.id
}

async function loadList(): Promise<void> {
  if (!hasViewPermission.value) {
    records.value = []
    listError.value = '暂无权限查看经手人（handler:manage:view）'
    return
  }
  await runExclusive(loading, async () => {
    listError.value = null
    try {
      const data = await fetchStoreHandlerPage({
        category: activeCategory.value,
        keyword: keyword.value.trim() || undefined,
        orgEntityId: orgFilter.value ?? undefined,
        active:
          activeFilter.value === 'true'
            ? true
            : activeFilter.value === 'false'
              ? false
              : undefined,
        page: 1,
        size: 200,
      })
      records.value = data.records ?? []
    } catch (error) {
      records.value = []
      listError.value = getUserFriendlyErrorMessage(error)
    }
  })
}

async function loadOrgTree(): Promise<void> {
  if (orgTree.value.length > 0) {
    return
  }
  try {
    orgTree.value = await fetchOrganizationTree(true)
  } catch {
    orgTree.value = []
  }
}

async function loadJobOptions(): Promise<void> {
  if (jobOptions.value.length > 0) {
    return
  }
  try {
    const data = await fetchJobTypePage({ page: 1, size: 200, active: true })
    jobOptions.value = data.records ?? []
  } catch {
    jobOptions.value = []
  }
}

function handleSearch(): void {
  keyword.value = keywordInput.value.trim()
  void loadList()
}

function handleReset(): void {
  keywordInput.value = ''
  keyword.value = ''
  orgFilter.value = null
  activeFilter.value = 'true'
  void loadList()
}

function handleCategoryChange(code: string): void {
  if (code === activeCategory.value) {
    return
  }
  activeCategory.value = code
  keywordInput.value = ''
  keyword.value = ''
  orgFilter.value = null
  activeFilter.value = 'true'
  void loadList()
}

function openCreate(): void {
  formMode.value = 'create'
  editingId.value = null
  form.name = ''
  form.orgEntityId = null
  form.jobTypeIds = []
  form.active = true
  formError.value = null
  formVisible.value = true
  void loadOrgTree()
  void loadJobOptions()
}

async function openEdit(row: StoreHandlerItem): Promise<void> {
  formMode.value = 'edit'
  editingId.value = row.id
  form.name = row.name ?? ''
  form.orgEntityId = row.orgEntityId ?? null
  form.jobTypeIds = [...(row.jobTypeIds ?? [])]
  form.active = row.active !== false
  formError.value = null
  formVisible.value = true
  void loadOrgTree()
  void loadJobOptions()
}

async function handleSubmit(): Promise<void> {
  const name = form.name.trim()
  if (!name) {
    uiMessage.warning('请填写经手人名称')
    return
  }
  if (name.length > 50) {
    uiMessage.warning('经手人名称最多 50 个字符')
    return
  }
  await runExclusive(formSaving, async () => {
    formError.value = null
    try {
      if (formMode.value === 'create') {
        await createStoreHandler({
          name,
          category: activeCategory.value,
          orgEntityId: form.orgEntityId ?? null,
          jobTypeIds: form.jobTypeIds,
          active: form.active,
        })
        uiMessage.success('经手人已创建')
      } else if (editingId.value != null) {
        await updateStoreHandler(editingId.value, {
          name,
          orgEntityId: form.orgEntityId ?? null,
          jobTypeIds: form.jobTypeIds,
          active: form.active,
        })
        uiMessage.success('经手人已更新')
      }
      formVisible.value = false
      await loadList()
    } catch (error) {
      formError.value = getUserFriendlyErrorMessage(error)
      notifyError(error)
    }
  })
}

async function handleMove(row: StoreHandlerItem, direction: StoreHandlerMoveDirection): Promise<void> {
  if (!hasEditPermission.value) {
    return
  }
  try {
    await moveStoreHandler(row.id, direction)
    await loadList()
  } catch (error) {
    notifyError(error)
  }
}

function rowOf(row: unknown): StoreHandlerItem {
  return row as StoreHandlerItem
}

/** 全选 / 取消全选。
 *  - 不传参（undefined）= 反转当前态（已全选→取消，否则全选），用于链接按钮
 *  - 传布尔值 = 设为指定状态，用于 header checkbox 的 change(checked) 回调
 */
function toggleAllJobTypes(next?: unknown): void {
  const allIds = jobOptions.value.map((job) => job.id)
  const alreadyAll =
    form.jobTypeIds.length === allIds.length && allIds.length > 0
  let shouldSelectAll: boolean
  if (next === undefined) {
    shouldSelectAll = !alreadyAll
  } else {
    shouldSelectAll = Boolean(next)
  }
  form.jobTypeIds = shouldSelectAll ? [...allIds] : []
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
  <section class="handler-manage">
    <aside class="category-panel">
      <div class="category-title">经手人分类</div>
      <ul class="category-list">
        <li
          v-for="item in STORE_HANDLER_CATEGORIES"
          :key="item.code"
          class="category-item"
          :class="{ active: item.code === activeCategory }"
          @click="handleCategoryChange(item.code)"
        >
          {{ item.label }}
        </li>
      </ul>
    </aside>

    <div class="content-panel">
      <div class="filter-bar">
        <div class="filter-toolbar">
          <el-form :inline="true" class="filter-form" @submit.prevent="handleSearch">
            <el-form-item :label="activeCategoryLabel">
              <el-input
                v-model="keywordInput"
                clearable
                :placeholder="`输入${activeCategoryLabel}名称`"
                style="max-width: 220px"
              />
            </el-form-item>
            <el-form-item label="组织单位">
              <el-tree-select
                v-model="orgFilter"
                :data="orgTree"
                check-strictly
                filterable
                clearable
                node-key="id"
                :props="{ label: 'entityName', children: 'children' }"
                placeholder="全部组织单位"
                style="width: 220px"
              />
            </el-form-item>
            <el-form-item label="有效性">
              <el-select v-model="activeFilter" style="width: 120px">
                <el-option label="全部" value="" />
                <el-option label="有效" value="true" />
                <el-option label="无效" value="false" />
              </el-select>
            </el-form-item>
            <el-form-item>
              <el-button type="primary" native-type="submit" :loading="loading">搜索</el-button>
              <el-button native-type="button" :disabled="loading" @click="handleReset">重置</el-button>
            </el-form-item>
          </el-form>
          <el-button
            v-permission="StoreHandlerPermission.EDIT"
            class="create-btn"
            color="#ff7a00"
            @click="openCreate"
          >
            新增
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
            <el-table-column
              prop="name"
              :label="activeCategoryLabel"
              min-width="220"
              show-overflow-tooltip
            >
              <template #default="{ row }">
                {{ rowOf(row).name || '—' }}
              </template>
            </el-table-column>
            <el-table-column label="移动" width="230" align="center">
              <template #default="{ row }">
                <div class="move-btns">
                  <el-button
                    v-permission="StoreHandlerPermission.EDIT"
                    class="move-btn"
                    color="#ff7a00"
                    circle
                    :icon="Top"
                    :disabled="!canMoveUp(rowOf(row))"
                    @click="handleMove(rowOf(row), 'TOP')"
                  />
                  <el-button
                    v-permission="StoreHandlerPermission.EDIT"
                    class="move-btn"
                    color="#ff7a00"
                    circle
                    :icon="ArrowUp"
                    :disabled="!canMoveUp(rowOf(row))"
                    @click="handleMove(rowOf(row), 'UP')"
                  />
                  <el-button
                    v-permission="StoreHandlerPermission.EDIT"
                    class="move-btn"
                    color="#ff7a00"
                    circle
                    :icon="ArrowDown"
                    :disabled="!canMoveDown(rowOf(row))"
                    @click="handleMove(rowOf(row), 'DOWN')"
                  />
                  <el-button
                    v-permission="StoreHandlerPermission.EDIT"
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
            <el-table-column label="适用组织" min-width="200" show-overflow-tooltip>
              <template #default="{ row }">
                {{ rowOf(row).orgEntityName || '全部组织' }}
              </template>
            </el-table-column>
            <el-table-column label="适用职务" min-width="200" show-overflow-tooltip>
              <template #default="{ row }">
                {{ (rowOf(row).jobTypeNames ?? []).length ? rowOf(row).jobTypeNames!.join('·') : '全部职务' }}
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
            <el-table-column label="操作" width="100" fixed="right">
              <template #default="{ row }">
                <el-button
                  v-permission="StoreHandlerPermission.EDIT"
                  size="small"
                  color="#ff7a00"
                  @click="openEdit(rowOf(row))"
                >
                  编辑
                </el-button>
              </template>
            </el-table-column>
          </el-table>

          <AppEmpty
            v-if="!loading && !listError && records.length === 0"
            title="暂无经手人"
            :description="`可点击「新增」创建${activeCategoryLabel}`"
          />
        </template>
      </div>
    </div>

    <el-dialog
      v-model="formVisible"
      :title="formMode === 'create' ? `新增${activeCategoryLabel}` : `编辑${activeCategoryLabel}`"
      width="520px"
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
            :placeholder="`请输入${activeCategoryLabel}名称`"
          />
        </el-form-item>
        <el-form-item label="适用组织">
          <el-tree-select
            v-model="form.orgEntityId"
            :data="orgTree"
            check-strictly
            filterable
            clearable
            node-key="id"
            :props="{ label: 'entityName', children: 'children' }"
            placeholder="全部组织（不选则适用全部）"
            style="width: 100%"
          />
        </el-form-item>
        <el-form-item label="适用职务">
          <div class="job-type-field">
            <el-select
              v-model="form.jobTypeIds"
              multiple
              filterable
              clearable
              collapse-tags
              collapse-tags-tooltip
              placeholder="全部职务（不选则适用全部）"
              style="width: 100%"
            >
              <template #header>
                <div class="select-all-row">
                  <el-checkbox
                    :model-value="form.jobTypeIds.length === jobOptions.length && jobOptions.length > 0"
                    :indeterminate="form.jobTypeIds.length > 0 && form.jobTypeIds.length < jobOptions.length"
                    @change="toggleAllJobTypes"
                  >
                    全选
                  </el-checkbox>
                </div>
              </template>
              <el-option
                v-for="job in jobOptions"
                :key="job.id"
                :label="job.name"
                :value="job.id"
              />
            </el-select>
            <el-button
              v-if="jobOptions.length > 0"
              class="job-type-quick"
              link
              type="primary"
              @click="toggleAllJobTypes()"
            >
              {{ form.jobTypeIds.length === jobOptions.length ? '取消全选' : '全选全部职务' }}
            </el-button>
          </div>
        </el-form-item>
        <el-form-item label="有效性">
          <el-switch v-model="form.active" active-text="有效" inactive-text="无效" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button :disabled="formSaving" @click="formVisible = false">取消</el-button>
        <el-button
          color="#ff7a00"
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
.handler-manage {
  display: flex;
  gap: 16px;
  min-height: 100%;
  padding: 20px 24px 24px;
  align-items: flex-start;
}

.category-panel {
  width: 220px;
  flex-shrink: 0;
  background: #fff;
  border: 1px solid #ebeef5;
  border-radius: 8px;
  padding: 12px;
}

.category-title {
  font-size: 13px;
  font-weight: 600;
  color: #909399;
  padding: 4px 8px 10px;
}

.category-list {
  list-style: none;
  margin: 0;
  padding: 0;
  display: flex;
  flex-direction: column;
  gap: 4px;
}

.category-item {
  padding: 9px 12px;
  border-radius: 6px;
  font-size: 14px;
  color: #303133;
  cursor: pointer;
  transition: background-color 0.15s, color 0.15s;
}

.category-item:hover {
  background: #fff4ea;
  color: #ff7a00;
}

.category-item.active {
  background: #ff7a00;
  color: #fff;
}

.content-panel {
  flex: 1;
  min-width: 0;
  display: flex;
  flex-direction: column;
  gap: 16px;
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
  min-height: 320px;
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

.job-type-field {
  width: 100%;
  display: flex;
  flex-direction: column;
  gap: 6px;
}

.job-type-quick {
  align-self: flex-start;
  padding: 0;
  font-size: 12px;
}

.select-all-row {
  padding: 2px 10px 6px;
  font-size: 13px;
}
</style>
