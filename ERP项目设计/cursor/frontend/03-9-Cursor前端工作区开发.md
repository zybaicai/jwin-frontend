# 03-9 Cursor 前端工作区开发 Prompt

## 一、你的角色

你现在是本 ERP 项目的前端核心开发工程师。

当前项目已经完成前端基础框架：

```text
03-1 Request / Token                 PASS
03-2 Login                           PASS
03-3 Auth Store                      PASS
03-4 Permission Store                PASS
03-5 Store Context / Store Switch   PASS
03-6 Router Guard                    PASS
03-7 MainLayout                      PASS
03-8 Sidebar + Header                PASS
```

现在进入：

> **03-9 ERP 工作区增强阶段**

本阶段要正式建立成熟 SaaS ERP 常见的：

```text
品牌 Logo
+
Header
+
员工菜单
+
门店切换
+
Breadcrumb
+
Page Tabs
+
Tab Store
+
KeepAlive
+
路由与 Tab 联动
```

这不是业务模块开发。

本阶段的目标是：

> 建立以后所有 ERP 业务页面都可以直接运行在上面的统一工作区 Shell。

---

# 二、当前技术栈

必须以实际项目代码为准。

已知：

```text
Vue 3.5.43
TypeScript 6.0.3
Vite 8.3.0
Element Plus 2.14.6
Pinia 4.0.3
Vue Router 5.3.1
Axios 1.20.0
```

后端：

```text
Spring Boot
127.0.0.1:12002
```

前端代理：

```text
/api -> http://127.0.0.1:12002
```

---

# 三、当前项目已经 PASS 的能力

## 3.1 Auth Store

当前：

```text
src/stores/auth.ts
```

已有：

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

其中：

```text
employee
```

可以用于 Header 显示员工信息。

当前真实用户示例：

```text
员工：
测试员工

岗位：
店长
```

不要重新设计 Auth Store。

---

# 四、Permission Store

当前：

```text
src/stores/permission.ts
```

已有：

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

本阶段：

> 不重新设计权限系统。

Page Tabs 本阶段也不要做复杂权限菜单。

---

# 五、Store Context

当前：

```text
src/stores/store.ts
```

这是本阶段非常重要的已有能力。

已有：

```text
currentStoreId
currentStoreName
availableStoreIds
initialized
switching

initialize()
switchStore()
```

已经验证过：

```text
1001
↔
1005
```

可以正常切换。

---

# 六、后端真实门店切换接口

当前真实接口：

```http
POST /api/v1/auth/switch-store
```

请求：

```json
{
  "storeId": 1005
}
```

切换成功：

```text
新 Token
 ↓
重新 /me
 ↓
Auth Store 更新
 ↓
Permission Store 更新
 ↓
Store Context 更新
```

必须继续使用现有：

```text
storeStore.switchStore()
```

禁止在 Header 中重新实现：

```text
POST switch-store
```

禁止直接修改 Token。

禁止直接修改 Auth Store。

---

# 七、员工下拉菜单

Header 右侧当前已经有：

```text
测试员工
店长
退出
```

本阶段将它正式改成：

```text
测试员工 ▼
```

点击后：

```text
┌────────────────────┐
│ 测试员工            │
│ 店长                │
├────────────────────┤
│ 修改密码            │
│ 退出登录            │
└────────────────────┘
```

---

# 八、修改密码功能的特殊要求

非常重要。

当前后端：

> **还没有修改密码接口。**

因此：

禁止 Cursor 自己创建：

```text
/api/v1/auth/change-password
```

禁止假设：

```text
POST /api/v1/auth/change-password
```

禁止修改后端。

禁止伪造 API。

禁止通过其他接口偷偷实现。

---

## 8.1 本阶段 UI 行为

员工菜单显示：

```text
修改密码
```

但是当前：

```text
disabled
```

或者点击后显示：

```text
修改密码功能暂未开放
```

推荐：

> 使用 disabled 状态，并在必要时提供明确的“暂未开放”提示。

---

## 8.2 以后后端提供接口后

未来只需要增加：

```text
changePassword()
```

并接入正式接口。

本阶段不实现。

---

# 九、退出登录

员工菜单：

```text
退出登录
```

必须复用：

```text
authStore.logout()
```

不要：

```text
removeToken()
router.push('/login')
```

自己实现。

因为已有：

```text
authStore.logout()
```

负责：

```text
调用后端 logout
finally clearAuth()
```

必须保持已有行为。

---

# 十、Logo 设计

左上角建立：

```text
AppLogo
```

