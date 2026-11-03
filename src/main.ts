import { createApp } from 'vue'
import { createPinia } from 'pinia'
import ElementPlus from 'element-plus'
import zhCn from 'element-plus/es/locale/lang/zh-cn'
import 'element-plus/dist/index.css'

import App from './App.vue'
import { permissionDirective } from '@/directives/permission'
import router from './router'
import { useAuthStore } from '@/stores/auth'
import { ApiBusinessError, ApiHttpError } from '@/utils/api-error'
import { onAuthExpiredOnce } from '@/utils/auth-event'
import { DEV_MOCK_AUTH } from '@/mock/dev-auth'
import { uiMessage } from '@/utils/ui'
import './style.css'

async function bootstrap() {
  const app = createApp(App)
  const pinia = createPinia()

  app.use(pinia)

  const authStore = useAuthStore()
  onAuthExpiredOnce(() => {
    // 本地调试旁路下接口必然未授权，不再清账号、不跳登录页。
    if (DEV_MOCK_AUTH) {
      return
    }
    authStore.clearAuth()
    if (router.currentRoute.value.name !== 'login') {
      void router.replace({ name: 'login' })
    }
  })

  app.use(router)
  app.use(ElementPlus, { locale: zhCn })
  app.directive('permission', permissionDirective)
  app.config.errorHandler = (err, _instance, info) => {
    console.error(err, info)
    if (!import.meta.env.PROD) {
      return
    }
    if (err instanceof ApiBusinessError || err instanceof ApiHttpError) {
      return
    }
    uiMessage.error('系统出现异常，请稍后重试')
  }

  await router.isReady()
  app.mount('#app')
}

void bootstrap()
