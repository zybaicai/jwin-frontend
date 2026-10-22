<script setup lang="ts">
import { computed, ref, watch } from 'vue'

import AppError from '@/components/common/AppError.vue'
import { fetchMembershipEntryRule, saveMembershipEntryRule } from '@/api/customer'
import { fetchGeneralCardOptions, fetchPackageCardOptions, fetchSavingCardOptions, fetchTimeCardOptions } from '@/api/card'
import { fetchProductOptions } from '@/api/product'
import { fetchProjectOptions } from '@/api/project'
import {
  CustomerPermission,
  type MembershipEntryMode,
  type MembershipGoodsItem,
} from '@/types/customer'
import { usePermissionStore } from '@/stores/permission'
import { getUserFriendlyErrorMessage, notifyError, runExclusive, uiMessage } from '@/utils/ui'

defineOptions({ name: 'CustomerMembershipEntryView' })

const GOODS_TYPES = [
  { value: 'PRODUCT', label: '产品' },
  { value: 'PROJECT', label: '项目' },
  { value: 'GENERAL_CARD', label: '通用次卡' },
  { value: 'TIME_CARD', label: '时效卡' },
  { value: 'SAVING_CARD', label: '储值卡' },
  { value: 'PACKAGE_CARD', label: '套餐卡' },
]

const permissionStore = usePermissionStore()
const canView = computed(() => permissionStore.hasPermission(CustomerPermission.MEMBERSHIP_ENTRY_VIEW))
const canEdit = computed(() => permissionStore.hasPermission(CustomerPermission.MEMBERSHIP_ENTRY_EDIT))

const loading = ref(false)
const saving = ref(false)
const errorText = ref<string | null>(null)
const mode = ref<MembershipEntryMode>('NONE')
const singleAmount = ref<number | null>(null)
const totalSaleAmount = ref<number | null>(null)
const totalTreatAmount = ref<number | null>(null)
const typeAmount = ref<number | null>(null)
const goodsTypes = ref<string[]>([])
const goods = ref<MembershipGoodsItem[]>([])

const pickerVisible = ref(false)
const pickerType = ref('PRODUCT')
const pickerKeyword = ref('')
const pickerLoading = ref(false)
const pickerRows = ref<Array<{ id: number; name: string }>>([])
const picked = ref<MembershipGoodsItem[]>([])

function applyAmount(target: MembershipEntryMode, amount?: number | null): void {
  if (target === 'SINGLE_SALE_AMOUNT') singleAmount.value = amount ?? null
  if (target === 'TOTAL_SALE_AMOUNT') totalSaleAmount.value = amount ?? null
  if (target === 'TOTAL_TREAT_AMOUNT') totalTreatAmount.value = amount ?? null
  if (target === 'SALE_GOODS_TYPE') typeAmount.value = amount ?? null
}

async function load(): Promise<void> {
  if (!canView.value) {
    errorText.value = '暂无权限查看入会门槛（customer:membership-entry:view）'
    return
  }
  await runExclusive(loading, async () => {
    errorText.value = null
    try {
      const data = await fetchMembershipEntryRule()
      mode.value = (data.mode || 'NONE') as MembershipEntryMode
      goodsTypes.value = data.goodsTypes ?? []
      goods.value = data.goods ?? []
      applyAmount(mode.value, data.amount ?? null)
    } catch (error) {
      errorText.value = getUserFriendlyErrorMessage(error)
    }
  })
}

function currentAmount(): number | null {
  if (mode.value === 'SINGLE_SALE_AMOUNT') return singleAmount.value
  if (mode.value === 'TOTAL_SALE_AMOUNT') return totalSaleAmount.value
  if (mode.value === 'TOTAL_TREAT_AMOUNT') return totalTreatAmount.value
  if (mode.value === 'SALE_GOODS_TYPE') return typeAmount.value
  return null
}

