<script setup lang="ts">
import { computed, reactive, ref, watch } from 'vue'

import AppEmpty from '@/components/common/AppEmpty.vue'
import AppError from '@/components/common/AppError.vue'
import {
  createCardCategory,
  deactivateCardCategory,
  fetchCardCategoryDetail,
  fetchCardCategoryList,
  updateCardCategory,
} from '@/api/card'
import {
  CARD_CATEGORY_SORT_FIELDS,
  CardPermission,
  type CardCategoryItem,
  type CardCategoryKind,
  type CardCategorySortField,
} from '@/types/card'
import { usePermissionStore } from '@/stores/permission'
import {
  getUserFriendlyErrorMessage,
  notifyError,
  runExclusive,
  uiConfirm,
  uiMessage,
} from '@/utils/ui'

defineOptions({ name: 'CardCategoryManageView' })

const KIND_TABS: Array<{ kind: CardCategoryKind; label: string; view: string; edit: string }> = [
  {
    kind: 'general',
    label: '通用次卡分类',
    view: CardPermission.GENERAL_VIEW,
    edit: CardPermission.GENERAL_EDIT,
  },
  {
    kind: 'time',
    label: '时效卡分类',
    view: CardPermission.TIME_VIEW,
    edit: CardPermission.TIME_EDIT,
  },
  {
    kind: 'saving',
    label: '储值卡分类',
    view: CardPermission.SAVING_VIEW,
    edit: CardPermission.SAVING_EDIT,
  },
  {
    kind: 'package',
    label: '套餐卡分类',
    view: CardPermission.PACKAGE_VIEW,
    edit: CardPermission.PACKAGE_EDIT,
  },
]

const SORT_WHITELIST = new Set<string>(CARD_CATEGORY_SORT_FIELDS)

const permissionStore = usePermissionStore()

const activeKind = ref<CardCategoryKind>('general')
const activeTabMeta = computed(
  () => KIND_TABS.find((t) => t.kind === activeKind.value) ?? KIND_TABS[0],
)

const hasViewPermission = computed(() =>
  permissionStore.hasPermission(activeTabMeta.value.view),
)
const hasEditPermission = computed(() =>
  permissionStore.hasPermission(activeTabMeta.value.edit),
)

const visibleTabs = computed(() =>
  KIND_TABS.filter((t) => permissionStore.hasPermission(t.view)),
)

const loading = ref(false)
const listError = ref<string | null>(null)
const onlyActiveFilter = ref(false)
const records = ref<CardCategoryItem[]>([])
const sortField = ref<CardCategorySortField>('sequence')
const sortOrder = ref<'asc' | 'desc'>('asc')
const deactivatingIds = ref<Set<number>>(new Set())

const tableDefaultSort = computed(() => ({
  prop: sortField.value,
  order: (sortOrder.value === 'asc' ? 'ascending' : 'descending') as
    | 'ascending'
    | 'descending',
}))

function mapSortField(prop: string | null | undefined): CardCategorySortField | null {
  if (prop == null || prop === '') {
    return null
  }
  if (!SORT_WHITELIST.has(prop)) {
    return null
  }
  return prop as CardCategorySortField
}

function handleSortChange(payload: {
  prop: string | null
  order: 'ascending' | 'descending' | null
}): void {
  const field = mapSortField(payload.prop)
  if (field == null || payload.order == null) {
    sortField.value = 'sequence'
    sortOrder.value = 'asc'
  } else {
    sortField.value = field
    sortOrder.value = payload.order === 'ascending' ? 'asc' : 'desc'
  }
  void loadList()
}

const formVisible = ref(false)
const formMode = ref<'create' | 'edit'>('create')
const formLoading = ref(false)
const formSaving = ref(false)
const formError = ref<string | null>(null)
const editingId = ref<number | null>(null)

const form = reactive({
  name: '',
  sequence: 0 as number,
  active: true,
})

function rowOf(row: unknown): CardCategoryItem {
  return row as CardCategoryItem
}

async function loadList(): Promise<void> {
  if (!hasViewPermission.value) {
    records.value = []
    listError.value = `暂无权限查看（${activeTabMeta.value.view}）`
    return
  }
  await runExclusive(loading, async () => {
    listError.value = null
    try {
      records.value = await fetchCardCategoryList(activeKind.value, {
        onlyActive: onlyActiveFilter.value ? true : undefined,
        sortField: sortField.value,
        sortOrder: sortOrder.value,
      })
    } catch (error) {
      records.value = []
      listError.value = getUserFriendlyErrorMessage(error)
    }
  })
}

function handleReset(): void {
  onlyActiveFilter.value = false
  sortField.value = 'sequence'
  sortOrder.value = 'asc'
  void loadList()
}

