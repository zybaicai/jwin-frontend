<script setup lang="ts">
import { computed, reactive, ref, watch } from 'vue'

import AppEmpty from '@/components/common/AppEmpty.vue'
import AppError from '@/components/common/AppError.vue'
import { fetchCustomerServiceLogs } from '@/api/customer'
import {
  CustomerPermission,
  type CustomerServiceLogItem,
} from '@/types/customer'
import { usePermissionStore } from '@/stores/permission'
import { getUserFriendlyErrorMessage, runExclusive } from '@/utils/ui'
import { formatDateTime } from '@/views/customer/customer-format'

defineOptions({ name: 'CustomerServiceLog' })

const props = defineProps<{
  customerId: number
}>()

interface ServiceLogPageState {
  page: number
  size: number
  total: number
  records: CustomerServiceLogItem[]
  loaded: boolean
  error: string | null
}

function createPageState(): ServiceLogPageState {
  return {
    page: 1,
    size: 20,
    total: 0,
    records: [],
    loaded: false,
    error: null,
  }
}

const permissionStore = usePermissionStore()
const serviceLogsLoading = ref(false)
const loadingMore = ref(false)
const serviceLogsState = reactive(createPageState())

const hasMore = computed(
  () => serviceLogsState.records.length < serviceLogsState.total,
)

const infiniteDisabled = computed(
  () =>
    !serviceLogsState.loaded ||
    serviceLogsLoading.value ||
    loadingMore.value ||
    !!serviceLogsState.error ||
    !hasMore.value,
)

function canLoadMore(): boolean {
  return (
    serviceLogsState.loaded &&
    !serviceLogsLoading.value &&
    !loadingMore.value &&
    hasMore.value
  )
}

function displayName(row: CustomerServiceLogItem): string {
  return row.nurseName?.trim() || '护理师'
}

function avatarText(row: CustomerServiceLogItem): string {
  const name = displayName(row)
  return name.slice(0, 1)
}

async function loadServiceLogs(options?: {
  force?: boolean
  append?: boolean
}): Promise<void> {
  const force = options?.force === true
  const append = options?.append === true

  if (!force && !append && serviceLogsState.loaded) {
    return
  }

  if (!permissionStore.hasPermission(CustomerPermission.LIST_VIEW)) {
    serviceLogsState.records = []
    serviceLogsState.total = 0
    serviceLogsState.loaded = true
    serviceLogsState.error = '暂无权限查看服务日志'
    return
  }

  const loadingFlag = append ? loadingMore : serviceLogsLoading
  await runExclusive(loadingFlag, async () => {
    if (!append) {
      serviceLogsState.error = null
    }
    const requestPage = append ? serviceLogsState.page : 1
    try {
      const data = await fetchCustomerServiceLogs(props.customerId, {
        page: requestPage,
        size: serviceLogsState.size,
      })
      const nextRecords = data.records ?? []
      serviceLogsState.records = append
        ? [...serviceLogsState.records, ...nextRecords]
        : nextRecords
      serviceLogsState.total = data.total ?? 0
      serviceLogsState.page = data.page || requestPage
      serviceLogsState.size = data.size || serviceLogsState.size
      serviceLogsState.loaded = true
      serviceLogsState.error = null
    } catch (error) {
      if (append) {
        serviceLogsState.page = Math.max(1, serviceLogsState.page - 1)
      } else {
        serviceLogsState.records = []
        serviceLogsState.total = 0
        serviceLogsState.loaded = false
      }
      serviceLogsState.error = getUserFriendlyErrorMessage(error)
    }
  })
}

async function loadMore(): Promise<void> {
  if (!canLoadMore()) {
    return
  }
  serviceLogsState.error = null
  serviceLogsState.page += 1
  await loadServiceLogs({ force: true, append: true })
}

async function reloadCurrent(): Promise<void> {
  serviceLogsState.page = 1
  await loadServiceLogs({ force: true, append: false })
}

watch(
  () => props.customerId,
  () => {
    Object.assign(serviceLogsState, createPageState())
    void loadServiceLogs({ force: true, append: false })
  },
  { immediate: true },
)

defineExpose({
  reloadCurrent,
})
</script>

