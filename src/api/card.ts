import request from '@/utils/request'
import type { ApiResponse } from '@/types/response'
import type {
  CardCategoryItem,
  CardCategoryKind,
  CardCategoryListQuery,
  CardListQuery,
  GeneralCardItem,
  PackageCardItem,
  PriceAreaItem,
  SavingCardDiscountItem,
  SavingCardDiscountListQuery,
  SavingCardItem,
  TimeCardItem,
  UpsertCardCategoryBody,
  UpsertGeneralCardBody,
  UpsertPackageCardBody,
  UpsertSavingCardBody,
  UpsertSavingCardDiscountBody,
  UpsertTimeCardBody,
} from '@/types/card'

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

/** ---------- 通用次卡 ---------- */

export async function fetchGeneralCardList(
  query: CardListQuery | boolean = {},
): Promise<GeneralCardItem[]> {
  const q: CardListQuery = typeof query === 'boolean' ? { onlySellable: query } : query
  const response = await request.get<ApiResponse<GeneralCardItem[]>>('/v1/cards/general', {
    params: buildParams({
      onlySellable: q.onlySellable,
      categoryId: q.categoryId,
      sortField: q.sortField,
      sortOrder: q.sortOrder,
    }),
  })
  return response.data.data ?? []
}

export async function fetchGeneralCardOptions(keyword?: string): Promise<GeneralCardItem[]> {
  const response = await request.get<ApiResponse<GeneralCardItem[]>>('/v1/cards/general/options', {
    params: buildParams({ keyword }),
  })
  return response.data.data ?? []
}

export async function fetchGeneralCardDetail(id: number): Promise<GeneralCardItem> {
  const response = await request.get<ApiResponse<GeneralCardItem>>(`/v1/cards/general/${id}`)
  return response.data.data
}

export async function createGeneralCard(body: UpsertGeneralCardBody): Promise<GeneralCardItem> {
  const response = await request.post<ApiResponse<GeneralCardItem>>('/v1/cards/general', body)
  return response.data.data
}

export async function updateGeneralCard(
  id: number,
  body: UpsertGeneralCardBody,
): Promise<GeneralCardItem> {
  const response = await request.put<ApiResponse<GeneralCardItem>>(`/v1/cards/general/${id}`, body)
  return response.data.data
}

export async function deactivateGeneralCard(id: number): Promise<GeneralCardItem> {
  const response = await request.delete<ApiResponse<GeneralCardItem>>(`/v1/cards/general/${id}`)
  return response.data.data
}

/** ---------- 时效卡 ---------- */

export async function fetchTimeCardList(
  query: CardListQuery | boolean = {},
): Promise<TimeCardItem[]> {
  const q: CardListQuery = typeof query === 'boolean' ? { onlySellable: query } : query
  const response = await request.get<ApiResponse<TimeCardItem[]>>('/v1/cards/time', {
    params: buildParams({
      onlySellable: q.onlySellable,
      categoryId: q.categoryId,
      sortField: q.sortField,
      sortOrder: q.sortOrder,
    }),
  })
  return response.data.data ?? []
}

export async function fetchTimeCardOptions(keyword?: string): Promise<TimeCardItem[]> {
  const response = await request.get<ApiResponse<TimeCardItem[]>>('/v1/cards/time/options', {
    params: buildParams({ keyword }),
  })
  return response.data.data ?? []
}

export async function fetchTimeCardDetail(id: number): Promise<TimeCardItem> {
  const response = await request.get<ApiResponse<TimeCardItem>>(`/v1/cards/time/${id}`)
  return response.data.data
}

export async function createTimeCard(body: UpsertTimeCardBody): Promise<TimeCardItem> {
  const response = await request.post<ApiResponse<TimeCardItem>>('/v1/cards/time', body)
  return response.data.data
}

export async function updateTimeCard(id: number, body: UpsertTimeCardBody): Promise<TimeCardItem> {
  const response = await request.put<ApiResponse<TimeCardItem>>(`/v1/cards/time/${id}`, body)
  return response.data.data
}

