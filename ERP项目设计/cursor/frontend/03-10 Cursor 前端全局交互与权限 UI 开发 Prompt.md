# 03-10 Cursor 前端全局交互与权限 UI 开发 Prompt

你现在负责执行 ERP 前端基础框架阶段：

> **03-10：全局交互规范 + 权限 UI**

这是 ERP 前端基础框架的最后一个建设阶段之一。

前面已经完成并验收：

- 03-1 Request / Token
- 03-2 Login
- 03-3 Auth Store
- 03-4 Permission Store
- 03-5 Store Context / Store Switch
- 03-6 Router Guard
- 03-7 MainLayout
- 03-8 Sidebar + Header
- 03-9 ERP 工作区

因此：

> **不要重新设计前面的架构。**
>
> **不要重复实现已经 PASS 的功能。**
>
> **不要为了本阶段方便而修改 Auth Store、Permission Store、Store Store、Request、Router Guard 的核心逻辑。**

本阶段目标是：

> 在现有 ERP 前端基础框架之上，建立统一的「全局交互层」和「权限 UI 层」，让后续所有业务模块都使用统一规范。

---

# 一、项目背景

当前前端技术栈：

- Vue 3
- TypeScript
- Vite
- Element Plus
- Pinia
- Vue Router
- Axios

项目：

```text
jwin-frontend
```

后端：

```text
Spring Boot
127.0.0.1:12002
```

前端开发服务器：

```text
http://localhost:5173
```

API：

```text
/api
```

实际业务 API：

```text
/v1/...
```

---



# 二、当前前端已经存在的基础能力

你必须先扫描实际项目代码。

重点查看：

```text
src/
├── api/
├── components/
├── layouts/
├── router/
├── stores/
├── types/
├── utils/
├── views/
└── main.ts
```

重点检查：

```text
src/utils/request.ts
src/utils/token.ts
src/utils/api-error.ts
src/utils/auth-event.ts

src/stores/auth.ts
src/stores/permission.ts
src/stores/store.ts
src/stores/tabs.ts

src/router/index.ts

src/layouts/MainLayout.vue
src/layouts/components/AppHeader.vue
src/layouts/components/AppSidebar.vue
src/layouts/components/AppLogo.vue
src/layouts/components/AppBreadcrumb.vue
src/layouts/components/AppStoreSelector.vue
src/layouts/components/AppUserDropdown.vue
src/layouts/components/AppTabs.vue
```

不要假设代码结构。

必须以当前真实代码为准。

---



# 三、必须先做一次只读扫描

在修改代码之前，先回答：

## 1. 当前请求异常如何处理

检查：

```text
request.ts
api-error.ts
auth-event.ts
```

确认：

```text
10001
10002
10003
50000
HTTP 401
HTTP 403
网络异常
timeout
```

目前分别是什么行为。

---



# 四、当前权限模型

后端 `/me` 已经返回：

```text
employeeId
employeeName
jobId
jobName
jobTypeIds
orgEntityIds
storeId
storeName
storeIds
roles
permissionCodes
dataScope
```

权限来源：

```text
TB_JobTypeMenuPermission
+
TB_RoleMenuPermission
```

前端不能自己通过：

```text
jobName
role.name
jobId
```

推导权限。

必须使用：

```text
permissionCodes
```

作为 UI 权限判断依据。

---



# 五、本阶段核心目标

本阶段建立下面这层：

```text
业务页面
   ↓
统一 UI 交互规范
   ↓
全局交互工具
   ↓
Permission UI
   ↓
已有 Auth / Permission / Store / Request
```

以后业务模块：

```text
客户管理
预约中心
开单收银
耗卡
会员卡
项目管理
员工管理
供应链
营销
报表
```

都必须使用这一层。

---



# 六、禁止事项

本阶段严禁：

## 1. 不开发业务模块

不要开发：

```text
客户列表
客户详情
开单页面
耗卡页面
预约页面
会员卡页面
项目页面
员工页面
```

即使只是 Demo，也不要。

---



## 2. 不重新设计权限体系

不要新增：

```text
role → permission
job → permission
store → permission
```

之类的前端推导。

---



## 3. 不修改后端

本阶段：

```text
后端 = 不修改
数据库 = 不修改
API = 不新增
```

---



## 4. 不修改已有核心认证流程

不要重写：

