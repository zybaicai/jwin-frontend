# 03-6 Cursor 前端 Router Guard 开发 Prompt

## 一、执行目标

当前 ERP 前端基础设施已经完成：

* 03-1 Request / Token
* 03-2 Login
* 03-3 Auth Store
* 03-4 Permission Store
* 03-5 当前门店 Context 与切店

以上阶段均已通过验收。

现在只执行：

> **03-6 Router Guard**

本阶段目标：

建立 Vue Router 层面的登录态守卫和初始化流程，让前端具备：

```text
页面刷新
    ↓
Router Guard
    ↓
判断 Auth Store 是否初始化
    ↓
恢复 Token / /me
    ↓
判断登录状态
    ↓
未登录 → Login
已登录 → 放行
```

本阶段只解决：

* 路由认证
* 页面刷新后的认证恢复
* Auth Store 初始化等待
* 未登录访问受保护路由
* 已登录访问登录页
* 10001 后重新进入登录页
* 初始化失败时的处理边界
* Router Guard 与 Auth Store / Permission Store / Store Context 的协作

**不要在本阶段开发任何业务模块。**

---

# 二、严格禁止事项

本阶段禁止：

1. 不开发 Header
2. 不开发 StoreSelector
3. 不开发 Sidebar
4. 不开发 Menu
5. 不开发 Breadcrumb
6. 不开发 Layout UI
7. 不开发权限菜单树
8. 不开发业务页面
9. 不开发客户模块
10. 不开发收银模块
11. 不开发预约模块
12. 不开发任何 ERP 业务功能
13. 不修改后端 Controller
14. 不修改数据库
15. 不新增后端 API
16. 不执行 03-7
17. 不执行 03-8
18. 不执行 03-9
19. 不执行 03-10
20. 不执行 04～11

如果发现后续阶段需要的代码，不要提前实现，只记录问题。

---

# 三、先扫描实际项目，不允许猜测

执行前必须先扫描当前项目实际代码。

至少检查：

```text
src/router/index.ts

src/main.ts

src/stores/auth.ts

src/stores/permission.ts

src/stores/store.ts

src/utils/request.ts

src/utils/token.ts

src/utils/auth-event.ts

src/types/auth.ts

src/types/user.ts

src/views/LoginView.vue

src/views/HomeView.vue
```

同时确认：

```text
Vue Router 版本
Router 创建方式
当前 routes
当前 router history
当前 main.ts 初始化顺序
Auth Store initialize()
Permission Store initialize()
Store Store initialize()
Auth-expired 事件机制
```

不要根据假设修改。

---

# 四、当前基础设施必须保持不变

03-6 必须建立在已有实现之上。

不要重做：

```text
Token
Login
Auth Store
Permission Store
Store Context
Axios Interceptor
```

特别是：

```text
Auth Store
Permission Store
Store Store
```

不能重新设计成一个“大 Store”。

---

# 五、Router Guard 的职责

Router Guard 只负责：

```text
路由访问控制
+
认证初始化协调
```

不要让 Router Guard 承担业务逻辑。

Router Guard 不负责：

```text
业务权限判断
业务数据加载
门店业务数据加载
菜单生成
页面 API 调用
```

---

# 六、路由元信息设计

检查当前项目的 RouteMeta 类型。

如果项目还没有合理的 RouteMeta 类型，可以建立最小模型：

```ts
interface RouteMeta {
  requiresAuth?: boolean
}
```

原则：

```text
Login
    requiresAuth = false

受保护业务页面
    requiresAuth = true
```

如果当前项目只有 Home：

```text
/
```

则根据实际代码决定是否给 Home 增加：

```ts
meta: {
  requiresAuth: true
}
```

不要为了本阶段虚构大量业务 routes。

---

# 七、Router Guard 初始化原则

必须解决一个核心问题：

> 页面刷新时，Auth Store 可能还没有完成 initialize()，Router 不能在它完成之前错误地把用户踢到 Login。

例如：

```text
浏览器刷新
    ↓
Vue App 启动
    ↓
Router 开始导航
    ↓
Auth Store 还没有初始化
```

