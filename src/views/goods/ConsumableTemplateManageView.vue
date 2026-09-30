<script setup lang="ts">
import { computed, reactive, ref, watch } from 'vue'

import AppEmpty from '@/components/common/AppEmpty.vue'
import AppError from '@/components/common/AppError.vue'
import {
  createConsumableTemplate,
  deactivateConsumableTemplate,
  fetchConsumableCategoryOptions,
  fetchConsumableTemplateDetail,
  fetchConsumableTemplateList,
  updateConsumableTemplate,
} from '@/api/consumable'
import { fetchProductOptions } from '@/api/product'
import { fetchProjectOptions } from '@/api/project'
import {
  ConsumablePermission,
  type ConsumableCategoryItem,
  type ConsumableTemplateItem,
  type ConsumableTemplateProductLine,
} from '@/types/consumable'
import type { ProductOption } from '@/types/product'
import type { ProjectItem } from '@/types/project'
import { usePermissionStore } from '@/stores/permission'
import {
  getUserFriendlyErrorMessage,
  notifyError,
  runExclusive,
  uiConfirm,
  uiMessage,
} from '@/utils/ui'

defineOptions({ name: 'ConsumableTemplateManageView' })

const permissionStore = usePermissionStore()

const hasViewPermission = computed(() =>
  permissionStore.hasPermission(ConsumablePermission.VIEW),
)
const hasEditPermission = computed(() =>
  permissionStore.hasPermission(ConsumablePermission.EDIT),
)

const loading = ref(false)
const listError = ref<string | null>(null)
const onlyActiveFilter = ref(false)
const filterCategoryId = ref<number | null>(null)
const records = ref<ConsumableTemplateItem[]>([])
const categoryOptions = ref<ConsumableCategoryItem[]>([])
const deactivatingIds = ref<Set<number>>(new Set())

const formVisible = ref(false)
const formMode = ref<'create' | 'edit'>('create')
const formLoading = ref(false)
const formSaving = ref(false)
const formError = ref<string | null>(null)
const editingId = ref<number | null>(null)

const productOptions = ref<ProductOption[]>([])
const projectOptions = ref<ProjectItem[]>([])
const optionsError = ref<string | null>(null)

const form = reactive({
  name: '',
  categoryId: null as number | null,
  active: true,
  products: [] as ConsumableTemplateProductLine[],
  projectIds: [] as number[],
})

const draftProductId = ref<number | null>(null)
const draftQuantity = ref(1)

const productNameMap = computed(() => {
  const map = new Map<number, string>()
  for (const p of productOptions.value) {
    map.set(p.id, p.name || String(p.id))
  }
  return map
})

const projectNameMap = computed(() => {
  const map = new Map<number, string>()
  for (const p of projectOptions.value) {
    map.set(p.id, p.name || String(p.id))
  }
  return map
})

/** 下拉可选产品：排除已添加的 */
const availableProductOptions = computed(() => {
  const used = new Set(form.products.map((l) => l.productId))
  return productOptions.value.filter((p) => !used.has(p.id))
})

function rowOf(row: unknown): ConsumableTemplateItem {
  return row as ConsumableTemplateItem
}

function productCount(row: ConsumableTemplateItem): number {
  return row.products?.length ?? 0
}

function projectCount(row: ConsumableTemplateItem): number {
  return row.projectIds?.length ?? 0
}

function productLabel(productId: number): string {
  return productNameMap.value.get(productId) || `产品#${productId}`
}

function projectLabel(projectId: number): string {
  return projectNameMap.value.get(projectId) || `项目#${projectId}`
}

async function loadCategoryOptions(): Promise<void> {
  try {
    categoryOptions.value = await fetchConsumableCategoryOptions()
  } catch (error) {
    categoryOptions.value = []
    optionsError.value = getUserFriendlyErrorMessage(error)
  }
}

async function loadProductAndProjectOptions(): Promise<void> {
  optionsError.value = null
  try {
    const [products, projects] = await Promise.all([
      fetchProductOptions(),
      fetchProjectOptions(),
    ])
    productOptions.value = products
    projectOptions.value = projects
  } catch (error) {
    optionsError.value = getUserFriendlyErrorMessage(error)
  }
}

