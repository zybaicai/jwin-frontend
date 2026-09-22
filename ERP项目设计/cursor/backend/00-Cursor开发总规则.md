## 1. 项目身份

本项目是：

**养发直营连锁门店 ERP / 收银系统内部替换项目。**

系统主要服务于：

- 总部
- 区域
- 门店
- 店长
- 员工
- 护理师
- 收银人员
- 营运人员
- 财务
- 管理人员

系统涉及：

- 项目管理
- 项目分类
- 销售渠道
- 价格体系
- 活动
- 单店特殊价格
- 价格调整权限
- 会员
- 次卡
- 时效卡
- 储值卡
- 套餐卡
- 销售
- 耗卡
- 退款
- 提成
- 员工
- 角色
- 权限
- 门店
- 区域
- 操作日志
- 数据迁移
- 新旧系统并行

---

# 2. 最高优先级原则

Cursor 必须遵循以下优先级：

```text
已确认业务规则
    >
项目设计文档
    >
现有数据库实际结构
    >
现有代码
    >
当前开发任务
    >
AI 自己的经验
```

特别说明：

AI 自己的经验永远不能覆盖已经确认的业务规则。

---

# 3. 数据库第一原则

本项目不是从零设计数据库。

现有数据库已经被业务系统使用，并且数据已经进入 BI 系统。

因此：

```text
优先复用原表
    ↓
优先复用原字段
    ↓
必要时新增字段
    ↓
必要时新增表
    ↓
最后才考虑修改原结构
```

禁止：

- 未经确认删除表
- 未经确认删除字段
- 未经确认修改字段语义
- 未经确认修改字段类型
- 未经确认修改字段默认值
- 未经确认修改历史数据
- 为了代码方便而重新设计整套数据库

任何数据库变更都必须经过：

```text
数据库变更审查
    ↓
人工确认
    ↓
才能执行
```

---



# 4. 不允许猜测业务

如果发现业务文档没有定义：

不要猜。

必须输出：

```text
【业务歧义】

问题：
XXXX

当前已知：
XXXX

方案 A：
XXXX

方案 B：
XXXX

推荐：
XXXX

推荐理由：
XXXX

需要人工确认：
XXXX
```

没有确认之前：

**不得将猜测写进核心业务代码。**

---



# 5. 标准项目原则

一个标准项目只有一个业务身份。

例如：

```text
头疗护理
```

它可以拥有：

```text
普通销售
美团
团购
其他未来渠道
```

禁止：

```text
头疗护理
头疗护理-美团
头疗护理-团购
```

把渠道创建成三个项目。

正确模型：

```text
Project
   |
   +--- SaleChannel：普通销售
   |
   +--- SaleChannel：美团
   |
   +--- SaleChannel：团购
```

---



# 6. 禁止通过名称和价格推断业务

禁止：

```java
if (price == 159) {
    channel = MEITUAN;
}
```

禁止：

```java
if (projectName.contains("美团")) {
}
```

禁止：

```java
if (price < 200) {
    cardType = ...
}
```

必须使用明确业务字段：

```text
projectId
saleChannelId
cardType
productType
priceRuleId
activityId
```

---



# 7. 历史数据不可被新规则污染

例如：

项目：

```text
头疗护理
```

原价格：

```text
999
```

后来修改：

```text
1299
```

历史订单不能变成：

```text
1299
```

必须保存：

```text
projectId
projectNameSnapshot
standardPriceSnapshot
salePriceSnapshot
```

项目名称修改同理。

---



# 8. 销售和耗卡必须分离

销售：

```text
客户付款
↓
形成销售事件
↓
销售业绩
↓
销售提成
```

耗卡：

```text
客户使用卡
↓
形成消费事件
↓
耗卡金额
↓
耗卡提成
```

两者是两个业务事件。

不能用：

```text
saleAmount = consumptionAmount
```

简单替代整个业务。

特殊情况：

团购项目立即消费：

```text
销售金额 = 159
耗卡金额 = 159
```

这是：

```text
两个事件
两个统计维度
```

而不是：

```text
营业额 = 318
```

---



# 9. 金额规则

所有金额：

```java
BigDecimal
```

禁止：

```java
double
float
```

金额计算必须明确：

```text
标准价格
销售价格
实际收款
优惠金额
耗卡金额
退款金额
提成基数
```

不能混用。

---



# 10. 价格规则

价格不是写死在代码里的。

价格必须能够支持：