此时不能直接：

```ts
if (!authStore.isAuthenticated) {
  return '/login'
}
```

否则可能出现：

```text
刷新
 ↓
Auth Store 尚未 /me
 ↓
isAuthenticated = false
 ↓
错误跳 Login
 ↓
随后 /me 才成功
```

必须等待初始化完成。

---

# 八、推荐的初始化协调方式

先根据实际项目结构选择最合理方式。

推荐：

```ts
await authStore.initialize()
```

在应用启动阶段完成 Auth 初始化。

然后：

```ts
await permissionStore.initialize()
await storeStore.initialize()
```

之后 Router 再开始正式导航。

但是必须先扫描当前 main.ts 和 router 创建顺序。

如果当前结构不适合直接改变启动流程，也可以在 Router Guard 中：

```ts
if (!authStore.initialized) {
  await authStore.initialize()
}
```

但必须避免重复初始化。

---

# 九、必须明确 initialized 与 isAuthenticated 的区别

这是本阶段重点。

：

```text
initialized = 是否已经完成认证初始化
```

而：

```text
isAuthenticated = 当前是否具有有效登录状态
```

不能混淆。

例如：

```text
initialized = false
isAuthenticated = false
```

代表：

> 还不知道用户到底有没有登录。

不能理解成：

> 用户一定没有登录。

---

# 十、正常刷新场景

### 场景 A：没有 Token

```text
刷新
 ↓
Auth initialize
 ↓
没有 Token
 ↓
initialized = true
 ↓
isAuthenticated = false
 ↓
访问 /
 ↓
/login
```

正确。

---

### 场景 B：有有效 Token

```text
刷新
 ↓
Auth initialize
 ↓
Token 存在
 ↓
GET /me
 ↓
成功
 ↓
currentUser
 ↓
initialized = true
 ↓
permission initialize
 ↓
store initialize
 ↓
访问 /
 ↓
正常放行
```

正确。

---

### 场景 C：Token 已失效

```text
刷新
 ↓
GET /me
 ↓
10001
 ↓
现有 auth-expired 机制
 ↓
Auth 清理
 ↓
Permission 清理
 ↓
Store Context 清理
 ↓
进入 Login
```

必须保证不会出现：

```text
失效 Token
+
旧 currentUser
+
继续访问业务页面
```

---

# 十一、10002 / 10003 的处理

Router Guard 不应该把：

```text
10002
10003
```

当成：

```text
未登录
```

也就是说：

```text
10001
    → 认证失效
    → Login

10002
    → 有登录状态，但无权限
    → 不应该清 Token

10003
    → 有登录状态，但无门店权限
    → 不应该清 Token
```

Router Guard 不要自行制造登出行为。

---

# 十二、网络异常处理

这是本阶段重点。

如果：

```text
Token 存在
GET /me
    ↓
网络异常
```

不能简单理解为：

```text
没有登录
```

因为之前 03-3 已经确定：

> 网络异常不清 Token。

所以需要根据当前 Auth Store 的实际 initialize() 行为设计。

原则：

```text
网络异常 ≠ 10001
```

不要因为服务器暂时不可达就主动删除：

```text
erp_access_token
```

也不要伪造成：

```text
未登录
```

如果当前应用启动流程无法正常进入业务页面，应保留明确的初始化失败状态，并记录到最终报告。

不要为了“让页面能进去”而绕过认证初始化。

---

# 十三、直接访问 Login 的行为

### 未登录访问 Login

正常：

```text
/login
 ↓
放行
```

### 已登录访问 Login

应该：

```text
/login
 ↓
发现已经认证
 ↓
跳转 /
```

但不要使用：

```ts
router.push('/')
```

造成额外导航循环。

Router Guard 应使用：

```ts
return '/'
```

或者当前项目对应的导航返回方式。

---

# 十四、直接访问受保护路由

例如：

```text
/
```

如果：

```text
requiresAuth = true
```

则：

### 未登录

```text
/ 
 ↓
/login
```

### 已登录

```text
/
 ↓
放行
```

---

# 十五、避免导航死循环

重点检查：

