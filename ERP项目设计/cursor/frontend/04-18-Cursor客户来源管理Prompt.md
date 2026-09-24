# 04-18 Cursor客户来源管理开发 Prompt

本文件归档自 04-18 任务指引。

## 核心目标

1. 客户来源库管理（分页 / 搜索 / 新增 / 修改 / 启用停用 / 删除）
2. 客户建档 / 列表筛选 / 详情展示接入真实来源 API
3. 不修改 04-17 客户标签实现
4. 不修改后端

## 权限（后端真实码）

- `customer:source:view` / `customer:source:edit` —— 来源库
- `customer:create` —— `/options`（建档下拉）
