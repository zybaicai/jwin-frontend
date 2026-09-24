<script setup lang="ts">
import { computed, ref, watch } from 'vue'
import { useRouter } from 'vue-router'

import AppEmpty from '@/components/common/AppEmpty.vue'
import AppError from '@/components/common/AppError.vue'
import {
  attachCustomerTags,
  detachCustomerTag,
  fetchAllCustomerTags,
  fetchCustomerDetail,
  fetchCustomerTags,
  findCustomerListItemById,
} from '@/api/customer'
import {
  CustomerPermission,
  type CustomerDetail,
  type CustomerDetailTabKey,
  type CustomerListItem,
  type CustomerTagItem,
} from '@/types/customer'
import { usePermissionStore } from '@/stores/permission'
import {
  getUserFriendlyErrorMessage,
  notifyError,
  runExclusive,
  uiConfirm,
  uiMessage,
} from '@/utils/ui'
import {
  formatDate,
  formatDateTime,
  formatGender,
  formatMemberStatus,
  formatMoney,
} from '@/views/customer/customer-format'
import { AppointmentPermission } from '@/types/appointment'
import { SalePermission } from '@/types/sale'
import CustomerAppointment from '@/views/customer/CustomerAppointment.vue'
import CustomerAppointmentCreateDialog from '@/views/customer/CustomerAppointmentCreateDialog.vue'
import CustomerCardInfo from '@/views/customer/CustomerCardInfo.vue'
import CustomerFollowUp from '@/views/customer/CustomerFollowUp.vue'
import CustomerOrderInfo from '@/views/customer/CustomerOrderInfo.vue'
import CustomerServiceLog from '@/views/customer/CustomerServiceLog.vue'

defineOptions({ name: 'CustomerDetailDrawer' })

const visible = defineModel<boolean>({ default: false })

const props = defineProps<{
  customerId: number | null
}>()

const emit = defineEmits<{
  edit: [customerId: number]
}>()

const router = useRouter()
const permissionStore = usePermissionStore()
const canEditCustomer = computed(() =>
  permissionStore.hasPermission(CustomerPermission.EDIT),
)

const activeTab = ref<CustomerDetailTabKey>('profile')
const profileCollapsed = ref(false)
const cardInfoRef = ref<{ reloadCurrent: () => Promise<void> } | null>(null)
const orderInfoRef = ref<{ reloadCurrent: () => Promise<void> } | null>(null)
const followUpRef = ref<{ reloadCurrent: () => Promise<void> } | null>(null)
const appointmentRef = ref<{ reloadCurrent: () => Promise<void> } | null>(null)
const serviceLogRef = ref<{ reloadCurrent: () => Promise<void> } | null>(null)

const loading = ref(false)
const loadError = ref<string | null>(null)
const detail = ref<CustomerDetail | null>(null)
/** CustomerDetailVo 不含介绍人/地址/备注，用列表 CustomerVo 补齐展示 */
const profileExtra = ref<CustomerListItem | null>(null)

const tagsLoading = ref(false)
const tagsError = ref<string | null>(null)
const tags = ref<CustomerTagItem[]>([])

const tagEditVisible = ref(false)
const tagEditLoading = ref(false)
const tagSaving = ref(false)
const tagLibrary = ref<CustomerTagItem[]>([])
const editingTagIds = ref<number[]>([])

const visitedTabs = ref<Set<CustomerDetailTabKey>>(new Set(['profile']))
const appointmentCreateVisible = ref(false)

const displayName = computed(() => detail.value?.name?.trim() || '未命名客户')
const genderSymbol = computed(() => {
  const gender = detail.value?.gender
  if (gender === '2') return '♀'
  if (gender === '1') return '♂'
  return ''
})
const genderTone = computed(() => {
  if (detail.value?.gender === '2') return 'is-female'
  if (detail.value?.gender === '1') return 'is-male'
  return ''
})

const avgSaleTicket = computed(() => {
  const d = detail.value
  if (d == null || d.saleVisitCount == null || d.saleVisitCount <= 0) {
    return null
  }
  const amount = Number(d.saleAmount)
  if (!Number.isFinite(amount)) {
    return null
  }
  return amount / d.saleVisitCount
})