/**
 * 列表接口不含明细；并行拉详情补齐数量（管理员配置，规模通常较小）。
 */
async function enrichWithDetails(
  rows: ConsumableTemplateItem[],
): Promise<ConsumableTemplateItem[]> {
  if (rows.length === 0) {
    return []
  }
  return Promise.all(
    rows.map(async (row) => {
      try {
        const detail = await fetchConsumableTemplateDetail(row.id)
        return {
          ...row,
          products: detail.products ?? [],
          projectIds: detail.projectIds ?? [],
          categoryName: detail.categoryName ?? row.categoryName,
        }
      } catch {
        return { ...row, products: [], projectIds: [] }
      }
    }),
  )
}

async function loadList(): Promise<void> {
  if (!hasViewPermission.value) {
    records.value = []
    listError.value = '暂无权限查看耗材模板（consumable:view）'
    return
  }
  await runExclusive(loading, async () => {
    listError.value = null
    try {
      const rows = await fetchConsumableTemplateList({
        onlyActive: onlyActiveFilter.value ? true : undefined,
        categoryId: filterCategoryId.value ?? undefined,
      })
      records.value = await enrichWithDetails(rows)
    } catch (error) {
      records.value = []
      listError.value = getUserFriendlyErrorMessage(error)
    }
  })
}

function handleReset(): void {
  onlyActiveFilter.value = false
  filterCategoryId.value = null
  void loadList()
}

function resetDraftProduct(): void {
  draftProductId.value = null
  draftQuantity.value = 1
}

function openCreate(): void {
  formMode.value = 'create'
  editingId.value = null
  form.name = ''
  form.categoryId = null
  form.active = true
  form.products = []
  form.projectIds = []
  formError.value = null
  resetDraftProduct()
  formVisible.value = true
  void loadCategoryOptions()
}

async function openEdit(row: ConsumableTemplateItem): Promise<void> {
  formMode.value = 'edit'
  editingId.value = row.id
  formError.value = null
  resetDraftProduct()
  formVisible.value = true
  formLoading.value = true
  void loadCategoryOptions()
  void loadProductAndProjectOptions()
  try {
    const detail = await fetchConsumableTemplateDetail(row.id)
    form.name = detail.name ?? ''
    form.categoryId = detail.categoryId
    form.active = detail.active !== false
    form.products = (detail.products ?? []).map((p) => ({
      productId: p.productId,
      minimumUnitQuantity: p.minimumUnitQuantity > 0 ? p.minimumUnitQuantity : 1,
    }))
    form.projectIds = [...(detail.projectIds ?? [])]
  } catch (error) {
    notifyError(error)
  } finally {
    formLoading.value = false
  }
}

function validateMain(): string | null {
  if (!form.name.trim()) {
    return '请输入模板名称'
  }
  if (form.categoryId == null) {
    return '请选择耗材类别'
  }
  return null
}

function validateDetails(): string | null {
  const seen = new Set<number>()
  for (const line of form.products) {
    if (line.productId == null) {
      return '产品明细存在未选择的产品'
    }
    if (seen.has(line.productId)) {
      return '同一产品不能重复添加'
    }
    seen.add(line.productId)
    if (
      line.minimumUnitQuantity == null ||
      !Number.isFinite(line.minimumUnitQuantity) ||
      line.minimumUnitQuantity <= 0
    ) {
      return '产品用量必须为正数'
    }
  }
  const projectSeen = new Set<number>()
  for (const id of form.projectIds) {
    if (projectSeen.has(id)) {
      return '适用项目不能重复'
    }
    projectSeen.add(id)
  }
  return null
}

function handleAddProductLine(): void {
  if (!hasEditPermission.value) {
    return
  }
  if (draftProductId.value == null) {
    uiMessage.warning('请选择产品')
    return
  }
  if (form.products.some((l) => l.productId === draftProductId.value)) {
    uiMessage.warning('该产品已在明细中，不能重复添加')
    return
  }
  if (draftQuantity.value == null || draftQuantity.value <= 0) {
    uiMessage.warning('用量必须为正数')
    return
  }
  form.products.push({
    productId: draftProductId.value,
    minimumUnitQuantity: Math.floor(draftQuantity.value),
  })
  resetDraftProduct()
}

