<script setup lang="ts">
import BasicDictionaryPane from '@/views/settings/BasicDictionaryPane.vue'

defineOptions({ name: 'PayMethodSettingView' })
</script>

<template>
  <BasicDictionaryPane
    type="pay-methods"
    title="付款方式"
    create-label="新增付款方式"
  />
</template>
