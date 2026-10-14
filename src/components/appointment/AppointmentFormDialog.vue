<script setup lang="ts">
import { computed, reactive, ref, watch } from 'vue'

import AppError from '@/components/common/AppError.vue'
import SaleCustomerSelector from '@/components/sale/SaleCustomerSelector.vue'
import CustomerCreateDialog from '@/views/customer/CustomerCreateDialog.vue'
import {
  createAppointment,
  fetchAppointmentDetail,
  fetchAppointmentEmployees,
  fetchAppointmentTypes,
  fetchSameDayAppointments,
  updateAppointment,
} from '@/api/appointment'
import { fetchCustomerPage } from '@/api/customer'
import { fetchProjectPage } from '@/api/project'
import type {
  AppointmentDetail,
  AppointmentEmployeeOption,
  AppointmentItem,
  AppointmentTypeItem,
} from '@/types/appointment'
import type { CustomerListItem } from '@/types/customer'
import type { ProjectItem } from '@/types/project'
import { ProjectPermission } from '@/types/project'
import { usePermissionStore } from '@/stores/permission'
import { useStoreStore } from '@/stores/store'
import {
  getUserFriendlyErrorMessage,
  runExclusive,
  uiMessage,
} from '@/utils/ui'

defineOptions({ name: 'AppointmentFormDialog' })

const visible = defineModel<boolean>({ default: false })

const props = defineProps<{
  appointmentId?: string | null
  defaultDate?: string | null
  defaultEmployeeId?: string | null
  defaultStartTime?: string | null
}>()

const emit = defineEmits<{
  success: [id: string]
}>()

const permissionStore = usePermissionStore()
const storeStore = useStoreStore()

const loading = ref(false)
const saving = ref(false)
const loadError = ref<string | null>(null)

const employeeOptions = ref<AppointmentEmployeeOption[]>([])
const projectOptions = ref<ProjectItem[]>([])
const typeOptions = ref<AppointmentTypeItem[]>([])
const projectLoading = ref(false)
const customerSearching = ref(false)

const customerSelectorVisible = ref(false)
const createCustomerVisible = ref(false)
const createPrefillMobile = ref('')

const editing = ref<AppointmentDetail | null>(null)
const sameDayTips = ref<AppointmentItem[]>([])

const mobileKeyword = ref('')

const form = reactive({
  customerId: null as number | null,
  customerName: '',
  customerMobile: '',
  employeeId: '' as string,
  projectIds: [] as number[],
  appointmentTypeId: null as number | null,
  date: '' as string,
  startTime: '' as string,
  durationMinutes: 60 as number,
  remark: '',
})

const isEdit = computed(() => !!props.appointmentId)
const title = computed(() => (isEdit.value ? '编辑预约' : '新增预约'))

const selectedProjects = computed(() =>
  form.projectIds
    .map((id) => projectOptions.value.find((p) => p.id === id))
    .filter((p): p is ProjectItem => p != null),
)

const autoDuration = computed(() => {
  if (selectedProjects.value.length === 0) {
    return form.durationMinutes > 0 ? form.durationMinutes : 60
  }
  const sum = selectedProjects.value.reduce((acc, p) => {
    const t = p.treatTime
    if (t != null && Number.isFinite(t) && t > 0) return acc + t
    return acc + 60
  }, 0)
  return sum > 0 ? sum : 60
})

const endTimeLabel = computed(() => {
  if (!form.date || !form.startTime || !form.durationMinutes) return '—'
  const start = parseLocalDateTime(`${form.date}T${normalizeTime(form.startTime)}:00`)
  if (!start) return '—'
  const end = new Date(start.getTime() + form.durationMinutes * 60_000)
  return formatHm(end)
})

function normalizeTime(raw: string): string {
  const t = raw.trim()
  if (/^\d{2}:\d{2}$/.test(t)) return t
  if (/^\d{2}:\d{2}:\d{2}$/.test(t)) return t.slice(0, 5)
  return t
}

function parseLocalDateTime(isoLike: string): Date | null {
  const m = isoLike.match(/^(\d{4})-(\d{2})-(\d{2})[T ](\d{2}):(\d{2})(?::(\d{2}))?/)
  if (!m) return null
  const d = new Date(
    Number(m[1]),
    Number(m[2]) - 1,
    Number(m[3]),
    Number(m[4]),
    Number(m[5]),
    Number(m[6] ?? 0),
  )
  return Number.isNaN(d.getTime()) ? null : d
}

function formatHm(d: Date): string {
  return `${String(d.getHours()).padStart(2, '0')}:${String(d.getMinutes()).padStart(2, '0')}`
}

