import request from '@/utils/request'
import type { ApiResponse } from '@/types/response'
import type { PageData } from '@/types/customer'
import type { ProjectItem, ProjectPageQuery } from '@/types/project'

/**
 * GET /v1/projects —— 项目分页
 */
export async function fetchProjectPage(
  query: ProjectPageQuery = {},
): Promise<PageData<ProjectItem>> {
  const params: Record<string, string | number | boolean> = {}
  if (query.page != null) {
    params.page = query.page
  }
  if (query.size != null) {
    params.size = query.size
  }
  if (query.keyword != null && query.keyword !== '') {
    params.keyword = query.keyword
  }
  if (query.categoryId != null) {
    params.categoryId = query.categoryId
  }
  if (query.sellable != null) {
    params.sellable = query.sellable
  }
  if (query.consumable != null) {
    params.consumable = query.consumable
  }
  const response = await request.get<ApiResponse<PageData<ProjectItem>>>('/v1/projects', {
    params,
  })
  return response.data.data
}
