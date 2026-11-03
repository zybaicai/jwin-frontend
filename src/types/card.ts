/**
 * 卡类定义类型。字段对齐后端 *CardVo / Upsert*Command。
 */

/** 四类卡列表排序白名单：id|name|price|allowSell（无 createdOn） */
export const CARD_SORT_FIELDS = ['id', 'name', 'price', 'allowSell'] as const
export type CardSortField = (typeof CARD_SORT_FIELDS)[number]

/** 区域折扣排序白名单：id|active|discountRate */
export const DISCOUNT_SORT_FIELDS = ['id', 'active', 'discountRate'] as const
export type DiscountSortField = (typeof DISCOUNT_SORT_FIELDS)[number]

export interface CardListQuery {
  onlySellable?: boolean
  categoryId?: number | null
  sortField?: CardSortField
  sortOrder?: 'asc' | 'desc'
  keyword?: string
}

/** 四类卡分类路径段 */
export type CardCategoryKind = 'general' | 'time' | 'saving' | 'package'

/** 卡分类列表排序白名单：id|name|sequence|active */
export const CARD_CATEGORY_SORT_FIELDS = ['id', 'name', 'sequence', 'active'] as const
export type CardCategorySortField = (typeof CARD_CATEGORY_SORT_FIELDS)[number]

/** 对齐 CardCategoryVo */
export interface CardCategoryItem {
  id: number
  name: string | null
  sequence: number | null
  active: boolean | null
  /** 关联卡定义数量 */
  cardCount?: number | null
}

export interface CardCategoryListQuery {
  onlyActive?: boolean
  sortField?: CardCategorySortField
  sortOrder?: 'asc' | 'desc'
}

/** 对齐 UpsertCardCategoryCommand */
export interface UpsertCardCategoryBody {
  name: string
  sequence?: number | null
  active?: boolean | null
}

/** ---------- 通用次卡 ---------- */

export interface GeneralCardProjectLine {
  projectId: number
  consumeAmount: number | null
  limitConsumeTimes: number | null
}

export interface GeneralCardItem {
  id: number
  name: string | null
  categoryId: number | null
  /** 分类名称（含已停用历史引用） */
  categoryName?: string | null
  price: string | number | null
  amount: number | null
  unitDesignPrice: string | number | null
  validType: number | null
  validDay: number | null
  saleStartDate: string | null
  saleEndingDate: string | null
  allowSell: boolean | null
  allowLargess: boolean | null
  remark: string | null
  projects: GeneralCardProjectLine[] | null
}

export interface UpsertGeneralCardBody {
  name: string
  categoryId?: number | null
  price: string
  amount: number
  validType?: number | null
  validDay?: number | null
  saleStartDate?: string | null
  saleEndingDate?: string | null
  allowSell?: boolean | null
  allowLargess?: boolean | null
  remark?: string | null
  projects?: GeneralCardProjectLine[] | null
}

/** ---------- 时效卡 ---------- */

export interface TimeCardItem {
  id: number
  name: string | null
  categoryId: number | null
  categoryName?: string | null
  price: string | number | null
  consumeCycle: number | null
  cycleLimitAmount: number | null
  performanceAmount: number | null
  validType: number | null
  validDay: number | null
  saleStartDate: string | null
  saleEndingDate: string | null
  allowSell: boolean | null
  allowLargess: boolean | null
  remark: string | null
  projectIds: number[] | null
}

export interface UpsertTimeCardBody {
  name: string
  categoryId?: number | null
  price: string
  consumeCycle?: number | null
  cycleLimitAmount?: number | null
  performanceAmount?: number | null
  validType?: number | null
  validDay?: number | null
  saleStartDate?: string | null
  saleEndingDate?: string | null
  allowSell?: boolean | null
  allowLargess?: boolean | null
  remark?: string | null
  projectIds?: number[] | null
}

/** ---------- 储值卡 ---------- */

export interface SavingCardRangeProjectLine {
  projectId: number
  largess: boolean | null
  priceType: number | null
  discountPrice: string | number | null
}

export interface SavingCardRangeProductLine {
  productId: number
  largess: boolean | null
  priceType: number | null
  discountPrice: string | number | null
}

export interface SavingCardItem {
  id: number
  name: string | null
  categoryId: number | null
  categoryName?: string | null
  /** 本金 */
  price: string | number | null
  /** 赠金 */
  largessPrice: string | number | null
  validType: number | null
  validDay: number | null
  saleStartDate: string | null
  saleEndingDate: string | null
  allowSell: boolean | null
  remark: string | null
  allowSaleDeduct: boolean | null
  allowConsumeDeduct: boolean | null
  /** 允许余额购买其他卡项 */
  allowPayForCardPurchase: boolean | null
  goodsRange: boolean | null
  largessGoodsRange: boolean | null
  projects: SavingCardRangeProjectLine[] | null
  products: SavingCardRangeProductLine[] | null
}

