# 客户管理 04-2：客户详情弹窗/抽屉

## 一、任务定位

你现在继续开发 ERP 前端“客户管理”模块。

当前前端基础框架、登录、权限、门店切换、布局、Tab、统一异常处理、客户列表 04-1 已经完成并通过验证。

本次任务是：

> **开发客户管理 04-2：客户详情弹窗/抽屉。**

本任务不是开发一个新的客户详情路由页面。

必须遵循当前项目已经确定的前端交互架构：

```text
客户管理
└── 客户列表
    ├── 搜索
    ├── 新增客户
    ├── 编辑客户
    ├── 查看客户
    ├── 开单
    └── 客户详情
          ↓
       Dialog / Drawer
```

客户列表仍然是唯一的业务页面。

客户详情通过 Dialog 或 Drawer 打开。

禁止：

* 新增客户详情路由
* 新增客户详情全局 Tab
* 点击客户后跳转一个新的页面
* 为客户详情创建新的左侧菜单
* 为客户详情创建独立的全局 AppTabs

---

# 二、必须先阅读和扫描项目

在开始写代码之前，不要直接创建 Vue 文件。

先扫描当前项目。

重点检查：

```text
src/
├── api/
├── components/
├── config/
├── layouts/
├── stores/
├── types/
├── utils/
└── views/
```

重点阅读：

```text
src/views/
客户管理列表页面

src/api/
客户相关 API

src/types/
客户相关类型

src/stores/
auth.ts
permission.ts
store.ts
tabs.ts

src/utils/
request.ts
ui/
permission directive

src/layouts/
MainLayout
AppTabs
AppSidebar
```

同时扫描后端项目中实际存在的客户相关 API。

不要根据本 Prompt 猜接口。

必须以当前后端真实代码为准。

重点寻找：

```text
com.yudao.erp
```

下面与客户有关的：

```text
Controller
Service
VO
DTO
Query
Permission
```

尤其检查：

```text
客户列表
客户详情
客户查询
客户更新
客户标签
客户来源
客户服务人员
客户档案
```

以及客户详情已经能够关联的业务：

```text
销售订单
支付
耗卡
卡项
预约
服务日志
文件档案
转账
延期
```

但是：

> 本次只允许接入后端已经存在、已经可以正常调用的 API。

禁止为了完成前端页面而要求 Cursor 自己虚构后端接口。

---

# 三、必须遵守的架构边界

客户详情是一个“聚合展示容器”。

它负责：

```text
客户基础信息
+
客户相关业务入口
+
各业务模块查询结果展示
+
业务模块之间的导航
```

它不负责重新实现：

```text
销售订单业务
耗卡业务
卡项业务
预约业务
退款业务
提成业务
```

例如：

客户详情 → 销售订单

应该：

```text
调用销售订单已有 API
```

而不是：

```text
在 customer 模块重新实现销售订单查询逻辑
```

同理：

客户详情 → 卡项

应该调用已有卡项/客户资产相关 API。

---

# 四、客户详情 UI 形态

优先使用：

```text
Drawer
```

如果当前项目已经有统一 Dialog/Drawer 组件规范，则复用现有规范。

建议：

```text
el-drawer
```

形式。

推荐宽度：

```text
80%
```

或者根据当前项目实际视觉规范调整。

不要写死成一个极小窗口。

客户详情属于复杂业务信息聚合，必须有足够空间。

---

# 五、客户详情总体结构

推荐：

```text
┌──────────────────────────────────────────────────────────────┐
│ 客户详情                                           ×         │
├──────────────────────────────────────────────────────────────┤
│                                                              │
│  客户头像/姓名/手机号/会员状态/所属门店                       │
│                                                              │
│  [基础信息] [卡项信息] [文件档案] [服务日志] [预约记录]       │
│             [订单信息]                                       │
│                                                              │
├──────────────────────────────────────────────────────────────┤
│                                                              │
│                 当前业务内容                                 │
│                                                              │
└──────────────────────────────────────────────────────────────┘
```

