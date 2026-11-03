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
  /**
   * 是否锁定会员等级（对齐 CustomerDetailVo.lockMemberLevel / TB_Customer.IsLockMemberLevel）。
   * 接口必须返回 boolean；缺失时前端不得当作 false。
   */
  lockMemberLevel: boolean | null
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

/** 权益展示状态（延期/转账运营统一口径预留） */
export type CustomerCardDisplayStatus =
  | 'NORMAL'
  | 'POSTPONE_PENDING'
  | 'TRANSFER_PENDING'
  | 'EXPIRED'
  | 'REFUNDED'
  | string

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
  /** 是否赠送权益 */
  largess: boolean | null
  /** NORMAL / POSTPONE_PENDING / EXPIRED / REFUNDED */
  displayStatus: CustomerCardDisplayStatus | null
  /** 正常 / 延期申请中 / 已过期 / 已退款 */
  displayStatusName: string | null
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

/** 对齐 CustomerSaleItemVo —— 顾客销售明细（一行一个销售项目） */
export interface CustomerSaleItem {
  billId: string
  billStatus: string | null
  storeId: number | null
  storeName: string | null
  employeeId: string | null
  employeeName: string | null
  itemType: string | null
  itemTypeName: string | null
  categoryName: string | null
  itemName: string | null
  price: number | string | null
  quantity: number | null
  gift: boolean | null
  totalAmount: number | string | null
  giftAmount: number | string | null
  arrearAmount: number | string | null
  payAmount: number | string | null
  billDate: string | null
}

