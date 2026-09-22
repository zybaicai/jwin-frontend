# 03-3-Cursor当前用户 Auth Store 完善 Prompt

## 一、当前阶段定位

你现在进入：

> ERP 前端基础框架建设阶段 —— 03-3 当前用户 Auth Store

上一阶段已经完成：

```text
03-1
统一请求层 + Token 基础设施
```

以及：

```text
03-2
登录 API + 登录页面
```

当前任务不是重新做登录。

当前任务是：

> **把登录成功以后获取到的当前用户 `/me` 信息，正式建立为整个 ERP 前端统一使用的认证上下文。**

---

# 二、本阶段目标

本阶段完成：

```text
Token
+
CurrentUser
+
Auth Store
+
初始化恢复
+
登录状态
+
认证状态清理
```

最终形成：

```text
登录
↓
Token
↓
/me
↓
Auth Store
↓
CurrentUser
↓
整个前端可以统一读取当前用户
```

刷新：

```text
刷新浏览器
↓
读取Token
↓
/me
↓
恢复CurrentUser
```

退出或 Token 失效：

```text
清理Token
+
清理CurrentUser
+
恢复未登录状态
```

---

# 三、本阶段严格禁止越界

本阶段：

## 不开发权限体系

暂时不要实现：

```text
permissionCodes判断
v-permission
按钮权限
动态菜单
动态路由
```

---

## 不开发门店体系

暂时不要实现：

```text
Store Store
门店切换
switch-store
门店选择器
门店缓存刷新
```

---

## 不开发Layout

暂时不要实现：

```text
Sidebar
Header
Breadcrumb
MainLayout
```

---

## 不开发业务模块

禁止：

```text
客户
销售
消费
预约
库存
绩效
营销
报表
```

---

# 四、必须先读取

执行前必须阅读：

```text
cursor/frontend/00-Cursor前端开发总规则.md
cursor/frontend/01-Cursor前端项目初始化Prompt.md
cursor/frontend/02-Cursor前端项目扫描Prompt.md
cursor/frontend/03-Cursor前端基础框架开发Prompt.md
cursor/frontend/03-1-Cursor统一请求层与Token基础设施Prompt.md
cursor/frontend/03-2-Cursor登录API与登录页面开发Prompt.md
```

同时必须扫描当前实际代码。

---

# 五、必须先检查当前项目

重点检查：

```text
src/api/auth.ts
src/stores/
src/types/
src/views/auth/LoginView.vue
src/router/
src/utils/token.ts
src/utils/request.ts
src/utils/api-error.ts
src/utils/auth-event.ts
```

尤其必须读取：

```text
src/api/auth.ts
```

确认 03-2 实际实现。

不要假设 03-2 和 Prompt 完全一样。

---

# 六、必须扫描后端 /me

必须检查实际 Spring Boot 后端：

```text
AuthController
AuthService
当前用户VO
员工信息VO
JWT相关代码
```

确认：

```text
GET /api/v1/auth/me
```

实际返回结构。

---

# 七、当前已知 /me 信息

目前已知 `/me` 包含：

```text
employee
job
jobTypeIds
orgEntityIds
storeId
storeName
storeIds
roles
permissionCodes
dataScope
```

但是：

> 以上属于当前已知业务设计，不代表前端必须机械照抄字段。

必须以实际后端 VO 为最终依据。

---

# 八、Auth Store的职责

Auth Store 只负责：

```text
认证状态
+
当前用户
+
Token关联状态
+
登录
+
初始化
+
清理
```

不负责：

```text
权限业务判断
门店业务
菜单
页面
```

---

# 九、推荐Store结构

如果项目当前使用：

```text
src/stores/auth.ts
```

优先使用。

如果项目采用：

```text
src/stores/modules/auth.ts
```

则遵循现有项目结构。

不要为了本阶段重新设计整个 Store 架构。

---

# 十、Auth Store核心状态

至少需要考虑：

```text
token
currentUser
initialized
loading
```

推荐逻辑状态：

```text
isAuthenticated
```

但：

> 如果可以通过 token + currentUser 推导，就不要额外制造重复状态。

---

# 十一、currentUser类型

必须建立清晰 TypeScript 类型。

根据真实后端 VO 建立。

例如：