注意：

这里的：

```text
[基础信息]
[卡项信息]
[文件档案]
...
```

是**详情 Drawer 内部 Tab**。

不是全局 AppTabs。

---

# 六、详情内部 Tab

根据现有业务资料，客户详情需要支持：

```text
基础信息

卡项信息

文件档案

服务日志

预约记录

订单信息
```

订单信息内部还存在：

```text
销售订单
支付明细
消耗明细
转账记录
延期记录
```

卡项信息内部存在：

```text
产品
储值卡
套餐卡
时效卡
通用次卡
项目
```

因此推荐第二层结构：

```text
客户详情
│
├── 基础信息
│
├── 卡项信息
│   ├── 产品
│   ├── 储值卡
│   ├── 套餐卡
│   ├── 时效卡
│   ├── 通用次卡
│   └── 项目
│
├── 文件档案
│
├── 服务日志
│
├── 预约记录
│
└── 订单信息
    ├── 销售订单
    ├── 支付明细
    ├── 消耗明细
    ├── 转账记录
    └── 延期记录
```

但是本次开发不要把所有内容一次实现。

---

# 七、本次 04-2 的实现范围

本次只完成：

## 1. 客户详情 Drawer

完成：

```text
打开
关闭
加载
刷新
Loading
Error
```

## 2. 客户头部摘要

至少展示后端真实存在的数据：

```text
客户姓名
手机号
客户编号（如果后端存在）
所属门店
会员状态（如果后端存在）
会员等级（如果后端存在）
主护理师
客户来源
```

字段必须以实际 VO 为准。

不存在的字段不要伪造。

---

## 3. 基础信息 Tab

完成客户基础信息展示。

如果后端详情 API 支持编辑：

可以保留：

```text
编辑
```

入口。

但是：

> 不要在本任务中重新设计客户编辑业务。

直接复用 04-1 已经实现的编辑能力。

---

## 4. 内部 Tab 框架

先把以下 Tab 做出来：

```text
基础信息
卡项信息
文件档案
服务日志
预约记录
订单信息
```

尚未开发完成的 Tab：

可以显示：

```text
暂无数据
```

或者：

```text
功能建设中
```

但不要伪造数据。

---

# 八、卡项信息 Tab

本次只建立容器。

内部分类：

```text
产品
储值卡
套餐卡
时效卡
通用次卡
项目
```

可以使用：

```text
el-tabs
```

或者当前项目已有 Tab 组件。

本次如果已有后端 API，可以接：

```text
产品
储值卡
套餐卡
时效卡
通用次卡
项目
```

如果接口尚未完成，则：

> 只创建结构，不编造接口。

后续再分别开发。

---

# 九、订单信息 Tab

内部结构：

```text
销售订单
支付明细
消耗明细
转账记录
延期记录
```

本次先建立内部 Tab。

原则：

```text
客户详情
    ↓
订单信息
    ↓
调用已有订单查询接口
```

不要在 customer API 中复制销售订单业务。

---

# 十、客户详情打开方式

从客户列表 04-1：

```text
查看
```

或者：

```text
点击客户姓名
```

调用：

```text
openCustomerDetail(customerId)
```

示例逻辑：

```ts
const customerDetailVisible = ref(false)
const selectedCustomerId = ref<number | null>(null)

function openCustomerDetail(customerId: number) {
  selectedCustomerId.value = customerId
  customerDetailVisible.value = true
}
```

具体类型以项目实际 ID 类型为准。

---

# 十一、禁止把客户对象整个复制过去

不要这样：

```ts
openCustomerDetail(row)
```

然后完全依赖列表数据。

推荐：

```ts
openCustomerDetail(row.id)
```

打开 Drawer 后：

```text
customerId
   ↓
调用详情 API
   ↓
customerDetail
```