```text
标准项目
+
销售渠道
+
门店
+
价格区域
+
统一活动
+
特殊活动
+
特殊门店价格
+
生效时间
+
权限
```

价格优先级必须遵循已确认设计。

默认理解：

```text
已审批的单店特殊配置
        ↓
统一活动价格
        ↓
区域标准价格
        ↓
总部基础价格
```

如果设计文档存在更新，以最新已确认设计为准。

---



# 11. 前端不是最终业务判断者

前端可以：

- 展示价格
- 展示渠道
- 展示优惠
- 展示可调整
- 展示限制

但是：

**后端必须重新计算。**

例如：

```text
前端提交：
salePrice = 149
```

后端不能直接相信。

必须重新：

```text
查询项目
↓
查询渠道
↓
查询当前价格规则
↓
查询活动
↓
查询门店
↓
查询价格调整权限
↓
判断149是否合法
↓
最终确定价格
```

---



# 12. 核心财务操作必须事务化

至少包括：

```text
销售
充值
耗卡
退款
储值卡扣款
提成结算
```

涉及余额、次数、库存、资金变化时必须考虑：

```text
事务
并发
重复提交
幂等
锁
回滚
```

---



# 13. 分层原则

默认架构：

```text
Controller
    ↓
Application Service
    ↓
Domain Service
    ↓
Repository
    ↓
Mapper
    ↓
SQL Server
```

禁止：

```text
Controller → Mapper
```

禁止把全部业务写到 Controller。

---



# 14. 核心业务对象

根据当前设计，至少包含：

```text
Project
ProjectCategory
SaleChannel
Store
PriceArea
PriceRule
Activity
SpecialPriceApply
SpecialPriceRule
PriceChangePermission

GeneralTimesCard
TimeCard
StoredValueCard
PackageCard
PackageCardItem

CustomerCard
CustomerCardItem

SaleOrder
SaleOrderItem

ConsumptionOrder
ConsumptionItem

RefundOrder
RefundItem

SalesCommissionRule
ConsumptionCommissionRule
ConsumptionCommissionTier
CommissionRecord
```

如果现有项目已经有对应 Entity：

**优先映射和复用。**

不得机械创建重复 Entity。

---



# 15. 提成规则

销售提成：

```text
项目
+
销售渠道
+
角色
+
生效时间
+
提成比例
```

销售提成没有默认阶梯逻辑，除非业务文档明确要求。

例如：

```text
项目A
美团
护理师
5%
```

消费提成：

支持：

```text
角色
+
等级/阶梯
+
金额区间
+
提成比例
```

提成计算完成以后必须保存快照。

历史提成不能因为规则后来修改而变化。

---



# 16. 储值卡

必须明确区分：

```text
本金
赠金
```

当前规则：

```text
本金：
可以跨店

赠金：
不能退款
不能跨店
```

消费时：

```text
由护理师选择扣款顺序
```

有效期默认：

```text
3年
```

过期：

```text
小程序不可见
门店允许延期
```

储值卡消费折扣：

```text
项目原价
×
当前门店所属价格区域折扣
```

例如：

```text
一线市场：5折
二线市场：4折
```

历史消费必须保存：

```text
标准价格
价格区域
折扣
实际消费金额
```

---



# 17. 套餐卡

套餐设计时确定：

```text
项目
次数
单项价值
```

销售以后形成：

```text
客户套餐卡
客户套餐卡项
```

必须保存快照。

例如：

```text
10次 × 99 = 990
```

用了3次：

```text
剩余7次
剩余价值693
```

退款必须依据：

```text
历史卡项价值
```

而不是当前项目价格。

---



# 18. 代码生成规则

每个业务模块原则上完整实现：

```text
Entity
DTO
VO
Mapper
Repository
Domain Service
Application Service
Controller
Exception
Permission
Transaction
Audit
Unit Test
Integration Test
```

如果某项确实不需要：

必须说明原因。

---



# 19. 每个模块完成以后

必须输出：

```text
开发文件清单
数据库变更
业务规则实现情况
接口清单并写到API接口设计文档.md对应地方
权限清单
事务说明
测试结果
风险
遗留问题
```

并停止。

不得自动开发下一个模块。

---



# 20. 最终原则

Cursor 不负责决定：

```text
业务应该是什么
```

Cursor 负责：

```text
把已经确定的业务正确地实现出来，如果不确定事情先参考 养发直营连锁收银系统 Cursor AI 全栈开发指导书 V1.0.md文档看模块指导，如果还不明确先停下来问我再继续
```

---

