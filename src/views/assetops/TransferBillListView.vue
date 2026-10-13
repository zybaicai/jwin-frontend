<script setup lang="ts">
import { computed, onMounted, reactive, ref } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'

import AppEmpty from '@/components/common/AppEmpty.vue'
import AppError from '@/components/common/AppError.vue'
import TransferCreateDialog from '@/components/assetops/TransferCreateDialog.vue'
import {
  approveTransferBill,
  fetchAssetOpsConfig,
  fetchTransferBillDetail,
  fetchTransferBillPage,
  rejectTransferBill,
  saveAssetOpsConfig,
} from '@/api/asset-ops'
import type {
  AssetOpsConfig,
  TransferBill,
  UpsertAssetOpsConfigBody,
} from '@/types/asset-ops'
import { TRANSFER_STATUS_OPTIONS, TransferPermission } from '@/types/asset-ops'
import { usePermissionStore } from '@/stores/permission'
import { useStoreStore } from '@/stores/store'
import { getUserFriendlyErrorMessage, runExclusive } from '@/utils/ui'
import { formatDateTime, formatMoney } from '@/views/customer/customer-format'

defineOptions({ name: 'TransferBillListView' })

const permissionStore = usePermissionStore()
const storeStore = useStoreStore()

const loading = ref(false)
const error = ref<string | null>(null)
const records = ref<TransferBill[]>([])
const total = ref(0)
const query = reactive({
  billStatus: '0',
  keyword: '',
  page: 1,
  size: 20,
})

const detailVisible = ref(false)
const detailLoading = ref(false)
const current = ref<TransferBill | null>(null)
const decideRemark = ref('')

const configVisible = ref(false)
const configLoading = ref(false)
const configSaving = ref(false)
const config = reactive<{
  allowLargessTransfer: boolean
  roleCode: string
  employeeId: string
  jobTypeId: number | null
}>({
  allowLargessTransfer: false,
  roleCode: 'STORE_MANAGER',
  employeeId: '',
  jobTypeId: null,
})
const configApprovers = ref<AssetOpsConfig['transferApprovers']>([])

const canApprove = computed(() =>
  permissionStore.hasPermission(TransferPermission.ORDER_APPROVE),
)
const canConfig = computed(() =>
  permissionStore.hasPermission(TransferPermission.CONFIG_EDIT),
)
const canCreate = computed(() =>
  permissionStore.hasPermission(TransferPermission.ORDER_CREATE),
)

const createVisible = ref(false)

function customerLabel(name: string | null | undefined, mobile: string | null | undefined): string {
  const n = name || '—'
  return mobile ? `${n}（${mobile}）` : n
}

function statusLabel(code: string | null | undefined): string {
  const hit = TRANSFER_STATUS_OPTIONS.find((x) => x.value === code)
  return hit?.label ?? code ?? '—'
}

function itemQtyLabel(row: TransferBill['items'][number]): string {
  if (row.accountType === 'SAVING_CARD') {
    const p = formatMoney(row.savingPrincipalAmount)
    const b = formatMoney(row.savingBonusAmount)
    return `本金 ${p} / 赠金 ${b}`
  }
  return row.quantity != null ? `x ${row.quantity}` : '—'
}

