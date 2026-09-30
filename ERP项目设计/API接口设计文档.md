# API接口设计文档

# 08 养发直营连锁ERP系统API接口设计 V10

**项目名称：** 养发直营连锁ERP自主研发项目
**版本：** V10
**前置文档：** 01～07
**目标：** 将产品功能、业务流程、业务规则、权限和旧数据库映射转换为可直接研发的REST API规范。

---

# 一、API总体设计原则

## API001 API代表业务能力，不代表数据库表

```Plain Text
POST /api/sales/orders
POST /api/sales/orders/{id}/pay
POST /api/treat/orders/{id}/complete
```

Repository负责把业务动作映射到旧数据库。

---

# 二、API总体分层

```Plain Text
前端
 ↓
Controller
 ↓
Application Service
 ↓
Domain Service
 ↓
Repository
 ↓
旧数据库
```

---

# 三、统一API基础规范

## 31 URL规范

统一：

```Plain Text
/api/v1/{domain}/{resource}
```

例如：

```Plain Text
/api/v1/customers
/api/v1/sales/orders
/api/v1/treat/orders
/api/v1/cards/saving
```

---

# 32 HTTP方法

```Plain Text
GET     查询
POST    创建/执行业务动作
PUT     修改资源
DELETE  删除允许删除的资源
```

原则：

> 核心交易业务尽量使用POST业务动作，而不是让前端直接PUT各种状态。

---

# 33 统一响应结构

成功：

```JSON
{
  "code": 0,
  "message": "success",
  "data": {},
  "requestId": "..."
}
```

失败：

```JSON
{
  "code": 40001,
  "message": "储值余额不足",
  "data": null,
  "requestId": "..."
}
```

---

# 四、统一业务错误码

建议第一版：

```Plain Text
10000 参数错误
10001 未登录
10002 无权限
10003 门店无权限

20001 客户不存在
20002 客户重复
20003 权益不存在
20004 权益已过期
20005 权益余额不足

30001 订单不存在
30002 订单状态错误
30003 订单已完成
30004 订单已退款

40001 支付失败
40002 支付超时
40003 重复支付

50001 消耗失败
50002 消耗权益不足
50003 并发扣卡失败

60001 退款失败
60002 超过可退金额
60003 退款状态错误

70001 库存不足
70002 库存并发更新失败

80001 绩效计算失败
80002 提成规则不存在
80003 绩效已结算

90001 业务幂等
90002 系统内部异常
```

实际错误码在开发阶段建立统一枚举。

---

# 五、统一请求头

除登录与健康检查外，**所有** `/api/v1/`** 业务接口都必须携带：

```Plain Text
Authorization: Bearer {token}
```


| Header        | 必填      | 说明                                                                  |
| ------------- | ------- | ------------------------------------------------------------------- |
| Authorization | 是（登录除外） | 格式：`Bearer` + 登录返回的 `data.token`；缺失或无效返回 `code=10001`，`message=未登录` |
| X-Store-Id    | 否       | 预留；当前业务门店以 Token 内 `storeId` 为准                                     |
| X-Request-Id  | 否       | 请求唯一 ID，用于幂等与链路追踪；未传时服务端可自行生成                                       |


**免 Token 白名单（仅此几条）：**

```Plain Text
POST /api/v1/auth/login
GET  /api/v1/health
GET  /actuator/health
```

其余接口（含 `GET /api/v1/auth/me`、`GET /api/v1/stores`、客户等）均需登录 Token。

---

# 5.1 权限校验说明

组织与权限运行时请求链：

```PlainText
身份(JWT) → PermissionLoader 装载 permissionCodes → @RequirePermission 功能权限 → 门店权限 → 数据范围 → 业务规则
```

## 模型（组织 + 权限）


| 概念     | 说明                                                                                           |
| ------ | -------------------------------------------------------------------------------------------- |
| 人事职务   | `TK_Employee.JobID`：花名册/组织岗位，**不自动等于**系统权限                                                   |
| 权限角色   | `TB_EmployeeJobType`：可多选；功能权限来自 `TB_JobTypeMenuPermission`（当前角色定义仍复用 `TK_JobType`，后续可拆独立角色表） |
| 组织数据范围 | `TB_EmployeeOrgScope`：**跟人走**；同一「营运」角色可有人管一部、有人管二部                                           |
| 上级包含下级 | 勾选「杭州一部」自动包含其下全部组织节点与门店；可访问门店 = 展开后 `IsStore=true`                                           |
| 强制配置   | 人人必须配置权限角色 + 组织范围，否则**不能登录**；无权限码则不能进需鉴权页面/接口                                                |
| 登录默认门店 | 优先上次切店（`TB_EmployeeLoginEntity`，**退出不清除**）→ 仍在范围内的主门店 → 范围首店                                 |
| 切店     | 仅 `storeIds` 内可切；业务以当前门店为数据上下文（查顾客等需先切到对应门店）                                                 |
| 装载     | 每次请求重载角色、组织范围、`storeIds`、`permissionCodes`；`dataScope=SPECIFIED_STORE`                       |


配置：`PUT /api/v1/employees/{id}/role-access` 一并提交 `jobTypeIds` + `orgEntityIds`。  
功能码模板：`PUT /api/v1/job-types/{id}/permissions`。

种子脚本：`db/erp_permission_seed.sql`（建绑定表 + 初始权限点；并为 `JobTypeID=1` 绑定全部码便于联调）。

示例权限码：

```PlainText
org:store:view / org:store:edit
org:employee:view / org:employee:edit
org:job:view / org:job:edit
org:role:view / org:role:edit          # 查看/配置「职务」上的权限
org:permission:view / org:permission:edit
customer:list:view / customer:create / customer:edit
```

`GET /api/v1/auth/me` 的 `data` 额外返回：


| 字段              | 类型       | 说明               |
| --------------- | -------- | ---------------- |
| permissionCodes | string[] | 职务∪系统角色合并后的功能权限码 |
| dataScope       | string   | 数据范围枚举名          |
| orgEntities     | array    | 勾选组织范围节点（含名称）    |
| orgScopeTree    | array    | 可访问组织层级树（含名称）    |
| stores          | array    | 可访问门店 id+name    |


---

# 六、认证API

# 61 登录✅️

```HTTP
POST /api/v1/auth/login
```

无需 Token。

请求：

```JSON
{
  "username": "13800000000",
  "password": "123456",
  "storeId": 1001
}
```


| 字段       | 类型     | 必填  | 说明                                                   |
| -------- | ------ | --- | ---------------------------------------------------- |
| username | string | 是   | 员工手机号；也可传员工 ID                                       |
| password | string | 是   | 明文密码；服务端按 MD5（小写）与 `TK_Employee.Password` 比对，亦兼容明文直存 |
| storeId  | int    | 否   | 登录门店；省略时取主门店，再否则取权限内第一个门店                            |


返回（统一外壳 + `data`）：

```JSON
{
  "code": 0,
  "message": "success",
  "data": {
    "token": "eyJ...",
    "refreshToken": "eyJ...",
    "employee": {
      "id": "10001",
      "name": "测试员工",
      "jobId": 1,
      "jobName": "店长"
    },
    "store": {
      "id": 1001,
      "name": "杭州A店"
    },
    "roles": [
      {
        "id": 1,
        "name": "管理员"
      }
    ]
  },
  "requestId": "..."
}
```


| data 字段          | 类型     | 说明                                        |
| ---------------- | ------ | ----------------------------------------- |
| token            | string | JWT，后续请求放 `Authorization: Bearer {token}` |
| refreshToken     | string | 当前与 token 同值                              |
| employee.id      | string | 员工 ID（`TK_Employee.ID`）                   |
| employee.name    | string | 员工姓名                                      |
| employee.jobId   | int    | 职务 ID                                     |
| employee.jobName | string | 职务名称                                      |
| store.id         | int    | 当前门店 ID                                   |
| store.name       | string | 当前门店名称                                    |
| roles[].id       | int    | 角色 ID                                     |
| roles[].name     | string | 角色名称                                      |


业务校验：

```Plain Text
员工存在（手机号或员工 ID）
↓
员工状态正常（State=true）
↓
密码正确（MD5 或明文）
↓
已分配门店权限
↓
目标门店在权限内且门店存在
```

本地开发测试账号：`username=13800000000` / `password=123456` / `storeId=1001`。

会话说明：

- JWT 绝对最长有效期由配置 `yudao.erp.jwt.expire-hours` 控制（默认 12 小时）。
- 另有**空闲超时**：超过配置分钟数无任何业务请求，Token 自动失效（Redis 滑动窗口），需重新登录；默认见 `yudao.erp.auth.idle-timeout-minutes`，也可通过系统设置接口修改。

---

# 61.1 退出登录✅️

```HTTP
POST /api/v1/auth/logout
```

请求头（必填）：

```Plain Text
Authorization: Bearer {token}
```

无 Body。

行为：

1. 将当前 Token 写入 Redis 黑名单，直至 JWT 自然过期；
2. 删除该 Token 的空闲活跃记录。

此后使用同一 Token 访问任意需登录接口，返回 `code=10001`（登录已超时或已退出）。

返回：

```JSON
{
  "code": 0,
  "message": "success",
  "data": null,
  "requestId": "..."
}
```

---

# 62 获取当前用户✅️

```HTTP
GET /api/v1/auth/me
```

请求头：

```Plain Text
Authorization: Bearer {token}
```

无 Query / Body 参数。

返回（含权限上下文）：

```JSON
{
  "code": 0,
  "message": "success",
  "data": {
    "employeeId": "10001",
    "employeeName": "测试员工",
    "jobId": 1,
    "jobName": "店长",
    "jobTypeIds": [1],
    "orgEntityIds": [200],
    "orgEntities": [
      { "id": 200, "name": "杭州一部", "store": false, "parentId": 10 }
    ],
    "orgScopeTree": [
      {
        "id": 200,
        "name": "杭州一部",
        "parentId": 10,
        "store": false,
        "sequence": 1,
        "children": [
          {
            "id": 1001,
            "name": "杭州A店",
            "parentId": 200,
            "store": true,
            "sequence": 1,
            "children": []
          }
        ]
      }
    ],
    "storeId": 1001,
    "storeName": "杭州A店",
    "storeIds": [1001],
    "stores": [
      { "id": 1001, "name": "杭州A店" }
    ],
    "roles": [
      { "id": 1, "name": "管理员" }
    ],
    "permissionCodes": [],
    "dataScope": "SPECIFIED_STORE"
  },
  "requestId": "00ff2345f7f942fc960dffb0a562db68"
}
```


| data 字段         | 类型       | 说明                                              |
| --------------- | -------- | ----------------------------------------------- |
| employeeId      | string   | 员工 ID                                           |
| employeeName    | string   | 员工姓名                                            |
| jobId           | int      | 人事主职务 ID                                        |
| jobName         | string   | 职务名称                                            |
| jobTypeIds      | int[]    | 已分配职务角色（可多选；功能权限并集）                             |
| orgEntityIds    | int[]    | 组织数据范围节点（配置值，未展开）                               |
| orgEntities     | array    | 勾选范围节点摘要；元素含 `id`、`name`、`store`、`parentId`     |
| orgScopeTree    | array    | **可访问组织层级树**（勾选展开后的森林）；节点含 `id`/`name`/`parentId`/`store`/`sequence`/`children`；`store=true` 可切店 |
| storeId         | int      | 当前业务门店 ID（登录/切店后写入 Token）                       |
| storeName       | string   | 当前门店名称                                          |
| storeIds        | int[]    | 可访问门店 ID（兼容旧前端）                                 |
| stores          | array    | 可访问门店摘要；元素含 `id`、`name`（切店下拉优先用此或 `orgScopeTree`） |
| roles           | array    | 职务角色列表；元素含 `id`、`name`（同 jobTypeIds）            |
| permissionCodes | string[] | 功能权限码（职务∪系统角色合并；未配置绑定时可为空）                      |
| dataScope       | string   | 已配组织范围时为 `SPECIFIED_STORE`；否则多为 `STORE` / `ALL` |


说明：

- 未带或 Token 无效时返回 `code=10001`，`message=未登录`。
- 前端门店/组织选择展示用 `orgScopeTree`（层级 + 名称）或 `stores`（扁平 id+name）；不要只展示 `storeIds` 编号。
- 切店仍调用 `POST /api/v1/auth/switch-store`，且仅允许 `store=true` 的节点（与 `storeIds`/`stores` 一致）。
- 功能权限以 `permissionCodes` 为准（`@RequirePermission`）。
- 组织范围通过 `PUT /api/v1/employees/{id}/role-access` 与职务角色一并配置。

---

# 63 切换门店✅️

```HTTP
POST /api/v1/auth/switch-store
```

请求头：

```Plain Text
Authorization: Bearer {token}
```

请求：

```JSON
{
  "storeId": 1001
}
```


| 字段      | 类型  | 必填  | 说明                          |
| ------- | --- | --- | --------------------------- |
| storeId | int | 是   | 目标门店 ID，须在当前员工 `storeIds` 内 |


返回：

> 与「61 登录」的 `data` 结构相同（重新签发 `token` / `refreshToken`，并更新当前门店）。

说明：切店成功后原 Token 作废，客户端须改用返回的新 Token。

用于：

> 一个员工拥有多个门店权限时切换当前业务门店。

---

# 64 登录会话策略（网页配置入口）✅️

```HTTP
GET /api/v1/system/settings/auth-session
PUT /api/v1/system/settings/auth-session
```

请求头（必填）：

```Plain Text
Authorization: Bearer {token}
```

## GET 返回

