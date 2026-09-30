/**
 * 商品适用门店范围。对齐 GoodsScopeVo / ReplaceGoodsScopeCommand。
 * 空 entityIds = 全部可用。
 */

export interface GoodsScopeVo {
  entityIds: number[]
}

export interface ReplaceGoodsScopeBody {
  entityIds: number[]
}

/** 适用门店下拉选项（从组织树 store=true 或 /me stores 扁平化） */
export interface StoreOption {
  id: number
  name: string
}
