/** 对齐 RefundVo / 退款中心 R1 */

export type RefundType = 'SALE' | 'TREAT'

/** 0 待审批 / 1 已审批 / 2 已执行 / 9 已驳回 */
export type RefundApprovalStatus = '0' | '1' | '2' | '9' | string

export interface RefundPay {
  payMethodId: number | null
  payMethodName: string | null
  amount: number | null
}

export interface RefundProcess {
  id: number | null
  approvalBy: string | null
  approvalByName: string | null
  approvalOn: string | null
  approvalRemark: string | null
  actionType: string | null
  actionTypeName: string | null
}

export interface RefundItem {
  accountType: string | null
  accountTypeName: string | null
  accountId: number | null
  itemId: number | null
  itemName: string | null
  holderCustomerId: number | null
  holderCustomerName: string | null
  quantity: number | null
  amount: number | null
}

export interface RefundBill {
  id: string
  refundType: RefundType | string
  sourceOrderId: string | null
  storeId: number | null
  storeName: string | null
  customerId: number | null
  customerName: string | null
  customerMobile: string | null
  customerCode: string | null
  approvalStatus: RefundApprovalStatus
  approvalStatusName: string | null
  totalAmount: number | null
  payAmount: number | null
  reason: string | null
  specialRefund?: boolean | null
  specialReason?: string | null
  refundOccurMonth?: string | null
  createdBy: string | null
  createdByName: string | null
  createdOn: string | null
  payments: RefundPay[]
  processes: RefundProcess[]
  items: RefundItem[]
}

export interface RefundBillPageQuery {
  status?: string
  refundType?: string
  keyword?: string
  refundId?: string
  sourceOrderId?: string
  createdFrom?: string
  createdTo?: string
  page?: number
  size?: number
}

export interface DecideRefundBody {
  remark?: string
}

export interface CreateRefundBody {
  refundType: RefundType
  sourceOrderId: string
  reason?: string
  specialRefund?: boolean
  specialReason?: string
  /** R3：单持有人；多持有人时必填 */
  holderCustomerId?: number | null
  items?: Array<{
    accountType: string
    accountId: number
    quantity?: number
  }>
  payments?: Array<{ method?: string; amount?: number }>
}

export interface RefundPreviewLine {
  accountType: string | null
  accountTypeName: string | null
  accountId: number | null
  itemId: number | null
  itemName: string | null
  holderCustomerId: number | null
  holderCustomerName: string | null
  packageCardAccountId: number | null
  originalAmount: number | null
  originalQty: number | null
  consumedQty: number | null
  remainingQty: number | null
  alreadyRefundedQty: number | null
  frozenQty: number | null
  maxRefundableQty: number | null
  unitPrice: number | null
  maxRefundableAmount: number | null
  selectable: boolean | null
  unselectableReason: string | null
  /** 时效卡有效期（消耗退款恢复时保持原值） */
  validDate?: string | null
  /** 消耗退款储值：原扣本金 */
  principalAmount?: number | null
  /** 消耗退款储值：原扣赠送余额 */
  bonusAmount?: number | null
}

export interface RefundPreviewHolder {
  holderCustomerId: number | null
  holderCustomerName: string | null
  buyer: boolean | null
  lineCount: number | null
  selectableCount: number | null
  maxRefundableAmount: number | null
}

export interface RefundPreviewTransfer {
  transferBillId: string | null
  outCustomerId: number | null
  outCustomerName: string | null
  inCustomerId: number | null
  inCustomerName: string | null
  billStatus: string | null
  createdOn: string | null
  accountType: string | null
  outAccountId: number | null
  inAccountId: number | null
  quantity: number | null
  amount: number | null
}

export interface RefundPreview {
  refundType?: RefundType | string | null
  sourceOrderId: string | null
  /** 原购买客户 */
  customerId: number | null
  customerName: string | null
  /** 原单时间（销售时间或消耗时间） */
  saleTime: string | null
  saleAmount: number | null
  alreadyRefundedAmount: number | null
  specialRefund: boolean | null
  /** R2：消耗退款仅整单 */
  wholeOrderOnly?: boolean | null
  /** 耗材库存预留提示 */
  consumableHint?: string | null
  /** R3：筛选持有人 */
  holderCustomerId?: number | null
  holders?: RefundPreviewHolder[]
  transfers?: RefundPreviewTransfer[]
  lines: RefundPreviewLine[]
}

export interface PreviewRefundBody {
  refundType: RefundType
  sourceOrderId: string
  specialRefund?: boolean
  /** R3：按持有人过滤 */
  holderCustomerId?: number | null
}

export const REFUND_STATUS_OPTIONS = [
  { value: '0', label: '待审批' },
  { value: '1', label: '已审批' },
  { value: '2', label: '已执行' },
  { value: '9', label: '已驳回' },
] as const

export const REFUND_TYPE_OPTIONS = [
  { value: 'SALE', label: '销售退款' },
  { value: 'TREAT', label: '消耗退款' },
] as const

export const RefundPermission = {
  ORDER_VIEW: 'refund:order:view',
  ORDER_CREATE: 'refund:order:create',
  ORDER_APPROVE: 'refund:order:approve',
  ORDER_EXECUTE: 'refund:order:execute',
  SPECIAL: 'refund:special',
} as const
