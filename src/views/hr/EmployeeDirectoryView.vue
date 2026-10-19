<script setup lang="ts">
import { computed, reactive, ref, watch } from 'vue'

import AppEmpty from '@/components/common/AppEmpty.vue'
import AppError from '@/components/common/AppError.vue'
import {
  createEmployee,
  fetchEmployeeDetail,
  fetchEmployeePage,
  fetchJobTypePage,
  fetchOrganizationTree,
  updateEmployee,
  type OrganizationTreeNode,
} from '@/api/hr'
import {
  OrgPermission,
  type EmployeeRecord,
  type JobTypeRecord,
} from '@/types/hr'
import { usePermissionStore } from '@/stores/permission'
import {
  getUserFriendlyErrorMessage,
  notifyError,
  runExclusive,
  uiMessage,
} from '@/utils/ui'

defineOptions({ name: 'EmployeeDirectoryView' })

const permissionStore = usePermissionStore()

const hasViewPermission = computed(() =>
  permissionStore.hasPermission(OrgPermission.EMPLOYEE_VIEW),
)
const hasEditPermission = computed(() =>
  permissionStore.hasPermission(OrgPermission.EMPLOYEE_EDIT),
)

const loading = ref(false)
const listError = ref<string | null>(null)
const orgTree = ref<OrganizationTreeNode[]>([])
const jobTypes = ref<JobTypeRecord[]>([])

const entityId = ref<number | null>(null)
const keywordInput = ref('')
const keyword = ref('')
const jobId = ref<number | null>(null)
const stateFilter = ref<'' | 'true' | 'false'>('')
const page = ref(1)
const size = ref(20)
const total = ref(0)
const records = ref<EmployeeRecord[]>([])

const drawerVisible = ref(false)
const drawerLoading = ref(false)
const detail = ref<EmployeeRecord | null>(null)

const formVisible = ref(false)
const formMode = ref<'create' | 'edit'>('create')
const formLoading = ref(false)
const formSaving = ref(false)
const formError = ref<string | null>(null)
const editingId = ref<string | null>(null)

const form = reactive({
  id: '',
  name: '',
  alias: '',
  phoneNumber: '',
  gender: '',
  jobId: null as number | null,
  entityId: null as number | null,
  idNumber: '',
  address: '',
  entryDate: '',
  contractStartDate: '',
  contractEndDate: '',
  remark: '',
  password: '',
  state: true,
})

function rowOf(row: unknown): EmployeeRecord {
  return row as EmployeeRecord
}

function primaryStoreName(row: EmployeeRecord): string {
  const primary = (row.entities ?? []).find((e) => e.primaryEntity === true)
  return primary?.entityName?.trim() || (primary ? `组织#${primary.entityId}` : '—')
}

async function loadOrgTree(): Promise<void> {
  try {
    orgTree.value = await fetchOrganizationTree(false)
  } catch {
    orgTree.value = []
  }
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
    total.value = 0
    listError.value = '暂无权限查看员工（org:employee:view）'
    return
  }
  if (entityId.value == null) {
    records.value = []
    total.value = 0
    listError.value = null
    return
  }
  await runExclusive(loading, async () => {
    listError.value = null
    try {
      const data = await fetchEmployeePage({
        entityId: entityId.value!,
        keyword: keyword.value.trim() || undefined,
        jobId: jobId.value ?? undefined,
        state:
          stateFilter.value === 'true'
            ? true
            : stateFilter.value === 'false'
              ? false
              : undefined,
        page: page.value,
        size: size.value,
      })
      records.value = data.records ?? []
      total.value = data.total ?? 0
      page.value = data.page || page.value
      size.value = data.size || size.value
      if (total.value > 0 && records.value.length === 0 && page.value > 1) {
        page.value -= 1
        await loadList()
      }
    } catch (error) {
      records.value = []
      total.value = 0
      listError.value = getUserFriendlyErrorMessage(error)
    }
  })
}

