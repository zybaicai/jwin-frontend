/**
 * 产品主数据。字段对齐后端 ProductVo / CreateProductCommand / UpdateProductCommand。
 * 无 IsAllowConsume，不得虚构「允许消耗」。
 */

export interface ProductItem {
  id: number
  name: string | null
  alias: string | null
  categoryId: number | null
  categoryName: string | null
  brandId: number | null
  brandName: string | null
  specification: string | null
  active: boolean | null
  price: string | number | null
  originalText: string | null
  allowSell: boolean | null
  allowLargess: boolean | null
  memo: string | null
  remark: string | null
}

export interface ProductOption {
  id: number
  name: string | null
  price: string | number | null
}

export interface NamedOption {
  id: number
  name: string | null
}

/** 对齐 CreateProductCommand */
export interface CreateProductBody {
  name: string
  alias?: string | null
  categoryId: number
  brandId?: number | null
  specification?: string | null
  active?: boolean | null
  price: string
  originalText?: string | null
  allowSell?: boolean | null
  allowLargess?: boolean | null
  memo?: string | null
  remark?: string | null
}

/**
 * 对齐 UpdateProductCommand。
 * originalText / memo 为 null 且未设 Present 时后端保留原值；
 * 更新时未加载到的历史字段不得强制写空。
 */
export interface UpdateProductBody {
  name: string
  alias?: string | null
  categoryId: number
  brandId?: number | null
  specification?: string | null
  active?: boolean | null
  price: string
  originalText?: string | null
  allowSell?: boolean | null
  allowLargess?: boolean | null
  memo?: string | null
  remark?: string | null
  originalTextPresent?: boolean | null
  memoPresent?: boolean | null
}

/** 对齐 ProductPageQuery；sortField 白名单 id|name|price|active */
export interface ProductPageQuery {
  page?: number
  size?: number
  keyword?: string
  categoryId?: number
  brandId?: number
  active?: boolean
  sellable?: boolean
  sortField?: ProductSortField
  sortOrder?: 'asc' | 'desc'
}

export const PRODUCT_SORT_FIELDS = ['id', 'name', 'price', 'active'] as const
export type ProductSortField = (typeof PRODUCT_SORT_FIELDS)[number]

export const ProductPermission = {
  VIEW: 'product:view',
  EDIT: 'product:edit',
} as const