```text
Auth Store
Permission Store
Store Store
Router Guard
Request Interceptor
Login
```

如果发现问题：

1. 先记录；
2. 判断是否属于本阶段必须修复的问题；
3. 如果不是阻塞问题，不顺手重构。

---



# 七、建立统一的全局交互层

建议建立：

```text
src/
└── utils/
    └── ui/
        ├── message.ts
        ├── confirm.ts
        ├── loading.ts
        ├── error.ts
        └── index.ts
```

如果当前项目结构更适合：

```text
src/composables/
```

也可以采用 composable。

但是必须：

> 先看当前项目结构，再决定最终位置。

不要为了目录漂亮而重构整个项目。

---



# 八、统一 Message

建立统一消息入口。

例如：

```ts
uiMessage.success(...)
uiMessage.warning(...)
uiMessage.error(...)
uiMessage.info(...)
```

底层可以使用：

```text
ElMessage
```

但是业务页面以后不要到处直接写：

```ts
ElMessage.success(...)
ElMessage.error(...)
```

而应该：

```ts
uiMessage.success('保存成功')
```

---



# 九、Message 使用规范

成功：

```text
保存成功
提交成功
切换成功
操作成功
```

警告：

```text
请先选择客户
请选择项目
当前没有可操作数据
```

错误：

```text
保存失败
提交失败
操作失败
```

注意：

> 不要把技术错误直接展示给用户。

例如不要直接显示：

```text
AxiosError
Request failed with status code 500
Cannot read properties of undefined
```

---



# 十、API 错误统一处理

如果业务 API：

```text
10002
```

表示：

```text
无权限
```

UI 可以显示：

```text
暂无权限执行该操作
```

但是：

> 不要在 Request Interceptor 中直接弹 UI Message。

Request 层负责：

```text
识别错误
构造错误对象
抛出错误
```

页面层负责：

```text
决定如何展示
```

---



# 十一、业务页面统一错误处理

以后页面：

```ts
try {
  await xxx()
} catch (error) {
  ...
}
```

必须根据错误类型决定。

例如：

```text
ApiBusinessError
ApiHttpError
```

不要：

```ts
catch (error) {
  ElMessage.error(String(error))
}
```

---



# 十二、统一错误转换

建立一个统一方法，例如：

```ts
getUserFriendlyErrorMessage(error)
```

负责把：

```text
ApiBusinessError
ApiHttpError
网络异常
timeout
未知错误
```

转换成用户可理解的中文。

示例：

```text
网络异常，请检查网络连接
请求超时，请稍后重试
系统暂时不可用，请稍后重试
暂无权限执行该操作
操作失败，请稍后重试
```

---



# 十三、注意 10001

如果：

```text
10001
```

已经由现有 auth-event 机制处理：

```text
清理认证状态
跳转登录页
```

那么：

> 本阶段不要重复跳转。

尤其不能出现：

```text
API → Message
API → auth-event
Page → router.push('/login')
MainLayout → router.push('/login')
```

多个地方同时处理。

必须保持：

```text
10001
↓
现有认证过期机制
↓
清理认证
↓
登录页
```

---



# 十四、统一 Confirm

建立统一确认框：

```ts
uiConfirm(...)
```

底层可以使用：

```text
ElMessageBox.confirm
```

用途：

```text
删除
作废
退款
撤销
退出登录
关闭未保存页面
清空
批量操作
```

---



# 十五、危险操作必须二次确认

以下操作默认需要确认：

```text
删除
作废
退款
撤销
关闭
清空
批量删除
批量作废
```

例如：

```text
确定要删除该项目吗？
删除后不可恢复。
```

退款：

```text
确定要执行退款吗？
退款操作提交后将影响订单及账户数据。
```

不要只写：

```text
确定吗？
```

---



# 十六、确认框规范

确认框应该包含：

```text
标题
操作说明
取消
确认
```

例如：

```text
删除客户

确定要删除该客户吗？
删除后不可恢复。

取消
确认删除
```

---



# 十七、防重复提交

以后所有：

```text
保存
提交
退款
开单
确认
切换
作废
删除
```

都必须考虑防重复提交。

页面按钮应支持：

```text
loading
disabled
```

例如：

```vue
<el-button
  :loading="submitting"
  :disabled="submitting"
>
  保存
</el-button>
```

