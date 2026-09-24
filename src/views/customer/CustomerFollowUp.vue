<script setup lang="ts">
import { reactive, ref, watch } from 'vue'

import AppEmpty from '@/components/common/AppEmpty.vue'
import AppError from '@/components/common/AppError.vue'
import { fetchCustomerFollowUps } from '@/api/customer'
import type { CustomerFollowUpItem } from '@/types/customer'
import { getUserFriendlyErrorMessage, runExclusive } from '@/utils/ui'
import { formatDateTime } from '@/views/customer/customer-format'

defineOptions({ name: 'CustomerFollowUp' })

const props = defineProps<{
  customerId: number
}>()

interface FollowUpPageState {
  page: number
  size: number
  total: number
  records: CustomerFollowUpItem[]
  loaded: boolean
  error: string | null
}

function createPageState(): FollowUpPageState {
  return {
    page: 1,
    size: 20,
    total: 0,
    records: [],
    loaded: false,
    error: null,
  }
}

const followUpsLoading = ref(false)
const followUpsState = reactive(createPageState())

async function loadFollowUps(force = false): Promise<void> {
  if (!force && followUpsState.loaded) {
    return
  }
  await runExclusive(followUpsLoading, async () => {
    followUpsState.error = null
    try {
      const data = await fetchCustomerFollowUps(props.customerId, {
        page: followUpsState.page,
        size: followUpsState.size,
      })
      followUpsState.records = data.records ?? []
      followUpsState.total = data.total ?? 0
      followUpsState.page = data.page || followUpsState.page
      followUpsState.size = data.size || followUpsState.size
      followUpsState.loaded = true
    } catch (error) {
      followUpsState.records = []
      followUpsState.total = 0
      followUpsState.loaded = false
      followUpsState.error = getUserFriendlyErrorMessage(error)
    }
  })
}

async function handlePageChange(nextPage: number): Promise<void> {
  followUpsState.page = nextPage
  followUpsState.loaded = false
  await loadFollowUps(true)
}

async function handleSizeChange(size: number): Promise<void> {
  followUpsState.size = size
  followUpsState.page = 1
  followUpsState.loaded = false
  await loadFollowUps(true)
}

async function reloadCurrent(): Promise<void> {
  await loadFollowUps(true)
}

function isFollowUpText(value: boolean | null | undefined): string {
  if (value === true) {
    return '是'
  }
  if (value === false) {
    return '否'
  }
  return '—'
}

watch(
  () => props.customerId,
  () => {
    Object.assign(followUpsState, createPageState())
    void loadFollowUps(true)
  },
  { immediate: true },
)

defineExpose({
  reloadCurrent,
})
</script>

<template>
  <div class="customer-follow-up" v-loading="followUpsLoading">
    <AppError
      v-if="followUpsState.error && !followUpsLoading"
      :description="followUpsState.error"
      @retry="reloadCurrent"
    />
    <template v-else>
      <el-table :data="followUpsState.records" border stripe size="small" empty-text=" ">
        <el-table-column label="跟进时间" min-width="160">
          <template #default="{ row }">
            {{ formatDateTime(row.followUpOn) }}
          </template>
        </el-table-column>
        <el-table-column prop="followUpMethodName" label="跟进方式" min-width="100">
          <template #default="{ row }">
            {{ row.followUpMethodName || '—' }}
          </template>
        </el-table-column>
        <el-table-column prop="followUpStatusName" label="跟进状态" min-width="100">
          <template #default="{ row }">
            {{ row.followUpStatusName || '—' }}
          </template>
        </el-table-column>
        <el-table-column prop="followUpByName" label="跟进人" min-width="100" show-overflow-tooltip>
          <template #default="{ row }">
            {{ row.followUpByName || '—' }}
          </template>
        </el-table-column>
        <el-table-column prop="followUpContent" label="跟进内容" min-width="200" show-overflow-tooltip>
          <template #default="{ row }">
            {{ row.followUpContent || '—' }}
          </template>
        </el-table-column>
        <el-table-column label="计划时间" min-width="160">
          <template #default="{ row }">
            {{ formatDateTime(row.plannedOn) }}
          </template>
        </el-table-column>
        <el-table-column label="是否已跟进" min-width="100" align="center">
          <template #default="{ row }">
            {{ isFollowUpText(row.isFollowUp) }}
          </template>
        </el-table-column>
        <el-table-column label="创建时间" min-width="160">
          <template #default="{ row }">
            {{ formatDateTime(row.createdOn) }}
          </template>
        </el-table-column>
      </el-table>

      <AppEmpty
        v-if="!followUpsLoading && !followUpsState.error && followUpsState.loaded && followUpsState.records.length === 0"
        title="暂无跟进记录"
      />

      <div v-if="followUpsState.total > 0" class="pager">
        <el-pagination
          background
          layout="total, sizes, prev, pager, next"
          :total="followUpsState.total"
          :current-page="followUpsState.page"
          :page-size="followUpsState.size"
          :page-sizes="[10, 20, 50, 100]"
          @current-change="handlePageChange"
          @size-change="handleSizeChange"
        />
      </div>
    </template>
  </div>
</template>

<style scoped>
.customer-follow-up {
  min-height: 180px;
}

.pager {
  display: flex;
  justify-content: flex-end;
  margin-top: 12px;
}
</style>
