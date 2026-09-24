<script setup lang="ts">
import { computed, reactive, ref, watch } from 'vue'

import AppError from '@/components/common/AppError.vue'
import { createAppointment, fetchAvailableSlots } from '@/api/appointment'
import { fetchServicerOptions } from '@/api/customer'
import { fetchProjectPage } from '@/api/project'
import type { AvailableSlotItem } from '@/types/appointment'
import type { ProjectItem } from '@/types/project'
import { useStoreStore } from '@/stores/store'
import {
  getUserFriendlyErrorMessage,
  notifyError,
  runExclusive,
  uiMessage,
} from '@/utils/ui'

defineOptions({ name: 'CustomerAppointmentCreateDialog' })

const visible = defineModel<boolean>({ default: false })

const props = defineProps<{
  customerId: number | null
  customerName: string
}>()

const emit = defineEmits<{
  success: []
}>()

const storeStore = useStoreStore()

const loadingOptions = ref(false)
const loadingSlots = ref(false)
const saving = ref(false)
const optionsError = ref<string | null>(null)
const slotsError = ref<string | null>(null)

const projectOptions = ref<ProjectItem[]>([])
const slots = ref<AvailableSlotItem[]>([])
/** 仅用于展示姓名；可选护理师集合来自 available-slots */
const employeeNameMap = ref<Record<string, string>>({})

const form = reactive({
  projectId: undefined as number | undefined,
  date: '' as string,
  startTime: '' as string,
  employeeId: '' as string,
  remark: '',
})

const selectedProject = computed(() =>
  projectOptions.value.find((item) => item.id === form.projectId) ?? null,
)

const selectedSlot = computed(() =>
  slots.value.find((item) => item.startDateTime === form.startTime) ?? null,
)

const startTimeOptions = computed(() =>
  slots.value.map((slot) => ({
    value: slot.startDateTime,
    label: formatSlotLabel(slot),
  })),
)

const employeeOptions = computed(() => {
  const ids = selectedSlot.value?.employeeIds ?? []
  return ids.map((id) => ({
    id,
    name: employeeNameMap.value[id]?.trim() || id,
  }))
})

const durationHint = computed(() => {
  const treatTime = selectedProject.value?.treatTime
  if (treatTime != null && Number.isFinite(treatTime)) {
    return `${treatTime} 分钟（取自项目）`
  }
  const slot = selectedSlot.value
  if (slot?.startDateTime && slot?.endDateTime) {
    return formatSlotRange(slot)
  }
  return '—'
})

const endTimeHint = computed(() => {
  const end = selectedSlot.value?.endDateTime
  return end ? formatDateTimeLocal(end) : '—'
})

const customerLabel = computed(() => {
  const name = props.customerName?.trim()
  if (name) {
    return `${name}（ID: ${props.customerId ?? '—'}）`
  }
  return props.customerId != null ? `客户 ID: ${props.customerId}` : '—'
})

const storeLabel = computed(() => {
  const name = storeStore.currentStoreName?.trim()
  const id = storeStore.currentStoreId
  if (name && id != null) {
    return `${name}（ID: ${id}）`
  }
  if (id != null) {
    return `门店 ID: ${id}`
  }
  return '未选择门店'
})

function pad2(n: number): string {
  return n < 10 ? `0${n}` : String(n)
}

function todayIsoDate(): string {
  const now = new Date()
  return `${now.getFullYear()}-${pad2(now.getMonth() + 1)}-${pad2(now.getDate())}`
}

function formatDateTimeLocal(value: string): string {
  const normalized = value.includes('T') ? value : value.replace(' ', 'T')
  const match = normalized.match(/^(\d{4}-\d{2}-\d{2})T(\d{2}:\d{2})/)
  if (match) {
    return `${match[1]} ${match[2]}`
  }
  return value
}

function formatSlotLabel(slot: AvailableSlotItem): string {
  return `${formatDateTimeLocal(slot.startDateTime)} ~ ${formatDateTimeLocal(slot.endDateTime)}`
}

function formatSlotRange(slot: AvailableSlotItem): string {
  return formatSlotLabel(slot)
}

function toSubmitStartTime(value: string): string {
  // 后端 LocalDateTime：保留到秒
  const normalized = value.includes('T') ? value : value.replace(' ', 'T')
  if (/^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}$/.test(normalized)) {
    return `${normalized}:00`
  }
  if (/^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}/.test(normalized)) {
    return normalized.slice(0, 19)
  }
  return normalized
}

function resetForm(): void {
  form.projectId = undefined
  form.date = todayIsoDate()
  form.startTime = ''
  form.employeeId = ''
  form.remark = ''
  projectOptions.value = []
  slots.value = []
  employeeNameMap.value = {}
  optionsError.value = null
  slotsError.value = null
}

function buildEmployeeNameMap(
  roles: Awaited<ReturnType<typeof fetchServicerOptions>>,
): Record<string, string> {
  const map: Record<string, string> = {}
  for (const role of roles) {
    const list = role.servicerEmpList ?? []
    for (const emp of list) {
      if (emp.id && !map[emp.id]) {
        map[emp.id] = emp.name?.trim() || emp.id
      }
    }
  }
  return map
}

async function loadOptions(): Promise<void> {
  loadingOptions.value = true
  optionsError.value = null
  try {
    const [projectsPage, roles] = await Promise.all([
      fetchProjectPage({ page: 1, size: 100 }),
      fetchServicerOptions().catch(() => []),
    ])
    projectOptions.value = projectsPage.records ?? []
    employeeNameMap.value = buildEmployeeNameMap(roles)
  } catch (error) {
    projectOptions.value = []
    optionsError.value = getUserFriendlyErrorMessage(error)
    notifyError(error)
  } finally {
    loadingOptions.value = false
  }
}