function handleRemoveProductLine(index: number): void {
  form.products.splice(index, 1)
}

async function handleSubmit(): Promise<void> {
  if (!hasEditPermission.value) {
    return
  }
  const mainErr = validateMain()
  if (mainErr) {
    formError.value = mainErr
    return
  }
  if (formMode.value === 'edit') {
    const detailErr = validateDetails()
    if (detailErr) {
      formError.value = detailErr
      return
    }
  }
  await runExclusive(formSaving, async () => {
    formError.value = null
    try {
      if (formMode.value === 'create') {
        const created = await createConsumableTemplate({
          name: form.name.trim(),
          categoryId: form.categoryId!,
          active: form.active,
        })
        uiMessage.success('模板已创建，请继续维护产品明细与适用项目')
        editingId.value = created.id
        formMode.value = 'edit'
        form.products = []
        form.projectIds = []
        void loadProductAndProjectOptions()
        await loadList()
      } else if (editingId.value != null) {
        await updateConsumableTemplate(editingId.value, {
          name: form.name.trim(),
          categoryId: form.categoryId!,
          active: form.active,
          products: form.products.map((p) => ({
            productId: p.productId,
            minimumUnitQuantity: p.minimumUnitQuantity,
          })),
          projectIds: [...form.projectIds],
        })
        uiMessage.success('模板已保存')
        const detail = await fetchConsumableTemplateDetail(editingId.value)
        form.products = (detail.products ?? []).map((p) => ({
          productId: p.productId,
          minimumUnitQuantity: p.minimumUnitQuantity > 0 ? p.minimumUnitQuantity : 1,
        }))
        form.projectIds = [...(detail.projectIds ?? [])]
        form.active = detail.active !== false
        await loadList()
      }
    } catch (error) {
      formError.value = getUserFriendlyErrorMessage(error)
    }
  })
}

async function handleDeactivate(row: ConsumableTemplateItem): Promise<void> {
  if (!hasEditPermission.value || row.active === false) {
    return
  }
  const ok = await uiConfirm({
    title: '停用确认',
    message: `确认停用耗材模板「${row.name || row.id}」？`,
    confirmText: '停用',
  })
  if (!ok) {
    return
  }
  const next = new Set(deactivatingIds.value)
  next.add(row.id)
  deactivatingIds.value = next
  try {
    await deactivateConsumableTemplate(row.id)
    uiMessage.success('模板已停用')
    await loadList()
  } catch (error) {
    notifyError(error)
  } finally {
    const cleared = new Set(deactivatingIds.value)
    cleared.delete(row.id)
    deactivatingIds.value = cleared
  }
}

async function handleActivate(row: ConsumableTemplateItem): Promise<void> {
  if (!hasEditPermission.value || row.active !== false) {
    return
  }
  const ok = await uiConfirm({
    title: '启用确认',
    message: `确认启用耗材模板「${row.name || row.id}」？`,
    confirmText: '启用',
  })
  if (!ok) {
    return
  }
  try {
    const detail = await fetchConsumableTemplateDetail(row.id)
    if (detail.categoryId == null) {
      uiMessage.warning('模板缺少类别，无法启用')
      return
    }
    await updateConsumableTemplate(row.id, {
      name: detail.name || String(row.id),
      categoryId: detail.categoryId,
      active: true,
    })
    uiMessage.success('模板已启用')
    await loadList()
  } catch (error) {
    notifyError(error)
  }
}

watch(
  hasViewPermission,
  () => {
    void loadCategoryOptions()
    void loadList()
  },
  { immediate: true },
)
</script>