```JSON
{
  "code": 0,
  "message": "success",
  "data": {
    "idleTimeoutMinutes": 30,
    "tokenExpireHours": 12
  },
  "requestId": "..."
}
```


| data 字段            | 类型  | 说明                                                     |
| ------------------ | --- | ------------------------------------------------------ |
| idleTimeoutMinutes | int | 空闲超时分钟数；超过该时间无接口请求则 Token 失效                           |
| tokenExpireHours   | int | JWT 绝对最长有效小时数（配置文件 `yudao.erp.jwt.expire-hours`，本接口只读） |


## PUT 请求

```JSON
{
  "idleTimeoutMinutes": 45
}
```


| 字段                 | 类型  | 必填  | 说明                                    |
| ------------------ | --- | --- | ------------------------------------- |
| idleTimeoutMinutes | int | 是   | 1～10080；写入 `TB_ErpSystemSetting`，立即生效 |


空闲超时优先级：库表配置 > `application-erp.properties` 中 `yudao.erp.auth.idle-timeout-minutes`（默认 30）。

---

# 七、组织API

# 71 查询门店✅️

```HTTP
GET /api/v1/stores
```

请求头（必填）：

```Plain Text
Authorization: Bearer {token}
```

查询参数：


| 参数      | 类型     | 必填  | 说明                     |
| ------- | ------ | --- | ---------------------- |
| keyword | string | 否   | 按门店名称模糊匹配；不传则返回权限内全部门店 |


说明：

- 仅返回当前登录人 `storeIds` 权限范围内、且 `IsStore=true` 的门店。
- 本期未实现 `status`、`regionId` 筛选。

返回（实测）：

```JSON
{
  "code": 0,
  "message": "success",
  "data": [
    {
      "id": 1001,
      "name": "杭州A店"
    }
  ],
  "requestId": "f8ccb878a2064ea8a965de9e8ab3c1ea"
}
```


| data[] 字段 | 类型     | 说明                           |
| --------- | ------ | ---------------------------- |
| id        | int    | 门店 ID（`TK_Entity.ID`）        |
| name      | string | 门店名称（`TK_Entity.EntityName`） |


未登录时：

```JSON
{
  "code": 10001,
  "message": "未登录",
  "data": null,
  "requestId": null
}
```

---

# 72 查询组织下员工（分页）✅️

```HTTP
GET /api/v1/employees
```

点击组织节点查看该组织下人员。对齐旧接口 `EntityID + PageNum + SearchKey + State + JobID`。

查询参数：

```Plain Text
entityId     必填，组织单位 ID（旧 EntityID）
keyword      可选，姓名/手机号/员工编号/花名模糊（旧 SearchKey）
jobId        可选，职务 ID（旧 JobID）
state        可选，在职状态 true/false（旧 State）；不传不过滤
page         页码，默认 1（旧 PageNum）
size         每页条数，默认 10，最大 100（旧 PageSize）
```

返回 data（`PageData`）：

```JSON
{
  "total": 3,
  "page": 1,
  "size": 10,
  "records": [
    {
      "id": "6640",
      "name": "孙得川",
      "alias": "",
      "phoneNumber": "15157126640",
      "jobId": 17,
      "jobName": "普通员工(公司)",
      "state": true,
      "gender": "1",
      "genderName": "男",
      "idNumber": "",
      "birthdate": null,
      "address": "",
      "entryDate": "2023-02-01",
      "trialExpiryDate": null,
      "contractStartDate": null,
      "contractEndDate": null,
      "socialSecurityPaymentDate": null,
      "remark": null,
      "avatar": null,
      "entities": [
        {
          "entityId": 35,
          "entityName": "总经办",
          "primaryEntity": true
        }
      ]
    }
  ]
}
```

---

# 73 查询员工详情✅️

```HTTP
GET /api/v1/employees/{id}
```

返回字段同列表单条 `records[]`（含所属组织 `entities`）。员工不存在时 `code=30001`。

---

# 714 新增员工❌️id不能由前端存入，应该后端自动生成

```HTTP
POST /api/v1/employees
```

请求：

```JSON
{
  "id": "6640",
  "name": "孙得川",
  "alias": "",
  "phoneNumber": "18258488080",
  "gender": "1",
  "jobId": 17,
  "entityId": 35,
  "idNumber": "",
  "address": "",
  "entryDate": "2023-02-01",
  "contractStartDate": null,
  "contractEndDate": null,
  "remark": null,
  "password": "123456",
  "state": true
}
```


| 字段                | 类型      | 必填  | 说明                      |
| ----------------- | ------- | --- | ----------------------- |
| id                | string  | 是   | 员工编号（主键），最长 50          |
| name              | string  | 是   | 员工姓名，最长 20              |
| alias             | string  | 否   | 花名                      |
| phoneNumber       | string  | 是   | 手机号，全局唯一                |
| gender            | string  | 否   | 1 男 / 2 女 / 0 未知        |
| jobId             | int     | 是   | 职务 ID                   |
| entityId          | int     | 是   | 所属组织单位（主组织）             |
| idNumber          | string  | 否   | 证件号码                    |
| address           | string  | 否   | 地址                      |
| entryDate         | date    | 否   | 入职日期 yyyy-MM-dd         |
| contractStartDate | date    | 否   | 合同开始                    |
| contractEndDate   | date    | 否   | 合同结束                    |
| remark            | string  | 否   | 备注                      |
| password          | string  | 否   | 初始密码，默认 `123456`（存 MD5） |
| state             | boolean | 否   | 在职状态，默认 true            |


返回：同员工详情。编号重复、手机号重复、职务/组织不存在时 `code=10000`。

---

# 715 修改员工

```HTTP
PUT /api/v1/employees/{id}
```

请求：

```JSON
{
  "name": "孙得川",
  "alias": "",
  "phoneNumber": "15157126640",
  "gender": "1",
  "jobId": 17,
  "entityId": 35,
  "idNumber": "",
  "address": "",
  "entryDate": "2023-02-01",
  "birthdate": null,
  "contractStartDate": null,
  "contractEndDate": null,
  "remark": null,
  "state": true,
  "password": null
}
```


| 字段                                                              | 类型      | 必填  | 说明                    |
| --------------------------------------------------------------- | ------- | --- | --------------------- |
| name                                                            | string  | 是   | 姓名                    |
| alias                                                           | string  | 否   | 花名                    |
| phoneNumber                                                     | string  | 是   | 手机号                   |
| gender                                                          | string  | 否   | 性别                    |
| jobId                                                           | int     | 是   | 职务                    |
| entityId                                                        | int     | 是   | 主组织；仅调整主门店标记，保留其它跨店关系 |
| idNumber / address / entryDate / birthdate / contract* / remark |         | 否   | 同新增                   |
| state                                                           | boolean | 是   | 是否在职                  |
| password                                                        | string  | 否   | 传入则重置密码（MD5）          |


返回：更新后的员工详情。

---

# 715A 查询员工角色与组织数据范围

```HTTP
GET /api/v1/employees/{id}/role-access
```

请求头（必填）：

```PlainText
Authorization: Bearer {token}
```

功能权限：`org:role:view`（`storeCheck=false`）。

返回示例：

```JSON
{
  "code": 0,
  "message": "ok",
  "data": {
    "employeeId": "10001",
    "employeeName": "张三",
    "jobTypes": [{ "id": 2, "name": "营运" }],
    "orgEntityIds": [200],
    "orgEntities": [{ "id": 200, "name": "杭州一部", "store": false, "parentId": 10 }],
    "resolvedStoreIds": [1001, 1002],
    "dataScope": "SPECIFIED_STORE"
  }
}
```


| 字段                         | 说明                          |
| -------------------------- | --------------------------- |
| jobTypes                   | 已分配权限角色（功能权限来源；不等于人事 JobID） |
| orgEntityIds / orgEntities | 勾选的组织范围节点                   |
| resolvedOrgEntityIds       | 勾选节点展开后的全部下级组织（含非门店）        |
| resolvedStoreIds           | 展开后的可访问门店（`IsStore=true`）   |
| dataScope                  | `SPECIFIED_STORE`           |


---

# 715B 配置员工角色与组织数据范围（全量覆盖）

```HTTP
PUT /api/v1/employees/{id}/role-access
```

请求头（必填）：

```PlainText
Authorization: Bearer {token}
```

功能权限：`org:role:edit`（`storeCheck=false`）。

请求：

```JSON
{
  "jobTypeIds": [2],
  "orgEntityIds": [200]
}
```


| 字段           | 类型    | 必填  | 说明                                |
| ------------ | ----- | --- | --------------------------------- |
| jobTypeIds   | int[] | 是   | 权限角色，至少一项；**不修改**人事 JobID         |
| orgEntityIds | int[] | 是   | 组织范围，至少一项；勾选上级自动含下级全部组织/门店；空数组不允许 |


返回：同 715A（含 `resolvedOrgEntityIds` / `resolvedStoreIds`）。展开后无门店时 `code=10000`。

生效：下次请求即可。登录默认上次切店；查其它门店顾客须先 `switch-store`，可切列表以 `storeIds` 为准。

> V1（CONF-039）：系统角色 `TB_Role` **冻结管理写接口**；配置主路径为 JobType + `role-access`。登录仍可合并系统角色权限码（兼容旧数据）。

---

# 716 查询单店跨店员工

```HTTP
GET /api/v1/stores/{storeId}/cross-store-employees
```

本店「跨店员工」= `TK_EmployeeEntity` 中 `EntityID=storeId` 且 `IsPrimaryEntity=false` 的员工（主门店在其它组织）。

查询参数：

```Plain Text
keyword    可选；按员工姓名或员工编号模糊匹配（任一命中即可）
```

返回 data 数组：

```JSON
[
  {
    "employeeId": "6640",
    "name": "孙得川",
    "alias": "",
    "phoneNumber": "15157126640",
    "jobId": 17,
    "jobName": "普通员工(公司)",
    "state": true,
    "primaryEntityId": 35,
    "primaryEntityName": "总经办",
    "storeId": 1001,
    "storeName": "杭州A店"
  }
]
```

---

# 717 新增跨店员工

```HTTP
POST /api/v1/stores/{storeId}/cross-store-employees
```

请求：

```JSON
{
  "employeeId": "6640"
}
```

规则：

```Plain Text
员工须已存在且已有主门店
主门店不能是当前 storeId
本店尚未存在该员工关系
写入 TK_EmployeeEntity（IsPrimaryEntity=false）
```

返回：同列表单条。已是本店主门店员工 / 已是跨店员工 / 无主门店时 `code=10000`。

---

# 718 删除跨店员工

```HTTP
DELETE /api/v1/stores/{storeId}/cross-store-employees/{employeeId}
```

仅删除本店非主门店关系，不删员工主档、不删主门店。若关系不存在或实为主门店则 `code=10000`；成功时 `data=null`。

---

# 74 职务分页列表✅️

```HTTP
GET /api/v1/job-types
```

请求头（必填）：

```Plain Text
Authorization: Bearer {token}
```

查询参数：


| 参数      | 类型      | 必填  | 说明                |
| ------- | ------- | --- | ----------------- |
| keyword | string  | 否   | 按职务名称模糊搜索         |
| active  | boolean | 否   | 有效性筛选；不传则全部       |
| page    | long    | 否   | 页码，从 1 起，默认 1     |
| size    | long    | 否   | 每页条数，默认 20，最大 100 |


返回：

```JSON
{
  "code": 0,
  "message": "success",
  "data": {
    "total": 1,
    "page": 1,
    "size": 20,
    "records": [
      {
        "id": 1,
        "name": "店长",
        "description": "本地测试职务",
        "active": true
      }
    ]
  },
  "requestId": "..."
}
```


| records[] 字段 | 类型      | 说明                     |
| ------------ | ------- | ---------------------- |
| id           | int     | 职务 ID（`TK_JobType.ID`） |
| name         | string  | 职务名称                   |
| description  | string  | 职务说明，可为 null           |
| active       | boolean | 有效性                    |


---

# 75 职务详情

```HTTP
GET /api/v1/job-types/{id}
```

请求头（必填）：

```Plain Text
Authorization: Bearer {token}
```

返回 `data` 结构同列表单条（`id` / `name` / `description` / `active`）。职务不存在时 `code=10000`。

---

# 76 新增职务✅️

```HTTP
POST /api/v1/job-types
```

请求头（必填）：

```Plain Text
Authorization: Bearer {token}
```

请求：

```JSON
{
  "name": "护理师",
  "description": "门店护理岗位",
  "active": true
}
```


| 字段          | 类型      | 必填  | 说明              |
| ----------- | ------- | --- | --------------- |
| name        | string  | 是   | 职务名称，最长 50，全局唯一 |
| description | string  | 否   | 职务说明，最长 200     |
| active      | boolean | 否   | 有效性，默认 true     |


返回：新建后的职务对象（同详情 `data`）。名称重复时 `code=10000`。

---

# 77 修改职务✅️

```HTTP
PUT /api/v1/job-types/{id}
```

请求头（必填）：

```PlainText
Authorization: Bearer {token}
```

请求：

```JSON
{
  "name": "护理师",
  "description": "门店护理岗位",
  "active": false
}
```


| 字段          | 类型      | 必填  | 说明   |
| ----------- | ------- | --- | ---- |
| name        | string  | 是   | 职务名称 |
| description | string  | 否   | 职务说明 |
| active      | boolean | 是   | 有效性  |


返回：更新后的职务对象。

---

# 78 删除职务✅️

```HTTP
DELETE /api/v1/job-types/{id}
```

请求头（必填）：

```Plain Text
Authorization: Bearer {token}
```

无 Body。若仍有员工 `JobID` 引用该职务，返回 `code=10000`（无法删除）；成功时 `data=null`。删除成功时同步清理 `TB_JobTypeMenuPermission`。

