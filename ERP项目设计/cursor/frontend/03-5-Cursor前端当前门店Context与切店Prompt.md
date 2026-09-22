# 03-5 Cursor前端当前门店 Context 与切店开发 Prompt

# 一、任务名称

03-5：当前门店 Context 与切店能力建设。

---

# 二、当前项目阶段

当前 ERP 前端基础建设进度：

```text
03-1 统一请求层 + Token 基础设施    PASS
03-2 登录 API + 登录页面            PASS
03-3 Auth Store                     PASS
03-4 前端权限体系                   PASS
03-5 当前门店 Context + 切店         ← 本次任务
03-6 Router Guard
03-7 MainLayout
03-8 Sidebar / Menu
03-9 Header / StoreSelector / Breadcrumb
03-10 全局交互与其他基础能力
```

本次只执行：

> **03-5 当前门店 Context + 切店**

---

# 三、严格禁止

本次禁止执行：

```text
03-6 Router Guard
03-7 MainLayout
03-8 Sidebar / Menu
03-9 Header
03-9 StoreSelector UI
03-9 Breadcrumb
03-10
04～11
任何业务模块
```

禁止开始：

```text
客户
销售
消费
预约
会员卡
项目
价格
库存
绩效
报表
```

也禁止修改后端和数据库。

---



# 四、任务目标

本阶段要解决的问题只有一个：

> 建立 ERP 前端统一的“当前门店上下文”，并完成可靠的切店能力。

当前用户可能拥有多个允许操作的门店。

后端 `/me` 已经提供：

```text
storeId
storeName
storeIds
```

当前业务门店实际上由：

```text
JWT storeId
```

决定。

因此：

> 前端不能通过修改一个 `currentStoreId` 变量来完成切店。

真正切店必须调用后端：

```text
POST /api/v1/auth/switch-store
```

成功后获得新的 Token。

---



# 五、必须先扫描当前项目

开始修改前，必须先阅读：

```text
ERP项目设计/cursor/frontend/00-Cursor前端开发总规则.md
ERP项目设计/cursor/frontend/03-3-Cursor当前用户Auth Store完善Prompt.md
ERP项目设计/cursor/frontend/03-4-Cursor前端权限体系Prompt.md
```

同时扫描：

```text
src/stores/auth.ts
src/stores/permission.ts
src/types/auth.ts
src/types/user.ts
src/api/auth.ts
src/utils/token.ts
src/utils/request.ts
src/utils/api-error.ts
src/utils/auth-event.ts
src/main.ts
src/router/index.ts
```

还必须扫描后端真实实现：

```text
POST /api/v1/auth/switch-store
GET  /api/v1/auth/me
```

确认：

- Request DTO
- Response VO
- Token 更新方式
- storeId 校验方式
- 错误码
- 当前 JWT storeId 的来源

不要根据 Prompt 猜接口。

---



# 六、已经确认的后端事实

当前后端已经确认：

## 1. `/me`

```text
GET /api/v1/auth/me
```

返回：

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

其中：

```text
storeId
```

代表：

> 当前登录 Token 对应的业务门店。

---



# 七、切店 API

当前后端切店接口：

```text
POST /api/v1/auth/switch-store
```

Request：

```json
{
  "storeId": 123
}
```

成功：

> 后端返回新的 Token。

当前后端的设计是：

```text
旧 Token
   ↓
switch-store
   ↓
新 Token
```

新的 Token 内部携带新的：

```text
storeId
```

因此：

> 切店成功后，必须把新 Token 当成新的认证凭证保存下来。

---



# 八、切店的正确完整流程

必须实现：

```text
用户选择目标门店
        ↓
检查目标门店是否属于当前用户 storeIds
        ↓
防止重复提交
        ↓
POST /auth/switch-store
        ↓
后端校验门店权限
        ↓
成功返回新 Token
        ↓
保存新 Token
        ↓
重新 GET /auth/me
        ↓
得到新的 storeId / storeName / storeIds
        ↓
更新 Auth Store currentUser
        ↓
更新 Store Context
        ↓
清理旧门店相关前端缓存
        ↓
完成切店
```

必须保证：

> 前端 Store Context 的当前门店，最终以新的 `/me` 返回结果为准。

