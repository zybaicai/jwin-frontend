<script setup lang="ts">
import { computed, reactive, ref, watch } from 'vue'

import AppEmpty from '@/components/common/AppEmpty.vue'
import AppError from '@/components/common/AppError.vue'
import {
  createProduct,
  deactivateProduct,
  fetchProductBrandOptions,
  fetchProductCategoryOptions,
  fetchProductDetail,
  fetchProductPage,
  updateProduct,
} from '@/api/product'
import {
  PRODUCT_SORT_FIELDS,
  ProductPermission,
  type NamedOption,
  type ProductItem,
  type ProductSortField,
} from '@/types/product'
import { usePermissionStore } from '@/stores/permission'
import { formatAmountDisplay, normalizeAmountString } from '@/utils/amount'
import {
  getUserFriendlyErrorMessage,
  notifyError,
  runExclusive,
  uiConfirm,
  uiMessage,
} from '@/utils/ui'

defineOptions({ name: 'ProductManageView' })

const SORT_WHITELIST = new Set<string>(PRODUCT_SORT_FIELDS)

const permissionStore = usePermissionStore()

const hasViewPermission = computed(() =>
  permissionStore.hasPermission(ProductPermission.VIEW),
)
const hasEditPermission = computed(() =>
  permissionStore.hasPermission(ProductPermission.EDIT),
)

const loading = ref(false)
const listError = ref<string | null>(null)
const keywordInput = ref('')
const keyword = ref('')
const categoryFilter = ref<number | null>(null)
const brandFilter = ref<number | null>(null)
const activeFilter = ref<'' | 'true' | 'false'>('')
const page = ref(1)
const size = ref(20)
const total = ref(0)
const records = ref<ProductItem[]>([])
const sortField = ref<ProductSortField>('id')
const sortOrder = ref<'asc' | 'desc'>('asc')
const deactivatingIds = ref<Set<number>>(new Set())

const categoryOptions = ref<NamedOption[]>([])
const brandOptions = ref<NamedOption[]>([])
const optionsError = ref<string | null>(null)

const formVisible = ref(false)
const formMode = ref<'create' | 'edit'>('create')
const formLoading = ref(false)
const formSaving = ref(false)
const formError = ref<string | null>(null)
const editingId = ref<number | null>(null)

const form = reactive({
  name: '',
  alias: '',
  categoryId: null as number | null,
  brandId: null as number | null,
  specification: '',
  active: true,
  price: '',
  allowSell: true,
  allowLargess: false,
  remark: '',
})

const tableDefaultSort = computed(() => ({
  prop: sortField.value,
  order: (sortOrder.value === 'asc' ? 'ascending' : 'descending') as
    | 'ascending'
    | 'descending',
}))

function mapSortField(prop: string | null | undefined): ProductSortField | null {
  if (prop == null || prop === '') {
    return null
  }
  if (!SORT_WHITELIST.has(prop)) {
    return null
  }
  return prop as ProductSortField
}

async function loadOptions(): Promise<void> {
  if (!hasViewPermission.value) {
    return
  }
  optionsError.value = null
  try {
    const [cats, brands] = await Promise.all([
      fetchProductCategoryOptions(),
      fetchProductBrandOptions(),
    ])
    categoryOptions.value = cats
    brandOptions.value = brands
  } catch (error) {
    optionsError.value = getUserFriendlyErrorMessage(error)
  }
}

async function loadList(): Promise<void> {
  if (!hasViewPermission.value) {
    records.value = []
    total.value = 0
    listError.value = '暂无权限查看产品（product:view）'
    return
  }
  await runExclusive(loading, async () => {
    listError.value = null
    try {
      const data = await fetchProductPage({
        keyword: keyword.value.trim() || undefined,
        categoryId: categoryFilter.value ?? undefined,
        brandId: brandFilter.value ?? undefined,
        active:
          activeFilter.value === 'true'
            ? true
            : activeFilter.value === 'false'
              ? false
              : undefined,
        sortField: sortField.value,
        sortOrder: sortOrder.value,
        page: page.value,
        size: size.value,
      })
      records.value = data.records ?? []
      total.value = data.total ?? 0
      page.value = data.page || page.value
      size.value = data.size || size.value
      if (total.value > 0 && records.value.length === 0 && page.value > 1) {
        page.value -= 1
        await loadList()
      }
    } catch (error) {
      records.value = []
      total.value = 0
      listError.value = getUserFriendlyErrorMessage(error)
    }
  })
}