<template>
  <div class="customer-service-log">
    <AppError
      v-if="serviceLogsState.error && !serviceLogsLoading && serviceLogsState.records.length === 0"
      :description="serviceLogsState.error"
      @retry="reloadCurrent"
    />

    <div
      v-else
      v-loading="serviceLogsLoading"
      class="service-log-scroller"
      v-infinite-scroll="loadMore"
      :infinite-scroll-disabled="infiniteDisabled"
      :infinite-scroll-distance="60"
      :infinite-scroll-immediate="false"
    >
      <AppEmpty
        v-if="!serviceLogsLoading && serviceLogsState.loaded && serviceLogsState.records.length === 0"
        title="暂无服务日志"
      />

      <article
        v-for="row in serviceLogsState.records"
        :key="row.id"
        class="service-log-card"
      >
        <header class="card-header">
          <div class="card-title-row">
            <span class="avatar" aria-hidden="true">{{ avatarText(row) }}</span>
            <div class="title-block">
              <div class="name-line">
                <span class="nurse-name">{{ displayName(row) }}</span>
                <time class="created-on">{{ formatDateTime(row.createdOn) }}</time>
              </div>
              <div class="meta-line">
                <span class="meta-item">护理师</span>
                <span v-if="row.nurseEmployeeId" class="meta-item">工号 {{ row.nurseEmployeeId }}</span>
                <span v-if="row.storeName" class="meta-item">{{ row.storeName }}</span>
              </div>
            </div>
          </div>
        </header>

        <div class="card-content">
          {{ row.content?.trim() || '—' }}
        </div>
      </article>

      <div v-if="loadingMore" class="feed-status">加载中…</div>
      <div
        v-else-if="serviceLogsState.records.length > 0 && !hasMore"
        class="feed-status"
      >
        已加载全部 {{ serviceLogsState.total }} 条
      </div>
      <div
        v-else-if="serviceLogsState.error && serviceLogsState.records.length > 0"
        class="feed-status feed-status--error"
      >
        {{ serviceLogsState.error }}
        <button type="button" class="retry-inline" @click="loadMore">重试</button>
      </div>
    </div>
  </div>
</template>

<style scoped>
.customer-service-log {
  min-height: 180px;
}

.service-log-scroller {
  max-height: min(520px, calc(100vh - 320px));
  overflow-y: auto;
  padding-right: 2px;
}

.service-log-card {
  margin-bottom: 12px;
  padding: 14px 16px 16px;
  background: #f5f7fa;
  border-radius: 8px;
  border: 1px solid #ebeef5;
}

.service-log-card:last-of-type {
  margin-bottom: 0;
}

.card-header {
  margin-bottom: 10px;
}

.card-title-row {
  display: flex;
  gap: 10px;
  align-items: flex-start;
}

.avatar {
  flex-shrink: 0;
  display: inline-flex;
  align-items: center;
  justify-content: center;
  width: 36px;
  height: 36px;
  border-radius: 50%;
  background: #e8a05a;
  color: #fff;
  font-size: 14px;
  font-weight: 600;
  line-height: 1;
}

.title-block {
  flex: 1;
  min-width: 0;
}

.name-line {
  display: flex;
  align-items: baseline;
  justify-content: space-between;
  gap: 12px;
}

.nurse-name {
  color: #303133;
  font-size: 15px;
  font-weight: 600;
  line-height: 1.4;
}

.created-on {
  flex-shrink: 0;
  color: #909399;
  font-size: 12px;
  line-height: 1.4;
}

.meta-line {
  display: flex;
  flex-wrap: wrap;
  align-items: center;
  margin-top: 4px;
  color: #909399;
  font-size: 12px;
  line-height: 1.4;
}

.meta-item:not(:last-child)::after {
  content: '·';
  margin: 0 8px;
  color: #c0c4cc;
}

.card-content {
  color: #303133;
  font-size: 14px;
  line-height: 1.7;
  white-space: pre-wrap;
  word-break: break-word;
}

.feed-status {
  padding: 12px 0 4px;
  color: #909399;
  font-size: 12px;
  text-align: center;
}

.feed-status--error {
  color: #f56c6c;
}

.retry-inline {
  margin-left: 8px;
  padding: 0;
  border: none;
  background: none;
  color: #409eff;
  font-size: 12px;
  cursor: pointer;
}

.retry-inline:hover {
  text-decoration: underline;
}
</style>