async function loadSlots(): Promise<void> {
  slots.value = []
  form.startTime = ''
  form.employeeId = ''
  slotsError.value = null

  if (form.projectId == null || !form.date) {
    return
  }
  const storeId = storeStore.currentStoreId
  if (storeId == null) {
    slotsError.value = '请先选择当前门店'
    return
  }

  loadingSlots.value = true
  try {
    const data = await fetchAvailableSlots({
      storeId,
      date: form.date,
      projectId: form.projectId,
    })
    slots.value = data
    if (data.length === 0) {
      slotsError.value = '该日期暂无可用时段，请更换日期或项目'
    }
  } catch (error) {
    slots.value = []
    slotsError.value = getUserFriendlyErrorMessage(error)
    notifyError(error)
  } finally {
    loadingSlots.value = false
  }
}

function handleProjectChange(): void {
  void loadSlots()
}

function handleDateChange(): void {
  void loadSlots()
}

function handleStartTimeChange(): void {
  form.employeeId = ''
  const opts = employeeOptions.value
  if (opts.length === 1) {
    form.employeeId = opts[0].id
  }
}

async function handleSubmit(): Promise<void> {
  if (props.customerId == null) {
    uiMessage.warning('客户无效')
    return
  }
  const storeId = storeStore.currentStoreId
  if (storeId == null) {
    uiMessage.warning('请先选择当前门店')
    return
  }
  if (form.projectId == null) {
    uiMessage.warning('请选择项目')
    return
  }
  if (!form.date) {
    uiMessage.warning('请选择预约日期')
    return
  }
  if (!form.startTime) {
    uiMessage.warning('请选择开始时间')
    return
  }
  if (!form.employeeId) {
    uiMessage.warning('请选择护理师')
    return
  }

  await runExclusive(saving, async () => {
    try {
      await createAppointment({
        customerId: props.customerId!,
        storeId,
        projectId: form.projectId!,
        employeeId: form.employeeId,
        startTime: toSubmitStartTime(form.startTime),
        remark: form.remark.trim() || null,
      })
      uiMessage.success('预约创建成功')
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
    title="创建预约"
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
      v-loading="loadingOptions || loadingSlots"
      label-width="100px"
      @submit.prevent
    >
      <el-form-item label="客户" required>
        <el-input :model-value="customerLabel" disabled />
      </el-form-item>
      <el-form-item label="门店" required>
        <el-input :model-value="storeLabel" disabled />
      </el-form-item>
      <el-form-item label="项目" required>
        <el-select
          v-model="form.projectId"
          filterable
          clearable
          placeholder="请选择项目"
          style="width: 100%"
          @change="handleProjectChange"
        >
          <el-option
            v-for="item in projectOptions"
            :key="item.id"
            :label="item.name || `项目#${item.id}`"
            :value="item.id"
          >
            <span>{{ item.name || `项目#${item.id}` }}</span>
            <span v-if="item.treatTime != null" style="float: right; color: var(--el-text-color-secondary)">
              {{ item.treatTime }}分钟
            </span>
          </el-option>
        </el-select>
        <div v-if="!loadingOptions && projectOptions.length === 0" class="field-hint is-error">
          暂无可选项目，请先在项目管理中维护
        </div>
      </el-form-item>
      <el-form-item label="预约日期" required>
        <el-date-picker
          v-model="form.date"
          type="date"
          value-format="YYYY-MM-DD"
          placeholder="选择日期"
          style="width: 100%"
          @change="handleDateChange"
        />
      </el-form-item>
      <el-form-item label="开始时间" required>
        <el-select
          v-model="form.startTime"
          filterable
          clearable
          placeholder="请先选择项目与日期"
          style="width: 100%"
          :disabled="form.projectId == null || !form.date"
          @change="handleStartTimeChange"
        >
          <el-option
            v-for="item in startTimeOptions"
            :key="item.value"
            :label="item.label"
            :value="item.value"
          />
        </el-select>
        <div v-if="slotsError" class="field-hint is-error">{{ slotsError }}</div>
      </el-form-item>
      <el-form-item label="结束时间">
        <el-input :model-value="endTimeHint" disabled />
      </el-form-item>
      <el-form-item label="时长">
        <el-input :model-value="durationHint" disabled />
      </el-form-item>
      <el-form-item label="护理师" required>
        <el-select
          v-model="form.employeeId"
          filterable
          clearable
          placeholder="请先选择开始时间"
          style="width: 100%"
          :disabled="!form.startTime"
        >
          <el-option
            v-for="item in employeeOptions"
            :key="item.id"
            :label="item.name"
            :value="item.id"
          />
        </el-select>
      </el-form-item>
      <el-form-item label="备注">
        <el-input
          v-model="form.remark"
          type="textarea"
          :rows="2"
          maxlength="200"
          show-word-limit
          placeholder="选填"
        />
      </el-form-item>
    </el-form>

    <template #footer>
      <el-button :disabled="saving" @click="handleClose">取消</el-button>
      <el-button
        type="primary"
        :loading="saving"
        :disabled="loadingOptions || !!optionsError"
        @click="handleSubmit"
      >
        确认预约
      </el-button>
    </template>
  </el-dialog>
</template>

<style scoped>
.field-hint {
  margin-top: 4px;
  font-size: 12px;
  line-height: 1.4;
  color: var(--el-text-color-secondary);
}

.field-hint.is-error {
  color: var(--el-color-danger);
}
</style>
