<script setup lang="ts">
import { computed, ref, watch } from 'vue'
import { ElMessage } from 'element-plus'

import { createPostponeBill } from '@/api/asset-ops'
import { fetchCustomerCards, fetchCustomerPage } from '@/api/customer'
import { PostponePermission } from '@/types/asset-ops'
import type { CustomerCardItem, CustomerCardItemType, CustomerListItem } from '@/types/customer'
import { usePermissionStore } from '@/stores/permission'
import { getUserFriendlyErrorMessage, runExclusive } from '@/utils/ui'
import { formatDateTime } from '@/views/customer/customer-format'

defineOptions({ name: 'PostponeCreateDialog' })

const props = defineProps<{
  modelValue: boolean
}>()

const emit = defineEmits<{
  'update:modelValue': [value: boolean]
  success: []
}>()

interface DraftItem {
  key: string
  accountType: CustomerCardItemType
  accountId: number
  name: string
  oldValidDate: string | null
  mode: 'days' | 'date' | 'everlasting'
  extensionDays: number
  newValidDate: string
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
const customerSearching = ref(false)
const cardsLoading = ref(false)
const customerOptions = ref<CustomerListItem[]>([])
const selectedCustomer = ref<CustomerListItem | null>(null)
const activeType = ref<CustomerCardItemType>('GENERAL_CARD')
const cardKeyword = ref('')
const cards = ref<CustomerCardItem[]>([])
const drafts = ref<DraftItem[]>([])
const remark = ref('')

const visible = computed({
  get: () => props.modelValue,
  set: (v: boolean) => emit('update:modelValue', v),
})

const canSubmit = computed(() =>
  permissionStore.hasPermission(PostponePermission.ORDER_CREATE),
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
  customerOptions.value = []
  selectedCustomer.value = null
  activeType.value = 'GENERAL_CARD'
  cardKeyword.value = ''
  cards.value = []
  drafts.value = []
  remark.value = ''
}

async function searchCustomers(keyword: string): Promise<void> {
  const q = keyword.trim()
  if (q.length < 1) {
    customerOptions.value = []
    return
  }
  await runExclusive(customerSearching, async () => {
    try {
      const data = await fetchCustomerPage({ keyword: q, page: 1, size: 20 })
      customerOptions.value = data.records ?? []
    } catch {
      customerOptions.value = []
    }
  })
}

async function handleCustomerPick(id: number | undefined): Promise<void> {
  if (id == null) {
    selectedCustomer.value = null
    cards.value = []
    drafts.value = []
    return
  }
  selectedCustomer.value =
    customerOptions.value.find((c) => c.id === id) ??
    ({ id, name: String(id), mobile: null } as CustomerListItem)
  drafts.value = []
  await loadCards()
}

async function loadCards(): Promise<void> {
  if (selectedCustomer.value == null) {
    cards.value = []
    return
  }
  await runExclusive(cardsLoading, async () => {
    try {
      const data = await fetchCustomerCards(selectedCustomer.value!.id, {
        itemType: activeType.value,
        page: 1,
        size: 100,
      })
      cards.value = (data.records ?? []).filter(
        (r) => r.displayStatus !== 'REFUNDED' && r.displayStatus !== 'POSTPONE_PENDING',
      )
    } catch (e) {
      cards.value = []
      ElMessage.error(getUserFriendlyErrorMessage(e))
    }
  })
}

watch(activeType, () => {
  void loadCards()
})

function addCard(row: CustomerCardItem): void {
  const key = `${activeType.value}-${row.accountId}`
  if (drafts.value.some((d) => d.key === key)) {
    ElMessage.info('该权益已在延期清单中')
    return
  }
  drafts.value.push({
    key,
    accountType: activeType.value,
    accountId: row.accountId,
    name: row.name || `账户${row.accountId}`,
    oldValidDate: row.validDate,
    mode: 'days',
    extensionDays: 30,
    newValidDate: '',
  })
}

function removeDraft(key: string): void {
  drafts.value = drafts.value.filter((d) => d.key !== key)
}

async function handleSubmit(): Promise<void> {
  if (!canSubmit.value) {
    ElMessage.warning('无延期申请权限')
    return
  }
  if (selectedCustomer.value == null) {
    ElMessage.warning('请选择客户')
    return
  }
  if (drafts.value.length === 0) {
    ElMessage.warning('请选择要延期的卡项')
    return
  }

  const items: Array<{
    accountType: string
    accountId: number
    newValidDate?: string | null
    extensionDays?: number | null
    everlasting?: boolean
  }> = []

  for (const d of drafts.value) {
    const item: (typeof items)[number] = {
      accountType: d.accountType,
      accountId: d.accountId,
    }
    if (d.mode === 'everlasting') {
      item.everlasting = true
    } else if (d.mode === 'days') {
      if (!d.extensionDays || d.extensionDays <= 0) {
        ElMessage.warning(`请填写「${d.name}」的延期天数`)
        return
      }
      item.extensionDays = d.extensionDays
    } else {
      if (!d.newValidDate) {
        ElMessage.warning(`请选择「${d.name}」的新有效期`)
        return
      }
      item.newValidDate = d.newValidDate.includes('T')
        ? d.newValidDate
        : `${d.newValidDate}T23:59:59`
    }
    items.push(item)
  }

  await runExclusive(submitting, async () => {
    try {
      await createPostponeBill({
        customerId: selectedCustomer.value!.id,
        remark: remark.value.trim() || undefined,
        items,
      })
      ElMessage.success('延期申请已提交')
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
    title="延期申请"
    width="960px"
    top="5vh"
    destroy-on-close
    append-to-body
    class="postpone-create-dialog"
  >
    <div class="workbench">
      <div class="pane left">
        <el-select
          :model-value="selectedCustomer?.id"
          filterable
          remote
          clearable
          :teleported="false"
          :remote-method="searchCustomers"
          :loading="customerSearching"
          placeholder="请输入客户姓名、手机号、编号查找"
          style="width: 100%"
          @update:model-value="handleCustomerPick"
        >
          <el-option
            v-for="c in customerOptions"
            :key="c.id"
            :label="`${c.name || ''} ${c.mobile || ''}`"
            :value="c.id"
          />
        </el-select>

        <template v-if="selectedCustomer">
          <div class="customer-chip">
            {{ selectedCustomer.name || selectedCustomer.id }}
            <span v-if="selectedCustomer.mobile">【{{ selectedCustomer.mobile }}】</span>
          </div>
          <el-input
            v-model="cardKeyword"
            clearable
            placeholder="请输入商品名称关键字"
            class="mt8"
          />
          <el-tabs v-model="activeType" class="mt8" @tab-change="() => void loadCards()">
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
              @click="addCard(row)"
            >
              <div class="name">{{ row.name || '—' }}</div>
              <div class="sub">
                余量 {{ row.balance ?? '—' }} · 有效期 {{ formatDateTime(row.validDate) }}
              </div>
            </div>
            <div v-if="!cardsLoading && filteredCards.length === 0" class="empty-hint">
              暂无可延期卡项
            </div>
          </div>
        </template>
        <div v-else class="empty-hint tall">请先在上方选择客户</div>
      </div>

      <div class="pane right">
        <el-table :data="drafts" border size="small" empty-text="点击左侧卡项，将其加入延期清单" height="420">
          <el-table-column prop="name" label="商品" min-width="120" show-overflow-tooltip />
          <el-table-column label="原失效日期" min-width="140">
            <template #default="{ row }">{{ formatDateTime(row.oldValidDate) }}</template>
          </el-table-column>
          <el-table-column label="延期方式" min-width="220">
            <template #default="{ row }">
              <el-radio-group v-model="row.mode" size="small">
                <el-radio-button value="days">天数</el-radio-button>
                <el-radio-button value="date">日期</el-radio-button>
                <el-radio-button value="everlasting">永久</el-radio-button>
              </el-radio-group>
              <div class="mt8">
                <el-input-number
                  v-if="row.mode === 'days'"
                  v-model="row.extensionDays"
                  :min="1"
                  :max="3650"
                  size="small"
                />
                <el-date-picker
                  v-else-if="row.mode === 'date'"
                  v-model="row.newValidDate"
                  type="date"
                  value-format="YYYY-MM-DD"
                  size="small"
                  placeholder="新失效日期"
                  style="width: 100%"
                />
                <span v-else class="muted">永久有效</span>
              </div>
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
        <el-input
          v-model="remark"
          class="remark"
          placeholder="请输入备注信息"
          maxlength="500"
        />
        <span class="count">已选 {{ drafts.length }} 项</span>
        <el-button @click="visible = false">取消</el-button>
        <el-button type="primary" :loading="submitting" :disabled="!canSubmit" @click="handleSubmit">
          提交申请
        </el-button>
      </div>
    </template>
  </el-dialog>
</template>

<style scoped>
.workbench {
  display: grid;
  grid-template-columns: minmax(0, 1fr) minmax(0, 1.2fr);
  gap: 12px;
  min-height: 460px;
  overflow: hidden;
}

.pane {
  border: 1px solid var(--el-border-color-lighter);
  border-radius: 6px;
  padding: 12px;
  min-height: 440px;
  min-width: 0;
  overflow: hidden;
  position: relative;
}

.customer-chip {
  margin-top: 8px;
  font-size: 13px;
  color: var(--el-text-color-regular);
}

.card-list {
  max-height: 320px;
  overflow: auto;
}

.card-row {
  padding: 8px 10px;
  border-radius: 4px;
  cursor: pointer;
}

.card-row:hover {
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

.empty-hint {
  padding: 24px 8px;
  text-align: center;
  color: var(--el-text-color-secondary);
  font-size: 13px;
}

.empty-hint.tall {
  padding-top: 120px;
}

.mt8 {
  margin-top: 8px;
}

.muted {
  color: var(--el-text-color-secondary);
  font-size: 12px;
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
