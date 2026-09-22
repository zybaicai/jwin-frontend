# ERP系统前端项目初始化 Prompt

> 版本：V1.0
> 当前阶段：前端项目初始化
> 前置规则：必须先遵守《00-Cursor前端开发总规则.md》

---

# 一、你的当前角色

你现在是本 ERP 项目的：

> 高级 Vue 3 + TypeScript 前端工程师。

当前任务不是开发 ERP 业务功能。

你现在只负责：

> **从零初始化 ERP 前端工程。**

---

# 二、首先阅读规则

开始执行之前，必须先阅读：

```text
ERP项目设计/cursor/frontend/00-Cursor前端开发总规则.md
```

必须遵守其中所有规则。

如果当前项目目录中找不到该文件：

不要自行猜测规则。

请先告诉我：

```text
未找到：
00-Cursor前端开发总规则.md

请先提供该文件后再继续。
```

---

# 三、当前任务范围

当前只做：

```text
Vue 3
+
TypeScript
+
Vite
+
Element Plus
+
Pinia
+
Vue Router
+
Axios
```

完成一个可以正常启动、正常访问的前端基础项目。

---

# 四、当前阶段明确禁止做的事情

非常重要。

当前阶段：

## 禁止开发登录

不要创建：

```text
Login.vue
LoginForm.vue
```

不要实现：

```text
登录接口
Token
JWT
/auth/me
```

---



## 禁止开发权限

不要实现：

```text
角色
权限
菜单权限
按钮权限
路由权限
```

---



## 禁止开发门店

不要实现：

```text
当前门店
门店切换
门店选择器
storeId
门店权限
```

---



## 禁止开发业务模块

不要开发：

```text
客户
销售
开单
支付
消费
预约
卡项
绩效
库存
营销
报表
系统管理
```

---



## 禁止提前设计业务API

不要创建：

```text
customer.ts
sales.ts
appointment.ts
inventory.ts
```

等业务 API 文件。

---



# 五、项目技术栈

必须使用：

```text
Vue 3
TypeScript
Vite
Element Plus
Pinia
Vue Router
Axios
```

优先使用当前稳定版本。

不要为了追求最新版本而使用明显不成熟的版本。

如果项目已有 package.json：

> 先检查现有版本，不要无理由升级。

---



# 六、初始化前先检查环境

在执行初始化之前，先检查：

```text
Node.js
npm
pnpm
```

至少确认：

```text
node -v
npm -v
```

如果项目使用 pnpm，则检查：

```text
pnpm -v
```

---



# 七、如果当前目录为空

如果当前工作目录是空目录：

创建 Vue 3 + TypeScript + Vite 项目。

推荐：

```text
Vue
TypeScript
Vite
```

项目必须能够正常：

```text
npm install
npm run dev
```

或者如果项目使用 pnpm：

```text
pnpm install
pnpm dev
```

---



# 八、如果项目已经存在

如果当前目录已经存在前端项目：

不要直接覆盖。

先检查：

```text
package.json
src/
vite.config.*
tsconfig.*
index.html
```

判断项目当前状态。

然后输出：

```text
【现有项目检查】

项目类型：
Vue / 非Vue / 无法判断

Vue版本：
xxx

TypeScript：
xxx

Vite：
xxx

Element Plus：
已安装 / 未安装

Pinia：
已安装 / 未安装

Vue Router：
已安装 / 未安装

Axios：
已安装 / 未安装

结论：
可以继续初始化 / 需要人工确认
```

如果现有项目已经是可运行的 Vue 3 + TypeScript + Vite 项目：

> 不要重新创建项目。

直接进入依赖补充和基础结构整理。

---



# 九、安装依赖

必须确保存在：

```text
vue
vue-router
pinia
element-plus
axios
```

开发依赖：

```text
typescript
vite
@vitejs/plugin-vue
```

以及 Vue 3 + TypeScript 项目所需要的基础依赖。

---



# 十、初始化项目后的最低要求

项目至少应该能够：

```text
npm install
```

成功。

并能够：

```text
npm run dev
```

成功启动。

浏览器可以打开：

```text
http://localhost:5173
```

或者 Vite 实际输出的地址。

---



# 十一、创建基础目录

当前阶段不要创建大量业务目录。

只建立基础工程结构。

推荐：

```text
src/
├── api/
├── assets/
├── components/
├── composables/
├── constants/
├── layouts/
├── router/
├── stores/
├── types/
├── utils/
├── views/
├── App.vue
└── main.ts
```