async function loadList(): Promise<void> {
  await runExclusive(loading, async () => {
    error.value = null
    try {
      const data = await fetchTransferBillPage({
        billStatus: query.billStatus || undefined,
        keyword: query.keyword.trim() || undefined,
        storeId: storeStore.currentStoreId ?? undefined,
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

async function openDetail(row: TransferBill): Promise<void> {
  detailVisible.value = true
  decideRemark.value = ''
  await runExclusive(detailLoading, async () => {
    try {
      current.value = await fetchTransferBillDetail(row.id)
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
      '确认通过该转账申请？通过后将扣减原账户并创建目标客户新账户。',
      '审批通过',
      { type: 'warning' },
    )
  } catch {
    return
  }
  try {
    current.value = await approveTransferBill(current.value.id, {
      remark: decideRemark.value.trim() || undefined,
    })
    ElMessage.success('已通过')
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
    await ElMessageBox.confirm('确认拒绝该转账申请？拒绝后将解除冻结。', '审批拒绝', {
      type: 'warning',
    })
  } catch {
    return
  }
  try {
    current.value = await rejectTransferBill(current.value.id, {
      remark: decideRemark.value.trim() || undefined,
    })
    ElMessage.success('已拒绝')
    await loadList()
  } catch (e) {
    ElMessage.error(getUserFriendlyErrorMessage(e))
  }
}

async function openConfig(): Promise<void> {
  configVisible.value = true
  await runExclusive(configLoading, async () => {
    try {
      const data = await fetchAssetOpsConfig(storeStore.currentStoreId)
      config.allowLargessTransfer = data.allowLargessTransfer === true
      configApprovers.value = data.transferApprovers ?? []
      const first = configApprovers.value[0]
      if (first) {
        config.roleCode = first.roleCode
        config.employeeId = first.employeeId ?? ''
        config.jobTypeId = first.jobTypeId ?? null
      }
    } catch (e) {
      ElMessage.error(getUserFriendlyErrorMessage(e))
    }
  })
}

async function saveConfig(): Promise<void> {
  const body: UpsertAssetOpsConfigBody = {
    storeId: storeStore.currentStoreId,
    allowLargessTransfer: config.allowLargessTransfer,
    transferApprovers: [
      {
        roleCode: config.roleCode,
        employeeId: config.roleCode === 'EMPLOYEE' ? config.employeeId || null : null,
        jobTypeId: config.roleCode === 'JOB_TYPE' ? config.jobTypeId : null,
        levelNo: 1,
      },
    ],
  }
  await runExclusive(configSaving, async () => {
    try {
      const data = await saveAssetOpsConfig(body)
      configApprovers.value = data.transferApprovers ?? []
      ElMessage.success('配置已保存')
      configVisible.value = false
    } catch (e) {
      ElMessage.error(getUserFriendlyErrorMessage(e))
    }
  })
}

onMounted(() => {
  void loadList()
})
</script>

<template>
  <div class="page">
    <div class="filter-bar">
      <div class="filter-toolbar">
        <el-form :inline="true" class="filter-form" @submit.prevent="() => { query.page = 1; void loadList() }">
          <el-form-item label="客户信息">
            <el-input
              v-model="query.keyword"
              clearable
              placeholder="单号 / 转出或转入客户 / 手机号"
              style="width: 260px"
              @keyup.enter="() => { query.page = 1; void loadList() }"
            />
          </el-form-item>
          <el-form-item label="状态">
            <el-select
              v-model="query.billStatus"
              clearable
              placeholder="全部"
              style="width: 140px"
            >
              <el-option
                v-for="opt in TRANSFER_STATUS_OPTIONS"
                :key="opt.value"
                :label="opt.label"
                :value="opt.value"
              />
            </el-select>
          </el-form-item>
          <el-form-item>
            <el-button type="primary" :loading="loading" @click="() => { query.page = 1; void loadList() }">
              查询
            </el-button>
            <el-button v-if="canConfig" @click="openConfig">运营配置</el-button>
          </el-form-item>
        </el-form>
        <el-button
          v-if="canCreate"
          v-permission="TransferPermission.ORDER_CREATE"
          class="create-btn"
          type="primary"
          @click="createVisible = true"
        >
          新增
        </el-button>
      </div>
    </div>

    <div v-loading="loading" class="body">
      <AppError v-if="error && !loading" :description="error" @retry="loadList" />
      <template v-else>
        <el-table :data="records" border stripe size="small" empty-text=" ">
          <el-table-column prop="id" label="转账单号" min-width="150" show-overflow-tooltip />
          <el-table-column label="转出顾客" min-width="150" show-overflow-tooltip>
            <template #default="{ row }">
              {{ customerLabel(row.outCustomerName, row.outCustomerMobile) }}
            </template>
          </el-table-column>
          <el-table-column label="转入顾客" min-width="150" show-overflow-tooltip>
            <template #default="{ row }">
              {{ customerLabel(row.inCustomerName, row.inCustomerMobile) }}
            </template>
          </el-table-column>
          <el-table-column prop="storeName" label="门店" min-width="110" show-overflow-tooltip />
          <el-table-column label="状态" min-width="90">
            <template #default="{ row }">
              <el-tag v-if="row.billStatus === '0'" size="small" type="warning">
                {{ row.billStatusName || statusLabel(row.billStatus) }}
              </el-tag>
              <el-tag v-else-if="row.billStatus === '2'" size="small" type="success">
                {{ row.billStatusName || statusLabel(row.billStatus) }}
              </el-tag>
              <el-tag v-else-if="row.billStatus === '9'" size="small" type="info">
                {{ row.billStatusName || statusLabel(row.billStatus) }}
              </el-tag>
              <span v-else>{{ row.billStatusName || statusLabel(row.billStatus) }}</span>
            </template>
          </el-table-column>
          <el-table-column prop="createdByName" label="操作人" min-width="100" />
          <el-table-column label="操作时间" min-width="160">
            <template #default="{ row }">
              {{ formatDateTime(row.createdOn) }}
            </template>
          </el-table-column>
          <el-table-column prop="remark" label="备注" min-width="120" show-overflow-tooltip />
          <el-table-column label="操作" width="100" fixed="right">
            <template #default="{ row }">
              <el-button link type="primary" @click="openDetail(row as TransferBill)">详情</el-button>
            </template>
          </el-table-column>
        </el-table>
        <AppEmpty
          v-if="!loading && !error && records.length === 0"
          title="暂无转账单"
        />
        <div v-if="total > 0" class="pager">
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

    <el-drawer v-model="detailVisible" title="转账详情" size="560px" destroy-on-close>
      <div v-loading="detailLoading">
        <template v-if="current">
          <div class="detail-meta">
            <div>单号：{{ current.id }}</div>
            <div>
              转出：{{ customerLabel(current.outCustomerName, current.outCustomerMobile) }}
            </div>
            <div>
              转入：{{ customerLabel(current.inCustomerName, current.inCustomerMobile) }}
            </div>
            <div>状态：{{ current.billStatusName || statusLabel(current.billStatus) }}</div>
            <div>操作人：{{ current.createdByName || '—' }}</div>
            <div>操作时间：{{ formatDateTime(current.createdOn) }}</div>
            <div>原因：{{ current.remark || '—' }}</div>
            <div v-if="current.approvedByName">
              审核人：{{ current.approvedByName }} / {{ formatDateTime(current.approvedOn) }}
            </div>
            <div v-if="current.approvalRemark">审核备注：{{ current.approvalRemark }}</div>
          </div>

          <el-table :data="current.items" border size="small" class="mt">
            <el-table-column prop="itemName" label="权益" min-width="140" show-overflow-tooltip />
            <el-table-column prop="accountTypeName" label="类型" width="90" />
            <el-table-column label="数量/金额" min-width="140">
              <template #default="{ row }">
                {{ itemQtyLabel(row as TransferBill['items'][number]) }}
              </template>
            </el-table-column>
            <el-table-column label="有效期" min-width="140">
              <template #default="{ row }">{{ formatDateTime(row.validDate) }}</template>
            </el-table-column>
            <el-table-column prop="sourceSaleBillId" label="原销售单" min-width="140" show-overflow-tooltip />
            <el-table-column label="账户" min-width="120">
              <template #default="{ row }">
                {{ row.outAccountId ?? '—' }} → {{ row.inAccountId && row.inAccountId > 0 ? row.inAccountId : '待生成' }}
              </template>
            </el-table-column>
          </el-table>

          <template v-if="canApprove && current.billStatus === '0'">
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

    <TransferCreateDialog v-model="createVisible" @success="loadList" />

    <el-dialog v-model="configVisible" title="权益转账配置" width="520px" destroy-on-close>
      <div v-loading="configLoading">
        <el-form label-width="140px">
          <el-form-item label="允许赠送转账">
            <el-switch v-model="config.allowLargessTransfer" />
          </el-form-item>
          <el-form-item label="转账审批角色">
            <el-select v-model="config.roleCode" style="width: 100%">
              <el-option label="店长（职务名含店长/经理）" value="STORE_MANAGER" />
              <el-option label="财务（职务名含财务/会计）" value="FINANCE" />
              <el-option label="指定员工" value="EMPLOYEE" />
              <el-option label="指定职务ID" value="JOB_TYPE" />
            </el-select>
          </el-form-item>
          <el-form-item v-if="config.roleCode === 'EMPLOYEE'" label="员工ID">
            <el-input v-model="config.employeeId" placeholder="TK_Employee.ID" />
          </el-form-item>
          <el-form-item v-if="config.roleCode === 'JOB_TYPE'" label="职务ID">
            <el-input-number v-model="config.jobTypeId" :min="1" />
          </el-form-item>
        </el-form>
        <p class="hint">必须配置并命中审批角色后才可审批；未配置或未命中均不可审批；发起人只要有审批权限且命中配置，允许自批。</p>
      </div>
      <template #footer>
        <el-button @click="configVisible = false">取消</el-button>
        <el-button type="primary" :loading="configSaving" @click="saveConfig">保存</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<style scoped>
.page {
  padding: 12px 16px;
}

.filter-bar {
  background: #fff;
  border: 1px solid #ebeef5;
  border-radius: 4px;
  padding: 12px 14px;
  margin-bottom: 12px;
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

.body {
  min-height: 240px;
}

.pager {
  display: flex;
  justify-content: flex-end;
  margin-top: 12px;
}

.detail-meta {
  font-size: 13px;
  line-height: 1.8;
  color: var(--el-text-color-regular);
}

.mt {
  margin-top: 12px;
}

.actions {
  display: flex;
  justify-content: flex-end;
  gap: 8px;
  margin-top: 16px;
}

.hint {
  margin: 0;
  font-size: 12px;
  color: var(--el-text-color-secondary);
}
</style>
