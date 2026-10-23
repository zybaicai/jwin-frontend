<script setup lang="ts">
import { computed, onMounted, reactive, ref, watch } from 'vue'
import { useRoute } from 'vue-router'
import { ElMessage, ElMessageBox } from 'element-plus'

import AppEmpty from '@/components/common/AppEmpty.vue'
import AppError from '@/components/common/AppError.vue'
import RefundCreateTypeDialog from '@/components/refund/RefundCreateTypeDialog.vue'
import SaleRefundApplyDialog from '@/components/refund/SaleRefundApplyDialog.vue'
import TreatRefundApplyDialog from '@/components/refund/TreatRefundApplyDialog.vue'
import {
  approveRefundBill,
  fetchRefundBillDetail,
  fetchRefundBillPage,
  rejectRefundBill,
} from '@/api/refund'
import type { RefundBill } from '@/types/refund'
import {
  REFUND_STATUS_OPTIONS,
  REFUND_TYPE_OPTIONS,
  RefundPermission,
} from '@/types/refund'
import { usePermissionStore } from '@/stores/permission'
import { useStoreStore } from '@/stores/store'
import { getUserFriendlyErrorMessage, runExclusive } from '@/utils/ui'
import {
  formatDateTime,
  formatMoney,
  maskMobile,
} from '@/views/customer/customer-format'

defineOptions({ name: 'RefundBillListView' })

const route = useRoute()
const permissionStore = usePermissionStore()
const storeStore = useStoreStore()

/** list=全部；pending=待审批；done=已完成(已执行) */
const pageMode = computed(() => {
  const m = route.meta.mode
  if (m === 'pending' || m === 'done') {
    return m
  }
  return 'list'
})

const isPendingMode = computed(() => pageMode.value === 'pending')
const isDoneMode = computed(() => pageMode.value === 'done')
/** 列表页才允许改状态；待审/已完成由路由锁定 */
const statusFilterLocked = computed(() => isPendingMode.value || isDoneMode.value)

const loading = ref(false)
const error = ref<string | null>(null)
const records = ref<RefundBill[]>([])
const total = ref(0)
const moreFiltersOpen = ref(false)

const query = reactive({
  status: '' as string,
  refundType: '' as string,
  refundId: '',
  sourceOrderId: '',
  keyword: '',
  dateRange: null as [string, string] | null,
  page: 1,
  size: 20,
})

const hasActiveFilters = computed(() => {
  return (
    !!query.keyword.trim() ||
    !!query.refundType ||
    (!statusFilterLocked.value && !!query.status) ||
    !!query.refundId.trim() ||
    !!query.sourceOrderId.trim() ||
    query.dateRange != null
  )
})

const hasActiveMoreFilters = computed(() => {
  return (
    !!query.refundId.trim() ||
    !!query.sourceOrderId.trim() ||
    query.dateRange != null
  )
})

const emptyTitle = computed(() => {
  if (hasActiveFilters.value) {
    if (isPendingMode.value) {
      return '暂无符合条件的待审批退款单'
    }
    if (isDoneMode.value) {
      return '暂无符合条件的已完成退款单'
    }
    return '暂无符合条件的退款单'
  }
  if (isPendingMode.value) {
    return '暂无待审批退款单'
  }
  if (isDoneMode.value) {
    return '暂无已完成退款单'
  }
  return '暂无退款单'
})

const currentStoreLabel = computed(() => {
  const name = storeStore.currentStoreName
  const id = storeStore.currentStoreId
  if (name && id != null) {
    return `${name}（ID ${id}）`
  }
  if (id != null) {
    return `门店 ID ${id}`
  }
  return '当前登录门店'
})

function resetQueryForMode(): void {
  query.refundType = ''
  query.refundId = ''
  query.sourceOrderId = ''
  query.keyword = ''
  query.dateRange = null
  query.page = 1
  query.size = 20
  moreFiltersOpen.value = false
  if (isPendingMode.value) {
    query.status = '0'
  } else if (isDoneMode.value) {
    query.status = '2'
  } else {
    query.status = ''
  }
}

const detailVisible = ref(false)
const detailLoading = ref(false)
const current = ref<RefundBill | null>(null)
const decideRemark = ref('')

