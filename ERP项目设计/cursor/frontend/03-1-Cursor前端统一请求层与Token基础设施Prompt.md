# 03-1 Cursor 前端统一请求层与 Token 基础设施开发 Prompt

## 一、你的角色

你现在是本项目的高级 Vue 3 + TypeScript 前端工程师。

当前项目：

* Vue 3.5
* TypeScript 6
* Vite 8
* Element Plus
* Pinia
* Vue Router
* Axios

后端：

* Spring Boot 2.7.18
* Java 8
* Spring MVC
* MyBatis-Plus
* SQL Server

ERP 后端真实 API 已经开发完成。

本阶段只负责：

> **建立前端统一 HTTP 请求层 + Token 基础设施。**

严禁提前开发登录页面、权限 Store、门店 Store、Layout 或任何业务页面。

---

# 二、必须先阅读的内容

开发前必须先阅读：

1. `ERP项目设计/` 下相关设计文档
2. `frontend/00-Cursor前端开发总规则.md`
3. `frontend/02-Cursor前端项目扫描Prompt.md`
4. 当前项目 `package.json`
5. 当前 `src/utils/request.ts`
6. 当前 `src/main.ts`
7. 当前 `src/App.vue`
8. 当前 `src/router/index.ts`

同时必须以刚刚完成的《ERP前端项目扫描报告》为后端真实事实依据。

不要重新猜测后端接口。

---

# 三、后端统一响应必须以真实代码为准

后端成功响应：

```json
{
  "code": 0,
  "message": "success",
  "data": {},
  "requestId": "..."
}
```

业务异常：

```json
{
  "code": 10001,
  "message": "...",
  "data": null,
  "requestId": "..."
}
```

当前已确认：

```text
10001 = 未登录 / Token 无效 / 登录失效

10002 = 无权限

10003 = 无门店权限

50000 = 系统异常
```

特别注意：

## 后端未登录和无权限不是通过 HTTP 401/403 返回

真实后端行为：

```text
未登录：
HTTP 200
code = 10001

无权限：
HTTP 200
code = 10002

无门店权限：
HTTP 200
code = 10003

系统异常：
HTTP 500
code = 50000
```

因此：

> **前端不得只通过 HTTP status 判断业务异常。**

必须解析后端统一响应中的 `code`。

---

# 四、第一步：检查当前 request.ts

先读取当前：

```text
src/utils/request.ts
```

确认当前 Axios 实例的实现。

不要直接推翻现有代码。

在现有结构基础上进行最小必要改造。

---

# 五、建立统一 API Response 类型

建议在：

```text
src/types/
```

建立统一响应类型。

例如：

```ts
export interface ApiResponse<T = unknown> {
  code: number
  message: string
  data: T
  requestId?: string
}
```

如果实际后端响应类型存在差异，以实际代码为准。

要求：

1. 不使用 `any` 作为统一响应类型。
2. 泛型支持不同 API 的 data 类型。
3. `requestId` 保留。
4. 分页结构后续单独定义，本阶段不要混进统一响应类型。

---

# 六、建立 Token 管理工具

建议：

```text
src/utils/token.ts
```

集中管理 Token。

至少提供：

```ts
getToken()
setToken(token)
removeToken()
hasToken()
```

具体命名可以根据项目现有代码规范调整。

不要在业务代码中到处直接：

```ts
localStorage.getItem(...)
localStorage.setItem(...)
localStorage.removeItem(...)
```

Token 存储必须集中。

---

# 七、Token 存储要求

当前后端：

```text
POST /api/v1/auth/login
```

成功后：

```text
data.token
```

作为 JWT。

请求头：

```http
Authorization: Bearer {token}
```

当前没有真正独立的 refresh token 流程。

虽然 LoginVo 返回：

```text
refreshToken
```

但当前：

```text
refreshToken = token
```

且目前没有独立 refresh API。

因此本阶段：

> **不要实现自动刷新 Token。**

只实现 Token 保存、读取、删除和请求自动携带。

---

# 八、Axios Request Interceptor

修改：

