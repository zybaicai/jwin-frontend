<script setup lang="ts">
import { reactive, ref } from 'vue'
import { useRouter } from 'vue-router'
import type { FormInstance, FormRules } from 'element-plus'

import { useAuthStore } from '@/stores/auth'
import { ApiBusinessError, ApiHttpError } from '@/utils/api-error'

const router = useRouter()
const authStore = useAuthStore()

const formRef = ref<FormInstance>()
const errorMessage = ref('')

const form = reactive({
  username: '',
  password: '',
})

const rules: FormRules<typeof form> = {
  username: [{ required: true, message: '请输入账号', trigger: 'blur' }],
  password: [{ required: true, message: '请输入密码', trigger: 'blur' }],
}

async function handleLogin() {
  if (authStore.loading) {
    return
  }
  errorMessage.value = ''
  const valid = await formRef.value?.validate().catch(() => false)
  if (!valid) {
    return
  }

  try {
    await authStore.login({
      username: form.username.trim(),
      password: form.password,
    })
    await router.push({ name: 'home' })
  } catch (error) {
    if (error instanceof ApiBusinessError || error instanceof ApiHttpError) {
      errorMessage.value = error.message
    } else {
      errorMessage.value = '登录失败，请稍后重试'
    }
  }
}
</script>

<template>
  <main class="login-page">
    <el-card class="login-card" shadow="hover">
      <h1>预道养发 ERP</h1>
      <p class="subtitle">员工登录</p>

      <el-form
        ref="formRef"
        :model="form"
        :rules="rules"
        label-position="top"
        @submit.prevent="handleLogin"
      >
        <el-form-item label="账号" prop="username">
          <el-input
            v-model="form.username"
            name="username"
            autocomplete="username"
            placeholder="手机号或员工 ID"
            :disabled="authStore.loading"
          />
        </el-form-item>
        <el-form-item label="密码" prop="password">
          <el-input
            v-model="form.password"
            name="password"
            type="password"
            show-password
            autocomplete="current-password"
            placeholder="请输入密码"
            :disabled="authStore.loading"
          />
        </el-form-item>

        <p v-if="errorMessage" class="error-text">{{ errorMessage }}</p>

        <el-button
          class="submit-btn"
          type="primary"
          native-type="submit"
          :loading="authStore.loading"
          :disabled="authStore.loading"
        >
          登录
        </el-button>
      </el-form>
    </el-card>
  </main>
</template>

<style scoped>
.login-page {
  min-height: 100vh;
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 24px;
  background: #f5f7fa;
}

.login-card {
  width: 400px;
  max-width: 100%;
}

h1 {
  margin: 0 0 8px;
  font-size: 24px;
  font-weight: 600;
  text-align: center;
}

.subtitle {
  margin: 0 0 24px;
  color: #909399;
  text-align: center;
}

.error-text {
  margin: 0 0 16px;
  color: #f56c6c;
  font-size: 14px;
  line-height: 1.4;
}

.submit-btn {
  width: 100%;
}
</style>
