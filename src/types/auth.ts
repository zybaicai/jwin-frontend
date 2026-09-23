import type { EmployeeInfo, RoleBrief } from '@/types/user'

export type { EmployeeInfo, RoleBrief }

export interface StoreBrief {
  id: number
  name: string
}

/** 对齐 EmployeeRoleAccessVo.OrgEntityBriefVo */
export interface OrgEntityBrief {
  id: number
  name: string
  store: boolean
  parentId: number | null
}

/** 对齐 OrgScopeTreeNodeVo：可访问组织层级树节点 */
export interface OrgScopeTreeNode {
  id: number
  name: string
  parentId: number | null
  /** true=门店，可调用 switch-store */
  store: boolean
  sequence: number | null
  children: OrgScopeTreeNode[]
}

export interface LoginRequest {
  username: string
  password: string
  storeId?: number
}

/** 对齐后端 SwitchStoreCommand，只有 storeId。 */
export interface SwitchStoreRequest {
  storeId: number
}

export interface LoginVo {
  token: string
  refreshToken: string
  employee: EmployeeInfo
  store: StoreBrief
  roles: RoleBrief[]
}

/**
 * 对齐 AuthController.switchStore 的 ApiResult<LoginVo>。
 * 含 token / refreshToken / employee / store / roles，不含 permissionCodes。
 */
export type SwitchStoreResponse = LoginVo

/**
 * 对齐后端 CurrentUserVo。不是嵌套 employee 对象。
 */
export interface CurrentUserVo {
  employeeId: string
  employeeName: string
  jobId: number | null
  jobName: string | null
  jobTypeIds: number[]
  orgEntityIds: number[]
  orgEntities: OrgEntityBrief[]
  /** 可访问组织层级树；store=true 的节点可切店 */
  orgScopeTree: OrgScopeTreeNode[]
  storeId: number | null
  storeName: string | null
  /** 可访问门店 ID（兼容旧前端） */
  storeIds: number[]
  /** 可访问门店摘要（id + name） */
  stores: StoreBrief[]
  roles: RoleBrief[]
  permissionCodes: string[]
  dataScope: string | null
}

export type CurrentUser = CurrentUserVo