原因：

列表数据与详情数据不是同一个数据模型。

---

# 十二、详情数据生命周期

标准流程：

```text
点击客户
    ↓
保存 customerId
    ↓
打开 Drawer
    ↓
Loading
    ↓
请求详情
    ↓
成功
    ↓
显示详情
```

关闭：

```text
关闭 Drawer
    ↓
保留或清理 customerId
```

推荐：

关闭后清理临时详情状态。

再次打开：

```text
重新请求
```

不要长期缓存客户详情。

---

# 十三、刷新机制

Drawer 内提供：

```text
刷新
```

按钮。

刷新必须：

```text
重新调用当前详情 API
```

不能：

```text
重新调用列表 API
```

也不能：

```text
强制刷新整个页面
```

---

# 十四、客户编辑后的同步

如果用户在详情中修改客户资料：

```text
保存成功
    ↓
刷新详情
    ↓
通知客户列表刷新
```

推荐使用事件或者父子组件 emit。

例如：

```ts
emit('updated')
```

由客户列表决定：

```text
重新查询列表
```

不要让详情组件直接操作客户列表 API。

---

# 十五、组件职责建议

根据项目实际结构决定最终文件位置。

建议：

```text
src/views/customer/
├── CustomerListView.vue
├── components/
│   └── CustomerDetailDrawer.vue
└── ...
```

如果当前项目已经有 customer 目录结构：

必须复用。

建议进一步拆分：

```text
CustomerDetailDrawer.vue
CustomerDetailHeader.vue
CustomerBasicInfo.vue
CustomerCardInfo.vue
CustomerFiles.vue
CustomerServiceLogs.vue
CustomerAppointments.vue
CustomerOrders.vue
```

但是：

> 不要为了拆组件而拆组件。

如果某个组件目前只有很少代码，可以暂时放在 Drawer 中。

本次重点是业务结构正确。

---

# 十六、类型设计

不要：

```ts
const detail = ref<any>()
```

禁止任何 `any`。

应该根据真实后端 VO：

```ts
export interface CustomerDetail {
  ...
}
```

具体字段必须来自实际后端。

如果后端返回结构：

```json
{
  "id": 1,
  "name": "...",
  ...
}
```

按照实际结构定义。

不要自行增加：

```ts
level
status
memberNo
```

等后端不存在的字段。

---

# 十七、API 设计

先检查当前：

```text
src/api/customer.ts
```

如果已有：

```ts
getCustomerDetail(id)
```

直接复用。

如果没有：

先检查后端。

只有确认后端已有对应接口后，才能增加：

```ts
getCustomerDetail()
```

API 方法必须使用：

```text
/v1/...
```

不要写：

```text
/api/v1/...
```

因为当前 Axios baseURL 已经是：

```text
/api
```

---

# 十八、权限

客户详情必须继续使用客户模块已有权限。

不要根据：

```text
role === '店长'
```

决定是否显示。

使用：

```text
permissionStore
```

或者：

```text
v-permission
```

具体权限码必须扫描真实后端。

禁止自己创造：

```text
customer:detail
customer:view
```

除非后端实际已经存在。

---

# 十九、数据权限

客户详情必须遵循后端数据权限。

不要在前端自行判断：

```text
当前门店
区域
本人
指定门店
总部
```

前端只传：

```text
customerId
```

后端负责判断当前用户是否有权查看。

如果后端返回：

```text
10002
10003
```

使用项目现有统一错误处理。

不要自己弹第二个错误消息。

---

# 二十、加载状态

Drawer 至少需要：

```text
详情 Loading
Tab Loading
局部 Loading
```

不要整个 Drawer 一直白屏。

推荐：

```text
el-skeleton
```

或者当前项目已有：

```text
AppLoading
```

如果 API 请求失败：

使用：

```text
AppError
```

或者项目统一错误组件。

提供：

```text
重新加载
```

按钮。

