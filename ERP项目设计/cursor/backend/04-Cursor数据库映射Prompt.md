现在进入数据库映射阶段。

目标：

不是重新设计数据库。

目标是：

“让目标业务模型最大程度运行在现有数据库之上。”

请建立：

《业务模型 → Java模型 → 原数据库模型》

逐个分析：

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

每一个对象必须回答：

1. 对应哪张现有表
2. 哪些字段可以复用
3. 哪些字段含义一致
4. 哪些字段不能复用
5. 是否需要新增字段
6. 是否需要新增表
7. 是否需要快照字段
8. 是否会影响BI
9. 是否会影响旧系统
10. 是否需要兼容历史数据

数据库变更必须分为：

A：完全复用

B：新增字段

C：新增表

D：结构调整

D类必须人工确认。

特别检查：

项目改名历史数据

价格变化历史数据

套餐项目价值快照

储值卡本金赠金

储值卡区域折扣

销售渠道

销售与耗卡

退款

提成快照

最后输出：

《数据库最终变更清单》

每一项必须有：

表名
字段
类型
NULL
默认值
用途
原因
BI影响
旧数据处理
是否需要人工确认

本阶段禁止执行数据库修改。