# 03-8 Cursor 前端 Sidebar + Header 开发 Prompt

## 一、任务背景

03-7 已完成 MainLayout 基础骨架：

- `src/layouts/MainLayout.vue` 已存在
- 结构为：Sidebar Placeholder + Main Area（Header Placeholder + RouterView）
- 路由 `/` 已指向 MainLayout，子路由 `''` 指向 HomeView
- `#app` 高度已对齐 `html/body`，内容区独立滚动

本阶段（03-8）目标：**把 Sidebar Placeholder 和 Header Placeholder 替换为真实可用的侧边栏和顶栏**，但不接入权限、不接入业务模块、不做 StoreSelector、不做 Breadcrumb。

## 二、变更边界（必须严格遵守）

以下内容 **禁止修改**：

- Auth Store（`src/stores/auth.ts`）
- Permission Store（如存在）
- Store Context（如存在）
- Request 封装（`src/api/`、`src/utils/request.ts` 等）
- Login 流程（`src/views/LoginView.vue`、`src/stores/auth.ts` 中 login 相关）
- Router Guard 核心逻辑（`src/router/index.ts` 中守卫放行规则）
- 后端接口、数据库、03-4 / 04～11 阶段内容

以下内容 **本阶段不做**：

- 权限菜单（菜单项不根据 permissionCodes 过滤）
- StoreSelector（门店切换）
- Breadcrumb
- 业务模块页面
- 主题切换
- 国际化



## 三、本阶段要做的事



### 1. Sidebar 真实化

将 `MainLayout.vue` 中的 Sidebar Placeholder 替换为真实侧边栏组件。

要求：

- 固定在左侧，不随内容区滚动
- 高度 = 窗口高度，底部不塌陷
- 有独立的滚动容器（菜单多时可滚）
- 支持折叠/展开
- 折叠后只显示图标，展开后显示图标 + 文字
- 菜单项激活态正确（当前路由高亮）
- 菜单项 hover 态正常
- 菜单项点击后路由跳转正确
- 菜单项文字过长时有省略或换行处理
- 不硬编码权限判断

菜单数据来源：

- 本阶段先用 **静态配置**，放在 `src/config/menu.ts` 或 `src/layouts/menu.ts`
- 菜单项结构建议：`{ path, name, title, icon }`
- 菜单项先覆盖：首页（`/`），其余可留 1～2 个占位项，但不要指向不存在的路由

组件拆分建议：

- `src/layouts/components/AppSidebar.vue`
- `src/layouts/components/SidebarMenu.vue`（可选）
- `src/layouts/components/SidebarMenuItem.vue`（可选）



### 2. Header 真实化

将 `MainLayout.vue` 中的 Header Placeholder 替换为真实顶栏组件。

要求：

- 固定在顶部，不随内容区滚动
- 顶栏高度固定，不塌陷
- 左侧有折叠按钮（控制 Sidebar 折叠/展开）
- 右侧有用户信息展示（从 Auth Store 的 `currentUser` / `employee` 读取）
- 右侧有退出登录入口
- 退出登录后 Token 清除，回到登录页（复用现有 `authStore.logout()`）
- 不硬编码权限判断

组件拆分建议：

- `src/layouts/components/AppHeader.vue`
- `src/layouts/components/HeaderUser.vue`（可选）



### 3. MainLayout 结构调整

`MainLayout.vue` 调整为：

```text
MainLayout
├── AppSidebar
└── Main Area
    ├── AppHeader
    └── RouterView
要求：

整体布局：Sidebar 固定 + Header 固定 + 内容区独立滚动

文档高度 = 窗口高度，不出现整页滚动条

内容区高度不足时，不出现内容区滚动条

内容区高度超出时，只在内容区滚动

侧边栏折叠/展开时，内容区宽度自适应

没有横向滚动条

4. CSS 调整
如需新增样式，优先写在组件内 <style scoped>

如需全局变量，写在 src/style.css，但不要改主题

确保 html、body、#app 高度链路仍然正确（03-7 已处理，不要破坏）

四、验收标准
1. 变更边界
□ 未修改 Auth Store
□ 未修改 Permission Store
□ 未修改 Store Context
□ 未修改 Request
□ 未修改 Login
□ 未修改 Router Guard 核心逻辑
□ 未新增业务模块
2. Sidebar
□ 固定左侧，不随内容区滚动
□ 高度 = 窗口高度
□ 独立滚动容器
□ 折叠/展开正常
□ 激活态正确
□ hover 态正常
□ 点击跳转正确
□ 文字过长有处理
□ 无硬编码权限判断
3. Header
□ 固定顶部，不随内容区滚动
□ 高度固定
□ 有折叠按钮
□ 有用户信息展示
□ 有退出登录入口
□ 退出后 Token 清除，回到登录页
□ 无硬编码权限判断
4. 布局与滚动
□ 文档高度 = 窗口高度
□ 内容区独立滚动
□ 无整页滚动条
□ 无横向滚动条
□ 1100×640 不塌陷
□ 900×600 仍可用
□ 折叠/展开时内容区自适应
5. 认证路径回归（03-7 不能破）
□ 登录后 / 出现 Sidebar + Header + 首页内容
□ 刷新后仍是测试员工、门店杭州河滨之城店
□ 无 Token 访问 / 进入 /login，且没有主框架
□ 拦截 /me 后进入 /auth-init-error?redirect=/，Token 仍在，页面上没有主框架
□ 恢复网络并重试后回到 /
□ 退出后回到登录页，Token 已清除
□ 10001 能正确进登录页
□ 10002/10003 保留 Token，不登出
6. 代码质量
□ Type Check：PASS
□ Build：PASS
□ Lint：未配置 / PASS（如有配置）
□ IDE 诊断无错误
□ 无 console.log 残留
□ 无注释掉的死代码
□ 组件命名符合项目规范
□ 文件放在正确目录
五、Runtime 验证（必须实机跑）
text
登录：PASS
刷新：PASS
MainLayout：PASS
Home：PASS
无 Token：PASS
AuthInitError：PASS
滚动：PASS
退出登录：PASS
Sidebar 折叠/展开：PASS
Sidebar 菜单跳转：PASS
Header 用户信息展示：PASS
Header 退出入口：PASS
六、报告要求
开发完成后，输出一份 03-8 开发报告，必须包含：

扫描结果（当前 Router、App.vue、Layout、CSS 情况）

新增文件列表

修改文件列表

未修改文件列表（明确边界）

Sidebar 结构说明

Header 结构说明

MainLayout 结构调整说明

CSS 调整说明

Type Check / Build / Lint 结果

Runtime 验证结果

变更边界确认（逐条打勾）

已知遗留项

是否可以进入下一阶段：YES / NO

七、执行顺序建议
先读 src/layouts/MainLayout.vue、src/router/index.ts、src/style.css

再读 src/stores/auth.ts（只读，不修改）

创建 src/config/menu.ts 或 src/layouts/menu.ts

创建 src/layouts/components/AppSidebar.vue

创建 src/layouts/components/AppHeader.vue

修改 src/layouts/MainLayout.vue，接入 Sidebar + Header

跑 Type Check / Build

跑 Runtime 验证

输出 03-8 开发报告

八、注意事项
不要提前实现权限菜单，菜单项先静态

不要提前实现 StoreSelector

不要提前实现 Breadcrumb

不要修改 Router Guard 核心逻辑

不要破坏 03-7 已验证的认证路径

如果发现 03-7 遗留问题，先记录，不要在本阶段顺手修

如果后端未启动，Runtime 验证中相关场景标注"未跑通"，不要假装 PASS
```