function handleSearch(): void {
  keyword.value = keywordInput.value.trim()
  page.value = 1
  void loadList()
}

function handleReset(): void {
  keywordInput.value = ''
  keyword.value = ''
  jobId.value = null
  stateFilter.value = ''
  page.value = 1
  void loadList()
}

function handlePageChange(next: number): void {
  page.value = next
  void loadList()
}

function handleSizeChange(next: number): void {
  size.value = next
  page.value = 1
  void loadList()
}

async function openDetail(row: EmployeeRecord): Promise<void> {
  drawerVisible.value = true
  drawerLoading.value = true
  detail.value = null
  try {
    detail.value = await fetchEmployeeDetail(row.id)
  } catch (error) {
    notifyError(error)
    detail.value = row
  } finally {
    drawerLoading.value = false
  }
}

function resetForm(): void {
  form.id = ''
  form.name = ''
  form.alias = ''
  form.phoneNumber = ''
  form.gender = ''
  form.jobId = null
  form.entityId = entityId.value
  form.idNumber = ''
  form.address = ''
  form.entryDate = ''
  form.contractStartDate = ''
  form.contractEndDate = ''
  form.remark = ''
  form.password = ''
  form.state = true
}

function openCreate(): void {
  if (entityId.value == null) {
    uiMessage.warning('请先选择所属组织')
    return
  }
  formMode.value = 'create'
  editingId.value = null
  resetForm()
  formError.value = null
  formVisible.value = true
}

async function openEdit(row: EmployeeRecord): Promise<void> {
  formMode.value = 'edit'
  editingId.value = row.id
  formError.value = null
  formVisible.value = true
  formLoading.value = true
  try {
    const d = await fetchEmployeeDetail(row.id)
    form.id = d.id
    form.name = d.name ?? ''
    form.alias = d.alias ?? ''
    form.phoneNumber = d.phoneNumber ?? ''
    form.gender = d.gender ?? ''
    form.jobId = d.jobId
    const primary = (d.entities ?? []).find((e) => e.primaryEntity === true)
    form.entityId = primary?.entityId ?? entityId.value
    form.idNumber = d.idNumber ?? ''
    form.address = d.address ?? ''
    form.entryDate = d.entryDate ?? ''
    form.contractStartDate = d.contractStartDate ?? ''
    form.contractEndDate = d.contractEndDate ?? ''
    form.remark = d.remark ?? ''
    form.password = ''
    form.state = d.state !== false
  } catch (error) {
    notifyError(error)
  } finally {
    formLoading.value = false
  }
}

async function handleSubmit(): Promise<void> {
  if (!hasEditPermission.value) return
  if (!form.name.trim()) {
    uiMessage.warning('请填写姓名')
    return
  }
  if (!form.phoneNumber.trim()) {
    uiMessage.warning('请填写手机号')
    return
  }
  if (form.jobId == null) {
    uiMessage.warning('请选择职务')
    return
  }
  if (form.entityId == null) {
    uiMessage.warning('请选择所属组织')
    return
  }
  if (formMode.value === 'create' && !form.id.trim()) {
    uiMessage.warning('请填写工号/账号')
    return
  }
  await runExclusive(formSaving, async () => {
    formError.value = null
    try {
      if (formMode.value === 'create') {
        await createEmployee({
          id: form.id.trim(),
          name: form.name.trim(),
          alias: form.alias.trim() || undefined,
          phoneNumber: form.phoneNumber.trim(),
          gender: form.gender || undefined,
          jobId: form.jobId!,
          entityId: form.entityId!,
          idNumber: form.idNumber.trim() || undefined,
          address: form.address.trim() || undefined,
          entryDate: form.entryDate || undefined,
          contractStartDate: form.contractStartDate || undefined,
          contractEndDate: form.contractEndDate || undefined,
          remark: form.remark.trim() || undefined,
          password: form.password || undefined,
          state: form.state,
        })
        uiMessage.success('员工已创建')
      } else if (editingId.value) {
        await updateEmployee(editingId.value, {
          name: form.name.trim(),
          alias: form.alias.trim() || undefined,
          phoneNumber: form.phoneNumber.trim(),
          gender: form.gender || undefined,
          jobId: form.jobId!,
          entityId: form.entityId!,
          idNumber: form.idNumber.trim() || undefined,
          address: form.address.trim() || undefined,
          entryDate: form.entryDate || undefined,
          contractStartDate: form.contractStartDate || undefined,
          contractEndDate: form.contractEndDate || undefined,
          remark: form.remark.trim() || undefined,
          state: form.state,
          password: form.password || undefined,
        })
        uiMessage.success('员工已更新')
      }
      formVisible.value = false
      await loadList()
    } catch (error) {
      formError.value = getUserFriendlyErrorMessage(error)
      notifyError(error)
    }
  })
}

