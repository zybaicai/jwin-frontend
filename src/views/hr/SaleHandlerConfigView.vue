<script setup lang="ts">
import { computed, reactive, ref, watch } from 'vue'

import AppEmpty from '@/components/common/AppEmpty.vue'
import AppError from '@/components/common/AppError.vue'
import {
  createHandlerRole,
  deactivateHandlerRole,
  fetchHandlerRoles,
  fetchJobTypePage,
  updateHandlerRole,
} from '@/api/hr'
import { HandlerPermission, type HandlerRoleRecord, type JobTypeRecord } from '@/types/hr'
import {
  HandlerSaleBizTypes,
  type HandlerSaleBizType,
} from '@/types/handler'
import { usePermissionStore } from '@/stores/permission'
import { useStoreStore } from '@/stores/store'
import {
  getUserFriendlyErrorMessage,
  notifyError,
  runExclusive,
  uiConfirm,
  uiMessage,
} from '@/utils/ui'

defineOptions({ name: 'SaleHandlerConfigView' })

const BIZ_LABELS: Record<HandlerSaleBizType, string> = {
  PROJECT_SALE: '项目销售',
  PRODUCT_SALE: '产品销售',
  SAVING_SALE: '储值销售',
  GENERAL_SALE: '次卡销售',
  TIME_SALE: '时效卡销售',
  PACKAGE_SALE: '套餐销售',
}

const BIZ_TABS = Object.values(HandlerSaleBizTypes) as HandlerSaleBizType[]

const permissionStore = usePermissionStore()
const storeStore = useStoreStore()

const hasViewPermission = computed(() =>
  permissionStore.hasPermission(HandlerPermission.CONFIG_VIEW),
)
const hasEditPermission = computed(() =>
  permissionStore.hasPermission(HandlerPermission.CONFIG_EDIT),
)

const storeId = computed(() => storeStore.currentStoreId)
const activeBiz = ref<HandlerSaleBizType>('PROJECT_SALE')
const loading = ref(false)
const listError = ref<string | null>(null)
const records = ref<HandlerRoleRecord[]>([])
const jobTypes = ref<JobTypeRecord[]>([])

const formVisible = ref(false)
const formMode = ref<'create' | 'edit'>('create')
const formSaving = ref(false)
const formError = ref<string | null>(null)
const editingId = ref<number | null>(null)

const form = reactive({
  name: '',
  sequence: 0,
  active: true,
  jobTypeIds: [] as number[],
})

function rowOf(row: unknown): HandlerRoleRecord {
  return row as HandlerRoleRecord
}

function jobTypeNames(ids: number[]): string {
  if (!ids?.length) return '—'
  const map = new Map(jobTypes.value.map((j) => [j.id, j.name]))
  return ids.map((id) => map.get(id) || `#${id}`).join('、')
}

async function loadJobTypes(): Promise<void> {
  try {
    const data = await fetchJobTypePage({ active: true, page: 1, size: 200 })
    jobTypes.value = data.records ?? []
  } catch {
    jobTypes.value = []
  }
}

async function loadList(): Promise<void> {
  if (!hasViewPermission.value) {
    records.value = []
    listError.value = '暂无权限查看经手配置（handler:config:view）'
    return
  }
  if (storeId.value == null) {
    records.value = []
    listError.value = '请先选择当前门店'
    return
  }
  await runExclusive(loading, async () => {
    listError.value = null
    try {
      records.value = await fetchHandlerRoles({
        bizType: activeBiz.value,
        storeId: storeId.value!,
        onlyActive: false,
      })
    } catch (error) {
      records.value = []
      listError.value = getUserFriendlyErrorMessage(error)
    }
  })
}

function openCreate(): void {
  if (storeId.value == null) {
    uiMessage.warning('请先选择当前门店')
    return
  }
  formMode.value = 'create'
  editingId.value = null
  form.name = ''
  form.sequence = 0
  form.active = true
  form.jobTypeIds = []
  formError.value = null
  formVisible.value = true
}

function openEdit(row: HandlerRoleRecord): void {
  formMode.value = 'edit'
  editingId.value = row.id
  form.name = row.name ?? ''
  form.sequence = row.sequence ?? 0
  form.active = row.active !== false
  form.jobTypeIds = [...(row.jobTypeIds ?? [])]
  formError.value = null
  formVisible.value = true
}

async function handleSubmit(): Promise<void> {
  if (!hasEditPermission.value || storeId.value == null) return
  const name = form.name.trim()
  if (!name) {
    uiMessage.warning('请填写角色名称')
    return
  }
  await runExclusive(formSaving, async () => {
    formError.value = null
    try {
      if (formMode.value === 'create') {
        await createHandlerRole({
          bizType: activeBiz.value,
          storeId: storeId.value!,
          name,
          sequence: form.sequence,
          jobTypeIds: form.jobTypeIds,
        })
        uiMessage.success('经手角色已创建')
      } else if (editingId.value != null) {
        await updateHandlerRole(editingId.value, activeBiz.value, {
          name,
          sequence: form.sequence,
          active: form.active,
          jobTypeIds: form.jobTypeIds,
        })
        uiMessage.success('经手角色已更新')
      }
      formVisible.value = false
      await loadList()
    } catch (error) {
      formError.value = getUserFriendlyErrorMessage(error)
      notifyError(error)
    }
  })
}

