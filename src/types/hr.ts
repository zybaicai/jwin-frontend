/**
 * 人事绩效 / 组织权限 / 经手配置 / 业绩查询类型。
 * 对齐后端 organization / handler / performance VO。
 */

export const OrgPermission = {
  STORE_VIEW: 'org:store:view',
  STORE_EDIT: 'org:store:edit',
  EMPLOYEE_VIEW: 'org:employee:view',
  EMPLOYEE_EDIT: 'org:employee:edit',
  MOBILE_VIEW_FULL: 'employee:mobile:view_full',
  JOB_VIEW: 'org:job:view',
  JOB_EDIT: 'org:job:edit',
  ROLE_VIEW: 'org:role:view',
  ROLE_EDIT: 'org:role:edit',
  PERMISSION_VIEW: 'org:permission:view',
  PERMISSION_EDIT: 'org:permission:edit',
} as const

export const HandlerPermission = {
  CONFIG_VIEW: 'handler:config:view',
  CONFIG_EDIT: 'handler:config:edit',
  CANDIDATES_VIEW: 'handler:candidates:view',
} as const

export const PerformancePermission = {
  VIEW: 'performance:view',
} as const

export interface EmployeeEntityBrief {
  entityId: number
  entityName: string | null
  primaryEntity: boolean | null
}

export interface EmployeeRecord {
  id: string
  name: string
  alias: string | null
  phoneNumber: string | null
  /** 列表和详情里的脱敏手机号 */
  maskedMobile?: string | null
  jobId: number | null
  jobName: string | null
  state: boolean | null
  gender: string | null
  genderName: string | null
  idNumber: string | null
  birthdate: string | null
  address: string | null
  entryDate: string | null
  trialExpiryDate: string | null
  contractStartDate: string | null
  contractEndDate: string | null
  socialSecurityPaymentDate: string | null
  remark: string | null
  avatar: string | null
  entities: EmployeeEntityBrief[]
}

export interface EmployeePageQuery {
  entityId: number
  keyword?: string
  jobId?: number
  state?: boolean
  page?: number
  size?: number
}

export interface CreateEmployeeBody {
  id: string
  name: string
  alias?: string
  phoneNumber: string
  gender?: string
  jobId: number
  entityId: number
  idNumber?: string
  address?: string
  entryDate?: string | null
  birthdate?: string | null
  trialExpiryDate?: string | null
  contractStartDate?: string | null
  contractEndDate?: string | null
  socialSecurityPaymentDate?: string | null
  remark?: string
  password?: string
  state?: boolean
  /** 所属组织；entityId 为主组织 */
  entityIds?: number[]
}

export interface UpdateEmployeeBody {
  name: string
  alias?: string
  phoneNumber: string
  gender?: string
  jobId: number
  entityId: number
  idNumber?: string
  address?: string
  entryDate?: string | null
  birthdate?: string | null
  trialExpiryDate?: string | null
  contractStartDate?: string | null
  contractEndDate?: string | null
  socialSecurityPaymentDate?: string | null
  remark?: string
  state: boolean
  password?: string
  /** 所属组织全集；不传则只改主组织 */
  entityIds?: number[]
}

export interface JobTypeRecord {
  id: number
  name: string
  description: string | null
  active: boolean | null
}

export interface CrossStoreEmployee {
  employeeId: string
  name: string | null
  alias: string | null
  phoneNumber: string | null
  jobId: number | null
  jobName: string | null
  state: boolean | null
  primaryEntityId: number | null
  primaryEntityName: string | null
  /** 当前跨店门店（本店） */
  storeId: number | null
  storeName: string | null
}

export interface RoleAccessJobType {
  id: number
  name: string | null
}

export interface RoleAccessOrgEntity {
  id: number
  name: string | null
  store?: boolean | null
}

export interface EmployeeRoleAccess {
  employeeId: string
  employeeName: string | null
  jobTypes: RoleAccessJobType[]
  orgEntities: RoleAccessOrgEntity[]
  orgEntityIds: number[]
  resolvedOrgEntityIds: number[]
  resolvedStoreIds: number[]
  dataScope: string | null
}

export interface MenuPermissionNode {
  code: string
  name: string | null
  parentCode: string | null
  type: string | null
  menu: boolean | null
  sequence: number | null
  children?: MenuPermissionNode[]
}

export interface HandlerRoleRecord {
  id: number
  bizType: string
  storeId: number
  name: string
  sequence: number | null
  active: boolean | null
  jobTypeIds: number[]
}

