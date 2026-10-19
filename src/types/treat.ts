/**
 * 耗卡 / 消耗单类型。字段对齐后端 CustomerAssetsVo / CreateTreatOrderCommand / TreatOrderVo。
 */

/** 对齐 CustomerAssetsVo —— GET /v1/treat/customers/{id}/available-assets */
export interface TreatProjectAsset {
  accountId: number
  projectId: number | null
  name: string | null
  balance: number | null
  packageCardAccountId: number | null
  canUse: boolean | null
}

export interface TreatProductAsset {
  accountId: number
  productId: number | null
  name: string | null
  balance: number | null
  packageCardAccountId: number | null
  canUse: boolean | null
}

export interface TreatSavingAsset {
  accountId: number
  savingCardId: number | null
  name: string | null
  principalBalance: number | string | null
  bonusBalance: number | string | null
  validDate: string | null
  packageCardAccountId: number | null
  canUse: boolean | null
  /** 允许余额购买其他卡项 */
  allowPayForCardPurchase?: boolean | null
}

export interface TreatPackageAsset {
  accountId: number
  packageCardId: number | null
  name: string | null
  validDate: string | null
  canUse: boolean | null
}

export interface TreatGeneralCardAsset {
  accountId: number
  generalCardId: number | null
  name: string | null
  balance: number | null
  validDate: string | null
  packageCardAccountId: number | null
  canUse: boolean | null
}

export interface TreatTimeCardAsset {
  accountId: number
  timeCardId: number | null
  name: string | null
  performanceBalance: number | null
  validDate: string | null
  packageCardAccountId: number | null
  canUse: boolean | null
}

export interface CustomerAvailableAssets {
  projects: TreatProjectAsset[]
  products: TreatProductAsset[]
  saving: TreatSavingAsset[]
  packageCards: TreatPackageAsset[]
  generalCards: TreatGeneralCardAsset[]
  timeCards: TreatTimeCardAsset[]
}

/** 对齐 CreateTreatOrderCommand.Item —— POST /v1/treat/orders */
export interface CreateTreatOrderItem {
  itemType: string
  accountId: number
  quantity: number
  projectId?: number | null
  /** 储值拆分；不传则后端按本金优先自动拆分 */
  principalAmount?: number | string | null
  bonusAmount?: number | string | null
}

/** @deprecated 使用 CreateTreatOrderItem */
export type CreateTreatOrderItemDraft = CreateTreatOrderItem

/** 对齐 CreateTreatOrderCommand.Handler */
export interface CreateTreatOrderHandler {
  employeeId: string
  ratio?: number | string | null
}

/** @deprecated 使用 CreateTreatOrderHandler */
export type CreateTreatOrderHandlerDraft = CreateTreatOrderHandler

/** 对齐 CreateTreatOrderCommand */
export interface CreateTreatOrderRequest {
  customerId: number
  storeId?: number | null
  /** 消耗创建幂等键；超时重试须复用 */
  idempotencyKey?: string | null
  billDate?: string | null
  remark?: string | null
  signatureImageUrl?: string | null
  /** 预约开消耗：绑定预约单并驱动 SERV */
  appointmentId?: string | null
  items: CreateTreatOrderItem[]
  handlers: CreateTreatOrderHandler[]
}

/** 对齐 TreatOrderVo.Item */
export interface TreatOrderItem {
  lineId: number | null
  itemType: string | null
  accountId: number | null
  itemId: number | null
  itemName: string | null
  itemCode?: string | null
  projectId: number | null
  projectName: string | null
  quantity: number | null
  cardTreatTimes: number | null
  price: number | string | null
  preferentialAmount?: number | string | null
  totalAmount: number | string | null
  principalAmount: number | string | null
  bonusAmount: number | string | null
  /** 来源销售单号（经权益账户追溯） */
  sourceSaleBillId?: string | null
}

/** 对齐 TreatOrderVo.Handler */
export interface TreatOrderHandler {
  employeeId: string | null
  employeeName?: string | null
  ratio: number | string | null
  scale: number | string | null
}

/** 对齐 TreatOrderVo.Signature（预留） */
export interface TreatOrderSignature {
  id: number | null
  imageUrl: string | null
  createdOn: string | null
}

/** 对齐 TreatOrderVo.Consumable（预留） */
export interface TreatOrderConsumable {
  id: number | null
  projectId: number | null
  projectName: string | null
  productId: number | null
  productName: string | null
  quantity: number | string | null
  deducted: boolean | null
}

/** 对齐 TreatOrderVo —— GET/POST /v1/treat/orders* */
export interface TreatOrderDetail {
  id: string
  billDate: string | null
  createdOn?: string | null
  storeId: number | null
  customerId: number | null
  customerName?: string | null
  customerMobile?: string | null
  customerCode?: string | null
  billType?: string | null
  billStatus: string | null
  employeeId: string | null
  employeeName?: string | null
  amount: number | string | null
  remark: string | null
  /** 列表用经手人姓名汇总 */
  handlerNames?: string | null
  items: TreatOrderItem[]
  handlers: TreatOrderHandler[]
  signatures?: TreatOrderSignature[]
  consumables?: TreatOrderConsumable[]
}

/** GET /v1/treat/orders 分页查询 */
export interface TreatOrderPageQuery {
  keyword?: string | null
  handlerEmployeeId?: string | null
  status?: string | null
  billId?: string | null
  billType?: string | null
  billDateFrom?: string | null
  billDateTo?: string | null
  page?: number
  size?: number
}

export const TREAT_ORDER_STATUS_OPTIONS = [
  { label: '已完成', value: '1' },
  { label: '退款申请中', value: '3' },
  { label: '已退款', value: '2' },
  { label: '已取消', value: '9' },
] as const

export const TREAT_ORDER_TYPE_OPTIONS = [
  { label: '消耗单', value: '消耗' },
  { label: '退消耗单', value: '退消耗' },
] as const

/** 展示用：后端 BillStatus 为短码（1/3/2/9）或历史中文 */
export function formatTreatBillStatus(status: string | null | undefined): string {
  if (status == null || status === '') {
    return '—'
  }
  if (status === '1' || status === '已完成') {
    return '已完成'
  }
  if (status === '3' || status === '退款申请中') {
    return '退款申请中'
  }
  if (status === '9' || status === '已取消') {
    return '已取消'
  }
  if (status === '2' || status === '已退款') {
    return '已退款'
  }
  if (status === '0' || status === '草稿' || status === '待结账') {
    return '待结账'
  }
  return status
}

export function formatTreatBillType(billType: string | null | undefined): string {
  if (billType == null || billType === '') {
    return '—'
  }
  if (billType === '消耗') {
    return '消耗单'
  }
  if (billType === '退消耗') {
    return '退消耗单'
  }
  return billType
}

/** 对齐 TreatConfigVo */
export interface TreatConfig {
  autoDeductConsumable: boolean
  requireCustomerSign: boolean
}

export const TreatPermission = {
  ORDER_VIEW: 'treat:order:view',
  ORDER_CREATE: 'treat:order:create',
  ORDER_CANCEL: 'treat:order:cancel',
  ORDER_BACKDATE: 'treat:order:backdate',
  ORDER_EDIT_HANDLER: 'treat:order:edit-handler',
  CONFIG_EDIT: 'treat:config:edit',
} as const

export const TreatItemType = {
  PROJECT: 'PROJECT',
  GENERAL_CARD: 'GENERAL_CARD',
  TIME_CARD: 'TIME_CARD',
  SAVING_CARD: 'SAVING_CARD',
} as const
