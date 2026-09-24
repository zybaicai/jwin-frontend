/**
 * 项目主数据。字段对齐后端 ProjectVo / ProjectPageQuery。
 */

export interface ProjectItem {
  id: number
  name: string | null
  alias: string | null
  categoryId: number | null
  categoryName: string | null
  price: number | string | null
  treatTime: number | null
  allowSell: boolean | null
  allowConsume: boolean | null
  allowLargess: boolean | null
  brandId: number | null
  remark: string | null
}

export interface ProjectPageQuery {
  page?: number
  size?: number
  keyword?: string
  categoryId?: number
  sellable?: boolean
  consumable?: boolean
}

export const ProjectPermission = {
  VIEW: 'project:view',
  EDIT: 'project:edit',
} as const
