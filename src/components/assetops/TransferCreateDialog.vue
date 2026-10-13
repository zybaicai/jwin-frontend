<script setup lang="ts">
import { computed, ref, watch } from 'vue'
import { ElMessage } from 'element-plus'

import {
  createTransferBill,
  fetchPackageTransferChildren,
} from '@/api/asset-ops'
import { fetchCustomerCards, fetchCustomerPage } from '@/api/customer'
import type { CreateTransferBillBody, PackageTransferChild } from '@/types/asset-ops'
import { TransferPermission } from '@/types/asset-ops'
import type { CustomerCardItem, CustomerCardItemType, CustomerListItem } from '@/types/customer'
import { usePermissionStore } from '@/stores/permission'
import { getUserFriendlyErrorMessage, runExclusive } from '@/utils/ui'
import { formatDateTime, formatMoney } from '@/views/customer/customer-format'

defineOptions({ name: 'TransferCreateDialog' })

const props = defineProps<{
  modelValue: boolean
}>()

const emit = defineEmits<{
  'update:modelValue': [value: boolean]
  success: []
}>()

interface DraftItem {
  key: string
  accountType: string
  accountId: number
  name: string
  balance: number | string | null
  quantity: number
  savingPrincipal: number
  savingBonus: number
  fromPackage?: boolean
}

const CARD_TABS: Array<{ type: CustomerCardItemType; label: string }> = [
  { type: 'GENERAL_CARD', label: '通用次卡' },
  { type: 'TIME_CARD', label: '时效卡' },
  { type: 'SAVING_CARD', label: '储值卡' },
  { type: 'PACKAGE_CARD', label: '套餐卡' },
  { type: 'PROJECT', label: '项目' },
]

const permissionStore = usePermissionStore()
const submitting = ref(false)
const outSearching = ref(false)
const inSearching = ref(false)
const cardsLoading = ref(false)
const outOptions = ref<CustomerListItem[]>([])
const inOptions = ref<CustomerListItem[]>([])
const outCustomer = ref<CustomerListItem | null>(null)
const inCustomerId = ref<number | undefined>(undefined)
const activeType = ref<CustomerCardItemType>('GENERAL_CARD')
const cardKeyword = ref('')
const cards = ref<CustomerCardItem[]>([])
const packageChildren = ref<PackageTransferChild[]>([])
const focusedPackageId = ref<number | null>(null)
const drafts = ref<DraftItem[]>([])
const remark = ref('')

const visible = computed({
  get: () => props.modelValue,
  set: (v: boolean) => emit('update:modelValue', v),
})

const canSubmit = computed(() =>
  permissionStore.hasPermission(TransferPermission.ORDER_CREATE),
)

const filteredCards = computed(() => {
  const q = cardKeyword.value.trim().toLowerCase()
  if (!q) {
    return cards.value
  }
  return cards.value.filter((c) => (c.name || '').toLowerCase().includes(q))
})

watch(
  () => props.modelValue,
  (open) => {
    if (!open) {
      return
    }
    resetAll()
  },
)

function resetAll(): void {
  outOptions.value = []
  inOptions.value = []
  outCustomer.value = null
  inCustomerId.value = undefined
  activeType.value = 'GENERAL_CARD'
  cardKeyword.value = ''
  cards.value = []
  packageChildren.value = []
  focusedPackageId.value = null
  drafts.value = []
  remark.value = ''
}

async function searchCustomers(
  keyword: string,
  target: 'out' | 'in',
): Promise<void> {
  const q = keyword.trim()
  const loading = target === 'out' ? outSearching : inSearching
  const options = target === 'out' ? outOptions : inOptions
  if (q.length < 1) {
    options.value = []
    return
  }
  await runExclusive(loading, async () => {
    try {
      const data = await fetchCustomerPage({ keyword: q, page: 1, size: 20 })
      let list = data.records ?? []
      if (target === 'in' && outCustomer.value != null) {
        list = list.filter((c) => c.id !== outCustomer.value!.id)
      }
      options.value = list
    } catch {
      options.value = []
    }
  })
}

