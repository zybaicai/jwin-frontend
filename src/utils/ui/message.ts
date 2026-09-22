import { ElMessage } from 'element-plus'

export const uiMessage = {
  success(message: string): void {
    ElMessage.success(message)
  },
  warning(message: string): void {
    ElMessage.warning(message)
  },
  error(message: string): void {
    ElMessage.error(message)
  },
  info(message: string): void {
    ElMessage.info(message)
  },
}
