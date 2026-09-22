# ERP系统前端项目扫描 Prompt

> 版本：V1.0
> 当前阶段：前端项目扫描与上下文建立
> 前置文件：《00-Cursor前端开发总规则.md》
> 前置任务：《01-Cursor前端项目初始化Prompt.md》

---

# 一、你的当前角色

你现在是本 ERP 项目的：

> 高级 Vue 3 + TypeScript 前端架构工程师。

当前任务：

> **扫描并理解整个 ERP 项目，为后续前端基础框架开发建立准确的技术和业务上下文。**

---

# 二、本阶段不是开发阶段

非常重要。

本次任务：

> **只分析、扫描、整理，不进行大规模编码。**

不要开始开发：

- 登录
- Token
- 当前用户
- 权限
- 门店切换
- Layout
- 客户
- 销售
- 预约
- 卡项
- 业务页面

---

# 三、首先阅读前端总规则

必须首先阅读：

```text id="2m1b7u"
ERP项目设计/cursor/frontend/00-Cursor前端开发总规则.md
```

如果没有找到：

立即停止并报告。

---

# 四、扫描目标

本次需要建立以下几个方面的认知：

```text id="4njd7d"
1. 当前前端项目
2. 当前后端项目
3. 后端API
4. ERP产品设计文档
5. ERP业务模型
6. 数据库相关设计
7. 当前开发状态
8. 前后端之间的关系
9. 前端基础框架后续建设方案
10. 当前存在的风险和不确定点
```

---



# 五、第一步：扫描当前前端项目

先扫描整个前端工程。

重点检查：

```text id="y7p6sg"
package.json
src/
vite.config.*
tsconfig.*
index.html
.env*
public/
```

以及其他实际存在的重要配置文件。

---



# 六、分析package.json

输出：

```text id="jld6gr"
Vue版本
TypeScript版本
Vite版本
Element Plus版本
Pinia版本
Vue Router版本
Axios版本
```

同时检查：

```text id="5q5m3r"
ESLint
Prettier
Sass/Less
UnoCSS/Tailwind
其他UI组件库
其他状态管理库
其他工具库
```

如果存在：

> 说明是否需要保留。

不得因为个人偏好随意删除。

---



# 七、扫描src目录

输出当前实际目录结构。

例如：

```text id="0kvr8e"
src/
├── api/
├── assets/
├── components/
├── router/
├── stores/
├── views/
└── ...
```

如果当前目录与预期结构不同：

不要立即重构。

先报告。

---



# 八、扫描当前代码

检查：

```text id="6q9k6n"
main.ts
App.vue
router
stores
api
components
views
utils
```

判断：

```text id="yk9i2b"
哪些是初始化生成的
哪些是已有代码
哪些可能需要保留
哪些可能需要调整
```

---



# 九、第二步：扫描后端项目

如果后端项目与当前前端项目在同一工作区：

必须扫描后端。

如果不在当前工作区：

先检查是否存在后端项目路径。

不要擅自猜路径。

---



# 十、后端扫描重点

重点查看：

```text id="f8s1yx"
Controller
DTO
VO
Response
Enum
权限相关代码
认证相关代码
Security相关代码
JWT相关代码
用户相关接口
组织/门店相关接口
```

---



# 十一、重点扫描认证模块

需要找到后端真实登录接口。

重点确认：

```text id="s8y0c8"
登录接口路径
HTTP Method
请求参数
响应结构
Token字段
Token类型
Token有效期
错误响应结构
```

例如：

```text id="y1i6gu"
POST /api/v1/auth/login
```

但是：

> 不允许假设这个接口一定存在。

必须以实际代码/API文档为准。

---



# 十二、重点扫描当前用户接口

确认是否存在：

```text id="4qxx3j"
/api/v1/auth/me
```

如果存在，必须记录：

```text id="q1j7m5"
请求方式
响应结构
用户信息
角色
permissionCodes
dataScope
storeIds
其他字段
```

---



# 十三、重点扫描权限模型

必须找到后端实际权限模型。

重点分析：

```text id="r04e1n"
角色
权限编码
菜单
操作权限
数据范围
门店范围
```

不要自己设计一套新的权限编码。

