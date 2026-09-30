import { ref } from 'vue'

import { fetchOrganizationTree, flattenStoreOptions } from '@/api/organization'
import type { StoreOption } from '@/types/goods-scope'
import { usePermissionStore } from '@/stores/permission'
import { useStoreStore } from '@/stores/store'
import { getUserFriendlyErrorMessage } from '@/utils/ui'

/**
 * 商品管理侧「适用门店」选项：优先全量组织树（org:store:view），否则回退 /me stores。
 */
export function useGoodsStoreOptions() {
  const permissionStore = usePermissionStore()
  const storeStore = useStoreStore()
  const storeOptions = ref<StoreOption[]>([])
  const storeOptionsError = ref<string | null>(null)

  async function loadStoreOptions(): Promise<void> {
    storeOptionsError.value = null
    try {
      if (permissionStore.hasPermission('org:store:view')) {
        const tree = await fetchOrganizationTree(true)
        storeOptions.value = flattenStoreOptions(tree)
      } else {
        storeOptions.value = storeStore.availableStores.map((s) => ({
          id: s.id,
          name: s.name,
        }))
        if (storeOptions.value.length === 0) {
          storeOptionsError.value =
            '暂无适用门店选项（需要 org:store:view 或当前账号无可访问门店）'
        }
      }
    } catch (error) {
      storeOptions.value = storeStore.availableStores.map((s) => ({
        id: s.id,
        name: s.name,
      }))
      storeOptionsError.value = getUserFriendlyErrorMessage(error)
    }
  }

  return { storeOptions, storeOptionsError, loadStoreOptions }
}