const avgTreatTicket = computed(() => {
  const d = detail.value
  if (d == null || d.guestVisitCount == null || d.guestVisitCount <= 0) {
    return null
  }
  const amount = Number(d.treatAmount)
  if (!Number.isFinite(amount)) {
    return null
  }
  return amount / d.guestVisitCount
})

function resetState(): void {
  activeTab.value = 'profile'
  profileCollapsed.value = false
  visitedTabs.value = new Set(['profile'])
  appointmentCreateVisible.value = false
  detail.value = null
  profileExtra.value = null
  loadError.value = null
  tags.value = []
  tagsError.value = null
  tagEditVisible.value = false
  tagLibrary.value = []
  editingTagIds.value = []
}

async function loadProfileExtra(current: CustomerDetail): Promise<void> {
  try {
    const keyword = current.code?.trim() || current.mobile?.trim() || current.name?.trim() || ''
    profileExtra.value = await findCustomerListItemById(current.id, keyword)
  } catch {
    profileExtra.value = null
  }
}

async function loadBasic(): Promise<void> {
  if (props.customerId == null) {
    loadError.value = '客户 ID 无效'
    detail.value = null
    profileExtra.value = null
    return
  }
  await runExclusive(loading, async () => {
    loadError.value = null
    try {
      const next = await fetchCustomerDetail(props.customerId!)
      detail.value = next
      await loadProfileExtra(next)
    } catch (error) {
      detail.value = null
      profileExtra.value = null
      loadError.value = getUserFriendlyErrorMessage(error)
      notifyError(error)
    }
  })
}

async function loadTags(): Promise<void> {
  if (props.customerId == null) {
    tags.value = []
    tagsError.value = '客户 ID 无效'
    return
  }
  await runExclusive(tagsLoading, async () => {
    tagsError.value = null
    try {
      tags.value = await fetchCustomerTags(props.customerId!)
    } catch (error) {
      tags.value = []
      tagsError.value = getUserFriendlyErrorMessage(error)
      notifyError(error)
    }
  })
}

function handleTabChange(name: string | number): void {
  const key = String(name) as CustomerDetailTabKey
  activeTab.value = key
  const next = new Set(visitedTabs.value)
  next.add(key)
  visitedTabs.value = next
  if (key === 'profile' && tags.value.length === 0 && !tagsLoading.value) {
    void loadTags()
  }
}

async function handleRefresh(): Promise<void> {
  if (activeTab.value === 'profile') {
    await Promise.all([loadBasic(), loadTags()])
    return
  }
  if (activeTab.value === 'cards') {
    await cardInfoRef.value?.reloadCurrent()
    return
  }
  if (activeTab.value === 'orders') {
    await orderInfoRef.value?.reloadCurrent()
    return
  }
  if (activeTab.value === 'serviceLogs') {
    await serviceLogRef.value?.reloadCurrent()
    return
  }
  if (activeTab.value === 'followUps') {
    await followUpRef.value?.reloadCurrent()
    return
  }
  if (activeTab.value === 'appointments') {
    await appointmentRef.value?.reloadCurrent()
  }
}

function handleEdit(): void {
  if (props.customerId == null) {
    return
  }
  emit('edit', props.customerId)
}

function handleOpenAppointmentCreate(): void {
  if (props.customerId == null) {
    return
  }
  appointmentCreateVisible.value = true
}

function handleOpenSaleCashier(): void {
  if (props.customerId == null) {
    return
  }
  visible.value = false
  void router.push({
    path: '/sales/cashier',
    query: { customerId: String(props.customerId) },
  })
}

async function handleAppointmentCreated(): Promise<void> {
  // 仅刷新已访问过的预约记录 Tab，不提前加载、不切换 Tab
  if (visitedTabs.value.has('appointments')) {
    await appointmentRef.value?.reloadCurrent()
  }
}

const availableTagOptions = computed(() => {
  const owned = new Set(tags.value.map((item) => item.id))
  return tagLibrary.value.filter((item) => !owned.has(item.id))
})

