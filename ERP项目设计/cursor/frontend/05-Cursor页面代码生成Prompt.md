---

# [05-Cursor页面代码生成Prompt.md](http://05-Cursor页面代码生成Prompt.md)

# Cursor 前端页面代码生成 Prompt

## 一、Prompt定位

你现在承担：

> **高级 Vue3 + TypeScript 前端工程师**

你的任务是：

将已经通过确认的：

> `04-Cursor页面设计Prompt.md`

输出的页面设计方案，转换为真实 Vue3 + TypeScript 页面代码。

---

# 二、最高原则

> **04 是设计依据，05 是代码实现。**

不能：

```text
代码写着写着重新设计页面
```

如果发现设计存在问题：

```text
暂停
→ 指出问题
→ 返回页面设计阶段
```

不要擅自改变业务设计。

---

# 三、技术栈

必须遵守当前项目实际技术栈。

当前目标技术栈：

```text
Vue 3
TypeScript
Vite
Element Plus
Pinia
Vue Router
Axios
```

必须先读取：

```text
package.json
vite.config.*
tsconfig.*
src/
```

以项目实际版本为准。

---

# 四、必须先检查

开始代码前必须确认：

```text
00-Cursor前端开发总规则.md
01-Cursor前端项目初始化Prompt.md
02-Cursor前端项目扫描Prompt.md
03-Cursor前端基础框架开发Prompt.md
04-Cursor页面设计Prompt.md
```

以及当前页面对应：

```text
03-功能模块设计.md
04-核心业务流程.md
05-业务规则库.md
06-角色权限模型.md
08-API接口设计.md
09-前端原型规范.md
```

---



# 五、代码结构原则

禁止把所有代码塞进一个巨大 `.vue` 文件。

根据页面复杂程度合理拆分：

```text
views/
components/
api/
types/
stores/
composables/
utils/
```

例如：

```text
views/customer/CustomerList.vue

components/customer/
├── CustomerSearch.vue
├── CustomerTable.vue
├── CustomerFormDialog.vue
└── CustomerDetailDrawer.vue

api/customer.ts
types/customer.ts
```

不要为了拆组件而过度拆分。

---



# 六、页面代码实现顺序

严格按照：

```text
1. 页面路由
2. 页面骨架
3. 查询区
4. 操作区
5. 列表
6. 分页
7. 新增/编辑
8. 详情
9. 操作弹窗
10. 页面状态
11. 权限
12. 门店上下文
13. API接入
14. 异常处理
15. 类型检查
16. 构建
```

---



# 七、TypeScript要求

禁止：

```ts
any
```

除非现有第三方库确实无法避免，并必须说明原因。

必须定义：

```ts
interface
type
enum
```

用于：

- 查询参数
- 表单
- API Response
- 列表项
- 详情
- 状态
- 枚举

---



# 八、API原则

页面代码不得自行猜接口。

必须使用：

```text
08-API接口设计
+
实际 backend Controller / DTO / VO
```

进行确认。

如果没有确认：

```text
不要创造接口。
```

---



# 九、前端不能替代后端业务计算

例如：

```text
最终销售价格
绩效
佣金
储值余额
卡剩余次数
预约可用性
库存可用数量
退款金额
```

如果后端提供计算结果：

> 前端直接展示。

不能自行复制一套业务算法。

---



# 十、按钮行为

按钮必须实现：

```text
权限控制
↓
状态判断
↓
用户确认
↓
提交中
↓
API
↓
成功
↓
刷新
```

尤其是：

```text
支付
开单
退款
开卡
充值
消耗
提交订单
```

必须防止重复提交。

---



# 十一、弹窗规范

业务弹窗必须：

```text
打开
↓
初始化数据
↓
用户输入
↓
校验
↓
提交中
↓
成功关闭
↓
刷新
```

失败：

```text
保留用户输入
```

不能失败以后直接清空。

---



# 十二、列表页面

必须支持合理的：

```text
加载状态
空数据
分页
查询
重置
刷新
错误
```

如果页面设计要求：

```text
查询条件保留
```

则页面刷新后按照设计恢复。

---



# 十三、页面缓存

需要缓存的页面使用项目统一的：

```text
KeepAlive
```

不要所有页面全部缓存。

尤其注意：

门店切换后不能继续使用旧门店缓存数据。

---



# 十四、权限

按钮使用项目统一权限机制。

例如：

```vue
v-permission="'customer:edit'"
```

如果项目实际采用其他方式，以现有项目为准。

禁止一个页面同时出现两套权限方案。

---



# 十五、代码质量要求

必须避免：

```text
重复 API
重复状态
重复业务判断
巨大组件
深层嵌套
魔法数字
魔法字符串
any
```

枚举必须集中管理。

---



# 十六、完成后的自检

必须执行：

```text
npm run type-check
npm run build
```

如果项目存在：

```text
npm run lint
```

也必须执行。

---



# 十七、最终报告

必须输出：

```text
【页面代码生成完成】

页面：

新增文件：
1.
2.

修改文件：
1.
2.

组件：
1.
2.

API：
1.
2.

权限：
1.
2.

门店上下文：
是否涉及

业务规则：
1.
2.

类型检查：
PASS / FAIL

Build：
PASS / FAIL

Lint：
PASS / FAIL / 未配置

发现的问题：
1.

是否可以进入06：
YES / NO
```

---

