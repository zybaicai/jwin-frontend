<script setup lang="ts">
import { computed, ref, watch } from 'vue'

import AppEmpty from '@/components/common/AppEmpty.vue'
import AppError from '@/components/common/AppError.vue'
import {
  addCrossStoreEmployee,
  fetchCrossStoreEmployees,
  removeCrossStoreEmployee,
} from '@/api/hr'
import { OrgPermission, type CrossStoreEmployee } from '@/types/hr'
import { usePermissionStore } from '@/stores/permission'
import { useStoreStore } from '@/stores/store'
import {
  getUserFriendlyErrorMessage,
  notifyError,
  runExclusive,
  uiConfirm,
  uiMessage,
} from '@/utils/ui'

defineOptions({ name: 'CrossStoreEmployeeView' })

const permissionStore = usePermissionStore()
const storeStore = useStoreStore()

const hasViewPermission = computed(() =>
  permissionStore.hasPermission(OrgPermission.EMPLOYEE_VIEW),
)
const hasEditPermission = computed(() =>
  permissionStore.hasPermission(OrgPermission.EMPLOYEE_EDIT),
)

const loading = ref(false)
const listError = ref<string | null>(null)
const storeId = ref<number | null>(storeStore.currentStoreId)
const keywordInput = ref('')
const keyword = ref('')
const records = ref<CrossStoreEmployee[]>([])

const addVisible = ref(false)
const addSaving = ref(false)
const addEmployeeId = ref('')
const addError = ref<string | null>(null)
const removingIds = ref<Set<string>>(new Set())

const storeOptions = computed(() => storeStore.availableStores ?? [])

function rowOf(row: unknown): CrossStoreEmployee {
  return row as CrossStoreEmployee
}

async function loadList(): Promise<void> {
  if (!hasViewPermission.value) {
    records.value = []
    listError.value = '暂无权限查看跨店员工（org:employee:view）'
    return
  }
  if (storeId.value == null) {
    records.value = []
    listError.value = null
    return
  }
  await runExclusive(loading, async () => {
    listError.value = null
    try {
      records.value = await fetchCrossStoreEmployees(
        storeId.value!,
        keyword.value.trim() || undefined,
      )
    } catch (error) {
      records.value = []
      listError.value = getUserFriendlyErrorMessage(error)
    }
  })
}

function handleSearch(): void {
  keyword.value = keywordInput.value.trim()
  void loadList()
}

function handleReset(): void {
  keywordInput.value = ''
  keyword.value = ''
  void loadList()
}

function openAdd(): void {
  if (storeId.value == null) {
    uiMessage.warning('请先选择门店')
    return
  }
  addEmployeeId.value = ''
  addError.value = null
  addVisible.value = true
}

async function handleAdd(): Promise<void> {
  if (!hasEditPermission.value || storeId.value == null) return
  const empId = addEmployeeId.value.trim()
  if (!empId) {
    uiMessage.warning('请填写员工工号')
    return
  }
  await runExclusive(addSaving, async () => {
    addError.value = null
    try {
      await addCrossStoreEmployee(storeId.value!, empId)
      uiMessage.success('已添加跨店员工')
      addVisible.value = false
      await loadList()
    } catch (error) {
      addError.value = getUserFriendlyErrorMessage(error)
      notifyError(error)
    }
  })
}

async function handleRemove(row: CrossStoreEmployee): Promise<void> {
  if (!hasEditPermission.value || storeId.value == null) return
  if (row.primaryEntityId === storeId.value) {
    uiMessage.warning('不能移除主店归属，后端将拒绝该操作')
    return
  }
  const ok = await uiConfirm({
    title: '移除跨店',
    message: `确认将「${row.name || row.employeeId}」从本店跨店名单移除？若为本店主店员工，后端将拒绝。`,
    confirmText: '移除',
  })
  if (!ok) return

  const id = row.employeeId
  const next = new Set(removingIds.value)
  next.add(id)
  removingIds.value = next
  try {
    await removeCrossStoreEmployee(storeId.value, id)
    uiMessage.success('已移除')
    await loadList()
  } catch (error) {
    notifyError(error)
  } finally {
    const cleared = new Set(removingIds.value)
    cleared.delete(id)
    removingIds.value = cleared
  }
}

