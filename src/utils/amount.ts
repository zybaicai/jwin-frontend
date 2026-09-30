/**
 * 金额字符串校验与规范化。禁止浮点运算。
 * 允许最多两位小数的非负十进制。
 */

const AMOUNT_PATTERN = /^(0|[1-9]\d*)(\.\d{1,2})?$/

export function isValidAmountString(value: string): boolean {
  const trimmed = value.trim()
  if (!trimmed) {
    return false
  }
  return AMOUNT_PATTERN.test(trimmed)
}

/** 校验通过返回规范化字符串；失败返回 null */
export function normalizeAmountString(value: string): string | null {
  const trimmed = value.trim()
  if (!isValidAmountString(trimmed)) {
    return null
  }
  if (!trimmed.includes('.')) {
    return trimmed
  }
  const [intPart, frac = ''] = trimmed.split('.')
  const padded = `${frac}00`.slice(0, 2)
  return `${intPart}.${padded}`
}

export function formatAmountDisplay(value: string | number | null | undefined): string {
  if (value == null || value === '') {
    return '—'
  }
  if (typeof value === 'number') {
    if (!Number.isFinite(value)) {
      return '—'
    }
    return value.toFixed(2)
  }
  const normalized = normalizeAmountString(String(value))
  return normalized ?? String(value)
}