function formatDateYmd(d: Date): string {
  return `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, '0')}-${String(d.getDate()).padStart(2, '0')}`
}

function todayYmd(): string {
  return formatDateYmd(new Date())
}

function resetForm(): void {
  editing.value = null
  loadError.value = null
  sameDayTips.value = []
  mobileKeyword.value = ''
  createPrefillMobile.value = ''
  form.customerId = null
  form.customerName = ''
  form.customerMobile = ''
  form.employeeId = props.defaultEmployeeId?.trim() || ''
  form.projectIds = []
  form.appointmentTypeId = null
  form.date = props.defaultDate?.trim() || todayYmd()
  form.startTime = props.defaultStartTime?.trim() || '10:00'
  form.durationMinutes = 60
  form.remark = ''
}

function applyDetail(detail: AppointmentDetail): void {
  editing.value = detail
  form.customerId = detail.customerId
  form.customerName = detail.customerName?.trim() || ''
  form.customerMobile = detail.customerMobile?.trim() || ''
  mobileKeyword.value = form.customerMobile || form.customerName
  form.employeeId = detail.employeeId?.trim() || ''
  form.appointmentTypeId = detail.appointmentTypeId ?? null
  const ids = (detail.projects ?? [])
    .map((p) => p.projectId)
    .filter((id): id is number => id != null && id > 0)
  form.projectIds =
    ids.length > 0 ? ids : detail.projectId != null ? [detail.projectId] : []
  const start = detail.startDateTime ? parseLocalDateTime(detail.startDateTime) : null
  form.date = start ? formatDateYmd(start) : props.defaultDate?.trim() || todayYmd()
  form.startTime = start ? formatHm(start) : '10:00'
  form.durationMinutes =
    detail.durationMinutes != null && detail.durationMinutes > 0
      ? detail.durationMinutes
      : 60
  form.remark = detail.remark?.trim() || ''
}

async function loadEmployees(): Promise<void> {
  employeeOptions.value = await fetchAppointmentEmployees(
    storeStore.currentStoreId ?? undefined,
  )
}

async function loadTypes(): Promise<void> {
  typeOptions.value = await fetchAppointmentTypes()
  if (!isEdit.value && form.appointmentTypeId == null && typeOptions.value.length > 0) {
    form.appointmentTypeId = typeOptions.value[0].id
  }
}

async function loadProjects(keyword?: string): Promise<void> {
  if (!permissionStore.hasPermission(ProjectPermission.VIEW)) {
    projectOptions.value = []
    return
  }
  await runExclusive(projectLoading, async () => {
    const data = await fetchProjectPage({
      page: 1,
      size: 100,
      keyword: keyword?.trim() || undefined,
      consumable: true,
    })
    projectOptions.value = data.records ?? []
  })
}

async function refreshSameDayTips(): Promise<void> {
  sameDayTips.value = []
  if (form.customerId == null || !form.date) return
  try {
    sameDayTips.value = await fetchSameDayAppointments({
      storeId: storeStore.currentStoreId ?? undefined,
      customerId: form.customerId,
      date: form.date,
      excludeId: props.appointmentId ?? undefined,
    })
  } catch {
    sameDayTips.value = []
  }
}

async function loadForOpen(): Promise<void> {
  resetForm()
  await runExclusive(loading, async () => {
    loadError.value = null
    try {
      await Promise.all([loadEmployees(), loadProjects(), loadTypes()])
      if (props.appointmentId) {
        const detail = await fetchAppointmentDetail(props.appointmentId)
        applyDetail(detail)
      } else {
        const raw = sessionStorage.getItem('appt.invite.customer')
        if (raw) {
          try {
            const c = JSON.parse(raw) as {
              id?: number
              name?: string | null
              mobile?: string | null
            }
            if (c.id != null) {
              form.customerId = c.id
              form.customerName = c.name?.trim() || ''
              form.customerMobile = c.mobile?.trim() || ''
              mobileKeyword.value = form.customerMobile || form.customerName
            }
          } catch {
            /* ignore */
          } finally {
            sessionStorage.removeItem('appt.invite.customer')
          }
        }
      }
      await refreshSameDayTips()
    } catch (error) {
      loadError.value = getUserFriendlyErrorMessage(error)
    }
  })
}

function onProjectChange(): void {
  if (form.projectIds.length > 0) {
    form.durationMinutes = autoDuration.value
  }
}