async function openTagEditor(): Promise<void> {
  if (props.customerId == null) {
    return
  }
  tagEditVisible.value = true
  editingTagIds.value = []
  tagEditLoading.value = true
  try {
    tagLibrary.value = await fetchAllCustomerTags()
  } catch (error) {
    tagLibrary.value = []
    notifyError(error)
  } finally {
    tagEditLoading.value = false
  }
}

async function saveTags(): Promise<void> {
  if (props.customerId == null) {
    return
  }
  const customerId = props.customerId
  const currentIds = new Set(tags.value.map((item) => item.id))
  const toAttach = editingTagIds.value.filter((id) => !currentIds.has(id))
  if (toAttach.length === 0) {
    uiMessage.warning('请选择要添加的标签')
    return
  }

  await runExclusive(tagSaving, async () => {
    try {
      await attachCustomerTags(customerId, toAttach)
      tags.value = await fetchCustomerTags(customerId)
      uiMessage.success('标签已添加')
      tagEditVisible.value = false
    } catch (error) {
      notifyError(error)
    }
  })
}

async function handleRemoveCustomerTag(tag: CustomerTagItem): Promise<void> {
  if (props.customerId == null) {
    return
  }
  const ok = await uiConfirm({
    title: '移除标签',
    message: `确认移除该客户标签「${tag.name || tag.id}」？`,
    confirmText: '移除',
  })
  if (!ok) {
    return
  }
  try {
    await detachCustomerTag(props.customerId, tag.id)
    tags.value = await fetchCustomerTags(props.customerId)
    uiMessage.success('已移除客户标签')
  } catch (error) {
    notifyError(error)
  }
}

function handleClosed(): void {
  resetState()
}

watch(visible, (open) => {
  if (!open) {
    return
  }
  resetState()
  void (async () => {
    await loadBasic()
    await loadTags()
  })()
})

defineExpose({
  reload: async () => {
    await Promise.all([loadBasic(), loadTags()])
  },
})
</script>