---

# 78A 查询职务已绑定权限

```HTTP
GET /api/v1/job-types/{id}/permissions
```

请求头（必填）：

```PlainText
Authorization: Bearer {token}
```

功能权限：`org:role:view`（`storeCheck=false`）。

返回：

```JSON
{
  "code": 0,
  "message": "ok",
  "data": ["org:job:view", "customer:list:view", "customer:create"]
}
```

职务不存在时 `code=10000`。

---

# 78B 配置职务权限（全量覆盖）

```HTTP
PUT /api/v1/job-types/{id}/permissions
```

请求头（必填）：

```PlainText
Authorization: Bearer {token}
```

功能权限：`org:role:edit`（`storeCheck=false`）。

请求：

```JSON
{
  "permissionCodes": ["org:job:view", "customer:list:view", "customer:create"]
}
```


| 字段              | 类型       | 必填  | 说明                                             |
| --------------- | -------- | --- | ---------------------------------------------- |
| permissionCodes | string[] | 是   | 全量替换；空数组表示清空该职务全部权限；码须已存在于 `TB_MenuPermission` |


返回：保存后的权限码列表（同 78A `data`）。

说明：绑定写入 `TB_JobTypeMenuPermission`；员工 `JobID` 指向该职务后，下次请求 `PermissionLoader` 即装载生效。

---

# 78C 权限点树

```HTTP
GET /api/v1/permissions
```

请求头（必填）：

```PlainText
Authorization: Bearer {token}
```

功能权限：`org:permission:view`（`storeCheck=false`）。

返回 `data` 为树形节点数组，节点字段：


| 字段                            | 类型      | 说明              |
| ----------------------------- | ------- | --------------- |
| code                          | string  | 权限码（主键）         |
| name                          | string  | 显示名             |
| parentCode                    | string  | 父级码；顶级为 `""`    |
| type                          | string  | `M`/`P`/`B`/`A` |
| menu                          | boolean | 是否菜单            |
| verifyStore / verifyWarehouse | boolean | 是否校验门店/仓库       |
| routerPath / routerName       | string  | 前端路由（可空）        |
| sequence                      | int     | 排序              |
| children                      | array   | 子节点             |


---

# 78D 权限点详情

```HTTP
GET /api/v1/permissions/{code}
```

功能权限：`org:permission:view`。返回单节点（无 `children` 或空数组）。

> 路径变量使用 `{code:.+}`，支持权限码中的 `:`（如 `org:permission:view`）。

---

# 78E 新增权限点

```HTTP
POST /api/v1/permissions
```

功能权限：`org:permission:edit`。

请求：

```JSON
{
  "code": "customer:export",
  "name": "导出顾客",
  "parentCode": "customer",
  "type": "A",
  "menu": false,
  "verifyStore": true,
  "verifyWarehouse": false,
  "routerPath": null,
  "routerName": null,
  "sequence": 104
}
```

权限码已存在、父级不存在、类型非法时 `code=10000`。

---

# 78F 修改权限点

```HTTP
PUT /api/v1/permissions/{code}
```

功能权限：`org:permission:edit`。请求体同新增（不含 `code`，路径参数为码）。

---

# 78G 删除权限点

```HTTP
DELETE /api/v1/permissions/{code}
```

功能权限：`org:permission:edit`。有子节点、或仍被职务/系统角色绑定时拒绝（`code=10000`）。

---

# 78H 操作日志分页查询

```HTTP
GET /api/v1/operation-logs
```

功能权限：`system:audit:view`（`storeCheck=false`）。

查询参数：`from` / `to`（ISO 日期时间）、`storeId`、`operatorId`、`bizType`、`bizId`、`action`、`riskLevel`、`page`、`size`。

仅查询；无改删接口。写入由业务服务内部 `record` 完成（同事务）。

---

# 79 新增组织✅️

```HTTP
POST /api/v1/organizations
```

请求头（必填）：

```Plain Text
Authorization: Bearer {token}
```

在组织树中新增单位（写入 `TK_Entity`），可同时标记为门店和/或仓库。

请求：

```JSON
{
  "parentId": 0,
  "name": "杭州B店",
  "store": true,
  "warehouse": false,
  "provinceCode": "330000",
  "cityCode": "330100",
  "areaCode": "330106",
  "addressDetail": "西湖区文三路 100 号"
}
```


| 字段            | 类型      | 必填  | 说明                                   |
| ------------- | ------- | --- | ------------------------------------ |
| parentId      | int     | 否   | 上级单位 ID；顶级传 `null`/不传/`0`；非 0 时上级须存在 |
| name          | string  | 是   | 单位名称，最长 50；同一上级下不可重名                 |
| store         | boolean | 是   | 是否门店                                 |
| warehouse     | boolean | 是   | 是否仓库                                 |
| provinceCode  | string  | 否   | 地址-省编码                               |
| cityCode      | string  | 否   | 地址-市编码                               |
| areaCode      | string  | 否   | 地址-区编码                               |
| addressDetail | string  | 否   | 详细地址，最长 200                          |


业务：

```Plain Text
校验上级单位（parentId=0 跳过）
 ↓
同级名称去重
 ↓
生成 ID / Sequence，Active=true
 ↓
写入 TK_Entity
```

返回 data：

```JSON
{
  "id": 1002,
  "name": "杭州B店",
  "parentId": 0,
  "parentName": null,
  "store": true,
  "warehouse": false,
  "provinceCode": "330000",
  "cityCode": "330100",
  "areaCode": "330106",
  "addressDetail": "西湖区文三路 100 号",
  "sequence": 2,
  "active": true
}
```

说明：新建门店后，员工需另行授权门店权限，才会出现在 `GET /api/v1/stores` 的可访问列表中。

---

# 711 修改组织✅️

```HTTP
PUT /api/v1/organizations/{id}
```

请求头（必填）：

```Plain Text
Authorization: Bearer {token}
```

可修改创建时的全部字段，并额外支持修改是否有效。

请求：

```JSON
{
  "parentId": 0,
  "name": "杭州B店",
  "store": true,
  "warehouse": false,
  "provinceCode": "330000",
  "cityCode": "330100",
  "areaCode": "330106",
  "addressDetail": "西湖区文三路 100 号",
  "active": true
}
```


| 字段            | 类型      | 必填  | 说明                                  |
| ------------- | ------- | --- | ----------------------------------- |
| parentId      | int     | 否   | 上级单位 ID；顶级传 `null`/不传/`0`；不能是自身或其下级 |
| name          | string  | 是   | 单位名称，最长 50；同一上级下不可与其它单位重名           |
| store         | boolean | 是   | 是否门店                                |
| warehouse     | boolean | 是   | 是否仓库                                |
| provinceCode  | string  | 否   | 地址-省编码                              |
| cityCode      | string  | 否   | 地址-市编码                              |
| areaCode      | string  | 否   | 地址-区编码                              |
| addressDetail | string  | 否   | 详细地址，最长 200                         |
| active        | boolean | 是   | 是否有效                                |


返回：更新后的组织对象（同新增接口 `data` 结构）。组织不存在、上级非法或同级重名时 `code=10000`。

---

# 710 查询组织树✅️

```HTTP
GET /api/v1/organizations
```

请求头（必填）：

```Plain Text
Authorization: Bearer {token}
```

返回全部组织单位，按 `ParentID` 组装为树；同级按 `Sequence`、`ID` 升序。

查询参数：

```Plain Text
activeOnly    可选，true 时仅返回 Active=true 的节点（默认 false，返回全部）
```

口径（对齐旧接口语义，字段为 camelCase）：

```Plain Text
entityName           单位名称（旧 EntityName）
parentId             上级 ID（旧 ParentID）
store                是否门店（旧 IsStore）
warehouse            是否仓库（TK_Entity.IsWarehouse）
materialWarehouse    兼容旧 IsMaterialWarehouse；当前库无独立字段，与 warehouse 同值
medicineWarehouse    兼容旧 IsMedicineWarehouse；当前库无此字段，固定 false
children             子级列表（旧 Child）；无子级时为 []
不返回旧接口中的 PageNum / pageSize
```

返回 data 示例：

```JSON
[
  {
    "id": 1,
    "entityName": "杭州悦发企业管理咨询有限公司",
    "parentId": 0,
    "store": false,
    "warehouse": false,
    "materialWarehouse": false,
    "medicineWarehouse": false,
    "provinceCode": null,
    "cityCode": null,
    "areaCode": null,
    "addressDetail": null,
    "longitude": null,
    "latitude": null,
    "sequence": 1,
    "active": true,
    "remark": null,
    "children": [
      {
        "id": 7,
        "entityName": "杭州事业部一部",
        "parentId": 1,
        "store": false,
        "warehouse": false,
        "materialWarehouse": false,
        "medicineWarehouse": false,
        "provinceCode": "330000",
        "cityCode": "330100",
        "areaCode": null,
        "addressDetail": "",
        "longitude": null,
        "latitude": null,
        "sequence": 11,
        "active": true,
        "remark": "",
        "children": [
          {
            "id": 22,
            "entityName": "杭州乐堤港店",
            "parentId": 7,
            "store": true,
            "warehouse": true,
            "materialWarehouse": true,
            "medicineWarehouse": false,
            "provinceCode": "330000",
            "cityCode": "330100",
            "areaCode": "330105",
            "addressDetail": "A区3楼340号铺",
            "longitude": 120.1436720000,
            "latitude": 30.3055090000,
            "sequence": 19,
            "active": true,
            "remark": null,
            "children": []
          }
        ]
      }
    ]
  }
]
```

说明：本接口返回全量组织树（管理端用），与 `GET /api/v1/stores`（仅当前人权限内门店）不同。

---

# 八、客户API

> 维护约定：凡新增、修改、删除顾客相关 REST 接口（含路径、方法、请求/响应字段、查询参数、业务口径），必须同步更新本章；若文档有而代码未实现，须标明「尚未实现」。

# 81 查询客户（列表）

```HTTP
GET /api/v1/customers
```

查询参数（均可选，支持多条件组合 AND）：

```Plain Text
page                    页码，从 1 起，默认 1
size                    每页条数，默认 20，最大 100
storeId                 门店 ID，默认当前登录门店；须在员工门店权限内
keyword                 「客户名称」关键字：同时对客户姓名、客户编号、手机号做模糊匹配（OR，任一命中即可）
mobile                  手机号模糊搜索（兼容旧参数；与 keyword 同时传时为 AND）
levelId                 会员等级 ID（TB_CustomerLevel）
sourceId                信息来源 ID（TB_CustomerSource）
introducerCustomerId    介绍人客户 ID
nurseEmployeeId         主护理师员工 ID（匹配主护理师服务角色）
caregiverEmployeeId     护理师员工 ID（匹配名称含「护理」或「顾问」的服务角色）
memberOnFrom            成为会员日期起，格式 yyyy-MM-dd
memberOnTo              成为会员日期止，格式 yyyy-MM-dd
birthdayFrom            客户生日起，格式 yyyy-MM-dd
birthdayTo              客户生日止，格式 yyyy-MM-dd
createdOnFrom           注册日期起，格式 yyyy-MM-dd
createdOnTo             注册日期止，格式 yyyy-MM-dd
sortBy                  排序字段：lastTreatTime（上次消耗时间） / createdOn（注册日期，默认） / memberOn（成为会员日期）
sortOrder               排序方向：asc / desc，默认 desc；空值排在最后
```

说明：

```Plain Text
仅返回当前门店（或 storeId 指定且有权限的门店）在 TB_CustomerEntity 中建档的顾客
列表中的 mobile 为打码号码，11 位示例：138****5678
主护理师：TB_Servicer 优先取名称含「主护理」，否则「护理师」/「护理」
上次消费时间 lastSaleTime = TB_SaleBill 已支付/已退款最大 BillDate
上次消耗日期 lastTreatTime = TB_TreatBill 最大 BillDate（排除 TB_TreatBillCancelProcess 已取消单）
```

返回 data：

```JSON
{
  "total": 1,
  "page": 1,
  "size": 20,
  "records": [
    {
      "id": 10001,
      "code": "C00010001",
      "name": "张三",
      "storeId": 1001,
      "storeName": "杭州A店",
      "mobile": "138****0000",
      "gender": "1",
      "genderName": "男",
      "birthday": "1990-01-01",
      "nurseEmployeeId": "E001",
      "nurseName": "李护理",
      "sourceId": 1001,
      "sourceName": "自然到店",
      "introducerCustomerId": 2001,
      "introducerName": "王五",
      "member": true,
      "memberOn": "2024-01-15T10:00:00",
      "lastSaleTime": "2026-08-01T14:20:00",
      "lastTreatTime": "2026-08-20T11:00:00",
      "createdOn": "2023-12-01T09:00:00",
      "levelId": 1,
      "levelName": "金卡会员",
      "avatar": null,
      "remark": null,
      "address": null
    }
  ]
}
```

列表展示字段口径：客户姓名、客户编号、所属门店、手机号码（打码）、性别、生日、主护理师、信息来源、介绍人、会员等级、成为会员日期、上次消耗日期。

---

# 81.1 导出客户列表

```HTTP
GET /api/v1/customers/export
```

查询参数：与「81 查询客户」相同（忽略 page/size）；按相同筛选条件导出。

说明：

```Plain Text
响应为 XLSX 文件，Content-Type: application/vnd.openxmlformats-officedocument.spreadsheetml.sheet
Content-Disposition: attachment; filename*=UTF-8''customers-yyyyMMdd.xlsx
最多导出 10000 条；手机号打码规则同列表
表头：客户姓名,客户编号,所属门店,手机号码,性别,生日,主护理师,信息来源,介绍人,会员等级,成为会员日期,上次消耗日期
```

