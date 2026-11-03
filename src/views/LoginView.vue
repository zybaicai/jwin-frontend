<script setup lang="ts">
import { computed, nextTick, onMounted, onUnmounted, ref, watch } from 'vue'
import { useRouter } from 'vue-router'

import { useAuthStore } from '@/stores/auth'
import { ApiBusinessError, ApiHttpError } from '@/utils/api-error'

import './login/login-page.css'

const STORAGE_KEY = 'yudao_erp_remember_account'

const router = useRouter()
const authStore = useAuthStore()

type LoginMode = 'account' | 'phone'
type PolicyType = 'privacy' | 'terms'

const loginMode = ref<LoginMode>('account')
const submitting = ref(false)
const submitText = ref('登录工作台')
const showPassword = ref(false)
const rememberAccount = ref(false)
const formError = ref('')
const errorField = ref<string | null>(null)

const account = ref('')
const password = ref('')
const phone = ref('')
const code = ref('')

const toastVisible = ref(false)
const toastText = ref('提示')
let toastTimer: number | undefined

const successVisible = ref(false)
const successDesc = ref('正在进入门店运营工作台，请稍候…')
const successBarWidth = ref('0%')
let successRedirectTimer: number | undefined

const forgotVisible = ref(false)
const forgotAccount = ref('')
const forgotPhone = ref('')
const forgotError = ref('')
const forgotAccountError = ref(false)
const forgotPhoneError = ref(false)
const forgotSuccess = ref(false)
const forgotSubmitting = ref(false)
const forgotTicket = ref('')

const policyVisible = ref(false)
const policyType = ref<PolicyType>('privacy')

const codeCountdown = ref(0)
let codeTimer: number | undefined

const particleField = ref<HTMLElement | null>(null)
const accountInputRef = ref<HTMLInputElement | null>(null)
const passwordInputRef = ref<HTMLInputElement | null>(null)
const phoneInputRef = ref<HTMLInputElement | null>(null)
const codeInputRef = ref<HTMLInputElement | null>(null)

const POLICY_TEXT: Record<PolicyType, string[]> = {
  privacy: [
    '一、信息收集范围',
    '本系统仅收集员工完成门店运营工作所必需的信息，包括登录凭据、门店归属、岗位权限，以及为安全审计目的记录的操作日志与登录设备信息。',
    '二、信息使用目的',
    '收集的信息用于身份识别、权限校验、门店经营数据统计与服务记录留存，不会用于与门店运营无关的商业推广。',
    '三、信息共享与保护',
    '客户个人资料仅在门店服务履约与健康档案管理范围内流转。系统采用分级授权、传输加密与操作留痕机制保护数据安全。',
    '四、员工权利',
    '员工可向门店管理员申请查阅或更正本人的账号信息，离职后账号将在 30 日内停用并移交数据管理责任。',
  ],
  terms: [
    '一、账号使用',
    '系统账号仅限本人使用，不得转借、共享或交由他人代为操作。因保管不当导致的账号风险由使用人及所属门店承担。',
    '二、操作规范',
    '客户健康档案、检测数据与护理记录须如实录入，严禁虚构服务记录或篡改检测结果。所有关键操作均自动留痕。',
    '三、数据归属',
    '系统内生成的门店经营数据与客户档案归预道养发所有，员工不得导出、复制或对外传播。',
    '四、异常处理',
    '如发现账号异常登录、数据错漏或权限越界，请立即联系区域运营支持，系统将保留相关记录以便追溯。',
  ],
}

const policyTitle = computed(() => (policyType.value === 'privacy' ? '隐私政策' : '服务条款'))
const policyParagraphs = computed(() => POLICY_TEXT[policyType.value] || [])
const sendCodeLabel = computed(() => {
  if (codeCountdown.value > 0) {
    return `${codeCountdown.value}s 后重发`
  }
  return '获取验证码'
})
const rememberBoxStyle = computed(() => {
  if (rememberAccount.value) {
    return { backgroundColor: '#ff8646', borderColor: '#ff8646' }
  }
  return { backgroundColor: '', borderColor: '' }
})

function showToast(message: string) {
  toastText.value = message
  toastVisible.value = false
  void nextTick(() => {
    toastVisible.value = true
  })
  window.clearTimeout(toastTimer)
  toastTimer = window.setTimeout(() => {
    toastVisible.value = false
  }, 2400)
}

function clearErrors() {
  formError.value = ''
  errorField.value = null
}

function setFormError(field: string | null, message: string) {
  errorField.value = field
  formError.value = message
}

function switchLoginMode(mode: LoginMode) {
  loginMode.value = mode
  submitText.value = mode === 'account' ? '登录工作台' : '验证并登录'
  clearErrors()
}

function clearAccount() {
  account.value = ''
  accountInputRef.value?.focus()
  if (!submitting.value) {
    clearErrors()
  }
}

function togglePassword() {
  showPassword.value = !showPassword.value
}

function reserveFeature(name: string) {
  showToast(`${name}即将开放，请使用账号密码登录`)
}

function openBrandStory(event: Event) {
  event.preventDefault()
  showToast('品牌故事即将开放')
}

function openForgot() {
  forgotAccount.value = account.value.trim()
  forgotPhone.value = ''
  forgotError.value = ''
  forgotAccountError.value = false
  forgotPhoneError.value = false
  forgotSuccess.value = false
  forgotSubmitting.value = false
  forgotVisible.value = true
}

