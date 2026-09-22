# 03-4 Cursor前端权限体系开发 Prompt

## 一、任务名称

03-4：前端权限体系建设。

---

# 二、当前项目阶段

当前 ERP 前端基础建设进度：

```text
03-1 统一请求层 + Token 基础设施    PASS
03-2 登录 API + 登录页面            已执行
03-3 Auth Store                     PASS
03-4 前端权限体系                   ← 本次任务
03-5 当前门店
03-6 Router Guard
03-7 MainLayout
03-8 Sidebar / Menu
03-9 Header / StoreSelector / Breadcrumb
03-10 全局交互与按钮权限
```

本次只执行 **03-4**。

## 严格禁止

本次不要执行：

```text
03-5
03-6
03-7
03-8
03-9
03-10
04～11
任何业务模块
```

特别禁止开始：

```text
客户管理
销售开单
消费
预约
会员卡
项目
价格
库存
绩效
报表
```

不要提前开发业务页面。

---

# 三、角色

你现在是：

> Senior Vue 3 + TypeScript 前端架构工程师。

你的任务不是重新设计 ERP 权限业务。

你的任务是：

> 基于当前已经完成的 Auth Store 和后端真实 `/me` 数据结构，建立一套统一、可复用、可维护的前端权限基础设施。

---

# 四、执行原则

必须遵守：

1. 先扫描，再修改。
2. 不猜后端。
3. 不修改后端。
4. 不修改数据库。
5. 不新增没有真实 API 依据的权限接口。
6. 不改变现有登录流程。
7. 不重复实现 Auth Store。
8. 不重复实现 Token。
9. 不重复实现 `/me`。
10. 不实现数据权限过滤。
11. 不实现门店切换。
12. 不实现路由权限。
13. 不实现菜单系统。
14. 不开始业务模块。

如果发现实际代码与本 Prompt 假设不同：

```text
先以当前项目真实代码为准
→ 分析差异
→ 保持现有正确实现
→ 只补当前阶段必要内容
```

不要为了“符合 Prompt”而破坏已有代码。

---

# 五、首先阅读这些文件

在开始修改之前，必须阅读：

```text
ERP项目设计/cursor/frontend/00-Cursor前端开发总规则.md
ERP项目设计/cursor/frontend/01-Cursor前端项目初始化Prompt.md
ERP项目设计/cursor/frontend/02-Cursor前端项目扫描Prompt.md
ERP项目设计/cursor/frontend/03-Cursor前端基础框架开发Prompt.md
ERP项目设计/cursor/frontend/03-1-Cursor前端统一请求层与Token基础设施Prompt.md
ERP项目设计/cursor/frontend/03-2-Cursor登录API与登录页面Prompt.md
ERP项目设计/cursor/frontend/03-3-Cursor当前用户Auth Store完善Prompt.md
```

同时扫描当前代码。

重点查看：

```text
src/types/
src/stores/
src/api/
src/utils/
src/views/
src/router/
src/main.ts
```

---

# 六、读取当前 Auth Store

必须以当前已经通过验收的 Auth Store 为基础。

重点确认：

```text
src/stores/auth.ts
```

当前实际提供：

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

以及：

```text
currentUser.permissionCodes
currentUser.roles
currentUser.dataScope
```

不要重新创建第二套用户状态。

---

# 七、读取后端真实 CurrentUserVo

必须确认后端真实 `/api/v1/auth/me` 返回结构。

当前已确认：

```text
employeeId: string
employeeName: string
jobId: Integer | null
jobName: string | null

jobTypeIds: number[]
orgEntityIds: number[]

storeId: Integer | null
storeName: string | null
storeIds: number[]

roles: {
  id: number
  name: string
}[]

permissionCodes: string[]

dataScope:
  SELF
  STORE
  REGION
  SPECIFIED_STORE
  ALL
  或 null
```

如果当前代码与此不同：

> 以实际后端代码和当前已经验收通过的前端代码为准。

不要擅自修改后端。

---

# 八、03-4 的核心目标

建立：

```text
权限数据
 ↓
Permission Store
 ↓
统一权限判断 API
 ↓
页面按钮权限能力
```

最终业务页面不需要理解：

```text
jobTypeIds
roles
permissionCodes
dataScope
```

业务页面只需要：

```ts
permissionStore.hasPermission('某个权限码')
```

或者项目最终确定的统一权限判断方式。

---

# 九、Permission Store

新增或完善：

```text
src/stores/permission.ts
```

