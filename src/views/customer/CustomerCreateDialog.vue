<script setup lang="ts">
import { reactive, ref, watch } from 'vue'

import AppError from '@/components/common/AppError.vue'
import {
  createCustomer,
  fetchCustomerPage,
  fetchCustomerSourceOptions,
  fetchServicerOptions,
} from '@/api/customer'
import type { CustomerListItem, CustomerSourceOption } from '@/types/customer'
import { getUserFriendlyErrorMessage, notifyError, runExclusive, uiMessage } from '@/utils/ui'
import {
  formatCustomerPickerLabel,
  pickMainNurseEmployees,
} from '@/views/customer/customer-format'

const visible = defineModel<boolean>({ default: false })

const emit = defineEmits<{
  success: []
}>()

const saving = ref(false)
const loadingOptions = ref(false)
const optionsError = ref<string | null>(null)
const sourceOptions = ref<CustomerSourceOption[]>([])
const nurseOptions = ref<{ id: string; name: string }[]>([])

const introducerOptions = ref<CustomerListItem[]>([])
const introducerSearching = ref(false)
const introducerSearchError = ref<string | null>(null)
let introducerSearchTimer: ReturnType<typeof setTimeout> | null = null
let introducerSearchSeq = 0

const form = reactive({
  name: '',
  mobile: '',
  gender: '1',
  sourceId: undefined as number | undefined,
  birthday: '' as string,
  remark: '',
  address: '',
  nurseEmployeeId: '' as string,
  introducerCustomerId: undefined as number | undefined,
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
  form.introducerCustomerId = undefined
  introducerOptions.value = []
  introducerSearchError.value = null
  optionsError.value = null
  if (introducerSearchTimer != null) {
    clearTimeout(introducerSearchTimer)
    introducerSearchTimer = null
  }
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
    optionsError.value = getUserFriendlyErrorMessage(error)
    notifyError(error)
  } finally {
    loadingOptions.value = false
  }
}

function searchIntroducers(keyword: string): void {
  if (introducerSearchTimer != null) {
    clearTimeout(introducerSearchTimer)
  }
  const trimmed = keyword.trim()
  if (trimmed === '') {
    introducerOptions.value = []
    introducerSearchError.value = null
    introducerSearching.value = false
    return
  }
  introducerSearchTimer = setTimeout(() => {
    void runIntroducerSearch(trimmed)
  }, 300)
}

async function runIntroducerSearch(keyword: string): Promise<void> {
  const seq = ++introducerSearchSeq
  introducerSearching.value = true
  introducerSearchError.value = null
  try {
    const data = await fetchCustomerPage({
      keyword,
      page: 1,
      size: 20,
    })
    if (seq !== introducerSearchSeq) {
      return
    }
    introducerOptions.value = data.records ?? []
  } catch (error) {
    if (seq !== introducerSearchSeq) {
      return
    }
    introducerOptions.value = []
    introducerSearchError.value = '介绍人搜索失败'
    notifyError(error)
  } finally {
    if (seq === introducerSearchSeq) {
      introducerSearching.value = false
    }
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
        introducerCustomerId: form.introducerCustomerId ?? null,
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
      <el-form-item label="介绍人">
        <el-select
          v-model="form.introducerCustomerId"
          filterable
          remote
          clearable
          reserve-keyword
          :remote-method="searchIntroducers"
          :loading="introducerSearching"
          placeholder="输入姓名/编号/手机号搜索"
          style="width: 100%"
        >
          <el-option
            v-for="item in introducerOptions"
            :key="item.id"
            :label="formatCustomerPickerLabel(item)"
            :value="item.id"
          />
        </el-select>
        <p v-if="introducerSearchError" class="field-hint is-error">{{ introducerSearchError }}</p>
        <p
          v-else-if="!introducerSearching && introducerOptions.length === 0"
          class="field-hint"
        >
          输入关键字搜索本店可见客户
        </p>
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

<style scoped>
.field-hint {
  margin: 6px 0 0;
  color: #909399;
  font-size: 12px;
  line-height: 1.4;
}

.field-hint.is-error {
  color: #f56c6c;
}
</style>