function closeForgot() {
  forgotVisible.value = false
}

function openPolicy(type: PolicyType) {
  policyType.value = type
  policyVisible.value = true
}

function closePolicy() {
  policyVisible.value = false
}

function closeSuccess() {
  window.clearTimeout(successRedirectTimer)
  successVisible.value = false
  successBarWidth.value = '0%'
  submitting.value = false
  submitText.value = loginMode.value === 'account' ? '登录工作台' : '验证并登录'
  // 已拿到 token，返回登录需清会话，否则路由守卫会直接踢回首页
  authStore.clearAuth()
}

async function goWorkbench() {
  window.clearTimeout(successRedirectTimer)
  await router.push({ name: 'home' })
}

function openSuccess(desc: string) {
  successDesc.value = desc
  successVisible.value = true
  successBarWidth.value = '0%'
  window.setTimeout(() => {
    successBarWidth.value = '100%'
  }, 80)
  window.clearTimeout(successRedirectTimer)
  successRedirectTimer = window.setTimeout(() => {
    void goWorkbench()
  }, 900)
}

function sendCode() {
  const phoneValue = phone.value.trim()
  if (!/^1[3-9]\d{9}$/.test(phoneValue)) {
    setFormError('phoneField', '请先输入正确的 11 位手机号码，再获取验证码。')
    phoneInputRef.value?.focus()
    return
  }
  // 后端尚未提供短信验证码接口，先预留交互
  reserveFeature('手机验证码登录')
  clearErrors()
  if (codeCountdown.value > 0) {
    return
  }
  codeCountdown.value = 60
  window.clearInterval(codeTimer)
  codeTimer = window.setInterval(() => {
    codeCountdown.value -= 1
    if (codeCountdown.value <= 0) {
      window.clearInterval(codeTimer)
      codeCountdown.value = 0
    }
  }, 1000)
}

async function handleLogin(event: Event) {
  event.preventDefault()
  if (submitting.value || authStore.loading) {
    return
  }
  clearErrors()

  if (loginMode.value === 'phone') {
    const phoneValue = phone.value.trim()
    const codeValue = code.value.trim()
    if (!/^1[3-9]\d{9}$/.test(phoneValue)) {
      setFormError('phoneField', '请输入正确的 11 位手机号码。')
      phoneInputRef.value?.focus()
      return
    }
    if (!/^\d{6}$/.test(codeValue)) {
      setFormError('codeField', '请输入 6 位数字短信验证码。')
      codeInputRef.value?.focus()
      return
    }
    reserveFeature('手机验证码登录')
    return
  }

  const accountValue = account.value.trim()
  const passwordValue = password.value
  if (!accountValue) {
    setFormError('accountField', '请输入员工账号，账号由门店管理员统一开通。')
    accountInputRef.value?.focus()
    return
  }
  if (!passwordValue) {
    setFormError('passwordField', '请输入登录密码。')
    passwordInputRef.value?.focus()
    return
  }
  if (passwordValue.length < 6) {
    setFormError('passwordField', '密码长度不足 6 位，请检查后重新输入。')
    passwordInputRef.value?.focus()
    return
  }

  if (rememberAccount.value) {
    try {
      window.localStorage.setItem(STORAGE_KEY, accountValue)
    } catch {
      /* ignore */
    }
  } else {
    try {
      window.localStorage.removeItem(STORAGE_KEY)
    } catch {
      /* ignore */
    }
  }

  submitting.value = true
  submitText.value = '正在验证身份…'
  try {
    await authStore.login({
      username: accountValue,
      password: passwordValue,
    })
    openSuccess('正在进入门店运营工作台，请稍候…')
  } catch (error) {
    submitting.value = false
    submitText.value = '登录工作台'
    if (error instanceof ApiBusinessError || error instanceof ApiHttpError) {
      setFormError('accountField', error.message || '账号或密码不正确，请检查后重试。')
    } else {
      setFormError('accountField', '登录失败，请稍后重试')
    }
  }
}

function submitForgot(event: Event) {
  event.preventDefault()
  forgotAccountError.value = false
  forgotPhoneError.value = false
  forgotError.value = ''

  const accountValue = forgotAccount.value.trim()
  const phoneValue = forgotPhone.value.trim()
  if (!accountValue) {
    forgotAccountError.value = true
    forgotError.value = '请输入需要找回密码的员工账号。'
    return
  }
  if (!/^1[3-9]\d{9}$/.test(phoneValue)) {
    forgotPhoneError.value = true
    forgotError.value = '请输入与该账号绑定的 11 位手机号码。'
    return
  }

  // 后端尚未提供找回密码接口，先预留表单与成功态
  forgotSubmitting.value = true
  const now = new Date()
  const stamp = `${now.getFullYear()}${String(now.getMonth() + 1).padStart(2, '0')}${String(now.getDate()).padStart(2, '0')}-${String(now.getHours()).padStart(2, '0')}${String(now.getMinutes()).padStart(2, '0')}`
  forgotTicket.value = `YD-${stamp}`
  window.setTimeout(() => {
    forgotSubmitting.value = false
    forgotSuccess.value = true
    showToast('找回密码接口即将接入，当前为预留流程')
  }, 600)
}

