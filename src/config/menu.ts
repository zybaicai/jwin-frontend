import { defineComponent, h, type Component, type VNode } from 'vue'

/**
 * 侧栏菜单项。
 * - 有 children：父级分组，不绑定业务权限；任一子项可见则显示父级。
 * - 无 children：叶子，path 必填；permission 有值时按权限过滤。
 */
export interface AppMenuItem {
  /** 叶子必填；父级可省略（用 name 作为 submenu index） */
  path?: string
  name: string
  title: string
  icon?: Component
  /** 仅叶子；有值时仅在拥有该权限时显示 */
  permission?: string
  /** 只有分组标题、没有叶子。侧栏展示空状态，不进入路由。 */
  placeholder?: boolean
  children?: AppMenuItem[]
}

function menuIcon(name: string, markup: () => VNode[]): Component {
  return defineComponent({
    name,
    setup() {
      return () =>
        h(
          'svg',
          {
            viewBox: '0 0 24 24',
            width: '1em',
            height: '1em',
            fill: 'none',
            stroke: 'currentColor',
            'stroke-width': '2',
            'stroke-linejoin': 'round',
            'stroke-linecap': 'round',
          },
          markup(),
        )
    },
  })
}

const IconHome = menuIcon('IconHome', () => [
  h('path', { d: 'M4 11 L12 4 L20 11' }),
  h('path', { d: 'M6 10 V20 H18 V10' }),
])

const IconCustomers = menuIcon('IconCustomers', () => [
  h('circle', { cx: '9', cy: '8', r: '3' }),
  h('path', { d: 'M3 19 C3 15.5 5.5 14 9 14 C12.5 14 15 15.5 15 19' }),
  h('circle', { cx: '17', cy: '9', r: '2.5' }),
  h('path', { d: 'M16 19 C16 16.5 17.5 15.5 20 15.5' }),
])

const IconSales = menuIcon('IconSales', () => [
  h('path', { d: 'M4 7 H20' }),
  h('path', { d: 'M4 12 H20' }),
  h('path', { d: 'M4 17 H14' }),
  h('circle', { cx: '18', cy: '17', r: '2' }),
])

const IconAppointment = menuIcon('IconAppointment', () => [
  h('rect', { x: '4', y: '5', width: '16', height: '15', rx: '2' }),
  h('path', { d: 'M8 3 V7' }),
  h('path', { d: 'M16 3 V7' }),
  h('path', { d: 'M4 10 H20' }),
  h('path', { d: 'M9 14 H15' }),
])

const IconAssetOps = menuIcon('IconAssetOps', () => [
  h('path', { d: 'M12 3 V14' }),
  h('path', { d: 'M8 10 L12 14 L16 10' }),
  h('path', { d: 'M5 18 H19' }),
  h('path', { d: 'M7 21 H17' }),
])

const IconRefund = menuIcon('IconRefund', () => [
  h('path', { d: 'M4 12 H18' }),
  h('path', { d: 'M8 8 L4 12 L8 16' }),
  h('path', { d: 'M20 7 V17' }),
])

const IconGoods = menuIcon('IconGoods', () => [
  h('path', { d: 'M4 7 L12 3 L20 7 L12 11 Z' }),
  h('path', { d: 'M4 7 V17 L12 21 L20 17 V7' }),
  h('path', { d: 'M12 11 V21' }),
])

const IconHr = menuIcon('IconHr', () => [
  h('circle', { cx: '9', cy: '8', r: '3' }),
  h('path', { d: 'M3 19 C3 15.5 5.5 14 9 14 C12.5 14 15 15.5 15 19' }),
  h('rect', { x: '15', y: '6', width: '6', height: '8', rx: '1' }),
])

const IconHrAuth = menuIcon('IconHrAuth', () => [
  h('rect', { x: '5', y: '11', width: '14', height: '9', rx: '2' }),
  h('path', { d: 'M8 11 V8 C8 5.8 9.8 4 12 4 C14.2 4 16 5.8 16 8 V11' }),
])