不要依赖用户自己避免连续点击。

---



# 十八、统一 Loading 规范

区分：

## 页面 Loading

例如：

```text
列表加载
详情加载
```

优先使用：

```text
el-skeleton
el-loading
```

但根据实际页面选择。

---



## 按钮 Loading

例如：

```text
保存中...
提交中...
切换中...
```

必须使用按钮自身 loading。

---



## 全局 Loading

只用于真正需要阻塞整个工作区的操作。

例如：

```text
切换门店
登录
初始化 ERP
```

不要所有 API 都弹全局 Loading。

否则 ERP 使用体验会非常差。

---



# 十九、门店切换 Loading

现有：

```text
Store Store
```

已经负责：

```text
switchStore()
switching
```

本阶段只负责：

> 统一视觉表现。

切换期间：

```text
门店下拉禁用
切换按钮禁用
显示“切换中...”
```

不要重新实现 switchStore。

---



# 二十、按钮权限

必须正式建立统一按钮权限规范。

支持：

```vue
v-permission="'customer:create'"
```

以及：

```vue
v-permission="['customer:create', 'customer:edit']"
```

但是必须先扫描当前：

```text
src/directives/permission.ts
```

确认已有实现。

如果已有实现满足要求：

> 不重复写。

---



# 二十一、权限按钮的默认行为

对于：

```text
新增
编辑
删除
退款
导出
审核
作废
```

等按钮：

没有权限时：

```text
默认不显示
```

而不是：

```text
显示后点击提示无权限
```

因为后台 ERP 的权限 UI 应尽量保持干净。

---



# 二十二、什么时候使用 Disabled

某些情况下可以：

```text
显示按钮
但 disabled
```

例如：

```text
当前订单状态不允许退款
当前没有选择数据
当前正在提交
```

这和：

```text
没有权限
```

必须区分。

原则：

```text
无权限 → 隐藏

有权限但当前状态不能操作 → 显示 disabled
```

---



# 二十三、权限与业务状态不能混淆

例如：

用户拥有：

```text
order:refund
```

但是订单状态：

```text
已退款
```

应该：

```text
退款按钮 disabled
```

而不是：

```text
隐藏
```

因为：

```text
用户有权限
只是当前业务状态不允许
```

---



# 二十四、权限判断工具

除了：

```text
v-permission
```

建议支持：

```ts
permissionStore.hasPermission(...)
```

页面逻辑可以：

```ts
if (permissionStore.hasPermission('xxx')) {
  ...
}
```

用于：

```text
是否加载某功能
是否显示某区域
是否允许某交互
```

---



# 二十五、空状态规范

以后业务页面不能出现：

```text
白屏
空白区域
```

没有数据时应该有：

```text
暂无数据
```

或者：

```text
暂无客户
暂无订单
暂无预约
暂无记录
```

如果允许新增：

```text
暂无数据
立即新增
```

---



# 二十六、异常状态规范

业务页面至少考虑：

```text
Loading
Success + 有数据
Success + 无数据
Error
```

例如列表：

```text
Loading
↓
成功
├── 有数据 → Table
└── 无数据 → Empty
```

异常：

```text
Error
↓
错误提示
↓
重新加载
```

---



# 二十七、建立统一 Empty / Error 状态组件

如果当前项目没有：

```text
EmptyState
ErrorState
```

可以建立：

```text
src/components/common/
├── AppEmpty.vue
└── AppError.vue
```

但必须保持轻量。

---



# 二十八、AppEmpty

建议支持：

```text
title
description
action
```

例如：

```text
暂无客户

当前没有符合条件的客户

+ 新增客户
```

---



# 二十九、AppError

建议支持：

```text
title
description
retry
```

例如：

```text
加载失败

网络异常，请稍后重试

重新加载
```

---



# 三十、不要过度抽象

本阶段禁止建立巨大组件体系。

不要一口气建立：

```text
BaseTable
BaseForm
BaseDialog
BasePage
BaseSearch
BaseButton
BaseCard
BaseLayout
Base...
```

原因：

> 当前还没有真正业务页面。

等客户、订单、预约等模块开发时，根据真实重复场景再抽象。

本阶段只抽：

```text
真正全局
真正稳定
真正会重复
```

的能力。

---



# 三十一、退出登录

03-9 已经实现：