export interface UpsertSavingCardBody {
  name: string
  categoryId?: number | null
  price: string
  largessPrice?: string | null
  validType?: number | null
  validDay?: number | null
  saleStartDate?: string | null
  saleEndingDate?: string | null
  allowSell?: boolean | null
  remark?: string | null
  allowSaleDeduct?: boolean | null
  allowConsumeDeduct?: boolean | null
  allowPayForCardPurchase?: boolean | null
  goodsRange?: boolean | null
  largessGoodsRange?: boolean | null
  projects?: SavingCardRangeProjectLine[] | null
  products?: SavingCardRangeProductLine[] | null
}

/** ---------- 套餐卡 ---------- */

export interface PackageCardProjectLine {
  id?: number | null
  projectId: number
  price: string | number | null
  amount: number | null
  totalPrice: string | number | null
  largess: boolean | null
}

export interface PackageCardItemLine {
  id?: number | null
  itemId: number
  price: string | number | null
  amount: number | null
  totalPrice: string | number | null
  largess: boolean | null
}

export interface PackageCardItem {
  id: number
  name: string | null
  /** 套餐卡编号（Alias） */
  alias?: string | null
  categoryId: number | null
  categoryName?: string | null
  price: string | number | null
  validType: number | null
  validDay: number | null
  saleStartDate: string | null
  saleEndingDate: string | null
  allowSell: boolean | null
  allowLargess: boolean | null
  remark: string | null
  projects: PackageCardProjectLine[] | null
  products: PackageCardItemLine[] | null
  generalCards: PackageCardItemLine[] | null
  timeCards: PackageCardItemLine[] | null
  savingCards: PackageCardItemLine[] | null
}

/**
 * 更新时：集合字段 null=不修改，非 null=全量替换。
 * 编辑表单始终传非 null 数组以全量替换。
 */
export interface UpsertPackageCardBody {
  name: string
  categoryId?: number | null
  price: string
  validType?: number | null
  validDay?: number | null
  saleStartDate?: string | null
  saleEndingDate?: string | null
  allowSell?: boolean | null
  allowLargess?: boolean | null
  remark?: string | null
  projects?: Array<{
    projectId: number
    price: string
    amount: number
    totalPrice?: string | null
    largess?: boolean | null
  }> | null
  products?: Array<{
    itemId: number
    price: string
    amount: number
    totalPrice?: string | null
    largess?: boolean | null
  }> | null
  generalCards?: Array<{
    itemId: number
    price: string
    amount: number
    totalPrice?: string | null
    largess?: boolean | null
  }> | null
  timeCards?: Array<{
    itemId: number
    price: string
    amount: number
    totalPrice?: string | null
    largess?: boolean | null
  }> | null
  savingCards?: Array<{
    itemId: number
    price: string
    amount: number
    totalPrice?: string | null
    largess?: boolean | null
  }> | null
}

/** ---------- 储值区域折扣 ---------- */

export interface SavingCardDiscountItem {
  id: number
  priceAreaId: number | null
  projectId: number | null
  discountRate: string | number | null
  beginDate: string | null
  endDate: string | null
  active: boolean | null
  remark: string | null
}

export interface SavingCardDiscountListQuery {
  priceAreaId?: number
  projectId?: number
  sortField?: DiscountSortField
  sortOrder?: 'asc' | 'desc'
}

export interface UpsertSavingCardDiscountBody {
  priceAreaId: number
  projectId: number
  discountRate: string
  beginDate?: string | null
  endDate?: string | null
  active?: boolean | null
  remark?: string | null
}

export interface PriceAreaItem {
  id: number
  name: string | null
  sequence: number | null
  active: boolean | null
  remark: string | null
}

export const CardPermission = {
  GENERAL_VIEW: 'card:general:view',
  GENERAL_EDIT: 'card:general:edit',
  TIME_VIEW: 'card:time:view',
  TIME_EDIT: 'card:time:edit',
  SAVING_VIEW: 'card:saving:view',
  SAVING_EDIT: 'card:saving:edit',
  PACKAGE_VIEW: 'card:package:view',
  PACKAGE_EDIT: 'card:package:edit',
  SAVING_DISCOUNT_VIEW: 'card:saving-discount:view',
  SAVING_DISCOUNT_EDIT: 'card:saving-discount:edit',
} as const

export function formatCardValidPeriod(
  validType: number | null | undefined,
  validDay: number | null | undefined,
): string {
  if (validType == null && validDay == null) {
    return '—'
  }
  const typePart = validType != null ? `类型${validType}` : ''
  const dayPart = validDay != null ? `${validDay}天` : ''
  if (typePart && dayPart) {
    return `${typePart} / ${dayPart}`
  }
  return typePart || dayPart
}

export function formatSellStatus(allowSell: boolean | null | undefined): string {
  return allowSell === false ? '停售' : '可售'
}
