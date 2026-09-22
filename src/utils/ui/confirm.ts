import { ElMessageBox } from 'element-plus'

export interface UiConfirmOptions {
  title: string
  message: string
  confirmText?: string
  cancelText?: string
}

export async function uiConfirm(options: UiConfirmOptions): Promise<boolean> {
  try {
    await ElMessageBox.confirm(options.message, options.title, {
      confirmButtonText: options.confirmText ?? '确认',
      cancelButtonText: options.cancelText ?? '取消',
      type: 'warning',
      distinguishCancelAndClose: true,
    })
    return true
  } catch {
    return false
  }
}
