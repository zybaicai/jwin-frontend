# 03-2 Cursor 登录 API 与登录页面开发 Prompt

## 一、当前阶段目标

前一个阶段 `03-1` 已完成：

* Axios 基础请求层
* Token 工具
* 统一响应类型
* ApiBusinessError
* ApiHttpError
* auth-expired 事件
* Authorization 自动携带
* 后端业务 code 处理

现在进入：

> **03-2：登录 API + 登录页面 + 登录成功后的基础登录态建立**

本阶段只完成：

```text
登录页面
    ↓
POST /api/v1/auth/login
    ↓
保存 token
    ↓
GET /api/v1/auth/me
    ↓
保存当前用户基础信息
    ↓
进入 ERP 临时首页
```

暂时不要开发完整权限体系、门店切换、Layout、Sidebar。

---

# 二、必须先阅读

开发前先读取：

```text
frontend/00-Cursor前端开发总规则.md
frontend/02-Cursor前端项目扫描Prompt.md
frontend/03-Cursor前端基础框架开发Prompt.md
```

以及当前已经完成的：

```text
src/types/response.ts
src/utils/request.ts
src/utils/token.ts
src/utils/api-error.ts
src/utils/auth-event.ts
```

还要读取后端真实代码中：

```text
POST /api/v1/auth/login
GET /api/v1/auth/me
```

对应 Controller、DTO、VO、Service。

不要只根据旧 API 文档猜字段。

---

# 三、登录 API 真实定义

已经确认：

```http
POST /api/v1/auth/login
```

请求：

```json
{
  "username": "手机号或员工ID",
  "password": "密码",
  "storeId": 1001
}
```

其中：

```text
username：必填
password：必填
storeId：可选
```

登录成功返回：

```json
{
  "code": 0,
  "message": "success",
  "data": {
    "token": "...",
    "refreshToken": "...",
    "employee": {
      "id": "...",
      "name": "...",
      "jobId": "...",
      "jobName": "..."
    },
    "store": {
      "id": "...",
      "name": "..."
    },
    "roles": [
      {
        "id": "...",
        "name": "..."
      }
    ]
  }
}
```

注意：

> 登录接口不返回完整 permissionCodes / storeIds / dataScope。

所以登录成功后必须继续：

```http
GET /api/v1/auth/me
```

---

# 四、不要误解 refreshToken

当前后端：

```text
refreshToken = token
```

而且没有确认真正的 refresh API。

所以：

> 不实现 refresh token。

只保存：

```text
data.token
```

即可。

是否保存 refreshToken 可以根据类型保留字段，但：

> 不得使用它自动刷新。

---

# 五、创建登录 API 封装

创建：

```text
src/api/auth.ts
```

建议定义：

```text
LoginRequest
LoginVo
CurrentUserVo
```

具体字段必须以实际后端 DTO / VO 为准。

不要凭空增加：

```text
email
avatar
department
permissions
```

之类后端没有确认的字段。

---

# 六、API 返回值规范

从现在开始统一 API 封装规范。

底层 request 可以保留：

```text
AxiosResponse<ApiResponse<T>>
```

但是：

```text
src/api/*.ts
```

对业务层统一返回：

```text
Promise<T>
```

也就是说：

```ts
const loginVo = await authApi.login(form)
```

应该直接得到：

```text
LoginVo
```

而不是：

```text
AxiosResponse
```

更不是：

```text
ApiResponse<LoginVo>
```

API 层负责把：

```text
response.data.data
```

提取出来。

例如概念上：

```ts
async function login(data: LoginRequest): Promise<LoginVo> {
  const response = await request.post<ApiResponse<LoginVo>>(
    '/v1/auth/login',
    data
  )

  return response.data.data
}
```

具体实现必须与 `03-1` 当前 request 封装实际返回类型保持一致。

---

# 七、登录错误必须保留业务码

例如密码错误可能返回：

```text
code != 0
```

比如扫描报告提到：

```text
30002
```

这种情况：

> 不应该被认为是 Token 失效。

不要调用：

```text
removeToken()
auth-expired
```

只有：

