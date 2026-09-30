/**
 * 项目耗材配置类型。对齐后端 ConsumableCategoryVo / ConsumableTemplateVo。
 * 列表无 sortField 白名单；类别默认 sequence asc,id asc；模板默认 id desc。
 * 禁止实现产品自有耗材模板、耗材分类适用项目。
 */

export const ConsumablePermission = {
  VIEW: 'consumable:view',
  EDIT: 'consumable:edit',
} as const

/** ---------- 耗材类别 ---------- */

export interface ConsumableCategoryItem {
  id: number
  name: string | null
  parentId: number | null
  sequence: number | null
  active: boolean | null
}

export interface UpsertConsumableCategoryBody {
  name: string
  parentId?: number | null
  sequence?: number | null
  active?: boolean | null
}

export interface ConsumableCategoryListQuery {
  onlyActive?: boolean
}

/** ---------- 耗材模板 ---------- */

export interface ConsumableTemplateProductLine {
  productId: number
  minimumUnitQuantity: number
}

export interface ConsumableTemplateItem {
  id: number
  name: string | null
  categoryId: number | null
  categoryName: string | null
  active: boolean | null
  /** 详情才返回；列表接口不带明细 */
  products?: ConsumableTemplateProductLine[] | null
  projectIds?: number[] | null
}

/**
 * 创建/更新命令。
 * products / projectIds 为 null 时后端不改动；传数组则全量替换。
 */
export interface UpsertConsumableTemplateBody {
  name: string
  categoryId: number
  active?: boolean | null
  products?: ConsumableTemplateProductLine[] | null
  projectIds?: number[] | null
}

export interface ConsumableTemplateListQuery {
  onlyActive?: boolean
  categoryId?: number
}
