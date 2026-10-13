<script setup lang="ts">
import { computed, reactive, ref, watch } from 'vue'
import { ElMessage } from 'element-plus'

import {
  createTransferBill,
  fetchPackageTransferChildren,
} from '@/api/asset-ops'
import { fetchCustomerPage } from '@/api/customer'
import type {
  CreateTransferBillBody,
  PackageTransferChild,
} from '@/types/asset-ops'
import { TransferPermission } from '@/types/asset-ops'
import type { CustomerCardItem, CustomerCardItemType, CustomerListItem } from '@/types/customer'
import { usePermissionStore } from '@/stores/permission'
import { getUserFriendlyErrorMessage, runExclusive } from '@/utils/ui'
import { formatDateTime, formatMoney } from '@/views/customer/customer-format'

defineOptions({ name: 'TransferApplyDialog' })

const props = defineProps<{
  modelValue: boolean
  customerId: number
  customerName?: string | null
  account: CustomerCardItem | null
  accountType: CustomerCardItemType | null
}>()

const emit = defineEmits<{
  'update:modelValue': [value: boolean]
  success: []
}>()

const permissionStore = usePermissionStore()
const submitting = ref(false)
const targetSearching = ref(false)
const targetOptions = ref<CustomerListItem[]>([])
const packageChildren = ref<PackageTransferChild[]>([])
const selectedChildKey = ref('')

const form = reactive({
  inCustomerId: undefined as number | undefined,
  quantity: 1,
  savingPrincipal: 0,
  savingBonus: 0,
  remark: '',
})

const visible = computed({
  get: () => props.modelValue,
  set: (v: boolean) => emit('update:modelValue', v),
})

const canSubmit = computed(() =>
  permissionStore.hasPermission(TransferPermission.ORDER_CREATE),
)

const isSaving = computed(() => props.accountType === 'SAVING_CARD')
const isPackage = computed(() => props.accountType === 'PACKAGE_CARD')

const selectedChild = computed((): PackageTransferChild | null => {
  if (!selectedChildKey.value) {
    return null
  }
  return (
    packageChildren.value.find(
      (c) => `${c.accountType}-${c.accountId}` === selectedChildKey.value,
    ) ?? null
  )
})

const showSavingSplit = computed(() => {
  if (isSaving.value && !isPackage.value) {
    return true
  }
  return selectedChild.value?.accountType === 'SAVING_CARD'
})

const showQuantity = computed(() => {
  if (isPackage.value && !selectedChild.value) {
    return false
  }
  return !showSavingSplit.value
})

watch(
  () => props.modelValue,
  async (open) => {
    if (!open) {
      return
    }
    form.inCustomerId = undefined
    form.quantity = 1
    form.savingPrincipal = 0
    form.savingBonus = 0
    form.remark = ''
    targetOptions.value = []
    packageChildren.value = []
    selectedChildKey.value = ''
    if (props.accountType === 'PACKAGE_CARD' && props.account != null) {
      try {
        packageChildren.value = await fetchPackageTransferChildren(props.account.accountId)
      } catch (e) {
        ElMessage.error(getUserFriendlyErrorMessage(e))
      }
    }
  },
)

async function searchTargets(keyword: string): Promise<void> {
  const q = keyword.trim()
  if (q.length < 1) {
    targetOptions.value = []
    return
  }
  await runExclusive(targetSearching, async () => {
    try {
      const data = await fetchCustomerPage({ keyword: q, page: 1, size: 20 })
      targetOptions.value = (data.records ?? []).filter((c) => c.id !== props.customerId)
    } catch {
      targetOptions.value = []
    }
  })
}