async function handleOutPick(id: number | undefined): Promise<void> {
  if (id == null) {
    outCustomer.value = null
    cards.value = []
    drafts.value = []
    packageChildren.value = []
    focusedPackageId.value = null
    return
  }
  outCustomer.value =
    outOptions.value.find((c) => c.id === id) ??
    ({ id, name: String(id), mobile: null } as CustomerListItem)
  if (inCustomerId.value === id) {
    inCustomerId.value = undefined
  }
  drafts.value = []
  packageChildren.value = []
  focusedPackageId.value = null
  await loadCards()
}

async function loadCards(): Promise<void> {
  if (outCustomer.value == null) {
    cards.value = []
    return
  }
  await runExclusive(cardsLoading, async () => {
    try {
      const data = await fetchCustomerCards(outCustomer.value!.id, {
        itemType: activeType.value,
        page: 1,
        size: 100,
      })
      cards.value = (data.records ?? []).filter(
        (r) =>
          r.displayStatus !== 'REFUNDED' &&
          r.displayStatus !== 'TRANSFER_PENDING',
      )
    } catch (e) {
      cards.value = []
      ElMessage.error(getUserFriendlyErrorMessage(e))
    }
  })
}

watch(activeType, () => {
  packageChildren.value = []
  focusedPackageId.value = null
  void loadCards()
})

async function handleCardClick(row: CustomerCardItem): Promise<void> {
  if (activeType.value === 'PACKAGE_CARD') {
    focusedPackageId.value = row.accountId
    try {
      packageChildren.value = await fetchPackageTransferChildren(row.accountId)
      if (packageChildren.value.length === 0) {
        ElMessage.warning('该套餐下无可转子权益')
      }
    } catch (e) {
      packageChildren.value = []
      ElMessage.error(getUserFriendlyErrorMessage(e))
    }
    return
  }
  addDraft({
    accountType: activeType.value,
    accountId: row.accountId,
    name: row.name || `账户${row.accountId}`,
    balance: row.balance,
  })
}

function addChild(child: PackageTransferChild): void {
  addDraft({
    accountType: String(child.accountType),
    accountId: Number(child.accountId),
    name: String(child.itemName || `账户${child.accountId}`),
    balance: child.balance ?? null,
    fromPackage: true,
  })
}

function addDraft(input: {
  accountType: string
  accountId: number
  name: string
  balance: number | string | null
  fromPackage?: boolean
}): void {
  const key = `${input.accountType}-${input.accountId}`
  if (drafts.value.some((d) => d.key === key)) {
    ElMessage.info('该权益已在转账清单中')
    return
  }
  drafts.value.push({
    key,
    accountType: input.accountType,
    accountId: input.accountId,
    name: input.name,
    balance: input.balance,
    quantity: 1,
    savingPrincipal: 0,
    savingBonus: 0,
    fromPackage: input.fromPackage,
  })
}

function removeDraft(key: string): void {
  drafts.value = drafts.value.filter((d) => d.key !== key)
}

function clearDrafts(): void {
  drafts.value = []
}

async function handleSubmit(): Promise<void> {
  if (!canSubmit.value) {
    ElMessage.warning('无转账发起权限')
    return
  }
  if (outCustomer.value == null) {
    ElMessage.warning('请选择转出客户')
    return
  }
  if (inCustomerId.value == null) {
    ElMessage.warning('请选择转入客户')
    return
  }
  if (drafts.value.length === 0) {
    ElMessage.warning('请选择要转账的权益')
    return
  }

  const items: CreateTransferBillBody['items'] = []
  for (const d of drafts.value) {
    const item: CreateTransferBillBody['items'][number] = {
      accountType: d.accountType,
      accountId: d.accountId,
    }
    if (d.accountType === 'SAVING_CARD') {
      if (d.savingPrincipal <= 0 && d.savingBonus <= 0) {
        ElMessage.warning(`请填写「${d.name}」的本金或赠送金`)
        return
      }
      item.savingPrincipalAmount = d.savingPrincipal > 0 ? d.savingPrincipal : 0
      item.savingBonusAmount = d.savingBonus > 0 ? d.savingBonus : 0
    } else {
      if (!d.quantity || d.quantity <= 0) {
        ElMessage.warning(`请填写「${d.name}」的转出数量`)
        return
      }
      item.quantity = d.quantity
    }
    items.push(item)
  }

  await runExclusive(submitting, async () => {
    try {
      await createTransferBill({
        outCustomerId: outCustomer.value!.id,
        inCustomerId: inCustomerId.value!,
        remark: remark.value.trim() || undefined,
        items,
      })
      ElMessage.success('转账申请已提交（待审批冻结中）')
      visible.value = false
      emit('success')
    } catch (e) {
      ElMessage.error(getUserFriendlyErrorMessage(e))
    }
  })
}
</script>

