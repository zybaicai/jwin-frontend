<script setup lang="ts">
import { computed, ref, watch } from 'vue'

import AppError from '@/components/common/AppError.vue'
import { fetchCustomerProfileSettings, saveCustomerProfileSettings } from '@/api/customer'
import { CustomerPermission, type CustomerProfileField } from '@/types/customer'
import { usePermissionStore } from '@/stores/permission'
import { getUserFriendlyErrorMessage, notifyError, runExclusive, uiMessage } from '@/utils/ui'

defineOptions({ name: 'CustomerProfileSceneView' })

const permissionStore = usePermissionStore()
const canView = computed(() => permissionStore.hasPermission(CustomerPermission.FORM_VIEW))
const canEdit = computed(() => permissionStore.hasPermission(CustomerPermission.FORM_EDIT))

const loading = ref(false)
const saving = ref(false)
const errorText = ref<string | null>(null)
const rows = ref<CustomerProfileField[]>([])

const choice = computed(() => {
  const map: Record<string, string> = {}
  for (const row of rows.value) {
    map[row.fieldCode] = row.requirement === 'SYSTEM_REQUIRED' ? 'SYSTEM_REQUIRED' : row.requirement
  }
  return map
})

async function load(): Promise<void> {
  if (!canView.value) {
    rows.value = []
    errorText.value = '暂无权限查看档案应用场景（customer:form:view）'
    return
  }
  await runExclusive(loading, async () => {
    errorText.value = null
    try {
      rows.value = await fetchCustomerProfileSettings()
    } catch (error) {
      rows.value = []
      errorText.value = getUserFriendlyErrorMessage(error)
    }
  })
}

function onRequirementChange(row: unknown, requirement: unknown): void {
  const item = row as CustomerProfileField
  if (item.requirement === 'SYSTEM_REQUIRED') return
  item.requirement = String(requirement)
}

async function save(): Promise<void> {
  if (!canEdit.value) return
  await runExclusive(saving, async () => {
    try {
      rows.value = await saveCustomerProfileSettings(
        rows.value
          .filter((row) => row.requirement !== 'SYSTEM_REQUIRED')
          .map((row) => ({ fieldCode: row.fieldCode, requirement: row.requirement })),
      )
      uiMessage.success('已保存，之后所有创建客户入口都按这份配置校验')
    } catch (error) {
      notifyError(error)
    }
  })
}

watch(canView, () => void load(), { immediate: true })
</script>

<template>
  <section class="scene-page">
    <header class="page-header">
      <el-button v-if="canEdit" type="primary" :loading="saving" @click="save">保存</el-button>
    </header>
    <AppError v-if="errorText && !loading" :description="errorText" @retry="load" />
    <el-table v-else v-loading="loading" :data="rows" border>
      <el-table-column prop="fieldName" label="字段" min-width="160" />
      <el-table-column label="状态" min-width="280">
        <template #default="{ row }">
          <span v-if="row.requirement === 'SYSTEM_REQUIRED'" class="system-required">系统必填</span>
          <el-radio-group
            v-else
            :model-value="choice[row.fieldCode]"
            :disabled="!canEdit"
            @update:model-value="onRequirementChange(row, $event)"
          >
            <el-radio value="REQUIRED">必填</el-radio>
            <el-radio value="OPTIONAL">选填</el-radio>
          </el-radio-group>
        </template>
      </el-table-column>
      <el-table-column label="说明" min-width="220">
        <template #default="{ row }">{{ row.remark || '—' }}</template>
      </el-table-column>
    </el-table>
  </section>
</template>

<style scoped>
.scene-page {
  padding: 20px 24px 32px;
}
.page-header {
  display: flex;
  align-items: flex-start;
  justify-content: space-between;
  gap: 12px;
  margin-bottom: 16px;
}
.page-header h1 {
  margin: 0 0 6px;
  font-size: 20px;
}
.subtitle {
  margin: 0;
  color: #909399;
  font-size: 13px;
}
.system-required {
  color: var(--el-color-primary);
  font-weight: 600;
}
</style>
