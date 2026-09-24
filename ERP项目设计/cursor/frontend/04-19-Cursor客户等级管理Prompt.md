# 04-19 Cursor客户等级管理开发 Prompt

本文件归档自 04-19 任务指引。

## 扫描结论（实施前）

后端 **不存在** `CustomerLevelController` / `customer-levels` API。

客户侧已有：

- 列表查询参数 `levelId`（`CustomerPageQuery`）
- VO 字段 `levelId` / `levelName`（JOIN `TB_CustomerLevel`）
- 建档 / 更新 Command **不含** `levelId`

因此本阶段无法在不改后端的前提下完成等级库 CRUD 与 options 打通。

详见会话报告：PARTIAL。