```ts
interface CurrentUser {
  employee: EmployeeInfo
  jobTypeIds: number[]
  orgEntityIds: number[]
  storeId?: number
  storeName?: string
  storeIds: number[]
  roles: string[]
  permissionCodes: string[]
  dataScope: string
}
```

注意：

> 这里只是结构示例。

必须以实际后端返回为准。

---

# 十二、员工类型

如果 `/me` 返回：

```text
employee
```

必须建立明确类型。

例如：

```ts
interface EmployeeInfo {
  id: number
  name: string
  jobId?: number
  jobName?: string
}
```

具体字段以真实后端为准。

---

# 十三、不要使用any

禁止：

```ts
const currentUser: any
```

禁止：

```ts
response.data as any
```

如果确实存在第三方类型问题：

> 必须说明原因。

---

# 十四、Auth Store核心方法

建议至少实现：

```text
login()
fetchCurrentUser()
initialize()
clearAuth()
logout()
```

---

# 十五、login()

如果03-2已经实现登录：

不要重新复制一套登录逻辑。

应该检查：

```text
03-2当前实现
```

然后整理成：

```text
Auth Store.login()
```

流程：

```text
login API
↓
保存Token
↓
fetchCurrentUser()
↓
保存currentUser
```

---

# 十六、fetchCurrentUser()

负责：

```text
GET /v1/auth/me
```

然后：

```text
currentUser = response
```

不要在这里做：

```text
权限判断
门店切换
菜单生成
路由生成
```

---

# 十七、initialize()

应用启动时执行。

流程：

```text
initialize()
↓
检查Token
```

如果没有：

```text
initialized = true
isAuthenticated = false
```

如果有：

```text
GET /me
```

成功：

```text
保存currentUser
isAuthenticated = true
initialized = true
```

失败：

```text
根据统一错误机制处理
```

最终必须：

```text
initialized = true
```

避免应用永久卡在初始化状态。

---

# 十八、为什么需要initialized

后续 Router Guard 会依赖：

```text
initialized
```

避免出现：

```text
浏览器刚启动
↓
Auth Store还没初始化
↓
Router立刻判断
↓
误认为未登录
↓
跳转/login
```

所以现在先把：

```text
initialized
```

建立好。

---

# 十九、Token和currentUser关系

必须理解：

```text
Token
=
认证凭证
```

而：

```text
currentUser
=
当前登录用户上下文
```

两者不能混为一谈。

---

# 二十、禁止把currentUser作为认证凭证

不能：

```text
localStorage有currentUser
↓
就认为用户登录
```

正确：

```text
Token存在
↓
调用/me
↓
后端确认
↓
建立currentUser
```

---

# 二十一、currentUser是否持久化

本阶段推荐：

> Token持久化，currentUser以内存状态为主。

浏览器刷新：

```text
Token
↓
/me
↓
重新建立currentUser
```

不要把完整 currentUser 当成安全认证凭证。

如果03-2已经存在currentUser持久化：

> 不要立即大范围修改。

先检查现有实现，再统一。

---

# 二十二、clearAuth()

必须负责：

```text
清理Token
+
清理currentUser
+
恢复认证状态
```

例如：

```text
token = null
currentUser = null
isAuthenticated = false
```

如果项目已经有：

```text
removeToken()
```

必须复用。

不要重复实现localStorage删除。

---

# 二十三、logout()

如果后端存在 logout API：

可以：

```text
调用logout API
↓
finally
↓
clearAuth()
```

如果后端 logout 不存在或03-2已经确定当前阶段不调用：

至少：

```text
clearAuth()
```

不要为了完整性自行创造后端 logout API。

---

# 二十四、Token失效

上一阶段已经建立：

```text
auth-expired
```

事件。

本阶段需要保证：

```text
auth-expired
↓
Auth Store清理currentUser
↓
认证状态变为未登录
```

但：

> Router跳转逻辑仍由认证路由层负责。

不要在 Store 里面到处直接：

```ts
router.push('/login')
```

如果当前项目已经在03-2中实现了监听：

> 检查并复用，不要重复注册。

---

# 二十五、避免重复事件监听

重点检查：

```text
auth-expired
```

不能因为：

```text
页面初始化
Store初始化
App初始化
```

重复注册多个 listener。

否则可能出现：

```text
一次Token失效
↓
多个clearAuth
↓
多个router跳转
```

必须保证监听职责唯一。