建议：

```text
src/layouts/components/AppLogo.vue
```

当前正式 Logo 尚未确定。

因此：

> 暂时使用文字 Logo。

展开状态：

```text
UDAO
```

折叠状态：

```text
U
```

以后可以直接替换为正式品牌图片。

---

# 十一、Logo 结构

整体：

```text
┌────────────────┬─────────────────────────────────────┐
│                │ Header                              │
│      UDAO      ├─────────────────────────────────────┤
│                │ Tabs                                │
├────────────────┼─────────────────────────────────────┤
│                │                                     │
│    Sidebar     │ RouterView                          │
│                │                                     │
└────────────────┴─────────────────────────────────────┘
```

Logo 区域高度：

> 与 Header 高度保持一致。

当前 Header：

```text
48px
```

所以：

```text
Logo Area ≈ 48px
Header ≈ 48px
```

---

# 十二、Logo 与 Sidebar 的关系

MainLayout 当前：

```text
AppSidebar
AppHeader
```

调整为：

```text
Sidebar Area
│
├── AppLogo
└── AppSidebar
```

即：

```text
┌──────────────┬─────────────────────────────────────┐
│    UDAO      │ Header                              │
├──────────────┤─────────────────────────────────────┤
│              │ Tabs                                │
│   Sidebar    │                                     │
│              │ RouterView                          │
└──────────────┴─────────────────────────────────────┘
```

---

# 十三、Sidebar 折叠时 Logo

展开：

```text
┌────────────────┐
│      UDAO      │
└────────────────┘
```

折叠：

```text
┌──────┐
│  U   │
└──────┘
```

Logo 必须跟 Sidebar 折叠状态同步。

不要创建独立的：

```text
logoStore
```

直接通过 MainLayout 当前已有的折叠状态控制。

---

# 十四、Header 结构

Header 最终：

```text
┌─────────────────────────────────────────────────────────┐
│ ☰    Breadcrumb                 门店 ▼    测试员工 ▼    │
└─────────────────────────────────────────────────────────┘
```

左侧：

```text
折叠按钮
+
Breadcrumb
```

右侧：

```text
StoreSelector
+
EmployeeDropdown
```

---

# 十五、StoreSelector

点击当前门店：

```text
杭州河滨之城店 ▼
```

显示：

```text
┌────────────────────────┐
│ 杭州河滨之城店          │
│ 杭州××店                │
└────────────────────────┘
```

实际名称必须以当前项目真实数据为准。

---

# 十六、门店名称数据来源

非常重要。

当前 `/me` 返回：

```text
storeId
storeName
storeIds
```

当前 Store Store：

```text
currentStoreId
currentStoreName
availableStoreIds
```

本阶段：

> 当前门店名称使用 Store Store。

但：

> availableStoreIds 当前只有 ID。

不要猜测其他门店名称。

---

# 十七、门店下拉名称问题

如果当前已有 Stores API，并且项目已有合法的门店查询方式：

可以扫描并复用。

但不要为了做 Header 而重新设计后端。

如果当前 Store Store 没有保存完整：

```text
[
  {
    id,
    name
  }
]
```

而只有：

```text
availableStoreIds
```

那么：

> 当前阶段允许先显示门店 ID 或基于已有数据能够安全获得的名称。

禁止：

```text
1001 -> 杭州河滨之城店
1005 -> 某某店
```

这种硬编码。

---

# 十八、门店切换流程

必须：

```text
点击门店
    ↓
选择目标门店
    ↓
storeStore.switchStore(targetStoreId)
    ↓
POST /api/v1/auth/switch-store
    ↓
得到新 Token
    ↓
重新 /me
    ↓
Auth Store 更新
    ↓
Permission Store 更新
    ↓
Store Store 更新
    ↓
Header 更新
```

---

# 十九、切换中的 UI

切换期间：

```text
switching === true
```

需要：

```text
禁止重复点击
```

可以显示：

```text
切换中...
```

或者 Element Plus loading。

禁止用户连续点击：

```text
1001
1005
1001
1005
```

造成并发请求。

---

# 二十、门店切换失败

如果：

```text
10003
```

必须保持：

```text
原 Token
原 currentUser
原 currentStore
```

Header 不应该变成目标门店。

应该提示：

```text
无该门店权限
```

---

# 二十一、门店切换 10001

如果切换过程中收到：

```text
10001
```

必须沿用已有：

```text
auth-expired
```

逻辑。

最终：

```text
清理 Auth
清理 Permission
清理 Store
→ /login
```

