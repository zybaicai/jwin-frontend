<script setup lang="ts">
import { computed, ref, watch } from 'vue'
import { useRoute, useRouter } from 'vue-router'

import AppEmpty from '@/components/common/AppEmpty.vue'
import AppError from '@/components/common/AppError.vue'
import SaleOrderDetailContent from '@/components/sale/SaleOrderDetailContent.vue'
import { fetchSaleOrderDetail } from '@/api/sale'
import { SalePermission, type SaleOrderDetail } from '@/types/sale'
import { usePermissionStore } from '@/stores/permission'
import { getUserFriendlyErrorMessage, runExclusive } from '@/utils/ui'

defineOptions({ name: 'SaleOrderDetailView' })

const route = useRoute()
const router = useRouter()
const permissionStore = usePermissionStore()

const hasViewPermission = computed(() =>
  permissionStore.hasPermission(SalePermission.ORDER_VIEW),
)

const loading = ref(false)
const loadError = ref<string | null>(null)
const detail = ref<SaleOrderDetail | null>(null)

const orderId = computed(() => {
  const raw = route.params.orderId
  return typeof raw === 'string' ? raw : Array.isArray(raw) ? raw[0] : ''
})

async function loadDetail(): Promise<void> {
  if (!hasViewPermission.value) {
    detail.value = null
    loadError.value = '无销售订单查看权限（sale:order:view）'
    return
  }
  if (!orderId.value) {
    detail.value = null
    loadError.value = '订单编号无效'
    return
  }
  await runExclusive(loading, async () => {
    loadError.value = null
    try {
      detail.value = await fetchSaleOrderDetail(orderId.value)
    } catch (error) {
      detail.value = null
      loadError.value = getUserFriendlyErrorMessage(error)
    }
  })
}

function goBackToList(): void {
  const q = { ...route.query }
  void router.push({ name: 'sale-orders', query: q })
}

watch(
  orderId,
  () => {
    void loadDetail()
  },
  { immediate: true },
)
</script>

<template>
  <div class="page">
    <div class="toolbar">
      <el-button @click="goBackToList">返回列表</el-button>
      <el-button :loading="loading" @click="loadDetail">刷新</el-button>
      <span class="title">销售订单详情</span>
      <el-tag v-if="detail?.billStatus" size="small">{{ detail.billStatus }}</el-tag>
    </div>

    <AppError
      v-if="loadError && !loading"
      :description="loadError"
      @retry="loadDetail"
    />
    <div v-else v-loading="loading" class="panel">
      <SaleOrderDetailContent v-if="detail" :detail="detail" />
      <AppEmpty v-else-if="!loading" title="暂无订单详情" />
    </div>
  </div>
</template>

<style scoped>
.page {
  display: flex;
  flex-direction: column;
  gap: 12px;
  padding: 12px 16px 24px;
  min-height: 100%;
}

.toolbar {
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
  align-items: center;
}

.title {
  margin-left: 4px;
  font-size: 16px;
  font-weight: 600;
  color: #303133;
}

.panel {
  background: #fff;
  border: 1px solid #ebeef5;
  border-radius: 4px;
  padding: 16px;
  min-height: 240px;
}
</style>
