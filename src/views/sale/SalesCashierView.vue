<script setup lang="ts">
import { computed, ref, watch } from 'vue'
import { useRoute, useRouter } from 'vue-router'

import AppEmpty from '@/components/common/AppEmpty.vue'
import AppError from '@/components/common/AppError.vue'
import SaleCustomerSelector from '@/components/sale/SaleCustomerSelector.vue'
import { fetchCustomerDetail } from '@/api/customer'
import type { CustomerDetail, CustomerListItem } from '@/types/customer'
import { SalePermission } from '@/types/sale'
import { usePermissionStore } from '@/stores/permission'
import { getUserFriendlyErrorMessage, runExclusive } from '@/utils/ui'

defineOptions({ name: 'SalesCashierView' })

type CustomerContextStatus =
  | 'none'
  | 'invalid'
  | 'loading'
  | 'ready'
  | 'error'

const route = useRoute()
const router = useRouter()
const permissionStore = usePermissionStore()

const customerLoading = ref(false)
const customerError = ref<string | null>(null)
const customer = ref<CustomerDetail | null>(null)
const selectorVisible = ref(false)

const hasCreatePermission = computed(() =>
  permissionStore.hasPermission(SalePermission.ORDER_CREATE),
)

/**
 * 从 query.customerId 解析正整数；缺省返回 null；非法返回 'invalid'。
 */
function parseCustomerIdQuery(raw: unknown): number | null | 'invalid' {
  if (raw == null || raw === '') {
    return null
  }
  const text = Array.isArray(raw) ? String(raw[0] ?? '') : String(raw)
  const trimmed = text.trim()
  if (trimmed === '') {
    return null
  }
  if (!/^\d+$/.test(trimmed)) {
    return 'invalid'
  }
  const id = Number(trimmed)
  if (!Number.isSafeInteger(id) || id <= 0) {
    return 'invalid'
  }
  return id
}

const resolvedCustomerId = computed(() => parseCustomerIdQuery(route.query.customerId))

const contextStatus = computed<CustomerContextStatus>(() => {
  if (resolvedCustomerId.value === 'invalid') {
    return 'invalid'
  }
  if (resolvedCustomerId.value == null) {
    return 'none'
  }
  if (customerLoading.value) {
    return 'loading'
  }
  if (customerError.value) {
    return 'error'
  }
  if (customer.value != null) {
    return 'ready'
  }
  return 'loading'
})

async function loadCustomer(customerId: number): Promise<void> {
  await runExclusive(customerLoading, async () => {
    customerError.value = null
    customer.value = null
    try {
      customer.value = await fetchCustomerDetail(customerId)
    } catch (error) {
      customer.value = null
      customerError.value = getUserFriendlyErrorMessage(error)
    }
  })
}

function syncCustomerContext(): void {
  const parsed = resolvedCustomerId.value
  if (parsed === 'invalid') {
    customer.value = null
    customerError.value = null
    return
  }
  if (parsed == null) {
    customer.value = null
    customerError.value = null
    return
  }
  // 已与当前客户一致时不重复请求（选择后 URL 变化会触发 watch）
  if (customer.value?.id === parsed && !customerError.value) {
    return
  }
  void loadCustomer(parsed)
}

function openCustomerSelector(): void {
  selectorVisible.value = true
}

function applySelectedCustomer(item: CustomerListItem): void {
  const nextId = item.id
  const current = resolvedCustomerId.value
  // 先清空摘要，避免新旧客户字段短暂混合
  customer.value = null
  customerError.value = null
  if (current === nextId) {
    void loadCustomer(nextId)
    return
  }
  void router.replace({
    path: '/sales/cashier',
    query: { customerId: String(nextId) },
  })
}

function retryLoadCustomer(): void {
  const parsed = resolvedCustomerId.value
  if (typeof parsed === 'number') {
    void loadCustomer(parsed)
  }
}

watch(
  () => route.query.customerId,
  () => {
    syncCustomerContext()
  },
  { immediate: true },
)
</script>

