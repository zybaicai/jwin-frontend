/**
 * 开单工作台：耗卡提交请求构建与校验。
 */

import type {
  CreateTreatOrderHandler,
  CreateTreatOrderItem,
  CreateTreatOrderRequest,
} from '@/types/treat'

export const TREAT_CASHIER_LAST_ORDER_KEY = 'sales-cashier:last-treat-order-id'

export interface ConsumeLineForSubmit {
  itemType: string
  accountId: number
  projectId: number | null
  quantity: number
  /** 储值拟用资金来源；不传金额时后端按本金优先自动拆分 */
  fundSource: 'principal' | 'bonus' | null
}

export interface TreatHandlerForSubmit {
  employeeId: string
  ratio: number | null
}

export type TreatCheckoutBlockReason =
  | 'NO_CREATE_PERMISSION'
  | 'NO_CUSTOMER'
  | 'NO_STORE'
  | 'NO_LINES'
  | 'NO_HANDLERS'
  | 'HANDLER_RATIO_INVALID'
  | 'SAVING_MISSING_PROJECT'
  | 'CARD_MISSING_PROJECT'

export function getTreatCheckoutBlockReason(input: {
  hasCreatePermission: boolean
  customerReady: boolean
  storeId: number | null | undefined
  lineCount: number
  handlerCount: number
  handlerRatioValid: boolean
  lines: ConsumeLineForSubmit[]
}): TreatCheckoutBlockReason | null {
  if (!input.hasCreatePermission) {
    return 'NO_CREATE_PERMISSION'
  }
  if (!input.customerReady) {
    return 'NO_CUSTOMER'
  }
  if (input.storeId == null) {
    return 'NO_STORE'
  }
  if (input.lineCount <= 0) {
    return 'NO_LINES'
  }
  if (input.handlerCount <= 0) {
    return 'NO_HANDLERS'
  }
  if (!input.handlerRatioValid) {
    return 'HANDLER_RATIO_INVALID'
  }
  for (const line of input.lines) {
    const type = String(line.itemType).toUpperCase()
    if (type === 'SAVING_CARD' && (line.projectId == null || line.projectId <= 0)) {
      return 'SAVING_MISSING_PROJECT'
    }
    if (
      (type === 'GENERAL_CARD' || type === 'TIME_CARD') &&
      (line.projectId == null || line.projectId <= 0)
    ) {
      return 'CARD_MISSING_PROJECT'
    }
  }
  return null
}

export function mapTreatCheckoutBlockMessage(reason: TreatCheckoutBlockReason): string {
  switch (reason) {
    case 'NO_CREATE_PERMISSION':
      return '无消耗开单权限（treat:order:create）'
    case 'NO_CUSTOMER':
      return '请先选择客户'
    case 'NO_STORE':
      return '请先选择当前门店'
    case 'NO_LINES':
      return '请添加消耗明细'
    case 'NO_HANDLERS':
      return '请选择经手人'
    case 'HANDLER_RATIO_INVALID':
      return '经手人比例合计须为 100%，或全部留空由后端均分'
    case 'SAVING_MISSING_PROJECT':
      return '储值耗卡必须选择消耗项目'
    case 'CARD_MISSING_PROJECT':
      return '次卡/时效卡耗卡必须指定项目'
    default:
      return '无法提交消耗单'
  }
}

/** 是否含卡类行（签字配置开启时需 signatureImageUrl） */
export function treatLinesNeedCardSign(lines: ConsumeLineForSubmit[]): boolean {
  return lines.some((line) => {
    const t = String(line.itemType).toUpperCase()
    return (
      t === 'GENERAL_CARD' ||
      t === 'TIME_CARD' ||
      t === 'SAVING_CARD' ||
      t === 'PACKAGE_CARD'
    )
  })
}

export function buildCreateTreatOrderRequest(input: {
  customerId: number
  storeId: number | null | undefined
  backdateEnabled: boolean
  billDate: string | null | undefined
  remark?: string | null
  signatureImageUrl?: string | null
  appointmentId?: string | null
  lines: ConsumeLineForSubmit[]
  handlers: TreatHandlerForSubmit[]
}): CreateTreatOrderRequest {
  if (!input.lines.length) {
    throw new Error('请添加消耗明细')
  }
  if (!input.handlers.length) {
    throw new Error('请选择经手人')
  }

  const items: CreateTreatOrderItem[] = input.lines.map((line) => {
    const item: CreateTreatOrderItem = {
      itemType: String(line.itemType).toUpperCase(),
      accountId: line.accountId,
      quantity: line.quantity,
    }
    if (line.projectId != null && line.projectId > 0) {
      item.projectId = line.projectId
    }
    // 储值金额由后端按现价×折扣计算；不传 principal/bonus 时后端本金优先自动拆分
    return item
  })

  const handlers: CreateTreatOrderHandler[] = input.handlers.map((h) => ({
    employeeId: h.employeeId,
    ratio: h.ratio,
  }))

  const body: CreateTreatOrderRequest = {
    customerId: input.customerId,
    storeId: input.storeId,
    items,
    handlers,
  }
  if (input.backdateEnabled && input.billDate) {
    body.billDate = input.billDate
  }
  if (input.remark) {
    body.remark = input.remark
  }
  if (input.signatureImageUrl) {
    body.signatureImageUrl = input.signatureImageUrl
  }
  if (input.appointmentId) {
    body.appointmentId = input.appointmentId
  }
  return body
}