<template>
  <el-dialog
    v-model="visible"
    class="customer-detail-dialog"
    width="calc(100vw - 220px)"
    align-center
    destroy-on-close
    append-to-body
    :close-on-click-modal="false"
    @closed="handleClosed"
  >
    <template #header>
      <h2 class="drawer-title">客户详情</h2>
    </template>

    <AppError
      v-if="loadError && !loading && detail == null"
      :description="loadError"
      @retry="loadBasic"
    />

    <div v-else class="drawer-body" v-loading="loading && detail == null">
      <section v-if="detail" class="profile-panel">
        <div class="profile-top">
          <div class="identity">
            <div class="avatar" aria-hidden="true">{{ displayName.slice(0, 1) }}</div>
            <div class="identity-text">
              <div class="name-line">
                <span class="name">{{ displayName }}</span>
                <span v-if="genderSymbol" class="gender" :class="genderTone">{{ genderSymbol }}</span>
                <span class="member-text">{{ formatMemberStatus(detail.member) }}</span>
                <span v-if="detail.levelName" class="level-text">{{ detail.levelName }}</span>
              </div>
            </div>
          </div>
          <div class="profile-actions">
            <button
              v-permission="CustomerPermission.EDIT"
              type="button"
              class="text-action"
              @click="handleEdit"
            >
              查看/编辑全部信息
            </button>
            <button
              type="button"
              class="text-action"
              @click="profileCollapsed = !profileCollapsed"
            >
              {{ profileCollapsed ? '展开资料' : '收起资料' }}
              <span class="chevron" :class="{ 'is-collapsed': profileCollapsed }">⌃</span>
            </button>
            <el-button
              v-permission="SalePermission.ORDER_CREATE"
              @click="handleOpenSaleCashier"
            >
              开单
            </el-button>
            <el-button
              v-permission="AppointmentPermission.EDIT"
              @click="handleOpenAppointmentCreate"
            >
              预约
            </el-button>
          </div>
        </div>

        <div v-show="!profileCollapsed" class="profile-detail">
          <div class="info-grid">
            <div class="info-cell">
              <span class="label">手机号</span>
              <span class="value">{{ detail.mobile || '—' }}</span>
            </div>
            <div class="info-cell">
              <span class="label">服务人员</span>
              <span class="value">{{ detail.nurseName || '—' }}</span>
            </div>
            <div class="info-cell">
              <span class="label">会员编号</span>
              <span class="value">{{ detail.code || '—' }}</span>
            </div>
            <div class="info-cell">
              <span class="label">公历生日</span>
              <span class="value">{{ formatDate(detail.birthday) }}</span>
            </div>
            <div class="info-cell">
              <span class="label">归属门店</span>
              <span class="value">{{ detail.storeName || '—' }}</span>
            </div>
            <div class="info-cell">
              <span class="label">信息来源</span>
              <span class="value">{{ detail.sourceName || '—' }}</span>
            </div>
            <div class="info-cell">
              <span class="label">介绍人</span>
              <span class="value">{{ profileExtra?.introducerName || '—' }}</span>
            </div>
            <div class="info-cell">
              <span class="label">注册门店</span>
              <span class="value">{{ detail.registerStoreName || '—' }}</span>
            </div>
            <div class="info-cell">
              <span class="label">注册时间</span>
              <span class="value">{{ formatDateTime(detail.createdOn) }}</span>
            </div>
            <div class="info-cell">
              <span class="label">入会时间</span>
              <span class="value">{{ formatDateTime(detail.memberOn) }}</span>
            </div>
          </div>

          <div class="metric-bar">
            <div class="metric">
              <span class="metric-label">余额(元) / 赠额</span>
              <span class="metric-value">
                {{ formatMoney(detail.cardBalance) }} / {{ formatMoney(detail.giftBalance) }}
              </span>
            </div>
            <div class="metric">
              <span class="metric-label">累计消费金额(元) / 次数 / 客单</span>
              <span class="metric-value">
                {{ formatMoney(detail.saleAmount) }} /
                {{ detail.saleVisitCount != null ? `${detail.saleVisitCount}次` : '—' }} /
                {{ formatMoney(avgSaleTicket) }}
              </span>
            </div>
            <div class="metric">
              <span class="metric-label">累计消耗金额(元) / 次数 / 客单</span>
              <span class="metric-value">
                {{ formatMoney(detail.treatAmount) }} /
                {{ detail.treatVisitCount != null ? `${detail.treatVisitCount}次` : '—' }} /
                {{ formatMoney(avgTreatTicket) }}
              </span>
            </div>
            <div class="metric">
              <span class="metric-label">欠款金额(元)</span>
              <span class="metric-value is-danger">{{ formatMoney(detail.arrearAmount) }}</span>
            </div>
            <div class="metric">
              <span class="metric-label">最近购买时间</span>
              <span class="metric-value">{{ formatDate(detail.lastSaleTime) }}</span>
            </div>
            <div class="metric">
              <span class="metric-label">最近消耗时间</span>
              <span class="metric-value">{{ formatDate(detail.lastTreatTime) }}</span>
            </div>
          </div>
        </div>
      </section>

      <div class="tabs-toolbar">
        <el-tabs
          v-model="activeTab"
          class="detail-tabs"
          @tab-change="handleTabChange"
        >
          <el-tab-pane label="基本档案" name="profile" lazy>
            <div v-if="visitedTabs.has('profile')" class="tab-pane-body">
              <div v-if="detail" class="profile-archive">
                <section class="archive-section">
                  <h3 class="archive-title">基础资料</h3>
                  <div class="archive-grid">
                    <div class="info-cell">
                      <span class="label">姓名</span>
                      <span class="value">{{ detail.name || '—' }}</span>
                    </div>
                    <div class="info-cell">
                      <span class="label">手机号</span>
                      <span class="value">{{ detail.mobile || '—' }}</span>
                    </div>
                    <div class="info-cell">
                      <span class="label">性别</span>
                      <span class="value">{{ formatGender(detail.gender, detail.genderName) }}</span>
                    </div>
                    <div class="info-cell">
                      <span class="label">生日</span>
                      <span class="value">{{ formatDate(detail.birthday) }}</span>
                    </div>
                    <div class="info-cell">
                      <span class="label">地址</span>
                      <span class="value">{{ profileExtra?.address || '—' }}</span>
                    </div>
                  </div>
                </section>

                <section class="archive-section">
                  <h3 class="archive-title">会员资料</h3>
                  <div class="archive-grid">
                    <div class="info-cell">
                      <span class="label">是否会员</span>
                      <span class="value">{{ formatMemberStatus(detail.member) }}</span>
                    </div>
                    <div class="info-cell">
                      <span class="label">会员等级</span>
                      <span class="value">{{ detail.levelName || '—' }}</span>
                    </div>
                    <div class="info-cell">
                      <span class="label">入会时间</span>
                      <span class="value">{{ formatDateTime(detail.memberOn) }}</span>
                    </div>
                    <div class="info-cell">
                      <span class="label">会员编号</span>
                      <span class="value">{{ detail.code || '—' }}</span>
                    </div>
                  </div>
                </section>

                <section class="archive-section">
                  <h3 class="archive-title">来源关系</h3>
                  <div class="archive-grid">
                    <div class="info-cell">
                      <span class="label">首来源</span>
                      <span class="value">{{ detail.sourceName || '—' }}</span>
                    </div>
                    <div class="info-cell">
                      <span class="label">介绍人</span>
                      <span class="value">{{ profileExtra?.introducerName || '—' }}</span>
                    </div>
                  </div>
                </section>

                <section class="archive-section">
                  <h3 class="archive-title">服务关系</h3>
                  <div class="archive-grid">
                    <div class="info-cell">
                      <span class="label">主护理师</span>
                      <span class="value">{{ detail.nurseName || '—' }}</span>
                    </div>
                    <div class="info-cell">
                      <span class="label">归属门店</span>
                      <span class="value">{{ detail.storeName || '—' }}</span>
                    </div>
                  </div>
                </section>

                <section class="archive-section">
                  <h3 class="archive-title">其他</h3>
                  <div class="archive-grid">
                    <div class="info-cell archive-cell-wide">
                      <span class="label">备注</span>
                      <span class="value is-wrap">{{ profileExtra?.remark || '—' }}</span>
                    </div>
                  </div>
                </section>
              </div>

              <div class="tags-panel">
                <div class="tags-header">
                  <span class="tags-title">客户标签</span>
                  <button
                    v-permission="CustomerPermission.EDIT"
                    type="button"
                    class="text-action"
                    :disabled="customerId == null || tagsLoading"
                    @click="openTagEditor"
                  >
                    + 添加标签
                  </button>
                </div>
                <div v-loading="tagsLoading" class="tags-body">
                  <AppError
                    v-if="tagsError && !tagsLoading"
                    :description="tagsError"
                    @retry="loadTags"
                  />
                  <template v-else-if="tags.length > 0">
                    <el-tag
                      v-for="tag in tags"
                      :key="tag.id"
                      class="tag-chip"
                      effect="plain"
                      :closable="canEditCustomer"
                      @close="handleRemoveCustomerTag(tag)"
                    >
                      {{ tag.name }}
                    </el-tag>
                  </template>
                  <AppEmpty
                    v-else
                    title="暂无标签"
                    description="可点击「+ 添加标签」为顾客贴标。"
                  />
                </div>
              </div>
            </div>
          </el-tab-pane>

          <el-tab-pane label="卡项信息" name="cards" lazy>
            <div v-if="visitedTabs.has('cards') && customerId != null" class="tab-pane-body">
              <CustomerCardInfo ref="cardInfoRef" :customer-id="customerId" />
            </div>
          </el-tab-pane>

          <el-tab-pane label="订单信息" name="orders" lazy>
            <div v-if="visitedTabs.has('orders') && customerId != null" class="tab-pane-body">
              <CustomerOrderInfo ref="orderInfoRef" :customer-id="customerId" />
            </div>
          </el-tab-pane>

          <el-tab-pane label="服务日志" name="serviceLogs" lazy>
            <div v-if="visitedTabs.has('serviceLogs') && customerId != null" class="tab-pane-body">
              <CustomerServiceLog ref="serviceLogRef" :customer-id="customerId" />
            </div>
          </el-tab-pane>

          <el-tab-pane label="跟进记录" name="followUps" lazy>
            <div v-if="visitedTabs.has('followUps') && customerId != null" class="tab-pane-body">
              <CustomerFollowUp ref="followUpRef" :customer-id="customerId" />
            </div>
          </el-tab-pane>

          <el-tab-pane label="预约记录" name="appointments" lazy>
            <div v-if="visitedTabs.has('appointments') && customerId != null" class="tab-pane-body">
              <CustomerAppointment ref="appointmentRef" :customer-id="customerId" />
            </div>
          </el-tab-pane>

          <el-tab-pane label="文件档案" name="files" lazy>
            <div v-if="visitedTabs.has('files')" class="tab-pane-body">
              <AppEmpty title="功能建设中" description="文件档案接口就绪后在此接入。" />
            </div>
          </el-tab-pane>
        </el-tabs>
        <button
          type="button"
          class="refresh-link"
          :disabled="loading || tagsLoading"
          @click="handleRefresh"
        >
          刷新
        </button>
      </div>
    </div>

    <el-dialog
      v-model="tagEditVisible"
      title="添加标签"
      width="480px"
      append-to-body
      destroy-on-close
      :close-on-click-modal="false"
    >
      <el-select
        v-model="editingTagIds"
        v-loading="tagEditLoading"
        multiple
        filterable
        collapse-tags
        collapse-tags-tooltip
        placeholder="搜索并选择标签"
        style="width: 100%"
      >
        <el-option
          v-for="item in availableTagOptions"
          :key="item.id"
          :label="item.name"
          :value="item.id"
        />
      </el-select>
      <p v-if="!tagEditLoading && availableTagOptions.length === 0" class="tag-select-hint">
        暂无可添加的标签（已全部贴标或标签库为空）
      </p>
      <template #footer>
        <el-button :disabled="tagSaving" @click="tagEditVisible = false">取消</el-button>
        <el-button type="primary" :loading="tagSaving" @click="saveTags">添加</el-button>
      </template>
    </el-dialog>

    <CustomerAppointmentCreateDialog
      v-model="appointmentCreateVisible"
      :customer-id="customerId"
      :customer-name="displayName"
      @success="handleAppointmentCreated"
    />
  </el-dialog>
