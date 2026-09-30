import request from '@/utils/request'
import type { ApiResponse } from '@/types/response'
import type { PageData } from '@/types/project'
import type {
  CreateProductBody,
  NamedOption,
  ProductItem,
  ProductOption,
  ProductPageQuery,
  UpdateProductBody,
} from '@/types/product'

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

/** GET /v1/products */
export async function fetchProductPage(
  query: ProductPageQuery = {},
): Promise<PageData<ProductItem>> {
  const response = await request.get<ApiResponse<PageData<ProductItem>>>('/v1/products', {
    params: buildParams({
      page: query.page,
      size: query.size,
      keyword: query.keyword,
      categoryId: query.categoryId,
      brandId: query.brandId,
      active: query.active,
      sellable: query.sellable,
      sortField: query.sortField,
      sortOrder: query.sortOrder,
    }),
  })
  return response.data.data
}

/** GET /v1/products/options */
export async function fetchProductOptions(keyword?: string): Promise<ProductOption[]> {
  const response = await request.get<ApiResponse<ProductOption[]>>('/v1/products/options', {
    params: buildParams({ keyword }),
  })
  return response.data.data ?? []
}

/** GET /v1/products/{id} */
export async function fetchProductDetail(id: number): Promise<ProductItem> {
  const response = await request.get<ApiResponse<ProductItem>>(`/v1/products/${id}`)
  return response.data.data
}

/** POST /v1/products */
export async function createProduct(body: CreateProductBody): Promise<ProductItem> {
  const response = await request.post<ApiResponse<ProductItem>>('/v1/products', body)
  return response.data.data
}

/** PUT /v1/products/{id} */
export async function updateProduct(id: number, body: UpdateProductBody): Promise<ProductItem> {
  const response = await request.put<ApiResponse<ProductItem>>(`/v1/products/${id}`, body)
  return response.data.data
}

/** DELETE /v1/products/{id} —— 停用（Active=false 且不可售），非物理删除 */
export async function deactivateProduct(id: number): Promise<ProductItem> {
  const response = await request.delete<ApiResponse<ProductItem>>(`/v1/products/${id}`)
  return response.data.data
}

/** GET /v1/product-categories/options */
export async function fetchProductCategoryOptions(): Promise<NamedOption[]> {
  const response = await request.get<ApiResponse<NamedOption[]>>(
    '/v1/product-categories/options',
  )
  return response.data.data ?? []
}

/** GET /v1/product-brands/options */
export async function fetchProductBrandOptions(): Promise<NamedOption[]> {
  const response = await request.get<ApiResponse<NamedOption[]>>('/v1/product-brands/options')
  return response.data.data ?? []
}
