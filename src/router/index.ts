import { createRouter, createWebHistory } from 'vue-router'

import { setupRouterGuard } from '@/router/guard'
import MainLayout from '@/layouts/MainLayout.vue'
import MenuPlaceholderView from '@/layouts/MenuPlaceholderView.vue'
import AuthInitErrorView from '@/views/AuthInitErrorView.vue'
import HomeView from '@/views/HomeView.vue'
import LoginView from '@/views/LoginView.vue'
import CustomerListView from '@/views/customer/CustomerListView.vue'
import CustomerLevelManageView from '@/views/customer/CustomerLevelManageView.vue'
import CustomerSourceManageView from '@/views/customer/CustomerSourceManageView.vue'
import CustomerTagManageView from '@/views/customer/CustomerTagManageView.vue'
import SalesCashierView from '@/views/sale/SalesCashierView.vue'
import SaleOrderListView from '@/views/sale/SaleOrderListView.vue'
import SaleOrderDetailView from '@/views/sale/SaleOrderDetailView.vue'
import TreatOrderListView from '@/views/sale/TreatOrderListView.vue'
import AppointmentBoardView from '@/views/appointment/AppointmentBoardView.vue'
import AppointmentConfigView from '@/views/appointment/AppointmentConfigView.vue'
import AppointmentRemindRecordView from '@/views/appointment/AppointmentRemindRecordView.vue'
import PostponeBillListView from '@/views/assetops/PostponeBillListView.vue'
import TransferBillListView from '@/views/assetops/TransferBillListView.vue'
import RefundBillListView from '@/views/refund/RefundBillListView.vue'
import RefundConfigView from '@/views/refund/RefundConfigView.vue'
import ProjectCategoryManageView from '@/views/goods/ProjectCategoryManageView.vue'
import CardCategoryManageView from '@/views/goods/CardCategoryManageView.vue'
import ProjectManageView from '@/views/goods/ProjectManageView.vue'
import ProductManageView from '@/views/goods/ProductManageView.vue'
import GeneralCardManageView from '@/views/goods/GeneralCardManageView.vue'
import TimeCardManageView from '@/views/goods/TimeCardManageView.vue'
import SavingCardManageView from '@/views/goods/SavingCardManageView.vue'
import SavingCardDiscountManageView from '@/views/goods/SavingCardDiscountManageView.vue'
import PackageCardManageView from '@/views/goods/PackageCardManageView.vue'
import ConsumableCategoryManageView from '@/views/goods/ConsumableCategoryManageView.vue'
import ConsumableTemplateManageView from '@/views/goods/ConsumableTemplateManageView.vue'
import UnderConstructionView from '@/views/common/UnderConstructionView.vue'
import OrgStructureView from '@/views/hr/OrgStructureView.vue'
import EmployeeDirectoryView from '@/views/hr/EmployeeDirectoryView.vue'
import CrossStoreEmployeeView from '@/views/hr/CrossStoreEmployeeView.vue'
import JobTypeManageView from '@/views/hr/JobTypeManageView.vue'
import RolePermissionView from '@/views/hr/RolePermissionView.vue'
import UserPermissionView from '@/views/hr/UserPermissionView.vue'
import SaleHandlerConfigView from '@/views/hr/SaleHandlerConfigView.vue'
import TreatHandlerConfigView from '@/views/hr/TreatHandlerConfigView.vue'
import SalePerformanceView from '@/views/hr/SalePerformanceView.vue'
import TreatPerformanceView from '@/views/hr/TreatPerformanceView.vue'

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
    /** 页面级权限码（菜单/守卫可读；业务页仍自行校验） */
    permission?: string
    /** 延期页：apply=申请列表，approve=审批列表；退款页：list/pending/done */
    mode?: 'apply' | 'approve' | 'list' | 'pending' | 'done'
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
            title: '客户列表',
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
            title: '客户标签',
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
            title: '客户来源',
            keepAlive: true,
            breadcrumb: true,
            tabClosable: true,
            workspaceTab: true,
          },
        },
        {
          path: 'customers/levels',
          name: 'customer-levels',
          component: CustomerLevelManageView,
          meta: {
            requiresAuth: true,
            title: '会员等级',
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
            title: '开单',
            keepAlive: true,
            breadcrumb: true,
            tabClosable: true,
            workspaceTab: true,
          },
        },
        {
          path: 'sales/orders',
          name: 'sale-orders',
          component: SaleOrderListView,
          meta: {
            requiresAuth: true,
            title: '销售订单',
            keepAlive: true,
            breadcrumb: true,
            tabClosable: true,
            workspaceTab: true,
          },
        },
        {
          path: 'sales/orders/:orderId',
          name: 'sale-order-detail',
          component: SaleOrderDetailView,
          meta: {
            requiresAuth: true,
            title: '销售订单详情',
            keepAlive: false,
            breadcrumb: true,
            tabClosable: true,
            workspaceTab: false,
          },
        },
        {
          path: 'treat/orders',
          name: 'treat-orders',
          component: TreatOrderListView,
          meta: {
            requiresAuth: true,
            title: '消耗订单',
            keepAlive: true,
            breadcrumb: true,
            tabClosable: true,
            workspaceTab: true,
          },
        },
        {
          path: 'appointments/config',
          name: 'appointment-config',
          component: AppointmentConfigView,
          meta: {
            requiresAuth: true,
            title: '预约配置',
            permission: 'appointment:view',
            defaultTab: 'roster',
            keepAlive: true,
            breadcrumb: true,
            tabClosable: true,
            workspaceTab: true,
          },
        },
        {
          path: 'appointments/schedule',
          redirect: '/appointments/config',
        },
        {
          path: 'appointments/remind-records',
          name: 'appointment-remind-records',
          component: AppointmentRemindRecordView,
          meta: {
            requiresAuth: true,
            title: '提醒记录',
            permission: 'appointment:view',
            keepAlive: true,
            breadcrumb: true,
            tabClosable: true,
            workspaceTab: true,
          },
        },
        {
          path: 'appointments',
          name: 'appointment-board',
          component: AppointmentBoardView,
          meta: {
            requiresAuth: true,
            title: '预约看板',
            permission: 'appointment:view',
            keepAlive: true,
            breadcrumb: true,
            tabClosable: true,
            workspaceTab: true,
          },
        },
        {
          path: 'asset-ops/postpone-apply',
          name: 'postpone-apply',
          component: PostponeBillListView,
          meta: {
            requiresAuth: true,
            title: '延期申请',
            mode: 'apply',
            keepAlive: true,
            breadcrumb: true,
            tabClosable: true,
            workspaceTab: true,
          },
        },
        {
          path: 'asset-ops/postpone-approve',
          name: 'postpone-approve',
          component: PostponeBillListView,
          meta: {
            requiresAuth: true,
            title: '延期审批',
            mode: 'approve',
            keepAlive: true,
            breadcrumb: true,
            tabClosable: true,
            workspaceTab: true,
          },
        },
        {
          // 兼容旧菜单/书签
          path: 'asset-ops/postpone-bills',
          redirect: { name: 'postpone-apply' },
        },
        {
          path: 'asset-ops/transfer-bills',
          name: 'transfer-bills',
          component: TransferBillListView,
          meta: {
            requiresAuth: true,
            title: '权益转账',
            keepAlive: true,
            breadcrumb: true,
            tabClosable: true,
            workspaceTab: true,
          },
        },
        {
          path: 'refunds',
          name: 'refund-list',
          component: RefundBillListView,
          meta: {
            requiresAuth: true,
            title: '退款订单列表',
            mode: 'list',
            keepAlive: true,
            breadcrumb: true,
            tabClosable: true,
            workspaceTab: true,
          },
        },
        {
          path: 'refunds/pending',
          name: 'refund-pending',
          component: RefundBillListView,
          meta: {
            requiresAuth: true,
            title: '退款待审批',
            mode: 'pending',
            keepAlive: true,
            breadcrumb: true,
            tabClosable: true,
            workspaceTab: true,
          },
        },
        {
          path: 'refunds/done',
          name: 'refund-done',
          component: RefundBillListView,
          meta: {
            requiresAuth: true,
            title: '退款已完成',
            mode: 'done',
            keepAlive: true,
            breadcrumb: true,
            tabClosable: true,
            workspaceTab: true,
          },
        },
        {
          path: 'refunds/config',
          name: 'refund-config',
          component: RefundConfigView,
          meta: {
            requiresAuth: true,
            title: '退款配置',
            keepAlive: false,
            breadcrumb: true,
            tabClosable: true,
            workspaceTab: true,
          },
        },
        {
          path: 'goods/project-categories',
          name: 'project-categories',
          component: ProjectCategoryManageView,
          meta: {
            requiresAuth: true,
            title: '项目分类',
            keepAlive: true,
            breadcrumb: true,
            tabClosable: true,
            workspaceTab: true,
          },
        },
        {
          path: 'goods/cards/categories',
          name: 'card-categories',
          component: CardCategoryManageView,
          meta: {
            requiresAuth: true,
            title: '卡类分类',
            keepAlive: true,
            breadcrumb: true,
            tabClosable: true,
            workspaceTab: true,
          },
        },
        {
          path: 'goods/card-categories',
          redirect: { name: 'card-categories' },
        },
        {
          path: 'goods/projects',
          name: 'projects',
          component: ProjectManageView,
          meta: {
            requiresAuth: true,
            title: '项目管理',
            keepAlive: true,
            breadcrumb: true,
            tabClosable: true,
            workspaceTab: true,
          },
        },
        {
          path: 'goods/products',
          name: 'products',
          component: ProductManageView,
          meta: {
            requiresAuth: true,
            title: '产品管理',
            keepAlive: true,
            breadcrumb: true,
            tabClosable: true,
            workspaceTab: true,
          },
        },
        {
          path: 'goods/cards/general',
          name: 'general-cards',
          component: GeneralCardManageView,
          meta: {
            requiresAuth: true,
            title: '通用次卡',
            keepAlive: true,
            breadcrumb: true,
            tabClosable: true,
            workspaceTab: true,
          },
        },
        {
          path: 'goods/cards/time',
          name: 'time-cards',
          component: TimeCardManageView,
          meta: {
            requiresAuth: true,
            title: '时效卡',
            keepAlive: true,
            breadcrumb: true,
            tabClosable: true,
            workspaceTab: true,
          },
        },
        {
          path: 'goods/cards/saving',
          name: 'saving-cards',
          component: SavingCardManageView,
          meta: {
            requiresAuth: true,
            title: '储值卡',
            keepAlive: true,
            breadcrumb: true,
            tabClosable: true,
            workspaceTab: true,
          },
        },
        {
          path: 'goods/cards/saving-discounts',
          name: 'saving-card-discounts',
          component: SavingCardDiscountManageView,
          meta: {
            requiresAuth: true,
            title: '储值区域折扣',
            keepAlive: true,
            breadcrumb: true,
            tabClosable: true,
            workspaceTab: true,
          },
        },
        {
          path: 'goods/cards/package',
          name: 'package-cards',
          component: PackageCardManageView,
          meta: {
            requiresAuth: true,
            title: '套餐卡',
            keepAlive: true,
            breadcrumb: true,
            tabClosable: true,
            workspaceTab: true,
          },
        },
        {
          path: 'goods/consumables/categories',
          name: 'consumable-categories',
          component: ConsumableCategoryManageView,
          meta: {
            requiresAuth: true,
            title: '耗材类别',
            keepAlive: true,
            breadcrumb: true,
            tabClosable: true,
            workspaceTab: true,
          },
        },
        {
          path: 'goods/consumables/templates',
          name: 'consumable-templates',
          component: ConsumableTemplateManageView,
          meta: {
            requiresAuth: true,
            title: '耗材模板',
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
        {
          path: 'hr/org',
          name: 'hr-org',
          component: OrgStructureView,
          meta: {
            requiresAuth: true,
            title: '组织架构',
            keepAlive: true,
            breadcrumb: true,
            tabClosable: true,
            workspaceTab: true,
            permission: 'org:store:view',
          },
        },
        {
          path: 'hr/employees',
          name: 'hr-employees',
          component: EmployeeDirectoryView,
          meta: {
            requiresAuth: true,
            title: '通讯录',
            keepAlive: true,
            breadcrumb: true,
            tabClosable: true,
            workspaceTab: true,
            permission: 'org:employee:view',
          },
        },
        {
          path: 'hr/cross-store',
          name: 'hr-cross-store',
          component: CrossStoreEmployeeView,
          meta: {
            requiresAuth: true,
            title: '跨店员工',
            keepAlive: true,
            breadcrumb: true,
            tabClosable: true,
            workspaceTab: true,
            permission: 'org:employee:view',
          },
        },
        {
          path: 'hr/job-types',
          name: 'hr-job-types',
          component: JobTypeManageView,
          meta: {
            requiresAuth: true,
            title: '职务配置',
            keepAlive: true,
            breadcrumb: true,
            tabClosable: true,
            workspaceTab: true,
            permission: 'org:job:view',
          },
        },
        {
          path: 'hr/role-permissions',
          name: 'hr-role-permissions',
          component: RolePermissionView,
          meta: {
            requiresAuth: true,
            title: '角色权限',
            keepAlive: true,
            breadcrumb: true,
            tabClosable: true,
            workspaceTab: true,
            permission: 'org:role:view',
          },
        },
        {
          path: 'hr/user-permissions',
          name: 'hr-user-permissions',
          component: UserPermissionView,
          meta: {
            requiresAuth: true,
            title: '用户权限',
            keepAlive: true,
            breadcrumb: true,
            tabClosable: true,
            workspaceTab: true,
            permission: 'org:role:view',
          },
        },
        {
          path: 'hr/sale-handlers',
          name: 'hr-sale-handlers',
          component: SaleHandlerConfigView,
          meta: {
            requiresAuth: true,
            title: '销售业绩人员配置',
            keepAlive: true,
            breadcrumb: true,
            tabClosable: true,
            workspaceTab: true,
            permission: 'handler:config:view',
          },
        },
        {
          path: 'hr/treat-handlers',
          name: 'hr-treat-handlers',
          component: TreatHandlerConfigView,
          meta: {
            requiresAuth: true,
            title: '消耗/划卡人员配置',
            keepAlive: true,
            breadcrumb: true,
            tabClosable: true,
            workspaceTab: true,
            permission: 'handler:config:view',
          },
        },
        {
          path: 'hr/sale-performance',
          name: 'hr-sale-performance',
          component: SalePerformanceView,
          meta: {
            requiresAuth: true,
            title: '销售业绩',
            keepAlive: true,
            breadcrumb: true,
            tabClosable: true,
            workspaceTab: true,
            permission: 'performance:view',
          },
        },
        {
          path: 'hr/treat-performance',
          name: 'hr-treat-performance',
          component: TreatPerformanceView,
          meta: {
            requiresAuth: true,
            title: '划卡业绩',
            keepAlive: true,
            breadcrumb: true,
            tabClosable: true,
            workspaceTab: true,
            permission: 'performance:view',
          },
        },
        {
          path: 'hr/sale-commission-rules',
          name: 'hr-sale-commission-rules',
          component: UnderConstructionView,
          meta: {
            requiresAuth: true,
            title: '销售提成规则',
            keepAlive: false,
            breadcrumb: true,
            tabClosable: true,
            workspaceTab: true,
            permission: 'commission:view',
          },
        },
        {
          path: 'hr/treat-commission-rules',
          name: 'hr-treat-commission-rules',
          component: UnderConstructionView,
          meta: {
            requiresAuth: true,
            title: '划卡提成规则',
            keepAlive: false,
            breadcrumb: true,
            tabClosable: true,
            workspaceTab: true,
            permission: 'commission:view',
          },
        },
        {
          path: 'hr/commission-calc',
          name: 'hr-commission-calc',
          component: UnderConstructionView,
          meta: {
            requiresAuth: true,
            title: '提成计算',
            keepAlive: false,
            breadcrumb: true,
            tabClosable: true,
            workspaceTab: true,
            permission: 'commission:view',
          },
        },
      ],
    },
  ],
})

setupRouterGuard(router)

export default router
