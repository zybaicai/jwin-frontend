import request from '@/utils/request'
import type { ApiResponse } from '@/types/response'
import type { StoreOption } from '@/types/goods-scope'

/** 对齐 OrganizationTreeNodeVo */
export interface OrganizationTreeNode {
  id: number
  entityName: string | null
  parentId: number | null
  store: boolean | null
  warehouse?: boolean | null
  provinceCode?: string | null
  cityCode?: string | null
  areaCode?: string | null
  addressDetail?: string | null
  longitude?: number | null
  latitude?: number | null
  active: boolean | null
  sequence: number | null
  remark?: string | null
  priceAreaId?: number | null
  /** 该节点及其下级组织的在职员工数 */
  employeeCount?: number | null
  children: OrganizationTreeNode[]
}

/**
 * GET /v1/organizations —— 全量组织树（管理端）。
 * 权限：org:store:view
 */
export async function fetchOrganizationTree(
  activeOnly = true,
): Promise<OrganizationTreeNode[]> {
  const response = await request.get<ApiResponse<OrganizationTreeNode[]>>(
    '/v1/organizations',
    {
      params: { activeOnly },
    },
  )
  return response.data.data ?? []
}

/** 从组织树提取 store=true 的适用门店选项 */
export function flattenStoreOptions(nodes: OrganizationTreeNode[]): StoreOption[] {
  const result: StoreOption[] = []
  const walk = (list: OrganizationTreeNode[]): void => {
    for (const node of list) {
      if (node.store === true && node.id != null) {
        result.push({
          id: node.id,
          name: node.entityName?.trim() || String(node.id),
        })
      }
      if (node.children != null && node.children.length > 0) {
        walk(node.children)
      }
    }
  }
  walk(nodes)
  result.sort((a, b) => a.id - b.id)
  return result
}
