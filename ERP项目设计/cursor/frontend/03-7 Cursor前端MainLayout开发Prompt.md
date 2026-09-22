# 03-7 Cursor 前端 MainLayout 开发 Prompt

## 一、你的角色

你现在是本 ERP 项目的前端核心开发工程师。

当前项目是一个已经存在的 Vue 3 + TypeScript ERP 前端项目。

本阶段不是开发业务模块，而是继续完成：

> **03-7 MainLayout 主框架容器**

你必须严格遵守“一个阶段只解决一个问题”的原则。

---

# 二、当前项目技术栈

请以当前项目实际代码为准，不要假设。

已知技术栈：

- Vue 3.5.43
- TypeScript 6.0.3
- Vite 8.3.0
- Element Plus 2.14.6
- Pinia 4.0.3
- Vue Router 5.3.1
- Axios 1.20.0

当前 API 代理：

```text
/api -> http://127.0.0.1:12002
```

当前后端：

```text
Spring Boot
port: 12002
```

---

# 三、当前已经完成的阶段

以下阶段已经 PASS。

不要重复实现，不要重构，不要破坏已有逻辑。

```text
03-1 Request / Token
03-2 Login
03-3 Auth Store
03-4 Permission Store
03-5 Store Context
03-6 Router Guard
```

当前基础链路：

```text
Login
  ↓
Token
  ↓
Auth Store
  ↓
/me
  ↓
Permission Store
  ↓
Store Context
  ↓
Router Guard
  ↓
进入受保护页面
```

---



# 四、当前已经存在的重要基础能力



## 4.1 Auth Store

当前已有：

```text
src/stores/auth.ts
```

包含：

```text
token
currentUser
initialized
loading
isAuthenticated
employee
login()
fetchCurrentUser()
initialize()
clearAuth()
logout()
```

不要重新设计 Auth Store。

---



# 五、Permission Store

当前已有：

```text
src/stores/permission.ts
```

包含：

```text
permissionCodes
roles
dataScope
initialized

initialize()
clear()
hasPermission()
hasAnyPermission()
hasAllPermissions()
```

不要在 MainLayout 中实现权限逻辑。

---



# 六、Store Store

当前已有：

```text
src/stores/store.ts
```

负责：

```text
currentStoreId
currentStoreName
availableStoreIds
initialized
switching

initialize()
switchStore()
```

本阶段不要实现门店切换 UI。

---



# 七、Router Guard

当前已经完成：

```text
03-6 Router Guard
```

当前已经支持：

```text
/login
/
受保护路由
Auth 初始化
Permission 初始化
Store 初始化
Auth 初始化失败页
```

不要修改 Router Guard 的核心逻辑。

---



# 八、本阶段目标

本阶段只实现：

> **MainLayout 主框架容器**

MainLayout 是未来所有 ERP 业务页面的外壳。

最终结构概念：

```text
App
│
├── Login
│
└── MainLayout
      │
      ├── Sidebar       ← 03-8
      │
      ├── Header        ← 03-9
      │
      └── Main Content
             │
             └── RouterView
```

但本阶段：

> Sidebar / Header 暂时不正式实现。

---



# 九、MainLayout 本阶段职责

MainLayout 当前只负责：

1. 提供后台管理系统整体页面容器
2. 提供左侧区域占位
3. 提供顶部区域占位
4. 提供主内容区域
5. 正确渲染 RouterView
6. 保证页面高度撑满浏览器
7. 保证主内容区域可以正常滚动
8. 不影响现有登录、权限、门店、Router Guard

---



# 十、不要实现的内容

以下全部禁止在本阶段实现。

## 10.1 禁止实现 Sidebar 正式菜单

不要实现：

```text
首页
店务管理
客户管理
人事绩效
供应链
营销中心
报表中心
系统管理
```

也不要：

```text
动态菜单
权限菜单
菜单折叠
菜单图标
菜单高亮
菜单树
```

这些属于：

> 03-8 Sidebar/Menu

---



