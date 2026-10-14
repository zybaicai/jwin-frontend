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

/**
 * 静态菜单树。叶子 path 必须已在 router 注册。
 * 父级无 permission；子项权限由 Sidebar 过滤。
 */
export const appMenu: AppMenuItem[] = [
  {
    path: '/',
    name: 'home',
    title: '首页',
    icon: IconHome,
  },
  {
    name: 'group-customers',
    title: '客户管理',
    icon: IconCustomers,
    children: [
      {
        path: '/customers',
        name: 'customer-list',
        title: '客户列表',
        // 与改造前一致：菜单项不绑权限（页面内仍校验 customer:list:view）
      },
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
        path: '/customers/levels',
        name: 'customer-levels',
        title: '会员等级',
        permission: 'customer:level:view',
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
]

export interface MenuCrumb {
  title: string
}

/** 按当前 path 解析「分组 / 叶子」面包屑；未命中返回空 */
export function findMenuBreadcrumb(path: string): MenuCrumb[] {
  for (const item of appMenu) {
    if (item.children && item.children.length > 0) {
      const child = item.children.find((c) => c.path === path)
      if (child) {
        return [{ title: item.title }, { title: child.title }]
      }
    } else if (item.path === path) {
      return [{ title: item.title }]
    }
  }
  return []
}

/** 当前 path 所属父级 submenu index（name），用于展开侧栏 */
export function findOpenMenuIndexes(path: string): string[] {
  for (const item of appMenu) {
    if (item.children?.some((c) => c.path === path)) {
      return [item.name]
    }
  }
  return []
}