async function handleDeactivate(row: HandlerRoleRecord): Promise<void> {
  if (!hasEditPermission.value) return
  const ok = await uiConfirm({
    title: '停用经手角色',
    message: `确认停用「${row.name}」？停用后开单将不再出现该角色。`,
    confirmText: '停用',
  })
  if (!ok) return
  try {
    await deactivateHandlerRole(row.id, activeBiz.value)
    uiMessage.success('已停用')
    await loadList()
  } catch (error) {
    notifyError(error)
  }
}

watch(
  hasViewPermission,
  async (ok) => {
    if (ok) await loadJobTypes()
    void loadList()
  },
  { immediate: true },
)

watch([activeBiz, storeId], () => void loadList())
</script>

<template>
  <section class="sale-handler-config">
    <header class="page-header">
      <div>
        <h1>销售经手配置</h1>
        <p class="subtitle">
          当前门店：{{ storeStore.currentStoreName || (storeId != null ? `#${storeId}` : '未选择') }}
        </p>
      </div>
    </header>

    <el-alert
      type="warning"
      :closable="false"
      show-icon
      title="本页仅配置可参与经手的角色与允许职务；业绩占比在开单时填写且合计须为 100%，不是提成率。"
    />

    <el-tabs v-model="activeBiz" type="card">
      <el-tab-pane
        v-for="biz in BIZ_TABS"
        :key="biz"
        :label="BIZ_LABELS[biz]"
        :name="biz"
      />
    </el-tabs>

    <div class="toolbar">
      <el-button type="primary" :loading="loading" @click="loadList">刷新</el-button>
      <el-button v-if="hasEditPermission" type="primary" @click="openCreate">新增角色</el-button>
    </div>

    <div v-loading="loading" class="table-panel">
      <AppError
        v-if="listError && !loading"
        :description="listError"
        @retry="loadList"
      />
      <template v-else>
        <el-table :data="records" border stripe size="small" empty-text=" ">
          <el-table-column prop="name" label="角色名称" min-width="140" show-overflow-tooltip />
          <el-table-column label="允许职务" min-width="200" show-overflow-tooltip>
            <template #default="{ row }">
              {{ jobTypeNames(rowOf(row).jobTypeIds) }}
            </template>
          </el-table-column>
          <el-table-column prop="sequence" label="排序" width="80" align="right" />
          <el-table-column label="状态" width="90">
            <template #default="{ row }">
              <el-tag :type="rowOf(row).active !== false ? 'success' : 'info'" size="small">
                {{ rowOf(row).active !== false ? '启用' : '停用' }}
              </el-tag>
            </template>
          </el-table-column>
          <el-table-column label="操作" width="140" fixed="right">
            <template #default="{ row }">
              <el-button
                v-if="hasEditPermission"
                link
                type="primary"
                @click="openEdit(rowOf(row))"
              >
                编辑
              </el-button>
              <el-button
                v-if="hasEditPermission && rowOf(row).active !== false"
                link
                type="danger"
                @click="handleDeactivate(rowOf(row))"
              >
                停用
              </el-button>
            </template>
          </el-table-column>
        </el-table>
        <AppEmpty
          v-if="!loading && !listError && records.length === 0"
          title="暂无经手角色"
          description="可点击「新增角色」为本业务类型配置"
        />
      </template>
    </div>

    <el-dialog
      v-model="formVisible"
      :title="formMode === 'create' ? '新增经手角色' : '编辑经手角色'"
      width="480px"
      destroy-on-close
      :close-on-click-modal="false"
    >
      <AppError v-if="formError" :description="formError" />
      <el-form label-width="100px" @submit.prevent>
        <el-form-item label="业务类型">
          <span>{{ BIZ_LABELS[activeBiz] }}</span>
        </el-form-item>
        <el-form-item label="角色名称" required>
          <el-input v-model="form.name" maxlength="50" />
        </el-form-item>
        <el-form-item label="允许职务">
          <el-select
            v-model="form.jobTypeIds"
            multiple
            filterable
            collapse-tags
            collapse-tags-tooltip
            placeholder="可多选"
            style="width: 100%"
          >
            <el-option
              v-for="j in jobTypes"
              :key="j.id"
              :label="j.name"
              :value="j.id"
            />
          </el-select>
        </el-form-item>
        <el-form-item label="排序">
          <el-input-number v-model="form.sequence" :step="1" controls-position="right" />
        </el-form-item>
        <el-form-item v-if="formMode === 'edit'" label="状态">
          <el-switch v-model="form.active" active-text="启用" inactive-text="停用" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button :disabled="formSaving" @click="formVisible = false">取消</el-button>
        <el-button type="primary" :loading="formSaving" @click="handleSubmit">保存</el-button>
      </template>
    </el-dialog>
  </section>
</template>

<style scoped>
.sale-handler-config {
  display: flex;
  flex-direction: column;
  gap: 16px;
  min-height: 100%;
  padding: 20px 24px 24px;
}

.page-header h1 {
  margin: 0 0 4px;
  font-size: 20px;
  font-weight: 600;
  color: #303133;
}

.subtitle {
  margin: 0;
  font-size: 13px;
  color: #909399;
}

.toolbar {
  display: flex;
  gap: 8px;
}

.table-panel {
  min-height: 240px;
  padding: 16px;
  border: 1px solid #ebeef5;
  border-radius: 8px;
  background: #fff;
}
</style>