---

# 二十一、空状态

例如：

```text
没有预约记录
没有服务日志
没有文件档案
没有订单
```

必须使用：

```text
AppEmpty
```

禁止自己到处写：

```text
暂无数据
```

形成多套视觉规范。

---

# 二十二、错误处理

继续使用：

```text
src/utils/ui/
```

统一错误处理。

禁止在 API 层直接：

```ts
ElMessage.error()
```

禁止在 request interceptor 中弹消息。

组件捕获：

```ts
try {
  ...
} catch (error) {
  handleUiError(error)
}
```

具体写法以当前项目已经通过验收的实现为准。

---

# 二十三、Drawer 关闭行为

用户关闭：

```text
X
点击遮罩
ESC
```

都应该正确关闭。

如果正在提交编辑：

必须遵循当前项目已有 Confirm 机制。

如果只是查看：

直接关闭。

不要阻止用户关闭。

---

# 二十四、详情中的“开单”

客户详情未来需要有：

```text
开单
```

入口。

但是本次：

> 不开发开单业务。

如果客户列表已经有开单功能：

复用现有入口。

如果详情头部需要预留：

可以放：

```text
[开单]
```

但点击后必须调用已有开单跳转/打开机制。

如果尚无统一实现：

暂时不要添加假的按钮。

---

# 二十五、特别重要：不要新增全局 Tab

禁止：

```text
点击客户
→ router.push('/customer/detail/123')
```

禁止：

```text
router.addRoute(...)
```

禁止：

```text
tabs.addTab(...)
```

客户详情必须：

```text
CustomerListView
    ↓
CustomerDetailDrawer
```

---

# 二十六、不要破坏现有 AppTabs

04-2 开发完成后：

客户管理仍然只有：

```text
客户管理
```

一个全局业务 Tab。

例如：

```text
首页
客户管理
项目管理
...
```

点击客户：

```text
客户管理 Tab
    ↓
Drawer
```

全局 Tab 数量不增加。

---

# 二十七、不要破坏组织树门店切换

当前门店选择器已经改成：

```text
组织树
```

这是当前项目的新标准。

本任务：

禁止恢复为：

```text
普通 select
```

禁止重新实现门店切换。

客户详情打开时使用当前 Auth/Store 上下文。

如果切换门店后重新进入客户详情：

由后端权限控制。

---

# 二十八、UI 交互建议

详情顶部：

```text
客户姓名
手机号

所属门店
会员等级
客户来源
主护理师
```

右侧：

```text
刷新
编辑
开单（如果现有能力已支持）
关闭
```

下面：

```text
基础信息
卡项信息
文件档案
服务日志
预约记录
订单信息
```

---

# 二十九、基础信息展示建议

根据后端实际字段动态决定。

可以分组：

```text
基本资料

姓名
手机号
性别
生日
微信/联系方式
客户来源
所属门店
会员等级
主护理师
创建时间
最近消费时间
```

注意：

只有后端真实返回的字段才能展示。

不要因为设计上“应该有”就创建假字段。

---

# 三十、客户详情数据模型

建议逻辑：

```text
CustomerDetailDrawer
        │
        ├── customerId
        │
        ├── detail
        │
        ├── activeTab
        │
        ├── loading
        │
        └── error
```

例如：

```ts
const visible = ref(false)
const customerId = ref<number | null>(null)
const activeTab = ref('basic')
const loading = ref(false)
const detail = ref<CustomerDetail | null>(null)
```

---

# 三十一、Tab 懒加载

不要一打开详情就同时请求：

```text
客户详情
卡项
订单
预约
日志
文件
```

这样会造成：

```text
一个客户详情
→ 6~10 个接口
→ 首屏很慢
```

推荐：

```text
打开 Drawer
    ↓
只加载基础信息
```

用户点击：

```text
卡项信息
```

再加载卡项。

用户点击：

```text
订单信息
```