async function save(): Promise<void> {
  if (!canEdit.value) return
  await runExclusive(saving, async () => {
    try {
      const saved = await saveMembershipEntryRule({
        mode: mode.value,
        amount: currentAmount(),
        goodsTypes: goodsTypes.value,
        goods: goods.value.map((item) => ({
          goodsType: item.goodsType,
          goodsId: item.goodsId,
          goodsName: item.goodsName,
        })),
      })
      mode.value = (saved.mode || mode.value) as MembershipEntryMode
      goodsTypes.value = saved.goodsTypes ?? []
      goods.value = saved.goods ?? []
      uiMessage.success('入会门槛已保存，只对之后的建档和交易生效')
    } catch (error) {
      notifyError(error)
    }
  })
}

async function searchGoods(): Promise<void> {
  pickerLoading.value = true
  try {
    const keyword = pickerKeyword.value.trim() || undefined
    if (pickerType.value === 'PRODUCT') {
      const rows = await fetchProductOptions(keyword)
      pickerRows.value = rows.map((row) => ({ id: row.id, name: row.name || String(row.id) }))
    } else if (pickerType.value === 'PROJECT') {
      const rows = await fetchProjectOptions(keyword)
      pickerRows.value = rows.map((row) => ({ id: row.id, name: row.name || String(row.id) }))
    } else if (pickerType.value === 'GENERAL_CARD') {
      const rows = await fetchGeneralCardOptions(keyword)
      pickerRows.value = rows.map((row) => ({ id: row.id, name: row.name || String(row.id) }))
    } else if (pickerType.value === 'TIME_CARD') {
      const rows = await fetchTimeCardOptions(keyword)
      pickerRows.value = rows.map((row) => ({ id: row.id, name: row.name || String(row.id) }))
    } else if (pickerType.value === 'SAVING_CARD') {
      const rows = await fetchSavingCardOptions(keyword)
      pickerRows.value = rows.map((row) => ({ id: row.id, name: row.name || String(row.id) }))
    } else {
      const rows = await fetchPackageCardOptions(keyword)
      pickerRows.value = rows.map((row) => ({ id: row.id, name: row.name || String(row.id) }))
    }
  } catch (error) {
    pickerRows.value = []
    notifyError(error)
  } finally {
    pickerLoading.value = false
  }
}

function openPicker(): void {
  picked.value = goods.value.map((item) => ({ ...item }))
  pickerVisible.value = true
  void searchGoods()
}

function onTogglePick(row: unknown): void {
  const item = row as { id: number; name: string }
  const key = `${pickerType.value}:${item.id}`
  const index = picked.value.findIndex((pickedItem) => `${pickedItem.goodsType}:${pickedItem.goodsId}` === key)
  if (index >= 0) {
    picked.value.splice(index, 1)
    return
  }
  picked.value.push({ goodsType: pickerType.value, goodsId: item.id, goodsName: item.name })
}

function confirmGoods(): void {
  goods.value = picked.value.map((item) => ({ ...item }))
  pickerVisible.value = false
}

function removeGoods(item: MembershipGoodsItem): void {
  goods.value = goods.value.filter(
    (row) => !(row.goodsType === item.goodsType && row.goodsId === item.goodsId),
  )
}

function typeLabel(type: string): string {
  return GOODS_TYPES.find((item) => item.value === type)?.label ?? type
}

watch(canView, () => void load(), { immediate: true })
</script>

