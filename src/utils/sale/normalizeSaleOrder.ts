/** 销售订单详情缺省字段归一（API 与页面共用）。 */
export function normalizeSaleOrderDetail<
  T extends {
    items?: unknown
    payments?: unknown
    paymentAllocations?: unknown
    handlers?: unknown
  },
>(
  data: T,
): T & {
  items: NonNullable<T['items']> | []
  payments: NonNullable<T['payments']> | []
  paymentAllocations: NonNullable<T['paymentAllocations']> | []
  handlers: NonNullable<T['handlers']> | []
} {
  return {
    ...data,
    items: (data.items ?? []) as NonNullable<T['items']> | [],
    payments: (data.payments ?? []) as NonNullable<T['payments']> | [],
    paymentAllocations: (data.paymentAllocations ?? []) as NonNullable<T['paymentAllocations']> | [],
    handlers: (data.handlers ?? []) as NonNullable<T['handlers']> | [],
  }
}
