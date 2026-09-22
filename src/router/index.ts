import { createRouter, createWebHistory } from 'vue-router'

import { setupRouterGuard } from '@/router/guard'
import MainLayout from '@/layouts/MainLayout.vue'
import MenuPlaceholderView from '@/layouts/MenuPlaceholderView.vue'
import AuthInitErrorView from '@/views/AuthInitErrorView.vue'
import HomeView from '@/views/HomeView.vue'
import LoginView from '@/views/LoginView.vue'

declare module 'vue-router' {
  interface RouteMeta {
    requiresAuth?: boolean
    title?: string
    keepAlive?: boolean
    breadcrumb?: boolean
    tabClosable?: boolean
  }
}

const router = createRouter({
  history: createWebHistory(import.meta.env.BASE_URL),
  routes: [
    {
      path: '/login',
      name: 'login',
      component: LoginView,
      meta: { requiresAuth: false },
    },
    {
      path: '/auth-init-error',
      name: 'auth-init-error',
      component: AuthInitErrorView,
      meta: { requiresAuth: false },
    },
    {
      path: '/',
      component: MainLayout,
      meta: { requiresAuth: true },
      children: [
        {
          path: '',
          name: 'home',
          component: HomeView,
          meta: { requiresAuth: true, title: '首页', keepAlive: false, tabClosable: false },
        },
        {
          path: 'menu-placeholder',
          name: 'menu-placeholder',
          component: MenuPlaceholderView,
          meta: { requiresAuth: true, title: '菜单占位', keepAlive: true, tabClosable: true },
        },
      ],
    },
  ],
})

setupRouterGuard(router)

export default router
