<script setup lang="ts">
import { onMounted, reactive, ref } from 'vue'
import { ElMessage } from 'element-plus'

import { fetchAssetOpsConfig, saveAssetOpsConfig } from '@/api/asset-ops'
import type { AssetOpsConfig, UpsertAssetOpsConfigBody } from '@/types/asset-ops'
import { RefundPermission } from '@/types/refund'
import { usePermissionStore } from '@/stores/permission'
import { useStoreStore } from '@/stores/store'
import { getUserFriendlyErrorMessage, runExclusive } from '@/utils/ui'

defineOptions({ name: 'RefundConfigView' })

const permissionStore = usePermissionStore()
const storeStore = useStoreStore()

const loading = ref(false)
const saving = ref(false)
const approvers = ref<AssetOpsConfig['refundApprovers']>([])

const form = reactive({
  roleCode: 'STORE_MANAGER',
  employeeId: '',
  jobTypeId: null as number | null,
})

const canEdit = permissionStore.hasPermission(RefundPermission.ORDER_APPROVE)

async function load(): Promise<void> {
  await runExclusive(loading, async () => {
    try {
      const data = await fetchAssetOpsConfig(storeStore.currentStoreId)
      approvers.value = data.refundApprovers ?? []
      const first = approvers.value[0]
      if (first) {
        form.roleCode = first.roleCode
        form.employeeId = first.employeeId ?? ''
        form.jobTypeId = first.jobTypeId ?? null
      }
    } catch (e) {
      ElMessage.error(getUserFriendlyErrorMessage(e))
    }
  })
}

async function save(): Promise<void> {
  const body: UpsertAssetOpsConfigBody = {
    storeId: storeStore.currentStoreId,
    refundApprovers: [
      {
        roleCode: form.roleCode,
        employeeId: form.roleCode === 'EMPLOYEE' ? form.employeeId || null : null,
        jobTypeId: form.roleCode === 'JOB_TYPE' ? form.jobTypeId : null,
        levelNo: 1,
      },
    ],
  }
  await runExclusive(saving, async () => {
    try {
      const data = await saveAssetOpsConfig(body)
      approvers.value = data.refundApprovers ?? []
      ElMessage.success('退款审批配置已保存')
    } catch (e) {
      ElMessage.error(getUserFriendlyErrorMessage(e))
    }
  })
}

onMounted(() => {
  void load()
})
</script>

<template>
  <div class="page">
    <h3 class="title">退款配置（预留）</h3>
    <p class="desc">
      审批复用组织配置表 <code>TB_ErpApprovalRoleConfig</code>，BizType=<code>REFUND</code>。
      未配置或未命中时不可审批；不新建退款审批人员表。
    </p>

    <div v-loading="loading" class="card">
      <el-form label-width="140px" style="max-width: 480px">
        <el-form-item label="退款审批角色">
          <el-select v-model="form.roleCode" style="width: 100%" :disabled="!canEdit">
            <el-option label="店长（职务名含店长/经理）" value="STORE_MANAGER" />
            <el-option label="财务（职务名含财务/会计）" value="FINANCE" />
            <el-option label="指定员工" value="EMPLOYEE" />
            <el-option label="指定职务ID" value="JOB_TYPE" />
          </el-select>
        </el-form-item>
        <el-form-item v-if="form.roleCode === 'EMPLOYEE'" label="员工ID">
          <el-input v-model="form.employeeId" placeholder="TK_Employee.ID" :disabled="!canEdit" />
        </el-form-item>
        <el-form-item v-if="form.roleCode === 'JOB_TYPE'" label="职务ID">
          <el-input-number v-model="form.jobTypeId" :min="1" :disabled="!canEdit" />
        </el-form-item>
        <el-form-item>
          <el-button type="primary" :loading="saving" :disabled="!canEdit" @click="save">
            保存
          </el-button>
          <el-button :disabled="loading" @click="load">刷新</el-button>
        </el-form-item>
      </el-form>

      <div v-if="approvers?.length" class="current">
        <div class="label">当前生效配置：</div>
        <ul>
          <li v-for="(a, i) in approvers" :key="a.id ?? i">
            {{ a.roleCode }}
            <template v-if="a.employeeName || a.employeeId">
              / 员工 {{ a.employeeName || a.employeeId }}
            </template>
            <template v-if="a.jobTypeName || a.jobTypeId">
              / 职务 {{ a.jobTypeName || a.jobTypeId }}
            </template>
          </li>
        </ul>
      </div>
      <p v-else class="hint">尚未配置退款审批人，待审批页将无法通过/拒绝。</p>
    </div>
  </div>
</template>

<style scoped>
.page {
  padding: 16px 20px;
}

.title {
  margin: 0 0 8px;
  font-size: 16px;
}

.desc {
  margin: 0 0 16px;
  color: var(--el-text-color-secondary);
  font-size: 13px;
  line-height: 1.6;
}

.card {
  background: var(--el-bg-color);
  border: 1px solid var(--el-border-color-lighter);
  border-radius: 8px;
  padding: 16px;
}

.current {
  margin-top: 12px;
  font-size: 13px;
}

.current ul {
  margin: 6px 0 0;
  padding-left: 18px;
}

.hint {
  margin-top: 12px;
  color: var(--el-color-warning);
  font-size: 13px;
}

.label {
  font-weight: 600;
}
</style>
