/**
 * 耗卡 / 消耗单类型。字段对齐后端 CustomerAssetsVo / CreateTreatOrderCommand / TreatOrderVo。
 */

/** 对齐 CustomerAssetsVo —— GET /v1/treat/customers/{id}/available-assets */
export interface TreatProjectAsset {
  accountId: number
  projectId: number | null
  name: string | null
  balance: number | null
  packageCardAccountId: number | null
  canUse: boolean | null
}

export interface TreatProductAsset {
  accountId: number
  productId: number | null
  name: string | null
  balance: number | null
  packageCardAccountId: number | null
  canUse: boolean | null
}

export interface TreatSavingAsset {
  accountId: number
  savingCardId: number | null
  name: string | null
  principalBalance: number | string | null
  bonusBalance: number | string | null
  validDate: string | null
  packageCardAccountId: number | null
  canUse: boolean | null
}

export interface TreatPackageAsset {
  accountId: number
  packageCardId: number | null
  name: string | null
  validDate: string | null
  canUse: boolean | null
}

export interface TreatGeneralCardAsset {
  accountId: number
  generalCardId: number | null
  name: string | null
  balance: number | null
  validDate: string | null
  packageCardAccountId: number | null
  canUse: boolean | null
}

export interface TreatTimeCardAsset {
  accountId: number
  timeCardId: number | null
  name: string | null
  performanceBalance: number | null
  validDate: string | null
  packageCardAccountId: number | null
  canUse: boolean | null
}

export interface CustomerAvailableAssets {
  projects: TreatProjectAsset[]
  products: TreatProductAsset[]
  saving: TreatSavingAsset[]
  packageCards: TreatPackageAsset[]
  generalCards: TreatGeneralCardAsset[]
  timeCards: TreatTimeCardAsset[]
}

/** 对齐 CreateTreatOrderCommand.Item —— 本阶段仅用于工作台草稿，不提交 */
export interface CreateTreatOrderItemDraft {
  itemType: string
  accountId: number
  quantity: number
  projectId?: number | null
  principalAmount?: number | string | null
  bonusAmount?: number | string | null
}

/** 对齐 CreateTreatOrderCommand.Handler */
export interface CreateTreatOrderHandlerDraft {
  employeeId: string
  ratio?: number | string | null
}

export const TreatPermission = {
  ORDER_VIEW: 'treat:order:view',
  ORDER_CREATE: 'treat:order:create',
  ORDER_CANCEL: 'treat:order:cancel',
  ORDER_BACKDATE: 'treat:order:backdate',
  ORDER_EDIT_HANDLER: 'treat:order:edit-handler',
  CONFIG_EDIT: 'treat:config:edit',
} as const

export const TreatItemType = {
  PROJECT: 'PROJECT',
  GENERAL_CARD: 'GENERAL_CARD',
  TIME_CARD: 'TIME_CARD',
  SAVING_CARD: 'SAVING_CARD',
} as const