```text
员工菜单
↓
退出登录
↓
确认
↓
Auth Store logout
↓
清理
↓
Login
```

本阶段只需要检查：

```text
是否重复实现
是否统一 Message / Confirm
是否存在重复跳转
```

如果现有逻辑已经正确：

> 不要重写。

---



# 三十二、浏览器刷新

检查：

```text
F5
```

必须保持：

```text
token
currentUser
currentStore
permission
tabs
```

符合当前已经验收的行为。

不要因为本阶段新增 UI 工具破坏：

```text
Router Guard
Auth Initialize
Store Initialize
Tab Store
KeepAlive
```

---



# 三十三、Tab 关闭与危险操作

暂时不要实现复杂的：

```text
未保存数据检测
```

因为当前还没有真实表单页面。

但是建立扩展点即可。

未来：

```text
close tab
↓
判断页面是否 dirty
↓
有修改 → Confirm
↓
确认关闭
```

本阶段不要虚构业务。

---



# 三十四、统一按钮交互原则

以后所有业务模块遵循：

### 查询

```text
查询中 → loading
```



### 保存

```text
保存中 → loading
```



### 删除

```text
Confirm
↓
删除中
↓
成功
```



### 导出

```text
导出中
↓
成功
```



### 切换门店

```text
切换中
↓
重新初始化业务上下文
```

---



# 三十五、全局异常兜底

检查：

```text
Vue app errorHandler
```

如果当前没有全局异常兜底，可以建立轻量处理。

要求：

> 不要吞异常。

开发环境：

```text
console.error
```

生产环境：

```text
用户看到友好的错误提示
```

但不能把完整技术堆栈直接展示给用户。

---



# 三十六、不要在全局 errorHandler 中处理业务异常

例如：

```text
ApiBusinessError
```

不应该被全局 errorHandler 当成系统崩溃。

业务代码应该正常：

```text
try/catch
```

处理。

全局 errorHandler 主要处理：

```text
未捕获 Vue 异常
```

---



# 三十七、权限 UI Demo

为了验收本阶段，可以暂时在：

```text
HomeView.vue
```

增加一个：

```text
全局交互测试区
```

但必须明确：

> 这是基础框架验收测试，不是业务功能。

测试内容至少包括：

```text
成功消息
警告消息
错误消息
确认框
Loading
权限按钮
无权限按钮
Disabled 按钮
Empty
Error
```

---



# 三十八、权限测试

使用当前真实账号：

```text
13800000000
```

当前测试账号拥有大量 permissionCodes。

不要修改后端权限数据。

测试：

```text
已有权限 → 显示
不存在权限 → 隐藏
```

如果需要模拟无权限：

> 仅在前端测试区域通过不存在的 permissionCode 测试。

例如：

```text
__test:no:such:permission__
```

不要修改真实权限。

---



# 三十九、测试权限指令

至少验证：

```text
v-permission="'existing:permission'"
```

显示。

以及：

```text
v-permission="'__test:no:such:permission__'"
```

隐藏。

验证：

```text
Permission Store
↓
Directive
↓
DOM
```

链路正常。

---



# 四十、全局交互测试区不要污染最终页面

测试完成后：

可以保留一个：

```text
基础框架诊断页面
```

例如：

```text
/menu-placeholder
```

但不要把大量测试按钮永久塞进首页。

如果需要：

可以建立：

```text
src/views/system/UiDemoView.vue
```

但不要加入真实 ERP 业务菜单。

---



# 四十一、页面错误测试

模拟：

```text
网络断开
```

验证：

```text
页面不会白屏
用户得到明确提示
Token 不被错误清除
```

---



# 四十二、10002 测试

模拟：

```text
ApiBusinessError(10002)
```

必须：

```text
提示无权限
Token 保留
当前用户保留
当前门店保留
不跳登录
```

这与：

```text
10001
```

完全不同。

---



# 四十三、10003 测试

模拟：

```text
ApiBusinessError(10003)
```

必须：

```text
提示无门店权限
Token 保留
当前用户保留
当前门店保留
不跳登录
```

---



# 四十四、10001 测试

模拟：

```text
ApiBusinessError(10001)
```

必须继续使用已有：

```text
auth-expired
```

机制。

结果：

```text
Token 清除
Auth 清除
Permission 清除
Store 清除
Tabs 按现有逻辑清理
跳 Login
```

