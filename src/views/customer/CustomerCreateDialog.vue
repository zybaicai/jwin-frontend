<script setup lang="ts">
import { reactive, ref, watch } from 'vue'

import AppError from '@/components/common/AppError.vue'
import {
  createCustomer,
  fetchCustomerSourceOptions,
  fetchServicerOptions,
} from '@/api/customer'
import type { CustomerSourceOption } from '@/types/customer'
import { notifyError, runExclusive, uiMessage } from '@/utils/ui'
import { pickMainNurseEmployees } from '@/views/customer/customer-format'

const visible = defineModel<boolean>({ default: false })

const emit = defineEmits<{
  success: []
}>()

const saving = ref(false)
const loadingOptions = ref(false)
const optionsError = ref<string | null>(null)
const sourceOptions = ref<CustomerSourceOption[]>([])
const nurseOptions = ref<{ id: string; name: string }[]>([])

const form = reactive({
  name: '',
  mobile: '',
  gender: '1',
  sourceId: undefined as number | undefined,
  birthday: '' as string,
  remark: '',
  address: '',
  nurseEmployeeId: '' as string,
})

function resetForm(): void {
  form.name = ''
  form.mobile = ''
  form.gender = '1'
  form.sourceId = undefined
  form.birthday = ''
  form.remark = ''
  form.address = ''
  form.nurseEmployeeId = ''
  optionsError.value = null
}

async function loadOptions(): Promise<void> {
  loadingOptions.value = true
  optionsError.value = null
  try {
    const [sources, roles] = await Promise.all([
      fetchCustomerSourceOptions(),
      fetchServicerOptions(),
    ])
    sourceOptions.value = sources.filter((item) => item.active !== false)
    nurseOptions.value = pickMainNurseEmployees(roles).map((emp) => ({
      id: emp.id,
      name: emp.name?.trim() || emp.id,
    }))
  } catch (error) {
    optionsError.value = '选项加载失败'
    notifyError(error)
  } finally {
    loadingOptions.value = false
  }
}

async function handleSubmit(): Promise<void> {
  if (!form.name.trim() || !form.mobile.trim() || form.sourceId == null) {
    uiMessage.warning('请填写姓名、手机号和首次来源')
    return
  }
  await runExclusive(saving, async () => {
    try {
      await createCustomer({
        name: form.name.trim(),
        mobile: form.mobile.trim(),
        gender: form.gender,
        sourceId: form.sourceId!,
        birthday: form.birthday || null,
        remark: form.remark.trim() || null,
        address: form.address.trim() || null,
        nurseEmployeeId: form.nurseEmployeeId || null,
      })
      uiMessage.success('保存成功')
      visible.value = false
      emit('success')
    } catch (error) {
      notifyError(error)
    }
  })
}

function handleClose(): void {
  visible.value = false
}

watch(visible, (open) => {
  if (!open) {
    resetForm()
    return
  }
  resetForm()
  void loadOptions()
})
</script>

<template>
  <el-dialog
    v-model="visible"
    title="新增客户"
    width="560px"
    destroy-on-close
    :close-on-click-modal="false"
    @closed="resetForm"
  >
    <AppError
      v-if="optionsError && !loadingOptions"
      :description="optionsError"
      @retry="loadOptions"
    />
    <el-form
      v-else
      v-loading="loadingOptions"
      label-width="100px"
      @submit.prevent
    >
      <el-form-item label="姓名" required>
        <el-input v-model="form.name" maxlength="50" placeholder="客户姓名" />
      </el-form-item>
      <el-form-item label="手机号" required>
        <el-input v-model="form.mobile" maxlength="20" placeholder="手机号" />
      </el-form-item>
      <el-form-item label="性别" required>
        <el-radio-group v-model="form.gender">
          <el-radio value="1">男</el-radio>
          <el-radio value="2">女</el-radio>
          <el-radio value="0">未知</el-radio>
        </el-radio-group>
      </el-form-item>
      <el-form-item label="首次来源" required>
        <el-select v-model="form.sourceId" filterable placeholder="请选择" style="width: 100%">
          <el-option
            v-for="item in sourceOptions"
            :key="item.id"
            :label="item.name"
            :value="item.id"
          />
        </el-select>
      </el-form-item>
      <el-form-item label="主护理师">
        <el-select
          v-model="form.nurseEmployeeId"
          clearable
          filterable
          placeholder="可选"
          style="width: 100%"
        >
          <el-option
            v-for="item in nurseOptions"
            :key="item.id"
            :label="item.name"
            :value="item.id"
          />
        </el-select>
      </el-form-item>
      <el-form-item label="生日">
        <el-date-picker
          v-model="form.birthday"
          type="date"
          value-format="YYYY-MM-DD"
          placeholder="可选"
          style="width: 100%"
        />
      </el-form-item>
      <el-form-item label="地址">
        <el-input v-model="form.address" maxlength="200" placeholder="可选" />
      </el-form-item>
      <el-form-item label="备注">
        <el-input
          v-model="form.remark"
          type="textarea"
          :rows="3"
          maxlength="500"
          placeholder="可选"
        />
      </el-form-item>
    </el-form>

    <template #footer>
      <el-button :disabled="saving" @click="handleClose">取消</el-button>
      <el-button type="primary" :loading="saving" @click="handleSubmit">保存</el-button>
    </template>
  </el-dialog>
</template>