</template>

<style scoped>
.drawer-title {
  margin: 0;
  color: #303133;
  font-size: 16px;
  font-weight: 600;
}

.drawer-body {
  min-height: 240px;
}

.profile-panel {
  margin-bottom: 4px;
  padding-bottom: 8px;
  border-bottom: 1px solid #ebeef5;
}

.profile-top {
  display: flex;
  gap: 16px;
  align-items: flex-start;
  justify-content: space-between;
}

.identity {
  display: flex;
  gap: 12px;
  align-items: center;
  min-width: 0;
}

.avatar {
  display: flex;
  flex: 0 0 52px;
  align-items: center;
  justify-content: center;
  width: 52px;
  height: 52px;
  border-radius: 50%;
  background: #eceff3;
  color: #909399;
  font-size: 20px;
  font-weight: 600;
}

.identity-text {
  min-width: 0;
}

.name-line {
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
  align-items: center;
}

.name {
  color: #303133;
  font-size: 18px;
  font-weight: 600;
}

.gender {
  font-size: 14px;
  line-height: 1;
}

.gender.is-female {
  color: #f56c9a;
}

.gender.is-male {
  color: #409eff;
}

.member-text,
.level-text {
  color: #409eff;
  font-size: 13px;
}

.profile-actions {
  display: flex;
  flex-shrink: 0;
  flex-wrap: wrap;
  gap: 8px 12px;
  align-items: center;
  justify-content: flex-end;
}