function openCreate(): void {
  formMode.value = 'create'
  editingId.value = null
  form.name = ''
  form.sequence = 0
  form.active = true
  formError.value = null
  formVisible.value = true
}

async function openEdit(row: CardCategoryItem): Promise<void> {
  formMode.value = 'edit'
  editingId.value = row.id
  form.name = row.name ?? ''
  form.sequence = row.sequence ?? 0
  form.active = row.active !== false
  formError.value = null
  formVisible.value = true
  formLoading.value = true
  try {
    const detail = await fetchCardCategoryDetail(activeKind.value, row.id)
    form.name = detail.name ?? ''
    form.sequence = detail.sequence ?? 0
    form.active = detail.active !== false
  } catch (error) {
    notifyError(error)
  } finally {
    formLoading.value = false
  }
}

function validateForm(): string | null {
  if (!form.name.trim()) {
    return '请输入分类名称'
  }
  if (form.sequence == null || Number.isNaN(Number(form.sequence))) {
    return '请输入排序值'
  }
  return null
}

async function handleSubmit(): Promise<void> {
  if (!hasEditPermission.value) {
    return
  }
  const err = validateForm()
  if (err) {
    formError.value = err
    return
  }
  await runExclusive(formSaving, async () => {
    formError.value = null
    try {
      const body = {
        name: form.name.trim(),
        sequence: form.sequence,
        active: form.active,
      }
      if (formMode.value === 'create') {
        await createCardCategory(activeKind.value, body)
        uiMessage.success('分类已创建')
      } else if (editingId.value != null) {
        await updateCardCategory(activeKind.value, editingId.value, body)
        uiMessage.success('分类已保存')
      }
      formVisible.value = false
      await loadList()
    } catch (error) {
      formError.value = getUserFriendlyErrorMessage(error)
    }
  })
}

async function handleActivate(row: CardCategoryItem): Promise<void> {
  if (!hasEditPermission.value || row.active !== false) {
    return
  }
  try {
    await updateCardCategory(activeKind.value, row.id, {
      name: row.name ?? '',
      sequence: row.sequence ?? 0,
      active: true,
    })
    uiMessage.success('分类已启用')
    await loadList()
  } catch (error) {
    notifyError(error)
  }
}

async function handleDeactivate(row: CardCategoryItem): Promise<void> {
  if (!hasEditPermission.value || row.active === false) {
    return
  }
  const ok = await uiConfirm({
    title: '停用确认',
    message: `确认停用分类「${row.name || row.id}」？停用后不可再用于新建/改绑卡定义，历史卡仍可回显原分类名称。`,
    confirmText: '停用',
  })
  if (!ok) {
    return
  }
  const next = new Set(deactivatingIds.value)
  next.add(row.id)
  deactivatingIds.value = next
  try {
    await deactivateCardCategory(activeKind.value, row.id)
    uiMessage.success('分类已停用')
    await loadList()
  } catch (error) {
    notifyError(error)
  } finally {
    const cleared = new Set(deactivatingIds.value)
    cleared.delete(row.id)
    deactivatingIds.value = cleared
  }
}

watch(
  [activeKind, hasViewPermission],
  () => {
    void loadList()
  },
  { immediate: true },
)

watch(
  visibleTabs,
  (tabs) => {
    if (tabs.length === 0) {
      return
    }
    if (!tabs.some((t) => t.kind === activeKind.value)) {
      activeKind.value = tabs[0].kind
    }
  },
  { immediate: true },
)
</script>