不要在 StoreSelector 里面重新实现退出逻辑。

---

# 二十二、门店切换成功后的 Tab 行为

本阶段需要明确设计：

> 门店切换成功后，不自动关闭所有 Tab。

例如：

```text
当前门店：
杭州河滨之城店

Tabs：
[首页] [客户管理] [预约中心]
```

切换到：

```text
杭州××店
```

Tabs：

```text
[首页] [客户管理] [预约中心]
```

继续保留。

但是：

> 当前业务页面的数据最终必须由后端当前 Token/storeId 决定。

本阶段不要去修改业务页面，因为业务页面还没有开发。

---

# 二十三、Breadcrumb

Breadcrumb 必须基于 Router。

不要在每个页面：

```vue
<el-breadcrumb>
```

手写。

建议通过：

```text
route.matched
```

以及：

```text
route.meta
```

统一计算。

---

# 二十四、Breadcrumb 建议

首页：

```text
首页
```

未来：

```text
店务管理 / 预约中心
```

未来详情：

```text
客户管理 / 客户详情
```

如果某个页面不需要面包屑：

可以通过：

```text
meta.breadcrumb = false
```

控制。

---

# 二十五、Breadcrumb 不负责菜单权限

Breadcrumb：

> 只是当前路由的视觉导航。

不要在 Breadcrumb 中：

```text
请求菜单
检查权限
判断 dataScope
```

---

# 二十六、Page Tabs

现在开始建立：

> ERP 页面标签管理。

最终：

```text
┌─────────────────────────────────────────────────────────┐
│ [首页] [客户管理 ×] [预约中心 ×] [订单详情 ×]           │
└─────────────────────────────────────────────────────────┘
```

---

# 二十七、Tab Store

新增：

```text
src/stores/tabs.ts
```

职责：

```text
tabs
activeTab
```

建议：

```text
addTab()
removeTab()
activateTab()
closeCurrentTab()
closeOtherTabs()
closeAllTabs()
closeTabsToRight()
refreshTab()
```

如果某些方法本阶段暂时不需要，可以先设计接口，但不要制造无意义复杂代码。

---

# 二十八、Tab 数据模型

建议：

```ts
interface AppTab {
  key: string
  path: string
  title: string
  closable: boolean
  keepAlive: boolean
}
```

必要时可以根据实际 Router 结构增加：

```text
name
query
params
meta
```

但不要为了“以后可能需要”堆大量字段。

---

# 二十九、Tab 唯一 Key

普通静态页面：

```text
/
```

只能存在一个。

例如：

```text
客户管理
```

也只能存在一个。

动态详情：

```text
/customer/10001
/customer/10002
```

应该允许：

```text
[张三]
[李四]
```

两个 Tab。

因此：

> 不要简单用 route.name 作为所有 Tab 唯一 Key。

优先考虑：

```text
fullPath
```

或者实际项目中更合适的：

```text
name + params
```

根据扫描结果决定。

---

# 三十、首页 Tab

首页：

```text
title = 首页
closable = false
```

必须始终存在。

如果用户关闭其他页面：

```text
[首页]
```

仍然存在。

---

# 三十一、打开页面自动创建 Tab

以后：

```text
router.push('/customer')
```

应该自动产生：

```text
[客户管理]
```

因此需要建立：

```text
Router
 ↓
Tab Store
```

的联动。

---

# 三十二、Router 与 Tab 的关系

最终：

```text
用户点击菜单
      ↓
Router.push()
      ↓
route changed
      ↓
Tab Store add/activate
      ↓
AppTabs 更新
      ↓
RouterView 更新
```

不要让：

```text
AppTabs
```

自己维护一套独立的“当前页面”。

Router：

> 是真正的页面状态来源。

Tab Store：

> 是页面历史/工作区状态。

---

# 三十三、点击 Tab

点击：

```text
[客户管理]
```

必须：

```text
router.push(tab.path)
```

不要直接操作 RouterView。

---

# 三十四、关闭 Tab

点击：

```text
客户管理 ×
```

应该：

1. 从 Tab Store 删除
2. 如果关闭的是当前 Tab
3. 自动跳到合理的相邻 Tab

例如：

```text
[首页] [客户] [预约]
```

当前：

```text
[客户]
```

关闭：

```text
客户 ×
```

可以跳：

```text
预约
```

或者：

```text
首页
```

必须形成稳定规则。

建议：

> 优先激活关闭 Tab 左侧的 Tab；左侧没有则激活右侧；都没有则回首页。

---

# 三十五、关闭首页