---



# 十四、重点扫描门店模型

找到后端实际的：

```text id="e4a4io"
组织
门店
员工
用户
角色
员工门店关系
用户门店关系
数据范围
```

需要回答：

> 当前用户可以访问哪些门店？

以及：

> 后端如何告诉前端？

---



# 十五、重点扫描门店切换相关API

检查后端是否存在类似：

```text id="h8h7zo"
切换门店
设置当前门店
获取门店列表
```

不要假设一定存在。

如果不存在：

必须记录。

因为：

> 前端的“切换门店”到底是纯前端上下文切换，还是需要调用后端接口，必须根据后端实际设计决定。

---



# 十六、扫描统一响应结构

找到后端统一响应结构。

例如可能类似：

```json id="bcbjqa"
{
  "code": 0,
  "message": "success",
  "data": {}
}
```

但不要假设。

必须读取实际后端代码。

需要记录：

```text id="v3hrf8"
成功标识
错误码
错误信息
数据字段
分页字段
```

---



# 十七、扫描异常处理

重点查看后端：

```text id="r8x2gv"
401
403
404
业务异常
参数校验异常
系统异常
```

确认前端应该如何识别。

---



# 十八、扫描分页结构

找到后端分页响应。

确认：

```text id="q0ad9x"
page
size
total
records
```

还是其他结构。

不要自行假设。

后续所有 ERP 列表页面都要使用统一分页模型。

---



# 十九、扫描枚举

重点找到：

```text id="7k3c3s"
订单状态
支付状态
卡类型
预约状态
员工状态
客户状态
项目类型
销售渠道
```

当前不需要全部实现前端枚举。

但必须建立认知。

---



# 二十、扫描API文档

如果工作区存在：

```text id="9t9o4r"
API设计文档
Swagger
OpenAPI
V10 API文档
```

必须阅读。

重点不是只看接口名称。

必须对照：

```text id="7n9s3c"
Controller
DTO
Response
实际业务代码
```

---



# 二十一、API文档与代码不一致时

必须记录：

```text id="o5i3yw"
【API文档与代码不一致】

接口：
xxx

文档：
xxx

实际代码：
xxx

差异：
xxx

前端当前应该依据：
xxx

需要人工确认：
是
```

不得自行选择一个然后默默继续。

---



# 二十二、扫描ERP产品设计文档

必须读取：

```text id="4r2xji"
ERP项目设计/
```

重点：

```text
01-产品总体架构.md
02-业务领域模型.md
02A-预约中心设计.md
03-功能模块设计.md
04-核心业务流程.md
05-业务规则库.md
06-角色权限模型.md
07-数据库设计.md
08-API接口设计.md
09-前端原型规范.md
10-系统架构设计.md
```

如果某些文件还没有：

不要假设内容。

明确记录：

```text
未找到。
```

---



# 二十三、扫描前端原型规范

重点阅读：

```text id="xg8v0z"
09-前端原型规范.md
```

了解：

- 页面整体风格
- 页面布局
- 页面交互原则
- 表格规范
- 表单规范
- 弹窗规范
- 操作按钮规范
- 页面状态规范

如果该文件还没有：

记录：

> 当前不存在，需要后续建立。

---



# 二十四、扫描角色权限模型

重点阅读：

```text id="6qpl3q"
06-角色权限模型.md
```

理解：

```text id="q5n2cx"
角色
↓
权限
↓
数据范围
↓
门店范围
```

这会直接影响：

```text id="t8y4iq"
菜单
路由
按钮
门店
```

---



# 二十五、扫描业务领域模型

重点阅读：

```text id="0cvk4k"
02-业务领域模型.md
```

重点建立前端认知：

```text id="i9qgxx"
Customer
Employee
Store
Project
Product
Card
SaleOrder
SaleOrderItem
Consumption
Appointment
Performance
```

注意：

这里只建立认知。

不要开始生成这些页面。

---



# 二十六、扫描API设计

重点阅读：

```text id="s84c1v"
08-API接口设计.md
```

建立：

```text id="h0j2qi"
认证API
组织API
员工API
角色权限API
客户API
项目API
卡项API
销售API
支付API
消费API
预约API
绩效API
库存API
报表API
```

