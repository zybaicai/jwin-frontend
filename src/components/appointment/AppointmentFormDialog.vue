<script setup lang="ts">
import { computed, reactive, ref, watch } from 'vue'
import { View } from '@element-plus/icons-vue'
import { ElMessageBox } from 'element-plus'

import AppError from '@/components/common/AppError.vue'
import AppointmentProjectPickerDialog from '@/components/appointment/AppointmentProjectPickerDialog.vue'
import CustomerCreateDialog from '@/views/customer/CustomerCreateDialog.vue'
import CustomerDetailDrawer from '@/views/customer/CustomerDetailDrawer.vue'
import CustomerServiceLog from '@/views/customer/CustomerServiceLog.vue'
import {
  createAppointment,
  fetchAppointmentDetail,
  fetchAppointmentEmployees,
  fetchAppointmentTypes,
  fetchSameDayAppointments,
  updateAppointment,
} from '@/api/appointment'
import { fetchCustomerDetail, fetchCustomerPage } from '@/api/customer'
import type {
  AppointmentDetail,
  AppointmentEmployeeOption,
  AppointmentItem,
  AppointmentTypeItem,
} from '@/types/appointment'
import type { CustomerListItem } from '@/types/customer'
import { useStoreStore } from '@/stores/store'
import {
  getUserFriendlyErrorMessage,
  runExclusive,
  uiMessage,
} from '@/utils/ui'
import { maskMobile } from '@/views/customer/customer-format'

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

const storeStore = useStoreStore()

const loading = ref(false)
const saving = ref(false)
const loadError = ref<string | null>(null)
const dirty = ref(false)
const allowClose = ref(false)

const employeeOptions = ref<AppointmentEmployeeOption[]>([])
const typeOptions = ref<AppointmentTypeItem[]>([])
const createCustomerVisible = ref(false)
const createPrefillMobile = ref('')
const detailDrawerVisible = ref(false)
const projectPickerVisible = ref(false)

const editing = ref<AppointmentDetail | null>(null)
const sameDayTips = ref<AppointmentItem[]>([])

const customerKeyword = ref('')
const customerDropdownVisible = ref(false)
const customerSearching = ref(false)
const customerSearchLoadingMore = ref(false)
const customerSearchResults = ref<CustomerListItem[]>([])
const customerSearchPage = ref(1)
const customerSearchHasMore = ref(false)
let customerSearchTimer: ReturnType<typeof setTimeout> | null = null
let customerSearchSeq = 0
const CUSTOMER_PAGE_SIZE = 15

const selectedProjects = ref<Array<{ id: number; name: string; treatTime: number | null }>>([])
const customerLevelName = ref<string | null>(null)

const form = reactive({
  customerId: null as number | null,
  customerName: '',
  customerMobile: '',
  employeeId: '' as string,
  appointmentTypeId: null as number | null,
  date: '' as string,
  startTime: '' as string,
  durationMinutes: 60 as number,
  remark: '',
})

const isEdit = computed(() => !!props.appointmentId)
const title = computed(() => (isEdit.value ? '编辑预约' : '添加预约'))
const isMember = computed(
  () => form.customerId != null && !!customerLevelName.value?.trim(),
)

