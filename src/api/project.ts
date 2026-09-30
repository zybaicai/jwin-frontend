import request from '@/utils/request'
import type { ApiResponse } from '@/types/response'
import type {
  CreateProjectBody,
  CreateProjectCategoryBody,
  PageData,
  ProjectCategoryItem,
  ProjectCategoryPageQuery,
  ProjectCategoryTreeNode,
  ProjectItem,
  ProjectPageQuery,
  UpdateProjectBody,
  UpdateProjectCategoryBody,
} from '@/types/project'

function buildParams(
  query: Record<string, string | number | boolean | undefined | null>,
): Record<string, string | number | boolean> {
  const params: Record<string, string | number | boolean> = {}
  for (const [key, value] of Object.entries(query)) {
    if (value === undefined || value === null || value === '') {
      continue
    }
    params[key] = value
  }
  return params
}

/** GET /v1/projects */
export async function fetchProjectPage(
  query: ProjectPageQuery = {},
): Promise<PageData<ProjectItem>> {
  const response = await request.get<ApiResponse<PageData<ProjectItem>>>('/v1/projects', {
    params: buildParams({
      page: query.page,
      size: query.size,
      keyword: query.keyword,
      categoryId: query.categoryId,
      sellable: query.sellable,
      consumable: query.consumable,
      sortField: query.sortField,
      sortOrder: query.sortOrder,
    }),
  })
  return response.data.data
}

/** GET /v1/projects/options —— 可售项目下拉 */
export async function fetchProjectOptions(keyword?: string): Promise<ProjectItem[]> {
  const response = await request.get<ApiResponse<ProjectItem[]>>('/v1/projects/options', {
    params: buildParams({ keyword }),
  })
  return response.data.data ?? []
}

/** GET /v1/projects/{id} */
export async function fetchProjectDetail(id: number): Promise<ProjectItem> {
  const response = await request.get<ApiResponse<ProjectItem>>(`/v1/projects/${id}`)
  return response.data.data
}

/** POST /v1/projects */
export async function createProject(body: CreateProjectBody): Promise<ProjectItem> {
  const response = await request.post<ApiResponse<ProjectItem>>('/v1/projects', body)
  return response.data.data
}

/** PUT /v1/projects/{id} */
export async function updateProject(id: number, body: UpdateProjectBody): Promise<ProjectItem> {
  const response = await request.put<ApiResponse<ProjectItem>>(`/v1/projects/${id}`, body)
  return response.data.data
}

/** DELETE /v1/projects/{id} —— 停用（不可售且不可耗），非物理删除 */
export async function deactivateProject(id: number): Promise<ProjectItem> {
  const response = await request.delete<ApiResponse<ProjectItem>>(`/v1/projects/${id}`)
  return response.data.data
}

/** GET /v1/project-categories */
export async function fetchProjectCategoryPage(
  query: ProjectCategoryPageQuery = {},
): Promise<PageData<ProjectCategoryItem>> {
  const response = await request.get<ApiResponse<PageData<ProjectCategoryItem>>>(
    '/v1/project-categories',
    {
      params: buildParams({
        page: query.page,
        size: query.size,
        keyword: query.keyword,
        parentId: query.parentId,
        active: query.active,
      }),
    },
  )
  return response.data.data
}

/** GET /v1/project-categories/tree */
export async function fetchProjectCategoryTree(
  onlyActive?: boolean,
): Promise<ProjectCategoryTreeNode[]> {
  const response = await request.get<ApiResponse<ProjectCategoryTreeNode[]>>(
    '/v1/project-categories/tree',
    {
      params: buildParams({ onlyActive }),
    },
  )
  return response.data.data ?? []
}

/** GET /v1/project-categories/{id} */
export async function fetchProjectCategoryDetail(id: number): Promise<ProjectCategoryItem> {
  const response = await request.get<ApiResponse<ProjectCategoryItem>>(
    `/v1/project-categories/${id}`,
  )
  return response.data.data
}

/** POST /v1/project-categories */
export async function createProjectCategory(
  body: CreateProjectCategoryBody,
): Promise<ProjectCategoryItem> {
  const response = await request.post<ApiResponse<ProjectCategoryItem>>(
    '/v1/project-categories',
    body,
  )
  return response.data.data
}

/** PUT /v1/project-categories/{id} */
export async function updateProjectCategory(
  id: number,
  body: UpdateProjectCategoryBody,
): Promise<ProjectCategoryItem> {
  const response = await request.put<ApiResponse<ProjectCategoryItem>>(
    `/v1/project-categories/${id}`,
    body,
  )
  return response.data.data
}

/** DELETE /v1/project-categories/{id} —— 停用，非物理删除 */
export async function deactivateProjectCategory(id: number): Promise<ProjectCategoryItem> {
  const response = await request.delete<ApiResponse<ProjectCategoryItem>>(
    `/v1/project-categories/${id}`,
  )
  return response.data.data
}