的整体认知。

---



# 二十七、特别检查销售API

后续销售页面非常重要。

当前只分析，不修改。

重点检查：

```text id="5bd9oa"
销售订单
销售订单明细
销售渠道
价格
经手人
绩效分配
支付
欠款
退款
```

特别确认：

> 销售渠道究竟是订单级还是明细级。

---



# 二十八、特别检查绩效分配

必须确认后端真实结构。

业务设计要求：

```text id="skks2m"
SaleOrder
 ↓
SaleOrderItem
 ↓
PerformanceAllocation
```

但：

> 最终必须以后端实际代码为准。

如果发现：

```text id="f89vfi"
文档认为是明细级
实际API却是订单级
```

必须报告。

不要自行修改。

---



# 二十九、特别检查金额

确认后端金额字段使用：

```text id="5m3apq"
BigDecimal
```

还是其他类型。

并记录：

```text
销售金额
实收金额
应收金额
退款金额
绩效金额
佣金金额
```

对应字段。

---



# 三十、扫描数据库设计

当前前端不修改数据库。

但是需要了解：

```text id="a3h7bb"
客户
员工
门店
项目
卡项
销售
支付
消费
预约
库存
```

等核心数据之间的关系。

原因：

> 前端表单和页面结构必须与真实业务数据模型一致。

---



# 三十一、建立前后端关系图

扫描完成以后输出类似：

```text id="7o7m1q"
前端
 ↓
Axios
 ↓
Controller
 ↓
Service
 ↓
Domain
 ↓
Repository
 ↓
SQL Server
```

并标记：

```text id="t9u5t6"
认证
权限
门店
业务
```

分别如何贯通。

---



# 三十二、建立登录链路

必须输出真实登录链路：

```text id="0j4t7v"
登录页面
 ↓
POST 登录API
 ↓
Token
 ↓
保存Token
 ↓
/auth/me
 ↓
CurrentUser
 ↓
权限
 ↓
门店
 ↓
菜单
 ↓
ERP首页
```

其中每一步必须使用实际接口名称。

---



# 三十三、建立门店链路

输出：

```text id="q1c7ko"
当前用户
 ↓
可用门店
 ↓
当前门店
 ↓
页面请求
 ↓
后端数据范围
```

如果门店上下文目前后端还没有明确设计：

必须指出。

---



# 三十四、建立权限链路

输出：

```text id="9zv80x"
登录
 ↓
用户
 ↓
角色
 ↓
permissionCodes
 ↓
前端菜单
 ↓
路由
 ↓
按钮
 ↓
后端权限校验
```

明确：

> 哪部分由前端完成。

> 哪部分由后端完成。

---



# 三十五、建立前端基础框架建议

扫描完成以后，根据真实项目情况给出建议：

```text id="8qylp8"
src/
├── api/
├── components/
├── composables/
├── constants/
├── layouts/
├── router/
├── stores/
├── types/
├── utils/
└── views/
```

但：

> 如果当前项目已经存在合理结构，不要强行重构。

---



# 三十六、当前阶段不得修改业务代码

扫描期间：

禁止：

```text id="zyj9q2"
大规模重构
业务开发
后端修改
数据库修改
API修改
```

原则：

> **先建立认知，再开始开发。**

---



# 三十七、发现问题时分类

所有问题分为：

```text id="e9kzqi"
A. 已确认问题
B. 文档与代码不一致
C. 设计缺口
D. 当前无法判断
E. 后续需要确认
```

---



# 三十八、输出“已确认事实”

必须单独输出：

```text id="m48i2m"
【已确认事实】

1. 前端技术栈：
xxx

2. 登录API：
xxx

3. 当前用户API：
xxx

4. Token：
xxx

5. 权限：
xxx

6. 门店：
xxx

7. API响应：
xxx

8. 错误处理：
xxx
```

只写通过项目代码或文档确认的信息。

---



# 三十九、输出“不能确定的事情”

必须单独输出：

```text id="w3lq2c"
【当前无法确定】

1. xxx
2. xxx
3. xxx
```

不能用猜测补充。

---



# 四十、输出“前端基础框架实施建议”