---

# 82 新增客户

```HTTP
POST /api/v1/customers
```

请求：

```JSON
{
  "name": "张三",
  "mobile": "13800000000",
  "gender": "1",
  "birthday": "1990-01-01",
  "sourceId": 1001,
  "introducerCustomerId": 2001,
  "remark": "到店咨询",
  "nurseEmployeeId": "E001"
}
```

字段：

```Plain Text
name                 必填，顾客姓名
mobile               必填，手机号
gender               必填，1 男 / 2 女 / 0 未知
sourceId             必填，信息来源 ID（须为有效来源，见 823 options）
birthday             可选，yyyy-MM-dd（是否展示由建档字段配置控制）
introducerCustomerId 可选，介绍人客户 ID
remark               可选，备注
address              可选，地址
nurseEmployeeId      可选，主护理师员工 ID
```

建档前建议调用：

```Plain Text
GET /api/v1/customer-sources/options          → 来源下拉
GET /api/v1/customer-form-fields/create-schema → 可见字段 schema
GET /api/v1/servicers/options                → 本店可选护理师（主护理师等）
```

业务：

```Plain Text
查询全局客户（按手机号）
 ↓
已存在且已在本店建档 → 返回客户重复
已存在但未绑定本店 → 绑定本店，可同时指定主护理师
不存在
 ↓
创建 TB_Customer
 ↓
创建 TB_CustomerEntity 归属本店
 ↓
可选写入 TB_CustomerServicer 主护理师
```

返回：同 8.4 客户详情（手机号为明文）。

---

# 83 修改客户

```HTTP
PUT /api/v1/customers/{id}
```

请求（未传的字段保持原值）：

```JSON
{
  "name": "张三",
  "mobile": "13800000000",
  "gender": "1",
  "birthday": "1990-01-01",
  "sourceId": 1001,
  "remark": "备注",
  "address": "杭州市",
  "nurseEmployeeId": "E001"
}
```

字段：

```Plain Text
name              可选，顾客姓名
mobile            可选，手机号；若与其他客户重复则失败
gender            可选，1 男 / 2 女 / 0 未知
birthday          可选
sourceId          可选
remark            可选
address           可选
nurseEmployeeId   可选，主护理师员工 ID；传空字符串表示清空主护理师
```

必须做（本期实现范围）：

```Plain Text
数据权限：仅允许修改当前门店已建档顾客
手机号全局去重
主护理师必须是已存在员工
```

尚未实现：

```Plain Text
字段权限
修改日志
```

返回：同 8.4 客户详情（手机号为明文）。

---

# 84 客户详情

```HTTP
GET /api/v1/customers/{id}
```

只返回顾客基本信息与汇总指标，不返回卡项列表、销售订单和销售明细，避免一次查询过慢。

手机号为明文。服务人员为主护理师。所属门店取 `TB_CustomerEntity.IsBelongEntity=1`；注册门店取该顾客最早建档门店。注册时间取 `TB_Customer.CreatedOn`。

客单（`guestVisitCount`）只统计消耗到店，不统计销售。同一天无论开了多少张消耗单（一次到店耗多个项目、或开单拆成多张单），都只算 1 个客单。已取消的消耗单不计入。

返回：

```JSON
{
  "id": 10001,
  "code": "C00010001",
  "name": "张三",
  "mobile": "13800000000",
  "gender": "1",
  "genderName": "男",
  "birthday": "1990-01-01",
  "nurseEmployeeId": "E001",
  "nurseName": "李护理",
  "storeId": 1001,
  "storeName": "杭州A店",
  "registerStoreId": 1001,
  "registerStoreName": "杭州A店",
  "createdOn": "2023-12-01T09:00:00",
  "levelId": 1,
  "levelName": "金卡",
  "lockMemberLevel": false,
  "member": true,
  "memberOn": "2024-01-15T10:00:00",
  "cardBalance": 1280.00,
  "giftBalance": 200.00,
  "saleAmount": 8600.00,
  "saleVisitCount": 12,
  "treatAmount": 3200.00,
  "guestVisitCount": 18,
  "treatVisitCount": 18,
  "arrearAmount": 500.00,
  "lastSaleTime": "2026-08-01T14:20:00",
  "lastTreatTime": "2026-08-20T11:00:00"
}
```

字段说明：

```Plain Text
levelId           当前会员等级 ID；当月无有效耗卡时可为 null
levelName         当前会员等级名称
lockMemberLevel   是否锁定会员等级（TB_Customer.IsLockMemberLevel）；true 时自动重算跳过
cardBalance       卡项余额：剩余有效金额折算合计，不含赠送
                  储值卡取剩余本金；项目/产品/次卡/时效卡按剩余次数×单价折算
giftBalance       赠送金额：储值卡剩余赠金 + 赠送项目/卡项按余量折算
saleAmount        累计消费金额：历史销售业绩 PayPerformance+SavingCardPerformance，不含赠送
saleVisitCount    销售到店天数：已支付/已退款销售单按自然日去重；这不是客单
treatAmount       累计消耗金额：历史消耗业绩 PayPerformance+CardPerformance，不含赠送
guestVisitCount   客单数（本业态口径）：只统计消耗到店；同一自然日无论开了多少张消耗单只算 1 个客单；销售开卡/买产品不计入；已取消消耗单不计入
treatVisitCount   与 guestVisitCount 相同，兼容「消耗次数」叫法
arrearAmount      欠款金额：各卡项账户剩余 ArrearAmount 合计
lastSaleTime      最近购买日期
lastTreatTime     最近消耗日期（最近一次有效客单日，已排除取消单）
createdOn         注册时间，不是客单
```

卡项、销售、支付、消耗、转账、服务日志请使用 8.6～8.13。耗卡可用权益仍使用：

```Plain Text
GET /api/v1/customers/{id}/assets
```

---

# 85 客户资产汇总

```HTTP
GET /api/v1/customers/{id}/assets
```

别名：

```HTTP
GET /api/v1/treat/customers/{customerId}/available-assets
```

用于耗卡开单页：返回当前顾客**仍可用**的权益账户（有余量、未失效）。与 8.6「剩余卡项」不同：本接口按耗卡可用维度分组，不分页。

返回：

```JSON
{
  "projects": [
    {
      "accountId": 1,
      "projectId": 101,
      "name": "头皮护理",
      "balance": 3,
      "packageCardAccountId": null,
      "canUse": true
    }
  ],
  "products": [
    {
      "accountId": 2,
      "productId": 201,
      "name": "洗发水",
      "balance": 1,
      "packageCardAccountId": null,
      "canUse": true
    }
  ],
  "saving": [
    {
      "accountId": 3,
      "savingCardId": 301,
      "name": "储值金卡",
      "principalBalance": 1000.00,
      "bonusBalance": 200.00,
      "validDate": "2027-01-10T11:00:00",
      "packageCardAccountId": null,
      "canUse": true
    }
  ],
  "packageCards": [
    {
      "accountId": 4,
      "packageCardId": 401,
      "name": "养发套餐",
      "validDate": "2027-01-10T11:00:00",
      "canUse": true
    }
  ],
  "generalCards": [
    {
      "accountId": 5,
      "generalCardId": 501,
      "name": "通用10次卡",
      "balance": 6,
      "validDate": "2027-01-10T11:00:00",
      "packageCardAccountId": null,
      "canUse": true
    }
  ],
  "timeCards": [
    {
      "accountId": 6,
      "timeCardId": 601,
      "name": "时效护理卡",
      "performanceBalance": 8,
      "validDate": "2027-01-10T11:00:00",
      "packageCardAccountId": null,
      "canUse": true
    }
  ]
}
```

```Plain Text
projects        项目账户（余额为剩余次数）
products        产品账户（余额为剩余数量）
saving          储值卡账户（本金 principalBalance + 赠金 bonusBalance）
packageCards    套餐卡账户
generalCards    通用次卡账户
timeCards       时效卡账户（performanceBalance 为剩余次数）
canUse          是否当前可用
```

这是耗卡页面的核心接口。顾客详情页卡项一览请用 8.6。

---

# 86 顾客剩余卡项

```HTTP
GET /api/v1/customers/{id}/cards
```

查询参数：

```Plain Text
itemType             可选。项目 / 储值卡 / 时效卡 / 通用次卡 / 套餐卡 / 产品
                     也可传 PROJECT / SAVING_CARD / TIME_CARD / GENERAL_CARD / PACKAGE_CARD / PRODUCT
                     不传则返回全部剩余卡项
page                 页码，默认 1
size                 每页条数，默认 20，最大 100
```

只返回仍有余量且未过期的卡项。套餐卡按套餐内剩余有效金额折算，金额为 0 的不展示。

返回 records 字段：

```JSON
{
  "accountId": 9001,
  "itemType": "SAVING_CARD",
  "itemTypeName": "储值卡",
  "name": "储值金卡",
  "storeId": 1001,
  "storeName": "杭州A店",
  "buyDate": "2026-01-10T11:00:00",
  "price": 3000.00,
  "payAmount": 2800.00,
  "cardDeductionAmount": 200.00,
  "validDate": "2027-01-10T11:00:00",
  "balance": 1280.00,
  "balanceAmount": 1280.00,
  "source": "购买"
}
```

```Plain Text
name                   名称
storeName              开卡门店
buyDate                开单时间
price                  卡售价
payAmount              实付
cardDeductionAmount    卡扣（储值本金抵扣）
validDate              有效期
balance                余量：储值卡为剩余本金+赠金，次数类为剩余次数，套餐卡为剩余折算金额
balanceAmount          剩余有效金额折算（不含赠送）
source                 来源：购买 / 赠送 / 套餐
```

---

# 87 顾客销售订单

```HTTP
GET /api/v1/customers/{id}/sales
```

查询参数：

```Plain Text
employeeId           开单人员工 ID
employeeName         开单人姓名模糊搜索
page                 页码，默认 1
size                 每页条数，默认 20，最大 100
```

返回 records 字段：

```JSON
{
  "id": "S20260801001",
  "totalAmount": 1280.00,
  "billType": "销售",
  "billStatus": "已支付",
  "storeId": 1001,
  "storeName": "杭州A店",
  "employeeId": "E001",
  "employeeName": "王开单",
  "createdOn": "2026-08-01T14:18:00",
  "billDate": "2026-08-01T14:20:00"
}
```

```Plain Text
id            订单编号
totalAmount   订单总金额
billType      订单类型
billStatus    订单状态
storeName     开单门店
employeeName  开单人
createdOn     录单时间
billDate      下单时间
```

---

# 88 顾客销售明细

```HTTP
GET /api/v1/customers/{id}/sale-items
```

查询参数：

```Plain Text
employeeId           开单人员工 ID
employeeName         开单人姓名模糊搜索
page                 页码，默认 1
size                 每页条数，默认 20，最大 100
```

套餐卡作为一行展示，不展开套餐内项目，避免与套餐内账户重复。

返回 records 字段：

```JSON
{
  "billId": "S20260801001",
  "billStatus": "已支付",
  "storeId": 1001,
  "storeName": "杭州A店",
  "employeeId": "E001",
  "employeeName": "王开单",
  "itemType": "PROJECT",
  "itemTypeName": "项目",
  "categoryName": "养发",
  "itemName": "头皮护理",
  "price": 198.00,
  "quantity": 1,
  "gift": false,
  "totalAmount": 198.00,
  "giftAmount": 0,
  "arrearAmount": 0,
  "payAmount": 198.00,
  "billDate": "2026-08-01T14:20:00"
}
```

```Plain Text
billId         订单编号
billStatus     状态
storeName      开单门店
employeeName   开单人
itemTypeName   商品类型
categoryName   商品分类
itemName       商品名称
price          商品单价
quantity       商品数量
gift           是否赠送
totalAmount    合计金额
giftAmount     赠送金额
arrearAmount   欠款金额
payAmount      实收金额（合计-欠款；赠送行为 0）
```

---

# 89 顾客支付明细

```HTTP
GET /api/v1/customers/{id}/payments
```

查询该顾客销售单的支付流水（`TB_SaleBillPay`），一行一笔支付。

查询参数：

```Plain Text
employeeId           录单人/开单人员工 ID
employeeName         录单人姓名模糊搜索
page                 页码，默认 1
size                 每页条数，默认 20，最大 100
```

返回 records 字段：

```JSON
{
  "billId": "S20260801001",
  "billType": "销售",
  "storeId": 1001,
  "storeName": "杭州A店",
  "employeeId": "E001",
  "employeeName": "王开单",
  "totalAmount": 1280.00,
  "payType": "实收",
  "payMethodName": "微信",
  "payAmount": 1280.00,
  "orderAmount": 1280.00,
  "createdOn": "2026-08-01T14:18:00"
}
```

```Plain Text
billId           订单编号
billType         订单类型
storeName        开单门店
employeeName     开单人/录单人
totalAmount      订单金额（销售单 TotalAmount）
payType          支付类型：实收 / 储值卡扣（按支付方式名称含「储值」判断）
payMethodName    支付方式：微信 / 支付宝 / 银行卡 / 现金…
payAmount        本笔支付金额
orderAmount      下单金额（销售单 Amount）
createdOn        录单时间
```

---

# 810 顾客消耗订单

```HTTP
GET /api/v1/customers/{id}/treats
```

查询参数：

```Plain Text
keyword              订单编号模糊搜索
billStatus           订单状态（库内值，如 1）
employeeId           开单人员工 ID
employeeName         开单人姓名模糊搜索
page                 页码，默认 1
size                 每页条数，默认 20，最大 100
```

返回 records 字段：