function handleSearch(): void {
  keyword.value = keywordInput.value.trim()
  page.value = 1
  void loadList()
}

function handleReset(): void {
  keywordInput.value = ''
  keyword.value = ''
  categoryFilter.value = null
  brandFilter.value = null
  activeFilter.value = ''
  sortField.value = 'id'
  sortOrder.value = 'asc'
  page.value = 1
  void loadList()
}

function handlePageChange(next: number): void {
  page.value = next
  void loadList()
}

function handleSizeChange(next: number): void {
  size.value = next
  page.value = 1
  void loadList()
}

async function handleSortChange(payload: {
  prop: string | null
  order: 'ascending' | 'descending' | null
}): Promise<void> {
  const mapped = mapSortField(payload.prop)
  if (mapped == null || payload.order == null) {
    sortField.value = 'id'
    sortOrder.value = 'asc'
  } else {
    sortField.value = mapped
    sortOrder.value = payload.order === 'ascending' ? 'asc' : 'desc'
  }
  page.value = 1
  await loadList()
}

function openCreate(): void {
  formMode.value = 'create'
  editingId.value = null
  form.name = ''
  form.alias = ''
  form.categoryId = null
  form.brandId = null
  form.specification = ''
  form.active = true
  form.price = ''
  form.allowSell = true
  form.allowLargess = false
  form.remark = ''
  formError.value = null
  formVisible.value = true
  void loadOptions()
}

async function openEdit(row: ProductItem): Promise<void> {
  formMode.value = 'edit'
  editingId.value = row.id
  form.name = row.name ?? ''
  form.alias = row.alias ?? ''
  form.categoryId = row.categoryId
  form.brandId = row.brandId
  form.specification = row.specification ?? ''
  form.active = row.active !== false
  form.price =
    row.price == null ? '' : typeof row.price === 'number' ? row.price.toFixed(2) : String(row.price)
  form.allowSell = row.allowSell !== false
  form.allowLargess = row.allowLargess === true
  form.remark = row.remark ?? ''
  formError.value = null
  formVisible.value = true
  formLoading.value = true
  void loadOptions()
  try {
    const detail = await fetchProductDetail(row.id)
    form.name = detail.name ?? ''
    form.alias = detail.alias ?? ''
    form.categoryId = detail.categoryId
    form.brandId = detail.brandId
    form.specification = detail.specification ?? ''
    form.active = detail.active !== false
    form.price =
      detail.price == null
        ? ''
        : typeof detail.price === 'number'
          ? detail.price.toFixed(2)
          : String(detail.price)
    form.allowSell = detail.allowSell !== false
    form.allowLargess = detail.allowLargess === true
    form.remark = detail.remark ?? ''
  } catch (error) {
    notifyError(error)
  } finally {
    formLoading.value = false
  }
}

function validateForm(): string | null {
  const name = form.name.trim()
  if (!name) {
    return '请填写产品名称'
  }
  if (form.categoryId == null) {
    return '请选择分类'
  }
  const price = normalizeAmountString(form.price)
  if (price == null) {
    return '请填写合法价格（非负，最多两位小数）'
  }
  return null
}

async function handleSubmit(): Promise<void> {
  const err = validateForm()
  if (err != null) {
    uiMessage.warning(err)
    return
  }
  const name = form.name.trim()
  const price = normalizeAmountString(form.price)
  const categoryId = form.categoryId
  if (price == null || categoryId == null) {
    return
  }
  await runExclusive(formSaving, async () => {
    formError.value = null
    try {
      if (formMode.value === 'create') {
        await createProduct({
          name,
          alias: form.alias.trim() || null,
          categoryId,
          brandId: form.brandId,
          specification: form.specification.trim() || null,
          active: form.active,
          price,
          allowSell: form.allowSell,
          allowLargess: form.allowLargess,
          remark: form.remark.trim() || null,
        })
        uiMessage.success('产品已创建')
      } else if (editingId.value != null) {
        // 不传 originalTextPresent/memoPresent，且不传 originalText/memo，
        // 后端按 null=保留原值，避免未在表单展示的历史字段被清空
        await updateProduct(editingId.value, {
          name,
          alias: form.alias.trim() || null,
          categoryId,
          brandId: form.brandId,
          specification: form.specification.trim() || null,
          active: form.active,
          price,
          allowSell: form.allowSell,
          allowLargess: form.allowLargess,
          remark: form.remark.trim() || null,
        })
        uiMessage.success('产品已更新')
      }
      formVisible.value = false
      await loadList()
    } catch (error) {
      formError.value = getUserFriendlyErrorMessage(error)
      notifyError(error)
    }
  })
}