最后给出建议顺序：

```text id="0fy5x8"
1. 项目初始化
2. Axios基础层
3. 登录
4. Token
5. 当前用户
6. 权限
7. 门店
8. Router
9. Layout
10. Sidebar
11. Header
12. Breadcrumb
13. 菜单权限
14. 路由权限
15. 按钮权限
16. 全局错误处理
17. Logout
18. 基础框架验收
```

这个顺序必须根据实际项目扫描结果调整。

如果需要调整：

说明原因。

---



# 四十一、特别要求：不要开始编码

本次任务完成后：

> **停止。**

不要继续执行：

```text id="8n9c6q"
登录开发
权限开发
门店开发
Layout开发
```

等待下一条指令。

---



# 四十二、最终输出格式

Cursor 完成扫描后，必须按照以下格式输出。

```text
【ERP前端项目扫描报告】

一、前端项目概况

项目：
xxx

Vue：
xxx

TypeScript：
xxx

Vite：
xxx

Element Plus：
xxx

Pinia：
xxx

Vue Router：
xxx

Axios：
xxx


二、当前前端目录结构

```text
xxx
```

三、后端项目概况

项目：
xxx

Spring Boot：
xxx

数据库：
xxx

四、认证机制

登录API：
xxx

Token：
xxx

当前用户API：
xxx

五、权限模型

角色：
xxx

权限：
xxx

数据范围：
xxx

门店范围：
xxx

六、门店模型

用户可访问门店：
xxx

当前门店机制：
xxx

门店切换API：
xxx

七、统一响应

成功结构：
xxx

错误结构：
xxx

分页结构：
xxx

八、API模块

认证：
xxx

组织：
xxx

客户：
xxx

销售：
xxx

消费：
xxx

预约：
xxx

库存：
xxx

其他：
xxx

九、核心业务模型

Customer：
xxx

Store：
xxx

Employee：
xxx

Project：
xxx

Card：
xxx

SaleOrder：
xxx

SaleOrderItem：
xxx

Appointment：
xxx

十、前后端关系

```text
xxx
```

十一、登录链路

```text
xxx
```

十二、权限链路

```text
xxx
```

十三、门店链路

```text
xxx
```

十四、已确认事实

1. xxx
2. xxx
3. xxx

十五、发现的问题

1. xxx
2. xxx

十六、文档与代码不一致

1. xxx

十七、当前无法确定

1. xxx

十八、前端基础框架建议

1. xxx
2. xxx
3. xxx

十九、当前未修改内容

本次只进行了项目扫描，没有进行业务开发。

二十、下一步

等待执行：

03-Cursor前端基础框架开发Prompt.md

```

---
```



# 四十三、完成标准

本次任务只有在 Cursor 能够回答下面这些问题后才算完成：

```text
1. 前端现在是什么技术栈？

2. 后端登录接口是什么？

3. Token怎么获得？

4. 当前用户怎么获取？

5. 当前用户有哪些角色？

6. permissionCodes从哪里来？

7. dataScope是什么？

8. storeIds从哪里来？

9. 当前门店如何确定？

10. 门店切换是否需要后端接口？

11. 后端统一响应结构是什么？

12. 401怎么返回？

13. 403怎么返回？

14. 分页结构是什么？

15. 后端销售API是什么？

16. 销售渠道在哪里？

17. 绩效分配在哪里？

18. 前端应该如何和后端API对应？

19. 当前有哪些设计文档？

20. 当前有哪些不确定问题？
```

如果有任何一个问题无法从代码或文档确认：

> 明确写“当前无法确定”。

不得猜测。

---



# 四十四、本阶段最终目标

完成本次扫描以后，Cursor应该达到：

> **“我已经认识这个ERP项目，但我还没有开始写业务代码。”**

这是本阶段正确状态。

下一阶段才开始：

```text
03-Cursor前端基础框架开发Prompt.md
```

正式搭建：

```text
登录
 ↓
Token
 ↓
当前用户
 ↓
权限
 ↓
门店
 ↓
Layout
 ↓
菜单
 ↓
路由
 ↓
按钮权限
 ↓
全局请求/错误处理
 ↓
退出登录
```

