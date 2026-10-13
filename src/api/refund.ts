import request from '@/utils/request'
import type { ApiResponse } from '@/types/response'
import type { PageData } from '@/types/customer'
import type {
  CreateRefundBody,
  DecideRefundBody,
  PreviewRefundBody,
  RefundBill,
  RefundBillPageQuery,
  RefundPreview,
} from '@/types/refund'

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

function normalize(data: RefundBill): RefundBill {
  return {
    ...data,
    payments: data.payments ?? [],
    processes: data.processes ?? [],
    items: data.items ?? [],
    specialRefund: data.specialRefund ?? false,
  }
}

function normalizePreview(data: RefundPreview): RefundPreview {
  return {
    ...data,
    lines: data.lines ?? [],
    holders: data.holders ?? [],
    transfers: data.transfers ?? [],
    specialRefund: data.specialRefund ?? false,
  }
}

/** GET /v1/refunds */
export async function fetchRefundBillPage(
  query: RefundBillPageQuery,
): Promise<PageData<RefundBill>> {
  const response = await request.get<ApiResponse<PageData<RefundBill>>>('/v1/refunds', {
    params: buildParams({ ...query }),
  })
  const data = response.data.data
  return {
    ...data,
    records: (data.records ?? []).map(normalize),
  }
}

/** GET /v1/refunds/{id} */
export async function fetchRefundBillDetail(id: string): Promise<RefundBill> {
  const response = await request.get<ApiResponse<RefundBill>>(
    `/v1/refunds/${encodeURIComponent(id)}`,
  )
  return normalize(response.data.data)
}

/** POST /v1/refunds/preview —— 销售明细试算 / 消耗整单预览 */
export async function previewRefund(body: PreviewRefundBody): Promise<RefundPreview> {
  const response = await request.post<ApiResponse<RefundPreview>>('/v1/refunds/preview', body)
  return normalizePreview(response.data.data)
}

/** POST /v1/refunds */
export async function createRefund(body: CreateRefundBody): Promise<RefundBill> {
  const response = await request.post<ApiResponse<RefundBill>>('/v1/refunds', body)
  return normalize(response.data.data)
}

/** POST /v1/refunds/{id}/approve —— 通过后销售/消耗退款同事务自动执行 */
export async function approveRefundBill(
  id: string,
  body?: DecideRefundBody,
): Promise<RefundBill> {
  const response = await request.post<ApiResponse<RefundBill>>(
    `/v1/refunds/${encodeURIComponent(id)}/approve`,
    body ?? {},
  )
  return normalize(response.data.data)
}

/** POST /v1/refunds/{id}/reject */
export async function rejectRefundBill(
  id: string,
  body?: DecideRefundBody,
): Promise<RefundBill> {
  const response = await request.post<ApiResponse<RefundBill>>(
    `/v1/refunds/${encodeURIComponent(id)}/reject`,
    body ?? {},
  )
  return normalize(response.data.data)
}
