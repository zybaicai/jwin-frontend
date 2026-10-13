import request from '@/utils/request'
import type { ApiResponse } from '@/types/response'
import type { PageData } from '@/types/customer'
import type {
  AssetOpsConfig,
  CreatePostponeBillBody,
  CreateTransferBillBody,
  DecidePostponeBillBody,
  DecideTransferBillBody,
  PostponeBill,
  PostponeBillPageQuery,
  PackageTransferChild,
  TransferBill,
  TransferBillPageQuery,
  UpsertAssetOpsConfigBody,
} from '@/types/asset-ops'

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

/** GET /v1/asset-ops/postpone-bills */
export async function fetchPostponeBillPage(
  query: PostponeBillPageQuery,
): Promise<PageData<PostponeBill>> {
  const response = await request.get<ApiResponse<PageData<PostponeBill>>>(
    '/v1/asset-ops/postpone-bills',
    { params: buildParams({ ...query }) },
  )
  const data = response.data.data
  return {
    ...data,
    records: (data.records ?? []).map((row) => ({
      ...row,
      items: row.items ?? [],
    })),
  }
}

/** GET /v1/asset-ops/postpone-bills/{id} */
export async function fetchPostponeBillDetail(id: string): Promise<PostponeBill> {
  const response = await request.get<ApiResponse<PostponeBill>>(
    `/v1/asset-ops/postpone-bills/${id}`,
  )
  const data = response.data.data
  return { ...data, items: data.items ?? [] }
}

/** POST /v1/asset-ops/postpone-bills */
export async function createPostponeBill(body: CreatePostponeBillBody): Promise<PostponeBill> {
  const response = await request.post<ApiResponse<PostponeBill>>(
    '/v1/asset-ops/postpone-bills',
    body,
  )
  const data = response.data.data
  return { ...data, items: data.items ?? [] }
}

/** POST /v1/asset-ops/postpone-bills/{id}/approve */
export async function approvePostponeBill(
  id: string,
  body?: DecidePostponeBillBody,
): Promise<PostponeBill> {
  const response = await request.post<ApiResponse<PostponeBill>>(
    `/v1/asset-ops/postpone-bills/${id}/approve`,
    body ?? {},
  )
  const data = response.data.data
  return { ...data, items: data.items ?? [] }
}

/** POST /v1/asset-ops/postpone-bills/{id}/reject */
export async function rejectPostponeBill(
  id: string,
  body?: DecidePostponeBillBody,
): Promise<PostponeBill> {
  const response = await request.post<ApiResponse<PostponeBill>>(
    `/v1/asset-ops/postpone-bills/${id}/reject`,
    body ?? {},
  )
  const data = response.data.data
  return { ...data, items: data.items ?? [] }
}

/** GET /v1/asset-ops/config */
export async function fetchAssetOpsConfig(storeId?: number | null): Promise<AssetOpsConfig> {
  const response = await request.get<ApiResponse<AssetOpsConfig>>('/v1/asset-ops/config', {
    params: buildParams({ storeId: storeId ?? undefined }),
  })
  const data = response.data.data
  return {
    ...data,
    postponeApprovers: data.postponeApprovers ?? [],
    transferApprovers: data.transferApprovers ?? [],
    refundApprovers: data.refundApprovers ?? [],
  }
}

/** PUT /v1/asset-ops/config */
export async function saveAssetOpsConfig(body: UpsertAssetOpsConfigBody): Promise<AssetOpsConfig> {
  const response = await request.put<ApiResponse<AssetOpsConfig>>('/v1/asset-ops/config', body)
  const data = response.data.data
  return {
    ...data,
    postponeApprovers: data.postponeApprovers ?? [],
    transferApprovers: data.transferApprovers ?? [],
    refundApprovers: data.refundApprovers ?? [],
  }
}

/** GET /v1/asset-ops/transfer-bills */
export async function fetchTransferBillPage(
  query: TransferBillPageQuery,
): Promise<PageData<TransferBill>> {
  const response = await request.get<ApiResponse<PageData<TransferBill>>>(
    '/v1/asset-ops/transfer-bills',
    { params: buildParams({ ...query }) },
  )
  const data = response.data.data
  return {
    ...data,
    records: (data.records ?? []).map((row) => ({
      ...row,
      items: row.items ?? [],
    })),
  }
}

/** GET /v1/asset-ops/transfer-bills/{id} */
export async function fetchTransferBillDetail(id: string): Promise<TransferBill> {
  const response = await request.get<ApiResponse<TransferBill>>(
    `/v1/asset-ops/transfer-bills/${id}`,
  )
  const data = response.data.data
  return { ...data, items: data.items ?? [] }
}

/** POST /v1/asset-ops/transfer-bills */
export async function createTransferBill(body: CreateTransferBillBody): Promise<TransferBill> {
  const response = await request.post<ApiResponse<TransferBill>>(
    '/v1/asset-ops/transfer-bills',
    body,
  )
  const data = response.data.data
  return { ...data, items: data.items ?? [] }
}

/** POST /v1/asset-ops/transfer-bills/{id}/approve */
export async function approveTransferBill(
  id: string,
  body?: DecideTransferBillBody,
): Promise<TransferBill> {
  const response = await request.post<ApiResponse<TransferBill>>(
    `/v1/asset-ops/transfer-bills/${id}/approve`,
    body ?? {},
  )
  const data = response.data.data
  return { ...data, items: data.items ?? [] }
}

/** POST /v1/asset-ops/transfer-bills/{id}/reject */
export async function rejectTransferBill(
  id: string,
  body?: DecideTransferBillBody,
): Promise<TransferBill> {
  const response = await request.post<ApiResponse<TransferBill>>(
    `/v1/asset-ops/transfer-bills/${id}/reject`,
    body ?? {},
  )
  const data = response.data.data
  return { ...data, items: data.items ?? [] }
}

/** GET /v1/asset-ops/transfer-bills/package-children */
export async function fetchPackageTransferChildren(
  packageAccountId: number,
): Promise<PackageTransferChild[]> {
  const response = await request.get<ApiResponse<PackageTransferChild[]>>(
    '/v1/asset-ops/transfer-bills/package-children',
    { params: { packageAccountId } },
  )
  return response.data.data ?? []
}