不能只相信：

```text
switch-store
```

接口返回成功以后，直接：

```text
currentStoreId = selectedStoreId
```

就结束。

---



# 九、建立 Current Store Store

新增：

```text
src/stores/store.ts
```

使用 Pinia。

这个 Store 是：

> 当前门店运行时上下文。

---



# 十、Store Store 职责

Store Store 只负责：

```text
当前门店
可用门店
切店状态
切店流程
```

建议包含：

```text
currentStoreId
currentStoreName
availableStoreIds
initialized
switching
```

如果当前项目有合适的 Store 类型，可以复用。

不要重复创建 Auth User。

---



# 十一、Auth Store 与 Store Store 的关系

必须避免两个 Store 互相维护两套“当前门店”。

正确关系：

```text
Auth Store
│
└── currentUser
      │
      ├── storeId
      ├── storeName
      └── storeIds
             │
             ↓
       Store Context
             │
             ├── currentStoreId
             ├── currentStoreName
             └── availableStoreIds
```

Store Store 可以从 Auth Store 当前用户初始化。

---



# 十二、最重要的原则：谁是最终真相？

当前门店最终真相是：

```text
后端 JWT storeId
        ↓
GET /auth/me
        ↓
Auth Store currentUser.storeId
```

Store Store 是：

> 前端对当前门店上下文的便捷封装。

因此不能出现：

```text
Auth Store:
storeId = 1

Store Store:
currentStoreId = 2
```

这种状态。

---



# 十三、初始化

提供：

```ts
initialize()
```

初始化逻辑：

```text
authStore.currentUser
        ↓
有用户
        ↓
读取 storeId
storeName
storeIds
        ↓
初始化 Store Context
```

如果：

```text
currentUser = null
```

则：

```text
currentStoreId = null
currentStoreName = null
availableStoreIds = []
initialized = true
```

---



# 十四、只有一个门店

如果：

```text
storeIds = [100]
```

当前：

```text
storeId = 100
```

则：

```text
currentStoreId = 100
```

不需要人为创建“切店”。

后续 Header 虽然可以展示当前门店，但本阶段不做 UI。

---



# 十五、多个门店

例如：

```text
storeIds = [
  100,
  101,
  102
]
```

当前：

```text
storeId = 101
```

则：

```text
currentStoreId = 101
availableStoreIds = [100,101,102]
```

不能默认：

```text
currentStoreId = storeIds[0]
```

必须尊重 `/me` 返回的：

```text
storeId
```

---



# 十六、storeIds 与 storeName 的边界

当前 `/me` 只有：

```text
storeId
storeName
storeIds
```

如果 `storeIds` 是 ID 数组，而没有返回完整：

```text
[
  {
    id,
    name
  }
]
```

则：

> 不要擅自给每个 storeId 编造 storeName。

Store Context 当前可以保存：

```text
currentStoreId
currentStoreName
availableStoreIds
```

如果后续 Header 需要显示所有门店名称，再通过真实门店 API 获取。

本阶段不要自行补造门店名称数据。

---



# 十七、禁止重新请求门店列表

本阶段不要为了初始化 Store Context 而调用：

```text
GET /stores
```

如果：

```text
/me
```

已经提供：

```text
storeIds
storeId
storeName
```

就直接使用。

门店列表 API 后续如果确实需要：

> 在 Header / StoreSelector 阶段根据真实需求接入。

---



# 十八、切店方法

Store Store 应提供类似：

```ts
switchStore(storeId)
```

具体命名可按照当前项目规范调整。

职责：

```text
switchStore(targetStoreId)
```

---



# 十九、切店前校验

切店前必须检查：

```text
targetStoreId ∈ availableStoreIds
```

如果不属于：

> 不发送 API 请求。

直接返回明确的业务错误或抛出统一错误。

禁止：

```text
用户输入任意 storeId
        ↓
直接请求 switch-store
```

前端应该先做一次 UX 层校验。

但是：

> 后端仍然必须是最终权限校验者。

---



# 二十、当前门店再次点击

如果：

```text
targetStoreId === currentStoreId
```

则不应该重新请求切店 API。

直接视为：

```text
no-op
```

或者返回：