<template>
  <section class="card-category-manage">
    <header class="page-header">
      <div>
        <h1>卡类分类</h1>
        <p class="subtitle">
          四类卡商品归类展示（平面列表）；可售门店仍由 SaleEntity 配置。分类不作渠道与报价依据。
          默认按排序值升序、同序按 ID 升序。
        </p>
      </div>
    </header>

    <el-tabs v-model="activeKind" class="kind-tabs">
      <el-tab-pane
        v-for="tab in visibleTabs"
        :key="tab.kind"
        :label="tab.label"
        :name="tab.kind"
      />
    </el-tabs>

    <AppEmpty
      v-if="visibleTabs.length === 0"
      title="暂无卡分类查看权限"
      description="需要 card:general|time|saving|package:view 之一"
    />

    <template v-else>
      <div class="filter-bar">
        <div class="filter-toolbar">
          <el-form :inline="true" class="filter-form" @submit.prevent="loadList">
            <el-form-item label="状态">
              <el-checkbox v-model="onlyActiveFilter">仅显示启用</el-checkbox>
            </el-form-item>
            <el-form-item>
              <el-button type="primary" native-type="submit" :loading="loading">查询</el-button>
              <el-button native-type="button" :disabled="loading" @click="handleReset">重置</el-button>
            </el-form-item>
          </el-form>
          <el-button
            v-if="hasEditPermission"
            class="create-btn"
            type="primary"
            @click="openCreate"
          >
            新增分类
          </el-button>
        </div>
      </div>

      <div v-loading="loading" class="table-panel">
        <AppError v-if="listError && !loading" :description="listError" @retry="loadList" />
        <template v-else>
          <el-table
            :data="records"
            border
            stripe
            size="small"
            empty-text=" "
            :default-sort="tableDefaultSort"
            @sort-change="handleSortChange"
          >
            <el-table-column
              prop="name"
              label="分类名称"
              min-width="160"
              sortable="custom"
              show-overflow-tooltip
            >
              <template #default="{ row }">{{ rowOf(row).name || '—' }}</template>
            </el-table-column>
            <el-table-column
              prop="sequence"
              label="排序"
              width="100"
              align="right"
              sortable="custom"
            >
              <template #default="{ row }">{{ rowOf(row).sequence ?? '—' }}</template>
            </el-table-column>
            <el-table-column label="关联卡数" width="100" align="right">
              <template #default="{ row }">{{ rowOf(row).cardCount ?? 0 }}</template>
            </el-table-column>
            <el-table-column prop="active" label="状态" width="100" sortable="custom">
              <template #default="{ row }">
                <el-tag
                  :type="rowOf(row).active === false ? 'info' : 'success'"
                  size="small"
                >
                  {{ rowOf(row).active === false ? '停用' : '启用' }}
                </el-tag>
              </template>
            </el-table-column>
            <el-table-column label="操作" width="200" fixed="right">
              <template #default="{ row }">
                <el-button
                  v-if="hasEditPermission"
                  link
                  type="primary"
                  @click="openEdit(rowOf(row))"
                >
                  编辑
                </el-button>
                <el-button
                  v-if="hasEditPermission && rowOf(row).active === false"
                  link
                  type="success"
                  @click="handleActivate(rowOf(row))"
                >
                  启用
                </el-button>
                <el-button
                  v-if="hasEditPermission && rowOf(row).active !== false"
                  link
                  type="warning"
                  :disabled="deactivatingIds.has(rowOf(row).id)"
                  @click="handleDeactivate(rowOf(row))"
                >
                  停用
                </el-button>
              </template>
            </el-table-column>
          </el-table>
          <AppEmpty
            v-if="!loading && !listError && records.length === 0"
            title="暂无分类"
            description="可点击「新增分类」创建"
          />
        </template>
      </div>
    </template>

    <el-dialog
      v-model="formVisible"
      :title="formMode === 'create' ? '新增分类' : '编辑分类'"
      width="480px"
      destroy-on-close
      :close-on-click-modal="false"
    >
      <div v-loading="formLoading">
        <AppError v-if="formError" :description="formError" />
        <el-form label-width="100px" @submit.prevent>
          <el-form-item label="分类名称" required>
            <el-input
              v-model="form.name"
              maxlength="50"
              show-word-limit
              placeholder="请输入分类名称"
              :disabled="!hasEditPermission"
            />
          </el-form-item>
          <el-form-item label="排序值" required>
            <el-input-number
              v-model="form.sequence"
              :step="1"
              :precision="0"
              controls-position="right"
              style="width: 100%"
              :disabled="!hasEditPermission"
            />
            <p class="field-hint">默认按排序值升序；表头可切换白名单排序</p>
          </el-form-item>
          <el-form-item v-if="formMode === 'edit'" label="启用状态">
            <el-switch
              v-model="form.active"
              active-text="启用"
              inactive-text="停用"
              :disabled="!hasEditPermission"
            />
          </el-form-item>
        </el-form>
      </div>
      <template #footer>
        <el-button :disabled="formSaving" @click="formVisible = false">取消</el-button>
        <el-button
          v-if="hasEditPermission"
          type="primary"
          :loading="formSaving"
          :disabled="formLoading"
          @click="handleSubmit"
        >
          保存
        </el-button>
      </template>
    </el-dialog>
  </section>
</template>

<style scoped>
.card-category-manage {
  display: flex;
  flex-direction: column;
  gap: 16px;
  min-height: 100%;
  padding: 20px 24px 24px;
}

.page-header {
  display: flex;
  flex-wrap: wrap;
  gap: 12px;
  align-items: flex-start;
  justify-content: space-between;
}

.page-header h1 {
  margin: 0;
  font-size: 20px;
  font-weight: 600;
  color: #1f2329;
}

.subtitle {
  margin: 6px 0 0;
  font-size: 13px;
  color: #8a9099;
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
  min-height: 200px;
}

.field-hint {
  margin: 4px 0 0;
  font-size: 12px;
  color: #8a9099;
  line-height: 1.4;
}

.kind-tabs {
  margin-top: -4px;
}
</style>
