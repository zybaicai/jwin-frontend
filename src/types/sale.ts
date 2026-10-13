/**
 * 销售订单类型。字段对齐后端 SaleOrderVo / CreateSaleOrderCommand / PaySaleOrderCommand / PayMethodVo。
 */

import type { PageData } from '@/types/project'

export interface SaleOrderItem {
  lineId: number | null
  clientLineKey?: string | null
  parentLineId: number | null
  packageCardId: number | null
  itemType: string | null
  itemId: number | null
  itemName: string | null
  quantity: number | null
  price: number | string | null
  totalAmount: number | string | null
  arrearAmount?: number | string | null
  /** 仅项目明细有值 */
  saleChannelId?: number | null
  saleChannelCode?: string | null
  gift: boolean | null
  newMoneyReceived?: number | string | null
  savingPrincipalDeduct?: number | string | null
  savingBonusDeduct?: number | string | null
  settledAmount?: number | string | null
}

export interface SaleOrderPayment {
  payMethodId: number | null
  payMethodName: string | null
  amount: number | string | null
}

/** 对齐 SaleOrderVo.PayAllocation */
export interface SaleOrderPayAllocation {
  saleBillPayId: number | null
  targetType: string | null
  targetBillId: string | null
  sourceSaleLineId: number | null
  clientLineKey: string | null
  amount: number | string | null
  fundSource: string | null
}

/** 对齐 SaleOrderVo —— GET/POST /v1/sales/orders* */
export interface SaleOrderDetail {
  id: string
  /** LocalDateTime 序列化为字符串；业务日 / 下单时间 */
  billDate: string | null
  storeId: number | null
  customerId: number | null
  customerName: string | null
  /** 客户手机号；列表展示需脱敏 */
  customerMobile: string | null
  billType: string | null
  billStatus: string | null
  employeeId: string | null
  employeeName: string | null
  amount: number | string | null
  payAmount: number | string | null
  arrearAmount: number | string | null
  totalAmount: number | string | null
  remark: string | null
  /** 录单时间 */
  createdOn: string | null
  saleStoreId: number | null
  saleStoreName: string | null
  customerBelongStoreId: number | null
  customerBelongStoreName: string | null
  saleChannelCode: string | null
  /** 本单权益是否已产生消耗 */
  hasConsumedAssets?: boolean | null
  newMoneyReceived?: number | string | null
  savingPrincipalDeduct?: number | string | null
  savingBonusDeduct?: number | string | null
  settledAmount?: number | string | null
  items: SaleOrderItem[]
  payments: SaleOrderPayment[]
  paymentAllocations?: SaleOrderPayAllocation[]
  handlers?: SaleOrderHandler[]
}

/** 对齐 SaleOrderVo.Handler */
export interface SaleOrderHandler {
  employeeId: string | null
  employeeName?: string | null
  ratio: number | string | null
  scale?: number | string | null
}

/** 对齐 CreateSaleOrderCommand.Handler */
export interface CreateSaleOrderHandler {
  employeeId: string
  /** 0～100 百分比；全员未填时后端均分 */
  ratio?: number | string | null
}

/** 对齐 CreateSaleOrderCommand.Item */
export interface CreateSaleOrderItem {
  clientLineKey?: string | null
  itemType: string
  itemId: number
  quantity: number
  price?: number | string | null
  priceChangeReason?: string | null
  gift?: boolean | null
  largessAmount?: number | string | null
  arrearAmount?: number | string | null
  /** 仅 PROJECT 必填叶子渠道 */
  saleChannelId?: number | null
  /** 本行储值抵扣账户；与本金/赠金同时使用 */
  savingAccountId?: number | null
  savingPrincipalAmount?: number | string | null
  savingBonusAmount?: number | string | null
  /** 本行经手人；非空时覆盖整单 handlers */
  handlers?: CreateSaleOrderHandler[] | null
}

/** 对齐 PaySaleOrderCommand.Payment */
export interface SalePaymentInput {
  paymentKey?: string | null
  method: string
  amount?: number | string | null
  accountId?: number | null
  principalAmount?: number | string | null
  bonusAmount?: number | string | null
}

/** 对齐 PaySaleOrderCommand.PaymentAllocation */
export interface SalePaymentAllocationInput {
  paymentKey: string
  targetLineKey: string
  amount: number | string
  principalAmount?: number | string | null
  bonusAmount?: number | string | null
}

/**
 * 对齐 CreateSaleOrderCommand —— POST /v1/sales/orders
 * customerId / items 必填；整单 saleChannelId 可选（兼容）；PROJECT 明细自带渠道。
 */
export interface CreateSaleOrderRequest {
  customerId: number
  storeId?: number | null
  /** 兼容旧客户端；纯卡/产品可省略 */
  saleChannelId?: number | null
  /** LocalDate yyyy-MM-dd；空=今天；补单需 sale:order:backdate */
  billDate?: string | null
  remark?: string | null
  items: CreateSaleOrderItem[]
  /** 整单默认经手人；明细均自带 handlers 时可省略 */
  handlers?: CreateSaleOrderHandler[] | null
  arrearAmount?: number | string | null
  payMethod?: string | null
  payments?: SalePaymentInput[] | null
  paymentAllocations?: SalePaymentAllocationInput[] | null
}

/** 对齐 PaySaleOrderCommand —— POST /v1/sales/orders/{id}/pay */
export interface PaySaleOrderRequest {
  payments: SalePaymentInput[]
  paymentAllocations?: SalePaymentAllocationInput[] | null
}

/** 对齐 PayMethodVo —— GET /v1/payments/methods */
export interface PayMethodOption {
  id: number
  name: string | null
  code: string | null
}

/** GET /v1/sales/orders 分页查询（门店由登录态限定，不可越权） */
export interface SaleOrderPageQuery {
  customerId?: number | null
  status?: string | null
  /** 销售单号，后端模糊匹配 */
  billId?: string | null
  /** 订单类型，精确匹配 BillType */
  billType?: string | null
  /** 客户姓名 / 编号 / 手机号模糊 */
  keyword?: string | null
  /** 业务日起 yyyy-MM-dd */
  billDateFrom?: string | null
  /** 业务日止 yyyy-MM-dd */
  billDateTo?: string | null
  page?: number
  size?: number
}

/** 后端 BillStatus 既有取值（展示用，不新增「部分支付」） */
export const SALE_ORDER_STATUS_OPTIONS = [
  { value: '草稿', label: '草稿' },
  { value: '待支付', label: '待支付' },
  { value: '已支付', label: '已支付' },
  { value: '已关闭', label: '已关闭' },
  { value: '已退款', label: '已退款' },
] as const

/** 后端 BillType 既有/约定取值（筛选与展示；当前开单写入为「销售」） */
export const SALE_ORDER_TYPE_OPTIONS = [
  { value: '销售', label: '销售订单' },
  { value: '补欠款', label: '补欠款单' },
  { value: '退款', label: '退款订单' },
] as const

export type SaleOrderPageData = PageData<SaleOrderDetail>

export const SalePermission = {
  ORDER_VIEW: 'sale:order:view',
  ORDER_CREATE: 'sale:order:create',
  ORDER_PAY: 'sale:order:pay',
  ORDER_CLOSE: 'sale:order:close',
  ORDER_BACKDATE: 'sale:order:backdate',
  ORDER_EDIT_HANDLER: 'sale:order:edit-handler',
  ARREAR_REPAY: 'sale:arrear:repay',
} as const

/** @deprecated 请使用 @/types/refund 的 RefundPermission */
export const RefundPermission = {
  ORDER_CREATE: 'refund:order:create',
} as const