const createTypeVisible = ref(false)
const saleApplyVisible = ref(false)
const treatApplyVisible = ref(false)

const canCreate = computed(() =>
  permissionStore.hasPermission(RefundPermission.ORDER_CREATE),
)
const canApprove = computed(() =>
  permissionStore.hasPermission(RefundPermission.ORDER_APPROVE),
)
/** 申请列表页展示新增入口；审批/已完成页不展示 */
const showCreateEntry = computed(() => pageMode.value === 'list' && canCreate.value)

function openCreateRefund(): void {
  createTypeVisible.value = true
}

function onCreateTypeSelect(type: 'SALE' | 'TREAT'): void {
  if (type === 'SALE') {
    saleApplyVisible.value = true
  } else {
    treatApplyVisible.value = true
  }
}

function onCreateSuccess(): void {
  void loadList()
}

const showApproveActions = computed(
  () =>
    canApprove.value &&
    current.value?.approvalStatus === '0' &&
    (isPendingMode.value || pageMode.value === 'list'),
)

/** YYYY-MM-DD → 当日起止 ISO（与销售订单日期筛选口径一致） */
function toIsoStart(day: string): string {
  return `${day}T00:00:00.000`
}

function toIsoEnd(day: string): string {
  return `${day}T23:59:59.999`
}

async function loadList(): Promise<void> {
  await runExclusive(loading, async () => {
    error.value = null
    try {
      const data = await fetchRefundBillPage({
        status: query.status || undefined,
        refundType: query.refundType || undefined,
        refundId: query.refundId.trim() || undefined,
        sourceOrderId: query.sourceOrderId.trim() || undefined,
        keyword: query.keyword.trim() || undefined,
        createdFrom: query.dateRange?.[0] ? toIsoStart(query.dateRange[0]) : undefined,
        createdTo: query.dateRange?.[1] ? toIsoEnd(query.dateRange[1]) : undefined,
        page: query.page,
        size: query.size,
      })
      records.value = data.records ?? []
      total.value = data.total ?? 0
    } catch (e) {
      records.value = []
      total.value = 0
      error.value = getUserFriendlyErrorMessage(e)
    }
  })
}

async function openDetail(row: RefundBill): Promise<void> {
  detailVisible.value = true
  decideRemark.value = ''
  await runExclusive(detailLoading, async () => {
    try {
      current.value = await fetchRefundBillDetail(row.id)
    } catch (e) {
      ElMessage.error(getUserFriendlyErrorMessage(e))
      detailVisible.value = false
    }
  })
}

async function handleApprove(): Promise<void> {
  if (current.value == null) {
    return
  }
  try {
    await ElMessageBox.confirm(
      current.value.refundType === 'TREAT'
        ? '确认通过该消耗退款？通过后将同事务自动恢复权益（不处理库存、不冲业绩）。'
        : '确认通过该退款申请？销售退款将在同事务自动执行权益减量与退款渠道记录（不接第三方支付）。',
      '审批通过',
      { type: 'warning' },
    )
  } catch {
    return
  }
  try {
    current.value = await approveRefundBill(current.value.id, {
      remark: decideRemark.value.trim() || undefined,
    })
    ElMessage.success('已通过并自动执行')
    await loadList()
  } catch (e) {
    ElMessage.error(getUserFriendlyErrorMessage(e))
  }
}

async function handleReject(): Promise<void> {
  if (current.value == null) {
    return
  }
  try {
    await ElMessageBox.confirm('确认拒绝该退款申请？', '审批拒绝', { type: 'warning' })
  } catch {
    return
  }
  try {
    current.value = await rejectRefundBill(current.value.id, {
      remark: decideRemark.value.trim() || undefined,
    })
    ElMessage.success('已拒绝')
    await loadList()
  } catch (e) {
    ElMessage.error(getUserFriendlyErrorMessage(e))
  }
}

function statusLabel(code: string | null | undefined): string {
  const hit = REFUND_STATUS_OPTIONS.find((x) => x.value === code)
  return hit?.label ?? code ?? '—'
}

function typeLabel(code: string | null | undefined): string {
  const hit = REFUND_TYPE_OPTIONS.find((x) => x.value === code)
  return hit?.label ?? code ?? '—'
}