```text
already current store
```

具体方式保持项目风格。

---



# 二十一、切店防重复提交

切店过程中：

```text
switching = true
```

再次调用：

```text
switchStore()
```

必须阻止重复请求。

不能出现：

```text
点击门店 A
点击门店 B
点击门店 C
```

然后同时发：

```text
switch-store A
switch-store B
switch-store C
```

---



# 二十二、并发切店

必须保证同一时间最多只有一个切店请求。

建议：

```text
switching === true
```

时直接拒绝新的切店操作。

本阶段不需要实现复杂队列。

简单可靠即可。

---



# 二十三、切店成功

假设：

```text
当前门店 = 100
目标门店 = 101
```

执行：

```text
POST /auth/switch-store
```

成功后：

```text
获得新 Token
```

立即：

```text
setToken(newToken)
```

然后：

```text
GET /auth/me
```

重新获取当前用户。

最终：

```text
currentUser.storeId === 101
```

才认为切店成功。

---



# 二十四、切店不能只看 switch-store 成功

禁止：

```text
switch-store 200
 ↓
直接认为 currentStoreId = targetStoreId
```

必须：

```text
switch-store
 ↓
保存新 Token
 ↓
/me
 ↓
确认 storeId
 ↓
更新 Auth Store
 ↓
更新 Store Context
```

---



# 二十五、切店成功后的权限

重新 `/me` 后：

```text
permissionCodes
roles
dataScope
storeIds
```

都有可能重新返回。

因此切店成功后：

> 必须让 Permission Store 同步当前用户的新权限上下文。

但要注意避免循环依赖。

推荐：

```text
switchStore
 ↓
newToken
 ↓
authStore.fetchCurrentUser()
 ↓
permissionStore.initialize()
 ↓
storeContext.initialize()
```

具体实现以项目现有依赖结构为准。

不要让：

```text
Auth Store
 ↔
Permission Store
 ↔
Store Store
```

形成循环依赖。

---



# 二十六、切店后的 currentUser

新的 `/me` 返回后：

```text
authStore.currentUser
```

必须整体更新。

不要只修改：

```text
currentUser.storeId
```

例如：

```ts
currentUser.storeId = targetStoreId
```

这是不完整的。

必须以：

```text
GET /me
```

的新结果整体替换当前用户。

因为切店后可能同时变化：

```text
storeId
storeName
storeIds
permissionCodes
roles
dataScope
```

---



# 二十七、切店失败

如果：

```text
switch-store
```

失败：

必须：

```text
保留原 Token
保留原 currentUser
保留原 currentStore
```

不能因为切店失败：

```text
clearAuth()
```

也不能：

```text
removeToken()
```

除非后端明确返回：

```text
10001
```

代表 Token 失效。

---



# 二十八、10003 切店失败

如果目标门店不属于当前用户范围，后端可能返回：

```text
10003
```

正确行为：

```text
10003
 ↓
ApiBusinessError
 ↓
Token 保留
 ↓
currentUser 保留
 ↓
currentStore 保留
```

不能退出登录。

这与 03-3 / 03-4 已验收规则一致。

---



# 二十九、10001 切店失败

如果切店过程中：

```text
switch-store
```

返回：

```text
10001
```

则沿用现有请求层：

```text
removeToken()
auth-expired
```

然后认证状态进入未登录。

Store Context 必须最终清空：

```text
currentStoreId = null
currentStoreName = null
availableStoreIds = []
```

不要保留旧门店上下文。

---



# 三十、网络异常

如果切店请求：

```text
timeout
connection refused
network error
```

则：

```text
Token 保留
currentUser 保留
currentStore 保留
```

不能因为网络失败而：

```text
clearAuth()
```

---



# 三十一、最重要的失败回滚原则

切店过程中：

```text
旧门店 = A
目标门店 = B
```

如果失败：

```text
最终仍然必须是 A
```

不能出现：

```text
Auth Store = A
Store Store = B
```

也不能：

```text
Token = A
currentStore = B
```

更不能：

```text
Token = B
currentUser = A
```

因此：

> 切店是一个完整的上下文更新流程，不是简单修改一个响应式变量。

---



# 三十二、旧门店数据缓存

