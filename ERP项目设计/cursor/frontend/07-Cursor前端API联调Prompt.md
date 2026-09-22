# 07-Cursor前端API联调Prompt.md

# Cursor 前端 API 联调 Prompt

## 一、Prompt定位

你现在承担：

> **ERP 前后端联调工程师**

目标：

将已经完成的 Vue 页面，与真实 Spring Boot ERP 后端 API 进行完整连接。

---

# 二、最高原则

> **Backend API 是最终接口事实来源。**

API 信息来源优先级：

```text
1. 实际 Controller / DTO / VO
2. 实际后端代码行为
3. API接口设计文档
4. 业务设计文档
5. 前端设计猜测
```

如果发生冲突：

```text
记录冲突
→ 不自行掩盖
→ 以实际后端为准
→ 必要时提交问题
```

---

# 三、必须读取

```text
08-API接口设计.md
06-角色权限模型.md
05-业务规则库.md
当前页面设计
当前页面代码
backend Controller
backend DTO
backend VO
backend Service
```

---

# 四、API路径规范

当前项目 Axios 已使用：

```text
baseURL = /api
```

因此：

```ts
request.get('/v1/xxx')
```

对应：

```text
/api/v1/xxx
```

不要写：

```ts
request.get('/api/v1/xxx')
```

否则可能形成：

```text
/api/api/v1/xxx
```

---

# 五、统一响应

当前后端存在：

```text
code = 0
```

代表成功。

重点业务错误包括：

```text
10001
未登录 / Token失效

10002
无权限

10003
无门店权限

50000
系统错误
```

前端必须使用统一请求层处理。

API 模块不允许每个页面自行解析：

```text
code
message
```

---

# 六、API模块规范

按照业务模块建立：

```text
src/api/
├── auth.ts
├── customer.ts
├── sales.ts
├── consumption.ts
├── appointment.ts
├── employee.ts
└── ...
```

API 方法必须返回明确的业务类型。

例如：

```ts
export function getCustomerList(
  params: CustomerQuery
): Promise<CustomerPageVO>
```

不要让页面直接操作 Axios 原始对象。

---

# 七、TypeScript类型

必须根据真实后端：

```text
Request DTO
Response VO
Page VO
Enum
```

建立类型。

例如：

```ts
interface CustomerQuery {
  keyword?: string
  status?: number
  page: number
  pageSize: number
}
```

不要：

```ts
any
```

---

# 八、分页

必须确认后端实际分页结构。

不要假定一定是：

```json
{
  "records": [],
  "total": 0
}
```

必须读取实际 API。

前端统一转换只能放在：

```text
API层
```

不要每个页面自己转换。

---

# 九、查询流程

标准：

```text
用户输入
↓
前端参数校验
↓
API
↓
Loading
↓
成功
↓
更新列表
↓
失败
↓
统一错误处理
```

---

# 十、表单提交

标准：

```text
用户点击提交
↓
按钮进入 loading
↓
前端基础校验
↓
API
↓
成功
↓
关闭弹窗
↓
提示成功
↓
刷新列表
```

失败：

```text
关闭 loading
保留表单
展示后端错误
```

---

# 十一、重复提交

以下操作必须重点防重复：

```text
登录
保存
开单
开卡
充值
消耗
支付
退款
提交预约
确认预约
```

必须使用：

```text
loading
disabled
```

必要时配合后端幂等机制。

---

# 十二、业务计算原则

以下数据不能由前端擅自作为最终结果：

```text
销售金额
最终价格
折扣
储值余额
卡余额
卡剩余次数
退款金额
绩效
佣金
库存
预约可用性
```

前端可以：

```text
计算UI临时展示
```

但最终提交和保存必须遵循后端规则。

---

# 十三、销售模块特殊规则

如果联调销售页面，必须特别确认：

```text
销售渠道
订单
订单明细
经手人
绩效分配
支付
欠款
开单
开卡
充值
```

尤其注意：

> 当前后端接口如果是订单级 `saleChannelId`，前端不能擅自伪造成明细级字段。

如果发现：

```text
业务设计要求明细级
后端实际接口订单级
```

必须记录：

```text
【API与业务模型差异】
```

不能自行假定后端支持。

---

# 十四、当前门店

当前业务门店来自：

```text
JWT storeId
```

不是简单：

```text
X-Store-Id
```

切换门店：

```text
POST /v1/auth/switch-store
```

然后：

```text
保存新token
↓
GET /v1/auth/me
↓
更新用户/门店上下文
↓
刷新门店相关数据
```

---

# 十五、API联调问题分类

发现问题必须分类：

```text
FRONTEND
前端问题

BACKEND
后端问题

API_CONTRACT
接口定义问题

BUSINESS
业务规则问题

DATA
数据问题

PERMISSION
权限问题

ENVIRONMENT
环境问题
```

禁止把所有问题都改前端。

---

# 十六、联调完成报告

```text
# API联调报告

模块：

## API清单

## 已联调

## 请求参数

## 响应结构

## 权限

## 门店

## 错误处理

## 重复提交

## 发现的问题

问题分类：

FRONTEND
BACKEND
API_CONTRACT
BUSINESS
DATA
PERMISSION
ENVIRONMENT

## 是否完成

PASS / FAIL / BLOCKED
```

---