```text
/login
/
```

之间是否可能产生：

```text
/login → / → /login → / → ...
```

必须保证：

```text
未登录 + /login
    → /login

未登录 + /
    → /login

已登录 + /login
    → /

已登录 + /
    → /
```

---

# 十六、Auth-expired 与 Router Guard 的关系

当前已有：

```text
auth-expired
```

机制。

不要重新创造第二套：

```text
token-expired
auth-invalid
session-expired
```

之类的机制。

保持现有体系。

Router Guard 只负责：

```text
导航时判断当前认证状态
```

Request 层负责：

```text
请求过程中发现 10001
```

这是两个不同场景。

---

# 十七、切店后的 Router 状态

03-5 已经实现：

```text
switchStore()
 ↓
新 Token
 ↓
/me
 ↓
Auth Store 更新
 ↓
Permission Store 更新
 ↓
Store Context 更新
```

03-6 不应该因为切店而强制：

```text
router.push('/login')
```

切店成功仍然保持当前登录状态。

不要重新登录。

---

# 十八、处理 03-5 发现的特殊情况

03-5 有一个已知边界：

```text
switch-store 成功
 ↓
旧 Token 已失效
 ↓
新 Token 保存
 ↓
/me 网络失败
 ↓
currentUser 可能暂时还是旧门店
```

03-6 不要通过“恢复旧 Token”解决。

禁止：

```text
发现 /me 失败
 ↓
恢复 oldToken
```

因为旧 Token 已经被服务端作废。

本阶段只需要保证：

```text
Router 不把这种情况错误识别成 10001
```

如果应用初始化或导航需要等待认证状态，必须尊重当前 Auth Store 的状态。

如果 Cursor 认为这里需要进一步调整 Auth Store，请：

1. 先记录问题
2. 判断是否属于 03-6 必需修复
3. 只有确实影响 Router 正确性时才修改
4. 不要顺便重构 Auth Store

---

# 十九、Router Guard 中禁止调用业务 API

禁止：

```text
客户 API
项目 API
预约 API
门店业务 API
价格 API
员工 API
订单 API
```

Router Guard 只允许涉及：

```text
Auth
Permission
Store Context
Router
```

---

# 二十、权限判断边界

03-4 已经建立：

```text
permissionStore.hasPermission()
```

但本阶段不要把所有业务权限塞进 Router Guard。

例如不要写：

```ts
if (!permissionStore.hasPermission('customer:view')) {
   ...
}
```

因为：

> Router Guard 不是业务权限系统。

后续菜单、按钮、页面级权限再按照实际设计处理。

本阶段只建立：

```text
认证态路由保护
```

---

# 二十一、测试要求

必须执行以下测试。

## 1. 未登录访问 Login

```text
PASS
```

---

## 2. 未登录访问受保护页面

```text
访问 /
 ↓
/login
```

PASS。

---

## 3. 登录后访问 /

PASS。

---

## 4. 登录后刷新页面

必须验证：

```text
刷新
 ↓
/me
 ↓
currentUser 恢复
 ↓
仍停留在当前路由
```

不能出现：

```text
刷新 → Login → 再回来
```

---

## 5. 登录后直接访问 /login

必须：

```text
/login
 ↓
/
```

PASS。

---

## 6. Token 删除后访问 /

必须：

```text
/
 ↓
/login
```

PASS。

---

## 7. 无效 Token

模拟或真实验证：

```text
Token
 ↓
/me
 ↓
10001
```

必须：

```text
Token 清除
currentUser 清除
Permission 清除
Store Context 清除
Login
```

---

## 8. 10002

验证：

```text
10002
```

不能清 Token。

不能把用户当成未登录。

---

## 9. 10003

验证：

```text
10003
```

不能清 Token。

不能强制 Login。

---

## 10. 网络异常

验证：

```text
GET /me
 ↓
network error
```

必须确认：

```text
Token 不被删除
```

---

## 11. 切店后保持登录

验证：

```text
1001
 ↓
1005
 ↓
当前仍在业务页面
```

不能跳 Login。

---

## 12. 刷新后当前门店恢复

切到：