function customerLabel(row: RefundBill): string {
  const name = row.customerName?.trim() || `客户#${row.customerId ?? '—'}`
  const code = row.customerCode?.trim()
  const mobile = row.customerMobile?.trim()
  const parts = [name]
  if (code) {
    parts.push(`(${code})`)
  }
  if (mobile) {
    parts.push(maskMobile(mobile))
  }
  return parts.join(' ')
}

function onSearch(): void {
  query.page = 1
  void loadList()
}

function onReset(): void {
  resetQueryForMode()
  void loadList()
}

function toggleMoreFilters(): void {
  moreFiltersOpen.value = !moreFiltersOpen.value
}

watch(
  () => pageMode.value,
  () => {
    resetQueryForMode()
    void loadList()
  },
)

onMounted(() => {
  resetQueryForMode()
  void loadList()
})
</script>

<template>
  <div class="page">
    <div class="filter-bar">
      <el-form :inline="true" class="filter-form" @submit.prevent="onSearch">
        <el-form-item label="客户信息">
          <el-input
            v-model="query.keyword"
            clearable
            placeholder="姓名 / 编号 / 手机号"
            style="width: 200px"
            @keyup.enter="onSearch"
          />
        </el-form-item>
        <el-form-item label="类型">
          <el-select
            v-model="query.refundType"
            clearable
            placeholder="全部"
            style="width: 140px"
          >
            <el-option
              v-for="opt in REFUND_TYPE_OPTIONS"
              :key="opt.value"
              :label="opt.label"
              :value="opt.value"
            />
          </el-select>
        </el-form-item>
        <el-form-item v-if="!statusFilterLocked" label="状态">
          <el-select
            v-model="query.status"
            clearable
            placeholder="全部"
            style="width: 140px"
          >
            <el-option
              v-for="opt in REFUND_STATUS_OPTIONS"
              :key="opt.value"
              :label="opt.label"
              :value="opt.value"
            />
          </el-select>
        </el-form-item>
        <el-form-item>
          <el-button type="primary" :loading="loading" @click="onSearch">查询</el-button>
          <el-button :disabled="loading" @click="onReset">重置</el-button>
          <el-button link type="primary" @click="toggleMoreFilters">
            {{ moreFiltersOpen ? '收起筛选' : '更多筛选' }}
            <span v-if="!moreFiltersOpen && hasActiveMoreFilters" class="more-dot" />
          </el-button>
          <el-button
            v-if="showCreateEntry"
            type="primary"
            plain
            :disabled="loading"
            @click="openCreateRefund"
          >
            新增退款
          </el-button>
        </el-form-item>
      </el-form>

      <el-form
        v-show="moreFiltersOpen"
        :inline="true"
        class="filter-form more-filters"
        @submit.prevent="onSearch"
      >
        <el-form-item label="退款编号">
          <el-input
            v-model="query.refundId"
            clearable
            placeholder="退款单号关键字"
            style="width: 180px"
            @keyup.enter="onSearch"
          />
        </el-form-item>
        <el-form-item label="原订单号">
          <el-input
            v-model="query.sourceOrderId"
            clearable
            placeholder="原销售/消耗单号"
            style="width: 180px"
            @keyup.enter="onSearch"
          />
        </el-form-item>
        <el-form-item label="申请时间">
          <el-date-picker
            v-model="query.dateRange"
            type="daterange"
            value-format="YYYY-MM-DD"
            start-placeholder="开始"
            end-placeholder="结束"
            unlink-panels
          />
        </el-form-item>
      </el-form>

      <div class="store-hint">
        数据范围：{{ currentStoreLabel }}（由登录门店限定，不可跨店查询）。可从本页「新增退款」发起，也可从销售/消耗订单详情发起。
      </div>
    </div>

    <div v-loading="loading" class="table-wrap">
      <AppError v-if="error && !loading" :description="error" @retry="loadList" />
      <template v-else>
        <el-table :data="records" border stripe empty-text=" ">
          <el-table-column prop="id" label="退款编号" min-width="150" show-overflow-tooltip />
          <el-table-column label="类型" min-width="100">
            <template #default="{ row }">
              {{ typeLabel(row.refundType) }}
            </template>
          </el-table-column>
          <el-table-column
            prop="sourceOrderId"
            label="原订单号"
            min-width="150"
            show-overflow-tooltip
          />
          <el-table-column label="客户信息" min-width="160" show-overflow-tooltip>
            <template #default="{ row }">
              <div class="customer-cell">
                <span>{{ row.customerName || `客户#${row.customerId ?? '—'}` }}</span>
                <span class="mobile">{{ maskMobile(row.customerMobile) }}</span>
              </div>
            </template>
          </el-table-column>
          <el-table-column label="退款金额" min-width="110" align="right">
            <template #default="{ row }">
              {{ formatMoney(row.totalAmount) }}
            </template>
          </el-table-column>
          <el-table-column label="状态" min-width="90">
            <template #default="{ row }">
              <el-tag
                size="small"
                :type="
                  row.approvalStatus === '0'
                    ? 'warning'
                    : row.approvalStatus === '2'
                      ? 'success'
                      : row.approvalStatus === '9'
                        ? 'info'
                        : 'primary'
                "
              >
                {{ row.approvalStatusName || statusLabel(row.approvalStatus) }}
              </el-tag>
            </template>
          </el-table-column>
          <el-table-column prop="createdByName" label="申请人" min-width="100" />
          <el-table-column label="申请时间" min-width="160">
            <template #default="{ row }">
              {{ formatDateTime(row.createdOn) }}
            </template>
          </el-table-column>
          <el-table-column label="操作" width="140" fixed="right">
            <template #default="{ row }">
              <el-button link type="primary" @click="openDetail(row as RefundBill)">
                详情
              </el-button>
              <el-button
                v-if="canApprove && row.approvalStatus === '0' && (isPendingMode || pageMode === 'list')"
                link
                type="warning"
                @click="openDetail(row as RefundBill)"
              >
                审批
              </el-button>
            </template>
          </el-table-column>
        </el-table>
        <AppEmpty
          v-if="!loading && !error && records.length === 0"
          :title="emptyTitle"
        />
        <div class="pager">
          <el-pagination
            background
            layout="total, sizes, prev, pager, next"
            :total="total"
            :current-page="query.page"
            :page-size="query.size"
            :page-sizes="[10, 20, 50]"
            @current-change="(p: number) => { query.page = p; void loadList() }"
            @size-change="(s: number) => { query.size = s; query.page = 1; void loadList() }"
          />
        </div>
      </template>
    </div>

    <el-drawer v-model="detailVisible" title="退款详情" size="560px" destroy-on-close>
      <div v-loading="detailLoading">
        <template v-if="current">
          <section class="section">
            <h4>基础信息</h4>
            <div class="detail-meta">
              <div>退款编号：{{ current.id }}</div>
              <div>类型：{{ typeLabel(current.refundType) }}</div>
              <div>原订单：{{ current.sourceOrderId || '—' }}</div>
              <div>客户：{{ customerLabel(current) }}</div>
              <div>
                状态：
                <el-tag size="small">
                  {{ current.approvalStatusName || statusLabel(current.approvalStatus) }}
                </el-tag>
                <el-tag
                  v-if="current.specialRefund"
                  size="small"
                  type="danger"
                  effect="dark"
                  style="margin-left: 8px"
                >
                  特殊退款
                </el-tag>
              </div>
              <div>原因：{{ current.reason || '—' }}</div>
              <div v-if="current.specialRefund">
                特殊原因：{{ current.specialReason || '—' }}
              </div>
              <div v-if="current.refundOccurMonth">
                退款发生月：{{ current.refundOccurMonth }}
              </div>
              <div>申请人：{{ current.createdByName || current.createdBy || '—' }}</div>
              <div>申请时间：{{ formatDateTime(current.createdOn) }}</div>
              <div>门店：{{ current.storeName || current.storeId || '—' }}</div>
            </div>
          </section>

          <section class="section">
            <h4>审批记录</h4>
            <el-table
              v-if="current.processes?.length"
              :data="current.processes"
              border
              size="small"
            >
              <el-table-column prop="actionTypeName" label="动作" width="80" />
              <el-table-column prop="approvalByName" label="审批人" min-width="100" />
              <el-table-column label="时间" min-width="150">
                <template #default="{ row }">{{ formatDateTime(row.approvalOn) }}</template>
              </el-table-column>
              <el-table-column prop="approvalRemark" label="备注" min-width="120" show-overflow-tooltip />
            </el-table>
            <AppEmpty v-else title="暂无审批记录" />
          </section>

          <section class="section">
            <h4>退款信息</h4>
            <div class="detail-meta">
              <div>退款金额：{{ formatMoney(current.totalAmount) }}</div>
              <div>应付退款：{{ formatMoney(current.payAmount) }}</div>
            </div>
            <el-table
              v-if="current.payments?.length"
              :data="current.payments"
              border
              size="small"
              class="mt"
            >
              <el-table-column prop="payMethodName" label="退款渠道" min-width="120" />
              <el-table-column label="金额" min-width="100" align="right">
                <template #default="{ row }">{{ formatMoney(row.amount) }}</template>
              </el-table-column>
            </el-table>
            <p v-else class="hint">无支付分摊记录（按原支付比例写入）。</p>
          </section>

          <section class="section">
            <h4>权益明细（只读预览）</h4>
            <el-table
              v-if="current.items?.length"
              :data="current.items"
              border
              size="small"
            >
              <el-table-column prop="itemName" label="项目/卡项" min-width="140" show-overflow-tooltip />
              <el-table-column prop="accountTypeName" label="类型" width="90" />
              <el-table-column prop="holderCustomerName" label="持有人" min-width="100" />
              <el-table-column prop="accountId" label="账户" width="80" />
              <el-table-column prop="quantity" label="数量" width="80" />
              <el-table-column label="金额" width="100" align="right">
                <template #default="{ row }">{{ formatMoney(row.amount) }}</template>
              </el-table-column>
            </el-table>
            <p v-else class="hint">暂无明细快照；R1/R2 将完善计算与展示。</p>
          </section>

          <template v-if="showApproveActions">
            <el-input
              v-model="decideRemark"
              class="mt"
              type="textarea"
              :rows="2"
              placeholder="审批备注（可选）"
            />
            <div class="actions">
              <el-button type="danger" plain @click="handleReject">拒绝</el-button>
              <el-button type="primary" @click="handleApprove">通过</el-button>
            </div>
          </template>
        </template>
      </div>
    </el-drawer>

    <RefundCreateTypeDialog v-model="createTypeVisible" @select="onCreateTypeSelect" />
    <SaleRefundApplyDialog v-model="saleApplyVisible" @success="onCreateSuccess" />
    <TreatRefundApplyDialog v-model="treatApplyVisible" @success="onCreateSuccess" />
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