注意：

当前这些目录只是工程基础目录。

暂时不要往里面大量添加业务代码。

---



# 十二、当前阶段可以创建的基础文件

可以创建：

```text
src/
├── router/
│   └── index.ts
│
├── stores/
│
├── api/
│
├── utils/
│
├── types/
│
├── components/
│
├── layouts/
│
├── views/
│
├── App.vue
└── main.ts
```

如果某个目录目前没有实际代码，可以只创建目录，不需要为了“看起来完整”而制造大量空文件。

---



# 十三、main.ts

完成 Vue 应用基础初始化。

至少建立：

```text
Vue
Element Plus
Pinia
Vue Router
```

最终形成类似：

```typescript
createApp(App)
  .use(pinia)
  .use(router)
  .use(ElementPlus)
  .mount('#app')
```

具体实现方式根据实际项目情况决定。

---



# 十四、Pinia初始化

建立 Pinia 基础能力。

当前只需要：

> Pinia 能够正常注册。

不要现在创建：

```text
userStore
authStore
permissionStore
storeStore
```

这些将在：

```text
03-Cursor前端基础框架开发Prompt.md
```

阶段建立。

---



# 十五、Vue Router初始化

建立基础 Router。

当前只需要：

> Router 可以正常注册。

可以建立一个最简单的测试首页，例如：

```text
/
```

对应：

```text
Home / Welcome
```

用于验证 Router 正常工作。

---



# 十六、Element Plus初始化

完成：

```text
Element Plus
```

注册。

同时确认：

```text
el-button
el-input
el-card
```

等基础组件可以正常使用。

可以在临时首页做最简单验证。

---



# 十七、Axios初始化

当前阶段只需要建立 Axios 基础能力。

建议建立：

```text
src/utils/request.ts
```

可以创建统一 Axios 实例：

```text
request
```

但是：

当前不要实现：

```text
Token
Authorization
401
403
登录
```

这些属于后续基础框架阶段。

当前只建立：

> 一个可被后续扩展的 Axios 基础请求实例。

---



# 十八、环境变量基础

如果项目需要 API 地址配置，可以建立：

```text
.env
.env.development
.env.production
```

例如：

```text
VITE_API_BASE_URL
```

但是不要现在硬编码真实生产服务器地址。

如果后端地址目前还没有最终确定：

可以暂时使用：

```text
VITE_API_BASE_URL=/api
```

或者根据现有项目情况采用合理的开发配置。

如果无法判断：

> 不要猜，报告给我。

---



# 十九、Vite配置

检查：

```text
vite.config.ts
```

确保：

- Vue 插件正常
- TypeScript 正常
- 开发服务器正常
- 路径配置合理

如果配置 API Proxy：

必须根据实际后端地址配置。

如果后端地址不明确：

不要自行假设。

---



# 二十、TypeScript配置

检查：

```text
tsconfig.json
```

确保：

- Vue 3 正常
- TypeScript 正常
- Vite 正常
- IDE 能够正确识别 `.vue`
- 路径别名如果配置，必须能正常工作

推荐后续统一使用：

```text
@
```

作为：

```text
src
```

的路径别名。

例如：

```typescript
import xxx from '@/xxx'
```

如果配置路径别名：

必须确保：

```text
Vite
TypeScript
Cursor/IDE
```

三者保持一致。

---



# 二十一、ESLint / Prettier

如果当前项目已经配置：

```text
ESLint
Prettier
```

保留并检查。

如果没有：

可以根据项目实际情况建立基础配置。

但是：

> 不要为了初始化项目而引入大量没有必要的工具。

如果添加：

必须说明：

```text
为什么需要
解决什么问题
增加了什么依赖
```

---



# 二十二、首页验证

当前阶段需要一个非常简单的首页。

例如：

```text
ERP系统
前端项目初始化成功
```

可以包含：

```text
Element Plus按钮
当前环境信息
```

目的只有一个：

> 验证整个 Vue 基础工程运行正常。

---



# 二十三、当前首页禁止做的事情

不要在首页实现：

```text
登录
用户
门店
权限
菜单
销售
客户
```

首页只是：

> 初始化验证页面。

---



# 二十四、不要过度设计

当前阶段不要建立：

```text
复杂Layout
复杂组件系统
复杂主题系统
复杂权限系统
复杂状态系统
复杂请求系统
```

