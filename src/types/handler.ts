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
  allowedJobTypeIds: number[] | null
  employees: HandlerCandidateEmployee[]
}

export interface HandlerCandidatesQuery {
  /** 必填 */
  bizType: string
  storeId?: number | null
  keyword?: string | null
}

/**
 * 权限：后端 OR —— handler:candidates:view | sale:order:create | treat:order:create
 */
export const HandlerPermission = {
  CANDIDATES_VIEW: 'handler:candidates:view',
} as const
