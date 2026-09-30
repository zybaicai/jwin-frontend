<script setup lang="ts">
import { computed, reactive, ref, watch } from 'vue'

import { validatePriceChange } from '@/api/price'
import type { PriceChangeCheckResult } from '@/types/price'
import { formatAmountDisplay, normalizeAmountString } from '@/utils/amount'
import { getUserFriendlyErrorMessage, runExclusive, uiMessage } from '@/utils/ui'

defineOptions({ name: 'CashierPriceAdjustDialog' })

const visible = defineModel<boolean>({ default: false })

const props = defineProps<{
  storeId: number
  itemType: string
  itemId: number
  itemName: string
  saleChannelId: number
  basePrice: string | number | null
  minPrice: string | number | null
  allowAdjust: boolean
}>()

const emit = defineEmits<{
  confirmed: [payload: { price: string; reason: string }]
}>()

const loading = ref(false)
const form = reactive({
  targetPrice: '',
  reason: '',
})
const checkResult = ref<PriceChangeCheckResult | null>(null)

const baseDisplay = computed(() => formatAmountDisplay(props.basePrice))
const minDisplay = computed(() => formatAmountDisplay(props.minPrice))

function reset(): void {
  form.targetPrice = props.basePrice != null ? String(props.basePrice) : ''
  form.reason = ''
  checkResult.value = null
}

async function handleConfirm(): Promise<void> {
  if (!props.allowAdjust) {
    uiMessage.warning('当前行不允许改价')
    return
  }
  const normalized = normalizeAmountString(form.targetPrice)
  if (!normalized) {
    uiMessage.warning('请输入合法金额（最多两位小数）')
    return
  }
  const reason = form.reason.trim()
  if (!reason) {
    uiMessage.warning('请填写改价原因')
    return
  }
  const base = normalizeAmountString(String(props.basePrice ?? ''))
  if (base != null && Number(normalized) > Number(base)) {
    uiMessage.warning('改价不得高于后端基准价格')
    return
  }

  await runExclusive(loading, async () => {
    try {
      const result = await validatePriceChange({
        storeId: props.storeId,
        itemType: props.itemType,
        itemId: props.itemId,
        saleChannelId: props.saleChannelId,
        targetPrice: normalized,
        reason,
      })
      checkResult.value = result
      if (!result.allowed) {
        uiMessage.error(result.message || '改价校验未通过')
        return
      }
      emit('confirmed', { price: normalized, reason })
      visible.value = false
    } catch (error) {
      uiMessage.error(getUserFriendlyErrorMessage(error))
    }
  })
}

watch(visible, (open) => {
  if (open) {
    reset()
  }
})
</script>

<template>
  <el-dialog
    v-model="visible"
    title="改价"
    width="480px"
    append-to-body
    destroy-on-close
    :close-on-click-modal="false"
  >
    <div class="meta">
      <div><span class="label">商品</span>{{ itemName }}</div>
      <div><span class="label">基准价</span>¥ {{ baseDisplay }}</div>
      <div><span class="label">最低价</span>¥ {{ minDisplay }}</div>
    </div>
    <el-form label-width="88px" @submit.prevent>
      <el-form-item label="改后价格" required>
        <el-input v-model="form.targetPrice" placeholder="不得高于基准价" />
      </el-form-item>
      <el-form-item label="改价原因" required>
        <el-input v-model="form.reason" type="textarea" :rows="3" maxlength="200" show-word-limit />
      </el-form-item>
      <el-alert
        v-if="checkResult && !checkResult.allowed"
        type="error"
        :closable="false"
        :title="checkResult.message || '改价校验未通过'"
        style="margin-bottom: 12px"
      />
    </el-form>
    <template #footer>
      <el-button @click="visible = false">取消</el-button>
      <el-button type="primary" :loading="loading" @click="handleConfirm">确认改价</el-button>
    </template>
  </el-dialog>
</template>

<style scoped>
.meta {
  display: flex;
  flex-direction: column;
  gap: 6px;
  margin-bottom: 16px;
  font-size: 13px;
  color: #606266;
}

.label {
  display: inline-block;
  width: 64px;
  color: #909399;
}
</style>