const IconHrHandler = menuIcon('IconHrHandler', () => [
  h('path', { d: 'M4 7 H20' }),
  h('path', { d: 'M4 12 H16' }),
  h('path', { d: 'M4 17 H12' }),
  h('circle', { cx: '18', cy: '12', r: '3' }),
])

const IconHrPerf = menuIcon('IconHrPerf', () => [
  h('path', { d: 'M4 19 V10' }),
  h('path', { d: 'M10 19 V6' }),
  h('path', { d: 'M16 19 V13' }),
  h('path', { d: 'M22 19 H2' }),
])

/** 顶部一级业务中心。只做导航分组，不是权限码。 */
export const BusinessCenter = {
  STORE: 'STORE',
  CUSTOMER: 'CUSTOMER',
  HR: 'HR',
  SUPPLY_CHAIN: 'SUPPLY_CHAIN',
  REPORT: 'REPORT',
} as const

export type BusinessCenterId = (typeof BusinessCenter)[keyof typeof BusinessCenter]

export interface BusinessCenterItem {
  id: BusinessCenterId
  title: string
}

export const businessCenters: BusinessCenterItem[] = [
  { id: BusinessCenter.STORE, title: '店务管理' },
  { id: BusinessCenter.CUSTOMER, title: '客户管理' },
  { id: BusinessCenter.HR, title: '人事绩效' },
  { id: BusinessCenter.SUPPLY_CHAIN, title: '供应链管理' },
  { id: BusinessCenter.REPORT, title: '报表中心' },
]

/**
 * 各业务中心的侧栏菜单。叶子 path、permission 与改造前一致。
 * 父级无 permission；子项权限由 Sidebar 过滤。
 */
