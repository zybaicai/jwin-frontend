/**
 * 销售订单类型。字段对齐后端 SaleOrderVo / CreateSaleOrderCommand / PaySaleOrderCommand。
 */

export interface SaleOrderItem {
  lineId: number | null
  parentLineId: number | null
  packageCardId: number | null
  itemType: string | null
  itemId: number | null
  itemName: string | null
  quantity: number | null
  price: number | string | null
  totalAmount: number | string | null
  gift: boolean | null
}

export interface SaleOrderPayment {
  payMethodId: number | null
  payMethodName: string | null
  amount: number | string | null
}

/** 对齐 SaleOrderVo —— GET /v1/sales/orders/{id} */
export interface SaleOrderDetail {
  id: string
  billDate: string | null
  storeId: number | null
  customerId: number | null
  customerName: string | null
  billType: string | null
  billStatus: string | null
  employeeId: string | null
  amount: number | string | null
  payAmount: number | string | null
  arrearAmount: number | string | null
  totalAmount: number | string | null
  remark: string | null
  saleStoreId: number | null
  saleStoreName: string | null
  customerBelongStoreId: number | null
  customerBelongStoreName: string | null
  saleChannelCode: string | null
  items: SaleOrderItem[]
  payments: SaleOrderPayment[]
}

/** 对齐 CreateSaleOrderCommand.Item */
export interface CreateSaleOrderItem {
  itemType: string
  itemId: number
  quantity: number
  price?: number | string | null
  priceChangeReason?: string | null
  gift?: boolean | null
  largessAmount?: number | string | null
  arrearAmount?: number | string | null
}

/** 对齐 CreateSaleOrderCommand.Handler */
export interface CreateSaleOrderHandler {
  employeeId: string
  ratio?: number | string | null
}

/** 对齐 PaySaleOrderCommand.Payment */
export interface SalePaymentInput {
  method: string
  amount?: number | string | null
  accountId?: number | null
  principalAmount?: number | string | null
  bonusAmount?: number | string | null
}

/**
 * 对齐 CreateSaleOrderCommand —— POST /v1/sales/orders
 * customerId / saleChannelId / items / handlers 为后端必填。
 */
export interface CreateSaleOrderRequest {
  customerId: number
  storeId?: number | null
  saleChannelId: number
  billDate?: string | null
  remark?: string | null
  items: CreateSaleOrderItem[]
  handlers: CreateSaleOrderHandler[]
  arrearAmount?: number | string | null
  payMethod?: string | null
  payments?: SalePaymentInput[] | null
}

export const SalePermission = {
  ORDER_VIEW: 'sale:order:view',
  ORDER_CREATE: 'sale:order:create',
  ORDER_PAY: 'sale:order:pay',
  ORDER_CLOSE: 'sale:order:close',
  ORDER_BACKDATE: 'sale:order:backdate',
  ARREAR_REPAY: 'sale:arrear:repay',
} as const