```text
10001
```

才属于登录态失效。

登录页面需要能够捕获：

```text
ApiBusinessError
```

并展示后端：

```text
message
```

例如：

```text
用户名或密码错误
```

具体文字以真实后端返回为准。

---

# 八、登录页面

创建：

```text
src/views/LoginView.vue
```

页面只做登录，不做复杂 ERP Layout。

建议包含：

```text
系统名称
账号输入框
密码输入框
登录按钮
错误提示
```

如果后端登录时：

```text
storeId
```

可选，则本阶段不要强行让用户选择门店。

原因：

后端已经存在默认门店逻辑：

```text
上次切店
↓
主门店
↓
storeIds 首店
```

门店完整选择能力留到后面的 Store Context 阶段。

---

# 九、登录表单

表单：

```text
username
password
```

要求：

1. username 必填
2. password 必填
3. 密码输入框使用 password 类型
4. Enter 可以触发登录
5. 登录过程中按钮 loading
6. 防止重复点击
7. 登录失败允许再次输入
8. 不要在前端自行判断“密码正确/错误”
9. 不要把密码打印到 console
10. 不要把密码保存到 localStorage

---

# 十、登录成功流程

点击登录：

```text
LoginView
   ↓
authApi.login()
   ↓
得到 LoginVo
   ↓
setToken(loginVo.token)
   ↓
authApi.getCurrentUser()
   ↓
得到 CurrentUser
   ↓
临时保存当前用户
   ↓
进入首页
```

注意：

> 必须先拿到 `/auth/me`。

不能：

```text
登录成功
↓
直接进入首页
```

因为完整的：

```text
permissionCodes
dataScope
storeIds
```

都在 `/me`。

---

# 十一、当前用户 API

创建：

```text
getCurrentUser()
```

实际接口：

```http
GET /api/v1/auth/me
```

已确认返回至少包含：

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

具体类型以真实后端 VO 为准。

---

# 十二、本阶段的 CurrentUser 暂存方式

注意：

本阶段还没有正式进入：

```text
Auth Store
Permission Store
Store Store
```

所以不要提前把整个状态体系做复杂。

可以建立一个非常轻量的临时登录态 Store，或者按照项目架构认为合理的最小实现。

但是必须遵守：

> **不要提前实现完整权限 Store / Store Store。**

如果 Cursor 判断为了实现登录闭环必须建立最小 auth store，可以建立：

```text
src/stores/auth.ts
```

只负责：

```text
token
currentUser
isLoggedIn
```

不要在这里加入：

```text
permission menu
store switching
data scope
sidebar
route permission
```

这些属于后续阶段。

---

# 十三、Router 最小修改

当前 Router 只有：

```text
/
```

本阶段可以增加：

```text
/login
```

并保留：

```text
/
```

作为临时首页。

暂时不要实现完整 Router Guard。

但要实现最基本的：

```text
/login
```

页面能够打开。

登录成功后：

```text
router.push('/')
```

或者使用项目当前合理的导航方式。

---

# 十四、不要在本阶段实现权限路由

禁止：

```text
permissionCodes
↓
动态生成 Router
```

禁止：

```text
router.beforeEach()
↓
检查权限
```

禁止：

```text
route.meta.permission
```

完整权限路由放到后面的权限阶段。

---

# 十五、登录成功后的临时首页

当前：

```text
HomeView.vue
```

可以暂时继续使用。

登录成功后进入：

```text
/
```

首页可以暂时显示：

```text
ERP 系统首页
当前员工：xxx
当前门店：xxx
```

仅用于验证：

```text
登录
↓
Token
↓
/me
↓
当前用户
↓
页面
```

不要开始设计正式 Dashboard。

---

# 十六、刷新页面的要求

本阶段需要考虑：

```text
登录成功
↓
刷新浏览器
```

Token 仍存在。

但是：

> 不要只根据 localStorage 认为登录成功。

应该：

```text
存在 Token
↓
GET /v1/auth/me
↓
成功 → 恢复登录态
失败 10001 → 清 Token → 登录页
```

这意味着可以做一个非常基础的启动恢复逻辑。

