/**
 * 人事绩效 / 组织权限 / 经手配置 / 业绩查询类型。
 * 对齐后端 organization / handler / performance VO。
 */

export const OrgPermission = {
  STORE_VIEW: 'org:store:view',
  STORE_EDIT: 'org:store:edit',
  EMPLOYEE_VIEW: 'org:employee:view',
  EMPLOYEE_EDIT: 'org:employee:edit',
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
  entryDate?: string
  contractStartDate?: string
  contractEndDate?: string
  remark?: string
  password?: string
  state?: boolean
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
  entryDate?: string
  birthdate?: string
  contractStartDate?: string
  contractEndDate?: string
  remark?: string
  state: boolean
  password?: string
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