<template>
  <el-dialog
    v-model="visible"
    title="客户转账"
    width="980px"
    top="4vh"
    destroy-on-close
    append-to-body
  >
    <div class="workbench">
      <div class="pane left">
        <el-select
          :model-value="outCustomer?.id"
          filterable
          remote
          clearable
          :teleported="false"
          :remote-method="(q: string) => searchCustomers(q, 'out')"
          :loading="outSearching"
          placeholder="选择转出客户（主护理客户）"
          style="width: 100%"
          @update:model-value="handleOutPick"
        >
          <el-option
            v-for="c in outOptions"
            :key="c.id"
            :label="`${c.name || ''} ${c.mobile || ''}`"
            :value="c.id"
          />
        </el-select>
        <div v-if="outCustomer" class="customer-chip">
          {{ outCustomer.name || outCustomer.id }}
          <span v-if="outCustomer.mobile">【{{ outCustomer.mobile }}】</span>
        </div>

        <template v-if="outCustomer">
          <el-input
            v-model="cardKeyword"
            class="mt8"
            clearable
            placeholder="请输入名称关键字搜索"
          />
          <el-tabs v-model="activeType" class="mt8">
            <el-tab-pane
              v-for="tab in CARD_TABS"
              :key="tab.type"
              :label="tab.label"
              :name="tab.type"
            />
          </el-tabs>
          <div v-loading="cardsLoading" class="card-list">
            <div
              v-for="row in filteredCards"
              :key="row.accountId"
              class="card-row"
              :class="{ active: focusedPackageId === row.accountId }"
              @click="handleCardClick(row)"
            >
              <div class="name">{{ row.name || '—' }}</div>
              <div class="sub">
                <template v-if="activeType === 'SAVING_CARD'">
                  余额 {{ formatMoney(row.balance) }}
                </template>
                <template v-else>余量 {{ row.balance ?? '—' }}</template>
                · {{ formatDateTime(row.validDate) }}
              </div>
            </div>
            <div v-if="!cardsLoading && filteredCards.length === 0" class="empty-hint">
              暂无可转权益
            </div>
          </div>

          <div v-if="activeType === 'PACKAGE_CARD' && packageChildren.length > 0" class="child-box">
            <div class="child-title">套餐子权益（点击加入转账清单）</div>
            <div
              v-for="c in packageChildren"
              :key="`${c.accountType}-${c.accountId}`"
              class="card-row child"
              @click="addChild(c)"
            >
              <div class="name">{{ c.itemName || '—' }}（{{ c.accountType }}）</div>
              <div class="sub">余量 {{ c.balance ?? 0 }}</div>
            </div>
          </div>
        </template>
        <div v-else class="empty-hint tall">请先选择转出客户</div>
      </div>

      <div class="pane right">
        <el-select
          v-model="inCustomerId"
          filterable
          remote
          clearable
          :teleported="false"
          :remote-method="(q: string) => searchCustomers(q, 'in')"
          :loading="inSearching"
          placeholder="选择转入客户（权限范围内）"
          style="width: 100%"
          popper-class="assetops-select-dropdown"
        >
          <el-option
            v-for="c in inOptions"
            :key="c.id"
            :label="`${c.name || ''} ${c.mobile || ''}`"
            :value="c.id"
          />
        </el-select>

        <div class="list-head mt8">
          <span>转账清单</span>
          <el-button v-if="drafts.length" link type="primary" @click="clearDrafts">清空</el-button>
        </div>

        <el-table :data="drafts" border size="small" empty-text="点击左侧权益加入转账清单" height="380">
          <el-table-column prop="name" label="权益" min-width="140" show-overflow-tooltip />
          <el-table-column label="有效存量" width="90">
            <template #default="{ row }">
              {{ row.accountType === 'SAVING_CARD' ? formatMoney(row.balance) : row.balance ?? '—' }}
            </template>
          </el-table-column>
          <el-table-column label="转出数量/金额" min-width="180">
            <template #default="{ row }">
              <template v-if="row.accountType === 'SAVING_CARD'">
                <div class="saving-row">
                  本金
                  <el-input-number v-model="row.savingPrincipal" :min="0" :precision="2" size="small" />
                </div>
                <div class="saving-row">
                  赠金
                  <el-input-number v-model="row.savingBonus" :min="0" :precision="2" size="small" />
                </div>
              </template>
              <el-input-number
                v-else
                v-model="row.quantity"
                :min="1"
                :max="9999"
                size="small"
              />
            </template>
          </el-table-column>
          <el-table-column label="操作" width="70" fixed="right">
            <template #default="{ row }">
              <el-button link type="danger" @click="removeDraft(row.key)">移除</el-button>
            </template>
          </el-table-column>
        </el-table>
      </div>
    </div>

    <template #footer>
      <div class="footer">
        <el-input v-model="remark" class="remark" placeholder="请输入备注信息" maxlength="500" />
        <span class="count">已选 {{ drafts.length }} 项</span>
        <el-button @click="visible = false">取消</el-button>
        <el-button type="primary" :loading="submitting" :disabled="!canSubmit" @click="handleSubmit">
          确认转账
        </el-button>
      </div>
    </template>
  </el-dialog>
