<script setup lang="ts">
import { computed, ref } from 'vue'
import { useRouter } from 'vue-router'

import { useAuthStore } from '@/stores/auth'
import { useTabsStore } from '@/stores/tabs'
import { ApiBusinessError, ApiHttpError } from '@/utils/api-error'
import { uiConfirm } from '@/utils/ui'

const router = useRouter()
const authStore = useAuthStore()
const tabsStore = useTabsStore()
const loggingOut = ref(false)

const employeeName = computed(
  () => authStore.employee?.name ?? authStore.currentUser?.employeeName ?? '—',
)
const jobName = computed(() => authStore.employee?.jobName ?? authStore.currentUser?.jobName ?? '')

async function confirmLogout(): Promise<void> {
  if (loggingOut.value) {
    return
  }
  const confirmed = await uiConfirm({
    title: '退出登录',
    message: '确定退出当前账号吗？',
    confirmText: '确定',
    cancelText: '取消',
  })
  if (!confirmed) {
    return
  }
  loggingOut.value = true
  try {
    await authStore.logout()
  } catch (error) {
    if (!(error instanceof ApiBusinessError) && !(error instanceof ApiHttpError)) {
      throw error
    }
  } finally {
    tabsStore.clear()
    loggingOut.value = false
    await router.replace({ name: 'login' })
  }
}
</script>

<template>
  <el-dropdown trigger="click">
    <button type="button" class="user-trigger">
      <span class="user-name">{{ employeeName }}</span>
      <span aria-hidden="true">▼</span>
    </button>
    <template #dropdown>
      <el-dropdown-menu>
        <div class="user-summary">
          <strong>{{ employeeName }}</strong>
          <span v-if="jobName">{{ jobName }}</span>
        </div>
        <el-dropdown-item divided disabled title="修改密码功能暂未开放">修改密码</el-dropdown-item>
        <el-dropdown-item :disabled="loggingOut" @click="confirmLogout">退出登录</el-dropdown-item>
      </el-dropdown-menu>
    </template>
  </el-dropdown>
</template>

<style scoped>
.user-trigger {
  display: inline-flex;
  align-items: center;
  max-width: 140px;
  gap: 4px;
  padding: 0;
  border: 0;
  background: transparent;
  color: inherit;
  cursor: pointer;
  font: inherit;
}

.user-name {
  overflow: hidden;
  font-weight: 600;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.user-summary {
  display: flex;
  flex-direction: column;
  gap: 4px;
  padding: 8px 16px 4px;
  color: #303133;
}

.user-summary span {
  color: #909399;
  font-size: 13px;
}
</style>