这些将在后续阶段逐步建立。

---



# 二十五、CSS原则

建立基础全局样式即可。

例如：

```text
body
html
#app
```

保证：

- 高度正常
- 宽度正常
- margin 清除
- box-sizing 合理

不要现在设计完整 ERP UI 风格。

---



# 二十六、项目启动验证

完成以后必须实际执行：

```text
npm install
```

然后：

```text
npm run dev
```

必须确认：

```text
项目启动成功
页面能够访问
浏览器没有明显运行时错误
```

---



# 二十七、构建验证

还需要执行：

```text
npm run build
```

确保生产构建能够成功。

如果项目没有 build 脚本：

必须说明。

---



# 二十八、类型检查

如果项目存在类型检查脚本：

执行。

例如：

```text
npm run type-check
```

或者：

```text
vue-tsc --noEmit
```

如果没有：

根据项目情况判断是否需要增加。

---



# 二十九、不要修改后端

本次任务：

> 只修改前端。

禁止：

- 修改 Spring Boot
- 修改后端 API
- 修改数据库
- 修改 SQL
- 修改后端 DTO
- 修改后端 Controller

---



# 三十、不要创建业务API

本次任务不要创建：

```text
customer.ts
sales.ts
payment.ts
appointment.ts
inventory.ts
performance.ts
```

这些以后按照模块逐步创建。

---



# 三十一、如果遇到问题

如果出现：

```text
npm安装失败
Node版本不兼容
依赖冲突
Vite错误
TypeScript错误
Element Plus错误
```

不要通过大量降级、升级依赖来“试试看”。

先分析：

```text
问题
原因
影响
建议
```

如果需要改变技术栈版本：

必须告诉我。

---



# 三十二、如果遇到版本问题

输出：

```text
【版本问题】

当前环境：
Node：
npm：
Vue：
Vite：
TypeScript：

问题：
xxx

原因：
xxx

候选方案：

方案A：
xxx

方案B：
xxx

建议：
xxx

需要人工确认：
是 / 否
```

---



# 三十三、初始化完成后的最终结构

完成后，项目结构大致应该类似：

```text
frontend/
│
├── public/
│
├── src/
│   ├── api/
│   ├── assets/
│   ├── components/
│   ├── composables/
│   ├── constants/
│   ├── layouts/
│   ├── router/
│   ├── stores/
│   ├── types/
│   ├── utils/
│   ├── views/
│   │
│   ├── App.vue
│   └── main.ts
│
├── .env*
├── index.html
├── package.json
├── tsconfig*.json
├── vite.config.ts
└── ...
```

---



# 三十四、初始化完成后的输出要求

Cursor 完成以后必须严格按照下面格式汇报：

```text
【前端项目初始化完成】

一、技术栈

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


二、运行环境

Node：
xxx

npm：
xxx

包管理器：
npm / pnpm


三、项目结构

请列出主要目录。


四、已创建文件

请列出本次新增的重要文件。


五、已安装依赖

请列出新增依赖。


六、运行验证

npm install：
成功 / 失败

npm run dev：
成功 / 失败

npm run build：
成功 / 失败

类型检查：
成功 / 失败 / 未配置


七、浏览器验证

访问地址：
xxx

页面：
正常 / 异常


八、发现的问题

没有则写：

无。


九、当前未实现内容

明确写：

登录：未实现
Token：未实现
当前用户：未实现
权限：未实现
门店切换：未实现
ERP Layout：未实现
业务模块：未实现


十、下一步

等待进入：

02-Cursor前端项目扫描Prompt.md
```

---



# 三十五、完成标准

只有同时满足以下条件，才算本阶段完成：

```text
✓ Vue 3正常
✓ TypeScript正常
✓ Vite正常
✓ Element Plus正常
✓ Pinia正常
✓ Vue Router正常
✓ Axios基础实例正常
✓ npm install成功
✓ npm run dev成功
✓ npm run build成功
✓ 首页正常显示
✓ 无明显控制台错误
```

---



# 三十六、最重要的限制

再次强调：

> **不要提前开发登录。**

> **不要提前开发权限。**

> **不要提前开发门店切换。**

> **不要提前开发ERP Layout。**

> **不要提前开发销售页面。**

> **不要提前开发任何业务模块。**

本次任务只有一个目标：

> **把一个干净、稳定、可扩展的 Vue3 ERP 前端工程搭起来。**

完成后停止。

等待下一条指令。