<template>
  <section class="cashier" v-loading="contextStatus === 'loading'">
    <header class="cashier-header">
      <div class="title-block">
        <h1>销售 / 开单</h1>
        <p class="subtitle">销售工作台基础页，完整收银业务后续专项接入</p>
      </div>

      <div class="customer-context">
        <template v-if="!hasCreatePermission">
          <AppError description="暂无销售开单权限（sale:order:create）" />
        </template>
        <template v-else-if="contextStatus === 'none'">
          <div class="customer-card is-empty">
            <span class="label">客户</span>
            <strong>未选择客户</strong>
            <el-button type="primary" @click="openCustomerSelector">选择客户</el-button>
          </div>
        </template>
        <template v-else-if="contextStatus === 'invalid'">
          <div class="customer-card is-empty">
            <div class="customer-main">
              <span class="label">客户</span>
              <strong>客户参数无效，请检查地址中的 customerId</strong>
            </div>
            <el-button type="primary" @click="openCustomerSelector">选择客户</el-button>
          </div>
        </template>
        <template v-else-if="contextStatus === 'error'">
          <div class="customer-card is-error">
            <AppError :description="customerError || '客户加载失败'" @retry="retryLoadCustomer" />
            <el-button @click="openCustomerSelector">更换客户</el-button>
          </div>
        </template>
        <template v-else-if="contextStatus === 'ready' && customer">
          <div class="customer-card">
            <div class="customer-main">
              <span class="label">客户</span>
              <strong class="name">{{ customer.name?.trim() || '未命名客户' }}</strong>
              <span class="meta">编号 {{ customer.code || '—' }}</span>
              <span class="meta">手机 {{ customer.mobile || '—' }}</span>
              <span class="meta">门店 {{ customer.storeName || '—' }}</span>
              <span class="meta">ID {{ customer.id }}</span>
            </div>
            <el-button @click="openCustomerSelector">更换客户</el-button>
          </div>
        </template>
      </div>
    </header>

    <div class="cashier-body">
      <section class="panel catalog-panel">
        <h2>商品 / 项目</h2>
        <AppEmpty title="本区域待销售专项接入" description="项目选择、卡项、价格体系将在后续阶段实现" />
      </section>
      <section class="panel order-panel">
        <h2>当前订单</h2>
        <AppEmpty title="本区域待销售专项接入" description="订单行、金额、经手人将在后续阶段实现" />
      </section>
    </div>

    <section class="panel footer-panel">
      <h2>后续销售业务</h2>
      <p class="hint">支付、欠款、渠道、提成等能力将在销售专项中接入真实 API，本阶段仅保留骨架。</p>
    </section>

    <SaleCustomerSelector v-model="selectorVisible" @select="applySelectedCustomer" />
  </section>
</template>

<style scoped>
.cashier {
  display: flex;
  flex-direction: column;
  gap: 16px;
  min-height: 100%;
  padding: 20px 24px 24px;
}

.cashier-header {
  display: flex;
  flex-wrap: wrap;
  gap: 16px;
  align-items: flex-start;
  justify-content: space-between;
}

.title-block h1 {
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

.customer-context {
  min-width: min(100%, 520px);
  flex: 1;
  max-width: 720px;
}

.customer-card {
  display: flex;
  flex-wrap: wrap;
  gap: 12px;
  align-items: center;
  justify-content: space-between;
  padding: 12px 16px;
  border: 1px solid #ebeef5;
  border-radius: 8px;
  background: #fff;
}

.customer-card.is-empty strong {
  color: #909399;
  font-weight: 500;
}

.customer-card.is-error {
  align-items: stretch;
}

.customer-card.is-error :deep(.app-error) {
  flex: 1;
  padding: 0;
  text-align: left;
}

.customer-main {
  display: flex;
  flex-wrap: wrap;
  gap: 8px 14px;
  align-items: baseline;
}

.label {
  color: #909399;
  font-size: 13px;
}

.name {
  font-size: 16px;
  color: #303133;
}

.meta {
  font-size: 13px;
  color: #606266;
}

.cashier-body {
  display: grid;
  grid-template-columns: minmax(0, 1.2fr) minmax(0, 1fr);
  gap: 16px;
  min-height: 320px;
}

.panel {
  padding: 16px;
  border: 1px solid #ebeef5;
  border-radius: 8px;
  background: #fff;
}

.panel h2 {
  margin: 0 0 12px;
  font-size: 15px;
  font-weight: 600;
  color: #303133;
}

.footer-panel .hint {
  margin: 0;
  font-size: 13px;
  line-height: 1.6;
  color: #909399;
}

@media (max-width: 960px) {
  .cashier-body {
    grid-template-columns: 1fr;
  }
}
</style>