watch(entityId, () => {
  page.value = 1
  void loadList()
})

watch(
  hasViewPermission,
  async (ok) => {
    if (ok) {
      await Promise.all([loadOrgTree(), loadJobTypes()])
      void loadList()
    } else {
      void loadList()
    }
  },
  { immediate: true },
)
</script>

<template>
  <section class="employee-directory">
    <header class="page-header">
      <div>
        <h1>员工档案</h1>
        <p class="subtitle">按组织查询员工；详情展示主店与跨店归属</p>
      </div>
    </header>

    <div class="filter-bar">
      <div class="filter-toolbar">
        <el-form :inline="true" class="filter-form" @submit.prevent="handleSearch">
          <el-form-item label="所属组织" required>
            <el-tree-select
              v-model="entityId"
              :data="orgTree"
              check-strictly
              filterable
              clearable
              node-key="id"
              :props="{ label: 'entityName', children: 'children' }"
              placeholder="必选组织"
              style="width: 220px"
            />
          </el-form-item>
          <el-form-item label="关键词">
            <el-input
              v-model="keywordInput"
              clearable
              placeholder="姓名/手机/工号"
              style="max-width: 180px"
            />
          </el-form-item>
          <el-form-item label="职务">
            <el-select v-model="jobId" clearable filterable placeholder="全部" style="width: 160px">
              <el-option
                v-for="j in jobTypes"
                :key="j.id"
                :label="j.name"
                :value="j.id"
              />
            </el-select>
          </el-form-item>
          <el-form-item label="状态">
            <el-select v-model="stateFilter" clearable placeholder="全部" style="width: 120px">
              <el-option label="全部" value="" />
              <el-option label="在职" value="true" />
              <el-option label="离职" value="false" />
            </el-select>
          </el-form-item>
          <el-form-item>
            <el-button type="primary" native-type="submit" :loading="loading" :disabled="entityId == null">
              查询
            </el-button>
            <el-button native-type="button" :disabled="loading" @click="handleReset">重置</el-button>
          </el-form-item>
        </el-form>
        <el-button
          v-if="hasEditPermission"
          class="create-btn"
          type="primary"
          @click="openCreate"
        >
          新增员工
        </el-button>
      </div>
    </div>

    <div v-loading="loading" class="table-panel">
      <AppError
        v-if="listError && !loading"
        :description="listError"
        @retry="loadList"
      />
      <template v-else>
        <el-alert
          v-if="entityId == null"
          type="info"
          :closable="false"
          show-icon
          title="请先选择所属组织后再查询员工"
          style="margin-bottom: 12px"
        />
        <el-table :data="records" border stripe size="small" empty-text=" ">
          <el-table-column prop="id" label="工号" width="120" show-overflow-tooltip />
          <el-table-column prop="name" label="姓名" min-width="100" show-overflow-tooltip />
          <el-table-column prop="phoneNumber" label="手机" width="130" show-overflow-tooltip />
          <el-table-column prop="jobName" label="职务" min-width="110" show-overflow-tooltip>
            <template #default="{ row }">
              {{ rowOf(row).jobName || '—' }}
            </template>
          </el-table-column>
          <el-table-column label="主店" min-width="120" show-overflow-tooltip>
            <template #default="{ row }">
              {{ primaryStoreName(rowOf(row)) }}
            </template>
          </el-table-column>
          <el-table-column label="状态" width="90">
            <template #default="{ row }">
              <el-tag :type="rowOf(row).state !== false ? 'success' : 'info'" size="small">
                {{ rowOf(row).state !== false ? '在职' : '离职' }}
              </el-tag>
            </template>
          </el-table-column>
          <el-table-column label="操作" width="140" fixed="right">
            <template #default="{ row }">
              <el-button link type="primary" @click="openDetail(rowOf(row))">详情</el-button>
              <el-button
                v-if="hasEditPermission"
                link
                type="primary"
                @click="openEdit(rowOf(row))"
              >
                编辑
              </el-button>
            </template>
          </el-table-column>
        </el-table>

        <AppEmpty
          v-if="!loading && !listError && entityId != null && records.length === 0"
          title="暂无员工"
          description="可点击「新增员工」创建档案"
        />

        <div v-if="total > 0" class="pager">
          <el-pagination
            background
            layout="total, sizes, prev, pager, next"
            :total="total"
            :current-page="page"
            :page-size="size"
            :page-sizes="[10, 20, 50, 100]"
            @current-change="handlePageChange"
            @size-change="handleSizeChange"
          />
        </div>
      </template>
    </div>

    <el-drawer v-model="drawerVisible" title="员工详情" size="420px" destroy-on-close>
      <div v-loading="drawerLoading">
        <template v-if="detail">
          <el-descriptions :column="1" border size="small">
            <el-descriptions-item label="工号">{{ detail.id }}</el-descriptions-item>
            <el-descriptions-item label="姓名">{{ detail.name }}</el-descriptions-item>
            <el-descriptions-item label="别名">{{ detail.alias || '—' }}</el-descriptions-item>
            <el-descriptions-item label="手机">{{ detail.phoneNumber || '—' }}</el-descriptions-item>
            <el-descriptions-item label="职务">{{ detail.jobName || '—' }}</el-descriptions-item>
            <el-descriptions-item label="性别">{{ detail.genderName || detail.gender || '—' }}</el-descriptions-item>
            <el-descriptions-item label="状态">
              {{ detail.state !== false ? '在职' : '离职' }}
            </el-descriptions-item>
            <el-descriptions-item label="备注">{{ detail.remark || '—' }}</el-descriptions-item>
          </el-descriptions>
          <h3 class="drawer-section-title">门店归属</h3>
          <el-table :data="detail.entities ?? []" border size="small" empty-text="无归属">
            <el-table-column prop="entityName" label="组织/门店" min-width="140">
              <template #default="{ row }">
                {{ row.entityName || `组织#${row.entityId}` }}
              </template>
            </el-table-column>
            <el-table-column label="类型" width="90">
              <template #default="{ row }">
                <el-tag :type="row.primaryEntity ? 'success' : 'warning'" size="small">
                  {{ row.primaryEntity ? '主店' : '跨店' }}
                </el-tag>
              </template>
            </el-table-column>
          </el-table>
        </template>
      </div>
    </el-drawer>

    <el-dialog
      v-model="formVisible"
      :title="formMode === 'create' ? '新增员工' : '编辑员工'"
      width="560px"
      destroy-on-close
      :close-on-click-modal="false"
    >
      <div v-loading="formLoading">
        <AppError v-if="formError" :description="formError" />
        <el-form label-width="100px" @submit.prevent>
          <el-form-item v-if="formMode === 'create'" label="工号" required>
            <el-input v-model="form.id" maxlength="40" placeholder="登录账号/工号" />
          </el-form-item>
          <el-form-item label="姓名" required>
            <el-input v-model="form.name" maxlength="50" />
          </el-form-item>
          <el-form-item label="别名">
            <el-input v-model="form.alias" maxlength="50" />
          </el-form-item>
          <el-form-item label="手机" required>
            <el-input v-model="form.phoneNumber" maxlength="20" />
          </el-form-item>
          <el-form-item label="职务" required>
            <el-select v-model="form.jobId" filterable style="width: 100%">
              <el-option
                v-for="j in jobTypes"
                :key="j.id"
                :label="j.name"
                :value="j.id"
              />
            </el-select>
          </el-form-item>
          <el-form-item label="所属组织" required>
            <el-tree-select
              v-model="form.entityId"
              :data="orgTree"
              check-strictly
              filterable
              node-key="id"
              :props="{ label: 'entityName', children: 'children' }"
              style="width: 100%"
            />
          </el-form-item>
          <el-form-item label="性别">
            <el-select v-model="form.gender" clearable style="width: 100%">
              <el-option label="男" value="M" />
              <el-option label="女" value="F" />
            </el-select>
          </el-form-item>
          <el-form-item label="身份证">
            <el-input v-model="form.idNumber" maxlength="30" />
          </el-form-item>
          <el-form-item label="地址">
            <el-input v-model="form.address" maxlength="200" />
          </el-form-item>
          <el-form-item label="入职日">
            <el-date-picker
              v-model="form.entryDate"
              type="date"
              value-format="YYYY-MM-DD"
              style="width: 100%"
            />
          </el-form-item>
          <el-form-item label="合同起止">
            <div class="date-row">
              <el-date-picker
                v-model="form.contractStartDate"
                type="date"
                value-format="YYYY-MM-DD"
                placeholder="开始"
                style="width: 48%"
              />
              <el-date-picker
                v-model="form.contractEndDate"
                type="date"
                value-format="YYYY-MM-DD"
                placeholder="结束"
                style="width: 48%"
              />
            </div>
          </el-form-item>
          <el-form-item label="密码">
            <el-input
              v-model="form.password"
              type="password"
              show-password
              :placeholder="formMode === 'create' ? '可选' : '留空不改'"
            />
          </el-form-item>
          <el-form-item label="状态">
            <el-switch v-model="form.state" active-text="在职" inactive-text="离职" />
          </el-form-item>
          <el-form-item label="备注">
            <el-input v-model="form.remark" type="textarea" :rows="2" maxlength="200" />
          </el-form-item>
        </el-form>
      </div>
      <template #footer>
        <el-button :disabled="formSaving" @click="formVisible = false">取消</el-button>
        <el-button
          type="primary"
          :loading="formSaving"
          :disabled="!hasEditPermission || formLoading"
          @click="handleSubmit"
        >
          保存
        </el-button>
      </template>
    </el-dialog>
  </section>
</template>

<style scoped>
.employee-directory {
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

.filter-bar {
  background: #fff;
  border: 1px solid #ebeef5;
  border-radius: 4px;
  padding: 12px 14px;
}

.filter-toolbar {
  display: flex;
  align-items: flex-start;
  justify-content: space-between;
  gap: 12px;
  flex-wrap: wrap;
}

.filter-form {
  flex: 1;
  margin-bottom: 0;
}

.create-btn {
  flex-shrink: 0;
  margin-top: 2px;
}

.table-panel {
  min-height: 240px;
  padding: 16px;
  border: 1px solid #ebeef5;
  border-radius: 8px;
  background: #fff;
}

.pager {
  display: flex;
  justify-content: flex-end;
  margin-top: 12px;
}

.drawer-section-title {
  margin: 16px 0 8px;
  font-size: 14px;
  font-weight: 600;
  color: #303133;
}

.date-row {
  display: flex;
  justify-content: space-between;
  width: 100%;
}
</style>