必须使用 Pinia。

职责：

```text
1. 保存当前用户 permissionCodes
2. 保存当前用户 roles
3. 保存当前用户 dataScope
4. 提供权限判断方法
5. 提供初始化/清理能力
```

权限数据的唯一来源：

```text
authStore.currentUser
```

不要再次调用 `/me`。

不要新建权限查询 API。

---

# 十、Permission Store 建议状态

根据实际项目代码决定最终类型，但至少应能够表达：

```ts
permissionCodes: string[]
roles: Role[]
dataScope: string | null
initialized: boolean
```

如果实际项目已经存在对应类型，则复用。

不要重复定义 Role。

---

# 十一、Permission Store 方法

至少提供：

```ts
initialize()
clear()
hasPermission(permissionCode)
hasAnyPermission(permissionCodes)
hasAllPermissions(permissionCodes)
```

具体方法命名可以根据现有项目规范调整，但整个项目必须统一。

---

# 十二、权限判断规则

## 1. 单权限

```ts
hasPermission('sales:price:edit')
```

当：

```text
permissionCodes.includes('sales:price:edit')
```

返回：

```text
true
```

否则：

```text
false
```

---

# 十三、多个权限：Any

例如：

```ts
hasAnyPermission([
  'sales:price:edit',
  'sales:price:admin'
])
```

规则：

> 只要拥有其中任意一个权限码，就返回 true。

---

# 十四、多个权限：All

例如：

```ts
hasAllPermissions([
  'sales:view',
  'sales:price:edit'
])
```

规则：

> 必须全部拥有才返回 true。

---

# 十五、空权限处理

必须明确处理：

```text
permissionCodes = []
```

不能报错。

建议：

```text
hasPermission('xxx') → false
hasAnyPermission([]) → false
hasAllPermissions([]) → true 或按照项目既定语义统一处理
```

如果选择 `hasAllPermissions([]) === true`，必须在代码中保持语义一致并在报告说明。

禁止出现：

```text
undefined.includes(...)
```

等异常。

---

# 十六、roles 的职责

当前：

```text
roles
```

只是当前用户角色信息。

不要把：

```text
roles
```

直接等同于：

```text
permissionCodes
```

不要在前端重新推导：

```text
店长 → xxx权限
员工 → xxx权限
```

这是错误的。

后端已经完成：

```text
JobType
+
Role
+
Permission
```

的权限计算。

前端直接使用后端返回的：

```text
permissionCodes
```

---

# 十七、jobId 与权限角色必须保持区别

不要出现：

```text
jobId === roleId
```

之类的假设。

后端已经明确：

```text
岗位
≠
权限角色
```

所以前端：

```text
jobId
jobTypeIds
roles
permissionCodes
```

必须保持独立。

---

# 十八、dataScope 的处理边界

当前用户有：

```text
dataScope
```

可能为：

```text
SELF
STORE
REGION
SPECIFIED_STORE
ALL
```

本阶段：

> 只保存并暴露 dataScope。

禁止实现：

```text
前端客户过滤
前端订单过滤
前端员工过滤
前端门店数据过滤
前端自己拼 SQL
```

数据权限由后端决定。

前端绝对不能因为：

```text
dataScope = STORE
```

自己过滤数据。

---

# 十九、权限工具函数

如果项目结构适合，可以提供：

```text
src/utils/permission.ts
```

但必须避免和 Permission Store 产生重复逻辑。

推荐原则：

```text
Permission Store
    ↓
核心权限状态与判断
```

如果工具函数只是：

```ts
permissionStore.hasPermission(...)
```

的简单代理，必须评估是否真的需要。

不要为了“文件齐全”而增加无意义抽象。

---

# 二十、Vue 权限指令

评估是否建立：

```text
v-permission
```

例如：

```vue
<el-button
  v-permission="'sales:price:edit'"
>
  改价
</el-button>
```

如果采用该方案：

必须建立统一实现。

例如：

```text
src/directives/permission.ts
```

然后统一注册。

---

# 二十一、v-permission 行为

单权限：

```vue
v-permission="'sales:price:edit'"
```

没有权限：

```text
不显示元素
```

有权限：

```text
正常显示
```

但必须注意：

> 前端权限指令只负责 UI 层控制，不承担真正安全控制。

后端仍然必须通过：

```text
@RequirePermission
```

等机制进行最终权限校验。

---

# 二十二、不要实现“前端安全权限”

禁止产生以下错误理解：

```text
隐藏按钮 = 安全
```

