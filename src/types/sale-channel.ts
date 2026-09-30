/**
 * 销售渠道（销售方式）类型。字段对齐后端 SaleChannelVo。
 * 开单仅需叶子 options；管理端 CRUD 本阶段不封装。
 */

/** 对齐 SaleChannelVo —— GET /v1/sale-channels/options */
export interface SaleChannelOption {
  id: number
  code: string | null
  name: string | null
  parentId: number | null
  sequence: number | null
  active: boolean | null
  remark: string | null
  /** 是否叶子（可开单选用） */
  leaf: boolean | null
}

export const SaleChannelPermission = {
  VIEW: 'sale-channel:view',
  EDIT: 'sale-channel:edit',
} as const
