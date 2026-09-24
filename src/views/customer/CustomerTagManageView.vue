<script setup lang="ts">
import { computed, reactive, ref, watch } from 'vue'

import AppEmpty from '@/components/common/AppEmpty.vue'
import AppError from '@/components/common/AppError.vue'
import {
  createCustomerTag,
  deleteCustomerTag,
  fetchCustomerTagDetail,
  fetchCustomerTagPage,
  updateCustomerTag,
} from '@/api/customer'
import { CustomerPermission, type CustomerTagItem } from '@/types/customer'
import { usePermissionStore } from '@/stores/permission'
import {
  getUserFriendlyErrorMessage,
  notifyError,
  runExclusive,
  uiConfirm,
  uiMessage,
} from '@/utils/ui'
import { formatDateTime } from '@/views/customer/customer-format'

defineOptions({ name: 'CustomerTagManageView' })

const permissionStore = usePermissionStore()

const hasViewPermission = computed(() =>
  permissionStore.hasPermission(CustomerPermission.TAG_VIEW),
)
const hasEditPermission = computed(() =>
  permissionStore.hasPermission(CustomerPermission.TAG_EDIT),
)

const loading = ref(false)
const listError = ref<string | null>(null)
const keywordInput = ref('')
const keyword = ref('')
const page = ref(1)
const size = ref(20)
const total = ref(0)
const records = ref<CustomerTagItem[]>([])

const formVisible = ref(false)
const formMode = ref<'create' | 'edit'>('create')
const formLoading = ref(false)
const formSaving = ref(false)
const formError = ref<string | null>(null)
const editingId = ref<number | null>(null)
const form = reactive({
  name: '',
})

async function loadList(): Promise<void> {
  if (!hasViewPermission.value) {
    records.value = []
    total.value = 0
    listError.value = '暂无权限查看客户标签（customer:tag:view）'
    return
  }
  await runExclusive(loading, async () => {
    listError.value = null
    try {
      const data = await fetchCustomerTagPage({
        keyword: keyword.value.trim() || undefined,
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

function openCreate(): void {
  formMode.value = 'create'
  editingId.value = null
  form.name = ''
  formError.value = null
  formVisible.value = true
}

async function openEdit(row: CustomerTagItem): Promise<void> {
  formMode.value = 'edit'
  editingId.value = row.id
  form.name = row.name ?? ''
  formError.value = null
  formVisible.value = true
  formLoading.value = true
  try {
    const detail = await fetchCustomerTagDetail(row.id)
    form.name = detail.name ?? ''
  } catch (error) {
    notifyError(error)
  } finally {
    formLoading.value = false
  }
}

async function handleSubmit(): Promise<void> {
  const name = form.name.trim()
  if (!name) {
    uiMessage.warning('请填写标签名称')
    return
  }
  if (name.length > 50) {
    uiMessage.warning('标签名称最多 50 个字符')
    return
  }
  await runExclusive(formSaving, async () => {
    formError.value = null
    try {
      if (formMode.value === 'create') {
        await createCustomerTag({ name })
        uiMessage.success('标签已创建')
      } else if (editingId.value != null) {
        await updateCustomerTag(editingId.value, { name })
        uiMessage.success('标签已更新')
      }
      formVisible.value = false
      await loadList()
    } catch (error) {
      formError.value = getUserFriendlyErrorMessage(error)
      notifyError(error)
    }
  })
}

async function handleDelete(row: CustomerTagItem): Promise<void> {
  const ok = await uiConfirm({
    title: '删除标签',
    message: `确认删除标签「${row.name || row.id}」？删除后将解除所有顾客与该标签的关系。`,
    confirmText: '删除',
  })
  if (!ok) {
    return
  }
  try {
    await deleteCustomerTag(row.id)
    uiMessage.success('标签已删除')
    await loadList()
  } catch (error) {
    notifyError(error)
  }
}

function rowOf(row: unknown): CustomerTagItem {
  return row as CustomerTagItem
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
  <section class="tag-manage">
    <header class="page-header">
      <div>
        <h1>客户标签管理</h1>
        <p class="subtitle">维护系统标签库；客户贴标在客户详情中操作</p>
      </div>
      <el-button
        v-permission="CustomerPermission.TAG_EDIT"
        type="primary"
        @click="openCreate"
      >
        新增标签
      </el-button>
    </header>

    <form class="toolbar" @submit.prevent="handleSearch">
      <el-input
        v-model="keywordInput"
        clearable
        placeholder="标签名称"
        style="max-width: 260px"
      />
      <el-button type="primary" native-type="submit" :loading="loading">查询</el-button>
      <el-button native-type="button" :disabled="loading" @click="handleReset">重置</el-button>
    </form>

    <div v-loading="loading" class="table-panel">
      <AppError
        v-if="listError && !loading"
        :description="listError"
        @retry="loadList"
      />
      <template v-else>
        <el-table :data="records" border stripe size="small" empty-text=" ">
          <el-table-column prop="name" label="标签名称" min-width="220" show-overflow-tooltip>
            <template #default="{ row }">
              {{ rowOf(row).name || '—' }}
            </template>
          </el-table-column>
          <el-table-column label="创建时间" min-width="180">
            <template #default="{ row }">
              {{ formatDateTime(rowOf(row).createdOn) }}
            </template>
          </el-table-column>
          <el-table-column label="操作" width="160" fixed="right">
            <template #default="{ row }">
              <el-button
                v-permission="CustomerPermission.TAG_EDIT"
                link
                type="primary"
                @click="openEdit(rowOf(row))"
              >
                编辑
              </el-button>
              <el-button
                v-permission="CustomerPermission.TAG_EDIT"
                link
                type="danger"
                @click="handleDelete(rowOf(row))"
              >
                删除
              </el-button>
            </template>
          </el-table-column>
        </el-table>

        <AppEmpty
          v-if="!loading && !listError && records.length === 0"
          title="暂无标签"
          description="可点击「新增标签」创建系统标签"
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
      :title="formMode === 'create' ? '新增标签' : '编辑标签'"
      width="420px"
      destroy-on-close
      :close-on-click-modal="false"
    >
      <div v-loading="formLoading">
        <AppError v-if="formError" :description="formError" />
        <el-form label-width="90px" @submit.prevent>
          <el-form-item label="标签名称" required>
            <el-input
              v-model="form.name"
              maxlength="50"
              show-word-limit
              placeholder="请输入标签名称"
            />
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
.tag-manage {
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
