/**
 * 客户中心前端类型。字段名与后端 CustomerVo / CustomerDetailVo / Command 对齐。
 */

export interface PageData<T> {
  total: number
  page: number
  size: number
  records: T[]
}

/** 列表项，对齐 CustomerVo。列表接口 mobile 为打码号码。 */
export interface CustomerListItem {
  id: number
  code: string | null
  name: string | null
  storeId: number | null
  storeName: string | null
  mobile: string | null
  gender: string | null
  genderName: string | null
  birthday: string | null
  nurseEmployeeId: string | null
  nurseName: string | null
  sourceId: number | null
  sourceName: string | null
  introducerCustomerId: number | null
  introducerName: string | null
  member: boolean | null
  memberOn: string | null
  lastSaleTime: string | null
  lastTreatTime: string | null
  createdOn: string | null
  levelId: number | null
  levelName: string | null
  avatar: string | null
  remark: string | null
  address: string | null
}

/** 详情，对齐 CustomerDetailVo（含汇总指标；不含卡项/订单列表）。 */
export interface CustomerDetail {
  id: number
  code: string | null
  name: string | null
  mobile: string | null
  gender: string | null
  genderName: string | null
  birthday: string | null
  nurseEmployeeId: string | null
  nurseName: string | null
  sourceId: number | null
  sourceName: string | null
  storeId: number | null
  storeName: string | null
  registerStoreId: number | null
  registerStoreName: string | null
  createdOn: string | null
  levelId: number | null
  levelName: string | null
  member: boolean | null
  memberOn: string | null
  cardBalance: number | string | null
  giftBalance: number | string | null
  saleAmount: number | string | null
  saleVisitCount: number | null
  treatAmount: number | string | null
  guestVisitCount: number | null
  treatVisitCount: number | null
  arrearAmount: number | string | null
  lastSaleTime: string | null
  lastTreatTime: string | null
}

/** 详情抽屉内部一级 Tab（对齐参考稿） */
export type CustomerDetailTabKey =
  | 'profile'
  | 'cards'
  | 'orders'
  | 'serviceLogs'
  | 'followUps'
  | 'appointments'
  | 'files'

/** 顾客已贴标签 / 标签库项，对齐 CustomerTagVo */
export interface CustomerTagItem {
  id: number
  name: string
  createdOn: string | null
}

/** 卡项类型编码，对齐 CustomerAssetTypes */
export type CustomerCardItemType =
  | 'PRODUCT'
  | 'SAVING_CARD'
  | 'PACKAGE_CARD'
  | 'TIME_CARD'
  | 'GENERAL_CARD'
  | 'PROJECT'

/** 对齐 CustomerCardItemVo */
export interface CustomerCardItem {
  accountId: number
  itemType: string | null
  itemTypeName: string | null
  name: string | null
  storeId: number | null
  storeName: string | null
  buyDate: string | null
  price: number | string | null
  payAmount: number | string | null
  cardDeductionAmount: number | string | null
  validDate: string | null
  /** 余量：储值/套餐为金额，次数类为次数，产品为数量 */
  balance: number | string | null
  /** 剩余有效金额折算（不含赠送） */
  balanceAmount: number | string | null
  source: string | null
}

export interface CustomerCardQuery {
  itemType?: CustomerCardItemType | string
  page?: number
  size?: number
}

/** 对齐 CustomerSaleOrderVo —— 顾客销售订单大览 */
export interface CustomerSaleOrder {
  id: string
  totalAmount: number | string | null
  billType: string | null
  billStatus: string | null
  storeId: number | null
  storeName: string | null
  employeeId: string | null
  employeeName: string | null
  createdOn: string | null
  billDate: string | null
}

export interface CustomerSaleQuery {
  employeeId?: string
  employeeName?: string
  page?: number
  size?: number
}

/** 对齐 CustomerPaymentVo —— 顾客支付流水（一行一笔支付） */
export interface CustomerPaymentItem {
  billId: string
  billType: string | null
  storeId: number | null
  storeName: string | null
  employeeId: string | null
  employeeName: string | null
  totalAmount: number | string | null
  payType: string | null
  payMethodName: string | null
  payAmount: number | string | null
  orderAmount: number | string | null
  createdOn: string | null
}

export interface CustomerPaymentQuery {
  employeeId?: string
  employeeName?: string
  page?: number
  size?: number
}

/** 对齐 CustomerTreatOrderVo —— 顾客消耗订单大览（一行一单） */
export interface CustomerTreatOrderItem {
  id: string
  amount: number | string | null
  billType: string | null
  billStatus: string | null
  billStatusName: string | null
  storeId: number | null
  storeName: string | null
  employeeId: string | null
  employeeName: string | null
  createdOn: string | null
  billDate: string | null
}

export interface CustomerTreatOrderQuery {
  keyword?: string
  billStatus?: string
  employeeId?: string
  employeeName?: string
  page?: number
  size?: number
}

/** 对齐 CustomerPageQuery（前端可传字段） */
export interface CustomerListQuery {
  keyword?: string
  mobile?: string
  storeId?: number
  levelId?: number
  sourceId?: number
  introducerCustomerId?: number
  nurseEmployeeId?: string
  caregiverEmployeeId?: string
  memberOnFrom?: string
  memberOnTo?: string
  birthdayFrom?: string
  birthdayTo?: string
  createdOnFrom?: string
  createdOnTo?: string
  sortBy?: string
  sortOrder?: string
  page?: number
  size?: number
}

/** 对齐 CreateCustomerCommand */
export interface CreateCustomerBody {
  name: string
  mobile: string
  gender: string
  sourceId: number
  birthday?: string | null
  introducerCustomerId?: number | null
  remark?: string | null
  address?: string | null
  nurseEmployeeId?: string | null
}

/** 对齐 UpdateCustomerCommand。不传 sourceId，避免改首次来源。 */
export interface UpdateCustomerBody {
  name?: string
  mobile?: string
  gender?: string
  birthday?: string | null
  remark?: string | null
  address?: string | null
  nurseEmployeeId?: string | null
}

export interface CustomerSourceOption {
  id: number
  name: string
  parentId: number | null
  sequence: number | null
  active: boolean | null
}

export interface ServicerEmployeeOption {
  id: string
  servicerId: number | null
  name: string | null
}

export interface ServicerOption {
  id: number
  name: string | null
  addWhetherToShow: boolean | null
  entityRange: string | null
  active: boolean | null
  entityId: number | null
  servicerEmpList: ServicerEmployeeOption[] | null
}

export const CustomerPermission = {
  LIST_VIEW: 'customer:list:view',
  CREATE: 'customer:create',
  EDIT: 'customer:edit',
  SOURCE_VIEW: 'customer:source:view',
  TAG_VIEW: 'customer:tag:view',
  TAG_EDIT: 'customer:tag:edit',
} as const