禁止关闭。

首页不显示：

```text
×
```

---

# 三十六、重复打开

例如已经有：

```text
[客户管理]
```

再次打开：

```text
客户管理
```

不能出现：

```text
[客户管理] [客户管理]
```

应该：

```text
激活已有 Tab
```

---

# 三十七、KeepAlive

需要建立基础 KeepAlive 机制。

但：

> 不允许所有页面无脑 KeepAlive。

通过：

```text
route.meta.keepAlive
```

控制。

例如：

```ts
meta: {
  keepAlive: true
}
```

才缓存。

---

# 三十八、RouterView + KeepAlive

根据当前 Vue Router 版本和实际项目结构实现。

目标：

```text
RouterView
    ↓
KeepAlive
    ↓
页面组件
```

但必须特别注意：

> 动态路由页面的缓存 key 必须正确。

不要出现：

```text
张三页面
↓
打开李四
↓
显示张三缓存
```

这种严重问题。

---

# 三十九、页面状态保留

以后：

```text
客户列表
```

页面可能存在：

```text
搜索条件
分页
排序
筛选
滚动位置
```

打开：

```text
预约中心
```

再回：

```text
客户列表
```

如果该路由：

```text
keepAlive=true
```

则允许保留组件状态。

---

# 四十、Tab 与 KeepAlive 的关系

不要认为：

```text
Tab = KeepAlive
```

两者是不同概念。

Tab：

> 用户工作区历史。

KeepAlive：

> Vue 组件实例缓存。

例如：

```text
Tab 存在
```

不一定：

```text
keepAlive=true
```

以后可以允许：

```text
订单详情
Tab 保留
组件不缓存
```

---

# 四十一、关闭 Tab 时必须处理缓存

如果某个页面：

```text
keepAlive=true
```

关闭 Tab 后：

> 应该允许对应缓存实例被销毁。

否则：

```text
Tab 已关闭
但组件还一直占内存
```

这是不正确的。

根据实际 Vue Router / KeepAlive 实现方式处理。

不要只删除 Tab 数组而忽略缓存生命周期。

---

# 四十二、Tab 刷新

本阶段可以提供：

```text
refreshTab()
```

基础能力。

但不要为了刷新功能引入：

```text
window.location.reload()
```

因为那会刷新整个 ERP。

目标是：

> 刷新当前页面组件。

可以使用：

```text
key
```

或者：

```text
KeepAlive
```

相关机制实现。

根据实际项目选择最稳定方案。

---

# 四十三、Tab 右键菜单

本阶段：

> 可以暂不实现完整右键菜单 UI。

但是 Tab Store 可以预留：

```text
closeOtherTabs()
closeTabsToRight()
closeAllTabs()
```

未来再做。

不要为了这个阶段引入复杂第三方组件。

---

# 四十四、Tabs 滚动

当页面 Tab 很多：

```text
[首页][客户][客户2][客户3][预约][订单]...
```

不能撑爆 Header。

Tabs 区域应该：

> 横向滚动。

可以使用：

```text
overflow-x: auto
```

或者 Element Plus 已有合理组件。

不要出现整个浏览器出现横向滚动条。

---

# 四十五、Sidebar 与 Tabs 的关系

Sidebar：

> 导航。

Tabs：

> 工作区。

两者不是一回事。

例如：

```text
Sidebar：
客户管理
预约中心
订单管理
```

Tabs：

```text
[首页] [张三] [订单10001]
```

不要强行让 Tabs 等于 Sidebar 菜单。

---

# 四十六、Breadcrumb 与 Tabs 的关系

例如：

```text
Tabs：
[张三]
```

Breadcrumb：

```text
客户管理 / 客户详情
```

两者显示不同信息。

Tab：

> 用户当前打开的工作页面名称。

Breadcrumb：

> 当前页面在系统功能树中的位置。

---

# 四十七、员工下拉菜单

建议结构：

```text
┌─────────────────────┐
│ 测试员工             │
│ 店长                 │
├─────────────────────┤
│ 修改密码             │
│ 退出登录             │
└─────────────────────┘
```

如果 Element Plus 已使用：

可以使用：

```text
ElDropdown
```

但必须遵守当前项目风格。

---

# 四十八、修改密码菜单

显示：

```text
修改密码
```

当前：

```text
disabled
```

鼠标操作不要调用 API。

如果 Element Plus 的 disabled 无法提供明确反馈：

可以点击后：

```text
ElMessage.info('修改密码功能暂未开放')
```

但是不要在 Request Interceptor 中处理。

