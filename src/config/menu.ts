import { defineComponent, h, type Component, type VNode } from 'vue'

export interface AppMenuItem {
  path: string
  name: string
  title: string
  icon: Component
  /** 有值时仅在拥有该权限时显示菜单项 */
  permission?: string
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

const IconPlaceholder = menuIcon('IconPlaceholder', () => [
  h('rect', { x: '4', y: '4', width: '16', height: '16', rx: '2' }),
  h('path', { d: 'M8 12 H16' }),
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

/**
 * 静态菜单。不指向未注册的路由。
 * 带 permission 的项由 Sidebar 按权限过滤。
 */
export const appMenu: AppMenuItem[] = [
  {
    path: '/',
    name: 'home',
    title: '首页',
    icon: IconHome,
  },
  {
    path: '/customers',
    name: 'customer-list',
    title: '客户管理',
    icon: IconCustomers,
  },
  {
    path: '/customers/tags',
    name: 'customer-tags',
    title: '客户标签管理',
    icon: IconCustomers,
    permission: 'customer:tag:view',
  },
  {
    path: '/customers/sources',
    name: 'customer-sources',
    title: '客户来源管理',
    icon: IconCustomers,
    permission: 'customer:source:view',
  },
  {
    path: '/sales/cashier',
    name: 'sales-cashier',
    title: '销售开单',
    icon: IconSales,
    permission: 'sale:order:create',
  },
  {
    path: '/menu-placeholder',
    name: 'menu-placeholder',
    title: '菜单占位项用于验证超长标题省略不是业务模块',
    icon: IconPlaceholder,
  },
]