---

# 二十六、Auth Store不要处理权限

虽然 currentUser 中有：

```text
permissionCodes
roles
dataScope
```

但是本阶段：

> 只保存这些数据。

不要实现：

```ts
hasPermission()
```

不要实现：

```ts
canAccessRoute()
```

不要实现：

```ts
hasButtonPermission()
```

这些放到后续：

```text
03-4 权限体系
```

---

# 二十七、Auth Store不要处理门店

虽然 currentUser 中有：

```text
storeId
storeIds
storeName
```

本阶段：

> 保存这些字段即可。

不要实现：

```text
switchStore()
```

不要调用：

```text
/v1/auth/switch-store
```

不要创建：

```text
StoreSelector
```

这些属于：

```text
03-5 当前门店体系
```

---

# 二十八、登录页面如何使用Auth Store

如果03-2当前 LoginView 是：

```text
LoginView
↓
直接调用authApi.login()
```

本阶段可以调整为：

```text
LoginView
↓
authStore.login()
↓
authApi.login()
↓
saveToken
↓
fetchCurrentUser
```

页面不应该自己维护完整认证流程。

---

# 二十九、页面职责

LoginView只负责：

```text
输入账号
输入密码
表单校验
调用authStore.login()
展示loading
展示错误
跳转首页
```

不要让 LoginView 自己处理：

```text
Token localStorage
/me
currentUser
权限
```

---

# 三十、认证流程最终结构

最终应该是：

```text
LoginView
    ↓
AuthStore.login()
    ↓
authApi.login()
    ↓
Token
    ↓
AuthStore.fetchCurrentUser()
    ↓
authApi.getCurrentUser()
    ↓
currentUser
```

这样以后：

```text
Router
Layout
Permission
Store
```

都可以读取 Auth Store。

---

# 三十一、应用启动流程

后续 App 初始化应该可以使用：

```text
AuthStore.initialize()
```

流程：

```text
App启动
↓
AuthStore.initialize()
↓
Token?
├── NO → 未登录
│
└── YES
     ↓
    /me
     ↓
   成功
     ↓
currentUser
```

---

# 三十二、异常处理

必须使用上一阶段：

```text
ApiBusinessError
ApiHttpError
```

不要重新创造一套错误体系。

---

# 三十三、10001

如果 `/me` 返回：

```text
10001
```

统一请求层已经负责：

```text
removeToken()
+
auth-expired
```

Auth Store必须最终进入：

```text
未认证状态
```

---

# 三十四、10002 / 10003

本阶段：

```text
10002
10003
```

不能清除Token。

因为：

```text
10002 = 没有权限
10003 = 没有门店权限
```

它们不是：

```text
未登录
```

本阶段只确保：

> Auth Store不会错误地把它们当成 Token 失效。

---

# 三十五、网络错误

如果 `/me`：

```text
网络失败
超时
服务器不可用
```

不要直接把：

```text
isAuthenticated = false
```

当作最终结论。

因为：

> 网络失败 ≠ 用户一定未登录。

应该根据当前项目错误策略处理。

至少不能因为一次网络异常就删除 Token。

---

# 三十六、登录成功后的currentUser

登录完成以后可以暂时在 Home 页面展示：

```text
当前用户
员工ID
岗位
当前门店
```

仅用于验证。

例如：

```text
ERP系统

当前用户：张三
员工ID：10001
岗位：店长
当前门店：杭州XX店
```

这只是调试/验收用途。

---

# 三十七、不要开始做Dashboard

当前首页：

> 只是认证链路验证页。

不要现在开发：

```text
经营数据
销售额
客流
业绩
预约
库存
图表
```

真正首页大屏以后单独开发。

---

# 三十八、测试要求

必须验证：

## 场景1：登录

```text
账号密码正确
↓
login
↓
token
↓
/me
↓
currentUser
```

---

## 场景2：刷新

```text
F5
↓
token存在
↓
/me
↓
currentUser恢复
```

---

## 场景3：没有Token

```text
删除Token
↓
刷新
```

预期：

```text
未认证
```

---

## 场景4：Token失效

模拟：

```text
10001
```

预期：

```text
Token清除
currentUser清除
认证状态变为false
```

---

## 场景5：10002

模拟：

```text
10002
```

预期：

```text
Token不删除
```

---

## 场景6：10003

模拟：

