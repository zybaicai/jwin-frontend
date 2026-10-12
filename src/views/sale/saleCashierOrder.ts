/**
 * 开单工作台：销售提交请求构建与校验（纯逻辑，供页面与单元测试共用）。
 */

import type {
  CreateSaleOrderHandler,
  CreateSaleOrderItem,
  CreateSaleOrderRequest,
  SalePaymentAllocationInput,
  SalePaymentInput,
} from '@/types/sale'

export const SALE_CASHIER_LAST_ORDER_KEY = 'sales-cashier:last-order-id'

export interface HandlerForSubmit {
  employeeId: string
  ratio: number | null
}

export interface SaleLineForSubmit {
  clientLineKey?: string | null
  itemType: string
  itemId: number
  quantity: number
  price: string | number | null
  priceChangeReason: string | null
  gift: boolean
  arrearAmount?: number | null
  largessAmount?: number | null
  /** 仅 PROJECT 需要 */
  saleChannelId?: number | null
  savingAccountId?: number | null
  savingPrincipalAmount?: number | null
  savingBonusAmount?: number | null
  /** 本行经手人（独立配置） */
  handlers: HandlerForSubmit[]
}

export interface BuildCreateSaleOrderInput {
  customerId: number | null | undefined
  storeId: number | null | undefined
  /** 兼容旧整单渠道；新开单以 lines[].saleChannelId 为准 */
  saleChannelId?: number | null | undefined
  lines: SaleLineForSubmit[]
  /** 仅作兼容回落；正常开单以 lines[].handlers 为准 */
  handlers?: HandlerForSubmit[]
  backdateEnabled: boolean
  billDate: string | null | undefined
  createOnly: boolean
  payments: SalePaymentInput[]
  paymentAllocations?: SalePaymentAllocationInput[]
  arrearAmount: number
}

export type SaleCheckoutBlockReason =
  | 'NO_CREATE_PERMISSION'
  | 'NO_CUSTOMER'
  | 'NO_STORE'
  | 'NO_LINES'
  | 'NO_HANDLERS'
  | 'HANDLER_RATIO_INVALID'
  | 'PROJECT_NO_CHANNEL'

function isHandlerRatioValid(handlers: HandlerForSubmit[]): boolean {
  if (!handlers.length) {
    return false
  }
  const filled = handlers.filter((h) => h.ratio != null && Number.isFinite(h.ratio))
  if (filled.length === 0) {
    return true
  }
  if (filled.length !== handlers.length) {
    return false
  }
  const sum = filled.reduce((s, h) => s + Number(h.ratio), 0)
  return Math.abs(sum - 100) < 0.0001
}

/**
 * 结账前必填校验。
 * 销售渠道仅校验 PROJECT 明细；卡项/产品不要求渠道。
 */
export function getSaleCheckoutBlockReason(input: {
  hasCreatePermission: boolean
  customerReady: boolean
  storeId: number | null | undefined
  lines: Array<{
    itemType?: string
    saleChannelId?: number | null
    handlers: HandlerForSubmit[]
  }>
}): SaleCheckoutBlockReason | null {
  if (!input.hasCreatePermission) {
    return 'NO_CREATE_PERMISSION'
  }
  if (!input.customerReady) {
    return 'NO_CUSTOMER'
  }
  if (input.storeId == null) {
    return 'NO_STORE'
  }
  if (input.lines.length <= 0) {
    return 'NO_LINES'
  }
  for (const line of input.lines) {
    if (String(line.itemType || '').toUpperCase() === 'PROJECT' && line.saleChannelId == null) {
      return 'PROJECT_NO_CHANNEL'
    }
    if (!line.handlers?.length) {
      return 'NO_HANDLERS'
    }
    if (!isHandlerRatioValid(line.handlers)) {
      return 'HANDLER_RATIO_INVALID'
    }
  }
  return null
}

export function mapSaleCheckoutBlockMessage(reason: SaleCheckoutBlockReason): string {
  switch (reason) {
    case 'NO_CREATE_PERMISSION':
      return '无销售开单权限（sale:order:create）'
    case 'NO_CUSTOMER':
      return '请先选择客户'
    case 'NO_STORE':
      return '请先选择当前门店'
    case 'NO_LINES':
      return '请添加销售明细'
    case 'NO_HANDLERS':
      return '请为每条明细选择经手人'
    case 'HANDLER_RATIO_INVALID':
      return '每条明细的经手人比例合计须为 100%，或全部留空由后端均分'
    case 'PROJECT_NO_CHANNEL':
      return '有项目未选择销售渠道，请在左侧先选渠道再加入项目'
    default:
      return '无法结账'
  }
}