export const menusByCenter: Record<BusinessCenterId, AppMenuItem[]> = {
  [BusinessCenter.STORE]: [
  {
    path: '/',
    name: 'home',
    title: '首页',
    icon: IconHome,
  },
  {
    name: 'group-store-customers',
    title: '顾客管理',
    icon: IconCustomers,
    children: [
      {
        path: '/customers',
        name: 'customer-list',
        title: '客户列表',
        // 与改造前一致：菜单项不绑权限（页面内仍校验 customer:list:view）
      },
    ],
  },
  {
    name: 'group-goods',
    title: '商品信息管理',
    icon: IconGoods,
    children: [
      {
        path: '/goods/project-categories',
        name: 'project-categories',
        title: '项目分类',
        permission: 'project:category:view',
      },
      {
        path: '/goods/cards/categories',
        name: 'card-categories',
        title: '卡类分类',
        // 任一卡 view 权限即可进页；页内按卡类型再过滤 Tab
      },
      {
        path: '/goods/projects',
        name: 'projects',
        title: '项目管理',
        permission: 'project:view',
      },
      {
        path: '/goods/products',
        name: 'products',
        title: '产品管理',
        permission: 'product:view',
      },
      {
        path: '/goods/cards/general',
        name: 'general-cards',
        title: '通用次卡',
        permission: 'card:general:view',
      },
      {
        path: '/goods/cards/time',
        name: 'time-cards',
        title: '时效卡',
        permission: 'card:time:view',
      },
      {
        path: '/goods/cards/saving',
        name: 'saving-cards',
        title: '储值卡',
        permission: 'card:saving:view',
      },
      {
        path: '/goods/cards/saving-discounts',
        name: 'saving-card-discounts',
        title: '储值区域折扣',
        permission: 'card:saving-discount:view',
      },
      {
        path: '/goods/cards/package',
        name: 'package-cards',
        title: '套餐卡',
        permission: 'card:package:view',
      },
      {
        path: '/goods/consumables/categories',
        name: 'consumable-categories',
        title: '耗材类别',
        permission: 'consumable:view',
      },
      {
        path: '/goods/consumables/templates',
        name: 'consumable-templates',
        title: '耗材模板',
        permission: 'consumable:view',
      },
    ],
  },
  {
    name: 'group-orders',
    title: '订单管理',
    icon: IconSales,
    children: [
      {
        path: '/sales/cashier',
        name: 'sales-cashier',
        title: '开单',
        permission: 'sale:order:create',
      },
      {
        path: '/sales/orders',
        name: 'sale-orders',
        title: '销售订单',
        permission: 'sale:order:view',
      },
      {
        path: '/treat/orders',
        name: 'treat-orders',
        title: '消耗订单',
        permission: 'treat:order:view',
      },
    ],
  },
  {
    name: 'group-appointments',
    title: '预约管理',
    icon: IconAppointment,
    children: [
      {
        path: '/appointments',
        name: 'appointment-board',
        title: '预约看板',
        permission: 'appointment:view',
      },
      {
        path: '/appointments/config',
        name: 'appointment-config',
        title: '预约配置',
        permission: 'appointment:view',
      },
      {
        path: '/appointments/remind-records',
        name: 'appointment-remind-records',
        title: '提醒记录',
        permission: 'appointment:view',
      },
    ],
  },
  {
    name: 'group-asset-ops',
    title: '延期转账',
    icon: IconAssetOps,
    children: [
      {
        path: '/asset-ops/postpone-apply',
        name: 'postpone-apply',
        title: '延期申请',
        permission: 'postpone:order:view',
      },
      {
        path: '/asset-ops/postpone-approve',
        name: 'postpone-approve',
        title: '延期审批',
        permission: 'postpone:order:approve',
      },
      {
        path: '/asset-ops/transfer-bills',
        name: 'transfer-bills',
        title: '权益转账',
        permission: 'transfer:order:view',
      },
    ],
  },
  {
    name: 'group-refunds',
    title: '退款管理',
    icon: IconRefund,
    children: [
      {
        path: '/refunds',
        name: 'refund-list',
        title: '退款订单列表',
        permission: 'refund:order:view',
      },
      {
        path: '/refunds/pending',
        name: 'refund-pending',
        title: '待审批',
        permission: 'refund:order:approve',
      },
      {
        path: '/refunds/done',
        name: 'refund-done',
        title: '已完成',
        permission: 'refund:order:view',
      },
      {
        path: '/refunds/config',
        name: 'refund-config',
        title: '退款配置',
        permission: 'refund:order:approve',
      },
    ],
  },
  ],
  [BusinessCenter.CUSTOMER]: [
    {
      name: 'group-customer-settings',
      title: '客户设置',
      icon: IconCustomers,
      children: [
        {
          path: '/customers/tags',
          name: 'customer-tags',
          title: '客户标签',
          permission: 'customer:tag:view',
        },
        {
          path: '/customers/sources',
          name: 'customer-sources',
          title: '客户来源',
          permission: 'customer:source:view',
        },
        {
          path: '/customers/profile-scenes',
          name: 'customer-profile-scenes',
          title: '档案应用场景',
          permission: 'customer:form:view',
        },
      ],
    },
    {
      name: 'group-customer-levels',
      title: '会员等级',
      icon: IconHrPerf,
      children: [
        {
          path: '/customers/levels',
          name: 'customer-levels',
          title: '等级设置',
          permission: 'customer:level:view',
        },
        {
          path: '/customers/membership-entry',
          name: 'customer-membership-entry',
          title: '入会门槛',
          permission: 'customer:membership-entry:view',
        },
      ],
    },
    {
      name: 'group-customer-servicers',
      title: '服务人员',
      icon: IconHr,
      placeholder: true,
    },
  ],
  [BusinessCenter.HR]: [
  {
    name: 'group-hr-org',
    title: '组织人员',
    icon: IconHr,
    children: [
      {
        path: '/hr/employees',
        name: 'hr-employees',
        title: '通讯录',
        permission: 'org:employee:view',
      },
      {
        path: '/hr/cross-store',
        name: 'hr-cross-store',
        title: '跨店员工',
        permission: 'org:employee:view',
      },
      {
        path: '/hr/job-types',
        name: 'hr-job-types',
        title: '职务配置',
        permission: 'org:job:view',
      },
    ],
  },
  {
    name: 'group-hr-auth',
    title: '权限管理',
    icon: IconHrAuth,
    children: [
      {
        path: '/hr/role-permissions',
        name: 'hr-role-permissions',
        title: '角色权限',
        permission: 'org:role:view',
      },
      {
        path: '/hr/user-permissions',
        name: 'hr-user-permissions',
        title: '用户权限',
        permission: 'org:role:view',
      },
    ],
  },
  {
    name: 'group-hr-handler',
    title: '业绩配置',
    icon: IconHrHandler,
    children: [
      {
        path: '/hr/sale-handlers',
        name: 'hr-sale-handlers',
        title: '销售业绩人员配置',
        permission: 'handler:config:view',
      },
      {
        path: '/hr/treat-handlers',
        name: 'hr-treat-handlers',
        title: '消耗/划卡人员配置',
        permission: 'handler:config:view',
      },
    ],
  },
  {
    name: 'group-hr-perf',
    title: '业绩提成',
    icon: IconHrPerf,
    children: [
      {
        path: '/hr/sale-performance',
        name: 'hr-sale-performance',
        title: '销售业绩',
        permission: 'performance:view',
      },
      {
        path: '/hr/treat-performance',
        name: 'hr-treat-performance',
        title: '划卡业绩',
        permission: 'performance:view',
      },
      {
        path: '/hr/sale-commission-rules',
        name: 'hr-sale-commission-rules',
        title: '销售提成规则',
        permission: 'commission:view',
      },
      {
        path: '/hr/treat-commission-rules',
        name: 'hr-treat-commission-rules',
        title: '划卡提成规则',
        permission: 'commission:view',
      },
      {
        path: '/hr/commission-calc',
        name: 'hr-commission-calc',
        title: '提成计算',
        permission: 'commission:view',
      },
    ],
  },
  ],
  [BusinessCenter.SUPPLY_CHAIN]: [],
  [BusinessCenter.REPORT]: [],
}