---

# 四十九、退出登录确认

建议：

点击：

```text
退出登录
```

弹出：

```text
确定退出当前账号吗？
```

然后：

```text
取消
确定
```

确定：

```text
authStore.logout()
```

取消：

> 什么都不做。

如果当前项目已经有成熟确认组件，可以复用。

---

# 五十、Logout 异常

即使后端 logout 请求失败：

> 也必须保持 Auth Store 现有 logout 行为。

当前已有：

```text
finally clearAuth()
```

不要在 Header 里自己处理。

---

# 五十一、不要修改 Auth Store

本阶段：

> 禁止为了员工下拉菜单修改 Auth Store。

如果需要显示：

```text
employeeName
jobName
```

直接使用现有：

```text
authStore.currentUser
```

或者：

```text
authStore.employee
```

---

# 五十二、不要创建 User Store

禁止新增：

```text
userStore
profileStore
accountStore
```

---

# 五十三、不要实现修改密码后端

再次强调：

> 后端没有接口。

不要修改：

```text
Spring Boot
Controller
Service
Mapper
DB
```

---

# 五十四、MainLayout 最终结构

目标：

```text
MainLayout
│
├── SidebarArea
│   │
│   ├── AppLogo
│   │
│   └── AppSidebar
│
└── MainArea
    │
    ├── AppHeader
    │   ├── CollapseButton
    │   ├── Breadcrumb
    │   ├── StoreSelector
    │   └── EmployeeDropdown
    │
    ├── AppTabs
    │
    └── ContentArea
        │
        └── RouterView
```

---

# 五十五、建议文件结构

最终建议：

```text
src/
├── layouts/
│   ├── MainLayout.vue
│   │
│   └── components/
│       ├── AppLogo.vue
│       ├── AppSidebar.vue
│       ├── AppHeader.vue
│       ├── AppBreadcrumb.vue
│       ├── AppStoreSelector.vue
│       ├── AppUserDropdown.vue
│       └── AppTabs.vue
│
├── stores/
│   ├── auth.ts
│   ├── permission.ts
│   ├── store.ts
│   └── tabs.ts
```

如果当前项目结构不同：

> 以实际项目为准。

不要为了“符合目录”大规模移动文件。

---

# 五十六、组件职责必须清晰

## AppLogo

只负责：

```text
Logo 展示
展开/折叠状态
```

---

## AppSidebar

只负责：

```text
导航菜单
```

本阶段仍然：

> 不做权限菜单。

---

## AppHeader

负责：

```text
顶栏容器
```

---

## AppBreadcrumb

负责：

```text
当前 Router 面包屑
```

---

## AppStoreSelector

负责：

```text
当前门店展示
门店选择 UI
调用 storeStore.switchStore()
```

不要自己处理 Token。

---

## AppUserDropdown

负责：

```text
员工信息展示
修改密码入口
退出登录入口
```

不要自己清 Token。

---

## AppTabs

负责：

```text
Tab UI
点击 Tab
关闭 Tab
```

真正数据由：

```text
tabsStore
```

管理。

---

# 五十七、Tab Store 不负责 Router

Tabs Store 可以调用 Router 吗？

建议：

> 尽量不要让 Store 强耦合 Router。

优先：

```text
组件
 ↓
router.push()
 ↓
route change
 ↓
tabsStore 同步
```

如果实际实现确实需要 Router：

必须控制依赖，避免：

```text
router
 ↔
tabsStore
 ↔
router
```

形成循环依赖。

---

# 五十八、Tab 同步机制

建议在 MainLayout 或独立 composable 中监听：

```text
useRoute()
```

当：

```text
route.fullPath
```

变化：

执行：

```text
tabsStore.addTab(route)
tabsStore.activateTab(...)
```

这样：

```text
router.push()
```

是唯一页面切换入口。

---

# 五十九、页面标题来源

优先：

```text
route.meta.title
```

例如：

```ts
{
  path: '/customers',
  component: CustomersView,
  meta: {
    title: '客户管理',
    keepAlive: true
  }
}
```

Tab：

```text
客户管理
```

Breadcrumb：

```text
客户管理
```

如果没有：

> 再根据当前 route name 等实际信息提供合理 fallback。

禁止出现：

```text
undefined
```

---

# 六十、未来动态标题预留

例如：

```text
客户详情 / 张三
```

本阶段不要硬编码业务页面。

但是 Tab 数据模型必须允许以后支持：

```text
title
```

动态生成。

---

# 六十一、路由 Meta 类型