export async function deactivateTimeCard(id: number): Promise<TimeCardItem> {
  const response = await request.delete<ApiResponse<TimeCardItem>>(`/v1/cards/time/${id}`)
  return response.data.data
}

/** ---------- 储值卡 ---------- */

export async function fetchSavingCardList(
  query: CardListQuery | boolean = {},
): Promise<SavingCardItem[]> {
  const q: CardListQuery = typeof query === 'boolean' ? { onlySellable: query } : query
  const response = await request.get<ApiResponse<SavingCardItem[]>>('/v1/cards/saving', {
    params: buildParams({
      onlySellable: q.onlySellable,
      categoryId: q.categoryId,
      sortField: q.sortField,
      sortOrder: q.sortOrder,
    }),
  })
  return response.data.data ?? []
}

export async function fetchSavingCardOptions(keyword?: string): Promise<SavingCardItem[]> {
  const response = await request.get<ApiResponse<SavingCardItem[]>>('/v1/cards/saving/options', {
    params: buildParams({ keyword }),
  })
  return response.data.data ?? []
}

export async function fetchSavingCardDetail(id: number): Promise<SavingCardItem> {
  const response = await request.get<ApiResponse<SavingCardItem>>(`/v1/cards/saving/${id}`)
  return response.data.data
}

export async function createSavingCard(body: UpsertSavingCardBody): Promise<SavingCardItem> {
  const response = await request.post<ApiResponse<SavingCardItem>>('/v1/cards/saving', body)
  return response.data.data
}

export async function updateSavingCard(
  id: number,
  body: UpsertSavingCardBody,
): Promise<SavingCardItem> {
  const response = await request.put<ApiResponse<SavingCardItem>>(`/v1/cards/saving/${id}`, body)
  return response.data.data
}

export async function deactivateSavingCard(id: number): Promise<SavingCardItem> {
  const response = await request.delete<ApiResponse<SavingCardItem>>(`/v1/cards/saving/${id}`)
  return response.data.data
}

/** ---------- 套餐卡 ---------- */

export async function fetchPackageCardList(
  query: CardListQuery | boolean = {},
): Promise<PackageCardItem[]> {
  const q: CardListQuery = typeof query === 'boolean' ? { onlySellable: query } : query
  const response = await request.get<ApiResponse<PackageCardItem[]>>('/v1/cards/package', {
    params: buildParams({
      onlySellable: q.onlySellable,
      categoryId: q.categoryId,
      sortField: q.sortField,
      sortOrder: q.sortOrder,
    }),
  })
  return response.data.data ?? []
}

export async function fetchPackageCardOptions(keyword?: string): Promise<PackageCardItem[]> {
  const response = await request.get<ApiResponse<PackageCardItem[]>>('/v1/cards/package/options', {
    params: buildParams({ keyword }),
  })
  return response.data.data ?? []
}

export async function fetchPackageCardDetail(id: number): Promise<PackageCardItem> {
  const response = await request.get<ApiResponse<PackageCardItem>>(`/v1/cards/package/${id}`)
  return response.data.data
}

export async function createPackageCard(body: UpsertPackageCardBody): Promise<PackageCardItem> {
  const response = await request.post<ApiResponse<PackageCardItem>>('/v1/cards/package', body)
  return response.data.data
}

export async function updatePackageCard(
  id: number,
  body: UpsertPackageCardBody,
): Promise<PackageCardItem> {
  const response = await request.put<ApiResponse<PackageCardItem>>(`/v1/cards/package/${id}`, body)
  return response.data.data
}

export async function deactivatePackageCard(id: number): Promise<PackageCardItem> {
  const response = await request.delete<ApiResponse<PackageCardItem>>(`/v1/cards/package/${id}`)
  return response.data.data
}

/** ---------- 储值区域折扣 ---------- */