```JSON
{
  "id": "T20260820001",
  "amount": 198.00,
  "billType": "消耗",
  "billStatus": "1",
  "billStatusName": "已完成",
  "storeId": 1001,
  "storeName": "杭州A店",
  "employeeId": "E001",
  "employeeName": "王开单",
  "createdOn": "2026-08-20T10:58:00",
  "billDate": "2026-08-20T11:00:00"
}
```

```Plain Text
id               订单编号
amount           消耗金额
billType         订单类型
billStatus       订单状态码
billStatusName   订单状态中文（1=已完成）
storeName        开单门店
createdOn        录单时间
billDate         订单时间
```

---

# 811 顾客消耗明细

```HTTP
GET /api/v1/customers/{id}/treat-items
```

查询参数同 8.10（keyword / billStatus / employeeId / employeeName / page / size）。

合并项目、产品、通用次卡、时效卡、储值卡消耗明细为一列表。

返回 records 字段：

```JSON
{
  "billId": "T20260820001",
  "billStatus": "1",
  "billStatusName": "已完成",
  "billType": "消耗",
  "storeId": 1001,
  "storeName": "杭州A店",
  "itemType": "GENERAL_CARD",
  "itemTypeName": "通用次卡",
  "cardName": "通用10次卡",
  "categoryName": "护理",
  "itemName": "头皮护理",
  "price": 198.00,
  "quantity": 1,
  "gift": false,
  "totalAmount": 198.00,
  "payAmount": 0,
  "cardDeductionAmount": 198.00,
  "largessCardDeductionAmount": 0,
  "billDate": "2026-08-20T11:00:00"
}
```

```Plain Text
billId                      订单编号
billStatus / billStatusName 订单状态
billType                    类型
storeName                   开单门店
itemTypeName                商品类型
cardName                    卡名称（项目/产品可为空或套餐名）
categoryName                商品分类
itemName                    商品名称（耗卡时多为消耗的项目名）
price                       商品单价
quantity                    商品数量
gift                        是否赠送
totalAmount                 合计金额
payAmount                   现金金额
cardDeductionAmount         卡扣金额（储值本金扣额对应 CardTreatAmount）
largessCardDeductionAmount  赠送卡扣金额
```

---

# 812 顾客转账记录

```HTTP
GET /api/v1/customers/{id}/transfers
```

查询该顾客作为转出或转入方的卡项转账单（`TB_TransferBill`）。

查询参数：

```Plain Text
keyword              订单编号模糊搜索
employeeId           录单人员工 ID（CreatedBy）
employeeName         录单人姓名模糊搜索
createdOnFrom        申请时间起，yyyy-MM-dd
createdOnTo          申请时间止，yyyy-MM-dd
page                 页码，默认 1
size                 每页条数，默认 20，最大 100
```

返回 records 字段：

```JSON
{
  "id": "TF20260701001",
  "outCustomerId": 10001,
  "outCustomerName": "张三",
  "inCustomerId": 10002,
  "inCustomerName": "李四",
  "storeId": 1001,
  "storeName": "杭州A店",
  "employeeId": "E001",
  "employeeName": "王开单",
  "billStatus": "已完成",
  "createdOn": "2026-07-01T15:00:00"
}
```

```Plain Text
id                 订单编号
outCustomerName    转出顾客
inCustomerName     转入顾客
storeName          操作门店
employeeName       录单人
createdOn          订单时间/申请时间
```

---

# 813 顾客服务日志

```HTTP
GET /api/v1/customers/{id}/service-logs
```

护理服务日志（`TB_NursingLog`）。

查询参数：

```Plain Text
createdOnFrom        日志时间起，yyyy-MM-dd
createdOnTo          日志时间止，yyyy-MM-dd
page                 页码，默认 1
size                 每页条数，默认 20，最大 100
```

返回 records 字段：

```JSON
{
  "id": 501,
  "nurseEmployeeId": "E002",
  "nurseName": "李护理",
  "content": "今日头皮护理情况良好…",
  "createdOn": "2026-08-20T11:30:00",
  "storeId": 1001,
  "storeName": "杭州A店"
}
```

```Plain Text
nurseName     护理师（日志创建人）
content       日志内容
createdOn     日志时间
```

---

# 814 系统标签分页列表

```HTTP
GET /api/v1/customer-tags
```

系统标签库（`TB_TagLibrary`）分页查询。

查询参数：

```Plain Text
keyword              标签名称模糊搜索
page                 页码，从 1 起，默认 1
size                 每页条数，默认 20，最大 100
```

返回 data：

```JSON
{
  "total": 2,
  "page": 1,
  "size": 20,
  "records": [
    { "id": 1, "name": "新客" },
    { "id": 2, "name": "高价值" }
  ]
}
```

---

# 815 系统全部标签

```HTTP
GET /api/v1/customer-tags/all
```

返回系统标签全量列表（最多 2000 条，按下拉选择场景使用），`data` 为数组：

```JSON
[
  { "id": 1, "name": "新客" },
  { "id": 2, "name": "高价值" }
]
```

---

# 816 系统标签详情

```HTTP
GET /api/v1/customer-tags/{id}
```

返回：

```JSON
{ "id": 1, "name": "新客" }
```

标签不存在时 `code=10000`。

---

# 817 新增系统标签

```HTTP
POST /api/v1/customer-tags
```

请求：

```JSON
{
  "name": "重点维护"
}
```


| 字段   | 类型     | 必填  | 说明              |
| ---- | ------ | --- | --------------- |
| name | string | 是   | 标签名称，最长 50，全局唯一 |


返回：新建后的标签对象。名称重复时 `code=10000`。

---

# 818 修改系统标签

```HTTP
PUT /api/v1/customer-tags/{id}
```

请求：

```JSON
{
  "name": "沉睡客"
}
```

返回：更新后的标签对象。名称与其它标签重复时 `code=10000`。

---

# 819 删除系统标签

```HTTP
DELETE /api/v1/customer-tags/{id}
```

删除标签库中的标签，并解除所有顾客对该标签的贴标关系。成功时 `data=null`。

---

# 820 查询顾客标签

```HTTP
GET /api/v1/customers/{id}/tags
```

返回该顾客已贴标签列表（须为本店顾客）：

```JSON
[
  {
    "id": 1,
    "name": "新客",
    "createdOn": "2026-09-10T10:00:00"
  }
]
```

```Plain Text
id           标签 ID
name         标签名称
createdOn    贴标时间
```

---

# 821 给顾客贴标

```HTTP
POST /api/v1/customers/{id}/tags
```

请求（`tagId` 与 `tagIds` 至少传其一；同时传时合并去重）：

```JSON
{
  "tagId": 1,
  "tagIds": [2, 3]
}
```

说明：已存在的标签会跳过，不报错；返回贴标后该顾客的全部标签列表（同 820）。

---

# 822 删除顾客标签

```HTTP
DELETE /api/v1/customers/{id}/tags/{tagId}
```

删除该顾客与指定标签的贴标关系（不删除系统标签本身）。顾客未贴该标签时 `code=10000`；成功时 `data=null`。

---

# 823 信息来源分页（管理端）

```HTTP
GET /api/v1/customer-sources
```

查询参数：

```Plain Text
keyword     名称模糊
active      true/false；不传不过滤
parentId    父级来源 ID；不传不过滤
page        默认 1
size        默认 20，最大 100
```

返回 records：

```JSON
{ "id": 1, "name": "自然到店", "parentId": 0, "sequence": 10, "active": true }
```

---

# 824 信息来源下拉（建档用）

```HTTP
GET /api/v1/customer-sources/options
```

仅返回 `active=true` 的来源，供创建顾客前选择。`data` 为数组，元素同 823。

---

# 825 信息来源详情

```HTTP
GET /api/v1/customer-sources/{id}
```

---

# 826 新增信息来源

```HTTP
POST /api/v1/customer-sources
```

请求：

```JSON
{
  "name": "老客介绍",
  "parentId": 0,
  "sequence": 20,
  "active": true
}
```


| 字段       | 类型      | 必填  | 说明              |
| -------- | ------- | --- | --------------- |
| name     | string  | 是   | 来源名称，最长 50，全局唯一 |
| parentId | int     | 否   | 父级，默认 0         |
| sequence | int     | 否   | 排序，默认 0         |
| active   | boolean | 否   | 默认 true         |


---

# 827 修改信息来源

```HTTP
PUT /api/v1/customer-sources/{id}
```

请求：

```JSON
{
  "name": "老客介绍",
  "parentId": 0,
  "sequence": 20,
  "active": false
}
```

`name` / `parentId` / `sequence` / `active` 均必填。停用后来源不会出现在 options 中，已建档顾客历史数据保留。

---

# 828 删除信息来源

```HTTP
DELETE /api/v1/customer-sources/{id}
```

若仍有子级来源，或仍有顾客引用该来源，返回 `code=10000`（可改为停用）；成功时 `data=null`。

---

# 829 建档字段配置列表（管理端）

```HTTP
GET /api/v1/customer-form-fields
```

返回全部字段配置（含固定必填与可选展示），按 `sequence` 排序：

```JSON
[
  { "fieldCode": "name", "fieldName": "姓名", "visible": true, "required": true, "builtin": true, "sequence": 10 },
  { "fieldCode": "mobile", "fieldName": "手机号码", "visible": true, "required": true, "builtin": true, "sequence": 20 },
  { "fieldCode": "gender", "fieldName": "性别", "visible": true, "required": true, "builtin": true, "sequence": 30 },
  { "fieldCode": "sourceId", "fieldName": "信息来源", "visible": true, "required": true, "builtin": true, "sequence": 40 },
  { "fieldCode": "birthday", "fieldName": "生日", "visible": false, "required": false, "builtin": true, "sequence": 50 }
]
```

固定必填字段编码：`name` / `mobile` / `gender` / `sourceId`（不可隐藏、不可删除）。

可选字段编码：`birthday` / `introducerCustomerId` / `nurseEmployeeId` / `remark` / `address`。

---

# 830 建档表单 schema（前端建档页）

```HTTP
GET /api/v1/customer-form-fields/create-schema
```

仅返回 `visible=true` 的字段，前端按此渲染创建顾客表单。固定必填字段始终包含。

---

# 831 建档字段配置详情

```HTTP
GET /api/v1/customer-form-fields/{fieldCode}
```

---

# 832 新增建档字段配置

```HTTP
POST /api/v1/customer-form-fields
```

请求：

```JSON
{
  "fieldCode": "address",
  "fieldName": "联系地址",
  "visible": true,
  "sequence": 90
}
```

仅允许已知可选字段编码；若已存在请用修改接口。固定必填字段不可通过本接口新增。

---

# 833 修改建档字段配置

```HTTP
PUT /api/v1/customer-form-fields/{fieldCode}
```

请求：

```JSON
{
  "fieldName": "生日",
  "visible": true,
  "sequence": 50
}
```

固定必填字段不可将 `visible` 设为 false。

---

# 834 删除建档字段配置

```HTTP
DELETE /api/v1/customer-form-fields/{fieldCode}
```

内置字段不可删除（可选字段可改为 `visible=false`）。非内置成功删除时 `data=null`。

表结构脚本：`db/erp_customer_form_field.sql`。

---

# 835 建档可选护理师（服务人员）

```HTTP
GET /api/v1/servicers/options
```

创建顾客选择主护理师时调用。按**当前登录用户已切换的门店**（或指定有权限的 `storeId`）返回：建档可展示的服务角色（`TB_Servicer.AddWhetherToShow=true` 且 `Active=true`），以及该门店下职务匹配的员工列表。

查询参数：

```Plain Text
storeId    可选，门店 ID；默认取当前切换门店；须在员工门店权限内
```

口径：

```Plain Text
服务角色来自 TB_Servicer（如主护理师、辅护理师）
本店员工 = TK_EmployeeEntity.EntityID = 当前门店 且 TK_Employee.State=1
员工须职务匹配 TB_ServicerJobType（ServicerID + JobTypeID=员工.JobID）
未配置适用职务的角色返回空员工列表
建档写主护理师时取「主护理师」角色下员工的 id，作为 nurseEmployeeId 传入 POST /customers
```

返回 data（统一包装为 `code/message/data`；字段为 camelCase，语义对齐旧接口）：

```JSON
[
  {
    "id": 1,
    "name": "主护理师",
    "addWhetherToShow": true,
    "entityRange": "10",
    "active": true,
    "entityId": 1001,
    "jobTypeList": null,
    "servicerEmpList": [
      { "id": "1072", "servicerId": 1, "name": "马芳红" },
      { "id": "9023", "servicerId": 1, "name": "曾凡薇" }
    ]
  },
  {
    "id": 2,
    "name": "辅护理师",
    "addWhetherToShow": true,
    "entityRange": "10",
    "active": true,
    "entityId": 1001,
    "jobTypeList": null,
    "servicerEmpList": []
  }
]
```

```Plain Text
id / name / addWhetherToShow / entityRange / active   服务角色
entityId                                              当前查询门店 ID
servicerEmpList[].id                                  员工 ID（即 nurseEmployeeId）
servicerEmpList[].name                                员工姓名
```

种子脚本（库中无服务角色时可执行）：`db/erp_servicer_seed.sql`。

---

# 九、商品API

# 91 产品列表

```HTTP
GET /api/v1/products
```

条件：

```Plain Text
keyword
categoryId
brandId
status
storeId
```

---

# 92 项目列表

```HTTP
GET /api/v1/projects
```

支持：

```Plain Text
keyword
categoryId
sellable
consumable
page
size
```

权限：`project:view`

---

# 92A 项目分类列表

```HTTP
GET /api/v1/project-categories
```

支持：

```Plain Text
keyword
parentId
active
page
size
```