.text-action {
  padding: 0;
  border: 0;
  background: transparent;
  color: #606266;
  cursor: pointer;
  font: inherit;
  font-size: 13px;
}

.text-action:hover:not(:disabled) {
  color: #409eff;
}

.text-action:disabled {
  cursor: not-allowed;
  opacity: 0.5;
}

.chevron {
  display: inline-block;
  margin-left: 2px;
  transition: transform 0.15s ease;
}

.chevron.is-collapsed {
  transform: rotate(180deg);
}

.profile-detail {
  margin-top: 14px;
}

.info-grid {
  display: grid;
  grid-template-columns: repeat(4, minmax(0, 1fr));
  gap: 10px 20px;
}

.info-cell {
  display: flex;
  gap: 8px;
  align-items: baseline;
  min-width: 0;
  font-size: 13px;
}

.label {
  flex-shrink: 0;
  color: #909399;
}

.value {
  min-width: 0;
  overflow: hidden;
  color: #303133;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.metric-bar {
  display: grid;
  grid-template-columns: repeat(6, minmax(0, 1fr));
  gap: 10px 14px;
  margin-top: 14px;
  padding: 10px 0 4px;
  border-top: 1px solid #f0f2f5;
}

.metric {
  min-width: 0;
}

.metric-label {
  display: block;
  color: #909399;
  font-size: 12px;
  line-height: 1.4;
}