<template>
  <section class="entry-page">
    <header class="page-header">
      <el-button v-if="canEdit" type="primary" :loading="saving" @click="save">保存</el-button>
    </header>
    <AppError v-if="errorText && !loading" :description="errorText" @retry="load" />
    <div v-else v-loading="loading" class="rule-list">
      <el-radio-group v-model="mode" class="rules" :disabled="!canEdit">
        <el-radio value="NONE">无门槛</el-radio>
        <el-radio value="FIRST_SALE">完成首次销售</el-radio>
        <el-radio value="FIRST_TREAT">完成首次消费</el-radio>
        <div class="rule-line">
          <el-radio value="SINGLE_SALE_AMOUNT">单次销售满</el-radio>
          <el-input-number v-model="singleAmount" :min="0.01" :precision="2" :disabled="!canEdit" />
          <span>元</span>
          <span class="hint">仅实付金额</span>
        </div>
        <div class="rule-line">
          <el-radio value="TOTAL_SALE_AMOUNT">累计销售满</el-radio>
          <el-input-number v-model="totalSaleAmount" :min="0.01" :precision="2" :disabled="!canEdit" />
          <span>元</span>
          <span class="hint">仅实付金额</span>
        </div>
        <div class="rule-line">
          <el-radio value="TOTAL_TREAT_AMOUNT">累计消费满</el-radio>
          <el-input-number v-model="totalTreatAmount" :min="0.01" :precision="2" :disabled="!canEdit" />
          <span>元</span>
          <span class="hint">包括：实付金额、卡抵扣</span>
        </div>
        <div class="rule-block">
          <div class="rule-line">
            <el-radio value="SALE_GOODS_TYPE">单次销售指定类型满</el-radio>
            <el-input-number v-model="typeAmount" :min="0.01" :precision="2" :disabled="!canEdit" />
            <span>元</span>
            <span class="hint">勾选的类型里，任意一条的实付达到金额就入会。同一单里的其他商品不计入这条金额</span>
          </div>
          <el-checkbox-group v-model="goodsTypes" :disabled="!canEdit">
            <el-checkbox v-for="item in GOODS_TYPES" :key="item.value" :value="item.value">
              {{ item.label }}
            </el-checkbox>
          </el-checkbox-group>
        </div>
        <div class="rule-block">
          <el-radio value="SALE_GOODS">销售指定商品</el-radio>
          <el-button :disabled="!canEdit" @click="openPicker">添加商品</el-button>
          <div class="goods-tags">
            <el-tag
              v-for="item in goods"
              :key="`${item.goodsType}-${item.goodsId}`"
              :closable="canEdit"
              @close="removeGoods(item)"
            >
              {{ typeLabel(item.goodsType) }} · {{ item.goodsName || item.goodsId }}
            </el-tag>
          </div>
        </div>
      </el-radio-group>
    </div>

    <el-dialog v-model="pickerVisible" title="添加商品" width="720px" :close-on-click-modal="false">
      <div class="picker-tools">
        <el-select v-model="pickerType" style="width: 160px" @change="searchGoods">
          <el-option v-for="item in GOODS_TYPES" :key="item.value" :label="item.label" :value="item.value" />
        </el-select>
        <el-input v-model="pickerKeyword" clearable placeholder="名称" style="width: 220px" @keyup.enter="searchGoods" />
        <el-button type="primary" :loading="pickerLoading" @click="searchGoods">搜索</el-button>
      </div>
      <el-table v-loading="pickerLoading" :data="pickerRows" height="360" @row-click="onTogglePick">
        <el-table-column label="选择" width="70">
          <template #default="{ row }">
            <el-checkbox
              :model-value="picked.some((item) => item.goodsType === pickerType && item.goodsId === row.id)"
              @change="onTogglePick(row)"
              @click.stop
            />
          </template>
        </el-table-column>
        <el-table-column prop="name" label="名称" min-width="240" />
      </el-table>
      <template #footer>
        <el-button @click="pickerVisible = false">取消</el-button>
        <el-button type="primary" @click="confirmGoods">确定</el-button>
      </template>
    </el-dialog>
  </section>
</template>

<style scoped>
.entry-page {
  padding: 20px 24px 32px;
}
.page-header {
  display: flex;
  justify-content: space-between;
  gap: 12px;
  margin-bottom: 16px;
}
.page-header h1 {
  margin: 0 0 6px;
  font-size: 20px;
}
.subtitle,
.hint {
  margin: 0;
  color: #909399;
  font-size: 13px;
}
.rules {
  display: flex;
  flex-direction: column;
  align-items: flex-start;
  gap: 14px;
}
.rule-line,
.rule-block,
.picker-tools,
.goods-tags {
  display: flex;
  flex-wrap: wrap;
  align-items: center;
  gap: 8px;
}
.rule-block {
  flex-direction: column;
  align-items: flex-start;
}
</style>