const autoDuration = computed(() => {
  if (selectedProjects.value.length === 0) {
    return form.durationMinutes > 0 ? form.durationMinutes : 60
  }
  const sum = selectedProjects.value.reduce(
    (acc, p) => acc + (p.treatTime != null && p.treatTime > 0 ? p.treatTime : 60),
    0,
  )
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

function markDirty(): void {
  dirty.value = true
}

function resetForm(): void {
  editing.value = null
  loadError.value = null
  sameDayTips.value = []
  customerKeyword.value = ''
  createPrefillMobile.value = ''
  customerLevelName.value = null
  selectedProjects.value = []
  customerSearchResults.value = []
  customerDropdownVisible.value = false
  dirty.value = false
  allowClose.value = false
  form.customerId = null
  form.customerName = ''
  form.customerMobile = ''
  form.employeeId = props.defaultEmployeeId?.trim() || ''
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
  customerKeyword.value = ''
  form.employeeId = detail.employeeId?.trim() || ''
  form.appointmentTypeId = detail.appointmentTypeId ?? null
  selectedProjects.value = (detail.projects ?? [])
    .filter((p) => p.projectId != null)
    .map((p) => ({
      id: p.projectId!,
      name: p.projectName?.trim() || `项目#${p.projectId}`,
      treatTime: p.durationMinutes ?? null,
    }))
  if (
    selectedProjects.value.length === 0 &&
    detail.projectId != null &&
    detail.projectNameSnapshot
  ) {
    selectedProjects.value = [
      {
        id: detail.projectId,
        name: detail.projectNameSnapshot,
        treatTime: detail.durationMinutes ?? null,
      },
    ]
  }
  const start = detail.startDateTime ? parseLocalDateTime(detail.startDateTime) : null
  form.date = start ? formatDateYmd(start) : props.defaultDate?.trim() || todayYmd()
  form.startTime = start ? formatHm(start) : '10:00'
  form.durationMinutes =
    detail.durationMinutes != null && detail.durationMinutes > 0
      ? detail.durationMinutes
      : 60
  form.remark = detail.remark?.trim() || ''
  dirty.value = false
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
      await Promise.all([loadEmployees(), loadTypes()])
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
            }
          } catch {
            /* ignore */
          } finally {
            sessionStorage.removeItem('appt.invite.customer')
          }
        }
      }
      await refreshSameDayTips()
      dirty.value = false
    } catch (error) {
      loadError.value = getUserFriendlyErrorMessage(error)
    }
  })
}

function onSelectCustomer(customer: CustomerListItem): void {
  form.customerId = customer.id
  form.customerName = customer.name?.trim() || ''
  form.customerMobile = customer.mobile?.trim() || ''
  customerLevelName.value = customer.levelName?.trim() || null
  customerKeyword.value = ''
  customerDropdownVisible.value = false
  customerSearchResults.value = []
  markDirty()
  void refreshSameDayTips()
  if (!customerLevelName.value) {
    void fetchCustomerDetail(customer.id)
      .then((d) => {
        customerLevelName.value = d.levelName?.trim() || null
      })
      .catch(() => {
        /* 护理日志非主路径，失败不阻塞 */
      })
  }
}

function onCreatedCustomer(customer: {
  id: number
  name: string | null
  mobile: string | null
}): void {
  form.customerId = customer.id
  form.customerName = customer.name?.trim() || ''
  form.customerMobile = customer.mobile?.trim() || ''
  customerLevelName.value = null
  markDirty()
  void refreshSameDayTips()
}

function clearCustomer(): void {
  form.customerId = null
  form.customerName = ''
  form.customerMobile = ''
  customerLevelName.value = null
  markDirty()
}

async function searchCustomers(reset = true): Promise<void> {
  const kw = customerKeyword.value.trim()
  if (!kw) {
    customerSearchResults.value = []
    customerSearchHasMore.value = false
    customerDropdownVisible.value = false
    return
  }
  if (
    !reset &&
    (customerSearching.value || customerSearchLoadingMore.value || !customerSearchHasMore.value)
  ) {
    return
  }
  const nextPage = reset ? 1 : customerSearchPage.value + 1
  const seq = ++customerSearchSeq
  if (reset) customerSearching.value = true
  else customerSearchLoadingMore.value = true
  try {
    const data = await fetchCustomerPage({ keyword: kw, page: nextPage, size: CUSTOMER_PAGE_SIZE })
    if (seq !== customerSearchSeq) return
    const chunk = data.records ?? []
    const total = data.total ?? 0
    if (reset) {
      customerSearchResults.value = chunk
      customerSearchPage.value = 1
    } else {
      customerSearchResults.value = [...customerSearchResults.value, ...chunk]
      customerSearchPage.value = nextPage
    }
    customerSearchHasMore.value =
      total > 0
        ? customerSearchResults.value.length < total
        : chunk.length >= CUSTOMER_PAGE_SIZE
    customerDropdownVisible.value = true
  } catch (e) {
    if (seq !== customerSearchSeq) return
    if (reset) {
      customerSearchResults.value = []
      customerSearchHasMore.value = false
    }
    uiMessage.error(getUserFriendlyErrorMessage(e))
  } finally {
    if (seq === customerSearchSeq) {
      customerSearching.value = false
      customerSearchLoadingMore.value = false
    }
  }
}

function onCustomerKeywordInput(): void {
  if (customerSearchTimer != null) clearTimeout(customerSearchTimer)
  customerSearchTimer = setTimeout(() => void searchCustomers(true), 300)
}

