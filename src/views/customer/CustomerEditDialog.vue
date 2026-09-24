<script setup lang="ts">
import { reactive, ref, watch } from 'vue'

import AppError from '@/components/common/AppError.vue'
import {
  fetchCustomerDetail,
  fetchServicerOptions,
  findCustomerListItemById,
  updateCustomer,
} from '@/api/customer'
import { getUserFriendlyErrorMessage, notifyError, runExclusive, uiMessage } from '@/utils/ui'
import {
  formatCustomerPickerLabel,
  pickMainNurseEmployees,
} from '@/views/customer/customer-format'

const visible = defineModel<boolean>({ default: false })

const props = defineProps<{
  customerId: number | null
}>()

const emit = defineEmits<{
  success: []
}>()

const loading = ref(false)
const saving = ref(false)
const loadError = ref<string | null>(null)

const sourceName = ref('—')
const levelName = ref('—')
const introducerLabel = ref('—')
const nurseOptions = ref<{ id: string; name: string }[]>([])

const form = reactive({
  name: '',
  mobile: '',
  gender: '0',
  birthday: '' as string,
  nurseEmployeeId: '' as string,
})

const initialSnapshot = ref('')

function snapshotOfForm(): string {
  return JSON.stringify({
    name: form.name.trim(),
    mobile: form.mobile.trim(),
    gender: form.gender,
    birthday: form.birthday || null,
    nurseEmployeeId: form.nurseEmployeeId || null,
  })
}

function resetForm(): void {
  form.name = ''
  form.mobile = ''
  form.gender = '0'
  form.birthday = ''
  form.nurseEmployeeId = ''
  sourceName.value = '—'
  levelName.value = '—'
  introducerLabel.value = '—'
  nurseOptions.value = []
  initialSnapshot.value = ''
  loadError.value = null
}

async function loadDetail(): Promise<void> {
  if (props.customerId == null) {
    loadError.value = '客户 ID 无效'
    return
  }
  await runExclusive(loading, async () => {
    loadError.value = null
    try {
      const detail = await fetchCustomerDetail(props.customerId!)
      form.name = detail.name ?? ''
      form.mobile = detail.mobile ?? ''
      form.gender = detail.gender || '0'
      form.birthday = detail.birthday ? detail.birthday.slice(0, 10) : ''
      form.nurseEmployeeId = detail.nurseEmployeeId ?? ''
      sourceName.value = detail.sourceName || '—'
      levelName.value = detail.levelName || '—'
      initialSnapshot.value = snapshotOfForm()

      try {
        const keyword = detail.code?.trim() || detail.mobile?.trim() || detail.name?.trim() || ''
        const listItem = await findCustomerListItemById(detail.id, keyword)
        if (listItem?.introducerName) {
          introducerLabel.value = formatCustomerPickerLabel({
            name: listItem.introducerName,
            mobile: null,
            code: null,
          })
        } else if (listItem?.introducerCustomerId != null) {
          introducerLabel.value = `客户#${listItem.introducerCustomerId}`
        } else {
          introducerLabel.value = '—'
        }
      } catch {
        introducerLabel.value = '—'
      }

      try {
        const roles = await fetchServicerOptions()
        nurseOptions.value = pickMainNurseEmployees(roles).map((emp) => ({
          id: emp.id,
          name: emp.name?.trim() || emp.id,
        }))
        if (
          form.nurseEmployeeId &&
          !nurseOptions.value.some((item) => item.id === form.nurseEmployeeId)
        ) {
          nurseOptions.value.unshift({
            id: form.nurseEmployeeId,
            name: detail.nurseName?.trim() || form.nurseEmployeeId,
          })
        }
      } catch {
        if (form.nurseEmployeeId) {
          nurseOptions.value = [
            {
              id: form.nurseEmployeeId,
              name: detail.nurseName?.trim() || form.nurseEmployeeId,
            },
          ]
        }
      }
    } catch (error) {
      loadError.value = getUserFriendlyErrorMessage(error)
      notifyError(error)
    }
  })
}

async function handleSubmit(): Promise<void> {
  if (props.customerId == null) {
    return
  }
  if (!form.name.trim() || !form.mobile.trim()) {
    uiMessage.warning('请填写姓名和手机号')
    return
  }
  const nextSnapshot = snapshotOfForm()
  if (nextSnapshot === initialSnapshot.value) {
    uiMessage.info('没有修改内容')
    return
  }
  await runExclusive(saving, async () => {
    try {
      // 故意不传 sourceId，首次来源不可改
      // UpdateCustomerCommand 不含 introducerCustomerId，介绍人不可通过本页修改
      // 详情 VO 无 remark/address，本轮不提交这两项，避免误清空
      await updateCustomer(props.customerId!, {
        name: form.name.trim(),
        mobile: form.mobile.trim(),
        gender: form.gender,
        birthday: form.birthday || null,
        nurseEmployeeId: form.nurseEmployeeId,
      })
      uiMessage.success('保存成功')
      initialSnapshot.value = nextSnapshot
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
  void loadDetail()
})
</script>

<template>
  <el-dialog
    v-model="visible"
    title="编辑客户"
    width="560px"
    destroy-on-close
    :close-on-click-modal="false"
    @closed="resetForm"
  >
    <AppError
      v-if="loadError && !loading"
      :description="loadError"
      @retry="loadDetail"
    />
    <el-form
      v-else
      v-loading="loading"
      label-width="100px"
      @submit.prevent
    >
      <el-form-item label="首次来源">
        <span class="readonly">{{ sourceName }}</span>
        <span class="hint">写入后不可修改</span>
      </el-form-item>
      <el-form-item label="介绍人">
        <span class="readonly">{{ introducerLabel }}</span>
        <span class="hint">后端暂不支持修改</span>
      </el-form-item>
      <el-form-item label="会员等级">
        <span class="readonly">{{ levelName }}</span>
        <span class="hint">不可通过本页修改</span>
      </el-form-item>
      <el-form-item label="姓名" required>
        <el-input v-model="form.name" maxlength="50" />
      </el-form-item>
      <el-form-item label="手机号" required>
        <el-input v-model="form.mobile" maxlength="20" />
      </el-form-item>
      <el-form-item label="性别">
        <el-radio-group v-model="form.gender">
          <el-radio value="1">男</el-radio>
          <el-radio value="2">女</el-radio>
          <el-radio value="0">未知</el-radio>
        </el-radio-group>
      </el-form-item>
      <el-form-item label="主护理师">
        <el-select
          v-model="form.nurseEmployeeId"
          clearable
          filterable
          placeholder="可选，清空表示取消主护理师"
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
    </el-form>

    <template #footer>
      <el-button :disabled="saving" @click="handleClose">取消</el-button>
      <el-button type="primary" :loading="saving" @click="handleSubmit">保存</el-button>
    </template>
  </el-dialog>
</template>

<style scoped>
.readonly {
  color: #303133;
  font-size: 14px;
}

.hint {
  margin-left: 12px;
  color: #909399;
  font-size: 12px;
}
</style>