.filter-bar {
  background: #fff;
  border: 1px solid #ebeef5;
  border-radius: 4px;
  padding: 12px 12px 4px;
}

.filter-form {
  margin-bottom: 0;
}

.more-filters {
  margin-top: 4px;
  padding-top: 4px;
  border-top: 1px dashed #ebeef5;
}

.more-dot {
  display: inline-block;
  width: 6px;
  height: 6px;
  margin-left: 4px;
  border-radius: 50%;
  background: #f56c6c;
  vertical-align: middle;
}

.store-hint {
  margin: 0 0 8px;
  color: #909399;
  font-size: 12px;
}

.table-wrap {
  background: #fff;
  border: 1px solid #ebeef5;
  border-radius: 4px;
  padding: 12px;
  min-height: 280px;
}

.customer-cell {
  display: flex;
  flex-direction: column;
  gap: 2px;
  line-height: 1.3;
}

.customer-cell .mobile {
  color: #909399;
  font-size: 12px;
}

.pager {
  margin-top: 12px;
  display: flex;
  justify-content: flex-end;
}

.section {
  margin-bottom: 16px;
}

.section h4 {
  margin: 0 0 8px;
  font-size: 14px;
  font-weight: 600;
}

.detail-meta {
  display: grid;
  gap: 6px;
  font-size: 13px;
  line-height: 1.5;
}

.mt {
  margin-top: 10px;
}

.actions {
  margin-top: 12px;
  display: flex;
  justify-content: flex-end;
  gap: 8px;
}

.hint {
  margin: 8px 0 0;
  color: var(--el-text-color-secondary);
  font-size: 12px;
}
</style>
