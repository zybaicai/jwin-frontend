import request from '@/utils/request'
import type { ApiResponse } from '@/types/response'
import type { CustomerAvailableAssets } from '@/types/treat'

/**
 * GET /v1/treat/customers/{customerId}/available-assets
 * 别名：GET /v1/customers/{id}/assets
 * 权限：treat:order:view
 *
 * 返回客户当前可耗权益（有余量、未失效）。本阶段仅用于消耗单工作台展示与选资产。
 */
export async function fetchCustomerAvailableAssets(
  customerId: number,
): Promise<CustomerAvailableAssets> {
  const response = await request.get<ApiResponse<CustomerAvailableAssets>>(
    `/v1/treat/customers/${customerId}/available-assets`,
  )
  const data = response.data.data
  return {
    projects: data?.projects ?? [],
    products: data?.products ?? [],
    saving: data?.saving ?? [],
    packageCards: data?.packageCards ?? [],
    generalCards: data?.generalCards ?? [],
    timeCards: data?.timeCards ?? [],
  }
}