function onPhoneInput(event: Event) {
  const target = event.target as HTMLInputElement
  phone.value = target.value.replace(/\D/g, '').slice(0, 11)
  if (errorField.value === 'phoneField') {
    clearErrors()
  }
}

function onCodeInput(event: Event) {
  const target = event.target as HTMLInputElement
  code.value = target.value.replace(/\D/g, '').slice(0, 6)
  if (errorField.value === 'codeField') {
    clearErrors()
  }
}

function onForgotPhoneInput(event: Event) {
  const target = event.target as HTMLInputElement
  forgotPhone.value = target.value.replace(/\D/g, '').slice(0, 11)
  forgotPhoneError.value = false
}

function onKeydown(event: KeyboardEvent) {
  if (event.key === 'Escape') {
    closeForgot()
    closePolicy()
    if (successVisible.value) {
      closeSuccess()
    }
  }
}

function initParticles() {
  const field = particleField.value
  if (!field) {
    return
  }
  if (window.matchMedia('(prefers-reduced-motion: reduce)').matches) {
    return
  }
  const tints = [
    'rgba(255, 134, 70, 0.85)',
    'rgba(255, 168, 116, 0.75)',
    'rgba(200, 90, 31, 0.55)',
    'rgba(255, 200, 170, 0.80)',
  ]
  const total = window.innerWidth < 1280 ? 34 : 52
  const frag = document.createDocumentFragment()
  for (let i = 0; i < total; i++) {
    const dot = document.createElement('span')
    const size = 1.6 + Math.random() * (Math.random() > 0.82 ? 4 : 1.6)
    dot.className = 'particle'
    dot.style.left = `${(Math.random() * 100).toFixed(2)}%`
    dot.style.top = `${(12 + Math.random() * 80).toFixed(2)}%`
    dot.style.width = `${size.toFixed(1)}px`
    dot.style.height = `${size.toFixed(1)}px`
    dot.style.background = tints[i % tints.length]
    dot.style.boxShadow = `0 0 ${(size * 3).toFixed(0)}px rgba(255, 134, 70, 0.42)`
    dot.style.animationDuration = `${(9 + Math.random() * 12).toFixed(1)}s`
    dot.style.animationDelay = `${(-Math.random() * 18).toFixed(1)}s`
    frag.appendChild(dot)
  }
  field.appendChild(frag)
}

watch(account, () => {
  if (errorField.value === 'accountField') {
    clearErrors()
  }
})

watch(password, () => {
  if (errorField.value === 'passwordField') {
    clearErrors()
  }
})

onMounted(() => {
  document.body.classList.add('login-body-lock')
  document.title = '预道养发 · 门店运营管理系统 | 登录'

  let saved = ''
  try {
    saved = window.localStorage.getItem(STORAGE_KEY) || ''
  } catch {
    saved = ''
  }
  if (saved) {
    account.value = saved
    rememberAccount.value = true
    void nextTick(() => passwordInputRef.value?.focus())
  } else if (window.matchMedia('(min-width: 1280px)').matches) {
    void nextTick(() => accountInputRef.value?.focus())
  }

  initParticles()
  window.addEventListener('keydown', onKeydown)
})

onUnmounted(() => {
  document.body.classList.remove('login-body-lock')
  document.title = '预道养发 · 门店运营管理系统'
  window.removeEventListener('keydown', onKeydown)
  window.clearTimeout(toastTimer)
  window.clearTimeout(successRedirectTimer)
  window.clearInterval(codeTimer)
})
</script>

