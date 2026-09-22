import { resetAuthExpiredState } from '@/utils/auth-event'

const TOKEN_KEY = 'erp_access_token'

export function getToken(): string | null {
  const token = localStorage.getItem(TOKEN_KEY)
  if (token == null || token === '') {
    return null
  }
  return token
}

export function setToken(token: string): void {
  localStorage.setItem(TOKEN_KEY, token)
  resetAuthExpiredState()
}

export function removeToken(): void {
  localStorage.removeItem(TOKEN_KEY)
}

export function hasToken(): boolean {
  return getToken() != null
}
