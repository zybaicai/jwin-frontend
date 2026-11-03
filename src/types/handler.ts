/**
 * 经手人候选类型。字段对齐后端 HandlerCandidateVo / HandlerBizType。
 */

/** 销售侧 bizType（开单选人）；耗卡侧本阶段不封装调用 */
export type HandlerSaleBizType =
  | 'PROJECT_SALE'
  | 'PRODUCT_SALE'
  | 'SAVING_SALE'
  | 'GENERAL_SALE'
  | 'TIME_SALE'
  | 'PACKAGE_SALE'

/** 后端完整 bizType 字面量（含耗卡，仅作类型约束） */
export type HandlerBizType =
  | HandlerSaleBizType
  | 'PROJECT_TREAT'
  | 'PRODUCT_TREAT'
  | 'GENERAL_TREAT'
  | 'TIME_TREAT'
  | 'SAVING_TREAT'

export const HandlerSaleBizTypes = {
  PROJECT_SALE: 'PROJECT_SALE',
  PRODUCT_SALE: 'PRODUCT_SALE',
  SAVING_SALE: 'SAVING_SALE',
  GENERAL_SALE: 'GENERAL_SALE',
  TIME_SALE: 'TIME_SALE',
  PACKAGE_SALE: 'PACKAGE_SALE',
} as const satisfies Record<HandlerSaleBizType, HandlerSaleBizType>

export type HandlerTreatBizType =
  | 'PROJECT_TREAT'
  | 'PRODUCT_TREAT'
  | 'GENERAL_TREAT'
  | 'TIME_TREAT'
  | 'SAVING_TREAT'

export const HandlerTreatBizTypes = {
  PROJECT_TREAT: 'PROJECT_TREAT',
  PRODUCT_TREAT: 'PRODUCT_TREAT',
  GENERAL_TREAT: 'GENERAL_TREAT',
  TIME_TREAT: 'TIME_TREAT',
  SAVING_TREAT: 'SAVING_TREAT',
} as const satisfies Record<HandlerTreatBizType, HandlerTreatBizType>

/** 对齐 HandlerCandidateVo.EmployeeItem */
export interface HandlerCandidateEmployee {
  employeeId: string | null
  name: string | null
  jobTypeIds: number[] | null
  crossStore: boolean | null
}

/** 对齐 HandlerCandidateVo —— GET /v1/handler-candidates */
export interface HandlerCandidateResult {
  bizType: string | null
  storeId: number | null
  handlerRoleId: number | null
  handlerRoleName: string | null
  /** 店务经手人分类名（如「产品销售经手人」），启用 TB_Handler 规则时有值 */
  storeHandlerName: string | null
  /** 店务经手人规则名（如「销售经手人」） */
  storeHandlerRuleName: string | null
  /** 命中的 TB_Handler 有效规则数（多条 OR 合并） */
  storeHandlerRuleCount: number | null
  allowedJobTypeIds: number[] | null
  employees: HandlerCandidateEmployee[]
}

export interface HandlerCandidatesQuery {
  /** 必填 */
  bizType: string
  storeId?: number | null
  keyword?: string | null
}

/** 对齐 HandlerReadinessVo —— GET /v1/handler-readiness */
export interface HandlerReadinessMissing {
  bizType: string | null
  label: string | null
  hint: string | null
}

export interface HandlerReadinessResult {
  storeId: number | null
  mode: string | null
  ready: boolean
  message: string | null
  missing: HandlerReadinessMissing[]
}

export type HandlerReadinessMode = 'SALE' | 'TREAT' | 'ALL'

/**
 * 权限：后端 OR —— handler:candidates:view | sale:order:create | treat:order:create
 */
export const HandlerPermission = {
  CANDIDATES_VIEW: 'handler:candidates:view',
} as const
