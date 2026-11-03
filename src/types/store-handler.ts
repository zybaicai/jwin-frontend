/** 对齐 HandlerVo */
export interface StoreHandlerItem {
  id: number
  name: string
  category: string
  orgEntityId: number | null
  orgEntityName: string | null
  jobTypeIds: number[] | null
  jobTypeNames: string[] | null
  sequence: number | null
  active: boolean | null
}

/** 经手人在同分类内的移动方向 */
export type StoreHandlerMoveDirection = 'TOP' | 'UP' | 'DOWN' | 'BOTTOM'

export interface StoreHandlerCategoryOption {
  code: string
  label: string
}

/** 左侧分类列表顺序与哲联系统一致 */
export const STORE_HANDLER_CATEGORIES: StoreHandlerCategoryOption[] = [
  { code: 'product_sale', label: '产品销售经手人' },
  { code: 'project_sale', label: '项目销售经手人' },
  { code: 'general_times_sale', label: '通用次卡销售经手人' },
  { code: 'times_limit_sale', label: '次效卡销售经手人' },
  { code: 'stored_value_sale', label: '储值卡销售经手人' },
  { code: 'package_sale', label: '套餐卡销售经手人' },
  { code: 'project_consume', label: '项目消耗经手人' },
  { code: 'stored_value_consume', label: '储值卡消耗项目经手人' },
  { code: 'product_consume', label: '产品消耗经手人' },
]

export const StoreHandlerPermission = {
  VIEW: 'handler:manage:view',
  EDIT: 'handler:manage:edit',
} as const