/** 全部侧栏节点，供按 path 反查归属。顺序与业务中心一致。 */
export const appMenu: AppMenuItem[] = businessCenters.flatMap(
  (center) => menusByCenter[center.id],
)

export interface MenuCrumb {
  title: string
}

function walkMenu(
  items: AppMenuItem[],
  path: string,
  parents: AppMenuItem[],
): { item: AppMenuItem; parents: AppMenuItem[] } | null {
  for (const item of items) {
    if (item.children && item.children.length > 0) {
      const hit = walkMenu(item.children, path, [...parents, item])
      if (hit) return hit
      continue
    }
    if (item.path === path) {
      return { item, parents }
    }
  }
  return null
}

/** 叶子 path 所属一级业务中心；未登记的地址返回 null */
export function findBusinessCenter(path: string): BusinessCenterId | null {
  for (const center of businessCenters) {
    if (walkMenu(menusByCenter[center.id], path, [])) {
      return center.id
    }
  }
  return null
}

/** 按当前 path 解析「分组 / 叶子」；未命中返回空 */
export function findMenuBreadcrumb(path: string): MenuCrumb[] {
  for (const center of businessCenters) {
    const hit = walkMenu(menusByCenter[center.id], path, [])
    if (!hit) continue
    return [...hit.parents, hit.item].map((item) => ({ title: item.title }))
  }
  return []
}

/** 当前 path 所属父级 submenu index（name），用于展开侧栏 */
export function findOpenMenuIndexes(path: string): string[] {
  for (const center of businessCenters) {
    const hit = walkMenu(menusByCenter[center.id], path, [])
    if (hit) {
      return hit.parents.map((item) => item.name)
    }
  }
  return []
}