切店成功后，必须考虑清理旧门店业务缓存。

当前阶段：

> 项目还没有真正业务模块，因此不要创建假的业务缓存。

只需要预留清晰的机制，例如：

```text
storeContextChanged
```

或者统一的 Store Context 更新点。

后续业务模块开发时：

```text
切店成功
 ↓
清理客户列表缓存
清理项目价格缓存
清理员工缓存
清理预约缓存
清理库存缓存
...
```

本阶段不提前实现这些业务缓存。

---



# 三十三、禁止使用 X-Store-Id

当前后端已经明确：

> 当前业务门店来自 JWT storeId。

所以本阶段不要在 Axios 中新增：

```http
X-Store-Id
```

也不要修改请求拦截器，去自动添加：

```text
X-Store-Id: currentStoreId
```

这是错误方向。

正确方式：

```text
当前门店
 ↓
switch-store
 ↓
新 Token
 ↓
JWT storeId
 ↓
后端识别当前门店
```

---



# 三十四、Token 更新规则

切店成功后：

```text
newToken
```

必须使用现有：

```text
setToken()
```

统一保存。

不要自己：

```text
localStorage.setItem(...)
```

不要创建第二个 Token Key。

继续使用：

```text
erp_access_token
```

---



# 三十五、不要实现 Refresh Token

当前后端：

```text
refreshToken
```

虽然存在，但当前实际与 Token 相同，并没有独立 refresh API。

因此本阶段：

> 不实现 refresh token。

---



# 三十六、切店 API 封装

如果：

```text
src/api/auth.ts
```

已有 Auth API：

可以继续放：

```text
switchStore()
```

例如：

```ts
authApi.switchStore(storeId)
```

不要为了一个接口额外创建没有必要的：

```text
src/api/store-auth.ts
```

除非当前项目结构已经明确需要。

API 层只负责：

```text
请求
响应类型
```

业务流程放 Store。

---



# 三十七、类型要求

根据真实后端 API 建立：

```text
SwitchStoreRequest
SwitchStoreResponse
```

但必须：

> 以真实后端 DTO / VO 为准。

不要猜返回结构。

如果返回值实际只是：

```text
token
```

就不要虚构：

```text
store
employee
permissions
```

---



# 三十八、Store Context 类型

建议定义明确类型，例如：

```ts
currentStoreId: number | null
currentStoreName: string | null
availableStoreIds: number[]
initialized: boolean
switching: boolean
```

如果后端实际 ID 类型与当前工程不同：

> 以实际项目类型为准。

不要为了 Prompt 强行转换。

---



# 三十九、Store Context 不负责 UI

本阶段：

禁止创建：

```text
StoreSelector.vue
StoreDropdown.vue
Header.vue
```

禁止修改：

```text
MainLayout
Sidebar
Header
Breadcrumb
```

如果当前项目没有这些组件：

> 不创建。

03-9 再做。

---



# 四十、Store Context 不负责 Router

禁止：

```text
router.push()
router.replace()
router.beforeEach()
```

Store Context 不应该决定：

```text
登录页
首页
403
404
```

Router Guard 是：

```text
03-6
```

后续独立阶段。

---



# 四十一、Store Context 与 Permission Store

切店以后，重新 `/me`。

由于：

```text
permissionCodes
roles
dataScope
```

可能变化，因此必须同步权限状态。

但禁止循环依赖。

推荐思路：

```text
Store Store
   ↓
Auth Store
   ↓
Permission Store
```

或者通过明确的 orchestrator 进行：

```text
switchStore
 ↓
authStore.fetchCurrentUser()
 ↓
permissionStore.initialize()
 ↓
storeStore.initialize()
```

以当前项目实际代码结构选择最简单可靠方案。

---



# 四十二、不要修改 Auth Store 的职责边界

可以为了完成切店流程：

```text
调用 authStore.fetchCurrentUser()
```

但不要让 Auth Store 变成：

```text
Auth Store
├── 登录
├── Token
├── 权限
├── 门店
├── 菜单
├── Router
├── UI
└── 业务
```

Auth Store 仍然只负责：

```text
认证
用户
Session
```

---



# 四十三、切店状态

至少应该有：

```text
switching
```