/** 对齐 CustomerSaleQuery（销售明细与销售订单共用查询参数） */
export interface CustomerSaleItemQuery {
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

/** 对齐 CustomerTreatItemVo —— 顾客消耗明细（一行一个消耗项目） */
export interface CustomerTreatItem {
  billId: string
  billStatus: string | null
  billStatusName: string | null
  billType: string | null
  storeId: number | null
  storeName: string | null
  itemType: string | null
  itemTypeName: string | null
  cardName: string | null
  categoryName: string | null
  itemName: string | null
  price: number | string | null
  quantity: number | null
  gift: boolean | null
  totalAmount: number | string | null
  payAmount: number | string | null
  cardDeductionAmount: number | string | null
  largessCardDeductionAmount: number | string | null
  billDate: string | null
}

export interface CustomerTreatItemQuery {
  keyword?: string
  billStatus?: string
  employeeId?: string
  employeeName?: string
  page?: number
  size?: number
}

/** 对齐 CustomerTransferVo —— 顾客卡项转账记录（一行一单） */
export interface CustomerTransferItem {
  id: string
  outCustomerId: number | null
  outCustomerName: string | null
  inCustomerId: number | null
  inCustomerName: string | null
  storeId: number | null
  storeName: string | null
  employeeId: string | null
  employeeName: string | null
  billStatus: string | null
  createdOn: string | null
}

export interface CustomerTransferQuery {
  keyword?: string
  employeeId?: string
  employeeName?: string
  createdOnFrom?: string
  createdOnTo?: string
  page?: number
  size?: number
}

/** 对齐 CustomerExtensionVo —— 延期单下的一个卡项账户延期明细 */
export interface CustomerExtensionItem {
  billId: string
  customerId: number | null
  customerName: string | null
  storeId: number | null
  storeName: string | null
  employeeId: string | null
  employeeName: string | null
  approvalStatus: string | null
  approvalStatusName: string | null
  itemType: string | null
  itemTypeName: string | null
  accountId: number | null
  cardName: string | null
  oldValidDate: string | null
  newValidDate: string | null
  extensionDays: number | null
  everlasting: boolean | null
  remark: string | null
  channel: string | null
  createdOn: string | null
}

/** 对齐 CustomerExtensionQuery */
export interface CustomerExtensionQuery {
  keyword?: string
  employeeId?: string
  employeeName?: string
  createdOnFrom?: string
  createdOnTo?: string
  page?: number
  size?: number
}

/** 对齐 CustomerFollowUpVo —— 顾客跟进记录 */
export interface CustomerFollowUpItem {
  id: number
  customerId: number | null
  followUpMethodId: number | null
  followUpMethodName: string | null
  followUpStatusId: number | null
  followUpStatusName: string | null
  followUpContent: string | null
  isFollowUp: boolean | null
  plannedOn: string | null
  plannedRemark: string | null
  followUpOn: string | null
  followUpBy: string | null
  followUpByName: string | null
  createdBy: string | null
  createdByName: string | null
  createdOn: string | null
}

/** 对齐 CustomerFollowUpQuery */
export interface CustomerFollowUpQuery {
  keyword?: string
  followUpStatusId?: number
  followUpMethodId?: number
  followUpBy?: string
  plannedOnFrom?: string
  plannedOnTo?: string
  followUpOnFrom?: string
  followUpOnTo?: string
  page?: number
  size?: number
}

/** 对齐 CustomerServiceLogVo —— 顾客服务（护理）日志 */
export interface CustomerServiceLogItem {
  id: number
  nurseEmployeeId: string | null
  nurseName: string | null
  content: string | null
  createdOn: string | null
  storeId: number | null
  storeName: string | null
}

/** 对齐 CustomerServiceLogQuery */
export interface CustomerServiceLogQuery {
  createdOnFrom?: string
  createdOnTo?: string
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

/** 对齐 CustomerSourceVo */
export interface CustomerSourceOption {
  id: number
  name: string
  parentId: number | null
  sequence: number | null
  active: boolean | null
}

/** 来源管理页复用同一 VO */
export type CustomerSource = CustomerSourceOption

/** 来源在同级中的移动方向 */
export type CustomerSourceMoveDirection = 'TOP' | 'UP' | 'DOWN' | 'BOTTOM'

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
  SOURCE_EDIT: 'customer:source:edit',
  TAG_VIEW: 'customer:tag:view',
  TAG_EDIT: 'customer:tag:edit',
  LEVEL_VIEW: 'customer:level:view',
  LEVEL_EDIT: 'customer:level:edit',
  LEVEL_OVERRIDE: 'customer:level:override',
  FORM_VIEW: 'customer:form:view',
  FORM_EDIT: 'customer:form:edit',
  MEMBERSHIP_ENTRY_VIEW: 'customer:membership-entry:view',
  MEMBERSHIP_ENTRY_EDIT: 'customer:membership-entry:edit',
} as const

export interface CustomerProfileField {
  fieldCode: string
  fieldName: string
  requirement: 'REQUIRED' | 'OPTIONAL' | 'SYSTEM_REQUIRED' | string
  remark?: string | null
}

export interface CustomerCreateFieldSchema {
  fieldCode: string
  fieldName: string
  visible?: boolean | null
  required?: boolean | null
  requirement?: string | null
}

export type MembershipEntryMode =
  | 'NONE'
  | 'FIRST_SALE'
  | 'FIRST_TREAT'
  | 'SINGLE_SALE_AMOUNT'
  | 'TOTAL_SALE_AMOUNT'
  | 'TOTAL_TREAT_AMOUNT'
  | 'SALE_GOODS_TYPE'
  | 'SALE_GOODS'

export interface MembershipGoodsItem {
  goodsType: string
  goodsId: number
  goodsName?: string | null
}

export interface MembershipEntryRule {
  mode: MembershipEntryMode | string
  amount?: number | null
  goodsTypes?: string[]
  goods?: MembershipGoodsItem[]
}

/** 对齐 CustomerLevelVo */
export interface CustomerLevelItem {
  id: number
  name: string
  levelValue: number
  reduceLevelValue: number | null
  active: boolean | null
  sequence: number | null
}

/** 对齐 CreateCustomerLevelCommand */
export interface CreateCustomerLevelBody {
  name: string
  levelValue: number
  reduceLevelValue?: number | null
  sequence?: number | null
  active?: boolean | null
}

/** 对齐 UpdateCustomerLevelCommand */
export interface UpdateCustomerLevelBody {
  name: string
  levelValue: number
  reduceLevelValue?: number | null
  sequence: number
  active: boolean
}

/**
 * 对齐 OverrideCustomerMemberLevelCommand。
 * - updateLevel=true：按 levelId 写入（null 表示清空）
 * - updateLevel=false/null：不改等级
 * - lockMemberLevel 非 null：更新锁定；解锁后后端按当月累计重算
 */
export interface OverrideCustomerMemberLevelBody {
  updateLevel?: boolean | null
  levelId?: number | null
  lockMemberLevel?: boolean | null
}

/** 等级管理页排序白名单，对齐 CustomerLevelRules.isSortByAllowed */
export const CUSTOMER_LEVEL_SORT_BY = [
  'sequence',
  'name',
  'levelValue',
  'active',
  'id',
] as const

export type CustomerLevelSortBy = (typeof CUSTOMER_LEVEL_SORT_BY)[number]