function onCustomerDropdownScroll(e: Event): void {
  const el = e.target as HTMLElement | null
  if (!el) return
  if (el.scrollHeight - el.scrollTop - el.clientHeight <= 36) {
    void searchCustomers(false)
  }
}

function onCustomerEnter(): void {
  const kw = customerKeyword.value.trim()
  if (!kw) return
  if (customerSearchResults.value.length === 1) {
    onSelectCustomer(customerSearchResults.value[0]!)
    return
  }
  if (customerSearchResults.value.length === 0) {
    createPrefillMobile.value = /^\d{7,15}$/.test(kw) ? kw : ''
    createCustomerVisible.value = true
  }
}

function onCustomerBlur(): void {
  window.setTimeout(() => {
    customerDropdownVisible.value = false
  }, 180)
}

function onProjectsConfirm(
  items: Array<{ id: number; name: string; treatTime: number | null }>,
): void {
  selectedProjects.value = items
  if (items.length > 0) {
    form.durationMinutes = items.reduce(
      (s, p) => s + (p.treatTime != null && p.treatTime > 0 ? p.treatTime : 60),
      0,
    )
  }
  markDirty()
}

function removeProject(id: number): void {
  selectedProjects.value = selectedProjects.value.filter((p) => p.id !== id)
  if (selectedProjects.value.length > 0) {
    form.durationMinutes = autoDuration.value
  }
  markDirty()
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
      const projectIds = selectedProjects.value.map((p) => p.id)
      if (isEdit.value && props.appointmentId) {
        const updated = await updateAppointment(props.appointmentId, {
          customerId: form.customerId,
          projectIds,
          employeeId: form.employeeId.trim() || null,
          startTime,
          durationMinutes: form.durationMinutes,
          appointmentTypeId: form.appointmentTypeId,
          remark: form.remark.trim() || null,
          version: editing.value?.version ?? null,
        })
        uiMessage.success('预约已更新')
        allowClose.value = true
        dirty.value = false
        visible.value = false
        emit('success', updated.id)
        return
      }
      const created = await createAppointment({
        customerId: form.customerId!,
        storeId,
        projectIds,
        employeeId: form.employeeId.trim() || null,
        startTime,
        durationMinutes: form.durationMinutes,
        appointmentTypeId: form.appointmentTypeId,
        remark: form.remark.trim() || null,
      })
      uiMessage.success('预约已创建')
      allowClose.value = true
      dirty.value = false
      visible.value = false
      emit('success', created.id)
    } catch (error) {
      uiMessage.error(getUserFriendlyErrorMessage(error))
    }
  })
}

async function handleBeforeClose(done: () => void): Promise<void> {
  if (allowClose.value || !dirty.value) {
    done()
    return
  }
  try {
    await ElMessageBox.confirm('预约尚未保存，关闭后将丢失，确定关闭吗？', '提示', {
      confirmButtonText: '放弃修改',
      cancelButtonText: '继续编辑',
      distinguishCancelAndClose: true,
      type: 'warning',
      closeOnClickModal: false,
    })
    dirty.value = false
    done()
  } catch {
    /* 继续编辑或点 X：不关闭主弹窗 */
  }
}