</template>

<style scoped>
.workbench {
  display: grid;
  grid-template-columns: minmax(0, 1fr) minmax(0, 1.15fr);
  gap: 12px;
  min-height: 480px;
  overflow: hidden;
}

.pane {
  border: 1px solid var(--el-border-color-lighter);
  border-radius: 6px;
  padding: 12px;
  min-height: 460px;
  min-width: 0;
  overflow: hidden;
  position: relative;
}

.customer-chip {
  margin-top: 8px;
  font-size: 13px;
}

.card-list {
  max-height: 240px;
  overflow: auto;
}

.card-row {
  padding: 8px 10px;
  border-radius: 4px;
  cursor: pointer;
}

.card-row:hover,
.card-row.active {
  background: var(--el-color-primary-light-9);
}

.card-row .name {
  font-size: 13px;
}

.card-row .sub {
  margin-top: 2px;
  font-size: 12px;
  color: var(--el-text-color-secondary);
}

.child-box {
  margin-top: 8px;
  border: 1px solid var(--el-color-success-light-5);
  border-radius: 4px;
  padding: 6px;
  max-height: 160px;
  overflow: auto;
}

.child-title {
  font-size: 12px;
  color: var(--el-color-success);
  margin-bottom: 4px;
}

.empty-hint {
  padding: 24px 8px;
  text-align: center;
  color: var(--el-text-color-secondary);
  font-size: 13px;
}

.empty-hint.tall {
  padding-top: 140px;
}

.list-head {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 6px;
  font-size: 13px;
}

.saving-row {
  display: flex;
  align-items: center;
  gap: 6px;
  margin-bottom: 4px;
  font-size: 12px;
}

.mt8 {
  margin-top: 8px;
}

.footer {
  display: flex;
  align-items: center;
  gap: 10px;
  width: 100%;
}

.remark {
  flex: 1;
}

.count {
  white-space: nowrap;
  color: var(--el-text-color-secondary);
  font-size: 13px;
}
</style>
