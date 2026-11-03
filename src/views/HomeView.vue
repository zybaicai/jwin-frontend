<script setup lang="ts">
import { ref } from 'vue'

defineOptions({ name: 'HomeView' })

// 通过 Vite /bi 代理加载（绕过悦发BI X-Frame-Options: SAMEORIGIN）
// 同时 Vite /webroot 代理 FineReport 内部 JS/CSS/报表请求
const BI_URL = '/bi/webroot/decision#?activeTab=fd0cce31-dd3a-4eff-ac5b-1feac97d7386'
// 直接悦发BI登录页（给用户手动登录 cookie 用）
const BI_DIRECT = 'http://8.149.141.99:8080/webroot/decision'

// iframe 加载状态：loading / loaded / failed
const frameState = ref<'loading' | 'loaded' | 'failed'>('loading')
const frameError = ref(false)

function onIframeLoad(): void {
  frameState.value = 'loaded'
  frameError.value = false
}

function onIframeError(): void {
  frameState.value = 'failed'
  frameError.value = true
}

function openBILogin(): void {
  // 新窗口打开悦发BI，用户登录一次后 cookie 种到 .149.141.99，iframe 即可渲染
  window.open(BI_DIRECT, '_blank')
}

function reloadIframe(): void {
  frameState.value = 'loading'
  frameError.value = false
  const el = document.getElementById('bi-iframe') as HTMLIFrameElement | null
  if (el) {
    // 触发重新加载
    el.src = el.src
  }
}
</script>

<template>
  <div class="home-bi">
    <!-- 顶部操作条 -->
    <div class="bi-toolbar">
      <div class="bi-toolbar__left">
        <h2 class="bi-title">悦发BI · 门店会员分析驾驶舱</h2>
        <span v-if="frameState === 'loading'" class="bi-status bi-status--loading">加载中…</span>
        <span v-else-if="frameState === 'loaded'" class="bi-status bi-status--ok">已就绪</span>
        <span v-else class="bi-status bi-status--err">加载异常</span>
      </div>
      <div class="bi-toolbar__right">
        <button class="bi-btn bi-btn--ghost" type="button" @click="reloadIframe">刷新</button>
        <button class="bi-btn bi-btn--ghost" type="button" @click="openBILogin">在新窗口打开</button>
      </div>
    </div>

    <!-- 异常兜底条 -->
    <div v-if="frameError" class="bi-fallback">
      <div class="bi-fallback__content">
        <div class="bi-fallback__icon">⚠️</div>
        <div>
          <p class="bi-fallback__title">悦发BI 加载失败</p>
          <p class="bi-fallback__hint">
            请先在新窗口中登录一次悦发BI（账号 zy / 密码 5.UypN），登录成功后回到本页点击「刷新」即可显示驾驶舱。
          </p>
        </div>
        <button class="bi-btn bi-btn--primary" type="button" @click="openBILogin">前往悦发BI登录</button>
      </div>
    </div>

    <!-- iframe 主体 -->
    <div class="bi-frame-wrap">
      <iframe
        id="bi-iframe"
        class="bi-iframe"
        :src="BI_URL"
        title="悦发BI · 门店会员分析"
        frameborder="0"
        allowfullscreen
        referrerpolicy="no-referrer-when-downgrade"
        @load="onIframeLoad"
        @error="onIframeError"
      />
      <!-- 加载遮罩 -->
      <div v-if="frameState === 'loading'" class="bi-loading">
        <div class="bi-loading__spinner" />
        <span>悦发BI 驾驶舱加载中…</span>
      </div>
    </div>
  </div>
</template>

<style scoped>
.home-bi {
  display: flex;
  flex-direction: column;
  height: 100%;
  min-height: 0;
}

.bi-toolbar {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 14px 20px;
  background: #ffffff;
  border-bottom: 1px solid #e5e7eb;
  flex-shrink: 0;
}

.bi-toolbar__left {
  display: flex;
  align-items: center;
  gap: 12px;
}

.bi-title {
  margin: 0;
  font-size: 16px;
  font-weight: 600;
  color: #0f172a;
  letter-spacing: 0.02em;
}

.bi-status {
  font-size: 12px;
  padding: 2px 10px;
  border-radius: 10px;
  line-height: 1.6;
}
.bi-status--loading {
  background: #f1f5f9;
  color: #64748b;
}
.bi-status--ok {
  background: #dcfce7;
  color: #166534;
}
.bi-status--err {
  background: #fee2e2;
  color: #b91c1c;
}

.bi-toolbar__right {
  display: flex;
  gap: 8px;
}

.bi-btn {
  height: 32px;
  padding: 0 14px;
  border-radius: 6px;
  font-size: 13px;
  cursor: pointer;
  border: 1px solid transparent;
  transition: background-color 0.15s ease, border-color 0.15s ease;
}
.bi-btn--ghost {
  background: transparent;
  color: #475569;
  border-color: #cbd5e1;
}
.bi-btn--ghost:hover {
  background: #f1f5f9;
  color: #0f172a;
}
.bi-btn--primary {
  background: linear-gradient(135deg, #fb923c, #f97316);
  color: #ffffff;
  border: none;
}
.bi-btn--primary:hover {
  filter: brightness(0.95);
}

.bi-fallback {
  padding: 16px 20px;
  background: #fff7ed;
  border-bottom: 1px solid #fed7aa;
  flex-shrink: 0;
}
.bi-fallback__content {
  display: flex;
  align-items: center;
  gap: 14px;
}
.bi-fallback__icon {
  font-size: 24px;
  flex-shrink: 0;
}
.bi-fallback__title {
  margin: 0 0 2px 0;
  font-size: 14px;
  font-weight: 600;
  color: #9a3412;
}
.bi-fallback__hint {
  margin: 0;
  font-size: 13px;
  color: #9a3412;
  line-height: 1.6;
}

.bi-frame-wrap {
  flex: 1;
  min-height: 0;
  position: relative;
  background: #f8fafc;
}

.bi-iframe {
  display: block;
  width: 100%;
  height: 100%;
  border: 0;
  background: #ffffff;
}

.bi-loading {
  position: absolute;
  inset: 0;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  gap: 14px;
  background: rgba(255, 255, 255, 0.85);
  color: #64748b;
  font-size: 13px;
  letter-spacing: 0.05em;
}

.bi-loading__spinner {
  width: 32px;
  height: 32px;
  border: 3px solid #e2e8f0;
  border-top-color: #f97316;
  border-radius: 50%;
  animation: bi-spin 0.9s linear infinite;
}

@keyframes bi-spin {
  to {
    transform: rotate(360deg);
  }
}
</style>