再加载订单。

用户点击：

```text
预约记录
```

再加载预约。

即：

```text
按 Tab 懒加载。
```

---

# 三十二、Tab 加载状态

每个 Tab 独立：

```text
basicLoading
cardLoading
fileLoading
serviceLogLoading
appointmentLoading
orderLoading
```

或者建立统一 Map：

```ts
const tabLoading = reactive<Record<string, boolean>>({})
```

具体实现根据代码质量选择。

不要为了简单使用：

```text
一个全局 loading
```

导致切换 Tab 时整个 Drawer 闪烁。

---

# 三十三、Tab 数据缓存

本次推荐：

```text
首次进入 Tab → 请求
再次进入 → 使用当前结果
```

如果用户点击：

```text
刷新
```

则：

```text
重新请求当前 Tab
```

如果客户资料发生变化：

```text
重新加载基础信息
```

后续业务操作成功后：

```text
只刷新受影响 Tab
```

不要每次都重新请求所有 Tab。

---

# 三十四、与 04-1 客户列表连接

04-1 已经存在客户列表。

修改：

```text
查看
```

行为。

从：

```text
未来路由/未实现
```

统一变成：

```text
openCustomerDetail(row.id)
```

如果 04-1 已经实现了某种查看弹窗：

不要重复创建。

直接改造成正式的：

```text
CustomerDetailDrawer
```

---

# 三十五、不要影响新增/编辑客户

04-1 已经 PASS。

本次不能因为增加详情而破坏：

```text
新增
编辑
查询
重置
分页
门店切换
权限
```

必须进行回归测试。

---

# 三十六、开发顺序

严格按照以下顺序：

## Step 1

扫描：

```text
客户列表
客户 API
客户类型
客户 Controller
客户详情 VO
权限码
```

输出扫描结果。

---

## Step 2

确认：

```text
实际客户详情 API
实际响应结构
实际权限码
实际 ID 类型
```

---

## Step 3

创建/修改：

```text
CustomerDetailDrawer.vue
```

---

## Step 4

完成：

```text
Drawer
客户摘要
基础信息
```

---

## Step 5

增加：

```text
内部 Tabs
```

---

## Step 6

实现：

```text
Tab 懒加载结构
```

---

## Step 7

如果后端接口已经存在：

逐步接入：

```text
卡项
文件
服务日志
预约
订单
```

否则保留结构，不造假数据。

---

## Step 8

连接：

```text
CustomerListView
```

---

## Step 9

运行：

```bash
npm run type-check
npm run build
```

具体命令以 package.json 为准。

---

# 三十七、浏览器验证

必须实际打开浏览器验证。

至少验证：

### 1. 客户列表

```text
正常进入
```

### 2. 查看客户

```text
点击客户
→ Drawer 打开
```

### 3. 数据

```text
真实客户信息显示
```

### 4. 关闭

```text
关闭 Drawer
→ 客户列表正常
```

### 5. 再次打开

```text
重新请求详情
```

### 6. Tab

依次测试：

```text
基础信息
卡项信息
文件档案
服务日志
预约记录
订单信息
```

### 7. 空状态

没有数据时：

```text
AppEmpty
```

### 8. 错误

模拟接口异常：

```text
AppError
重新加载
```

### 9. 权限

无权限时：

```text
后端返回 10002
```

确认统一错误处理。

### 10. 门店切换

```text
1001
→ 1005
→ 客户管理
→ 查看客户
```

验证详情正常使用当前门店上下文。

---

# 三十八、必须回归的现有功能

不能只验证详情。

必须回归：

```text
登录
权限
组织树门店切换
客户列表
客户搜索
客户分页
客户新增
客户编辑
客户查看
全局 Tab
面包屑
员工菜单
退出登录
```

---

# 三十九、禁止事项

本任务严禁：

