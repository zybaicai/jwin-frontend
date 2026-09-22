<script setup lang="ts">
import { ref } from 'vue'
import { useRoute, useRouter } from 'vue-router'

import { useAuthStore } from '@/stores/auth'

const route = useRoute()
const router = useRouter()
const authStore = useAuthStore()
const retrying = ref(false)

function targetPath(): string {
  const redirect = route.query.redirect
  if (typeof redirect !== 'string' || !redirect.startsWith('/') || redirect.startsWith('//')) {
    return '/'
  }
  if (redirect.startsWith('/auth-init-error')) {
    return '/'
  }
  return redirect
}

async function retry() {
  if (retrying.value) {
    return
  }
  retrying.value = true
  try {
    await authStore.initialize()
    if (authStore.initStatus === 'success' && authStore.isAuthenticated) {
      await router.replace(targetPath())
      return
    }
    if (authStore.initStatus === 'success') {
      await router.replace({ name: 'login' })
    }
  } finally {
    retrying.value = false
  }
}
</script>

<template>
  <main class="init-error-page">
    <el-card class="init-error-card" shadow="hover">
      <h1>系统初始化失败</h1>
      <p class="message">无法获取当前登录用户信息，请检查网络后重试。</p>
      <el-button
        type="primary"
        class="retry-btn"
        :loading="retrying || authStore.loading"
        :disabled="retrying || authStore.loading"
        @click="retry"
      >
        重新获取登录状态
      </el-button>
    </el-card>
  </main>
</template>

<style scoped>
.init-error-page {
  min-height: 100vh;
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 24px;
  background: #f5f7fa;
}

.init-error-card {
  width: 420px;
  max-width: 100%;
  text-align: center;
}

h1 {
  margin: 0 0 12px;
  font-size: 22px;
  font-weight: 600;
}

.message {
  margin: 0 0 24px;
  color: #606266;
  line-height: 1.5;
}

.retry-btn {
  width: 100%;
}
</style>