用于：

```text
防重复提交
```

并且必须：

```text
try
  ...
finally
  switching = false
```

不能因为异常导致：

```text
switching 永久 true
```

---



# 四十四、切店流程建议

推荐逻辑：

```text
switchStore(targetStoreId)
│
├── 当前门店？
│      └── return
│
├── switching？
│      └── return / reject
│
├── 是否属于 availableStoreIds？
│      └── reject
│
├── switching = true
│
├── POST switch-store
│
├── setToken(newToken)
│
├── GET /me
│
├── 更新 Auth Store
│
├── 同步 Permission Store
│
├── 同步 Store Context
│
└── finally switching = false
```

---



# 四十五、并发与异常重点

必须特别防止：

```text
switch A
 ↓
new token A
 ↓
/me A
```

与此同时：

```text
switch B
 ↓
new token B
 ↓
/me B
```

造成最终状态混乱。

简单方案：

> `switching` 锁住整个流程。

一次切店流程结束后，才允许下一次。

---



# 四十六、切店成功后的最终一致性

假设：

```text
targetStoreId = 101
```

最终至少满足：

```text
authStore.currentUser.storeId === 101

storeStore.currentStoreId === 101

token != oldToken
```

并且：

```text
permissionStore
```

已经来自新的：

```text
/me
```

---



# 四十七、测试要求

完成后必须测试。

## 测试 1：单门店

用户只有一个门店：

```text
storeIds = [A]
currentStoreId = A
```

验证：

```text
initialize()
```

正确。

---



## 测试 2：多门店

用户：

```text
storeIds = [A,B,C]
currentStoreId = B
```

验证：

```text
currentStoreId = B
availableStoreIds = [A,B,C]
```

不能默认选 A。

---



# 四十八、测试 3：切到允许门店

真实测试：

```text
当前门店 A
 ↓
切换 B
```

验证：

```text
switch-store
 ↓
新 Token
 ↓
/me
 ↓
storeId = B
```

并确认：

```text
Auth Store = B
Store Store = B
```

---



# 四十九、测试 4：切回原门店

```text
B → A
```

必须成功。

验证：

```text
storeId = A
```

---



# 五十、测试 5：当前门店重复切换

例如当前：

```text
A
```

调用：

```text
switchStore(A)
```

验证：

> 不发新的 switch-store 请求。

---



# 五十一、测试 6：非法门店

传入：

```text
999999
```

如果不在：

```text
availableStoreIds
```

则：

> 前端不发送 API 请求。

---



# 五十二、测试 7：后端 10003

如果目标门店在前端状态之外，但后端返回：

```text
10003
```

验证：

```text
Token 保留
currentUser 保留
currentStore 保留
```

不能退出登录。

---



# 五十三、测试 8：网络异常

切店 API 网络失败：

验证：

```text
Token 保留
currentUser 保留
currentStore 保留
switching 最终恢复 false
```

---



# 五十四、测试 9：10001

模拟或真实触发：

```text
10001
```

验证：

```text
Token 清除
Auth Store 清理
Permission Store 清理
Store Context 清理
```

最终：

```text
currentStoreId = null
currentStoreName = null
availableStoreIds = []
```

---



# 五十五、测试 10：切店后权限变化

如果真实账号切换门店后：

```text
/me
```

权限发生变化，则验证：

```text
Permission Store
```

使用的是新的：

```text
permissionCodes
roles
dataScope
```

而不是旧门店的数据。

如果当前真实测试账号切店后权限没有变化：

> 不要人为制造变化。

只验证重新执行 `/me` 并重新同步。

---



# 五十六、测试 11：切店防重复

快速连续调用：

```text
switchStore(A)
switchStore(B)
switchStore(C)
```

验证：

> 同一时间只有一个请求执行。

---



# 五十七、测试 12：Logout

退出后：

```text
Auth Store
Permission Store
Store Context
```

全部清空。

---



# 五十八、真实环境验收

必须使用当前真实测试账号：

```text
13800000000
```

后端：

```text
127.0.0.1:12002
```

前端：

```text
http://localhost:5173
```

如果测试账号只有一个可用门店：

> 不要伪造多门店数据。

可以使用单元/Store 层测试验证：

