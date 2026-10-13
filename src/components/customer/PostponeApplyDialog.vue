<script setup lang="ts">
import { computed, reactive, ref, watch } from 'vue'
import { ElMessage } from 'element-plus'

import { createPostponeBill } from '@/api/asset-ops'
import type { CustomerCardItem, CustomerCardItemType } from '@/types/customer'
import { PostponePermission } from '@/types/asset-ops'
import { usePermissionStore } from '@/stores/permission'
import { getUserFriendlyErrorMessage, runExclusive } from '@/utils/ui'
import { formatDateTime } from '@/views/customer/customer-format'

defineOptions({ name: 'PostponeApplyDialog' })

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
const form = reactive({
  mode: 'days' as 'days' | 'date' | 'everlasting',
  extensionDays: 30,
  newValidDate: '' as string,
  remark: '',
})

const visible = computed({
  get: () => props.modelValue,
  set: (v: boolean) => emit('update:modelValue', v),
})

const canSubmit = computed(() =>
  permissionStore.hasPermission(PostponePermission.ORDER_CREATE),
)

const title = computed(() => {
  const name = props.account?.name || '权益'
  return `申请延期 — ${name}`
})

watch(
  () => props.modelValue,
  (open) => {
    if (!open) {
      return
    }
    form.mode = 'days'
    form.extensionDays = 30
    form.newValidDate = ''
    form.remark = ''
  },
)

async function handleSubmit(): Promise<void> {
  if (!canSubmit.value) {
    ElMessage.warning('无延期申请权限')
    return
  }
  if (props.account == null || props.accountType == null) {
    ElMessage.warning('未选择权益')
    return
  }
  if (props.accountType === 'PRODUCT') {
    ElMessage.warning('产品权益不支持延期')
    return
  }

  const item: {
    accountType: string
    accountId: number
    newValidDate?: string | null
    extensionDays?: number | null
    everlasting?: boolean
  } = {
    accountType: props.accountType,
    accountId: props.account.accountId,
  }

  if (form.mode === 'everlasting') {
    item.everlasting = true
  } else if (form.mode === 'days') {
    if (!form.extensionDays || form.extensionDays <= 0) {
      ElMessage.warning('请填写延期天数')
      return
    }
    item.extensionDays = form.extensionDays
  } else {
    if (!form.newValidDate) {
      ElMessage.warning('请选择新有效期')
      return
    }
    item.newValidDate = form.newValidDate.includes('T')
      ? form.newValidDate
      : `${form.newValidDate}T23:59:59`
  }

  await runExclusive(submitting, async () => {
    try {
      await createPostponeBill({
        customerId: props.customerId,
        remark: form.remark.trim() || undefined,
        items: [item],
      })
      ElMessage.success('延期申请已提交')
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
    :title="title"
    width="520px"
    destroy-on-close
    append-to-body
  >
    <div class="meta">
      <div>客户：{{ customerName || customerId }}</div>
      <div>原有效期：{{ formatDateTime(account?.validDate) }}</div>
      <div>余量：{{ account?.balance ?? '—' }}</div>
    </div>

    <el-form label-width="100px" class="form">
      <el-form-item label="延期方式">
        <el-radio-group v-model="form.mode">
          <el-radio value="days">按天数</el-radio>
          <el-radio value="date">指定日期</el-radio>
          <el-radio value="everlasting">永久有效</el-radio>
        </el-radio-group>
      </el-form-item>
      <el-form-item v-if="form.mode === 'days'" label="延期天数">
        <el-input-number v-model="form.extensionDays" :min="1" :max="3650" />
      </el-form-item>
      <el-form-item v-else-if="form.mode === 'date'" label="新有效期">
        <el-date-picker
          v-model="form.newValidDate"
          type="date"
          value-format="YYYY-MM-DD"
          placeholder="选择日期"
        />
      </el-form-item>
      <el-form-item label="原因">
        <el-input
          v-model="form.remark"
          type="textarea"
          :rows="3"
          maxlength="500"
          show-word-limit
          placeholder="请填写延期原因"
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
