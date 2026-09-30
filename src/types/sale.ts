/**
 * 销售订单类型。字段对齐后端 SaleOrderVo / CreateSaleOrderCommand / PaySaleOrderCommand / PayMethodVo。
 */

import type { PageData } from '@/types/project'

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

/** 对齐 SaleOrderVo —— GET/POST /v1/sales/orders* */
export interface SaleOrderDetail {
  id: string
  /** LocalDateTime 序列化为字符串 */
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
  /** 0～100 百分比；全员未填时后端均分 */
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
  /** LocalDate yyyy-MM-dd；空=今天；补单需 sale:order:backdate */
  billDate?: string | null
  remark?: string | null
  items: CreateSaleOrderItem[]
  handlers: CreateSaleOrderHandler[]
  arrearAmount?: number | string | null
  payMethod?: string | null
  payments?: SalePaymentInput[] | null
}

/** 对齐 PaySaleOrderCommand —— POST /v1/sales/orders/{id}/pay */
export interface PaySaleOrderRequest {
  payments: SalePaymentInput[]
}

/** 对齐 PayMethodVo —— GET /v1/payments/methods */
export interface PayMethodOption {
  id: number
  name: string | null
  code: string | null
}

/** GET /v1/sales/orders 分页查询 */
export interface SaleOrderPageQuery {
  customerId?: number | null
  status?: string | null
  page?: number
  size?: number
}

export type SaleOrderPageData = PageData<SaleOrderDetail>

export const SalePermission = {
  ORDER_VIEW: 'sale:order:view',
  ORDER_CREATE: 'sale:order:create',
  ORDER_PAY: 'sale:order:pay',
  ORDER_CLOSE: 'sale:order:close',
  ORDER_BACKDATE: 'sale:order:backdate',
  ARREAR_REPAY: 'sale:arrear:repay',
} as const