/** 业绩汇总（现有 /performance/sales|treat） */
export interface PerformanceEmployeeRow {
  employeeId: string | null
  employeeName: string | null
  payAmount: number | null
  cardAmount: number | null
  largessAmount: number | null
  totalAmount: number | null
  guestCount: number | null
}

export interface PerformanceQueryResult {
  fromDate: string | null
  toDate: string | null
  storeId: number | null
  payAmount: number | null
  cardAmount: number | null
  largessAmount: number | null
  totalAmount: number | null
  guestCount: number | null
  employees: PerformanceEmployeeRow[]
}

/** 业绩明细行 — GET /performance/sales|treat/lines */
export interface PerformanceLineRow {
  billId: string
  billDate: string | null
  itemType: string
  itemName: string | null
  customerId: number | null
  customerName: string | null
  employeeId: string
  employeeName: string | null
  ratioPercent: number | null
  payAmount: number | null
  cardAmount: number | null
  largessAmount: number | null
  totalAmount: number | null
  performanceStoreId: number | null
  performanceStoreName: string | null
  billStoreId: number | null
  billStoreName: string | null
}

export interface PerformanceLineResult {
  fromDate: string | null
  toDate: string | null
  storeId: number | null
  payAmount: number | null
  cardAmount: number | null
  largessAmount: number | null
  totalAmount: number | null
  lines: PerformanceLineRow[]
}


/** —— 提成规则 / 阶梯 / 计算（C2） —— */

export interface CommissionBucketMeta {
  code: string
  label: string
}

export interface CommissionRuleMeta {
  scene: string
  itemType: string
  label: string
  ruleModel: 'CHAIN' | 'TIER'
  levels: string[]
  buckets: CommissionBucketMeta[]
  handlerBizType: string | null
  itemCatalogType: string | null
}

export interface CommissionRuleBucketRate {
  bucket: string
  bucketLabel?: string | null
  rate?: number | null
  fixed?: number | null
}

export interface CommissionRuleRecord {
  scene: string
  itemType: string
  level: string
  storeId: number
  itemId: number | null
  itemName: string | null
  handlerRoleId: number | null
  handlerRoleName: string | null
  jobTypeId: number | null
  jobTypeName: string | null
  rates: CommissionRuleBucketRate[]
}

export interface CommissionRuleUpsertBody {
  scene: string
  itemType: string
  level: string
  storeId: number
  itemId?: number | null
  handlerRoleId?: number | null
  jobTypeId?: number | null
  rates: { bucket: string; rate?: number | null; fixed?: number | null }[]
}

export interface CommissionRuleDeleteBody {
  scene: string
  itemType: string
  level: string
  storeId: number
  itemId?: number | null
  handlerRoleId?: number | null
  jobTypeId?: number | null
}

export interface TierRecord {
  id: number | null
  schemeId: number
  beginPerformance: number
  endPerformance?: number | null
  rate: number | null
  fixed: number | null
}

export interface TierSchemeRecord {
  id: number
  name: string
  storeId: number
  active: boolean
  tiers: TierRecord[]
}

export interface CommissionPartRecord {
  bucket: string
  bucketLabel: string | null
  base: number | null
  rate: number | null
  fixed: number | null
  rateAmount: number | null
  fixedAmount: number | null
  amount: number | null
}

export interface CommissionDetailRecord {
  scene: string
  category: string
  categoryLabel: string
  billId: string | null
  lineId: number | null
  subLineId: number | null
  pkgLineId: number | null
  itemId: number | null
  itemName: string | null
  masterItemId: number | null
  masterItemName: string | null
  projectId: number | null
  billDate: string | null
  employeeId: string | null
  handlerId: number | null
  scale: number | null
  ruleModel: string | null
  ruleLevel: string | null
  ruleDesc: string | null
  parts: CommissionPartRecord[]
  totalAmount: number | null
}

export interface CommissionEmployeeRow {
  employeeId: string
  saleBase?: number | null
  saleCommission?: number | null
  treatBase?: number | null
  treatCommission?: number | null
  totalCommission?: number | null
}

export interface CommissionResultRecord {
  month: string
  storeId: number
  employees: CommissionEmployeeRow[]
  saleLineCount?: number | null
  treatLineCount?: number | null
  details?: CommissionDetailRecord[] | null
  anomalies?: CommissionAnomaly[] | null
}

export interface CommissionAnomaly {
  billId?: string | null
  refundId?: string | null
  itemType?: string | null
  message?: string | null
}
