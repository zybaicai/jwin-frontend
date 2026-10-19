<script setup lang="ts">
import { computed, nextTick, reactive, ref, watch } from 'vue'
import type { ElTree } from 'element-plus'

import AppEmpty from '@/components/common/AppEmpty.vue'
import AppError from '@/components/common/AppError.vue'
import {
  fetchEmployeePage,
  fetchEmployeeRoleAccess,
  fetchJobTypePage,
  fetchOrganizationTree,
  replaceEmployeeRoleAccess,
  type OrganizationTreeNode,
} from '@/api/hr'
import {
  OrgPermission,
  type EmployeeRecord,
  type EmployeeRoleAccess,
  type JobTypeRecord,
} from '@/types/hr'
import { usePermissionStore } from '@/stores/permission'
import { useStoreStore } from '@/stores/store'
import {
  getUserFriendlyErrorMessage,
  notifyError,
  runExclusive,
  uiMessage,
} from '@/utils/ui'

defineOptions({ name: 'UserPermissionView' })

const permissionStore = usePermissionStore()
const storeStore = useStoreStore()

const hasViewPermission = computed(() =>
  permissionStore.hasPermission(OrgPermission.PERMISSION_VIEW),
)
const hasEditPermission = computed(() =>
  permissionStore.hasPermission(OrgPermission.PERMISSION_EDIT),
)

const searchLoading = ref(false)
const employeeKeyword = ref('')
const searchEntityId = ref<number | null>(storeStore.currentStoreId)
const employeeOptions = ref<EmployeeRecord[]>([])
const selectedEmployeeId = ref<string | null>(null)

const loading = ref(false)
const loadError = ref<string | null>(null)
const access = ref<EmployeeRoleAccess | null>(null)

const jobTypes = ref<JobTypeRecord[]>([])
const orgTree = ref<OrganizationTreeNode[]>([])
const selectedJobTypeIds = ref<number[]>([])
const orgTreeRef = ref<InstanceType<typeof ElTree>>()
const saving = ref(false)

const form = reactive({
  dirty: false,
})

async function loadMeta(): Promise<void> {
  try {
    const [jobs, orgs] = await Promise.all([
      fetchJobTypePage({ active: true, page: 1, size: 200 }),
      fetchOrganizationTree(false),
    ])
    jobTypes.value = jobs.records ?? []
    orgTree.value = orgs
  } catch (error) {
    notifyError(error)
  }
}

async function searchEmployees(): Promise<void> {
  if (!hasViewPermission.value) return
  if (searchEntityId.value == null) {
    uiMessage.warning('请先选择查询组织')
    return
  }
  await runExclusive(searchLoading, async () => {
    try {
      const data = await fetchEmployeePage({
        entityId: searchEntityId.value!,
        keyword: employeeKeyword.value.trim() || undefined,
        page: 1,
        size: 50,
      })
      employeeOptions.value = data.records ?? []
    } catch (error) {
      employeeOptions.value = []
      notifyError(error)
    }
  })
}

async function loadAccess(employeeId: string): Promise<void> {
  await runExclusive(loading, async () => {
    loadError.value = null
    access.value = null
    try {
      const data = await fetchEmployeeRoleAccess(employeeId)
      access.value = data
      selectedJobTypeIds.value = (data.jobTypes ?? []).map((j) => j.id)
      await nextTick()
      orgTreeRef.value?.setCheckedKeys(data.orgEntityIds ?? [])
      form.dirty = false
    } catch (error) {
      loadError.value = getUserFriendlyErrorMessage(error)
    }
  })
}

function onEmployeeChange(id: string | null): void {
  selectedEmployeeId.value = id
  if (id) {
    void loadAccess(id)
  } else {
    access.value = null
    selectedJobTypeIds.value = []
  }
}

async function handleSave(): Promise<void> {
  if (!hasEditPermission.value || !selectedEmployeeId.value) return
  if (selectedJobTypeIds.value.length === 0) {
    uiMessage.warning('请至少选择一个职务（角色）')
    return
  }
  const checked = (orgTreeRef.value?.getCheckedKeys?.(false) ?? []) as Array<string | number>
  const orgEntityIds = checked.map(Number).filter((n) => Number.isFinite(n))
  if (orgEntityIds.length === 0) {
    uiMessage.warning('请至少勾选一个组织范围')
    return
  }
  await runExclusive(saving, async () => {
    try {
      const data = await replaceEmployeeRoleAccess(selectedEmployeeId.value!, {
        jobTypeIds: selectedJobTypeIds.value,
        orgEntityIds,
      })
      access.value = data
      selectedJobTypeIds.value = (data.jobTypes ?? []).map((j) => j.id)
      await nextTick()
      orgTreeRef.value?.setCheckedKeys(data.orgEntityIds ?? [])
      form.dirty = false
      uiMessage.success('用户权限已保存')
    } catch (error) {
      notifyError(error)
    }
  })
}

