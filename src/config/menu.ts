import { defineComponent, h, type Component, type VNode } from 'vue'

export interface AppMenuItem {
  path: string
  name: string
  title: string
  icon: Component
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

/**
 * 静态菜单。不按权限过滤，也不指向未注册的路由。
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
    path: '/menu-placeholder',
    name: 'menu-placeholder',
    title: '菜单占位项用于验证超长标题省略不是业务模块',
    icon: IconPlaceholder,
  },
]
