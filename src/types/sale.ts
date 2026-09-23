/**
 * 销售订单类型。字段对齐后端 SaleOrderVo。
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

export const SalePermission = {
  ORDER_VIEW: 'sale:order:view',
  ORDER_CREATE: 'sale:order:create',
} as const