watch(visible, (open) => {
  if (!open) {
    if (customerSearchTimer) clearTimeout(customerSearchTimer)
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
    width="920px"
    top="5vh"
    destroy-on-close
    :close-on-click-modal="false"
    :before-close="handleBeforeClose"
    class="appt-form-dialog"
  >
    <AppError
      v-if="loadError && !loading"
      :description="loadError"
      @retry="loadForOpen"
    />
    <div v-else v-loading="loading" class="layout">
      <div class="left">
        <el-alert
          v-if="sameDayTips.length > 0"
          type="warning"
          :closable="false"
          show-icon
          class="same-day-tip"
          :title="`该顾客当日已有 ${sameDayTips.length} 条其他预约（不禁止继续登记）`"
        />

        <div class="customer-search-wrap">
          <template v-if="form.customerId && !isEdit">
            <div class="customer-selected-bar">
              <span class="picked-text">
                {{ form.customerName || '未命名' }}
                <span v-if="form.customerMobile">（{{ maskMobile(form.customerMobile) }}）</span>
                <el-tag v-if="customerLevelName" size="small" type="primary" effect="plain">
                  {{ customerLevelName }}
                </el-tag>
              </span>
              <div class="picked-actions">
                <el-button
                  link
                  :icon="View"
                  title="查看顾客详情"
                  @click="detailDrawerVisible = true"
                />
                <el-button link type="danger" @click="clearCustomer">清除</el-button>
              </div>
            </div>
          </template>
          <template v-else-if="form.customerId && isEdit">
            <div class="customer-selected-bar">
              <span class="picked-text">
                {{ form.customerName || '未命名' }}
                <span v-if="form.customerMobile">（{{ maskMobile(form.customerMobile) }}）</span>
              </span>
              <el-button
                link
                :icon="View"
                title="查看顾客详情"
                @click="detailDrawerVisible = true"
              />
            </div>
          </template>
          <template v-else>
            <el-input
              v-model="customerKeyword"
              clearable
              placeholder="请输入客户名称、手机号、编号查找，无匹配按回车新增"
              @input="onCustomerKeywordInput"
              @keyup.enter="onCustomerEnter"
              @focus="customerDropdownVisible = customerSearchResults.length > 0"
              @blur="onCustomerBlur"
            />
            <div
              v-if="customerDropdownVisible"
              class="customer-dropdown"
              @scroll.passive="onCustomerDropdownScroll"
            >
              <div
                v-for="item in customerSearchResults"
                :key="item.id"
                class="customer-option"
                @mousedown.prevent="onSelectCustomer(item)"
              >
                <strong>{{ item.name?.trim() || '未命名' }}</strong>
                <span>{{ maskMobile(item.mobile) }}</span>
                <span>{{ item.levelName || '—' }}</span>
              </div>
              <div v-if="customerSearchLoadingMore" class="customer-empty">加载中…</div>
              <div
                v-else-if="customerSearchHasMore && customerSearchResults.length"
                class="customer-empty"
              >
                下拉加载更多
              </div>
              <div
                v-if="!customerSearching && !customerSearchResults.length && customerKeyword.trim()"
                class="customer-empty"
              >
                无匹配，按 Enter 快速建客
              </div>
            </div>
          </template>
        </div>

        <el-form label-width="88px" class="form" @submit.prevent>
          <el-form-item label="预约类型">
            <el-select
              v-model="form.appointmentTypeId"
              clearable
              placeholder="可选"
              style="width: 100%"
              @change="markDirty"
            >
              <el-option
                v-for="t in typeOptions"
                :key="t.id"
                :label="t.name || String(t.id)"
                :value="t.id"
              />
            </el-select>
          </el-form-item>

          <el-form-item label="预约时间" required>
            <div class="time-row">
              <el-date-picker
                v-model="form.date"
                type="date"
                value-format="YYYY-MM-DD"
                style="width: 150px"
                @change="markDirty"
              />
              <el-time-select
                v-model="form.startTime"
                start="08:00"
                step="00:15"
                end="22:00"
                style="width: 120px"
                @change="markDirty"
              />
            </div>
          </el-form-item>

          <el-form-item label="预约时长" required>
            <el-input-number
              v-model="form.durationMinutes"
              :min="15"
              :max="480"
              :step="15"
              @change="markDirty"
            />
            <span class="hint">
              {{
                selectedProjects.length
                  ? `默认累加 ${autoDuration} 分，可改`
                  : '未选项目请手工填写'
              }}
              · 结束 {{ endTimeLabel }}
            </span>
          </el-form-item>

          <el-form-item label="养发师">
            <el-select
              v-model="form.employeeId"
              filterable
              clearable
              placeholder="可不选（到店确认列登记）"
              style="width: 100%"
              @change="markDirty"
            >
              <el-option
                v-for="emp in employeeOptions"
                :key="emp.employeeId"
                :label="emp.employeeName || emp.employeeId"
                :value="emp.employeeId"
              />
            </el-select>
          </el-form-item>

          <el-form-item label="商家备注">
            <el-input
              v-model="form.remark"
              type="textarea"
              :rows="3"
              maxlength="200"
              show-word-limit
              @input="markDirty"
            />
          </el-form-item>
        </el-form>
      </div>

      <div class="right">
        <div class="right-head">
          <span>预约项目</span>
          <el-button type="primary" size="small" @click="projectPickerVisible = true">
            添加
          </el-button>
        </div>
        <div class="project-chips">
          <div v-for="p in selectedProjects" :key="p.id" class="chip">
            <span>{{ p.name }}</span>
            <button type="button" class="chip-x" @click="removeProject(p.id)">×</button>
          </div>
          <div v-if="selectedProjects.length === 0" class="chip-empty">
            可不选项目，到店后再定
          </div>
        </div>

        <div v-if="form.customerId && isMember" class="log-block">
          <div class="log-title">护理日志</div>
          <div class="log-scroll">
            <CustomerServiceLog :customer-id="form.customerId" />
          </div>
        </div>
        <div v-else-if="form.customerId && !isMember" class="log-hint">
          非会员或未匹配等级时不展示护理日志
        </div>
      </div>
    </div>

    <template #footer>
      <el-button @click="visible = false">取消</el-button>
      <el-button type="primary" :loading="saving" :disabled="!!loadError" @click="handleSubmit">
        保存
      </el-button>
    </template>

    <AppointmentProjectPickerDialog
      v-model="projectPickerVisible"
      :model-selected="selectedProjects"
      @confirm="onProjectsConfirm"
    />
    <CustomerCreateDialog
      v-model="createCustomerVisible"
      :default-mobile="createPrefillMobile"
      @created="onCreatedCustomer"
    />
    <CustomerDetailDrawer
      v-model="detailDrawerVisible"
      :customer-id="form.customerId"
    />
  </el-dialog>
</template>

<style scoped>
.layout {
  display: flex;
  gap: 16px;
  min-height: 420px;
}
.left {
  flex: 1 1 52%;
  min-width: 0;
}
.right {
  flex: 1 1 48%;
  min-width: 0;
  border-left: 1px solid #ebeef5;
  padding-left: 16px;
  display: flex;
  flex-direction: column;
  gap: 10px;
}
.same-day-tip {
  margin-bottom: 10px;
}
.customer-search-wrap {
  position: relative;
  margin-bottom: 12px;
}
.customer-selected-bar {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 8px;
  padding: 8px 10px;
  background: #f5f7fa;
  border-radius: 4px;
}
.picked-text {
  display: flex;
  align-items: center;
  gap: 6px;
  font-size: 13px;
}
.picked-actions {
  display: flex;
  align-items: center;
}
.customer-dropdown {
  position: absolute;
  left: 0;
  right: 0;
  top: 100%;
  z-index: 20;
  max-height: 240px;
  overflow: auto;
  background: #fff;
  border: 1px solid #e4e7ed;
  border-radius: 4px;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.08);
}
.customer-option {
  display: grid;
  grid-template-columns: 1fr auto auto;
  gap: 10px;
  padding: 8px 12px;
  cursor: pointer;
  font-size: 13px;
}
.customer-option:hover {
  background: #f5f7fa;
}
.customer-empty {
  padding: 10px;
  text-align: center;
  color: #909399;
  font-size: 12px;
}
.time-row {
  display: flex;
  gap: 8px;
}
.hint {
  margin-left: 8px;
  color: #909399;
  font-size: 12px;
}
.right-head {
  display: flex;
  align-items: center;
  justify-content: space-between;
  font-weight: 600;
}
.project-chips {
  display: flex;
  flex-direction: column;
  gap: 8px;
  max-height: 160px;
  overflow: auto;
}
.chip {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 8px;
  padding: 8px 10px;
  background: var(--el-color-primary-light-9);
  border: 1px solid var(--el-color-primary-light-5);
  border-radius: 4px;
  color: var(--el-color-primary);
  font-size: 13px;
}
.chip-x {
  border: none;
  background: transparent;
  cursor: pointer;
  font-size: 16px;
  color: #909399;
}
.chip-empty {
  font-size: 12px;
  color: #c0c4cc;
  padding: 8px 0;
}
.log-block {
  flex: 1;
  min-height: 0;
  display: flex;
  flex-direction: column;
  border-top: 1px solid #ebeef5;
  padding-top: 8px;
}
.log-title {
  font-weight: 600;
  margin-bottom: 6px;
  font-size: 13px;
}
.log-scroll {
  flex: 1;
  max-height: 220px;
  overflow: auto;
  border: 1px solid #ebeef5;
  border-radius: 4px;
  padding: 4px;
}
.log-hint {
  font-size: 12px;
  color: #c0c4cc;
}
</style>