如果项目已有：

```text
RouteMeta
```

请扩展而不是重新定义。

可能需要：

```ts
interface RouteMeta {
  requiresAuth?: boolean
  title?: string
  keepAlive?: boolean
  breadcrumb?: boolean
  tabClosable?: boolean
}
```

实际项目中按现有类型体系实现。

---

# 六十二、AuthInitError 页面

非常重要。

当前：

```text
/auth-init-error
```

必须继续：

> 不进入 MainLayout。

所以：

```text
/auth-init-error
```

不能创建 Tab。

也不能进入：

```text
tabsStore
```

---

# 六十三、Login 页面

```text
/login
```

不能创建 Tab。

---

# 六十四、业务页面

以后所有：

```text
requiresAuth=true
```

的后台业务页面：

> 默认可以进入 MainLayout。

是否进入 Tab：

> 由 route meta / Shell 统一规则决定。

---

# 六十五、异常页面

以后类似：

```text
404
500
权限不足
```

如果属于后台工作区：

再单独决定是否加入 Tab。

本阶段只处理现有：

```text
/login
/auth-init-error
```

排除规则。

---

# 六十六、不要做 03-10

以下全部不做：

```text
全局按钮权限
v-permission 扩展
全局通知中心
全局快捷键
主题切换
全局搜索
消息中心
```

这些属于后续阶段。

---

# 六十七、不要做业务模块

禁止：

```text
客户管理
预约中心
收银
开单
耗卡
卡项
员工
绩效
供应链
营销
报表
```

---

# 六十八、开发前必须扫描

先扫描：

```text
src/main.ts
src/App.vue
src/router/
src/router/guard.ts
src/layouts/
src/layouts/components/
src/stores/
src/types/
src/utils/
src/views/
src/config/
```

重点确认：

1. MainLayout 当前结构
2. AppSidebar 当前实现
3. AppHeader 当前实现
4. Sidebar 折叠状态在哪里
5. Router 当前结构
6. Route Meta 类型
7. Auth Store
8. Store Store
9. Permission Store
10. HomeView
11. AuthInitErrorView

---

# 六十九、开发顺序

必须严格按照以下顺序：

```text
03-9-1 AppLogo
        ↓
03-9-2 Header 结构整理
        ↓
03-9-3 Breadcrumb
        ↓
03-9-4 StoreSelector
        ↓
03-9-5 EmployeeDropdown
        ↓
03-9-6 Tabs Store
        ↓
03-9-7 AppTabs
        ↓
03-9-8 Router / Tabs 联动
        ↓
03-9-9 KeepAlive
        ↓
03-9-10 Tab Close / Activate
        ↓
03-9-11 Tab Refresh 基础能力
        ↓
03-9-12 综合验证
```

---

# 七十、每一步完成后不要停下来询问

除非发现：

```text
现有架构冲突
```

否则按顺序继续完成。

如果发现架构冲突：

> 停止修改并报告问题。

不要擅自重构已有基础设施。

---

# 七十一、最小改动原则

只修改：

```text
Logo
Header
MainLayout
Router Meta
Tab Store
Tab UI
必要的 KeepAlive 机制
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

# 七十二、不能改变现有认证行为

以下行为必须保持：

```text
无 Token
→ /login

Token + /me 成功
→ MainLayout

Token + /me 10001
→ /login

Token + /me 10002/10003
→ AuthInitError

业务 API 10002
→ 保留当前登录

业务 API 10003
→ 保留当前登录
```

---

# 七十三、门店切换后的认证链路

成功：

```text
StoreSelector
 ↓
storeStore.switchStore()
 ↓
switch-store
 ↓
setToken
 ↓
authStore.fetchCurrentUser()
 ↓
permissionStore.initialize()
 ↓
