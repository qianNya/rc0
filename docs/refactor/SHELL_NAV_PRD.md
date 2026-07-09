# Shell 导航优化 · 产品需求文档（PRD）

> 版本：v1.0 · 状态：实施中（2026-07-09 开工）  
> 范围：大屏 PC 左侧导航栏 + App 底部导航栏（Hub）  
> 关联：[UX_GUIDELINES.md](../design/UX_GUIDELINES.md) · [UI_STYLE_GUIDE.md](../design/UI_STYLE_GUIDE.md) · [PRODUCT_CONCEPT.md](../design/PRODUCT_CONCEPT.md) · [全栈 PRD](PRD.md)  
> 实现锚点：`AdaptiveShellPage` · `DesktopSidebar` · `AppBottomNavBar` · `ShellNavConfigStore`

---

## 1. 背景与问题

### 1.1 产品上下文

rc0 是视觉创作操作系统。Shell 主导航是用户进入「浏览 / 构建 / 调度」三种心智的第一入口。  
近期 `/discovery` 已合并为**单页模板市场**，但导航文案与结构仍停留在「发现 Wiki / 推荐 Tab」时代，双端体验割裂。

### 1.2 现状（代码级）

| 端 | 形态 | 默认入口 | 创作入口 |
|---|---|---|---|
| App（`< 840px`） | 浮动玻璃底栏 + 独立创作胶囊 | Wiki / 场景 / 资产 / 我的（可定制 1–5） | `ShellCreateGlassButton` → `/studio` |
| PC（`≥ 840px`） | 左侧静态侧栏（约 22 项 / 5 分区） | Wiki 首页、动作、场景、角色、资产、模板市场… | 侧栏「进入创作」 |

断点：`Breakpoints.medium = 840`（`useSidebarShell`）。

### 1.3 核心痛点

| 编号 | 痛点 | 证据 |
|---|---|---|
| N1 | **标签漂移** | UX 称「模板市场」；底栏默认「Wiki」；侧栏「Wiki 首页」；多处仍写「发现」 |
| N2 | **双端 IA 不对称且无单一真相源** | 移动用 `ShellNavConfigStore`；桌面硬编码 `desktopSidebarSections`；`collectShellNavEntries()` 未接入 |
| N3 | **PC 侧栏过载** | 5 区 ~22 项，含重复 `scene_library`、过时「探索与社区」分区，像后台 Dashboard |
| N4 | **目录脏数据** | `screenplay` 槽 `branchIndex: 5` 与资产冲突；`community` 与 `/discovery` 同页仍双入口 |
| N5 | **创作心智混排风险** | 原则要求创作与消费分离；PC 把「进入创作」埋在「我的内容」区，弱于 App 胶囊 |
| N6 | **发现合并后语义未闭环** | `/discovery` = 模板市场，但主导航心智仍叫 Wiki/发现，用户不知道「模板」在哪 |

### 1.4 目标

- **G1** 双端共享同一套 **L1 主入口心智**（名称、顺序、路由一致）。
- **G2** PC 侧栏从「功能清单」收成 **主入口 + 可展开二级**，符合 Liquid Glass「界面退后」。
- **G3** App 底栏保持精简浮动 Hub；创作继续独立胶囊。
- **G4** 消灭发现/模板/Wiki 标签漂移；废弃重复与错误 catalog 项。
- **G5** 单一导航注册源（catalog / FeatureModule），桌面与移动只做布局适配。

### 1.5 非目标

- 不改 Studio 编辑态（L4）全屏退场与 `EditorHubBottomBar` 行为。
- 不重做 go_router branch 数量（可保留 6 branch，仅收敛对外入口）。
- 不做完全自定义 PC 侧栏拖拽（本期仅统一结构；移动端保留 1–5 定制）。
- 不引入新的社区 Feed 产品（`/community` 继续重定向）。

---

## 2. 用户与心智

### 2.1 心智模式 → 导航职责

| 心智 | 用户意图 | Shell 应提供 |
|---|---|---|
| 浏览 | 找模板、看资产、逛图库 | L1 消费入口 + PC 二级展开 |
| 构建 | 写剧本、改分镜、AI 打样 | **独立创作入口**，不与消费 Tab 混排 |
| 调度 | 挑角色/场景/预设 | 多从 Studio / Picker 进入，不占满 L1 |

### 2.2 目标用户故事

1. **作为创作者（手机）**，我打开 App 立刻看到「模板 / 场景 / 资产 / 我的」，点创作胶囊进入 Studio，不被「Wiki」英文词困惑。
2. **作为创作者（PC）**，左侧先看到与手机一致的主入口；需要角色/预设/图库时在对应主入口下展开，而不是扫 20+ 行菜单。
3. **作为回流用户**，旧链接 `/community`、`/discovery?section=template` 仍进模板市场，且侧栏高亮正确。

---

## 3. 信息架构（目标）

### 3.1 统一 L1 主入口（双端同一套）