不是。

正确模型：

```text
用户操作
 ↓
前端权限
 ↓
决定是否展示按钮
 ↓
用户发起 API
 ↓
后端权限校验
 ↓
真正决定是否允许
```

因此：

> 任何页面即使绕过前端，也不能绕过后端权限。

---

# 二十三、10002 与 Permission Store

如果后端返回：

```text
10002
```

当前请求层已经会抛出：

```text
ApiBusinessError
```

本阶段不要重新处理 Token。

不要：

```text
10002 → clearAuth()
```

不要：

```text
10002 → removeToken()
```

不要：

```text
10002 → 跳登录页
```

正确：

```text
10002
 ↓
ApiBusinessError
 ↓
当前用户仍然登录
 ↓
由后续全局错误处理阶段统一提示
```

本阶段也不要提前实现复杂的全局错误 UI。

---

# 二十四、Auth Store 与 Permission Store 的关系

关系必须清晰：

```text
Auth Store
│
├── Token
├── Current User
├── Login
├── Logout
└── Session lifecycle
        │
        ↓
Permission Store
│
├── permissionCodes
├── roles
├── dataScope
├── hasPermission
├── hasAnyPermission
└── hasAllPermissions
```

Permission Store 不应该拥有 Token。

Permission Store 不应该负责登录。

Permission Store 不应该负责退出。

Permission Store 不应该操作 Router。

---

# 二十五、初始化关系

不要让两个 Store 互相死循环。

推荐：

```text
authStore.initialize()
       ↓
GET /me
       ↓
authStore.currentUser
       ↓
permissionStore.initialize()
       ↓
读取 authStore.currentUser
       ↓
建立权限状态
```

但由于 03-6 Router Guard 还没有开始：

> 本阶段不需要建立完整的启动初始化编排。

只需要保证：

```text
permissionStore.initialize()
```

可以安全读取当前 Auth Store。

---

# 二十六、Auth 清理时的权限清理

需要考虑：

```text
logout
10001
clearAuth
```

之后：

```text
permissionCodes
roles
dataScope
```

不能继续残留。

如果当前阶段适合让 Auth Store 主动清理 Permission Store：

必须避免：

```text
Auth Store
 ↕
Permission Store
```

互相 import 导致循环依赖。

优先采用清晰的单向依赖。

如果当前架构不适合本阶段联动：

可以保留 Permission Store 自己的：

```ts
clear()
```

由后续认证初始化/全局流程统一调用。

但必须在最终报告中明确说明。

---

# 二十七、不要提前做 Router Guard

本阶段禁止：

```text
router.beforeEach
```

权限判断。

因为：

```text
03-6 = Router Guard
```

这是后面的独立阶段。

本阶段只把：

```text
Permission Store
+
权限判断能力
+
可选 v-permission
```

做好。

---

# 二十八、不要提前做菜单

禁止：

```text
Sidebar
Menu
动态菜单
菜单树
权限菜单映射
```

这些属于后续：

```text
03-8
```

本阶段不要碰。

---

# 二十九、不要提前做按钮业务权限

可以建立：

```text
v-permission
```

基础能力。

但是不要修改：

```text
客户页面
销售页面
预约页面
```

来实际接权限。

因为这些业务页面还没开发。

---

# 三十、TypeScript 要求

禁止：

```ts
any
```

权限码必须明确为：

```ts
string
```

或者项目实际定义的更合适类型。

不要为了所谓类型安全创建几百个硬编码权限字符串。

后端权限码是动态数据。

---

# 三十一、响应式要求

Permission Store 中：

```text
permissionCodes
roles
dataScope
```

应该是响应式状态。

当用户状态清理时：

```text
permissionCodes → []
roles → []
dataScope → null
```

页面依赖权限状态时能够自动更新。

---

# 三十二、性能要求

权限判断属于高频操作。

不要每次：

```text
hasPermission()
```

都重新请求 API。

不要：

```text
hasPermission()
 → GET /me
```

必须使用当前内存权限状态。

必要时可以使用：

```text
Set<string>
```

优化大量权限码判断。

但是：

> 如果当前项目权限码数量很小，保持简单数组也可以。

当前测试账号有 99 个权限码，不需要过度优化。

---

# 三十三、测试要求

完成后至少验证：

## 1. 有权限

例如当前测试账号：

```text
permissionCodes.length = 99
```

验证：

```text
hasPermission(已有权限码)
```

返回：

```text
true
```

---

## 2. 没有权限