storeStore.update
```

不要改变。

---

# 七十四、门店切换失败验证

必须测试：

```text
当前：
1001
```

尝试：

```text
无权限门店
```

要求：

```text
Token 不变
当前用户不变
当前门店不变
Header 不变
Tab 不丢失
```

---

# 七十五、门店切换成功验证

测试：

```text
1001 → 1005
1005 → 1001
```

要求：

```text
Token 改变
/me 更新
currentStoreId 更新
currentStoreName 更新
Header 更新
```

Tab 不应该被无故清空。

---

# 七十六、员工菜单验证

测试：

```text
点击员工名称
```

看到：

```text
修改密码
退出登录
```

点击：

```text
修改密码
```

要求：

```text
不发 API
不改变路由
不改变 Token
```

提示：

```text
修改密码功能暂未开放
```

或者保持 disabled。

---

# 七十七、退出登录验证

点击：

```text
退出登录
```

确认后：

```text
authStore.logout()
```

最终：

```text
Token 清除
Auth Store 清除
Permission 清除
Store Context 清除
Tabs 清理
→ /login
```

注意：

> 如果当前 logout 流程已有统一清理机制，不要重复清理。

---

# 七十八、Tabs 验证

至少验证：

```text
首页
```

自动存在。

然后：

```text
首页
→ menu-placeholder
```

产生：

```text
[首页] [菜单占位]
```

再回首页：

```text
[首页] [菜单占位]
```

Tab 仍然存在。

---

# 七十九、重复打开验证

点击：

```text
菜单占位
```

多次。

不能：

```text
[首页] [菜单占位] [菜单占位] [菜单占位]
```

只能：

```text
[首页] [菜单占位]
```

---

# 八十、关闭 Tab 验证

点击：

```text
菜单占位 ×
```

最终：

```text
[首页]
```

回到：

```text
/
```

---

# 八十一、关闭当前 Tab 验证

至少测试：

```text
首页
菜单占位
```

当前：

```text
菜单占位
```

关闭后：

```text
首页
```

---

# 八十二、Tab 横向溢出验证

如果可以：

临时创建足够多测试路由。

但：

> 测试完成后不要保留大量测试业务路由。

要求：

```text
Tab 区域横向滚动
```

浏览器：

```text
不能出现横向滚动条
```

---

# 八十三、KeepAlive 验证

创建临时简单测试页面。

例如：

```text
Tab Test
```

里面有：

```text
输入框
```

输入：

```text
ABC
```

切换其他 Tab。

再回来：

> 如果 keepAlive=true，ABC 应该保留。

测试完成后：

> 删除测试代码。

---

# 八十四、关闭 KeepAlive 页面

测试：

```text
打开页面
输入 ABC
关闭 Tab
重新打开
```

要求：

> 不应该继续保留上一次已经关闭页面的组件状态。

---

# 八十五、刷新 Tab

如果实现：

```text
refreshTab()
```

测试：

```text
输入 ABC
刷新
```

根据最终定义：

> 页面组件重新创建。

不要导致：

```text
整个浏览器刷新
```

---

# 八十六、浏览器刷新

刷新：

```text
F5
```

要求：

```text
Auth Store 恢复
Router Guard 正常
MainLayout 正常
当前路由正常
```

如果项目选择将 Tabs 持久化到 localStorage：

> 必须确保安全且合理。

本阶段不强制持久化 Tabs。

---

# 八十七、Tabs 是否持久化

第一版建议：

> **Tabs 不持久化到 localStorage。**

原因：

用户关闭浏览器重新进入 ERP：

```text
Auth 可以恢复
```

但：

```text
工作区 Tab
```

是否恢复是另外一个产品需求。

第一版：

```text
浏览器刷新
```

可以由 Router 当前 URL 恢复当前 Tab。

但：

```text
关闭浏览器
重新打开
```

不要求恢复全部 Tab。

---

# 八十八、Store 切换 + Tabs

测试：

```text
Tab：
[首页] [菜单占位]
```

切换：

```text
1001 → 1005
```

要求：

```text
Tabs 仍存在
当前路由不乱跳
```

---

# 八十九、Logo 验证

展开：

```text
UDAO
```

折叠：

```text
U
```

Sidebar：

```text
200px
```

折叠：

```text
64px
```

Logo 与 Sidebar 对齐。

---

# 九十、响应式验证

至少测试：

```text
1100 × 640
900 × 600
```

要求：

```text
无横向滚动条
Logo 不溢出
Header 不溢出
Tabs 可以滚动
Sidebar 正常
Content 正常
```

---

# 九十一、代码质量要求

禁止：

```text
any
```

除非第三方类型不可避免，并必须说明。

禁止：

```text
@ts-ignore
@ts-nocheck
```

禁止：

```text
大量重复代码
```

禁止：

```text
魔法字符串
```

可以建立必要的类型和常量。

---

# 九十二、不要新增依赖

本阶段：

> 不新增 npm 包。

优先使用：

```text
Vue
Vue Router
Pinia
Element Plus
原生 CSS
```

---

# 九十三、完成后运行

必须：

```bash
npm run type-check
```

然后：

```bash
npm run build
```

如果有：

```bash
npm run lint
```

也执行。

---

# 九十四、最终报告

完成后必须输出：

## 1. 扫描结果

说明：

```text
Router
MainLayout
Sidebar
Header
Auth Store
Store Store
Permission Store
Route Meta
```

当前结构。

---

## 2. 新增文件

例如：

```text
src/layouts/components/AppLogo.vue
src/layouts/components/AppBreadcrumb.vue
src/layouts/components/AppStoreSelector.vue
src/layouts/components/AppUserDropdown.vue
src/layouts/components/AppTabs.vue
src/stores/tabs.ts
```

按照实际情况列出。

---

## 3. 修改文件

完整列出。

---

## 4. MainLayout 最终结构

必须给出：

```text
MainLayout
├── SidebarArea
│   ├── AppLogo
│   └── AppSidebar
└── MainArea
    ├── AppHeader
    │   ├── CollapseButton
    │   ├── Breadcrumb
    │   ├── StoreSelector
    │   └── EmployeeDropdown
    ├── AppTabs
    └── RouterView
