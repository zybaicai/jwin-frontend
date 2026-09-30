<script setup lang="ts">
import type { StoreOption } from '@/types/goods-scope'

defineProps<{
  saleMode: 'all' | 'specified'
  consumeMode?: 'all' | 'specified'
  saleEntityIds: number[]
  consumeEntityIds?: number[]
  storeOptions: StoreOption[]
  editable: boolean
  /** 套餐等无消耗范围时传 false */
  showConsume?: boolean
  storeOptionsError?: string | null
}>()

const emit = defineEmits<{
  'update:saleMode': [value: 'all' | 'specified']
  'update:consumeMode': [value: 'all' | 'specified']
  'update:saleEntityIds': [value: number[]]
  'update:consumeEntityIds': [value: number[]]
}>()
</script>

<template>
  <div class="card-store-scope">
    <p class="scope-hint">
      由商品管理员维护适用门店。空列表表示全部可用。
    </p>
    <p v-if="storeOptionsError" class="scope-error">{{ storeOptionsError }}</p>

    <el-form-item label="销售范围">
      <div class="scope-block">
        <el-radio-group
          :model-value="saleMode"
          :disabled="!editable"
          @update:model-value="(v) => emit('update:saleMode', v as 'all' | 'specified')"
        >
          <el-radio value="all">全部可用</el-radio>
          <el-radio value="specified">指定适用门店</el-radio>
        </el-radio-group>
        <el-select
          v-if="saleMode === 'specified'"
          :model-value="saleEntityIds"
          multiple
          filterable
          collapse-tags
          collapse-tags-tooltip
          placeholder="选择适用门店"
          style="width: 100%; margin-top: 8px"
          :disabled="!editable"
          @update:model-value="(v) => emit('update:saleEntityIds', v as number[])"
        >
          <el-option
            v-for="s in storeOptions"
            :key="s.id"
            :label="s.name"
            :value="s.id"
          />
        </el-select>
      </div>
    </el-form-item>

    <el-form-item v-if="showConsume !== false" label="消耗范围">
      <div class="scope-block">
        <el-radio-group
          :model-value="consumeMode ?? 'all'"
          :disabled="!editable"
          @update:model-value="(v) => emit('update:consumeMode', v as 'all' | 'specified')"
        >
          <el-radio value="all">全部可用</el-radio>
          <el-radio value="specified">指定适用门店</el-radio>
        </el-radio-group>
        <el-select
          v-if="(consumeMode ?? 'all') === 'specified'"
          :model-value="consumeEntityIds ?? []"
          multiple
          filterable
          collapse-tags
          collapse-tags-tooltip
          placeholder="选择适用门店"
          style="width: 100%; margin-top: 8px"
          :disabled="!editable"
          @update:model-value="(v) => emit('update:consumeEntityIds', v as number[])"
        >
          <el-option
            v-for="s in storeOptions"
            :key="s.id"
            :label="s.name"
            :value="s.id"
          />
        </el-select>
      </div>
    </el-form-item>
  </div>
</template>

<style scoped>
.scope-hint {
  margin: 0 0 12px;
  font-size: 12px;
  color: #909399;
}

.scope-error {
  margin: 0 0 12px;
  font-size: 12px;
  color: #f56c6c;
}

.scope-block {
  width: 100%;
}
</style>
