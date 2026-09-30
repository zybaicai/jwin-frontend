/**
 * 报价 / 改价预检类型。字段对齐后端 PriceQuote / ValidatePriceChangeCommand / PriceChangeCheckResult。
 * 金额字段不在前端自行计算成交价。
 */

/** 对齐 PriceQuote —— GET /v1/prices/by-channels、GET /v1/prices/quote */
export interface PriceQuote {
  saleChannelId: number | null
  saleChannelCode: string | null
  saleChannelName: string | null
  /** BigDecimal */
  price: number | string | null
  /**
   * 价格来源快照，如 STORE_CHANNEL / AREA_CHANNEL / HQ_CHANNEL / ITEM_BASE / ACTIVITY 等。
   * 前端仅展示，不据此重算。
   */
  priceSource: string | null
  allowAdjust: boolean | null
  minPrice: number | string | null
  activityId: number | null
}

export interface PriceByChannelsQuery {
  storeId: number
  itemType: string
  itemId: number
}

export interface PriceQuoteQuery {
  storeId: number
  itemType: string
  itemId: number
  saleChannelId: number
}

/** 对齐 ValidatePriceChangeCommand —— POST /v1/prices/change/validate */
export interface ValidatePriceChangeRequest {
  storeId: number
  itemType: string
  itemId: number
  saleChannelId: number
  /** BigDecimal */
  targetPrice: number | string
  reason: string
}

/** 对齐 PriceChangeCheckResult */
export interface PriceChangeCheckResult {
  allowed: boolean
  basePrice: number | string | null
  minPrice: number | string | null
  message: string | null
}

export const PricePermission = {
  QUOTE: 'price:quote',
  CHANGE: 'price:change',
  CHANNEL_EDIT: 'price:channel:edit',
} as const

/** 项目渠道总部价 —— GET/POST /v1/projects/{id}/channel-prices */
export interface ProjectChannelPriceItem {
  id: number
  saleChannelId: number
  saleChannelCode: string | null
  saleChannelName: string | null
  price: string | number | null
  active: boolean | null
  remark: string | null
  /** true：渠道独立销售/消耗范围已启用 */
  channelScopeEnabled: boolean | null
  /** 空数组=该渠道全部门店 */
  saleEntityIds: number[] | null
  /** 空数组=该渠道全部门店 */
  consumeEntityIds: number[] | null
}

export interface UpsertProjectChannelPriceBody {
  saleChannelId: number
  price: string
  active?: boolean | null
  remark?: string | null
  /** null=不修改；[]=全部门店；有值=指定门店 */
  saleEntityIds?: number[] | null
  consumeEntityIds?: number[] | null
}