```text
1005
```

刷新浏览器。

必须：

```text
/me.storeId = 1005
Store Context = 1005
```

不能恢复成：

```text
1001
```

---

## 13. 防止导航死循环

至少验证：

```text
未登录 /
未登录 /login
已登录 /
已登录 /login
```

全部没有无限导航。

---

# 二十二、必须检查 main.ts 启动顺序

最终必须明确记录：

```text
main.ts
 ↓
Pinia
 ↓
Auth initialize
 ↓
Permission initialize
 ↓
Store initialize
 ↓
Router
 ↓
mount
```

或者如果实际采用 Router Guard 初始化：

```text
main.ts
 ↓
Pinia
 ↓
Router
 ↓
Guard
 ↓
Auth initialize
 ↓
Permission initialize
 ↓
Store initialize
 ↓
mount
```

**必须以实际项目最终代码为准。**

不要为了符合示例而强行采用某一种。

---

# 二十三、不要重复初始化

重点检查：

```text
Auth Store.initialize()
```

不会因为：

```text
main.ts
+
Router Guard
```

被重复执行多次。

如果需要增加：

```ts
initializingPromise
```

或者其他一次性初始化机制，可以做。

但不要复杂化。

目标是：

```text
一次初始化
多个导航等待同一个初始化过程
```

而不是：

```text
每次导航都重新 GET /me
```

---

# 二十四、代码质量要求

继续遵守之前规则：

* TypeScript strict
* 禁止 any
* 禁止 @ts-ignore
* 不修改 tsconfig 降低检查
* 不通过类型断言掩盖问题
* 不复制已有 Auth Store
* 不复制 Token 工具
* 不新增第二套错误处理
* 不新增第二套登录状态
* 不新增第二套 Token
* 不修改后端
* 不修改数据库

---

# 二十五、最终报告必须包含

完成后只报告 03-6，不要开始下一阶段。

按照以下结构返回：

```text
# 03-6 Router Guard 开发报告

## 1. 当前项目扫描

## 2. 当前 Router 实际结构

## 3. 当前 main.ts 初始化结构

## 4. RouteMeta 实际设计

## 5. Router Guard 实现

## 6. Auth 初始化机制

## 7. Permission 初始化机制

## 8. Store Context 初始化机制

## 9. 未登录处理

## 10. 已登录访问 Login 处理

## 11. 10001 处理

## 12. 10002 处理

## 13. 10003 处理

## 14. 网络异常处理

## 15. 页面刷新处理

## 16. 直接访问受保护页面

## 17. 切店后 Router 行为

## 18. 是否存在导航死循环

## 19. 是否重复 initialize

## 20. 新增文件

## 21. 修改文件

## 22. TypeCheck

## 23. Build

## 24. Lint

## 25. 实机测试

## 26. 后端是否修改

## 27. 数据库是否修改

## 28. 是否执行 03-7

必须 NO

## 29. 是否执行 03-8

必须 NO

## 30. 是否执行 03-9

必须 NO

## 31. 是否执行 03-10

必须 NO

## 32. 是否执行 04～11

必须 NO

## 33. 已知问题

## 34. 是否可以进入 03-7

YES / NO
```

---

# 二十六、最终停止条件

完成 03-6 后立即停止。

不要自动继续：

```text
03-7
03-8
03-9
03-10
04+
```

等待下一步指令。

---

# 二十七、执行原则

本次执行最重要的原则：

> **不要为了让 Router Guard “看起来完整”，提前建设整个前端框架。**

现在我们是在逐层搭基础设施：

```text
03-1 Request / Token
        ↓
03-2 Login
        ↓
03-3 Auth
        ↓
03-4 Permission
        ↓
03-5 Store Context
        ↓
03-6 Router Guard
        ↓
03-7 MainLayout
        ↓
03-8 Sidebar / Menu
        ↓
03-9 Header / StoreSelector / Breadcrumb
        ↓
03-10 基础交互与前端基础能力
        ↓
前端基础框架验收
        ↓
业务模块
```

**当前只允许做到 03-6。**

执行完成后停止并输出完整验收报告。