权限：`project:category:view`

---

# 92B 项目分类树

```HTTP
GET /api/v1/project-categories/tree?onlyActive=false
```

权限：`project:category:view`

---

# 92C 新增项目分类

```HTTP
POST /api/v1/project-categories
```

Body：

```JSON
{
  "name": "护理",
  "parentId": 0,
  "sequence": 1,
  "active": true
}
```

说明：最多两级；`parentId=0` 为一级。权限：`project:category:edit`

---

# 92D 修改 / 停用项目分类

```HTTP
PUT /api/v1/project-categories/{id}
DELETE /api/v1/project-categories/{id}
```

`DELETE` 为停用（`Active=false`），非物理删除。权限：`project:category:edit`

---

# 92E 新增项目

```HTTP
POST /api/v1/projects
```

Body：

```JSON
{
  "name": "头皮护理",
  "alias": "头护",
  "categoryId": 1,
  "price": 198.00,
  "treatTime": 60,
  "allowSell": true,
  "allowConsume": true,
  "allowLargess": false,
  "remark": ""
}
```

权限：`project:edit`。价格为总部基础价（`TB_Project.Price`）。

---

# 93 项目详情

```HTTP
GET /api/v1/projects/{id}
```

返回：

```Plain Text
项目基本信息
总部基础价 price
服务时长 treatTime
可售 allowSell
可耗 allowConsume
分类 categoryId / categoryName
```

权限：`project:view`

---

# 91A 销售方式列表

```HTTP
GET /api/v1/sale-channels
```

支持：`keyword` `parentId` `active` `page` `size`

权限：`sale-channel:view`

说明：配置化字典 `TB_SaleChannel`；**不是**旧表 `TB_Channel`（渠道商）。销售渠道 ≠ 支付方式。

---

# 91B 销售方式树 / 收银选项

```HTTP
GET /api/v1/sale-channels/tree?onlyActive=false
GET /api/v1/sale-channels/options
```

`options` 仅返回**有效叶子**。单据 `Channel` 写入叶子 **Code**（如 `MEITUAN`）。

权限：`sale-channel:view`

---

# 91C 销售方式增改停用

```HTTP
GET /api/v1/sale-channels/{id}
POST /api/v1/sale-channels
PUT /api/v1/sale-channels/{id}
DELETE /api/v1/sale-channels/{id}
```

Body 示例：

```JSON
{
  "code": "XHS",
  "name": "小红书",
  "parentId": 1,
  "sequence": 17,
  "active": true
}
```

最多两级；`DELETE`=停用。写权限：`sale-channel:edit`

---

# 91D 价格区域

```HTTP
GET /api/v1/price-areas
GET /api/v1/price-areas/{id}
POST /api/v1/price-areas
PUT /api/v1/price-areas/{id}
DELETE /api/v1/price-areas/{id}
```

权限：`price:area:view` / `price:area:edit`

---

# 91E 开单渠道价列表（CONF-009）

```HTTP
GET /api/v1/prices/by-channels?storeId=&itemType=PROJECT&itemId=
```

返回每个**有效叶子销售渠道**及其对应价格（供前端列出渠道供用户选择）。

同渠道取价顺序：

```text
已生效单店特价（SPECIAL_STORE）
  → 有效活动价（ACTIVITY）
  → 门店渠道价
  → 区域渠道价
  → 总部渠道价
  → 货品主数据基价
```

**不做**特价/活动/区域/总部跨类型优先级瀑布列表；特价与活动均为所选渠道展示价的覆盖来源。

权限：`price:quote`

---

# 91F 选定渠道报价

```HTTP
GET /api/v1/prices/quote?storeId=&itemType=PROJECT&itemId=&saleChannelId=
```

必须传 `saleChannelId`。同渠道作用域见 91E；可返回 `SPECIAL_STORE` / `ACTIVITY`（含 `activityId`）及 `allowAdjust`/`minPrice`。

权限：`price:quote`

---

# 91G 配置渠道货品价 / 门店挂区域

```HTTP
POST /api/v1/sale-channel-prices
DELETE /api/v1/sale-channel-prices/{id}
PUT /api/v1/stores/{storeId}/price-area
```

Body 示例（总部渠道价）：

```JSON
{
  "saleChannelId": 3,
  "itemType": "PROJECT",
  "itemId": 10,
  "price": 599.00,
  "priceAreaId": 0,
  "entityId": 0
}
```

门店价：`entityId=门店ID` 且 `priceAreaId=0`；区域价：`priceAreaId>0` 且 `entityId=0`。

权限：`price:channel:edit`；挂区域：`org:store:edit`

---

# 91H 活动体系

```HTTP
GET    /api/v1/activities
GET    /api/v1/activities/{id}
POST   /api/v1/activities
PUT    /api/v1/activities/{id}
DELETE /api/v1/activities/{id}
PUT    /api/v1/activities/{id}/prices
PUT    /api/v1/activities/{id}/stores
```

活动类型：`UNIFIED`（统一）/ `STORE_SPECIAL`（单店特殊）。

- 统一活动：`allStores=true` 或指定 `storeIds`
- 单店特殊：禁止全店，必须 `storeIds`
- 明细价绑定**叶子** `saleChannelId`；卡类不可配活动价
- 重叠活动：`BeginDateTime` 最晚优先，相同取 ID 最大

新建示例：

```JSON
{
  "name": "国庆活动",
  "activityType": "UNIFIED",
  "beginDateTime": "2026-10-01T00:00:00",
  "endDateTime": "2026-10-07T23:59:59",
  "allStores": true,
  "active": true
}
```

明细价示例：

```JSON
{
  "prices": [
    { "itemType": "PROJECT", "itemId": 10, "saleChannelId": 9, "price": 168.00 }
  ]
}
```

权限：`activity:view` / `activity:edit`

---

# 91I 单店特价申请 / 生效价

```HTTP
GET    /api/v1/special-price-applies
GET    /api/v1/special-price-applies/{id}
POST   /api/v1/special-price-applies
POST   /api/v1/special-price-applies/{id}/submit
POST   /api/v1/special-price-applies/{id}/approve
POST   /api/v1/special-price-applies/{id}/reject
POST   /api/v1/special-price-applies/{id}/cancel
GET    /api/v1/special-store-prices?storeId=&projectId=
DELETE /api/v1/special-store-prices?storeId=&projectId=
```

状态：`DRAFT` → `SUBMITTED` → `APPROVED` / `REJECTED`；可 `CANCELLED`。  
审批通过写入 `TB_ProjectPriceAdjustment`；删除生效行即撤销特价。  
V1 仅 `PROJECT`；无渠道维 → 该店该项目各叶子渠道同显 `SPECIAL_STORE`。

权限：`special-price:view` / `special-price:apply` / `special-price:approve`

---

# 91J 临时改价权限与校验

```HTTP
GET    /api/v1/price-change-permissions
POST   /api/v1/price-change-permissions
PUT    /api/v1/price-change-permissions/{id}
DELETE /api/v1/price-change-permissions/{id}
GET    /api/v1/projects/{projectId}/modify-price-stores
PUT    /api/v1/projects/{projectId}/modify-price-stores
POST   /api/v1/prices/change/validate
```

临时改价允许条件：功能权 `price:change` + `ModifyPriceEntity` 白名单 + 命中 C-07 规则 + 目标价在 [minPrice, 基准价] + 原因非空。  
禁止上调；多规则取最严最低价。报价 `allowAdjust`/`minPrice` 由规则填充。

权限：配置 `price:change:config`；校验 `price:change`

---

# 十、卡项API

---

# 101 储值卡产品列表

```HTTP
GET /api/v1/cards/saving
```

权限：`card:saving:view`（`storeCheck=false`）

查询参数：`onlySellable`（可选）

---

# 102 储值卡详情

```HTTP
GET /api/v1/cards/saving/{id}
```

权限：`card:saving:view`

返回：本金 `price`、赠金 `largessPrice`、有效期、销售窗口、可售状态。

---

# 102A 卡类商品定义（通用次卡 / 时效卡 / 储值卡 / 套餐卡）

路径前缀（均 `storeCheck=false`）：


| 前缀                      | 权限 view / edit                            |
| ----------------------- | ----------------------------------------- |
| `/api/v1/cards/general` | `card:general:view` / `card:general:edit` |
| `/api/v1/cards/time`    | `card:time:view` / `card:time:edit`       |
| `/api/v1/cards/saving`  | `card:saving:view` / `card:saving:edit`   |
| `/api/v1/cards/package` | `card:package:view` / `card:package:edit` |



| 方法     | 路径      | 说明                         |
| ------ | ------- | -------------------------- |
| GET    | `/`     | 列表；`onlySellable` / `sortField` / `sortOrder` 可选 |
| GET    | `/{id}` | 详情                         |
| POST   | `/`     | 创建                         |
| PUT    | `/{id}` | 更新                         |
| DELETE | `/{id}` | 停售（`allowSell=false`，非物理删） |


约定：

- 次卡详情含 `unitDesignPrice = price/amount`（展示用，不落项目行）
- 套餐明细合计**不强制**等于卡售价
- 储值本金/赠金分列；B-05 `UnitPriceSnapshot` 本模块只加列，销售开户写入
- 卡类**不**走项目 PriceResolution
- **列表排序**（`GET /`）：
  - 参数：`sortField`、`sortOrder`（`asc`/`desc`，大小写不敏感）
  - 白名单：`id` / `name` / `price` / `allowSell`（对应列 ID、Name、Price、IsAllowSell）
  - 未传 `sortField`：默认 `id desc`（与改造前一致）
  - 非法字段：`code=PARAM`，提示「不支持的排序字段」
  - 表结构无 `CreatedOn`，不支持 `createdOn`

---

# 102B 储值卡区域折扣

```HTTP
GET    /api/v1/saving-card-discounts
GET    /api/v1/saving-card-discounts/{id}
POST   /api/v1/saving-card-discounts
PUT    /api/v1/saving-card-discounts/{id}
DELETE /api/v1/saving-card-discounts/{id}
```

权限：`card:saving-discount:view` / `card:saving-discount:edit`（`storeCheck=false`）

列表过滤：`priceAreaId`、`projectId`（可选）

列表排序：`sortField` / `sortOrder`；白名单 `id` / `active` / `discountRate`；默认 `id desc`；非法字段拒绝。表无 Name/Price/CreatedOn。

正文：`priceAreaId`、`projectId`、`discountRate`(0,1]、`beginDate`/`endDate`、`active`、`remark`

规则：同 PriceArea+Project 且 Active 的有效期**禁止重叠**；DELETE=停用。

域查询：`SavingCardDiscountQuery.findDiscountRate` 供耗卡模块调用。

---

# 103 会员储值账户

```HTTP
GET /api/v1/customers/{customerId}/saving-accounts
```

返回：

```Plain Text
账户
本金余额
赠金余额
有效期
来源门店
状态
```

---

# 104 查询某张储值账户流水

```HTTP
GET /api/v1/saving-accounts/{accountId}/transactions
```

---

# 十一、销售API

这是核心接口。

---

# 111 创建销售订单

```HTTP
POST /api/v1/sales/orders
```

权限：`sale:order:create`（补单业务日另需 `sale:order:backdate`）

请求：

```JSON
{
  "customerId": 10001,
  "storeId": 1001,
  "saleChannelId": 11,
  "billDate": "2026-09-10",
  "arrearAmount": 500.00,
  "remark": null,
  "items": [
    {
      "itemType": "SAVING_CARD",
      "itemId": 3001,
      "quantity": 1,
      "largessAmount": 100.00,
      "arrearAmount": 500.00
    },
    {
      "itemType": "PROJECT",
      "itemId": 4001,
      "quantity": 1,
      "price": 180.00,
      "priceChangeReason": "店长特批"
    }
  ],
  "handlers": [
    { "employeeId": "2001", "ratio": 60 },
    { "employeeId": "2002", "ratio": 40 }
  ],
  "payments": [
    { "method": "WECHAT", "amount": 500.00 }
  ]
}
```


| 字段                    | 说明                                             |
| --------------------- | ---------------------------------------------- |
| saleChannelId         | **必填**叶子销售渠道 ID；单据 `Channel` 写 Code            |
| billDate              | 可选业务日；空=今天；回溯须本月内且有补单权限；`CreatedOn` 仍为录入时刻     |
| arrearAmount          | 整单欠尾款；`PayAmount + ArrearAmount = TotalAmount` |
| items[].price         | 项目可改价（须改价权限+原因）；卡类须等于定义价或标记 gift               |
| items[].largessAmount | 赠金**显式**入账；不传则赠金余额 0（不做自动赠送）                   |
| items[].arrearAmount  | 行欠款；空则按金额比例分摊整单欠款                              |
| handlers              | ≥1；ratio 合计 100%                               |
| payments              | 可选；带渠道则开单即完成；金额空时默认收 `Total-arrearAmount`      |


后端：权限/门店范围 → 经手人比例 → 业务日 → `SalePricing` 取价（按 BillDate）→ 分摊欠款 → 写单/明细/经手人 →（有支付）记渠道、关单、发卡、业绩。

业绩与账户 `EntityID` = **开单门店**；不改写顾客所属门店。

---

# 112 查询销售订单

```HTTP
GET /api/v1/sales/orders/{id}
```

权限：`sale:order:view`

返回含：`saleStoreId/Name`、`customerBelongStoreId/Name`、`saleChannelCode`、`arrearAmount`、明细与支付渠道。

---

# 113 销售订单列表

```HTTP
GET /api/v1/sales/orders
```

支持：`customerId` `status` `page` `size`（当前按登录门店过滤）。

权限：`sale:order:view`

---

# 114 修改销售订单

