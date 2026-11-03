/** 基础设置字典类型：付款方式 / 商品分类 / 项目品牌 */
export type BasicSettingType = 'pay-methods' | 'product-categories' | 'project-brands'

export const BasicSettingPermission = {
  VIEW: 'system:setting:view',
  EDIT: 'system:setting:edit',
} as const

export interface BasicDictionaryItem {
  id: number
  name: string | null
  /** 仅付款方式使用：渠道编码（WECHAT/ALIPAY/SAVING_CARD/BANK_CARD 等） */
  channelCode?: string | null
  sequence: number | null
  active: boolean
  /** 仅商品分类使用：0 表示一级分类 */
  parentId?: number | null
}

export interface SaveBasicDictionaryBody {
  name: string
  /** 仅付款方式使用：渠道编码 */
  channelCode?: string | null
  sequence?: number | null
  active?: boolean | null
  /** 仅商品分类使用 */
  parentId?: number | null
}