function onSelectCustomer(customer: CustomerListItem): void {
  form.customerId = customer.id
  form.customerName = customer.name?.trim() || ''
  form.customerMobile = customer.mobile?.trim() || ''
  mobileKeyword.value = form.customerMobile || form.customerName
  void refreshSameDayTips()
}

function onCreatedCustomer(customer: {
  id: number
  name: string | null
  mobile: string | null
}): void {
  form.customerId = customer.id
  form.customerName = customer.name?.trim() || ''
  form.customerMobile = customer.mobile?.trim() || ''
  mobileKeyword.value = form.customerMobile || form.customerName
  void refreshSameDayTips()
}

async function searchCustomerByMobile(): Promise<void> {
  const kw = mobileKeyword.value.trim()
  if (!kw) {
    uiMessage.warning('请输入手机号或姓名搜索')
    return
  }
  await runExclusive(customerSearching, async () => {
    try {
      const page = await fetchCustomerPage({ page: 1, size: 20, keyword: kw })
      const records = page.records ?? []
      if (records.length === 1) {
        onSelectCustomer(records[0])
        return
      }
      if (records.length > 1) {
        customerSelectorVisible.value = true
        return
      }
      // 无匹配：若像手机号则 Enter 打开快登
      if (/^\d{7,15}$/.test(kw)) {
        createPrefillMobile.value = kw
        createCustomerVisible.value = true
      } else {
        uiMessage.warning('未找到客户，可点击快速创建')
      }
    } catch (e) {
      uiMessage.error(getUserFriendlyErrorMessage(e))
    }
  })
}

function onMobileEnter(): void {
  void searchCustomerByMobile()
}

function buildStartTimePayload(): string {
  return `${form.date.trim()}T${normalizeTime(form.startTime)}:00`
}

async function handleSubmit(): Promise<void> {
  const storeId = storeStore.currentStoreId
  if (storeId == null) {
    uiMessage.warning('请先选择门店')
    return
  }
  if (form.customerId == null) {
    uiMessage.warning('请选择顾客')
    return
  }
  if (!form.employeeId) {
    uiMessage.warning('请选择护理师')
    return
  }
  if (!form.date || !form.startTime) {
    uiMessage.warning('请填写日期与开始时间')
    return
  }
  if (!form.durationMinutes || form.durationMinutes <= 0) {
    uiMessage.warning('请填写有效时长（未选项目时必须手工填写）')
    return
  }

  await runExclusive(saving, async () => {
    try {
      const startTime = buildStartTimePayload()
      if (isEdit.value && props.appointmentId) {
        const updated = await updateAppointment(props.appointmentId, {
          customerId: form.customerId,
          projectIds: [...form.projectIds],
          employeeId: form.employeeId,
          startTime,
          durationMinutes: form.durationMinutes,
          appointmentTypeId: form.appointmentTypeId,
          remark: form.remark.trim() || null,
          version: editing.value?.version ?? null,
        })
        uiMessage.success('预约已更新')
        visible.value = false
        emit('success', updated.id)
        return
      }
      const created = await createAppointment({
        customerId: form.customerId!,
        storeId,
        projectIds: [...form.projectIds],
        employeeId: form.employeeId,
        startTime,
        durationMinutes: form.durationMinutes,
        appointmentTypeId: form.appointmentTypeId,
        remark: form.remark.trim() || null,
      })
      uiMessage.success('预约已创建')
      visible.value = false
      emit('success', created.id)
    } catch (error) {
      uiMessage.error(getUserFriendlyErrorMessage(error))
    }
  })
}

watch(visible, (open) => {
  if (!open) {
    resetForm()
    return
  }
  void loadForOpen()
})

watch(
  () => [form.customerId, form.date] as const,
  () => {
    if (visible.value) void refreshSameDayTips()
  },
)
</script>