```text
src/utils/request.ts
```

增加 request interceptor。

如果存在 Token：

```http
Authorization: Bearer {token}
```

自动加入请求头。

要求：

1. 所有 API 默认自动携带 Token。
2. 登录接口本身没有 Token 也必须能够正常调用。
3. 不要让没有 Token 的请求失败。
4. 不要在每个 API 文件里重复写 Authorization。
5. 不要把 Token 写死。
6. 不要在业务页面里手动拼 Bearer Token。

最终业务 API 应该可以直接：

```ts
request.post('/api/v1/auth/login', data)
```

而不是：

```ts
axios.post(..., {
  headers: {
    Authorization: ...
  }
})
```

---

# 九、Axios Response Interceptor

这是本阶段最重要的部分。

必须同时处理：

## 1. HTTP 层错误

例如：

```text
500
502
503
网络异常
timeout
```

但是：

> HTTP status 不是当前 ERP 的主要业务鉴权判断依据。

---

## 2. 业务 code

必须读取：

```ts
response.data.code
```

进行判断。

处理规则：

### code = 0

正常返回。

---

### code = 10001

表示：

```text
未登录 / Token 无效 / 登录失效
```

处理：

```text
清除 Token
↓
通知前端登录态失效
↓
跳转登录页
```

但是注意：

本阶段还没有登录页面和 auth store。

所以不要提前创建复杂登录业务。

可以先设计一个统一的：

```text
auth-expired
```

处理机制。

例如：

```ts
window.dispatchEvent(new CustomEvent('auth-expired'))
```

或者使用项目认为更合理的基础设施方案。

要求：

> 本阶段只建立机制，不实现 LoginView。

---

### code = 10002

表示：

```text
无权限
```

处理原则：

```text
不要删除 Token
不要跳登录页
```

应该进入统一业务异常处理。

可以暂时：

```text
throw ApiBusinessError
```

由上层后续统一展示。

不要在 request.ts 中强行绑定具体业务页面。

---

### code = 10003

表示：

```text
无门店权限
```

处理原则：

```text
不要删除 Token
不要跳登录页
```

同样进入统一业务异常处理。

后续门店上下文建立后，再由上层决定如何处理。

---

### code = 50000

表示：

```text
系统异常
```

进入统一错误处理。

不要在底层直接弹出大量 Element Plus Message。

本阶段重点是：

> **统一识别 + 标准化错误。**

具体 UI 展示策略后续统一设计。

---

# 十、不要让 request.ts 变成“大杂烩”

request.ts 的职责主要是：

```text
创建 Axios 实例
↓
request interceptor
↓
response interceptor
↓
统一响应处理
↓
统一错误转换
```

不要把：

* 登录业务
* 用户业务
* 门店业务
* 权限业务
* 页面跳转业务
* 具体业务 API

全部写进 request.ts。

---

# 十一、建议建立统一 API Error

可以建立：

```text
src/utils/api-error.ts
```

例如定义一个：

```ts
ApiBusinessError
```

至少包含：

```text
code
message
requestId
data
```

例如：

```ts
class ApiBusinessError extends Error {
  code: number
  requestId?: string
  data?: unknown
}
```

具体实现以项目风格为准。

目的：

让上层可以这样判断：

```ts
try {
  await xxx()
} catch (error) {
  if (error instanceof ApiBusinessError) {
    // 根据业务 code 处理
  }
}
```

而不是到处自己解析：

```ts
response.data.code
```

---

# 十二、登录失效事件

因为：

```text
10001
```

需要让整个前端知道：

> 当前 Token 已经失效。

本阶段可以建立统一事件机制。

例如：

```ts
AUTH_EXPIRED_EVENT
```

触发：

```ts
window.dispatchEvent(...)
```

后续 Auth Store 可以监听。

但是：

> 不要现在创建 Auth Store。

后续：

```text
03-2
```

再建立：

```text
auth store
current user
login/logout
```

---

# 十三、防止重复触发登录失效

考虑这种情况：

一个页面同时发出：

```text
GET A
GET B
GET C
GET D
```

