import { createRouter, createWebHistory } from 'vue-router'

import { setupRouterGuard } from '@/router/guard'
import MainLayout from '@/layouts/MainLayout.vue'
import MenuPlaceholderView from '@/layouts/MenuPlaceholderView.vue'
import AuthInitErrorView from '@/views/AuthInitErrorView.vue'
import HomeView from '@/views/HomeView.vue'
import LoginView from '@/views/LoginView.vue'
import CustomerListView from '@/views/customer/CustomerListView.vue'
import CustomerSourceManageView from '@/views/customer/CustomerSourceManageView.vue'
import CustomerTagManageView from '@/views/customer/CustomerTagManageView.vue'
import SalesCashierView from '@/views/sale/SalesCashierView.vue'

declare module 'vue-router' {
  interface RouteMeta {
    requiresAuth?: boolean
    title?: string
    keepAlive?: boolean
    breadcrumb?: boolean
    tabClosable?: boolean
    /**
     * 是否作为工作区页签（左侧菜单叶子）。
     * 新建/查看/编辑等弹层页面不要设为 true。
     */
    workspaceTab?: boolean
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
          meta: {
            requiresAuth: true,
            title: '首页',
            keepAlive: false,
            tabClosable: false,
            workspaceTab: true,
          },
        },
        {
          path: 'customers',
          name: 'customer-list',
          component: CustomerListView,
          meta: {
            requiresAuth: true,
            title: '客户管理',
            keepAlive: true,
            breadcrumb: true,
            tabClosable: true,
            workspaceTab: true,
          },
        },
        {
          path: 'customers/tags',
          name: 'customer-tags',
          component: CustomerTagManageView,
          meta: {
            requiresAuth: true,
            title: '客户标签管理',
            keepAlive: true,
            breadcrumb: true,
            tabClosable: true,
            workspaceTab: true,
          },
        },
        {
          path: 'customers/sources',
          name: 'customer-sources',
          component: CustomerSourceManageView,
          meta: {
            requiresAuth: true,
            title: '客户来源管理',
            keepAlive: true,
            breadcrumb: true,
            tabClosable: true,
            workspaceTab: true,
          },
        },
        {
          path: 'sales/cashier',
          name: 'sales-cashier',
          component: SalesCashierView,
          meta: {
            requiresAuth: true,
            title: '销售开单',
            keepAlive: true,
            breadcrumb: true,
            tabClosable: true,
            workspaceTab: true,
          },
        },
        {
          path: 'menu-placeholder',
          name: 'menu-placeholder',
          component: MenuPlaceholderView,
          meta: {
            requiresAuth: true,
            title: '菜单占位',
            keepAlive: true,
            tabClosable: true,
            workspaceTab: true,
          },
        },
      ],
    },
  ],
})

setupRouterGuard(router)

export default router