```HTTP
PUT /api/v1/sales/orders/{id}
```

**本模块未实现**（已支付禁止普通修改；草稿改单留后续）。

---

# 115 关闭未支付订单

```HTTP
POST /api/v1/sales/orders/{id}/close
```

权限：`sale:order:close`

---

# 十二、支付API

---

# 121 获取可用支付方式

```HTTP
GET /api/v1/payments/methods
```

按照门店返回允许支付的方式。权限：`sale:order:view`

---

# 122 销售订单支付

```HTTP
POST /api/v1/sales/orders/{id}/pay
```

权限：`sale:order:pay`

请求：

```JSON
{
  "payments": [
    { "method": "WECHAT", "amount": 200 },
    { "method": "CASH", "amount": 100 }
  ]
}
```

规则：`sum(payments) ≤ TotalAmount`；差额写入 `ArrearAmount`；关单后发卡入账（储值：`Balance=面值-欠款`，`LargessBalance=显式赠金`）并写开单门店业绩。

---

# 123 储值支付

例如：

```JSON
{
  "method": "SAVING_CARD",
  "accountId": 90001,
  "principalAmount": 100,
  "bonusAmount": 200
}
```

后端必须校验账户/本金/赠金并扣减。

---

# 124 混合支付

支持微信+现金+储值；一次请求多个 payment；`sum ≤ receivable`（差额为欠款）。

---

# 124A 储值账户欠款平账

```HTTP
POST /api/v1/saving-card-accounts/{accountId}/arrear-repay
```

权限：`sale:arrear:repay`

请求：

```JSON
{
  "amount": 200.00,
  "storeId": 1001,
  "remark": "补尾款"
}
```

返回：`accountId`、`amount`、`before/afterArrearAmount`、`before/afterBalance`。

语义：`ArrearAmount -= amount`，`Balance += amount`（付多少本金录多少可用）；同步减少关联销售单头欠款；写入 `TB_ErpSavingCardArrearRepay` 审计。

---

# 十三、销售完成后的业务动作

支付成功后，不建议前端再分别调用：

```Plain Text
创建会员账户
创建业绩
...
```

而应该：

```Plain Text
POST /sales/orders/{id}/pay
```

内部统一完成：

```Plain Text
支付
 ↓
销售完成
 ↓
生成销售结果
 ↓
产生会员权益
 ↓
生成销售业绩
```

这样可以避免前端漏调用。

---

# 十四、消耗/耗卡API

这是整个系统最核心的API组。本模块（2026-09-16）已按 CONF-014～019 落地：多人护理师、本月补单、跨店全号选客、耗材开关扣库、签字开关、本月取消回滚。

权限：`treat:order:view|create|cancel|backdate|edit-handler`；`treat:config:edit`。

---

# 141 查询会员可用权益

```HTTP
GET /api/v1/treat/customers/{customerId}/available-assets
```

权限：`treat:order:view`

---

# 141A 跨店选客（完整手机号）

```HTTP
GET /api/v1/treat/customers/search?mobile=13800138000
```

须 11 位完整手机号精确匹配；返回 `customerId`。

---

# 141B 耗卡总部配置

```HTTP
GET /api/v1/treat/config
PUT /api/v1/treat/config
```

```JSON
{
  "autoDeductConsumable": true,
  "requireCustomerSign": false
}
```

- `autoDeductConsumable`：是否自动扣 `TE_Stock`（关则只写统计流水）
- `requireCustomerSign`：开则卡类耗卡必须带 `signatureImageUrl`，否则创建失败

---

# 142 创建消耗订单

```HTTP
POST /api/v1/treat/orders
```

```JSON
{
  "customerId": 10001,
  "storeId": 1002,
  "billDate": "2026-09-10",
  "signatureImageUrl": "https://.../sign.png",
  "items": [
    {
      "itemType": "SAVING_CARD",
      "accountId": 90001,
      "projectId": 2001,
      "quantity": 1
    }
  ],
  "handlers": [
    { "employeeId": "3001", "ratio": 60 },
    { "employeeId": "3002", "ratio": 40 }
  ]
}
```

创建即扣权益并完成（BillStatus=`1`）；储值未传本金/赠金时按「项目现价×区域折扣」计价，先本金后赠金。

---

# 143 创建消耗时校验

客户存在 → 门店权限 → 护理师比例 100% → 权益余量 →（开关）签字 → 耗材库存（开关开时）

---

# 144 查询 / 列表 / 完成（幂等）

```HTTP
GET /api/v1/treat/orders/{id}
GET /api/v1/treat/orders
POST /api/v1/treat/orders/{id}/complete
```

complete：若开启签字且无签名则失败。

---

# 145 本月取消（回滚权益，保留单据）

```HTTP
POST /api/v1/treat/orders/{id}/cancel?remark=误开
```

回滚次数/储值；曾扣库存则回加；写 `TB_TreatBillCancelProcess`；状态=`已取消`；**不删单**。隔月禁止。

---

# 146 本月改经手人

```HTTP
PUT /api/v1/treat/orders/{id}/handlers
```

```JSON
{ "handlers": [ { "employeeId": "3001", "ratio": 100 } ] }
```

---

# 十七、服务API

---

# 171 开始服务

```HTTP
POST /api/v1/services/{id}/start
```

---

# 172 完成服务

```HTTP
POST /api/v1/services/{id}/complete
```

如果服务和消耗在系统设计中最终合并为一个动作，则：

> `treat/complete` 可以统一完成服务。

---

# 十八、预约API

> 2026-09-16 预约中心（CONF-050～055）：排班 + 可约槽 + 预约创建/改/取消 + 状态机 + 看板；顾客必填（经 `GET /customers?keyword=` 选人）；**不**自动转开单；**不**写 OperationLog（过程写 `TB_AppointmentBillProcess`）。

权限：`appointment:view` / `appointment:edit` / `appointment:status`

---

# 181 创建预约

```HTTP
POST /api/v1/appointments
```

权限：`appointment:edit`

请求：

```JSON
{
  "customerId": 10001,
  "storeId": 1002,
  "projectId": 2001,
  "employeeId": "E001",
  "startTime": "2026-08-26T15:00:00",
  "appointmentTypeId": 1,
  "remark": "客户预约"
}
```

说明：`customerId` 必填；时长取项目 `TreatTime` 快照（无则配置 Period，再默认 60）；服务端校验排班与冲突。

---

# 182 查询预约

```HTTP
GET /api/v1/appointments?storeId=&date=&dateFrom=&dateTo=&status=&employeeId=&customerId=&page=1&size=20
```

权限：`appointment:view`

```HTTP
GET /api/v1/appointments/{id}
```

---

# 183 确认预约

```HTTP
POST /api/v1/appointments/{id}/confirm
```

权限：`appointment:status`  
状态：`WAIT` → `CONF`

---

# 184 到店

```HTTP
POST /api/v1/appointments/{id}/arrive
```

权限：`appointment:status`  
状态：`CONF` → `ARRV`（到店后由前端自行调销售/耗卡 API，本模块不建单）

---

# 185 爽约

```HTTP
POST /api/v1/appointments/{id}/no-show
```

权限：`appointment:status`  
状态：`CONF` → `NOSH`

---

# 185A 完成 / 取消 / 修改

```HTTP
POST /api/v1/appointments/{id}/complete
POST /api/v1/appointments/{id}/cancel
PUT  /api/v1/appointments/{id}
```

完成：`ARRV` → `DONE`；取消：`WAIT|CONF` → `CANC`（可带 `reason`）；修改仅 `WAIT|CONF`。

---

# 185B 可约槽 / 当日看板

```HTTP
GET /api/v1/appointments/available-slots?storeId=&date=&projectId=&employeeId=
GET /api/v1/appointments/board?storeId=&date=
```

权限：`appointment:view`  
可约槽由排班 − 占用预约计算，半开区间。

---

# 185C 排班与配置

```HTTP
GET  /api/v1/appointment-schedules?storeId=
POST /api/v1/appointment-schedules
PUT  /api/v1/appointment-schedules/{id}
GET  /api/v1/appointment-schedules/day-assignments?storeId=&date=
POST /api/v1/appointment-schedules/day-assignments
GET  /api/v1/appointment-schedules/config?storeId=
PUT  /api/v1/appointment-schedules/config
```

权限：读 `appointment:view`；写 `appointment:edit`

---

# 186 转开单（后置）

```HTTP
POST /api/v1/appointments/{id}/create-order
```

**V1 不实现**（CONF-054）。到店后请调用既有销售/耗卡接口。

---

# 十八B、经手人配置与可选名单

> 2026-09-16（CONF-056/057）：复用旧 `TB_*Handler` + `*JobType`；按 `bizType` Facade；选人=本店∪跨店∩在职∩职务。

权限：`handler:config:view|edit`；选人：`handler:candidates:view` **或** `sale:order:create` **或** `treat:order:create`（OR）。

`bizType`：`PROJECT_SALE` / `PRODUCT_SALE` / `SAVING_SALE` / `GENERAL_SALE` / `TIME_SALE` / `PACKAGE_SALE` / `PROJECT_TREAT` / `PRODUCT_TREAT` / `GENERAL_TREAT` / `TIME_TREAT` / `SAVING_TREAT`

---

# 187 经手人角色列表

```HTTP
GET /api/v1/handler-roles?bizType=PROJECT_SALE&storeId=&onlyActive=
```

---

# 188 创建经手人角色

```HTTP
POST /api/v1/handler-roles
```

```JSON
{
  "bizType": "PROJECT_SALE",
  "storeId": 1002,
  "name": "护理师",
  "sequence": 1,
  "jobTypeIds": [1, 2]
}
```

---

# 189 修改 / 停用 / 覆盖职务

```HTTP
PUT    /api/v1/handler-roles/{id}?bizType=
DELETE /api/v1/handler-roles/{id}?bizType=
PUT    /api/v1/handler-roles/{id}/job-types?bizType=
```

DELETE = `Active=0` 软停用。

---

# 190 开单可选经手人

```HTTP
GET /api/v1/handler-candidates?bizType=PROJECT_TREAT&storeId=&keyword=
```

返回：`handlerRoleId`（Sequence 最小 Active）、`allowedJobTypeIds`、`employees[{employeeId,name,jobTypeIds,crossStore}]`。

---

# 十九、退款API

> 2026-09-16 退款中心模块（CONF-003/004/020～026）：金额服务端计算；次卡=`UnitPriceSnapshot×剩余次数`；储值只退未耗本金（赠金不退）；审批后执行；与耗卡本月取消互斥。

---

# 191 创建退款申请

```HTTP
POST /api/v1/refunds
```

权限：`refund:order:create`

请求：

```JSON
{
  "refundType": "SALE",
  "sourceOrderId": "S202609160001",
  "reason": "客户退款",
  "payments": [
    { "method": "现金", "amount": 693.00 }
  ]
}
```

说明：

- `refundType`：`SALE` | `TREAT`
- **退款金额由服务端按剩余权益计算**，忽略前端定价字段
- `payments` 可选；缺省按原销售支付比例分摊到可退金额；未知支付方式失败（无 fallback）
- SALE：覆盖该单下全部仍可退账户（剩次×快照；储值仅本金未耗）
- TREAT：已取消/已退款消耗单禁止申请

---

# 191B 退款列表

```HTTP
GET /api/v1/refunds?status=0&page=1&size=20
```

权限：`refund:order:view`  
按当前门店；`status` 可选（0/1/2/9）。

---

# 192 查询退款申请

```HTTP
GET /api/v1/refunds/{id}
```

权限：`refund:order:view`（含门店隔离）

---

# 193 审批退款

```HTTP
POST /api/v1/refunds/{id}/approve
```

权限：`refund:order:approve`

请求：

```JSON
{
  "approved": true,
  "remark": "同意退款"
}
```

状态：`0` 待审批 → `1` 已审批 / `9` 已驳回。写 Process。

---

# 194 执行退款

```HTTP
POST /api/v1/refunds/{id}/execute
```

权限：`refund:order:execute`  
仅 `ApprovalStatus=1` 可执行；CAS 防重复。

执行：

```Plain Text
SALE：停用剩余账户 → 冲销售业绩 → 源单已退款 → 退款单已执行
TREAT：加回次数/储值 → 冲耗卡业绩 → 源消耗单已退款 → 退款单已执行
```

具体哪些步骤执行，由退款类型决定。

状态码：`0` 待审批 / `1` 已审批 / `2` 已执行 / `9` 已驳回。

---

# 二十、卡延期API

```HTTP
POST /api/v1/card-accounts/{id}/extend
```

请求：

```JSON
{
  "newValidDate": "2030-01-01",
  "reason": "客户延期"
}
```

必须：

```Plain Text
权限
 ↓
业务规则
 ↓
记录原有效期
 ↓
更新有效期
 ↓
写延期记录
```

---

# 二十一、次卡转让API

---

# 211 发起转让

```HTTP
POST /api/v1/general-card-accounts/{id}/transfer
```

请求：

```JSON
{
  "targetCustomerId": 20001,
  "reason": "客户转让"
}
```

生成：

> 转让申请。

---

# 212 审核转让

```HTTP
POST /api/v1/card-transfers/{id}/approve
```

---

# 213 执行转让

```HTTP
POST /api/v1/card-transfers/{id}/execute
```

---

# 二十二、绩效API

---

# 221 查询员工销售业绩

```HTTP
GET /api/v1/performance/sales
```

---

# 222 查询员工消耗业绩

```HTTP
GET /api/v1/performance/treat
```

---

# 223 查询客流

```HTTP
GET /api/v1/performance/guests
```

---

# 224 计算员工月度提成

```HTTP
POST /api/v1/commissions/calculate
```

