# 04-17 Cursor客户标签管理开发 Prompt

## 一、任务名称

客户管理——客户标签管理

---

## 二、本阶段目标

完善客户管理中的「标签」能力。

本阶段同时包含两个层次：

1. 系统标签库管理
2. 客户标签关系管理

最终形成：

```text
客户管理
│
├── 客户列表
│
├── 客户详情
│   └── 基本档案
│       └── 客户标签
│
└── 客户标签管理
    ├── 标签列表
    ├── 新增标签
    ├── 修改标签
    ├── 删除标签
    └── 给客户贴标 / 取消贴标
```

## 三、重要边界

本阶段只做「客户标签」。

禁止顺手开发：客户来源、会员等级、客户运营、回访、话术、会员价、服务人员配置、文件档案、销售开单、项目选择、支付。

## 四、API（必须以文档为准）

### 系统标签

- `GET /api/v1/customer-tags`（keyword/page/size）
- `GET /api/v1/customer-tags/all`
- `GET /api/v1/customer-tags/{id}`
- `POST /api/v1/customer-tags` `{ "name": "..." }`
- `PUT /api/v1/customer-tags/{id}` `{ "name": "..." }`
- `DELETE /api/v1/customer-tags/{id}`（同时解除所有顾客贴标）

### 客户标签关系

- `GET /api/v1/customers/{id}/tags`
- `POST /api/v1/customers/{id}/tags` `{ "tagId" }` / `{ "tagIds": [] }`
- `DELETE /api/v1/customers/{id}/tags/{tagId}`（仅取消关系）

## 五、权限（后端真实码）

- `customer:tag:view` / `customer:tag:edit` —— 标签库
- `customer:list:view` —— 查客户标签、/all
- `customer:edit` —— 贴标 / 取消贴标

## 六、验收重点

系统标签库可管理 + 客户可贴标/取消贴标 + 客户详情真实显示 + 权限/数据权限正确。

不要因为客户来源、会员等级、客户运营尚未开发而判本阶段 FAIL。
