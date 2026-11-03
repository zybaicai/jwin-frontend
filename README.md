# 预道养发 ERP 前端

养发直营连锁收银 / 门店运营 ERP 的前端工程。基于 **Vue 3 + TypeScript + Vite**，通过 `/api` 代理对接后端 `http://127.0.0.1:12002`（Spring Boot 模块化单体，包路径 `com.yudao.erp.*`）。

> 后端仓库见同目录 `jwin-sale-master`。本仓库只承载界面、路由、权限展示与接口调用，业务规则前后端以后端实现为准。

## 技术栈

| 项 | 说明 |
|---|---|
| 语言 / 框架 | TypeScript、Vue 3.5、Vue Router 5 |
| 构建 | Vite 8、`@vitejs/plugin-vue` |
| 状态管理 | Pinia 4（auth / permission / store / tabs / navigation） |
| UI 组件 | Element Plus 2（中文 locale，全量注册） |
| 请求 | Axios，统一拦截器 + `ApiResponse{code,message,data}` |
| 认证 | JWT，`localStorage` 键 `erp_access_token`，`Authorization: Bearer` |
| 权限 | 权限码 + `v-permission` 指令（仅控界面，不代替后端鉴权） |
| 其他 | `xlsx`（导入导出）、`element-china-area-data`（行政区划） |

## 已落地业务能力（节选）

- 认证与上下文：登录、`/me` 初始化、失败重试页、当前门店切换、页签缓存
- 工作台：五大业务中心（店务 / 客户 / 人事绩效 / 供应链 / 报表）侧栏导航
- 顾客管理：客户列表、详情抽屉、卡项 / 订单 / 耗卡信息、标签、来源、等级、入会门槛、档案应用场景
- 商品信息：项目分类与项目、产品、卡类分类与四类卡（通用次卡 / 时效卡 / 储值卡 / 套餐卡）、储值区域折扣、耗材类别与模板
- 订单：收银开单（客户选择、改价、经手人、结算）、销售订单列表与详情、消耗（划卡）订单
- 预约中心：预约看板、预约配置（排班 / 可约槽）、提醒记录
- 权益运营：延期申请与审批、权益转账
- 退款：退款订单列表、待审批、已完成、退款配置（销售退款 / 划卡退款）
- 人事绩效：通讯录、跨店员工、职务配置、角色权限、用户权限
- 业绩提成：经手人配置、销售 / 划卡业绩、销售 / 划卡提成规则、提成计算

详细接口与页面规则见 `ERP项目设计/`（设计文档，默认不入库）。

## 本地启动

### 环境要求

- Node.js `^22.18.0 || >=24.12.0`（`package.json` engines）
- npm 10+
- 后端已启动：`http://127.0.0.1:12002`（前端 `/api` 代理到该地址）

### 配置

| 文件 | 内容 |
|---|---|
| `.env` / `.env.development` / `.env.production` | `VITE_API_BASE_URL=/api` |
| `vite.config.ts` | 端口 `5173`，`/api` → `http://127.0.0.1:12002` |

后端地址如变更，改 `vite.config.ts` 的 `server.proxy['/api'].target` 即可。

### 运行

```bash
npm install
npm run dev
```

开发地址：<http://localhost:5173>

### 构建与类型检查

```bash
npm run build        # vue-tsc -b && vite build
npm run type-check   # 仅类型检查
npm run preview      # 预览构建产物
```

### 测试

当前仓库**尚未接入测试框架**，无 `*.spec.* / *.test.*` 或测试目录。

## 工程结构（简要）

```text
src/
  ├── main.ts              # 启动：Pinia、Router、Element Plus、v-permission、全局错误处理
  ├── api/                 # 按领域拆分的接口封装（auth/sale/treat/refund/card/customer/...）
  ├── types/               # 与接口对应的 TS 类型、ApiResponse 与错误码
  ├── utils/
  │   ├── request.ts       # Axios 实例、Bearer 注入、统一业务错误/HTTP 错误转换
  │   ├── token.ts         # localStorage 令牌读写
  │   ├── api-error.ts     # ApiBusinessError / ApiHttpError
  │   └── ui/              # message / confirm / loading / error 统一封装
  ├── stores/              # auth（/me 上下文）、permission、store（门店切换）、tabs、navigation
  ├── router/
  │   ├── index.ts         # 路由表与 RouteMeta（title/keepAlive/workspaceTab/permission/mode）
  │   └── guard.ts         # 仅做认证态保护：初始化失败跳重试页，未登录跳登录页
  ├── config/menu.ts       # 五大业务中心 → 侧栏菜单树，含权限码与面包屑解析
  ├── layouts/             # MainLayout、侧栏、顶栏、页签、切店选择器、面包屑
  ├── directives/          # v-permission（无权限则隐藏元素）
  ├── composables/         # useInfiniteList、useGoodsStoreOptions
  ├── components/          # 按业务模块拆分的对话框 / 抽屉组件
  └── views/               # 页面：customer / goods / sale / treat / refund / appointment / assetops / hr
ERP项目设计/               # 产品、领域模型、数据库、接口与研发规范文档
```

## 开发约定

- **认证态**：`auth.initialize()` 只在守卫里跑一次，同批导航共享 Promise；失败进 `/auth-init-error` 重试，不删 Token，也不当作未登录。
- **权限**：菜单与按钮读 `permissionStore` 的权限码；`v-permission` 只做界面隐藏，接口鉴权仍由后端负责。空数组语义分别为「任一满足」与「全部满足」。
- **门店上下文**：当前门店只认 `/me` 的 `storeId`；切店会作废旧 Token，成功后派发 `store-context-changed` 供业务清缓存。
- **工作区页签**：`meta.workspaceTab=true` 的叶子页进左侧菜单与页签；详情类页面不要设为 `true`。
- **请求**：业务码 10001（未授权）由请求层清 Token 并触发登录态失效事件，页面无需各自处理。

## 说明

- 运行时依赖后端 `/api/v1/**`，本地必须先起后端，否则登录与所有接口均失败。
- `ERP项目设计/` 下为研发过程文档（含 `cursor/` 分阶段 Prompt 与状态记录），不随代码分发。
