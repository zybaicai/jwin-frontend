<script setup lang="ts">
import { onBeforeUnmount, reactive, ref, watch } from 'vue'

import AppEmpty from '@/components/common/AppEmpty.vue'
import AppError from '@/components/common/AppError.vue'
import { fetchCustomerPage } from '@/api/customer'
import {
  CustomerPermission,
  type CustomerListItem,
} from '@/types/customer'
import { usePermissionStore } from '@/stores/permission'
import { getUserFriendlyErrorMessage, runExclusive } from '@/utils/ui'
import { formatMemberStatus } from '@/views/customer/customer-format'

defineOptions({ name: 'SaleCustomerSelector' })

const visible = defineModel<boolean>({ default: false })

const emit = defineEmits<{
  select: [customer: CustomerListItem]
}>()

const permissionStore = usePermissionStore()

const loading = ref(false)
const error = ref<string | null>(null)
const keyword = ref('')
const page = ref(1)
const size = ref(10)
const total = ref(0)
const records = ref<CustomerListItem[]>([])

const searchForm = reactive({
  keyword: '',
})

let searchTimer: ReturnType<typeof setTimeout> | null = null

function clearSearchTimer(): void {
  if (searchTimer != null) {
    clearTimeout(searchTimer)
    searchTimer = null
  }
}

function resetState(): void {
  clearSearchTimer()
  keyword.value = ''
  searchForm.keyword = ''
  page.value = 1
  size.value = 10
  total.value = 0
  records.value = []
  error.value = null
}

async function loadList(): Promise<void> {
  if (!permissionStore.hasPermission(CustomerPermission.LIST_VIEW)) {
    records.value = []
    total.value = 0
    error.value = '暂无权限查看客户列表（customer:list:view）'
    return
  }

  await runExclusive(loading, async () => {
    error.value = null
    try {
      const data = await fetchCustomerPage({
        keyword: keyword.value.trim() || undefined,
        page: page.value,
        size: size.value,
      })
      records.value = data.records ?? []
      total.value = data.total ?? 0
      page.value = data.page || page.value
      size.value = data.size || size.value
    } catch (err) {
      records.value = []
      total.value = 0
      error.value = getUserFriendlyErrorMessage(err)
    }
  })
}

function handleSearch(): void {
  clearSearchTimer()
  keyword.value = searchForm.keyword.trim()
  page.value = 1
  void loadList()
}

function onKeywordInput(): void {
  clearSearchTimer()
  searchTimer = setTimeout(() => {
    keyword.value = searchForm.keyword.trim()
    page.value = 1
    void loadList()
  }, 300)
}

function handlePageChange(nextPage: number): void {
  page.value = nextPage
  void loadList()
}

function handleSizeChange(nextSize: number): void {
  size.value = nextSize
  page.value = 1
  void loadList()
}

function handleSelect(row: CustomerListItem): void {
  emit('select', row)
  visible.value = false
}

function rowOf(row: unknown): CustomerListItem {
  return row as CustomerListItem
}

function handleClose(): void {
  visible.value = false
}

watch(visible, (open) => {
  if (!open) {
    resetState()
    return
  }
  resetState()
  void loadList()
})

onBeforeUnmount(() => clearSearchTimer())
</script>

<template>
  <el-dialog
    v-model="visible"
    title="选择客户"
    width="820px"
    append-to-body
    destroy-on-close
    :close-on-click-modal="false"
    @closed="resetState"
  >
    <form class="search-bar" @submit.prevent="handleSearch">
      <el-input
        v-model="searchForm.keyword"
        clearable
        placeholder="姓名 / 手机号 / 客户编号，自动搜索"
        style="max-width: 320px"
        @input="onKeywordInput"
        @clear="handleSearch"
      />
      <el-button type="primary" native-type="submit" :loading="loading">搜索</el-button>
    </form>

    <div v-loading="loading" class="table-wrap">
      <AppError
        v-if="error && !loading"
        :description="error"
        @retry="loadList"
      />
      <template v-else>
        <el-table :data="records" border stripe size="small" empty-text=" ">
          <el-table-column prop="name" label="客户姓名" min-width="110" show-overflow-tooltip>
            <template #default="{ row }">
              {{ row.name?.trim() || '—' }}
            </template>
          </el-table-column>
          <el-table-column prop="code" label="客户编号" min-width="110" show-overflow-tooltip>
            <template #default="{ row }">
              {{ row.code || '—' }}
            </template>
          </el-table-column>
          <el-table-column prop="mobile" label="手机号" min-width="120" show-overflow-tooltip>
            <template #default="{ row }">
              {{ row.mobile || '—' }}
            </template>
          </el-table-column>
          <el-table-column prop="levelName" label="会员等级" min-width="100" show-overflow-tooltip>
            <template #default="{ row }">
              {{ row.levelName || '—' }}
            </template>
          </el-table-column>
          <el-table-column prop="nurseName" label="主护理师" min-width="100" show-overflow-tooltip>
            <template #default="{ row }">
              {{ row.nurseName || '—' }}
            </template>
          </el-table-column>
          <el-table-column prop="storeName" label="所属门店" min-width="120" show-overflow-tooltip>
            <template #default="{ row }">
              {{ row.storeName || '—' }}
            </template>
          </el-table-column>
          <el-table-column label="会员状态" min-width="90">
            <template #default="{ row }">
              {{ formatMemberStatus(row.member) }}
            </template>
          </el-table-column>
          <el-table-column label="操作" width="90" fixed="right">
            <template #default="{ row }">
              <el-button link type="primary" @click="handleSelect(rowOf(row))">选择</el-button>
            </template>
          </el-table-column>
        </el-table>

        <AppEmpty
          v-if="!loading && !error && records.length === 0"
          title="暂无符合条件的客户"
        />

        <div v-if="total > 0" class="pager">
          <el-pagination
            background
            layout="total, sizes, prev, pager, next"
            :total="total"
            :current-page="page"
            :page-size="size"
            :page-sizes="[10, 20, 50]"
            @current-change="handlePageChange"
            @size-change="handleSizeChange"
          />
        </div>
      </template>
    </div>

    <template #footer>
      <el-button @click="handleClose">取消</el-button>
    </template>
  </el-dialog>
</template>

<style scoped>
.search-bar {
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
  margin-bottom: 12px;
}

.table-wrap {
  min-height: 220px;
}

.pager {
  display: flex;
  justify-content: flex-end;
  margin-top: 12px;
}
</style>