async function handleSubmit(): Promise<void> {
  if (!canSubmit.value) {
    ElMessage.warning('无转账发起权限')
    return
  }
  if (form.inCustomerId == null) {
    ElMessage.warning('请选择目标客户')
    return
  }
  if (props.account == null || props.accountType == null) {
    ElMessage.warning('未选择权益')
    return
  }

  let accountType = props.accountType
  let accountId = props.account.accountId
  if (isPackage.value) {
    const child = selectedChild.value
    if (child == null) {
      ElMessage.warning('请选择套餐内子权益')
      return
    }
    accountType = child.accountType as CustomerCardItemType
    accountId = child.accountId
  }

  const item: CreateTransferBillBody['items'][number] = {
    accountType,
    accountId,
  }

  if (accountType === 'SAVING_CARD') {
    if (form.savingPrincipal <= 0 && form.savingBonus <= 0) {
      ElMessage.warning('请分别填写本金或赠送金')
      return
    }
    item.savingPrincipalAmount = form.savingPrincipal > 0 ? form.savingPrincipal : 0
    item.savingBonusAmount = form.savingBonus > 0 ? form.savingBonus : 0
  } else {
    if (!form.quantity || form.quantity <= 0) {
      ElMessage.warning('请填写转账数量')
      return
    }
    item.quantity = form.quantity
  }

  await runExclusive(submitting, async () => {
    try {
      await createTransferBill({
        outCustomerId: props.customerId,
        inCustomerId: form.inCustomerId!,
        remark: form.remark.trim() || undefined,
        items: [item],
      })
      ElMessage.success('转账申请已提交（待审批冻结中）')
      visible.value = false
      emit('success')
    } catch (error) {
      ElMessage.error(getUserFriendlyErrorMessage(error))
    }
  })
}
</script>

<template>
  <el-dialog
    v-model="visible"
    title="权益转账"
    width="560px"
    destroy-on-close
    append-to-body
  >
    <div class="meta">
      <div>转出客户：{{ customerName || customerId }}</div>
      <div>权益：{{ account?.name || '—' }}（{{ accountType }}）</div>
      <div>原有效期：{{ formatDateTime(account?.validDate) }}</div>
      <div v-if="!isSaving">余量：{{ account?.balance ?? '—' }}</div>
      <div v-else>余额：{{ formatMoney(account?.balance) }}</div>
    </div>

    <el-form label-width="110px" class="form">
      <el-form-item label="目标客户" required>
        <el-select
          v-model="form.inCustomerId"
          filterable
          remote
          clearable
          :remote-method="searchTargets"
          :loading="targetSearching"
          placeholder="搜索姓名/手机号（权限范围内）"
          style="width: 100%"
        >
          <el-option
            v-for="c in targetOptions"
            :key="c.id"
            :label="`${c.name || ''} ${c.mobile || ''}`"
            :value="c.id"
          />
        </el-select>
      </el-form-item>

      <el-form-item v-if="isPackage" label="套餐子权益" required>
        <el-select v-model="selectedChildKey" placeholder="选择子项目/子卡" style="width: 100%">
          <el-option
            v-for="c in packageChildren"
            :key="`${c.accountType}-${c.accountId}`"
            :label="`${c.itemName || ''}（${c.accountType} 余${c.balance ?? 0}）`"
            :value="`${c.accountType}-${c.accountId}`"
          />
        </el-select>
      </el-form-item>

      <template v-if="showSavingSplit">
        <el-form-item label="本金">
          <el-input-number v-model="form.savingPrincipal" :min="0" :precision="2" :step="10" />
        </el-form-item>
        <el-form-item label="赠送金">
          <el-input-number v-model="form.savingBonus" :min="0" :precision="2" :step="10" />
        </el-form-item>
      </template>
      <el-form-item v-else-if="showQuantity" label="转账数量" required>
        <el-input-number v-model="form.quantity" :min="1" :max="9999" />
      </el-form-item>

      <el-form-item label="原因">
        <el-input
          v-model="form.remark"
          type="textarea"
          :rows="3"
          maxlength="500"
          show-word-limit
          placeholder="如：朋友到店消费"
        />
      </el-form-item>
    </el-form>

    <template #footer>
      <el-button @click="visible = false">取消</el-button>
      <el-button type="primary" :loading="submitting" :disabled="!canSubmit" @click="handleSubmit">
        提交申请
      </el-button>
    </template>
  </el-dialog>
</template>

<style scoped>
.meta {
  margin-bottom: 12px;
  color: var(--el-text-color-secondary);
  font-size: 13px;
  line-height: 1.7;
}

.form {
  margin-top: 4px;
}
</style>