使用一个确认不存在的权限码：

```text
__test_nonexistent_permission__
```

验证：

```text
false
```

---

## 3. Any

测试：

```text
[
  不存在权限,
  已存在权限
]
```

结果：

```text
true
```

---

## 4. All

测试：

```text
[
  已存在权限,
  已存在权限
]
```

结果：

```text
true
```

再测试：

```text
[
  已存在权限,
  不存在权限
]
```

结果：

```text
false
```

---

## 5. 空权限

测试：

```text
permissionCodes = []
```

确认不会报错。

---

## 6. 退出

执行：

```text
logout
```

确认：

```text
permissionCodes = []
roles = []
dataScope = null
```

不会继续残留旧用户权限。

---

# 三十四、禁止修改的内容

本次不要修改：

```text
后端
数据库
登录接口
/me接口
Token规则
Axios核心拦截逻辑
销售API
客户API
预约API
任何业务模块
```

除非发现当前实现存在明确 Bug，且必须修改才能完成本阶段。

如果确实需要修改已有代码：

必须在最终报告说明：

```text
文件
原因
修改内容
影响
```

---

# 三十五、最终项目结构目标

最终至少形成类似：

```text
src/
├── api/
├── components/
├── directives/
│   └── permission.ts
├── layouts/
├── router/
├── stores/
│   ├── auth.ts
│   └── permission.ts
├── types/
├── utils/
└── views/
```

但：

> 不要求为了符合这个目录而机械创建空目录或空文件。

以实际项目结构为准。

---

# 三十六、最终验收标准

只有全部满足才算 PASS：

### 权限状态

* [ ] Permission Store 已建立
* [ ] permissionCodes 来源为 Auth Store 当前用户
* [ ] roles 正确保存
* [ ] dataScope 正确保存
* [ ] 不重复调用 `/me`

### 判断能力

* [ ] hasPermission
* [ ] hasAnyPermission
* [ ] hasAllPermissions
* [ ] 空权限不会异常

### 权限指令

如果采用 `v-permission`：

* [ ] 已统一注册
* [ ] 有权限正常显示
* [ ] 无权限隐藏
* [ ] 不存在重复权限指令

### 清理

* [ ] logout 后权限清空
* [ ] clearAuth 后不会继续使用旧权限
* [ ] 10001 后不会残留旧权限

### 架构边界

* [ ] 没有修改后端
* [ ] 没有修改数据库
* [ ] 没有实现 Router Guard
* [ ] 没有实现动态菜单
* [ ] 没有实现门店切换
* [ ] 没有开始业务模块

### 工程质量

* [ ] 无 any
* [ ] npm run type-check PASS
* [ ] npm run build PASS
* [ ] lint 如果存在则 PASS

---

# 三十七、最终汇报格式

完成后不要只回复“完成”。

请按照以下格式报告：

```text
# 03-4 前端权限体系开发报告

## 1. 当前项目扫描
说明实际扫描了哪些文件。

## 2. 当前 Auth Store 结构
说明如何与 Auth Store 对接。

## 3. 新增文件
列出文件。

## 4. 修改文件
列出文件。

## 5. Permission Store
说明：

permissionCodes
roles
dataScope
initialized

以及：

initialize()
clear()
hasPermission()
hasAnyPermission()
hasAllPermissions()

## 6. 权限来源
明确说明权限来自哪里。

## 7. v-permission
如果实现，说明：

注册位置
使用方式
无权限行为

## 8. 10001 / 10002 / 10003
分别说明处理方式。

## 9. Auth Store / Permission Store 依赖关系

## 10. 清理机制

## 11. 测试结果

### 有权限
PASS / FAIL

### 无权限
PASS / FAIL

### Any
PASS / FAIL

### All
PASS / FAIL

### 空权限
PASS / FAIL

### Logout清理
PASS / FAIL

## 12. TypeCheck
PASS / FAIL

## 13. Build
PASS / FAIL

## 14. Lint
PASS / FAIL / 未配置

## 15. 后端是否修改
YES / NO

## 16. 数据库是否修改
YES / NO

## 17. 是否执行了03-5
必须是 NO

## 18. 是否执行04～11
必须是 NO

## 19. 是否存在问题
列出问题。

## 20. 是否可以进入03-5
YES / NO
并说明原因。
```

---

# 三十八、执行结束后停止

完成 03-4 后：

> **立即停止，不要自动进入 03-5。**

把完整开发报告返回。

下一阶段是否开始，由项目负责人确认。
