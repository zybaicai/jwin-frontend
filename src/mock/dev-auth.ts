import type { CurrentUserVo } from '@/types/auth'

/**
 * 本地调试用的登录旁路。
 * 仅开发环境且 VITE_MOCK_AUTH=true 时生效：跳过登录页与 /me 请求，直接注入一个全权限账号。
 * 生产构建不会命中（import.meta.env.DEV 为 false）。
 */
export const DEV_MOCK_AUTH = import.meta.env.DEV && import.meta.env.VITE_MOCK_AUTH === 'true'

/** 占位 Token：不会被写进 localStorage，也不会真正发给后端。 */
export const DEV_MOCK_TOKEN = 'dev-mock-token'

/** 全权限调试账号。permissionCodes 留空，权限判断在 Permission Store 里旁路放行。 */
export function createMockCurrentUser(): CurrentUserVo {
  return {
    employeeId: 'DEV0001',
    employeeName: '开发调试账号',
    jobId: 1,
    jobName: '店长',
    jobTypeIds: [1],
    orgEntityIds: [1, 2],
    orgEntities: [
      { id: 1, name: '开发测试门店', store: true, parentId: null },
      { id: 2, name: '开发测试门店二', store: true, parentId: null },
    ],
    orgScopeTree: [
      {
        id: 1,
        name: '开发测试门店',
        parentId: null,
        store: true,
        sequence: 1,
        children: [],
      },
      {
        id: 2,
        name: '开发测试门店二',
        parentId: null,
        store: true,
        sequence: 2,
        children: [],
      },
    ],
    storeId: 1,
    storeName: '开发测试门店',
    storeIds: [1, 2],
    stores: [
      { id: 1, name: '开发测试门店' },
      { id: 2, name: '开发测试门店二' },
    ],
    roles: [{ id: 1, name: '调试全权限角色' }],
    permissionCodes: [],
    dataScope: 'ALL',
  }
}