async function handleDeactivate(row: ProductItem): Promise<void> {
  if (!hasEditPermission.value || row.active === false) {
    return
  }
  const ok = await uiConfirm({
    title: '停用产品',
    message: `确认停用产品「${row.name || row.id}」？停用后不会出现在商品 options 与可售目录（非物理删除）。`,
    confirmText: '停用',
  })
  if (!ok) {
    return
  }
  const id = row.id
  if (deactivatingIds.value.has(id)) {
    return
  }
  deactivatingIds.value = new Set(deactivatingIds.value).add(id)
  try {
    await deactivateProduct(id)
    uiMessage.success('产品已停用')
    await loadList()
  } catch (error) {
    notifyError(error)
  } finally {
    const next = new Set(deactivatingIds.value)
    next.delete(id)
    deactivatingIds.value = next
  }
}

function yesNo(value: boolean | null | undefined): string {
  if (value === true) {
    return '是'
  }
  if (value === false) {
    return '否'
  }
  return '—'
}

function rowOf(row: unknown): ProductItem {
  return row as ProductItem
}

watch(
  hasViewPermission,
  () => {
    void loadOptions()
    void loadList()
  },
  { immediate: true },
)
</script>

<template>
  <section class="product-manage">
    <header class="page-header">
      <div>
        <h1>产品管理</h1>
        <p class="subtitle">维护产品主数据（TE+TB）；无「允许消耗」字段</p>
      </div>
      <el-button
        v-permission="ProductPermission.EDIT"
        type="primary"
        @click="openCreate"
      >
        新增产品
      </el-button>
    </header>

    <form class="toolbar" @submit.prevent="handleSearch">
      <el-input
        v-model="keywordInput"
        clearable
        placeholder="产品名称/别名"
        style="max-width: 200px"
      />
      <el-select
        v-model="categoryFilter"
        clearable
        filterable
        placeholder="分类"
        style="width: 160px"
      >
        <el-option
          v-for="opt in categoryOptions"
          :key="opt.id"
          :label="opt.name || String(opt.id)"
          :value="opt.id"
        />
      </el-select>
      <el-select
        v-model="brandFilter"
        clearable
        filterable
        placeholder="品牌"
        style="width: 160px"
      >
        <el-option
          v-for="opt in brandOptions"
          :key="opt.id"
          :label="opt.name || String(opt.id)"
          :value="opt.id"
        />
      </el-select>
      <el-select v-model="activeFilter" clearable placeholder="状态" style="width: 120px">
        <el-option label="全部" value="" />
        <el-option label="启用" value="true" />
        <el-option label="停用" value="false" />
      </el-select>
      <el-button type="primary" native-type="submit" :loading="loading">查询</el-button>
      <el-button native-type="button" :disabled="loading" @click="handleReset">重置</el-button>
    </form>

    <AppError v-if="optionsError" :description="optionsError" @retry="loadOptions" />

    <div v-loading="loading" class="table-panel">
      <AppError
        v-if="listError && !loading"
        :description="listError"
        @retry="loadList"
      />
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
            label="产品名称"
            min-width="140"
            sortable="custom"
            show-overflow-tooltip
          >
            <template #default="{ row }">
              {{ rowOf(row).name || '—' }}
            </template>
          </el-table-column>
          <el-table-column label="分类" min-width="110" show-overflow-tooltip>
            <template #default="{ row }">
              {{ rowOf(row).categoryName || '—' }}
            </template>
          </el-table-column>
          <el-table-column label="品牌" min-width="100" show-overflow-tooltip>
            <template #default="{ row }">
              {{ rowOf(row).brandName || '—' }}
            </template>
          </el-table-column>
          <el-table-column label="规格" min-width="100" show-overflow-tooltip>
            <template #default="{ row }">
              {{ rowOf(row).specification || '—' }}
            </template>
          </el-table-column>
          <el-table-column
            prop="price"
            label="价格"
            min-width="100"
            align="right"
            sortable="custom"
          >
            <template #default="{ row }">
              {{ formatAmountDisplay(rowOf(row).price) }}
            </template>
          </el-table-column>
          <el-table-column label="是否允许销售" width="110" align="center">
            <template #default="{ row }">
              {{ yesNo(rowOf(row).allowSell) }}
            </template>
          </el-table-column>
          <el-table-column label="是否允许赠送" width="110" align="center">
            <template #default="{ row }">
              {{ yesNo(rowOf(row).allowLargess) }}
            </template>
          </el-table-column>
          <el-table-column prop="active" label="状态" width="90" sortable="custom">
            <template #default="{ row }">
              <el-tag
                :type="rowOf(row).active !== false ? 'success' : 'info'"
                size="small"
              >
                {{ rowOf(row).active !== false ? '启用' : '停用' }}
              </el-tag>
            </template>
          </el-table-column>
          <el-table-column label="操作" width="160" fixed="right">
            <template #default="{ row }">
              <el-button
                v-permission="ProductPermission.EDIT"
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
            </template>
          </el-table-column>
        </el-table>

        <AppEmpty
          v-if="!loading && !listError && records.length === 0"
          title="暂无产品"
          description="可点击「新增产品」创建主数据"
        />

        <div v-if="total > 0" class="pager">
          <el-pagination
            background
            layout="total, sizes, prev, pager, next"
            :total="total"
            :current-page="page"
            :page-size="size"
            :page-sizes="[10, 20, 50, 100]"
            @current-change="handlePageChange"
            @size-change="handleSizeChange"
          />
        </div>
      </template>
    </div>

    <el-dialog
      v-model="formVisible"
      :title="formMode === 'create' ? '新增产品' : '编辑产品'"
      width="560px"
      destroy-on-close
      :close-on-click-modal="false"
    >
      <div v-loading="formLoading">
        <AppError v-if="formError" :description="formError" />
        <el-form label-width="110px" @submit.prevent>
          <el-form-item label="产品名称" required>
            <el-input v-model="form.name" maxlength="100" show-word-limit />
          </el-form-item>
          <el-form-item label="别名">
            <el-input v-model="form.alias" maxlength="100" show-word-limit />
          </el-form-item>
          <el-form-item label="分类" required>
            <el-select
              v-model="form.categoryId"
              filterable
              placeholder="请选择分类"
              style="width: 100%"
            >
              <el-option
                v-for="opt in categoryOptions"
                :key="opt.id"
                :label="opt.name || String(opt.id)"
                :value="opt.id"
              />
            </el-select>
          </el-form-item>
          <el-form-item label="品牌">
            <el-select
              v-model="form.brandId"
              clearable
              filterable
              placeholder="可选"
              style="width: 100%"
            >
              <el-option
                v-for="opt in brandOptions"
                :key="opt.id"
                :label="opt.name || String(opt.id)"
                :value="opt.id"
              />
            </el-select>
          </el-form-item>
          <el-form-item label="规格">
            <el-input v-model="form.specification" maxlength="100" />
          </el-form-item>
          <el-form-item label="价格" required>
            <el-input v-model="form.price" placeholder="如 99.00" />
          </el-form-item>
          <el-form-item label="允许销售">
            <el-switch v-model="form.allowSell" />
          </el-form-item>
          <el-form-item label="允许赠送">
            <el-switch v-model="form.allowLargess" />
          </el-form-item>
          <el-form-item v-if="formMode === 'edit'" label="启用状态">
            <el-switch v-model="form.active" active-text="启用" inactive-text="停用" />
          </el-form-item>
          <el-form-item label="备注">
            <el-input v-model="form.remark" type="textarea" :rows="2" maxlength="200" />
          </el-form-item>
        </el-form>
      </div>
      <template #footer>
        <el-button :disabled="formSaving" @click="formVisible = false">取消</el-button>
        <el-button
          type="primary"
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
.product-manage {
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

.pager {
  display: flex;
  justify-content: flex-end;
  margin-top: 12px;
}
</style>