| 顺序 | ID | 对外标签 | 路由 / Branch | 心智一句话 |
|---|---|---|---|---|
| 1 | `templates` | **模板** | `/discovery`（branch 0） | 浏览可 Fork 的剧本模板 |
| 2 | `scenes` | **场景** | `/scenes`（branch 2） | 场景库与拍摄空间 |
| 3 | `assets` | **资产** | `/assets`（branch 5） | 角色 / 设备 / 可复用素材枢纽 |
| 4 | `profile` | **我的** | `/profile`（branch 3） | 作品、身份、设置入口 |
| — | `create` | **创作** | `/studio`（branch 1） | 独立构建入口（不计入消费 Tab） |

**强制规则：**

- 对外禁止再使用「发现」「Wiki」「Wiki 首页」作为 L1 标签。
- 「模板市场」可作为 PC 二级标题或页面内标题；L1 短标签统一为 **模板**。
- `/discovery?section=template` 与 `/discovery` 同页；侧栏 active 均映射 `templates`。

### 3.2 App 底部导航（Hub）

```
[ 模板 | 场景 | 资产 | 我的 ]     ( 创作 )
     ↑ AppBottomNavBar 浮动药丸      ↑ ShellCreateGlassButton
```

| 项 | 规范 |
|---|---|
| 默认槽位 | 模板、场景、资产、我的（4） |
| 可定制 | 仍 1–5；长按打开配置 Sheet |
| 创作 | 始终独立胶囊，不可钉进药丸内 |
| 视觉 | 图标为主；配置 Sheet 显示中文标签 |
| 编辑态 | Studio 编辑路由继续替换为 Editor Hub，隐藏创作胶囊 |

**Catalog 治理（本期）：**

- 重命名：`wiki` → `templates`（迁移 prefs 时做 id alias）。
- 删除或修复：`screenplay`（错误 branch）、与模板同页的冗余 `community` 钉选（改为 alias → `templates`，或从可钉列表移除）。
- 「图库 / 角色 / 预设 / 动作 / 收藏」可保留为**可钉选二级入口**，但默认不出现在底栏。

### 3.3 PC 左侧导航（优化结构）

从「五区功能墙」改为 **主入口列表 + 分组二级**：

```
┌─────────────────────┐
│  rc0                │
│                     │
│  ● 模板             │  ← L1（与 App 一致）
│  ○ 场景             │
│      我的场景       │  ← 仅在「场景」展开时显示
│      灯光 / 设备…   │
│  ○ 资产             │
│      角色 / 图库…   │
│  ○ 我的             │
│      作品 / 设置…   │
│                     │
│  [ 创作 ]           │  ← 底部强调 CTA（等同 App 胶囊）
└─────────────────────┘
```

#### 3.3.1 L1 行（始终可见）

与 §3.1 四项消费入口一致；当前路由所属主入口高亮。

#### 3.3.2 L2 分组（按主入口展开，默认折叠非当前）

| 主入口 | 允许的二级（建议集） | 说明 |
|---|---|---|
| 模板 | （无二级，或仅「搜索」快捷） | 单页模板市场，避免再拆「社区」 |
| 场景 | 场景库、我的场景、灯光、设备、摄影预设 | 原「摄影流程」收拢到场景心智下 |
| 资产 | 角色 Wiki、动作 Wiki、图库、收藏 | 原散落 Wiki/探索项收拢 |
| 我的 | 我的剧本、我的角色、个人资料、设置 | 分析/下载等进设置或 Labs，不占 L1 |

**删除 / 降级：**

- 重复的「场景库」双条目。
- 「IP 参考」若仍指向 `/discovery`，改为资产或独立详情，禁止与模板抢同一高亮。
- 「场景摄影流程」不再作为伪装的 Studio 入口；Studio 只走底部 **创作** CTA。
- 「数据分析 / 下载」移入设置或 Labs，默认不进侧栏主路径。

#### 3.3.3 创作 CTA（PC）

- 固定在侧栏底部（或标题区旁），视觉权重高于普通行（`GlassButton.filled` / accent）。
- 文案：**创作**（与 App tooltip 一致），不再用「进入创作」埋在列表中部。

### 3.4 响应式行为

| 宽度 | 壳 |
|---|---|
| `< 840` | 底栏 Hub + 创作胶囊 |
| `≥ 840` | 左侧栏（主入口 + 展开二级）+ 创作 CTA；**无**底栏 |

断点保持 840，不新增 magic width。

---

## 4. 交互与视觉要求

遵循 Liquid Glass / UX 清单：

1. 导航浮动于内容之上；PC 侧栏使用现有 `DesktopCard` / glass 材质，禁止实心后台菜单感。
2. L1 切换：`goBranch`，保留各 tab 滚动位置；L2 非 shell 路由：`push`（与现 `shellTabRoutes` 规则一致）。
3. 展开/折叠二级：`AnimatedSize` / fade，时长 ≤ `AppMotion.normal`。
4. 同屏 blur ≤ 2；侧栏与内容区不叠多层独立 blur。
5. 明暗双模式文字可读；激活态用 accent，不靠粗边框。