.metric-value {
  display: block;
  margin-top: 4px;
  color: #303133;
  font-size: 13px;
  line-height: 1.4;
  word-break: break-all;
}

.metric-value.is-danger {
  color: #f56c6c;
}

.tabs-toolbar {
  position: relative;
  margin-top: 4px;
}

.detail-tabs {
  margin-top: 0;
}

.detail-tabs :deep(.el-tabs__header) {
  margin-bottom: 12px;
}

.refresh-link {
  position: absolute;
  top: 6px;
  right: 0;
  z-index: 2;
  padding: 0;
  border: 0;
  background: transparent;
  color: #909399;
  cursor: pointer;
  font: inherit;
  font-size: 13px;
}

.refresh-link:hover:not(:disabled) {
  color: #409eff;
}

.refresh-link:disabled {
  cursor: not-allowed;
  opacity: 0.5;
}

.tab-pane-body {
  min-height: 180px;
  padding-top: 2px;
}

.profile-archive {
  margin-bottom: 16px;
}

.archive-section + .archive-section {
  margin-top: 14px;
  padding-top: 12px;
  border-top: 1px solid #f0f2f5;
}

.archive-title {
  margin: 0 0 10px;
  color: #303133;
  font-size: 14px;
  font-weight: 600;
  line-height: 1.4;
}

.archive-grid {
  display: grid;
  grid-template-columns: repeat(4, minmax(0, 1fr));
  gap: 10px 20px;
}

.archive-cell-wide {
  grid-column: 1 / -1;
}

.value.is-wrap {
  overflow: visible;
  text-overflow: unset;
  white-space: normal;
  word-break: break-word;
}

.sub-tabs {
  margin-bottom: 8px;
}

.tags-panel {
  border: 1px solid #e4e7ed;
  border-radius: 4px;
  overflow: hidden;
}

.tags-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 8px 12px;
  background: #f5f7fa;
  border-bottom: 1px solid #e4e7ed;
}

.tags-title {
  color: #606266;
  font-size: 13px;
  font-weight: 600;
}

.tags-body {
  min-height: 88px;
  padding: 14px 12px;
}

.tag-chip {
  margin: 0 8px 8px 0;
}

.tag-select-hint {
  margin: 10px 0 0;
  color: #909399;
  font-size: 12px;
}

@media (max-width: 1100px) {
  .info-grid {
    grid-template-columns: repeat(2, minmax(0, 1fr));
  }

  .metric-bar {
    grid-template-columns: repeat(3, minmax(0, 1fr));
  }
}

@media (max-width: 720px) {
  .profile-top {
    flex-direction: column;
  }

  .info-grid,
  .metric-bar {
    grid-template-columns: 1fr;
  }
}
</style>

<style>
/* append-to-body 后需全局类控制居中与边距：左右更宽，上下也留边 */
.customer-detail-dialog.el-dialog {
  margin: 36px auto !important;
  max-width: calc(100vw - 220px);
  max-height: calc(100vh - 72px);
  display: flex;
  flex-direction: column;
  border-radius: 6px;
  overflow: hidden;
}

.customer-detail-dialog .el-dialog__header {
  flex-shrink: 0;
  margin-right: 0;
  padding: 14px 20px 10px;
}

.customer-detail-dialog .el-dialog__body {
  flex: 1;
  min-height: 0;
  max-height: calc(100vh - 140px);
  padding: 8px 20px 20px;
  overflow: auto;
}

@media (max-width: 960px) {
  .customer-detail-dialog.el-dialog {
    max-width: calc(100vw - 48px);
    width: calc(100vw - 48px) !important;
  }
}
</style>