```text
多门店
非法门店
并发
```

真实切店必须使用后端真实允许的门店。

---



# 五十九、不要修改业务页面

如果为了测试需要页面入口：

> 可以建立最小的临时开发/验收测试入口。

但不能开始开发：

```text
Header
StoreSelector
MainLayout
业务页面
```

测试入口后续应明确清理。

---



# 六十、最终代码质量要求

禁止：

```ts
any
```

禁止：

```text
重复 Token 存储
重复 /me 请求
重复切店逻辑
X-Store-Id
自行推导 storeName
自行推导门店权限
前端数据权限过滤
```

---



# 六十一、最终验收标准

以下全部满足才算 PASS：

## Store Context

- [ ] Store Store 已建立
- [ ] currentStoreId 正确
- [ ] currentStoreName 正确
- [ ] availableStoreIds 正确
- [ ] initialized 正确
- [ ] switching 正确



## 初始化

- [ ] 来源为 Auth Store currentUser
- [ ] 单门店正确
- [ ] 多门店正确
- [ ] 无用户正确清空



## 切店

- [ ] 校验 availableStoreIds
- [ ] 当前门店不重复请求
- [ ] 防重复提交
- [ ] 调用真实 switch-store
- [ ] 保存新 Token
- [ ] 重新调用 /me
- [ ] 整体更新 currentUser
- [ ] 更新 Store Context
- [ ] 同步 Permission Store



## 失败

- [ ] 10003 不退出
- [ ] 网络异常不退出
- [ ] 普通切店失败保留旧上下文
- [ ] 10001 清理完整认证上下文



## 架构

- [ ] Auth Store 不被重新设计成巨型 Store
- [ ] Permission Store 不重复请求 /me
- [ ] 无循环依赖
- [ ] 不修改 Axios 添加 X-Store-Id
- [ ] 不做 Router Guard
- [ ] 不做 Header
- [ ] 不做 StoreSelector UI
- [ ] 不做菜单
- [ ] 不做业务模块



## 工程

- [ ] TypeCheck PASS
- [ ] Build PASS
- [ ] Lint 如果存在则 PASS

---



# 六十二、最终汇报格式

完成后严格按以下格式汇报：

```text
# 03-5 当前门店 Context 与切店开发报告

## 1. 当前项目扫描

## 2. 后端 switch-store 实际接口结构

## 3. 新增文件

## 4. 修改文件

## 5. Store Context 状态

## 6. Store Context 方法

## 7. 初始化流程

## 8. 切店完整流程

## 9. Token 更新机制

## 10. /me 重新同步机制

## 11. Permission Store 同步机制

## 12. 切店失败与回滚机制

## 13. 10001 / 10003 / 网络异常处理

## 14. 防重复切店机制

## 15. 缓存处理机制

## 16. 测试结果

### 单门店
PASS / FAIL

### 多门店
PASS / FAIL

### 允许门店切换
PASS / FAIL

### 切回原门店
PASS / FAIL

### 当前门店重复切换
PASS / FAIL

### 非法门店
PASS / FAIL

### 10003
PASS / FAIL

### 网络异常
PASS / FAIL

### 10001
PASS / FAIL

### 切店后权限同步
PASS / FAIL / 无权限变化

### 并发切店
PASS / FAIL

### Logout 清理
PASS / FAIL

## 17. TypeCheck
PASS / FAIL

## 18. Build
PASS / FAIL

## 19. Lint
PASS / FAIL / 未配置

## 20. 后端是否修改
YES / NO

## 21. 数据库是否修改
YES / NO

## 22. 是否执行03-6
必须 NO

## 23. 是否执行03-7
必须 NO

## 24. 是否执行03-8
必须 NO

## 25. 是否执行03-9
必须 NO

## 26. 是否执行04～11
必须 NO

## 27. 存在的问题

## 28. 是否可以进入03-6
YES / NO
并说明原因。
```

---



# 六十三、执行结束后必须停止

完成本 Prompt 后：

> **立即停止。**

不要自动进入：

```text
03-6 Router Guard
03-7 MainLayout
03-8 Sidebar
03-9 Header
04～11
```

等待项目负责人验收后再进入下一阶段。