# 十一、禁止实现 Header

不要实现：

```text
用户信息
当前员工
当前门店
门店切换
退出登录
消息
面包屑
系统标题
```

这些属于：

> 03-9 Header / StoreSelector / Breadcrumb

---



# 十二、禁止实现业务功能

不要实现：

```text
客户
预约
收银
开单
耗卡
项目
卡项
员工
绩效
供应链
营销
报表
```

---



# 十三、建议文件结构

先扫描项目实际结构。

如果项目当前没有：

```text
src/layouts/
```

则创建：

```text
src/layouts/
```

建议：

```text
src/
├── layouts/
│   └── MainLayout.vue
```

如果当前项目已经存在布局目录，则遵循现有项目结构，不要重复创建。

---



# 十四、MainLayout 基础结构

建议逻辑结构：

```text
MainLayout
│
├── Layout Root
│
├── Sidebar Placeholder
│
├── Main Area
│    │
│    ├── Header Placeholder
│    │
│    └── Content
│         │
│         └── RouterView
│
└── End
```

注意：

这里的 Sidebar / Header 只是：

> **结构占位**

不是正式组件。

---



# 十五、布局要求



## 15.1 页面高度

MainLayout 必须至少：

```css
height: 100vh;
```

或者使用等效方案。

要求：

> 页面不能因为浏览器窗口高度变化导致布局塌陷。

---



# 十六、禁止整个页面出现双滚动条

整体布局应尽量：

```text
浏览器窗口
└── MainLayout
     ├── Sidebar
     └── MainArea
          ├── Header
          └── Content
```

Content 才是主要滚动区域。

不要出现：

```text
浏览器滚动条
+
MainLayout 滚动条
+
Content 滚动条
```

这种多重滚动。

---



# 十七、RouterView

MainLayout 必须正确渲染：

```vue
<RouterView />
```

或者项目当前 Vue Router 推荐的等效写法。

所有业务页面未来都必须通过这里显示。

例如：

```text
/
  ↓
MainLayout
  ↓
RouterView
  ↓
HomeView
```

---



# 十八、当前 Home 页面兼容

当前项目已经存在 Home 页面。

请先扫描当前 Router。

如果当前结构类似：

```text
{
  path: '/',
  component: HomeView
}
```

请根据实际代码，将其调整为：

```text
/
  ↓
MainLayout
  ↓
HomeView
```

但必须保持：

```text
/ 
```

原有访问逻辑不变。

---



# 十九、推荐 Router 结构

如果当前 Router 结构允许，建议：

```text
/login
```

独立。

后台：

```text
/
  component: MainLayout
  children:
    /        -> HomeView
```

即：

```text
routes
│
├── /login
│
└── /
     └── MainLayout
          └── HomeView
```

但是：

> 必须优先尊重当前项目 Router 结构。

如果为了实现 MainLayout 需要大规模重构 Router，禁止这么做。

---



# 二十、不要修改路由权限模型

不要重新设计：

```text
requiresAuth
permission
roles
dataScope
```

Router Guard 已经完成。

MainLayout 只负责：

> UI Layout

---



# 二十一、暂时占位区域

为了验证布局结构，可以使用非常简单的占位：

```text
Sidebar
```

以及：

```text
Header
```

例如：

```text
Sidebar Placeholder
Header Placeholder
```

但要求：

- 不做真实菜单
- 不做真实 Header
- 不接 API
- 不调用 Store
- 不处理权限

这些只是为了方便验证布局结构。

---



# 二十二、样式要求

当前阶段不追求最终视觉设计。

只需要做到：

```text
结构正确
尺寸合理
布局稳定
高度正确
滚动正确
RouterView 正常
```

不要花大量时间做：

```text
渐变
复杂动画
高级阴影
复杂主题
复杂颜色系统
```

---



# 二十三、Element Plus 使用原则

当前项目已经安装：

```text
Element Plus
```

本阶段没有必要为了布局强行使用大量 Element Plus Layout 组件。

优先：

