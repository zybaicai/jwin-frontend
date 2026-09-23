import type { ServicerEmployeeOption, ServicerOption } from '@/types/customer'

const MAIN_NURSE_NAMES = new Set(['主护理师', '主护理'])

/**
 * 从服务角色 options 中取出主护理师可选员工。与后端精确匹配口径一致。
 */
export function pickMainNurseEmployees(roles: ServicerOption[]): ServicerEmployeeOption[] {
  const result: ServicerEmployeeOption[] = []
  const seen = new Set<string>()
  for (const role of roles) {
    const name = role.name?.trim() ?? ''
    if (!MAIN_NURSE_NAMES.has(name)) {
      continue
    }
    for (const emp of role.servicerEmpList ?? []) {
      if (!emp.id || seen.has(emp.id)) {
        continue
      }
      seen.add(emp.id)
      result.push(emp)
    }
  }
  return result
}

export function formatDateTime(value: string | null | undefined): string {
  if (value == null || value === '') {
    return '—'
  }
  return value.replace('T', ' ').slice(0, 19)
}

export function formatDate(value: string | null | undefined): string {
  if (value == null || value === '') {
    return '—'
  }
  return value.slice(0, 10)
}

export function formatMoney(value: string | number | null | undefined): string {
  if (value == null || value === '') {
    return '—'
  }
  const amount = typeof value === 'number' ? value : Number(value)
  if (!Number.isFinite(amount)) {
    return '—'
  }
  return amount.toFixed(2)
}

export function formatGender(gender: string | null | undefined, genderName?: string | null): string {
  if (genderName != null && genderName !== '') {
    return genderName
  }
  if (gender === '1') {
    return '男'
  }
  if (gender === '2') {
    return '女'
  }
  if (gender === '0') {
    return '未知'
  }
  return '—'
}

export function formatMemberStatus(member: boolean | null | undefined): string {
  if (member === true) {
    return '会员'
  }
  if (member === false) {
    return '非会员'
  }
  return '—'
}

/** 次数/数量类余量展示 */
export function formatQuantity(value: string | number | null | undefined): string {
  if (value == null || value === '') {
    return '—'
  }
  const amount = typeof value === 'number' ? value : Number(value)
  if (!Number.isFinite(amount)) {
    return '—'
  }
  if (Number.isInteger(amount)) {
    return String(amount)
  }
  return amount.toFixed(2)
}

/**
 * 卡项余量：储值卡/套餐卡按金额，其余按次数或数量。
 */
export function formatCardBalance(
  itemType: string | null | undefined,
  balance: string | number | null | undefined,
): string {
  if (itemType === 'SAVING_CARD' || itemType === 'PACKAGE_CARD') {
    return formatMoney(balance)
  }
  return formatQuantity(balance)
}