export async function fetchSavingCardDiscountList(
  query: SavingCardDiscountListQuery = {},
): Promise<SavingCardDiscountItem[]> {
  const response = await request.get<ApiResponse<SavingCardDiscountItem[]>>(
    '/v1/saving-card-discounts',
    {
      params: buildParams({
        priceAreaId: query.priceAreaId,
        projectId: query.projectId,
        sortField: query.sortField,
        sortOrder: query.sortOrder,
      }),
    },
  )
  return response.data.data ?? []
}

export async function fetchSavingCardDiscountDetail(
  id: number,
): Promise<SavingCardDiscountItem> {
  const response = await request.get<ApiResponse<SavingCardDiscountItem>>(
    `/v1/saving-card-discounts/${id}`,
  )
  return response.data.data
}

export async function createSavingCardDiscount(
  body: UpsertSavingCardDiscountBody,
): Promise<SavingCardDiscountItem> {
  const response = await request.post<ApiResponse<SavingCardDiscountItem>>(
    '/v1/saving-card-discounts',
    body,
  )
  return response.data.data
}

export async function updateSavingCardDiscount(
  id: number,
  body: UpsertSavingCardDiscountBody,
): Promise<SavingCardDiscountItem> {
  const response = await request.put<ApiResponse<SavingCardDiscountItem>>(
    `/v1/saving-card-discounts/${id}`,
    body,
  )
  return response.data.data
}

export async function deactivateSavingCardDiscount(id: number): Promise<SavingCardDiscountItem> {
  const response = await request.delete<ApiResponse<SavingCardDiscountItem>>(
    `/v1/saving-card-discounts/${id}`,
  )
  return response.data.data
}

/** GET /v1/price-areas —— 折扣表单适用门店区域选项；权限 price:area:view */
export async function fetchPriceAreaList(onlyActive?: boolean): Promise<PriceAreaItem[]> {
  const response = await request.get<ApiResponse<PriceAreaItem[]>>('/v1/price-areas', {
    params: buildParams({ onlyActive }),
  })
  return response.data.data ?? []
}

/** ---------- 四类卡分类（归类展示，非销售渠道） ---------- */

function categoryBase(kind: CardCategoryKind): string {
  return `/v1/cards/${kind}/categories`
}

export async function fetchCardCategoryList(
  kind: CardCategoryKind,
  query: CardCategoryListQuery = {},
): Promise<CardCategoryItem[]> {
  const response = await request.get<ApiResponse<CardCategoryItem[]>>(categoryBase(kind), {
    params: buildParams({
      onlyActive: query.onlyActive,
      sortField: query.sortField,
      sortOrder: query.sortOrder,
    }),
  })
  return response.data.data ?? []
}

/** 仅启用分类，供卡定义表单下拉 */
export async function fetchCardCategoryOptions(
  kind: CardCategoryKind,
): Promise<CardCategoryItem[]> {
  const response = await request.get<ApiResponse<CardCategoryItem[]>>(
    `${categoryBase(kind)}/options`,
  )
  return response.data.data ?? []
}

export async function fetchCardCategoryDetail(
  kind: CardCategoryKind,
  id: number,
): Promise<CardCategoryItem> {
  const response = await request.get<ApiResponse<CardCategoryItem>>(
    `${categoryBase(kind)}/${id}`,
  )
  return response.data.data
}

export async function createCardCategory(
  kind: CardCategoryKind,
  body: UpsertCardCategoryBody,
): Promise<CardCategoryItem> {
  const response = await request.post<ApiResponse<CardCategoryItem>>(categoryBase(kind), body)
  return response.data.data
}

export async function updateCardCategory(
  kind: CardCategoryKind,
  id: number,
  body: UpsertCardCategoryBody,
): Promise<CardCategoryItem> {
  const response = await request.put<ApiResponse<CardCategoryItem>>(
    `${categoryBase(kind)}/${id}`,
    body,
  )
  return response.data.data
}

export async function deactivateCardCategory(
  kind: CardCategoryKind,
  id: number,
): Promise<CardCategoryItem> {
  const response = await request.delete<ApiResponse<CardCategoryItem>>(
    `${categoryBase(kind)}/${id}`,
  )
  return response.data.data
}
