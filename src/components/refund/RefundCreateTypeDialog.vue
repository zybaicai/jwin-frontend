<script setup lang="ts">
defineOptions({ name: 'RefundCreateTypeDialog' })

const visible = defineModel<boolean>({ default: false })

const emit = defineEmits<{
  select: [type: 'SALE' | 'TREAT']
}>()

function pick(type: 'SALE' | 'TREAT'): void {
  visible.value = false
  emit('select', type)
}
</script>

<template>
  <el-dialog
    v-model="visible"
    title="新增退款"
    width="520px"
    append-to-body
    destroy-on-close
    :close-on-click-modal="false"
  >
    <p class="hint">请选择退款类型。销售退款按权益明细申请；消耗退款仅支持整单。</p>
    <div class="cards">
      <button type="button" class="card" @click="pick('SALE')">
        <div class="title">销售退款</div>
        <div class="desc">按销售订单剩余权益退款，可勾选明细；转账后按持有人分开申请。</div>
      </button>
      <button type="button" class="card" @click="pick('TREAT')">
        <div class="title">消耗退款</div>
        <div class="desc">按已完成消耗订单整单退回权益，审批通过后自动恢复。</div>
      </button>
    </div>
  </el-dialog>
</template>

<style scoped>
.hint {
  margin: 0 0 14px;
  color: #606266;
  font-size: 13px;
  line-height: 1.5;
}
.cards {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 12px;
}
.card {
  text-align: left;
  border: 1px solid var(--el-border-color);
  border-radius: 8px;
  background: #fff;
  padding: 14px 12px;
  cursor: pointer;
  transition: border-color 0.15s, box-shadow 0.15s;
}
.card:hover {
  border-color: var(--el-color-primary);
  box-shadow: 0 0 0 1px var(--el-color-primary-light-7);
}
.title {
  font-size: 15px;
  font-weight: 600;
  margin-bottom: 6px;
  color: #303133;
}
.desc {
  font-size: 12px;
  color: #909399;
  line-height: 1.45;
}
</style>