不能出现重复弹窗和重复跳转。

---



# 四十五、权限 UI 与 Router Guard 的边界

本阶段必须明确：

```text
Router Guard
=
控制“能不能进入页面”
```

```text
v-permission
=
控制“页面里的操作是否显示”
```

不要混淆。

例如：

```text
客户管理页面
```

用户有：

```text
customer:view
```

但没有：

```text
customer:create
```

那么：

```text
可以进入客户页面
```

但：

```text
新增客户
```

按钮隐藏。

---



# 四十六、未来权限码命名规范

本阶段只建立规范，不需要开发业务。

建议统一：

```text
模块:资源:动作
```

例如：

```text
customer:view
customer:create
customer:edit
customer:delete

order:view
order:create
order:edit
order:refund

appointment:view
appointment:create
appointment:edit
appointment:cancel
```

最终实际权限码：

> 必须以现有后端权限定义为准。

不能擅自修改后端权限码。

---



# 四十七、Store Context 与权限

门店切换不是普通权限。

例如：

```text
用户有 customer:view
```

并不代表：

```text
所有门店都可以查看
```

当前门店范围仍由：

```text
JWT storeId
+
后端 dataScope
+
后端权限
```

决定。

前端不要自己判断：

```text
dataScope === ALL
```

然后绕过后端。

---



# 四十八、前端权限只是 UI 控制

必须明确：

> 前端权限不是安全边界。

真正安全控制：

```text
Backend @RequirePermission
+
dataScope
+
store permission
```

前端：

```text
Permission Store
+
v-permission
```

只是改善 UI。

---



# 四十九、代码质量要求

必须：

```text
TypeScript strict compatible
```

禁止：

```ts
any
```

除非现有第三方类型确实无法避免，并且必须说明原因。

---



# 五十、不得出现重复工具

先搜索：

```text
ElMessage
ElMessageBox
ElLoading
```

如果项目已经有统一封装：

> 复用。

不要建立：

```text
message.ts
message-util.ts
message-helper.ts
toast.ts
notification.ts
```

五套东西。

---



# 五十一、目录设计原则

最终可以类似：

```text
src/
├── components/
│   └── common/
│       ├── AppEmpty.vue
│       └── AppError.vue
│
├── directives/
│   └── permission.ts
│
├── utils/
│   └── ui/
│       ├── message.ts
│       ├── confirm.ts
│       ├── error.ts
│       └── index.ts
│
└── views/
    └── ...
```

但：

> 以当前实际项目结构为准。

不要机械照抄目录。

---



# 五十二、执行顺序

严格按照：

```text
Step 1
扫描现有代码

↓

Step 2
确认已有 UI / Permission 能力

↓

Step 3
设计最小新增能力

↓

Step 4
实现统一 Message

↓

Step 5
实现统一 Confirm

↓

Step 6
实现统一 Error Message

↓

Step 7
实现 Empty / Error 状态组件

↓

Step 8
检查 Permission Directive

↓

Step 9
补充权限 UI 测试

↓

Step 10
补充全局交互测试

↓

Step 11
运行 Type Check

↓

Step 12
运行 Build

↓

Step 13
运行浏览器 Runtime Test

↓

Step 14
输出测试报告
```

---



# 五十三、不要一次修改大量代码

必须：

> 小步修改。

每完成一组能力：

```text
检查 TypeScript
检查 import
检查运行时
```

再继续。

不要一次重构几十个文件。

---



# 五十四、必须记录修改文件

最终报告必须列：

```text
新增：

xxx
xxx

修改：

xxx
xxx

未修改：

Auth Store
Permission Store
Store Store
Request
Router Guard
Backend
Database
```

---



# 五十五、必须进行 Type Check

执行项目当前实际使用的 TypeScript 检查命令。

如果：

```text
npm run type-check
```

存在：

> 执行。

如果没有：

> 根据 package.json 使用实际命令。

不得自己假设脚本名称。

---



# 五十六、必须进行 Build

执行：

```text
npm run build
```

或 package.json 中实际定义的 build 命令。

必须：

```text
PASS
```

---



# 五十七、Runtime 验收清单

必须实际验证：

## 全局消息

```text
成功
警告
错误
信息
```

---



## Confirm

```text
取消
确认
```

---



## Loading

```text
按钮 Loading
页面 Loading
```

---