```text
CSS Flex
CSS Grid
普通 div
```

保持结构简单。

---



# 二十四、禁止引入新的 UI 框架

禁止新增：

```text
Ant Design
Naive UI
Vuetify
Tailwind
Bootstrap
其他 UI Framework
```

除非项目已经存在并正在使用。

本阶段不要引入任何新依赖。

---



# 二十五、App.vue 检查

请扫描：

```text
src/App.vue
```

确认 App 当前只是负责：

```text
RouterView
```

或者合理的应用级容器。

如果当前 App.vue 没有问题：

> 不要为了 MainLayout 重构 App.vue。

---



# 二十六、CSS 全局样式检查

扫描：

```text
src/assets/
src/style.css
src/main.ts
```

确认是否存在：

```text
body margin
html height
body height
#app height
```

如果缺少导致 MainLayout 无法撑满页面，可以进行最小修改。

推荐保证：

```css
html,
body,
#app {
  height: 100%;
  margin: 0;
}
```

但：

> 只做必要修改。

不要顺手重写整个主题系统。

---



# 二十七、组件职责

本阶段：

```text
MainLayout.vue
```

职责只有：

```text
页面整体布局
RouterView 容器
```

不要把以下代码放进去：

```text
权限判断
API 请求
用户信息
门店信息
菜单权限
业务数据
```

---



# 二十八、不要提前设计未来接口

不要创建：

```text
getMenus()
getCurrentStore()
getUserInfo()
getNotifications()
```

MainLayout 当前不需要 API。

---



# 二十九、不要提前创建 Store

本阶段禁止新增：

```text
layoutStore
menuStore
headerStore
sidebarStore
```

未来如果确有必要，再单独设计。

---



# 三十、开发前必须先扫描

执行前必须先扫描：

```text
src/main.ts
src/App.vue
src/router/
src/views/
src/layouts/
src/stores/
src/types/
src/utils/
```

重点确认：

1. 当前 Router 实际结构
2. Home 路由
3. Login 路由
4. Router Guard
5. App.vue
6. 当前全局 CSS
7. 是否已有 Layout
8. 是否已有页面容器

---



# 三十一、开发原则

严格遵守：

> 最小改动原则

只修改实现 03-7 所必须的文件。

优先：

```text
新增 MainLayout
+
最小 Router 修改
+
必要 CSS 修改
```

不要：

```text
重构 Auth
重构 Permission
重构 Store
重构 Request
重构 Login
重构 Router Guard
```

---



# 三十二、错误处理

如果扫描发现：

```text
当前 Router 结构和预期不一致
```

不要直接大改。

先基于当前代码实现最小方案。

如果确实无法安全实现：

> 停止修改，并明确告诉我冲突点。

不要自行扩大范围。

---



# 三十三、开发完成后必须验证

必须执行：

```bash
npm run type-check
```

如果项目实际脚本名称不同：

> 使用 package.json 中实际存在的 TypeScript 检查命令。

然后执行：

```bash
npm run build
```

如果存在 lint：

```bash
npm run lint
```

---



# 三十四、运行时验证

如果当前前后端可以正常启动，请验证：

## Case 1

打开：

```text
/login
```

登录页面正常。

---



## Case 2

登录成功。

应该进入：

```text
/
```

并显示：

```text
MainLayout
```

内部：

```text
Sidebar Placeholder
Header Placeholder
HomeView
```

---



## Case 3

刷新浏览器。

要求：

```text
不应该因为 MainLayout 导致重新登录
```

Auth Store / Router Guard 原有逻辑必须继续正常。

---



## Case 4

直接访问：

```text
/
```

无 Token：

```text
→ /login
```

---



## Case 5

有 Token：

```text
→ MainLayout
→ HomeView
```

---



## Case 6

浏览器高度变化。

要求：

```text
MainLayout 不塌陷
```

---



## Case 7

Home 内容较长时：

要求：

```text
Content 区域正常滚动
```

不要出现整个浏览器页面无限撑高。

---