---

## 5. 技术约束（实现指引，非本 PRD 详设）

| 约束 | 说明 |
|---|---|
| 单一注册源 | 以 `ShellNavCatalog`（或 FeatureModule `collectShellNavEntries`）为 L1/L2 数据源；`desktopSidebarSections` 改为派生，禁止再维护第二套硬编码列表 |
| ID 迁移 | prefs `rc0_shell_nav_active`：`wiki` → `templates`；`community` 钉选映射到 `templates` |
| Active 映射 | 重写 `desktopSidebarActiveId`：`/discovery` → `templates`；去掉重复 `community` 分支 |
| 路由兼容 | `/community`、`/discovery?section=template` 行为不变 |
| 文档同步 | 落地后更新 `UX_GUIDELINES.md` §2.1 与本 PRD 状态 |

---

## 6. 范围与里程碑

### 6.1 本期（Must）

- [ ] 统一 L1 标签与顺序（模板 / 场景 / 资产 / 我的 + 创作）
- [ ] App 默认底栏改名与 catalog 清理（含 `screenplay` 修复/移除）
- [ ] PC 侧栏改为「L1 + 可展开 L2 + 底部创作 CTA」
- [ ] Active 高亮与深链兼容
- [ ] 更新 UX_GUIDELINES §2.1

### 6.2 下期（Should）

- [ ] FeatureModule 导航注册真正驱动双端壳
- [ ] 侧栏折叠为 icon-rail（窄屏桌面 840–1024）
- [ ] 底栏可选显示短标签（无障碍 / 设置项）

### 6.3 不做（Won't）

- 自定义拖拽排序 PC 侧栏
- 恢复「推荐 Feed」为 L1
- 把创作塞进底栏药丸

---

## 7. 验收标准

| # | 标准 |
|---|---|
| A1 | App 默认底栏四字：**模板、场景、资产、我的**；无「Wiki」「发现」 |
| A2 | 创作仅为独立胶囊（App）/ 侧栏底部 CTA（PC），不在消费 Tab 序列内 |
| A3 | PC 默认可见 ≤ 4 个 L1 + 1 创作；二级默认仅展开当前主入口 |
| A4 | 打开 `/discovery` 与 `/discovery?section=template`，L1「模板」高亮 |
| A5 | 钉选旧「模板/community」或迁移后的 `templates`，行为一致且不重复占两槽 |
| A6 | 无 `screenplay`→资产 的错误跳转 |
| A7 | `<840` 无侧栏；`≥840` 无底栏 |
| A8 | 视觉通过 Agent UI 清单：浮动、token、动效、非 Dashboard 感 |

---

## 8. 风险与开放问题

| 风险 | 缓解 |
|---|---|
| 老用户习惯「Wiki」 | 首次升级轻提示「Wiki 已更名为模板」；prefs 静默迁移 |
| 资产二级过多 | 严格按 §3.3.2 白名单；其余进页内 Tab |
| FeatureModule 未接线 | 本期先 Catalog 单一源；下期再接插件注册 |

**开放问题（评审时拍板）：**

1. 「动作 Wiki」挂在 **资产** 二级还是保留可钉选底栏项？——默认：**资产二级**。
2. PC 840–1024 是否要做 icon-rail？——默认：**下期**。

---

## 9. 成功指标（定性 + 可观测）

- 新用户 10 秒内能指出「去模板 / 去创作」两个入口（双端）。
- 导航相关文案「发现」「Wiki」在 L1 壳层出现次数 → **0**。
- PC 侧栏默认首屏可点击主入口数 ≤ 5（含创作）。
- 无新增导航相关 crash；深链回归用例全绿。

---

## 附录 A · 现状 → 目标对照

| 现状 | 目标 |
|---|---|
| 底栏「Wiki」 | 「模板」 |
| 侧栏「Wiki 首页」+「模板市场」双入口 | 单一 L1「模板」 |
| 侧栏「进入创作」埋在列表 | 底部强调「创作」CTA |
| 五区 ~22 项平铺 | L1 4 项 + 按需 L2 |
| `wiki` / `community` 两套 id | `templates` 统一 |
| `screenplay` → branch 5 | 移除或改正确路由 |

## 附录 B · 关键代码锚点

- `lib/features/shell/presentation/pages/adaptive_shell_page.dart`
- `lib/features/shell/presentation/widgets/desktop_sidebar.dart`
- `lib/shared/widgets/app_bottom_nav_bar.dart`
- `lib/core/services/shell_nav_config_store.dart`
- `lib/shared/widgets/shell_nav_items.dart`
- `lib/features/shell/presentation/utils/shell_nav_navigation.dart`
- `lib/app/router/app_router.dart`（branch 0–5）
- `lib/core/responsive/breakpoints.dart`（840）