<template>
  <section class="consumable-template-manage">
    <header class="page-header">
      <div>
        <h1>耗材模板</h1>
        <p class="subtitle">
          项目耗材模板（产品为明细行）；列表按后端默认 id 降序，无 sortField
        </p>
      </div>
      <el-button
        v-permission="ConsumablePermission.EDIT"
        type="primary"
        @click="openCreate"
      >
        新增模板
      </el-button>
    </header>

    <form class="toolbar" @submit.prevent="loadList">
      <el-checkbox v-model="onlyActiveFilter">仅显示启用</el-checkbox>
      <el-select
        v-model="filterCategoryId"
        clearable
        filterable
        placeholder="类别"
        style="width: 180px"
      >
        <el-option
          v-for="c in categoryOptions"
          :key="c.id"
          :label="c.name || String(c.id)"
          :value="c.id"
        />
      </el-select>
      <el-button type="primary" native-type="submit" :loading="loading">查询</el-button>
      <el-button native-type="button" :disabled="loading" @click="handleReset">重置</el-button>
    </form>

    <div v-loading="loading" class="table-panel">
      <AppError v-if="listError && !loading" :description="listError" @retry="loadList" />
      <template v-else>
        <el-table :data="records" border stripe size="small" empty-text=" ">
          <el-table-column prop="name" label="模板名称" min-width="160" show-overflow-tooltip>
            <template #default="{ row }">{{ rowOf(row).name || '—' }}</template>
          </el-table-column>
          <el-table-column label="类别" min-width="120" show-overflow-tooltip>
            <template #default="{ row }">{{ rowOf(row).categoryName || '—' }}</template>
          </el-table-column>
          <el-table-column prop="active" label="启用状态" width="100">
            <template #default="{ row }">
              <el-tag :type="rowOf(row).active !== false ? 'success' : 'info'" size="small">
                {{ rowOf(row).active !== false ? '启用' : '停用' }}
              </el-tag>
            </template>
          </el-table-column>
          <el-table-column label="产品明细数量" width="120" align="right">
            <template #default="{ row }">{{ productCount(rowOf(row)) }}</template>
          </el-table-column>
          <el-table-column label="适用项目数量" width="120" align="right">
            <template #default="{ row }">{{ projectCount(rowOf(row)) }}</template>
          </el-table-column>
          <el-table-column label="操作" width="200" fixed="right">
            <template #default="{ row }">
              <el-button
                v-permission="ConsumablePermission.EDIT"
                link
                type="primary"
                @click="openEdit(rowOf(row))"
              >
                编辑
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
              <el-button
                v-if="hasEditPermission && rowOf(row).active === false"
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
          title="暂无耗材模板"
          description="可点击「新增模板」创建；创建后可维护产品与适用项目"
        />
      </template>
    </div>

    <el-dialog
      v-model="formVisible"
      :title="formMode === 'create' ? '新增耗材模板' : '编辑耗材模板'"
      width="760px"
      destroy-on-close
      :close-on-click-modal="false"
    >
      <div v-loading="formLoading">
        <AppError v-if="formError" :description="formError" />
        <AppError v-if="optionsError" :description="optionsError" />

        <el-form label-width="100px" @submit.prevent>
          <el-form-item label="模板名称" required>
            <el-input
              v-model="form.name"
              maxlength="100"
              show-word-limit
              placeholder="请输入模板名称"
              :disabled="!hasEditPermission"
            />
          </el-form-item>
          <el-form-item label="耗材类别" required>
            <el-select
              v-model="form.categoryId"
              filterable
              placeholder="请选择启用中的类别"
              style="width: 100%"
              :disabled="!hasEditPermission"
            >
              <el-option
                v-for="c in categoryOptions"
                :key="c.id"
                :label="c.name || String(c.id)"
                :value="c.id"
              />
            </el-select>
            <p class="field-hint">停用类别不会出现在选项中</p>
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

        <template v-if="formMode === 'edit'">
          <div class="section-block">
            <div class="section-title">产品明细（用量）</div>
            <p v-if="form.products.length === 0" class="section-empty">暂无产品明细</p>
            <el-table
              v-else
              :data="form.products"
              border
              size="small"
              empty-text=" "
              class="inner-table"
            >
              <el-table-column label="产品" min-width="180">
                <template #default="{ row }">
                  {{ productLabel((row as ConsumableTemplateProductLine).productId) }}
                </template>
              </el-table-column>
              <el-table-column label="用量" width="140" align="right">
                <template #default="{ row }">
                  <el-input-number
                    v-model="(row as ConsumableTemplateProductLine).minimumUnitQuantity"
                    :min="1"
                    :step="1"
                    :precision="0"
                    controls-position="right"
                    style="width: 110px"
                    :disabled="!hasEditPermission"
                  />
                </template>
              </el-table-column>
              <el-table-column v-if="hasEditPermission" label="操作" width="80">
                <template #default="{ $index }">
                  <el-button link type="danger" @click="handleRemoveProductLine($index)">
                    删除
                  </el-button>
                </template>
              </el-table-column>
            </el-table>

            <div v-if="hasEditPermission" class="add-row">
              <el-select
                v-model="draftProductId"
                filterable
                clearable
                placeholder="选择产品（options，停用不可选）"
                style="width: 260px"
              >
                <el-option
                  v-for="p in availableProductOptions"
                  :key="p.id"
                  :label="p.name || String(p.id)"
                  :value="p.id"
                />
              </el-select>
              <el-input-number
                v-model="draftQuantity"
                :min="1"
                :step="1"
                :precision="0"
                controls-position="right"
              />
              <el-button type="primary" @click="handleAddProductLine">添加产品</el-button>
            </div>
          </div>

          <div class="section-block">
            <div class="section-title">适用项目</div>
            <p v-if="form.projectIds.length === 0" class="section-empty">暂无适用项目</p>
            <el-select
              v-model="form.projectIds"
              multiple
              filterable
              collapse-tags
              collapse-tags-tooltip
              placeholder="从项目 options 选择"
              style="width: 100%"
              :disabled="!hasEditPermission"
            >
              <el-option
                v-for="p in projectOptions"
                :key="p.id"
                :label="p.name || String(p.id)"
                :value="p.id"
              />
            </el-select>
            <ul v-if="form.projectIds.length > 0" class="project-preview">
              <li v-for="id in form.projectIds" :key="id">{{ projectLabel(id) }}</li>
            </ul>
          </div>
        </template>
        <p v-else class="field-hint">
          新增时先保存主表；保存成功后将进入编辑，再维护产品明细与适用项目。
        </p>
      </div>
      <template #footer>
        <el-button :disabled="formSaving" @click="formVisible = false">
          {{ formMode === 'edit' ? '关闭' : '取消' }}
        </el-button>
        <el-button
          v-if="hasEditPermission"
          type="primary"
          :loading="formSaving"
          :disabled="formLoading"
          @click="handleSubmit"
        >
          {{ formMode === 'create' ? '创建并继续' : '保存' }}
        </el-button>
      </template>
    </el-dialog>
  </section>
</template>

<style scoped>
.consumable-template-manage {
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
  margin: 0 0 4px;
  font-size: 20px;
  font-weight: 600;
  color: #303133;
}

.subtitle {
  margin: 0;
  font-size: 13px;
  color: #909399;
}

.toolbar {
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
  align-items: center;
}

.table-panel {
  min-height: 240px;
  padding: 16px;
  border: 1px solid #ebeef5;
  border-radius: 8px;
  background: #fff;
}

.field-hint {
  margin: 4px 0 0;
  font-size: 12px;
  color: #909399;
  line-height: 1.4;
}

.section-block {
  margin-top: 16px;
  padding-top: 12px;
  border-top: 1px solid #ebeef5;
}

.section-title {
  margin-bottom: 8px;
  font-size: 14px;
  font-weight: 600;
  color: #303133;
}

.section-empty {
  margin: 0 0 8px;
  font-size: 13px;
  color: #909399;
}

.inner-table {
  margin-bottom: 8px;
}

.add-row {
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
  align-items: center;
  margin-top: 8px;
}

.project-preview {
  margin: 8px 0 0;
  padding-left: 18px;
  font-size: 13px;
  color: #606266;
}
</style>
