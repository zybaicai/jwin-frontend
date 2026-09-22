<script setup lang="ts">
import { ref } from 'vue'

import AppEmpty from '@/components/common/AppEmpty.vue'
import AppError from '@/components/common/AppError.vue'
import { ApiBusinessError, ApiHttpError } from '@/utils/api-error'
import { ApiCode } from '@/types/response'
import { notifyError, runExclusive, uiConfirm, uiMessage } from '@/utils/ui'

const anyPermission = ['org:store:view', '__test:no:such:permission__']
const nonePermission = ['__test:no:such:permission__', '__test:also:missing__']

const saving = ref(false)
const pageLoading = ref(false)
const actionNote = ref('')

function showSuccess() {
  uiMessage.success('操作成功')
}

function showWarning() {
  uiMessage.warning('当前没有可操作数据')
}

function showError() {
  uiMessage.error('操作失败')
}

function showInfo() {
  uiMessage.info('这是一条提示')
}

async function openConfirm() {
  const confirmed = await uiConfirm({
    title: '确认操作',
    message: '确定要执行该操作吗？确认后只会验证交互，不会修改业务数据。',
    confirmText: '确认',
    cancelText: '取消',
  })
  actionNote.value = confirmed ? '已确认' : '已取消'
  if (confirmed) {
    uiMessage.success('操作成功')
  }
}

async function runSave() {
  await runExclusive(saving, async () => {
    await new Promise((resolve) => {
      window.setTimeout(resolve, 600)
    })
    uiMessage.success('操作成功')
  })
}

async function runPageLoading() {
  if (pageLoading.value) {
    return
  }
  pageLoading.value = true
  await new Promise((resolve) => {
    window.setTimeout(resolve, 600)
  })
  pageLoading.value = false
}

function showNetworkError() {
  notifyError(new ApiHttpError(0, '网络异常'))
}

function showForbidden() {
  notifyError(new ApiBusinessError(ApiCode.FORBIDDEN, 'raw-forbidden'))
}

function showStoreForbidden() {
  notifyError(new ApiBusinessError(ApiCode.STORE_FORBIDDEN, 'raw-store'))
}

function showUnauthorized() {
  notifyError(new ApiBusinessError(ApiCode.UNAUTHORIZED, 'raw-unauthorized'))
  actionNote.value = '10001 未重复提示'
}

function retryLoad() {
  uiMessage.success('已重新加载')
}
</script>

<template>
  <main class="diagnostic">
    <h1>基础框架诊断</h1>
    <p class="note">不是业务功能。权限只控制界面显示，不代替后端鉴权。</p>

    <section>
      <h2>消息</h2>
      <el-button @click="showSuccess">成功消息</el-button>
      <el-button @click="showWarning">警告消息</el-button>
      <el-button @click="showError">错误消息</el-button>
      <el-button @click="showInfo">信息消息</el-button>
    </section>

    <section>
      <h2>确认与加载</h2>
      <el-button @click="openConfirm">打开确认框</el-button>
      <el-button :loading="saving" :disabled="saving" @click="runSave">保存</el-button>
      <el-button :loading="pageLoading" :disabled="pageLoading" @click="runPageLoading">
        页面加载
      </el-button>
      <p v-if="actionNote" class="note">{{ actionNote }}</p>
      <div v-loading="pageLoading" class="loading-panel">页面内容区</div>
    </section>

    <section>
      <h2>权限与状态</h2>
      <el-button v-permission="'org:store:view'" data-permission-case="granted">有权限按钮</el-button>
      <el-button v-permission="'__test:no:such:permission__'" data-permission-case="denied">
        无权限按钮
      </el-button>
      <el-button v-permission="anyPermission" data-permission-case="any">任一权限按钮</el-button>
      <el-button v-permission="nonePermission" data-permission-case="none">全部无权限按钮</el-button>
      <el-button disabled data-permission-case="state-disabled">当前状态不可操作</el-button>
    </section>

    <section>
      <h2>空状态与错误</h2>
      <AppEmpty title="暂无数据" description="当前没有可展示的记录" />
      <AppError title="加载失败" description="网络异常，请稍后重试" @retry="retryLoad" />
    </section>

    <section>
      <h2>错误提示</h2>
      <el-button @click="showNetworkError">模拟网络异常</el-button>
      <el-button @click="showForbidden">模拟无权限</el-button>
      <el-button @click="showStoreForbidden">模拟无门店权限</el-button>
      <el-button @click="showUnauthorized">模拟登录失效提示</el-button>
    </section>
  </main>
</template>

<style scoped>
.diagnostic {
  padding: 24px;
}

h1 {
  margin: 0 0 8px;
  font-size: 20px;
}

h2 {
  margin: 0 0 12px;
  font-size: 16px;
}

.note {
  margin: 0 0 16px;
  color: #909399;
}

section {
  margin-bottom: 24px;
}

section :deep(.el-button) {
  margin: 0 8px 8px 0;
}

.loading-panel {
  height: 72px;
  margin-top: 8px;
  border: 1px solid #e4e7ed;
  border-radius: 4px;
  background: #fff;
  line-height: 72px;
  text-align: center;
  color: #606266;
}
</style>
