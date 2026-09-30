/**
 * 项目 / 项目分类主数据。字段对齐后端 ProjectVo / ProjectCategoryVo / Command。
 */

export interface PageData<T> {
  total: number
  page: number
  size: number
  records: T[]
}

/** 对齐 ProjectVo */
export interface ProjectItem {
  id: number
  name: string | null
  alias: string | null
  categoryId: number | null
  categoryName: string | null
  /** BigDecimal 序列化为 number 或 string，前端按字符串处理 */
  price: string | number | null
  treatTime: number | null
  allowSell: boolean | null
  allowConsume: boolean | null
  allowLargess: boolean | null
  brandId: number | null
  remark: string | null
}

/** 对齐 CreateProjectCommand */
export interface CreateProjectBody {
  name: string
  alias?: string | null
  categoryId: number
  price: string
  treatTime?: number | null
  allowSell?: boolean | null
  allowConsume?: boolean | null
  allowLargess?: boolean | null
  brandId?: number | null
  remark?: string | null
}

/** 对齐 UpdateProjectCommand */
export interface UpdateProjectBody {
  name: string
  alias?: string | null
  categoryId: number
  price: string
  treatTime?: number | null
  allowSell: boolean
  allowConsume: boolean
  allowLargess: boolean
  brandId?: number | null
  remark?: string | null
}

/** 对齐 ProjectPageQuery；sortField 白名单 id|name|price */
export interface ProjectPageQuery {
  page?: number
  size?: number
  keyword?: string
  categoryId?: number
  sellable?: boolean
  consumable?: boolean
  sortField?: ProjectSortField
  sortOrder?: 'asc' | 'desc'
}

export const PROJECT_SORT_FIELDS = ['id', 'name', 'price'] as const
export type ProjectSortField = (typeof PROJECT_SORT_FIELDS)[number]

/** 对齐 ProjectCategoryVo */
export interface ProjectCategoryItem {
  id: number
  name: string | null
  parentId: number | null
  sequence: number | null
  active: boolean | null
}

/** 对齐 ProjectCategoryTreeNodeVo */
export interface ProjectCategoryTreeNode {
  id: number
  name: string | null
  parentId: number | null
  sequence: number | null
  active: boolean | null
  children: ProjectCategoryTreeNode[]
}

/** 对齐 CreateProjectCategoryCommand */
export interface CreateProjectCategoryBody {
  name: string
  parentId?: number | null
  sequence?: number | null
  active?: boolean | null
}

/** 对齐 UpdateProjectCategoryCommand */
export interface UpdateProjectCategoryBody {
  name: string
  parentId?: number | null
  sequence: number
  active: boolean
}

export interface ProjectCategoryPageQuery {
  page?: number
  size?: number
  keyword?: string
  parentId?: number
  active?: boolean
}

export const ProjectPermission = {
  VIEW: 'project:view',
  EDIT: 'project:edit',
  CATEGORY_VIEW: 'project:category:view',
  CATEGORY_EDIT: 'project:category:edit',
} as const

/** 后端停用 = 不可售且不可耗（无独立 Active 字段） */
export function isProjectDeactivated(row: ProjectItem): boolean {
  return row.allowSell === false && row.allowConsume === false
}