权限：`commission:calculate`（门店校验）

请求：

```JSON
{
  "month": "2026-08",
  "storeId": 1001
}
```

响应 `data`：

```JSON
{
  "month": "2026-08",
  "storeId": 1001,
  "saleLineCount": 12,
  "treatLineCount": 8,
  "employees": [
    {
      "employeeId": "E001",
      "saleCommission": 120.50,
      "treatCommission": 80.00,
      "totalCommission": 200.50
    }
  ]
}
```

内部（V1，CONF-027～037）：

```Plain Text
读取本月已支付且未整单退款的销售项目经手人行（× Handler.Scale）
 ↓
匹配销售提成规则（HandlerJobType > Handler > Project > Scheme；无阶梯）
 ↓
读取本月已完成耗卡项目经手人行；按员工月耗卡业绩匹配 TK_EmployeeCommission 阶梯
 ↓
删除同月门店项目提成快照后重写（同月可覆盖；V1 无 approve/settle）
 ↓
返回员工汇总
```

> V1 **不做**客流提成；**不做** `approve` / `settle`。

---

# 224b 查询员工月度提成

```HTTP
GET /api/v1/commissions?month=2026-08&storeId=1001
```

权限：`commission:view`（门店校验）

响应结构与 calculate 的 `employees` 汇总相同（不含本次批算行数时可视为快照查询）。

---

# 二十三、绩效审核

```HTTP
POST /api/v1/commissions/{id}/approve
```

---

# 二十四、绩效结算

```HTTP
POST /api/v1/commissions/{id}/settle
```

结算以后：

> 锁定结果。

---

# 二十五、业绩调整API

不能：

```Plain Text
PUT /performance/{id}
```

直接覆盖。

应该：

```HTTP
POST /api/v1/performance/{id}/adjust
```

请求：

```JSON
{
  "adjustAmount": 1000,
  "reason": "业务修正"
}
```

然后：

```Plain Text
产生调整记录
 ↓
审批
 ↓
重新计算结算结果
```

---

# 二十六、库存API

---

# 261 查询库存

```HTTP
GET /api/v1/inventory
```

---

# 262 入库

```HTTP
POST /api/v1/inventory/inbound
```

---

# 263 出库

```HTTP
POST /api/v1/inventory/outbound
```

---

# 264 调拨

```HTTP
POST /api/v1/inventory/transfers
```

---

# 265 盘点

```HTTP
POST /api/v1/inventory/checks
```

---

# 二十七、对账API

---

# 271 日营业汇总

```HTTP
GET /api/v1/reconciliation/daily
```

返回：

```Plain Text
销售
实收
微信
支付宝
现金
储值
退款
差异
```

---

# 272 日结

```HTTP
POST /api/v1/reconciliation/daily/{date}/close
```

执行：

```Plain Text
业务检查
 ↓
支付检查
 ↓
退款检查
 ↓
差异检查
 ↓
关账
```

---

# 273 解除关账

```HTTP
POST /api/v1/reconciliation/daily/{date}/reopen?reason={reason}
```

属于高风险接口。

必须：

```Plain Text
特殊权限
+
原因（query: reason，必填）
+
操作日志
```

---

# 二十八、商品与价格API

---

# 281 修改产品基础资料

```HTTP
PUT /api/v1/products/{id}
```

---

# 282 修改项目

```HTTP
PUT /api/v1/projects/{id}
```

权限：`project:edit`

```HTTP
DELETE /api/v1/projects/{id}
```

停用：`IsAllowSell=0` 且 `IsAllowConsume=0`；非物理删除。权限：`project:edit`

---

# 283 修改基础价格

```HTTP
POST /api/v1/prices/change
```

记录：

```Plain Text
原价格
新价格
生效时间
操作人
原因
```

---

# 二十九、报表API

ERP自身提供：

```HTTP
GET /api/v1/reports/store/daily
GET /api/v1/reports/sales
GET /api/v1/reports/treat
GET /api/v1/reports/customers
GET /api/v1/reports/performance
```

---

# 三十、BI原则

BI不是ERP API的核心消费者。

如果现有BI直接读取数据库：

> 新ERP API不能替代BI数据源。

所以V1：

```Plain Text
ERP
 ↓
旧数据库
 ↓
BI
```

API主要服务：

```Plain Text
ERP前端
移动端
未来其他业务系统
```

---

# 三十一、API事务边界

这是开发时必须严格遵守的。

---

## 销售支付

```Plain Text
POST /sales/orders/{id}/pay
```

事务：

```Plain Text
支付结果
+
销售订单
+
会员权益
+
销售业绩
```

---

## 完成耗卡

```Plain Text
POST /treat/orders/{id}/complete
```

事务：

```Plain Text
消耗
+
权益扣减
+
服务
+
客流
+
消耗业绩
+
库存耗材
```

---

## 执行退款

```Plain Text
POST /refunds/{id}/execute
```

事务：

```Plain Text
退款
+
权益
+
业绩
+
库存
```

---

# 三十二、幂等接口

以下接口必须幂等：

```Plain Text
POST /sales/orders
POST /sales/orders/{id}/pay
POST /treat/orders/{id}/complete
POST /refunds/{id}/execute
POST /card-accounts/{id}/extend
POST /card-transfers/{id}/execute
POST /reconciliation/.../close
```

---

# 三十三、幂等实现

每次业务请求带：

```Plain Text
X-Request-Id
```

数据库保存：

```Plain Text
request_id
api
user_id
result
created_at
```

重复请求：

> 直接返回第一次结果。

---

# 三十四、API权限模型

每一个业务API：

```Plain Text
Authentication
 ↓
Function Permission
 ↓
Store Permission
 ↓
Data Permission
 ↓
Business Rule
 ↓
Transaction
```

例如：

```Plain Text
POST /treat/orders/{id}/complete
```

需要：

```Plain Text
consume:complete
+
当前门店
+
客户数据权限
+
员工业务权限
+
权益规则
```

---

# 三十五、API与旧数据库关系

例如：

## 完成耗卡

前端：

```Plain Text
POST /api/v1/treat/orders/123/complete
```

后端：

```Plain Text
TreatApplicationService
 ↓
TreatDomainService
 ↓
EntitlementService
 ↓
PerformanceService
 ↓
InventoryService
 ↓
TreatRepository
```

最终写旧库：

```Plain Text
TB_TreatBill
TB_TreatBillProject
TB_TreatBillSavingCard
TB_TreatBillGeneralCard
TB_TreatBillTimeCard
TB_*Performance
TE_Inventory*
...
```

这就是：

> **API层不暴露旧数据库。**

---

# 三十六、API返回模型不要直接返回旧表字段

错误：

```JSON
{
  "CustomerID": 1,
  "EntityID": 2,
  "LargessAmount": 200
}
```

前端应该收到业务模型：

```JSON
{
  "customerId": 1,
  "storeId": 2,
  "bonusAmount": 200
}
```

这样前端不会被旧数据库字段命名绑死。

---

# 三十七、API DTO设计

建议：

```Plain Text
Command
Query
Response
```

例如：

```Plain Text
CreateSaleOrderCommand
PaySaleOrderCommand
CompleteTreatOrderCommand
CreateRefundCommand
```

查询：

```Plain Text
SaleOrderQuery
CustomerQuery
PerformanceQuery
```

返回：

```Plain Text
SaleOrderResponse
CustomerDetailResponse
TreatOrderResponse
```

---

# 三十八、API项目包结构

建议：

```Plain Text
api
│
├── auth
├── organization
├── customer
├── product
├── card
├── sale
├── payment
├── treat
├── service
├── appointment
├── inventory
├── performance
├── commission
├── refund
├── reconciliation
├── report
└── system
```

每个业务域内部再：

```Plain Text
controller
application
domain
infrastructure
```

---

# 三十九、第一批必须开发的API

为了让你们三个开发人员有明确起点，我建议第一批不是把全部API做完，而是做核心闭环。

## 第一组：基础

```Plain Text
POST /api/v1/auth/login
POST /api/v1/auth/logout
GET /api/v1/auth/me
POST /api/v1/auth/switch-store
GET /api/v1/system/settings/auth-session
PUT /api/v1/system/settings/auth-session
GET /api/v1/stores
GET /api/v1/employees
GET /api/v1/employees/{id}
POST /api/v1/employees
PUT /api/v1/employees/{id}
GET /api/v1/employees/{id}/role-access
PUT /api/v1/employees/{id}/role-access
GET /api/v1/job-types
GET /api/v1/job-types/{id}
POST /api/v1/job-types
PUT /api/v1/job-types/{id}
DELETE /api/v1/job-types/{id}
GET /api/v1/job-types/{id}/permissions
PUT /api/v1/job-types/{id}/permissions
GET /api/v1/permissions
GET /api/v1/permissions/{code}
POST /api/v1/permissions
PUT /api/v1/permissions/{code}
DELETE /api/v1/permissions/{code}
GET /api/v1/operation-logs
GET /api/v1/organizations
POST /api/v1/organizations
PUT /api/v1/organizations/{id}
GET /api/v1/stores/{storeId}/cross-store-employees
POST /api/v1/stores/{storeId}/cross-store-employees
DELETE /api/v1/stores/{storeId}/cross-store-employees/{employeeId}
```

---

## 第二组：客户

```Plain Text
GET /customers
GET /customers/export
POST /customers
PUT /customers/{id}
GET /customers/{id}
GET /customers/{id}/cards
GET /customers/{id}/sales
GET /customers/{id}/sale-items
GET /customers/{id}/payments
GET /customers/{id}/treats
GET /customers/{id}/treat-items
GET /customers/{id}/transfers
GET /customers/{id}/service-logs
GET /customers/{id}/tags
POST /customers/{id}/tags
DELETE /customers/{id}/tags/{tagId}
GET /customers/{id}/assets
GET /customer-tags
GET /customer-tags/all
GET /customer-tags/{id}
POST /customer-tags
PUT /customer-tags/{id}
DELETE /customer-tags/{id}
GET /customer-sources
GET /customer-sources/options
GET /customer-sources/{id}
POST /customer-sources
PUT /customer-sources/{id}
DELETE /customer-sources/{id}
GET /customer-form-fields
GET /customer-form-fields/create-schema
GET /customer-form-fields/{fieldCode}
POST /customer-form-fields
PUT /customer-form-fields/{fieldCode}
DELETE /customer-form-fields/{fieldCode}
GET /servicers/options
```

---

## 第三组：商品

```Plain Text
GET /products
GET /projects
GET /cards/saving
GET /cards/package
GET /cards/general
GET /cards/time
```

---

## 第四组：销售

```Plain Text
POST /sales/orders
GET /sales/orders/{id}
PUT /sales/orders/{id}
POST /sales/orders/{id}/pay
POST /sales/orders/{id}/close
```

---

## 第五组：消耗

```Plain Text
GET /treat/customers/{id}/available-assets
POST /treat/orders
GET /treat/orders/{id}
POST /treat/orders/{id}/complete
```

---

## 第六组：绩效

```Plain Text
GET /performance/sales
GET /performance/treat
GET /performance/guests
POST /commissions/calculate
GET /commissions
```

---

# 四十、API开发顺序

正确顺序：

```Plain Text
认证
 ↓
客户
 ↓
商品
 ↓
销售
 ↓
支付
 ↓
卡项
 ↓
消耗
 ↓
服务
 ↓
业绩
 ↓
退款
 ↓
库存
 ↓
预约
 ↓
报表
```

注意：

> 不建议先开发大量CRUD，再最后做销售/消耗。

因为真正困难的是：

```Plain Text
支付
权益
消耗
业绩
退款
```

---

# 四十一、API接口与业务验收

每一个业务API都必须有：

```Plain Text
正常场景
权限异常
参数异常
状态异常
业务规则异常
重复请求
并发
数据库异常
```

例如：

`POST /treat/orders/{id}/complete`

至少测试：

```Plain Text
正常耗卡
余额不足
卡过期
跨店赠金
次卡次数不足
多人比例≠100%
重复提交
并发扣卡
服务完成后再次提交
```

---

# 四十二、API最终设计原则

整个开发团队以后统一遵守：

> **一个API代表一个完整业务动作。**

不要让前端拼业务。

例如不要：

```Plain Text
前端：
1. 调扣余额
2. 调完成服务
3. 调生成业绩
4. 调扣库存
5. 调完成订单
```

正确：

```Plain Text
前端：
POST /treat/orders/{id}/complete

后端：
完成整个业务事务
```

这会显著降低系统出错概率。

---

# 四十三、08完成后的项目状态

现在我们已经形成：

```Plain Text
01 产品总体架构
 ↓
02 业务领域模型
 ↓
03 功能模块设计
 ↓
04 核心业务流程
 ↓
05 业务规则库
 ↓
06 角色权限
 ↓
07 旧数据库适配
 ↓
08 API
```

现在已经开始真正具备：

> **后端可以开始设计Controller、Service、DTO、Repository。**

但前端还缺一个很重要的东西：

> **每个页面到底怎么操作。**

所以第09章进入：

# 《前端原型规范 V10》

这一章不会只是告诉你“画几个页面”。

它会按照真实门店操作链设计：

```Plain Text
登录
 ↓
工作台
 ↓
客户搜索
 ↓
客户详情
 ↓
开单
 ↓
收银
 ↓
办卡
 ↓
耗卡
 ↓
选择本金/赠金
 ↓
选择护理师
 ↓
比例分配
 ↓
服务完成
 ↓
业绩
```

并且会明确：

**页面布局、组件、交互、状态、权限显示、错误提示、核心操作路径和各页面对应API。**

这时候你的前端新人就不再是“自己看着需求写页面”，而是可以直接按照原型和接口做开发。