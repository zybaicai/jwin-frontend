import type { EmployeeInfo, RoleBrief } from '@/types/user'

export type { EmployeeInfo, RoleBrief }

export interface StoreBrief {
  id: number
  name: string
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
  storeId: number | null
  storeName: string | null
  storeIds: number[]
  roles: RoleBrief[]
  permissionCodes: string[]
  dataScope: string | null
}

export type CurrentUser = CurrentUserVo