Token 全部失效。

不能出现：

```text
跳登录
跳登录
跳登录
跳登录
```

应该有一个简单的防重复机制，例如：

```ts
let authExpiredHandled = false
```

或者更合理的机制。

要求：

> 同一个 Token 失效周期内只触发一次 auth-expired。

当新的 Token 建立后，后续阶段再重置状态。

本阶段只做好基础设施。

---

# 十四、不要实现 Token 自动刷新

再次强调：

当前后端：

```text
refreshToken == token
```

没有确认真正 refresh API。

所以：

禁止实现：

```text
401
↓
refresh token
↓
重新请求
```

也不要自己发明：

```text
/api/v1/auth/refresh
```

---

# 十五、API 文件暂时只建立认证 API 类型，不实现登录页面

本阶段可以考虑建立：

```text
src/api/auth.ts
```

但只允许做：

```ts
login()
```

等后续基础 API 封装。

如果你认为 login API 应该放到 03-2，也可以暂时不创建。

重要的是：

> 不要开发 LoginView。

---

# 十六、不要提前创建这些内容

本阶段禁止开发：

```text
src/views/LoginView.vue
```

禁止开发：

```text
src/layouts/MainLayout.vue
```

禁止开发：

```text
src/stores/auth.ts
src/stores/user.ts
src/stores/permission.ts
src/stores/store.ts
```

禁止开发：

```text
Sidebar
Header
Breadcrumb
StoreSelector
PermissionDirective
RouterGuard
```

这些全部放到后续阶段。

---

# 十七、当前目录目标

完成后，至少应该形成类似：

```text
src/
├── api/
│
├── types/
│   └── response.ts
│
├── utils/
│   ├── request.ts
│   ├── token.ts
│   └── api-error.ts
│
├── router/
├── stores/
├── views/
└── ...
```

如果你认为文件命名应该不同，可以根据现有工程规范调整。

但职责必须保持清晰。

---

# 十八、开发原则

必须遵守：

## 1. 不修改后端

本阶段只修改前端。

---

## 2. 不改变后端 API

严格使用：

```text
/api/v1
```

不要根据设计文档旧示例写成：

```text
/api
```

---

## 3. 不假设 HTTP 401/403

必须依据：

```text
code=10001
code=10002
code=10003
```

---

## 4. 不实现 refresh token

当前没有真实 refresh API。

---

## 5. 不写业务页面

本阶段只是基础设施。

---

## 6. TypeScript 类型优先

禁止为了快速通过编译大量使用：

```ts
any
```

---

# 十九、开发完成后必须自行验证

至少执行：

```bash
npm run build
```

如果项目存在：

```bash
npm run type-check
```

也执行。

如果存在 lint：

```bash
npm run lint
```

也执行。

---

# 二十、最终汇报格式

完成后不要直接开始下一个阶段。

请严格按照以下格式汇报：

## 1. 修改文件

```text
src/xxx
src/xxx
```

## 2. 每个文件修改内容

说明职责。

## 3. Token 流程

说明：

```text
Token 从哪里保存
Token 从哪里读取
Token 如何自动加入 Authorization
Token 如何删除
```

## 4. 业务 code 处理

明确说明：

```text
0
10001
10002
10003
50000
```

分别如何处理。

## 5. auth-expired 机制

说明如何防止重复触发。

## 6. HTTP 异常处理

说明 HTTP 401/403/500 分别如何处理。

特别确认：

> 是否仍然错误地把 401/403 当成主要鉴权依据。

## 7. TypeScript 类型

列出新增的统一响应类型和错误类型。

## 8. 编译结果

给出：

```text
npm run build
```

实际结果。

## 9. 是否修改后端

必须明确：

```text
没有
```

或者列出实际修改。

## 10. 当前未完成内容

明确说明以下内容仍未开发：

```text
登录页面
Auth Store
CurrentUser
Permission Store
Store Store
Router Guard
MainLayout
Sidebar
Header
Breadcrumb
```

完成后停止。

**不要继续执行 03-2。**