```

---

## 5. Tab Store

说明：

```text
数据结构
状态
主要方法
```

---

## 6. KeepAlive

说明：

```text
如何实现
如何控制
如何销毁
```

---

## 7. 门店切换

说明：

```text
Header
 ↓
StoreSelector
 ↓
storeStore.switchStore()
 ↓
新 Token
 ↓
/me
 ↓
Permission
 ↓
Store Context
```

---

## 8. 员工菜单

说明：

```text
员工名称
岗位
修改密码
退出登录
```

并明确：

```text
修改密码暂未调用 API
```

---

## 9. 验证结果

必须：

```text
Type Check: PASS/FAIL
Build: PASS/FAIL
Lint: PASS/FAIL/未配置
```

---

## 10. Runtime

至少：

```text
Logo：PASS/FAIL
Sidebar：PASS/FAIL
Header：PASS/FAIL
Breadcrumb：PASS/FAIL
StoreSelector：PASS/FAIL
Store Switch：PASS/FAIL
Employee Dropdown：PASS/FAIL
Change Password Disabled：PASS/FAIL
Logout：PASS/FAIL
Tabs：PASS/FAIL
Duplicate Tab：PASS/FAIL
Close Tab：PASS/FAIL
KeepAlive：PASS/FAIL
Refresh Tab：PASS/FAIL
Browser Refresh：PASS/FAIL
AuthInitError：PASS/FAIL
No Token：PASS/FAIL
Responsive：PASS/FAIL
```

---

# 九十五、变更边界确认

必须明确回答：

```text
是否修改 Auth Store：否
是否修改 Permission Store：否
是否修改 Store Context 核心逻辑：否
是否修改 Request：否
是否修改 Login：否
是否修改 Router Guard 核心逻辑：否
是否新增修改密码后端接口：否
是否修改后端：否
是否修改数据库：否
是否实现业务模块：否
是否实现权限菜单：否
是否实现全局按钮权限：否
```

如果其中任何一项为“是”：

> 必须说明具体原因和文件。

---

# 九十六、最终 PASS 标准

只有以下全部满足：

```text
[ ] AppLogo 完成
[ ] Logo 与 Sidebar 折叠状态同步
[ ] Header 完成
[ ] Breadcrumb 完成
[ ] StoreSelector 完成
[ ] 可以真实切换门店
[ ] 切换失败不会破坏当前登录状态
[ ] EmployeeDropdown 完成
[ ] 修改密码入口存在
[ ] 修改密码没有调用不存在的 API
[ ] 退出登录复用 authStore.logout()
[ ] Tabs Store 完成
[ ] AppTabs 完成
[ ] 首页 Tab 固定
[ ] Tab 重复打开不会重复创建
[ ] Tab 可以切换
[ ] Tab 可以关闭
[ ] 关闭当前 Tab 后有正确的回退逻辑
[ ] Tab 可以横向滚动
[ ] Router 与 Tab 正确联动
[ ] KeepAlive 基础能力完成
[ ] 关闭 Tab 后缓存正确销毁
[ ] Refresh Tab 不刷新整个浏览器
[ ] 浏览器 F5 正常
[ ] AuthInitError 不进入 Tab
[ ] Login 不进入 Tab
[ ] 门店切换不无故清空 Tab
[ ] 没有破坏 03-1 ～ 03-8
[ ] Type Check PASS
[ ] Build PASS
[ ] Runtime PASS
[ ] 没有开发业务模块
```

全部满足：

> **03-9 ERP 工作区正式 PASS**

然后停止。

不要继续执行 03-10。

不要开始业务模块。

等待下一条指令。