watch(
  () => storeStore.currentStoreId,
  (id) => {
    if (searchEntityId.value == null && id != null) {
      searchEntityId.value = id
    }
  },
  { immediate: true },
)

watch(
  hasViewPermission,
  async (ok) => {
    if (ok) {
      await loadMeta()
    }
  },
  { immediate: true },
)
</script>

<template>
  <section class="user-permission">
    <header class="page-header">
      <div>
        <h1>用户权限</h1>
        <p class="subtitle">为员工绑定权限角色（职务）与组织数据范围</p>
      </div>
    </header>

    <div class="filter-bar">
      <el-form :inline="true" class="filter-form" @submit.prevent="searchEmployees">
        <el-form-item label="组织" required>
          <el-tree-select
            v-model="searchEntityId"
            :data="orgTree"
            check-strictly
            filterable
            node-key="id"
            :props="{ label: 'entityName', children: 'children' }"
            placeholder="查询组织"
            style="width: 200px"
          />
        </el-form-item>
        <el-form-item label="员工">
          <el-input
            v-model="employeeKeyword"
            clearable
            placeholder="姓名/手机/工号"
            style="width: 160px"
          />
        </el-form-item>
        <el-form-item>
          <el-button type="primary" native-type="submit" :loading="searchLoading">搜索</el-button>
        </el-form-item>
        <el-form-item label="选择">
          <el-select
            :model-value="selectedEmployeeId"
            filterable
            clearable
            placeholder="选择员工"
            style="width: 240px"
            @update:model-value="onEmployeeChange"
          >
            <el-option
              v-for="e in employeeOptions"
              :key="e.id"
              :label="`${e.name}（${e.id}）`"
              :value="e.id"
            />
          </el-select>
        </el-form-item>
      </el-form>
    </div>

    <div v-loading="loading" class="body-panel">
      <AppError
        v-if="!hasViewPermission"
        description="暂无权限查看用户权限（org:permission:view）"
      />
      <AppError
        v-else-if="loadError"
        :description="loadError"
        @retry="() => selectedEmployeeId && loadAccess(selectedEmployeeId)"
      />
      <template v-else-if="!selectedEmployeeId">
        <AppEmpty title="请选择员工" description="先搜索并选择员工，再配置角色与组织范围" />
      </template>
      <template v-else>
        <el-alert
          v-if="access"
          type="info"
          :closable="false"
          show-icon
          :title="`员工：${access.employeeName || access.employeeId} · 数据范围：${access.dataScope || '—'}`"
          style="margin-bottom: 12px"
        />

        <div class="config-grid">
          <div class="config-card">
            <div class="card-title">权限角色（职务）</div>
            <el-select
              v-model="selectedJobTypeIds"
              multiple
              filterable
              collapse-tags
              collapse-tags-tooltip
              placeholder="至少选一个"
              style="width: 100%"
              @change="form.dirty = true"
            >
              <el-option
                v-for="j in jobTypes"
                :key="j.id"
                :label="j.name"
                :value="j.id"
              />
            </el-select>
          </div>

          <div class="config-card">
            <div class="card-title">组织范围</div>
            <el-tree
              ref="orgTreeRef"
              :data="orgTree"
              node-key="id"
              show-checkbox
              default-expand-all
              check-strictly
              :props="{ label: 'entityName', children: 'children' }"
              @check="form.dirty = true"
            >
              <template #default="{ data }">
                <span class="org-node">
                  <span>{{ data.entityName || `组织#${data.id}` }}</span>
                  <el-tag v-if="data.store === true" size="small" type="success" effect="plain">
                    门店
                  </el-tag>
                </span>
              </template>
            </el-tree>
          </div>
        </div>

        <div class="actions">
          <el-button
            v-if="hasEditPermission"
            type="primary"
            :loading="saving"
            @click="handleSave"
          >
            保存
          </el-button>
        </div>
      </template>
    </div>
  </section>
</template>

<style scoped>
.user-permission {
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

.filter-form {
  margin-bottom: 0;
}

.body-panel {
  min-height: 320px;
  padding: 16px;
  border: 1px solid #ebeef5;
  border-radius: 8px;
  background: #fff;
}

.config-grid {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 16px;
}

.config-card {
  padding: 12px;
  border: 1px solid #ebeef5;
  border-radius: 6px;
}

.card-title {
  margin-bottom: 10px;
  font-size: 14px;
  font-weight: 600;
  color: #303133;
}

.org-node {
  display: inline-flex;
  align-items: center;
  gap: 6px;
}

.actions {
  margin-top: 16px;
}

@media (max-width: 900px) {
  .config-grid {
    grid-template-columns: 1fr;
  }
}
</style>