```text
10003
```

预期：

```text
Token不删除
```

---

## 场景7：网络异常

模拟：

```text
/me请求失败
```

确认：

```text
不会因为网络异常直接删除Token
```

具体用户体验根据现有项目错误处理。

---

# 三十九、类型检查

必须执行：

```bash
npm run type-check
```

结果必须：

```text
PASS
```

---

# 四十、Build

执行：

```bash
npm run build
```

必须：

```text
PASS
```

---

# 四十一、Lint

如果项目已有：

```bash
npm run lint
```

执行。

如果没有：

```text
报告：
Lint未配置
```

不要为了本阶段强行增加Lint。

---

# 四十二、最终代码结构

完成后重点检查：

```text
src/
├── api/
│   └── auth.ts
│
├── stores/
│   └── auth.ts
│
├── types/
│   ├── auth.ts
│   └── user.ts
│
├── views/
│   └── auth/
│       └── LoginView.vue
│
├── utils/
│   ├── token.ts
│   ├── request.ts
│   ├── api-error.ts
│   └── auth-event.ts
```

具体目录以当前项目为准。

---

# 四十三、禁止修改后端

本阶段：

> 不允许修改 Spring Boot 后端。

如果发现后端问题：

记录：

```text
BACKEND问题
```

不要为了让前端通过而修改后端。

---

# 四十四、禁止修改数据库

本阶段：

> 不允许修改数据库。

---

# 四十五、禁止执行04～11

特别注意：

本阶段不要执行：

```text
04-Cursor页面设计Prompt.md
05-Cursor页面代码生成Prompt.md
06-Cursor前端模块开发Prompt.md
07-Cursor前端API联调Prompt.md
08-Cursor前端代码审查Prompt.md
09-Cursor前端业务规则审查Prompt.md
10-Cursor页面验收Prompt.md
11-Cursor问题处理Prompt.md
```

原因：

这些 Prompt 是：

> **业务模块开发流程。**

当前还在：

> **ERP前端基础框架建设。**

---

# 四十六、什么时候开始使用04～11

当：

```text
03-1 PASS
03-2 PASS
03-3 PASS
03-4 PASS
03-5 PASS
03-6 PASS
03-7 PASS
03-8 PASS
03-9 PASS
03-10 PASS
```

并完成：

```text
前端基础框架整体验收
```

以后。

例如第一个真正业务模块：

```text
客户管理
```

才执行：

```text
04 页面设计
↓
05 页面代码
↓
06 模块开发
↓
07 API联调
↓
08 代码审查
↓
09 业务规则审查
↓
10 页面验收
```

如果失败：

```text
11 问题处理
```

---

# 四十七、最终报告

Cursor完成后必须输出：

```text
# 03-3 Auth Store开发报告

## 1. 当前项目扫描

## 2. 后端/me实际结构

## 3. 新增文件

## 4. 修改文件

## 5. Auth Store状态

## 6. Auth Store方法

## 7. Login流程

## 8. /me流程

## 9. Token流程

## 10. initialize流程

## 11. auth-expired处理

## 12. 10001处理

## 13. 10002处理

## 14. 10003处理

## 15. 网络异常处理

## 16. 是否修改后端

YES / NO

## 17. TypeCheck

PASS / FAIL

## 18. Build

PASS / FAIL

## 19. Lint

PASS / FAIL / 未配置

## 20. 是否存在问题

## 21. 是否可以进入03-4

YES / NO
```

---

# 四十八、03-3完成标准

只有以下全部满足，才能认为：

> **03-3 PASS**

```text
[ ] Auth Store已经存在
[ ] currentUser类型正确
[ ] login统一进入Auth Store
[ ] login成功保存Token
[ ] login成功获取/me
[ ] currentUser保存成功
[ ] initialize存在
[ ] 浏览器刷新可以恢复currentUser
[ ] clearAuth存在
[ ] Token失效可以清理currentUser
[ ] 没有把10002当成未登录
[ ] 没有把10003当成未登录
[ ] 网络异常不会随意删除Token
[ ] 没有实现权限体系
[ ] 没有实现门店切换
[ ] 没有实现Layout
[ ] 没有开发业务模块
[ ] type-check PASS
[ ] build PASS
```

最终：

```text
03-3 PASS
```

才能进入：

```text
03-4 权限体系
```