<template>
  <el-dialog
    v-model="visible"
    :title="title"
    width="680px"
    destroy-on-close
    :close-on-click-modal="false"
  >
    <AppError
      v-if="loadError && !loading"
      :description="loadError"
      @retry="loadForOpen"
    />
    <el-form v-else v-loading="loading" label-width="100px" @submit.prevent>
      <el-alert
        v-if="sameDayTips.length > 0"
        type="warning"
        :closable="false"
        show-icon
        class="same-day-tip"
        :title="`该顾客当日已有 ${sameDayTips.length} 条其他预约（不禁止继续登记）`"
      >
        <div v-for="tip in sameDayTips.slice(0, 3)" :key="tip.id" class="tip-line">
          {{ (tip.startDateTime || '').replace('T', ' ').slice(0, 16) }}
          · {{ tip.employeeName || tip.employeeId || '护理师' }}
          · {{ tip.statusName || tip.status }}
        </div>
      </el-alert>

      <el-form-item label="顾客" required>
        <div class="customer-row">
          <el-input
            v-model="mobileKeyword"
            :disabled="isEdit"
            clearable
            placeholder="输入手机号搜索，无匹配按 Enter 快速建客"
            @keyup.enter="onMobileEnter"
          />
          <el-button
            :loading="customerSearching"
            :disabled="isEdit"
            @click="searchCustomerByMobile"
          >
            搜索
          </el-button>
          <el-button :disabled="isEdit" @click="customerSelectorVisible = true">
            选客
          </el-button>
          <el-button
            :disabled="isEdit"
            @click="
              () => {
                createPrefillMobile = mobileKeyword.trim()
                createCustomerVisible = true
              }
            "
          >
            快速创建
          </el-button>
        </div>
        <div v-if="form.customerId" class="customer-picked">
          已选：{{ form.customerName || '未命名' }}
          <span v-if="form.customerMobile">（{{ form.customerMobile }}）</span>
        </div>
      </el-form-item>

      <el-form-item label="预约类型">
        <el-select
          v-model="form.appointmentTypeId"
          clearable
          placeholder="可选"
          style="width: 100%"
        >
          <el-option
            v-for="t in typeOptions"
            :key="t.id"
            :label="t.name || String(t.id)"
            :value="t.id"
          />
        </el-select>
      </el-form-item>

      <el-form-item label="护理师" required>
        <el-select
          v-model="form.employeeId"
          filterable
          clearable
          placeholder="请选择护理师"
          style="width: 100%"
        >
          <el-option
            v-for="emp in employeeOptions"
            :key="emp.employeeId"
            :label="emp.employeeName || emp.employeeId"
            :value="emp.employeeId"
          />
        </el-select>
      </el-form-item>

      <el-form-item label="项目">
        <el-select
          v-model="form.projectIds"
          multiple
          filterable
          collapse-tags
          collapse-tags-tooltip
          clearable
          placeholder="可选；可零个，到店后再定项目（不显示价格）"
          style="width: 100%"
          :loading="projectLoading"
          @change="onProjectChange"
        >
          <el-option
            v-for="p in projectOptions"
            :key="p.id"
            :label="`${p.name || p.id}${p.treatTime ? `（${p.treatTime}分）` : ''}`"
            :value="p.id"
          />
        </el-select>
      </el-form-item>

      <el-form-item label="日期" required>
        <el-date-picker
          v-model="form.date"
          type="date"
          value-format="YYYY-MM-DD"
          style="width: 100%"
        />
      </el-form-item>

      <el-form-item label="开始时间" required>
        <el-time-select
          v-model="form.startTime"
          start="08:00"
          step="00:15"
          end="22:00"
          style="width: 100%"
        />
      </el-form-item>

      <el-form-item label="时长(分钟)" required>
        <el-input-number
          v-model="form.durationMinutes"
          :min="15"
          :max="480"
          :step="15"
        />
        <span class="hint">
          {{
            form.projectIds.length
              ? `默认累加 ${autoDuration} 分，可改`
              : '未选项目请手工填写时长'
          }}
        </span>
      </el-form-item>

      <el-form-item label="结束时间">
        <span>{{ endTimeLabel }}</span>
      </el-form-item>

      <el-form-item label="备注">
        <el-input
          v-model="form.remark"
          type="textarea"
          :rows="2"
          maxlength="200"
          show-word-limit
        />
      </el-form-item>
    </el-form>

    <template #footer>
      <el-button @click="visible = false">取消</el-button>
      <el-button type="primary" :loading="saving" :disabled="!!loadError" @click="handleSubmit">
        保存
      </el-button>
    </template>

    <SaleCustomerSelector v-model="customerSelectorVisible" @select="onSelectCustomer" />
    <CustomerCreateDialog
      v-model="createCustomerVisible"
      :default-mobile="createPrefillMobile"
      @created="onCreatedCustomer"
    />
  </el-dialog>
</template>

<style scoped>
.same-day-tip {
  margin-bottom: 12px;
}
.tip-line {
  font-size: 12px;
  line-height: 1.6;
}
.customer-row {
  display: flex;
  gap: 8px;
  width: 100%;
  align-items: center;
}
.customer-row :deep(.el-input) {
  flex: 1;
}
.customer-picked {
  margin-top: 6px;
  font-size: 12px;
  color: #606266;
}
.hint {
  margin-left: 10px;
  color: #909399;
  font-size: 12px;
}
</style>