但不要提前做完整 Router Guard。

---

# 十七、auth-expired 处理

03-1 已经建立：

```text
auth-expired
```

本阶段可以开始监听：

```text
window.addEventListener('auth-expired', ...)
```

处理：

```text
清理当前用户
↓
跳转 /login
```

要求：

> 不重复跳转。

不要因为多个并发请求造成：

```text
router.push('/login')
router.push('/login')
router.push('/login')
```

---

# 十八、登录页面 UI 原则

当前只是基础登录页。

不要追求：

```text
复杂动画
复杂背景
复杂营销视觉
```

优先：

```text
清晰
稳定
响应式
PC 管理后台风格
```

因为这是 ERP，不是 C 端营销页面。

Element Plus 可以使用：

```text
ElForm
ElFormItem
ElInput
ElButton
```

---

# 十九、安全要求

禁止：

```text
console.log(password)
console.log(loginForm)
```

禁止：

```text
localStorage.setItem('password', ...)
```

禁止：

```text
localStorage.setItem('currentUser', JSON.stringify(...))
```

如果当前用户需要持久化：

> 优先通过 Token + `/me` 恢复。

本阶段不需要把完整 CurrentUser 写入 localStorage。

---

# 二十、错误处理

登录失败时：

```text
ApiBusinessError
```

应该显示：

```text
error.message
```

但要注意：

```text
10001
```

在登录页面本身通常代表登录接口返回的业务错误，而不是已经存在的登录态失效。

因此：

> 不要简单地因为 code=10001 就无条件执行登录页跳转循环。

登录 API 调用发生在 `/login` 页面时，应避免：

```text
/login
↓
login()
↓
10001
↓
auth-expired
↓
router.push('/login')
↓
/login
```

如果 `03-1` 当前拦截器对所有 10001 都广播 `auth-expired`，需要在登录页面场景中避免循环。

可以通过：

```text
当前已经处于 /login
```

进行保护。

或者采用合理的 auth-event 消费机制。

不要修改后端。

---

# 二十一、编译验证

完成后执行：

```bash
npm run type-check
npm run build
```

如果存在 lint：

```bash
npm run lint
```

同时手动验证：

## 场景 1

访问：

```text
/login
```

能正常显示。

## 场景 2

输入错误账号密码。

确认：

```text
后端错误 message
```

能够展示。

## 场景 3

输入正确账号密码。

确认：

```text
POST /api/v1/auth/login
↓
保存 token
↓
GET /api/v1/auth/me
↓
进入 /
```

## 场景 4

登录成功后刷新浏览器。

确认：

```text
读取 Token
↓
/me
↓
恢复当前用户
```

## 场景 5

手动让 Token 失效。

再次请求：

```text
code=10001
```

确认：

```text
清 Token
↓
auth-expired
↓
/login
```

## 场景 6

登录接口返回业务错误。

确认：

> 不发生无限跳转。

---

# 二十二、最终汇报格式

完成后严格汇报：

## 1. 修改文件

列出全部新增/修改文件。

## 2. 登录 API

说明：

```text
POST /v1/auth/login
GET /v1/auth/me
```

实际如何封装。

## 3. LoginView

说明表单字段、校验、loading、错误处理。

## 4. Token 流程

明确：

```text
login
↓
setToken
↓
/me
↓
currentUser
```

## 5. 刷新恢复

说明浏览器刷新后如何恢复登录态。

## 6. auth-expired

说明如何避免：

```text
/login → 10001 → /login
```

循环。

## 7. Router

说明增加了哪些路由。

## 8. Store

如果建立了 auth store：

明确列出职责。

确认没有提前加入：

```text
Permission Store
Store Store
Menu
Sidebar
```

## 9. 测试结果

给出：

```text
npm run type-check
npm run build
npm run lint
```

实际结果。

## 10. 未完成内容

明确列出：

```text
完整权限体系
门店切换
Permission Store
Store Store
Router Guard
MainLayout
Sidebar
Header
Breadcrumb
正式 Dashboard
业务模块
```

完成后停止。

**不要自动进入 03-3。**