# 三十五、必须验证已有基础能力没有被破坏

至少确认：

```text
登录
刷新恢复
退出登录
Router Guard
Auth 初始化
Permission 初始化
Store 初始化
```

没有被 MainLayout 修改破坏。

特别注意：

> 03-6 的 AuthInitErrorView 必须继续正常工作。

不要为了嵌套 MainLayout，把 AuthInitErrorView 错误地放进 MainLayout。

Auth 初始化错误页仍然属于：

```text
非 MainLayout 页面
```

---



# 三十六、最终目录期望

完成后大致应该是：

```text
src/
├── api/
├── assets/
├── components/
├── layouts/
│   └── MainLayout.vue
├── router/
├── stores/
│   ├── auth.ts
│   ├── permission.ts
│   └── store.ts
├── types/
├── utils/
├── views/
│   ├── LoginView.vue
│   ├── HomeView.vue
│   └── AuthInitErrorView.vue
├── App.vue
└── main.ts
```

如果实际项目结构不同：

> 以实际项目为准。

---



# 三十七、严禁顺手完成 03-8 / 03-9 / 03-10

这是本次任务最重要的边界。

不要因为 MainLayout 已经建立，就顺便实现：

```text
Sidebar
菜单
菜单权限
Header
用户菜单
门店切换
Breadcrumb
全局按钮权限
全局交互
```

这些全部留到后续阶段。

---



# 三十八、最终输出格式

开发完成后，不要只告诉我：

```text
完成了
```

必须给出完整开发报告。

报告格式：

## 1. 扫描结果

列出：

```text
Router 当前结构
App.vue 当前结构
现有 Layout 情况
CSS 情况
```

---



## 2. 修改文件

列出：

```text
新增：
xxx

修改：
xxx
xxx
```

---



## 3. MainLayout 结构

明确说明：

```text
MainLayout
├── Sidebar Placeholder
├── Main Area
│   ├── Header Placeholder
│   └── RouterView
```

---



## 4. Router 修改

说明是否修改。

如果修改：

```text
修改前
修改后
```

---



## 5. CSS 修改

说明是否修改。

---



## 6. 验证结果

至少：

```text
Type Check: PASS/FAIL
Build: PASS/FAIL
Lint: PASS/FAIL/未配置
```

---



## 7. Runtime 验证

如果能够运行：

```text
登录：PASS/FAIL
刷新：PASS/FAIL
MainLayout：PASS/FAIL
Home：PASS/FAIL
无 Token：PASS/FAIL
AuthInitError：PASS/FAIL
滚动：PASS/FAIL
```

---



## 8. 变更边界确认

必须明确回答：

```text
是否修改 Auth Store：否
是否修改 Permission Store：否
是否修改 Store Context：否
是否修改 Request：否
是否修改 Login：否
是否修改 Router Guard 核心逻辑：否
是否实现 Sidebar：否
是否实现 Header：否
是否实现 StoreSelector：否
是否实现 Breadcrumb：否
是否实现业务模块：否
```

如果其中任何一项是“是”，必须解释原因。

---



# 三十九、完成标准

只有满足以下全部条件，才能报告：

> **03-7 PASS**

条件：

```text
[ ] MainLayout 已建立
[ ] RouterView 正常工作
[ ] Home 可以通过 MainLayout 显示
[ ] Login 不受影响
[ ] Router Guard 不受影响
[ ] Auth Store 不受影响
[ ] Permission Store 不受影响
[ ] Store Context 不受影响
[ ] 页面高度正常
[ ] Content 滚动正常
[ ] Type Check PASS
[ ] Build PASS
[ ] Runtime 基础验证 PASS
[ ] 没有提前实现 03-8
[ ] 没有提前实现 03-9
[ ] 没有提前实现 03-10
[ ] 没有开发业务模块
```

全部满足后：

> **03-7 MainLayout 正式 PASS**

然后停止。

不要继续执行 03-8。
不要继续执行 03-9。
不要继续执行 03-10。

等待下一条指令。