watch(
  () => storeStore.currentStoreId,
  (id) => {
    if (storeId.value == null && id != null) {
      storeId.value = id
    }
  },
  { immediate: true },
)

watch([storeId, hasViewPermission], () => void loadList(), { immediate: true })
</script>

<template>
  <section class="cross-store-employee">

    <div class="filter-bar">
      <div class="filter-toolbar">
        <el-form :inline="true" class="filter-form" @submit.prevent="handleSearch">
          <el-form-item label="门店" required>
            <el-select
              v-model="storeId"
              filterable
              placeholder="选择门店"
              style="width: 200px"
            >
              <el-option
                v-for="s in storeOptions"
                :key="s.id"
                :label="s.name"
                :value="s.id"
              />
            </el-select>
          </el-form-item>
          <el-form-item label="关键词">
            <el-input
              v-model="keywordInput"
              clearable
              placeholder="姓名/手机/工号"
              style="max-width: 180px"
            />
          </el-form-item>
          <el-form-item>
            <el-button type="primary" native-type="submit" :loading="loading" :disabled="storeId == null">
              查询
            </el-button>
            <el-button native-type="button" :disabled="loading" @click="handleReset">重置</el-button>
          </el-form-item>
        </el-form>
        <el-button
          v-if="hasEditPermission"
          class="create-btn"
          type="primary"
          @click="openAdd"
        >
          添加跨店员工
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
        <el-table :data="records" border stripe size="small" empty-text=" ">
          <el-table-column prop="employeeId" label="工号" width="120" show-overflow-tooltip />
          <el-table-column prop="name" label="姓名" min-width="100" show-overflow-tooltip>
            <template #default="{ row }">
              {{ rowOf(row).name || '—' }}
            </template>
          </el-table-column>
          <el-table-column prop="phoneNumber" label="手机" width="130" show-overflow-tooltip />
          <el-table-column prop="jobName" label="职务" min-width="110" show-overflow-tooltip>
            <template #default="{ row }">
              {{ rowOf(row).jobName || '—' }}
            </template>
          </el-table-column>
          <el-table-column label="主店" min-width="140" show-overflow-tooltip>
            <template #default="{ row }">
              {{ rowOf(row).primaryEntityName || (rowOf(row).primaryEntityId != null ? `#${rowOf(row).primaryEntityId}` : '—') }}
            </template>
          </el-table-column>
          <el-table-column label="跨店门店" min-width="140" show-overflow-tooltip>
            <template #default="{ row }">
              {{ rowOf(row).storeName || (rowOf(row).storeId != null ? `#${rowOf(row).storeId}` : '—') }}
            </template>
          </el-table-column>
          <el-table-column label="操作" width="100" fixed="right">
            <template #default="{ row }">
              <el-button
                v-if="hasEditPermission"
                link
                type="danger"
                :loading="removingIds.has(rowOf(row).employeeId)"
                @click="handleRemove(rowOf(row))"
              >
                移除
              </el-button>
            </template>
          </el-table-column>
        </el-table>

        <AppEmpty
          v-if="!loading && !listError && storeId != null && records.length === 0"
          title="暂无跨店员工"
          description="可点击「添加跨店员工」按工号加入"
        />
      </template>
    </div>

    <el-dialog
      v-model="addVisible"
      title="添加跨店员工"
      width="420px"
      destroy-on-close
      :close-on-click-modal="false"
    >
      <AppError v-if="addError" :description="addError" />
      <el-form label-width="90px" @submit.prevent>
        <el-form-item label="员工工号" required>
          <el-input v-model="addEmployeeId" placeholder="输入已有员工工号" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button :disabled="addSaving" @click="addVisible = false">取消</el-button>
        <el-button type="primary" :loading="addSaving" @click="handleAdd">确定</el-button>
      </template>
    </el-dialog>
  </section>
</template>

<style scoped>
.cross-store-employee {
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
</style>