function mapHandlers(handlers: HandlerForSubmit[]): CreateSaleOrderHandler[] {
  return handlers.map((h) => ({
    employeeId: h.employeeId,
    ratio: h.ratio,
  }))
}

/**
 * 将工作台明细转换为 CreateSaleOrderRequest。
 * 项目未改价不传 price；卡类不传自定义价。
 * 仅 PROJECT 写入 saleChannelId；整单 saleChannelId 可选兼容。
 */
export function buildCreateSaleOrderRequest(
  input: BuildCreateSaleOrderInput,
): CreateSaleOrderRequest {
  if (input.customerId == null) {
    throw new Error('请先选择客户')
  }
  if (!input.lines.length) {
    throw new Error('请添加销售明细')
  }
  for (const line of input.lines) {
    if (String(line.itemType).toUpperCase() === 'PROJECT' && line.saleChannelId == null) {
      throw new Error('项目明细须选择销售渠道')
    }
    if (!line.handlers?.length) {
      throw new Error('请为每条明细选择经手人')
    }
    if (!isHandlerRatioValid(line.handlers)) {
      throw new Error('每条明细的经手人比例合计须为 100%')
    }
  }

  const items: CreateSaleOrderItem[] = input.lines.map((line, index) => {
    const item: CreateSaleOrderItem = {
      clientLineKey: line.clientLineKey?.trim() || `L${index + 1}`,
      itemType: String(line.itemType),
      itemId: line.itemId,
      quantity: line.quantity,
      gift: line.gift,
      handlers: mapHandlers(line.handlers),
    }
    if (String(line.itemType).toUpperCase() === 'PROJECT' && line.saleChannelId != null) {
      item.saleChannelId = line.saleChannelId
    }
    if (
      line.itemType === 'PROJECT' &&
      line.priceChangeReason &&
      line.price != null &&
      line.price !== ''
    ) {
      item.price = Number(line.price)
      item.priceChangeReason = line.priceChangeReason
    }
    if (line.arrearAmount != null && Number(line.arrearAmount) > 0) {
      item.arrearAmount = Number(line.arrearAmount)
    }
    if (
      line.itemType === 'SAVING_CARD' &&
      line.largessAmount != null &&
      Number(line.largessAmount) > 0
    ) {
      item.largessAmount = Number(line.largessAmount)
    }
    const sp = Number(line.savingPrincipalAmount ?? 0)
    const sb = Number(line.savingBonusAmount ?? 0)
    if ((sp > 0 || sb > 0) && line.savingAccountId != null) {
      item.savingAccountId = line.savingAccountId
      if (sp > 0) item.savingPrincipalAmount = sp
      if (sb > 0) item.savingBonusAmount = sb
    }
    return item
  })

  const body: CreateSaleOrderRequest = {
    customerId: input.customerId,
    storeId: input.storeId,
    items,
  }

  // 有项目时可选附带整单渠道（兼容）；纯卡/产品不传
  const firstProjectChannel = input.lines.find(
    (l) => String(l.itemType).toUpperCase() === 'PROJECT' && l.saleChannelId != null,
  )?.saleChannelId
  if (input.saleChannelId != null) {
    body.saleChannelId = input.saleChannelId
  } else if (firstProjectChannel != null) {
    body.saleChannelId = firstProjectChannel
  }

  if (input.handlers?.length) {
    body.handlers = mapHandlers(input.handlers)
  } else if (input.lines[0]?.handlers.length) {
    body.handlers = mapHandlers(input.lines[0].handlers)
  }

  if (input.backdateEnabled && input.billDate) {
    body.billDate = input.billDate
  }

  if (input.arrearAmount > 0) {
    body.arrearAmount = input.arrearAmount
  }

  if (!input.createOnly) {
    body.payments = input.payments
    if (input.paymentAllocations?.length) {
      body.paymentAllocations = input.paymentAllocations
    }
  }

  return body
}

/** 页面汇总应付；超额收款前端拦截收银台 */
export function isPayAmountExceedPayable(paySum: number, payable: number): boolean {
  return paySum > payable + 0.001
}

export { normalizeSaleOrderDetail } from '@/utils/sale/normalizeSaleOrder'
