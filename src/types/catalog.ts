/**
 * 可售目录类型。字段对齐后端 GoodsItemVo / CatalogController。
 */

/** 开单可售 itemType（Catalog / CreateSaleOrderCommand） */
export type CatalogItemType =
  | 'PROJECT'
  | 'PRODUCT'
  | 'GENERAL_CARD'
  | 'TIME_CARD'
  | 'SAVING_CARD'
  | 'PACKAGE_CARD'

/** 对齐 GoodsItemVo —— GET /v1/goods、GET /v1/goods/{itemType}/{itemId} */
export interface GoodsItem {
  itemType: string | null
  itemId: number | null
  name: string | null
  /** BigDecimal 序列化为 number 或 string */
  price: number | string | null
  sellable: boolean | null
  categoryName: string | null
}

export interface GoodsSearchQuery {
  itemType?: string | null
  keyword?: string | null
  /**
   * 可选。PROJECT 且传入时，后端仅返回该渠道有有效总部渠道价且当前门店在销售范围内的项目。
   * 不传时目录≠可任意渠道开单。
   */
  saleChannelId?: number | null
}

export const CatalogPermission = {
  VIEW: 'catalog:view',
} as const