## Empty

```text
暂无数据
```

---



## Error

```text
加载失败
重新加载
```

---



## Permission

```text
有权限 → 显示
无权限 → 隐藏
```

---



## 业务状态 Disabled

```text
有权限
但业务条件不满足
→ disabled
```

---



## 10002

```text
提示无权限
不退出
```

---



## 10003

```text
提示无门店权限
不退出
```

---



## 10001

```text
清理认证
跳登录
```

---



## Store Switch

```text
切换中
按钮禁用
切换成功
UI 更新
```

---



## Logout

```text
确认
取消
退出
```

---



# 五十八、浏览器测试

至少测试：

```text
Chrome
```

验证：

```text
刷新
前进
后退
切换 Tab
关闭 Tab
切换门店
退出登录
重新登录
```

不能因为全局交互层导致：

```text
白屏
路由死循环
重复弹窗
重复跳转
Token 丢失
CurrentUser 丢失
CurrentStore 丢失
```

---



# 五十九、最终禁止执行

完成 03-10 后：

**不要执行：**

```text
04 Cursor 前端页面设计
05 Cursor 页面代码生成
06 Cursor 前端模块开发
07 Cursor API 联调
08 Cursor 代码审查
09 Cursor 业务规则审查
10 Cursor 页面验收
11 Cursor 问题处理
```

因为这些属于：

> 后续真实业务模块开发阶段。

03-10 完成以后先停下来。

---



# 六十、最终输出报告

执行结束后必须输出：

## 1. 扫描结论

```text
现有 UI 基础：
现有权限体系：
现有错误处理：
现有 Loading：
现有 Confirm：
```

---



## 2. 新增文件

逐项列出。

---



## 3. 修改文件

逐项列出。

---



## 4. 每个文件做了什么

例如：

```text
src/utils/ui/message.ts
统一 Element Plus Message

src/utils/ui/confirm.ts
统一 Confirm

src/components/common/AppEmpty.vue
统一空状态
```

---



## 5. 权限规则

明确：

```text
Router Guard
=
页面访问权限

v-permission
=
按钮/区域 UI 权限
```

---



## 6. 错误规则

明确：

```text
10001
10002
10003
50000
HTTP Error
Network Error
```

各自行为。

---



## 7. Runtime 测试结果

使用：

```text
PASS / FAIL
```

逐项列出。

---



## 8. Type Check

```text
PASS / FAIL
```

---



## 9. Build

```text
PASS / FAIL
```

---



## 10. 后端/数据库

必须明确：

```text
Backend: 未修改
Database: 未修改
```

---



## 11. 边界

明确：

```text
未开发业务模块
未执行 04～11
```

---



# 六十一、最终验收标准

只有同时满足：

```text
全局 Message PASS
Confirm PASS
Loading PASS
Error PASS
Empty PASS
Permission UI PASS
10001 PASS
10002 PASS
10003 PASS
Store Switch PASS
Logout PASS
Refresh PASS
Router PASS
Type Check PASS
Build PASS
```

才能：

> **03-10 PASS**

如果有任何一个核心项失败：

> **03-10 不得 PASS。**

---



# 六十二、最重要的原则

整个 03 前端基础阶段的目标不是：

> “把页面做得越来越多。”

而是建立：

```text
认证
+
权限
+
门店上下文
+
路由
+
ERP Shell
+
Tabs
+
KeepAlive
+
全局交互
+
权限 UI
```

这套稳定基础。

后面真正进入：

```text
客户
预约
开单
耗卡
会员卡
员工
项目
供应链
营销
报表
```

时：

> 不再重复解决这些基础问题。

业务模块只负责：

```text
业务状态
业务规则
业务 API
业务页面
```

基础框架问题到这里收口。

---



# 六十三、执行纪律

再次强调：

1. 先扫描。
2. 不猜代码。
3. 不重复已有能力。
4. 不修改后端。
5. 不修改数据库。
6. 不开发业务模块。
7. 不为了抽象而抽象。
8. 不使用 any。
9. 不在 Request Interceptor 中弹业务 UI。
10. 不把 10002 / 10003 当成登录失效。
11. 不把前端权限当安全边界。
12. 不改变已经 PASS 的 03-1～03-9 核心行为。
13. 完成后必须停止。
14. 等待下一步指令。

现在开始执行 **03-10**。