```text
禁止 any
禁止新增 customer/detail 路由
禁止新增全局 Tab
禁止伪造后端 API
禁止伪造后端字段
禁止修改后端业务
禁止修改数据库
禁止重新实现销售业务
禁止重新实现耗卡业务
禁止重新实现预约业务
禁止自己判断数据权限
禁止 role === 店长 之类的权限判断
禁止恢复简单门店下拉框
禁止破坏已有客户列表
禁止大面积重构前端基础框架
```

---

# 四十、完成标准

只有同时满足以下条件，才能宣布：

```text
04-2 PASS
```

### 功能

* [ ] 客户列表可以打开客户详情
* [ ] 详情使用 Drawer/Dialog
* [ ] 没有新增全局 Tab
* [ ] 没有新增客户详情路由
* [ ] 客户基础信息真实展示
* [ ] 内部业务 Tab 正常切换
* [ ] Tab 按需加载
* [ ] Loading 正常
* [ ] Empty 正常
* [ ] Error 正常
* [ ] Refresh 正常
* [ ] Close 正常

### 数据

* [ ] 使用真实客户 API
* [ ] 使用真实 VO
* [ ] 无虚构字段
* [ ] 无虚构接口
* [ ] 客户 ID 类型正确
* [ ] 门店上下文正确
* [ ] 数据权限交给后端

### 架构

* [ ] 没有增加全局路由
* [ ] 没有增加全局 Tab
* [ ] 没有破坏 AppTabs
* [ ] 没有破坏组织树门店切换
* [ ] 没有破坏 04-1
* [ ] customer 模块没有复制其他领域业务逻辑

### 工程

* [ ] type-check PASS
* [ ] build PASS
* [ ] 浏览器运行 PASS
* [ ] 控制台无新增严重错误
* [ ] 代码无 any
* [ ] API 调用符合当前 request 规范

---

# 四十一、最终向我汇报的格式

完成后不要只说：

```text
完成了
```

必须按照下面格式汇报：

```text
【客户管理 04-2 验收报告】

一、后端接口扫描
- 客户详情接口：
- 客户相关接口：
- 实际权限码：
- 实际 VO：

二、本次修改文件
- xxx
- xxx
- xxx

三、已实现
- 客户详情 Drawer：
- 客户基础信息：
- 内部 Tab：
- Tab 懒加载：
- Loading：
- Empty：
- Error：
- Refresh：

四、未实现
- xxx
- xxx

五、验证
- npm run type-check：PASS/FAIL
- npm run build：PASS/FAIL
- 浏览器：PASS/FAIL

六、回归
- 客户列表：PASS/FAIL
- 客户新增：PASS/FAIL
- 客户编辑：PASS/FAIL
- 门店切换：PASS/FAIL
- 权限：PASS/FAIL

七、问题
- xxx

八、下一步建议
- ...
```

如果发现后端接口问题：

不要为了让前端 PASS 而绕过。

明确报告：

```text
后端接口问题
```

如果问题可以通过前端适配解决，再适配。

如果必须修改后端：

暂停该部分，并说明：

```text
需要后端修改
```

不要擅自修改后端业务规则。

---

# 四十二、最终目标

本次不是追求“页面看起来完成”。

而是建立后续客户详情开发的正确基础：

```text
客户列表
    │
    └── 客户详情 Drawer
          │
          ├── 基础信息
          │
          ├── 卡项信息
          │
          ├── 文件档案
          │
          ├── 服务日志
          │
          ├── 预约记录
          │
          └── 订单信息
```

最终形成：

```text
一个客户管理业务页面
+
一个客户详情业务容器
+
多个领域数据入口
```

而不是：

```text
一个客户列表页面
+
一个客户详情路由
+
一堆重复业务代码
```

这套结构必须为后续：

```text
04-3 客户详情-卡项信息
04-4 客户详情-订单信息
04-5 客户详情-预约/服务日志/档案
04-6 客户设置
04-7 客户运营
```

继续复用。