<template>
  <div class="login-page-root relative w-full h-full min-h-full overflow-hidden">
    <div class="bio-stage relative w-full h-full min-h-[680px] overflow-hidden flex flex-col">
      <!-- 氛围层 -->
      <div class="pointer-events-none absolute inset-0 micro-grid opacity-90"></div>
      <div class="pointer-events-none absolute inset-0 hair-lines opacity-80"></div>
      <div class="pointer-events-none absolute inset-0 dot-field opacity-70"></div>
      <!-- 悬浮暖光斑 -->
      <div
        class="particle-glow pointer-events-none absolute -left-[160px] top-[16%] w-[560px] h-[560px] rounded-full opacity-[0.55]"
        style="
          background: radial-gradient(
            circle at 40% 40%,
            rgba(255, 150, 92, 0.5),
            rgba(255, 214, 188, 0.2) 52%,
            transparent 70%
          );
          filter: blur(14px);
        "
      ></div>
      <div
        class="particle-glow pointer-events-none absolute left-[34%] bottom-[-220px] w-[620px] h-[620px] rounded-full opacity-50"
        style="
          background: radial-gradient(circle at 50% 50%, rgba(255, 168, 116, 0.4), transparent 66%);
          filter: blur(18px);
          animation-delay: -6s;
        "
      ></div>
      <!-- 动态粒子场 -->
      <div ref="particleField" class="pointer-events-none absolute inset-0 overflow-hidden"></div>
      <!-- 装饰轨道线 -->
      <div class="pointer-events-none absolute left-[16%] top-[12%] w-[560px] h-[560px] opacity-45">
        <svg aria-hidden="true" class="w-full h-full" fill="none" viewBox="0 0 560 560">
          <circle
            cx="280"
            cy="280"
            r="232"
            stroke="rgba(200,90,31,0.16)"
            stroke-dasharray="3 9"
            stroke-width="0.9"
          ></circle>
          <circle cx="280" cy="280" r="176" stroke="rgba(200,90,31,0.11)" stroke-width="0.9"></circle>
          <g class="ring-orbit">
            <circle cx="280" cy="48" fill="rgba(255,134,70,0.55)" r="4"></circle>
            <circle cx="512" cy="280" fill="rgba(200,90,31,0.30)" r="2.6"></circle>
          </g>
          <g class="ring-orbit-rev">
            <circle cx="280" cy="456" fill="rgba(255,166,112,0.55)" r="3.2"></circle>
          </g>
        </svg>
      </div>

      <!-- 顶部信息条 -->
      <header class="relative z-20 shrink-0 px-8 xl:px-14 2xl:px-20 pt-7 xl:pt-9">
        <div class="flex items-center justify-between gap-6">
          <a
            aria-label="预道养发 · 门店运营管理系统"
            class="flex items-center gap-4"
            href="#"
            @click.prevent
          >
            <img
              alt="YUDAO 预道养发"
              class="brand-logo"
              src="/vendor/yudao-logo.png"
            />
            <span class="hidden sm:block w-px h-7 bg-[rgba(43,33,28,0.14)]"></span>
            <span class="hidden sm:block text-[11.5px] tracking-[0.14em] text-[#7a6658]"
              >门店运营管理系统</span
            >
          </a>
          <div class="hidden lg:flex items-center gap-7">
            <div class="flex items-center gap-2 text-[12px] text-[#5c4f47]">
              <span class="relative flex w-1.5 h-1.5">
                <span class="absolute inset-0 rounded-full bg-[#ff8646] pulse-dot"></span>
                <span class="relative w-1.5 h-1.5 rounded-full bg-[#f2752f]"></span>
              </span>
              <span class="tracking-[0.04em]">系统运行正常</span>
            </div>
            <div class="w-px h-3.5 bg-[rgba(43,33,28,0.14)]"></div>
            <div class="text-[12px] tracking-[0.06em] text-[#5c4f47]">服务热线 400-826-1088</div>
            <div class="w-px h-3.5 bg-[rgba(43,33,28,0.14)]"></div>
            <a
              class="text-[12px] tracking-[0.06em] text-[#c85a1f] hover:text-[#ff8646] transition-colors inline-flex items-center gap-1"
              href="#"
              @click="openBrandStory"
            >
              品牌故事
              <iconify-icon class="text-[13px]" icon="solar:arrow-right-up-linear"></iconify-icon>
            </a>
          </div>
        </div>
      </header>

      <!-- 主舞台 -->
      <main class="relative z-10 flex-1 min-h-0 flex">
        <section
          id="story"
          class="brand-stage flex-1 min-w-0 overflow-y-auto story-scroll px-8 xl:px-14 2xl:px-20 py-10 xl:py-14 flex flex-col justify-center"
        >
          <div class="w-full max-w-[600px]">
            <div class="rise inline-flex items-center gap-2.5 rounded-full px-3.5 py-1.5 soft-card">
              <span class="w-1.5 h-1.5 rounded-full bg-[#ff8646]"></span>
              <span class="text-[11.5px] tracking-[0.18em] text-[#7a6658]"
                >STAFF PORTAL · 门店员工入口</span
              >
            </div>
            <h1
              class="rise rise-2 mt-8 text-[38px] xl:text-[44px] 2xl:text-[48px] leading-[1.22] font-semibold tracking-[0.01em] text-[#2b211c]"
            >
              门店的每一天<br />
              <span class="text-[#c85a1f]">都在这里开始</span>
            </h1>
            <p class="rise rise-2 mt-5 max-w-[460px] text-[14px] leading-[1.9] text-[#5c4f47]">
              预约、检测、预养方案与经营数据，一套系统完成门店日常。
            </p>
            <span class="rise rise-2 mt-8 block h-px w-[120px] brand-rule"></span>
            <p
              class="rise rise-3 mt-6 inline-flex items-center gap-2 text-[12.5px] tracking-[0.1em] text-[#8a7566]"
            >
              <iconify-icon class="text-[15px] text-[#ff8646]" icon="solar:leaf-linear"></iconify-icon>
              预先 · 预判 · 预防，一以贯之的预养服务体系
            </p>
            <div
              class="rise rise-3 mt-5 flex flex-wrap items-center gap-x-3 gap-y-1.5 text-[12.5px] text-[#7a6658]"
            >
              <span
                >全直营门店 <span class="font-semibold text-[#2b211c]">20+</span> 家</span
              >
              <span class="w-px h-3 bg-[rgba(43,33,28,0.16)]"></span>
              <span>覆盖 <span class="font-semibold text-[#2b211c]">5</span> 座城市</span>
              <span class="w-px h-3 bg-[rgba(43,33,28,0.16)]"></span>
              <span>在职员工 <span class="font-semibold text-[#2b211c]">300+</span> 人</span>
            </div>
            <a
              class="rise rise-3 group mt-10 inline-flex w-fit items-center gap-1.5 text-[12px] text-[#a85a2a] hover:text-[#ff8646] transition-colors"
              href="#"
              @click="openBrandStory"
            >
              了解预养之道
              <iconify-icon
                class="text-[14px] transition-transform group-hover:translate-x-0.5"
                icon="solar:arrow-right-up-linear"
              ></iconify-icon>
            </a>
          </div>
        </section>

        <!-- 右侧登录浮层 -->
        <section
          class="login-rail shrink-0 w-[492px] xl:w-[524px] 2xl:w-[548px] flex items-center justify-center px-6 xl:px-8 py-8"
        >
          <div class="glass-panel w-full rounded-[26px] px-7 xl:px-9 pt-8 pb-7">
            <div class="flex items-start justify-between gap-3">
              <div>
                <p class="text-[10.5px] tracking-[0.26em] text-[#a08b7b]">YUDAO ERP · STORE OPERATIONS</p>
                <h2 class="mt-2 text-[22px] xl:text-[23px] font-semibold tracking-[0.02em] text-[#2b211c]">
                  门店员工登录
                </h2>
                <p class="mt-1.5 text-[12.5px] text-[#7a6658]">使用门店发放的员工账号进入运营工作台</p>
              </div>
              <div
                class="shrink-0 mt-1 rounded-lg bg-[#fff1e8] px-2 py-1 text-[10px] font-medium tracking-[0.08em] text-[#c85a1f] border border-[#ffdcc7]"
              >
                v3.8.2
              </div>
            </div>

            <!-- 登录方式切换 -->
            <div class="mt-7 relative tabs-rail rounded-xl p-1 flex">
              <div
                class="tab-indicator absolute top-1 bottom-1 left-1 w-[calc(50%-4px)] rounded-[10px]"
                :style="{
                  transform:
                    loginMode === 'account' ? 'translateX(0)' : 'translateX(calc(100% + 4px))',
                }"
              ></div>
              <button
                class="tab-btn relative z-10 flex-1 rounded-[10px] py-2.5 text-[13px] font-medium inline-flex items-center justify-center gap-1.5"
                :style="{ color: loginMode === 'account' ? '#c85a1f' : '#7a6658' }"
                type="button"
                @click="switchLoginMode('account')"
              >
                <iconify-icon class="text-[15px]" icon="solar:user-circle-linear"></iconify-icon>
                账号密码登录
              </button>
              <button
                class="tab-btn relative z-10 flex-1 rounded-[10px] py-2.5 text-[13px] font-medium inline-flex items-center justify-center gap-1.5"
                :style="{ color: loginMode === 'phone' ? '#c85a1f' : '#7a6658' }"
                type="button"
                @click="switchLoginMode('phone')"
              >
                <iconify-icon class="text-[15px]" icon="solar:smartphone-linear"></iconify-icon>
                手机验证码登录
              </button>
            </div>

            <form class="mt-6" novalidate @submit="handleLogin">
              <!-- 账号密码 -->
              <div v-show="loginMode === 'account'">
                <label class="block text-[12px] font-medium tracking-[0.04em] text-[#6b5a4d]"
                  >员工账号</label
                >
                <div
                  class="field-wrap mt-2 flex items-center gap-2.5 rounded-xl border border-[rgba(43,33,28,0.13)] bg-white/78 px-3.5 h-[50px]"
                  :class="{ 'is-error': errorField === 'accountField' }"
                >
                  <iconify-icon class="text-[17px] text-[#bda998]" icon="solar:user-linear"></iconify-icon>
                  <input
                    ref="accountInputRef"
                    v-model="account"
                    autocomplete="username"
                    class="flex-1 min-w-0 bg-transparent text-[13.5px] text-[#2b211c] placeholder:text-[#bfae9f] outline-none"
                    name="account"
                    placeholder="请输入员工账号 / 手机号"
                    type="text"
                    :disabled="submitting"
                  />
                  <button
                    v-show="account.length > 0"
                    aria-label="清空账号"
                    class="text-[#bfae9f] hover:text-[#7a6658] transition-colors"
                    type="button"
                    @click="clearAccount"
                  >
                    <iconify-icon class="text-[16px]" icon="solar:close-circle-linear"></iconify-icon>
                  </button>
                </div>
                <div class="mt-4 flex items-center justify-between">
                  <label class="block text-[12px] font-medium tracking-[0.04em] text-[#6b5a4d]"
                    >登录密码</label
                  >
                  <button
                    class="text-[12px] text-[#c85a1f] hover:text-[#ff8646] hover:underline underline-offset-4 transition-colors"
                    type="button"
                    @click="openForgot"
                  >
                    忘记密码？
                  </button>
                </div>
                <div
                  class="field-wrap mt-2 flex items-center gap-2.5 rounded-xl border border-[rgba(43,33,28,0.13)] bg-white/78 px-3.5 h-[50px]"
                  :class="{ 'is-error': errorField === 'passwordField' }"
                >
                  <iconify-icon
                    class="text-[17px] text-[#bda998]"
                    icon="solar:lock-password-linear"
                  ></iconify-icon>
                  <input
                    ref="passwordInputRef"
                    v-model="password"
                    autocomplete="current-password"
                    class="flex-1 min-w-0 bg-transparent text-[13.5px] text-[#2b211c] placeholder:text-[#bfae9f] outline-none"
                    name="password"
                    placeholder="请输入登录密码"
                    :type="showPassword ? 'text' : 'password'"
                    :disabled="submitting"
                  />
                  <button
                    aria-label="显示或隐藏密码"
                    class="text-[#bda998] hover:text-[#6b5a4d] transition-colors"
                    type="button"
                    @click="togglePassword"
                  >
                    <iconify-icon
                      class="text-[17px]"
                      :icon="showPassword ? 'solar:eye-closed-linear' : 'solar:eye-linear'"
                    ></iconify-icon>
                  </button>
                </div>
                <label class="mt-4 flex items-center gap-2.5 cursor-pointer select-none w-fit group">
                  <input v-model="rememberAccount" class="sr-only" type="checkbox" />
                  <span
                    class="checkbox-mark w-[16px] h-[16px] rounded-[5px] border border-[rgba(43,33,28,0.22)] bg-white/80 flex items-center justify-center"
                    :style="rememberBoxStyle"
                  >
                    <iconify-icon
                      class="text-[11px] text-white"
                      :style="{ opacity: rememberAccount ? '1' : '0' }"
                      icon="solar:check-bold"
                    ></iconify-icon>
                  </span>
                  <span class="text-[12.5px] text-[#5c4f47] group-hover:text-[#c85a1f] transition-colors"
                    >记住账号，下次自动填充</span
                  >
                </label>
              </div>

              <!-- 手机验证码（接口预留） -->
              <div v-show="loginMode === 'phone'">
                <label class="block text-[12px] font-medium tracking-[0.04em] text-[#6b5a4d]"
                  >手机号码</label
                >
                <div
                  class="field-wrap mt-2 flex items-center gap-2.5 rounded-xl border border-[rgba(43,33,28,0.13)] bg-white/78 px-3.5 h-[50px]"
                  :class="{ 'is-error': errorField === 'phoneField' }"
                >
                  <iconify-icon
                    class="text-[17px] text-[#bda998]"
                    icon="solar:smartphone-linear"
                  ></iconify-icon>
                  <span class="text-[13px] text-[#5c4f47] pr-2 border-r border-[rgba(43,33,28,0.10)]"
                    >+86</span
                  >
                  <input
                    ref="phoneInputRef"
                    :value="phone"
                    class="flex-1 min-w-0 bg-transparent text-[13.5px] text-[#2b211c] placeholder:text-[#bfae9f] outline-none"
                    inputmode="numeric"
                    maxlength="11"
                    placeholder="请输入绑定的手机号"
                    type="tel"
                    @input="onPhoneInput"
                  />
                </div>
                <label class="block mt-4 text-[12px] font-medium tracking-[0.04em] text-[#6b5a4d]"
                  >短信验证码</label
                >
                <div class="mt-2 flex items-center gap-2.5">
                  <div
                    class="field-wrap flex-1 flex items-center gap-2.5 rounded-xl border border-[rgba(43,33,28,0.13)] bg-white/78 px-3.5 h-[50px]"
                    :class="{ 'is-error': errorField === 'codeField' }"
                  >
                    <iconify-icon
                      class="text-[17px] text-[#bda998]"
                      icon="solar:letter-unread-linear"
                    ></iconify-icon>
                    <input
                      ref="codeInputRef"
                      :value="code"
                      class="flex-1 min-w-0 bg-transparent text-[13.5px] tracking-[0.12em] text-[#2b211c] placeholder:tracking-normal placeholder:text-[#bfae9f] outline-none"
                      inputmode="numeric"
                      maxlength="6"
                      placeholder="6 位数字验证码"
                      type="text"
                      @input="onCodeInput"
                    />
                  </div>
                  <button
                    class="shrink-0 h-[50px] px-3.5 rounded-xl border border-[rgba(255,134,70,0.28)] bg-[#fff1e8] text-[12px] font-medium text-[#c85a1f] hover:bg-[#ffe6d8] transition-colors disabled:opacity-60 disabled:cursor-not-allowed"
                    type="button"
                    :disabled="codeCountdown > 0"
                    @click="sendCode"
                  >
                    {{ sendCodeLabel }}
                  </button>
                </div>
                <p class="mt-3 text-[11.5px] leading-relaxed text-[#98857a]">
                  验证码将发送至门店系统登记的在职手机号，如已变更请联系店长或区域管理员。
                </p>
              </div>

              <!-- 错误提示 -->
              <div
                v-if="formError"
                class="mt-4 flex items-start gap-2 rounded-lg bg-[#fdf1ee] border border-[#f4d5cb] px-3 py-2.5"
              >
                <iconify-icon
                  class="text-[15px] text-[#c9543f] mt-px shrink-0"
                  icon="solar:danger-circle-linear"
                ></iconify-icon>
                <p class="text-[12px] leading-relaxed text-[#a8432f]">{{ formError }}</p>
              </div>

              <button
                class="btn-primary mt-6 w-full h-[52px] rounded-xl text-[14px] font-semibold tracking-[0.1em] text-white inline-flex items-center justify-center gap-2"
                type="submit"
                :disabled="submitting || authStore.loading"
              >
                <span>{{ submitText }}</span>
                <iconify-icon class="text-[17px]" icon="solar:arrow-right-linear"></iconify-icon>
              </button>
            </form>

            <div
              class="mt-5 flex items-center gap-2 rounded-xl bg-[#fdf6f2]/90 border border-[#f6e2d5] px-3 py-2.5"
            >
              <iconify-icon
                class="text-[14px] text-[#ff8646] shrink-0"
                icon="solar:info-circle-linear"
              ></iconify-icon>
              <p class="text-[11.5px] leading-relaxed text-[#7a6658]">
                演示账号 <span class="font-medium text-[#c85a1f]">13812345678</span> ／ 密码
                <span class="font-medium text-[#c85a1f]">123456</span>
              </p>
            </div>

            <div class="mt-6 pt-4 border-t border-[rgba(43,33,28,0.09)]">
              <div class="flex items-center justify-between gap-3">
                <p class="text-[11px] text-[#ad9c90]">© 2026 预道养发 · 保留所有权利</p>
                <div class="flex items-center gap-3 text-[11px] text-[#98857a]">
                  <a
                    class="hover:text-[#c85a1f] transition-colors"
                    href="#"
                    @click.prevent="openPolicy('privacy')"
                    >隐私政策</a
                  >
                  <span class="w-px h-2.5 bg-[rgba(43,33,28,0.16)]"></span>
                  <a
                    class="hover:text-[#c85a1f] transition-colors"
                    href="#"
                    @click.prevent="openPolicy('terms')"
                    >服务条款</a
                  >
                </div>
              </div>
              <p class="mt-2.5 text-[10.5px] leading-relaxed text-[#b5a498]">
                本系统仅限预道养发授权员工使用，所有操作留痕审计，请妥善保管账号凭据。
              </p>
            </div>
          </div>
        </section>
      </main>

      <footer class="relative z-20 shrink-0 px-8 xl:px-14 2xl:px-20 pb-6 xl:pb-7">
        <div
          class="flex flex-wrap items-center justify-between gap-2 text-[11px] tracking-[0.05em] text-[#98857a]"
        >
          <p>预养合一 · 四季焕发 — 门店运营 · 预约排班 · 检测方案 · 客户档案</p>
          <p class="hidden md:block">内部系统 · 仅限在职员工使用</p>
        </div>
      </footer>
    </div>

    <!-- 登录成功遮罩 -->
    <div
      v-if="successVisible"
      class="fixed inset-0 z-50 modal-shell flex items-center justify-center px-6"
    >
      <div
        class="modal-card w-full max-w-[420px] rounded-2xl bg-white px-8 py-9 text-center shadow-[0_40px_90px_-30px_rgba(160,78,32,0.42)]"
      >
        <div class="mx-auto w-14 h-14 rounded-2xl bg-[#fff1e8] flex items-center justify-center">
          <iconify-icon class="text-[30px] text-[#ff8646]" icon="solar:check-circle-bold"></iconify-icon>
        </div>
        <h3 class="mt-5 text-[19px] font-semibold text-[#2b211c]">身份验证通过</h3>
        <p class="mt-2 text-[13px] leading-relaxed text-[#7a6658]">{{ successDesc }}</p>
        <div class="mt-6 h-1 rounded-full bg-[#fdf0e8] overflow-hidden">
          <div
            class="h-full rounded-full bg-[linear-gradient(90deg,#ff8646,#ffb287)] transition-[width] duration-700 ease-out"
            :style="{ width: successBarWidth }"
          ></div>
        </div>
        <div class="mt-6 grid gap-2">
          <button
            class="h-11 rounded-xl btn-primary text-white text-[13px] font-medium inline-flex items-center justify-center gap-1.5"
            type="button"
            @click="goWorkbench"
          >
            进入工作台
            <iconify-icon class="text-[15px]" icon="solar:arrow-right-linear"></iconify-icon>
          </button>
          <button
            class="h-10 rounded-xl text-[12.5px] text-[#7a6658] hover:bg-[#fdf6f2] transition-colors"
            type="button"
            @click="closeSuccess"
          >
            返回登录
          </button>
        </div>
      </div>
    </div>

    <!-- 忘记密码（接口预留） -->
    <div
      v-if="forgotVisible"
      class="fixed inset-0 z-50 modal-shell flex items-center justify-center px-6"
      @click.self="closeForgot"
    >
      <div
        class="modal-card w-full max-w-[440px] rounded-2xl bg-white px-8 py-8 shadow-[0_40px_90px_-30px_rgba(160,78,32,0.42)]"
      >
        <div class="flex items-start justify-between gap-4">
          <div>
            <p class="text-[10.5px] tracking-[0.24em] text-[#a08b7b]">ACCOUNT RECOVERY</p>
            <h3 class="mt-2 text-[19px] font-semibold text-[#2b211c]">找回登录密码</h3>
            <p class="mt-1.5 text-[12.5px] leading-relaxed text-[#7a6658]">
              输入你的员工账号与注册手机号，我们将向区域管理员发送重置申请。
            </p>
          </div>
          <button
            aria-label="关闭"
            class="shrink-0 w-8 h-8 rounded-lg text-[#ad9c90] hover:bg-[#fdf6f2] hover:text-[#6b5a4d] transition-colors flex items-center justify-center"
            type="button"
            @click="closeForgot"
          >
            <iconify-icon class="text-[18px]" icon="solar:close-square-linear"></iconify-icon>
          </button>
        </div>
        <form class="mt-6" novalidate @submit="submitForgot">
          <label class="block text-[12px] font-medium text-[#6b5a4d]">员工账号</label>
          <div
            class="field-wrap mt-2 flex items-center gap-2.5 rounded-xl border border-[rgba(43,33,28,0.13)] bg-white px-3.5 h-[48px]"
            :class="{ 'is-error': forgotAccountError }"
          >
            <iconify-icon class="text-[16px] text-[#bda998]" icon="solar:user-linear"></iconify-icon>
            <input
              v-model="forgotAccount"
              class="flex-1 min-w-0 bg-transparent text-[13px] outline-none placeholder:text-[#bfae9f]"
              placeholder="请输入员工账号"
              type="text"
              @input="forgotAccountError = false; forgotError = ''"
            />
          </div>
          <label class="block mt-4 text-[12px] font-medium text-[#6b5a4d]">绑定手机号</label>
          <div
            class="field-wrap mt-2 flex items-center gap-2.5 rounded-xl border border-[rgba(43,33,28,0.13)] bg-white px-3.5 h-[48px]"
            :class="{ 'is-error': forgotPhoneError }"
          >
            <iconify-icon class="text-[16px] text-[#bda998]" icon="solar:smartphone-linear"></iconify-icon>
            <input
              :value="forgotPhone"
              class="flex-1 min-w-0 bg-transparent text-[13px] outline-none placeholder:text-[#bfae9f]"
              inputmode="numeric"
              maxlength="11"
              placeholder="请输入 11 位手机号"
              type="tel"
              @input="onForgotPhoneInput"
            />
          </div>
          <div
            v-if="forgotError"
            class="mt-3.5 flex items-start gap-2 rounded-lg bg-[#fdf1ee] border border-[#f4d5cb] px-3 py-2.5"
          >
            <iconify-icon
              class="text-[15px] text-[#c9543f] mt-px shrink-0"
              icon="solar:danger-circle-linear"
            ></iconify-icon>
            <p class="text-[12px] leading-relaxed text-[#a8432f]">{{ forgotError }}</p>
          </div>
          <div
            v-if="forgotSuccess"
            class="mt-4 rounded-xl bg-[#fdf6f2] border border-[#f6e2d5] px-4 py-4"
          >
            <div class="flex items-center gap-2">
              <iconify-icon class="text-[17px] text-[#ff8646]" icon="solar:check-circle-bold"></iconify-icon>
              <p class="text-[13px] font-medium text-[#c85a1f]">重置申请已提交</p>
            </div>
            <p class="mt-1.5 text-[12px] leading-relaxed text-[#7a6658]">
              工单号 <span class="font-medium text-[#c85a1f]">{{ forgotTicket }}</span
              >。区域管理员将在 2 小时内完成身份核验，并通过预留手机号告知临时密码。
            </p>
          </div>
          <button
            v-if="!forgotSuccess"
            class="btn-primary mt-6 w-full h-[48px] rounded-xl text-[13.5px] font-semibold tracking-[0.08em] text-white"
            type="submit"
            :disabled="forgotSubmitting"
          >
            {{ forgotSubmitting ? '正在提交…' : '提交重置申请' }}
          </button>
          <p class="mt-3 text-center text-[11.5px] text-[#ad9c90]">
            如需加急处理，请联系区域运营支持 400-826-1088
          </p>
        </form>
      </div>
    </div>

    <!-- 政策说明 -->
    <div
      v-if="policyVisible"
      class="fixed inset-0 z-50 modal-shell flex items-center justify-center px-6"
      @click.self="closePolicy"
    >
      <div
        class="modal-card w-full max-w-[520px] rounded-2xl bg-white px-8 py-8 shadow-[0_40px_90px_-30px_rgba(160,78,32,0.42)]"
      >
        <div class="flex items-start justify-between gap-4">
          <h3 class="text-[18px] font-semibold text-[#2b211c]">{{ policyTitle }}</h3>
          <button
            aria-label="关闭"
            class="shrink-0 w-8 h-8 rounded-lg text-[#ad9c90] hover:bg-[#fdf6f2] transition-colors flex items-center justify-center"
            type="button"
            @click="closePolicy"
          >
            <iconify-icon class="text-[18px]" icon="solar:close-square-linear"></iconify-icon>
          </button>
        </div>
        <div
          class="mt-5 max-h-[52vh] overflow-y-auto pr-1 text-[12.5px] leading-[1.95] text-[#5c4f47] story-scroll"
        >
          <p
            v-for="(line, index) in policyParagraphs"
            :key="index"
            :class="
              line.includes('、')
                ? 'mt-4 first:mt-0 font-medium text-[#2b211c]'
                : 'mt-1.5'
            "
          >
            {{ line }}
          </p>
        </div>
        <p class="mt-5 text-[11px] text-[#ad9c90]">预道养发 · 门店运营管理系统 · 更新于 2026 年 10 月</p>
      </div>
    </div>

    <!-- Toast -->
    <div
      v-if="toastVisible"
      class="toast fixed top-6 left-1/2 -translate-x-1/2 z-[60] px-4 py-2.5 rounded-xl bg-[#3a2a20] text-white text-[12.5px] tracking-[0.02em] shadow-[0_18px_40px_-18px_rgba(58,42,32,.7)] inline-flex items-center gap-2"
    >
      <iconify-icon class="text-[15px] text-[#ffb287]" icon="solar:bell-bing-linear"></iconify-icon>
      <span>{{ toastText }}</span>
    </div>
  </div>
</template>

<style>
body.login-body-lock {
  overflow: hidden;
  background: #fbf3ee;
}
</style>
