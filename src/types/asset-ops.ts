/** 卡项延期 / 权益运营 */

export type PostponeAccountType =
  | 'GENERAL_CARD'
  | 'TIME_CARD'
  | 'SAVING_CARD'
  | 'PACKAGE_CARD'
  | 'PROJECT'

export const PostponePermission = {
  ORDER_VIEW: 'postpone:order:view',
  ORDER_CREATE: 'postpone:order:create',
  ORDER_APPROVE: 'postpone:order:approve',
  CONFIG_EDIT: 'asset-ops:config:edit',
} as const

export const POSTPONE_STATUS_OPTIONS = [
  { value: '0', label: '申请中' },
  { value: '1', label: '已通过' },
  { value: '9', label: '已拒绝' },
  { value: '8', label: '已撤销' },
] as const

export interface PostponeBillItem {
  accountType: PostponeAccountType | string | null
  accountTypeName: string | null
  accountId: number | null
  itemId: number | null
  itemName: string | null
  oldValidDate: string | null
  newValidDate: string | null
  extensionDays: number | null
  everlasting: boolean | null
}

export interface PostponeBill {
  id: string
  customerId: number | null
  customerName: string | null
  storeId: number | null
  storeName: string | null
  approvalStatus: string | null
  approvalStatusName: string | null
  remark: string | null
  createdBy: string | null
  createdByName: string | null
  createdOn: string | null
  approvedBy: string | null
  approvedByName: string | null
  approvedOn: string | null
  approvalRemark: string | null
  items: PostponeBillItem[]
}

export interface PostponeBillPageQuery {
  storeId?: number
  customerId?: number
  approvalStatus?: string
  keyword?: string
  page?: number
  size?: number
}

export interface CreatePostponeBillBody {
  customerId: number
  storeId?: number
  remark?: string
  items: Array<{
    accountType: string
    accountId: number
    newValidDate?: string | null
    extensionDays?: number | null
    everlasting?: boolean
  }>
}

export interface DecidePostponeBillBody {
  remark?: string
}

export interface ApprovalRoleItem {
  id?: number
  roleCode: string
  employeeId?: string | null
  employeeName?: string | null
  jobTypeId?: number | null
  jobTypeName?: string | null
  levelNo?: number | null
  active?: boolean | null
}

export interface AssetOpsConfig {
  storeId: number | null
  allowLargessPostpone: boolean | null
  allowLargessTransfer: boolean | null
  postponeApprovers: ApprovalRoleItem[]
  transferApprovers: ApprovalRoleItem[]
  refundApprovers: ApprovalRoleItem[]
}

export interface UpsertAssetOpsConfigBody {
  storeId?: number | null
  allowLargessPostpone?: boolean
  allowLargessTransfer?: boolean
  postponeApprovers?: Array<{
    roleCode: string
    employeeId?: string | null
    jobTypeId?: number | null
    levelNo?: number
  }>
  transferApprovers?: Array<{
    roleCode: string
    employeeId?: string | null
    jobTypeId?: number | null
    levelNo?: number
  }>
  refundApprovers?: Array<{
    roleCode: string
    employeeId?: string | null
    jobTypeId?: number | null
    levelNo?: number
  }>
}

export const TransferPermission = {
  ORDER_VIEW: 'transfer:order:view',
  ORDER_CREATE: 'transfer:order:create',
  ORDER_APPROVE: 'transfer:order:approve',
  CONFIG_EDIT: 'asset-ops:config:edit',
} as const

export const TRANSFER_STATUS_OPTIONS = [
  { value: '0', label: '申请中' },
  { value: '2', label: '已完成' },
  { value: '9', label: '已拒绝' },
  { value: '8', label: '已冲销' },
] as const

export interface TransferBillItem {
  accountType: string | null
  accountTypeName: string | null
  outAccountId: number | null
  inAccountId: number | null
  itemId: number | null
  itemName: string | null
  quantity: number | null
  savingPrincipalAmount: number | string | null
  savingBonusAmount: number | string | null
  validDate: string | null
  sourceSaleBillId: string | null
  outPackageCardAccountId: number | null
  largess: boolean | null
}

export interface TransferBill {
  id: string
  storeId: number | null
  storeName: string | null
  outCustomerId: number | null
  outCustomerName: string | null
  outCustomerMobile: string | null
  inCustomerId: number | null
  inCustomerName: string | null
  inCustomerMobile: string | null
  billStatus: string | null
  billStatusName: string | null
  remark: string | null
  createdBy: string | null
  createdByName: string | null
  createdOn: string | null
  approvedBy: string | null
  approvedByName: string | null
  approvedOn: string | null
  approvalRemark: string | null
  items: TransferBillItem[]
}

export interface TransferBillPageQuery {
  storeId?: number
  outCustomerId?: number
  inCustomerId?: number
  billStatus?: string
  keyword?: string
  page?: number
  size?: number
}

export interface CreateTransferBillBody {
  outCustomerId: number
  inCustomerId: number
  storeId?: number
  remark?: string
  items: Array<{
    accountType: string
    accountId: number
    quantity?: number | null
    savingPrincipalAmount?: number | null
    savingBonusAmount?: number | null
  }>
}

export interface DecideTransferBillBody {
  remark?: string
}

/** 套餐母户下可转子权益 */
export interface PackageTransferChild {
  accountType: string
  accountId: number
  balance?: number | string | null
  itemId?: number | null
  itemName?: string | null
  largess?: boolean | null
  validDate?: string | null
  packageAccountId?: number | null
  /** 储值赠金余额（若有） */
  largessBalance?: number | string | null
}
