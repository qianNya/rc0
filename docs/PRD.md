# RC0 产品需求文档（PRD）

> 版本：1.2 · 2026-07-10  
> 适用范围：Flutter 客户端 `lib/features/*`  
> 关联文档：[DESIGN_SYSTEM.md](./DESIGN_SYSTEM.md) · [design/UI_STYLE_GUIDE.md](./design/UI_STYLE_GUIDE.md) · [PAGE_ROUTE_MAP.md](./PAGE_ROUTE_MAP.md) · [PAGE_ROUTE_AGENT_STRUCTURE.md](./PAGE_ROUTE_AGENT_STRUCTURE.md) · [APP_API_MATRIX.md](./APP_API_MATRIX.md) · [refactor/SCREENPLAY_TEMPLATE_PRD.md](./refactor/SCREENPLAY_TEMPLATE_PRD.md)

---

## 1. 产品概述

### 1.1 产品定位

**RC0** 是一款面向摄影参考与分镜创作的 **Liquid Glass 视觉工作室**。以 **剧本（Screenplay）四级结构** 为创作主干，围绕 **角色、场景、IP、影像技法、制片资产** 构建可复用 Wiki 资产库，在 Studio 中完成分镜编辑、拍摄参数配置与发布同步。

**一句话**：内容是世界本体，UI 仅为轻量浮层——帮助创作者管理姿势参考、分镜脚本与视觉资产。

### 1.2 目标用户

| 用户类型 | 需求 | 核心场景 |
|---------|------|---------|
| 摄影 / Cosplay 创作者 | 姿势参考、分镜规划、拍摄预设 | 浏览 Wiki → 创建剧本 → 编辑分镜 → 导出 |
| ACGN / 同人创作者 | 角色设定、场景氛围、作品 IP 管理 | 维护角色库 → 绑定到分镜 → 发布作品 |
| 半专业制片 | 设备组合、灯光方案、制片清单 | 管理器材预设 → 应用到 Frame → 团队协作（远期） |

### 1.3 平台与后端

- **客户端**：Flutter（iOS / Android / macOS / Windows / Linux / Web）
- **后端**：`rc0-rust` REST API（默认 `:8080`）
- **本地**：`SharedPreferences` + 文件系统（剧本草稿、封面、分镜图）
- **3D 预览**：Unity Runtime（动作 Wiki、打光 Wiki）

### 1.4 设计哲学（强制）

遵循 **RC0 Apple Liquid Glass Design System v2.0**：

1. **Content is the world** — 角色图、场景图、分镜图占据主视觉
2. **三层视觉层级** — Level 0 内容 / Level 1 玻璃导航 / Level 2 交互浮层
3. **Liquid Glass 非普通毛玻璃** — 必须响应背景、滚动、触摸、上下文
4. **所有 CRUD 页面禁止 Material 设置页风格** — 表单应浮于内容之上，而非实心列表堆砌

---

## 2. 信息架构

### 2.1 Shell 导航（可配置）

| 分支 | 路由 | 页面 | 职责 |
|-----|------|------|------|
| Wiki / 发现 | `/discovery` | `WikiHubPage` → `ExplorePage`（模板市场） | 模板市场 + IP + 角色 Tab |
| Studio | `/studio` | `ScriptStudioPage` | 创作工作台 |
| 场景 | `/scenes` | `SceneListPage` | 场景 Wiki 库 |
| 我的 | `/profile` | `ProfilePage` | 用户中心 |
| 动作 | `/action` | `ActionWikiPage` | 景别/运镜/机位 Wiki |
| 资产 | `/assets` | `AssetsHubPage` | 制片资产库 |

**系统 Stack**：`/inbox`（消息+任务）· `/labs`（未上线功能）· `/create/ai`（AI 目录）

**阅读深链**：`/script/:id` 及 scene/shot/export — 非列表，从模板市场/收藏/搜索进入。

**Legacy**：`/community` · `/wiki/script` · `/script`（无 id）redirect → `/discovery?section=template`；详见 [PAGE_ROUTE_MAP.md](./PAGE_ROUTE_MAP.md) · [refactor/SHELL_NAV_PRD.md](./refactor/SHELL_NAV_PRD.md)。

**独立创作胶囊**：`/studio/create` — 浮动玻璃按钮入口。

### 2.1.1 Wiki Hub 内嵌 Tab

| hubTab | 内容 |
|--------|------|
| 0 | `ExplorePage`（模板市场 `TemplateMarketBody`） |
| 1 | `WikiIpTab` |
| 2 | `CharacterListPage(embeddedInHub)` — 与 `/character` 共用 `CharacterLibraryBody` |

### 2.2 核心数据模型

```
Screenplay（剧本）
├── ScriptAct（幕）
│   └── ScriptScene（场次）
│       └── ScriptFrame（分镜/画格）
│           ├── imagePath / caption / actionNote / tags
│           ├── characterId（绑定角色 Wiki）
│           ├── shootParams（拍摄预设）
│           └── lighting / camera 参数（技法层）
```

**Wiki 资产（独立于剧本树，可复用绑定）**：

| 实体 | 说明 | 存储 |
|-----|------|------|
| `CharacterEntry` | 角色设定 | API + 本地封面 |
| `SceneEntry` | 场景/地点资产 | API + 地图坐标 |
| `IpEntry` | IP/作品 | API |
| `ShootPreset` | 拍摄参数预设 | API |
| `LightingScheme` | 灯光方案 | 内置 + 本地 |
| `CineCameraSetup` | 相机组合 | API |
| `UserAssetCategory` / `UserAssetItem` | 制片资产 | API |
| `GalleryImage` | 用户图库 | API |

---

## 3. CRUD 页面总览

> 本章是 **页面改造的主参考**。每个页面包含：路由、状态、字段、操作、UI 要求、验收标准。

### 状态图例

| 标记 | 含义 |
|-----|------|
| ✅ 已实现 | 功能完整，仅需体验优化 |
| 🔧 需改造 | 功能存在，UI/交互不符合 PRD |
| 🚧 占位 | 路由存在但功能未完成 |
| 📋 待建 | API 已有，UI 未接入 |

---

## 4. 角色 Wiki CRUD

### 4.1 角色列表 `character-wiki-list`

| 属性 | 值 |
|-----|---|
| 路由 | `/character` · Shell 内嵌于 Wiki Tab 2 |
| 页面 | `CharacterListPage` / `WikiCharacterLibraryTab` |
| Repository | `CharacterRepository` |
| 状态 | ✅ 已实现 · 🔧 体验可优化 |

**Read 能力**
- 分页列表、分类筛选（`CharacterCategoryChips`）
- 支持 `?work_id=` 查询参数 — 过滤某 IP 下角色
- 搜索（全局 `/search` 或页内）

**Create 入口**
- 浮动/顶栏「创建」→ `/character/create`
- AI 入口 → `/character/ai`

**UI 要求**
- 内容层：角色封面网格/卡片为主视觉
- 玻璃层：浮动 `CharacterWikiAppBar` + 分类 Chips
- Tab 切换使用 `FadeSlideTabSwitcher`
- 空态：`GlassEmptyState` + 引导创建

**验收标准**
- [ ] 封面占卡片面积 ≥ 70%
- [ ] 筛选/排序走 `showGlassSheet`
- [ ] 长按或更多菜单支持删除（若权限允许）
- [ ] `work_id` 模式下 AppBar 显示作品名

---

### 4.2 角色详情 `character-detail`

| 属性 | 值 |
|-----|---|
| 路由 | `/character/:id` |
| 页面 | `CharacterDetailPage` |
| 状态 | ✅ 已实现 |

**Read 字段展示**

| 字段 | 展示优先级 | 说明 |
|-----|-----------|------|
| `coverUrl` | P0 | Hero 主视觉 |
| `name` / `nameOrig` | P0 | 标题区 |
| `workTitle` | P1 | 所属作品链接 |
| `gender` | P2 | 标签 |
| `summary` | P0 | 简介 |
| `appearance` | P1 | 外貌设定 |
| `personality` | P1 | 性格 |
| `aliases` | P2 | 别名列表 |

**操作**
- 编辑 → `/character/:id/edit`
- 删除 → `CharacterRepository.delete()` + 确认 `GlassDialog`
- 用于剧本 → 返回 Studio 并绑定 `characterId`

**UI 要求**
- 使用 `GlassHeroPage` — 封面 Hero + 玻璃信息浮层
- 操作按钮浮于 Hero 底部，非 AppBar 实心条
- 删除/更多走 `showGlassSheet`

**验收标准**
- [ ] Hero 区域可下拉展开封面
- [ ] 关联作品可点击跳转 `/ip/:id`
- [ ] 从 Studio 进入时显示「选用此角色」主 CTA

---

### 4.3 角色创建 `character-create`

| 属性 | 值 |
|-----|---|
| 路由 | `/character/create` |
| 页面 | `CharacterCreatePage` |
| 状态 | ✅ 已实现 · 🔧 表单体验可优化 |

**Create 字段**

| 字段 | 必填 | 组件 | 校验 |
|-----|------|------|------|
| `name` | ✅ | `GlassTextField` | 非空，≤ 64 字 |
| `nameOrig` | — | `GlassTextField` | ≤ 64 字 |
| `workId` | — | IP Picker Sheet | 可选 |
| `gender` | — | `GlassSegmentedControl` | 男/女/其他/未知 |
| `summary` | — | `GlassTextField` multiline | ≤ 500 字 |
| `appearance` | — | `GlassTextField` multiline | ≤ 1000 字 |
| `personality` | — | `GlassTextField` multiline | ≤ 1000 字 |
| `aliases` | — | Tag 输入 | 逗号分隔 |
| `cover` | — | 图片选择器 | 本地暂存后上传 |

**操作**
- 保存 → `CharacterRepository.create()` → 跳转详情
- 取消 → `pop` 或确认丢弃

**UI 要求**
- 非 `ListView` 实心表单 — 分段玻璃卡片浮于渐变/模糊背景
- 封面选择区在顶部，占视觉 40%
- 保存按钮固定底部浮动 `GlassButton`

**验收标准**
- [ ] 所有输入使用 `GlassTextField`
- [ ] 保存中显示 `GlassProgressSheet`
- [ ] 支持从 AI 页预填 `summary`（`?summary=` 或 `extra`）
- [ ] 错误提示走全局 SnackBar 反馈样式

---

### 4.4 角色编辑 `character-edit`

| 属性 | 值 |
|-----|---|
| 路由 | `/character/:id/edit` |
| 页面 | `CharacterEditPage` |
| 状态 | ✅ 已实现 |

**Update**：字段同创建页，预填现有数据。

**验收标准**
- [ ] 与创建页 UI 结构一致（共用 Form 组件）
- [ ] 封面可替换/删除
- [ ] 保存后 `pop` 并刷新详情

---

### 4.5 我的角色 `my-characters`

| 属性 | 值 |
|-----|---|
| 路由 | `/my-characters` |
| 页面 | `MyCharactersPage` |
| 状态 | ✅ 已实现 |

**Read**：仅当前用户创建的角色，支持 CRUD 快捷入口。

**验收标准**
- [ ] 与 Wiki 列表视觉一致，增加「我的」标识
- [ ] 空态引导创建

---

### 4.6 角色 AI `character-ai`

| 属性 | 值 |
|-----|---|
| 路由 | `/character/ai` |
| 状态 | 🚧 Mock 生成 |

**目标能力**
- 输入：角色名 / 作品名 / 风格关键词
- 输出：预填 `summary` + `appearance` + `personality`
- 沉淀：跳转 `/character/create` 并携带生成结果

**验收标准（远期）**
- [ ] 接入真实 AIGC API
- [ ] 生成过程在 `/tasks` 可追踪

---

## 5. 场景 Wiki CRUD

### 5.1 场景列表 `scene-wiki-list`

| 属性 | 值 |
|-----|---|
| 路由 | `/scenes`（Shell 分支） |
| 页面 | `SceneListPage` |
| Repository | `SceneRepository` |
| 状态 | ✅ 已实现 |

**Read**
- 列表 / 地图双视图（`SceneMapView`）
- 分类筛选、搜索
- Seed 数据 + 用户创建混合

**Create 入口**
- `/scenes/create` 或 Sheet `SceneCreateFormPanel`
- AI → `/scenes/ai`

**UI 要求**
- 地图模式：全屏内容层，玻璃控件浮于顶部
- 列表模式：场景封面卡片网格

**验收标准**
- [ ] 地图/列表切换有 `FadeSlideTabSwitcher` 动画
- [ ] 筛选走 `showGlassSheet`
- [ ] 创建支持 Sheet 与全页两种入口

---

### 5.2 场景详情 `scene-detail`

| 属性 | 值 |
|-----|---|
| 路由 | `/scenes/:id` |
| 页面 | `SceneDetailPage` |
| 状态 | ✅ 已实现 |

**Read 字段**

| 字段 | 优先级 | 说明 |
|-----|--------|------|
| `coverUrl` / `imageUrls` | P0 | 图集 Hero |
| `title` | P0 | 标题 |
| `description` | P0 | 描述 |
| `category` | P1 | 分类标签 |
| `tags` / `themes` | P1 | 标签云 |
| `latitude` / `longitude` | P1 | 地图标注 |
| `shootingTips` | P2 | 拍摄建议 |
| 统计（浏览/收藏） | P2 | 社交数据 |

**操作**
- 编辑 → `/scenes/:id/edit`
- 删除 → 确认后 `SceneRepository.delete()`
- 用于剧本 → 绑定到 Studio 场次

**验收标准**
- [ ] 地图区域可交互（`flutter_map`）
- [ ] 多图支持横向滑动预览
- [ ] Tab 分段：概览 / 图片 / 地图 / 拍摄建议

---

### 5.3 场景创建 `scene-create`

| 属性 | 值 |
|-----|---|
| 路由 | `/scenes/create` |
| 页面 | `SceneCreatePage` / `SceneCreateFormPanel` |
| 状态 | ✅ 已实现 |

**Create 字段**

| 字段 | 必填 | 组件 |
|-----|------|------|
| `title` | ✅ | `GlassTextField` |
| `description` | — | multiline |
| `category` | — | Picker |
| `tags` | — | Tag 输入 |
| `themes` | — | Tag 输入 |
| `imageUrls` | — | 多图选择 |
| `latitude` / `longitude` | — | `SceneLocationPicker` 地图选点 |
| `shootingTips` | — | multiline |

**验收标准**
- [ ] 地图选点交互流畅（`geolocator` 权限处理）
- [ ] 多图上传进度可见
- [ ] Sheet 与全页表单字段一致

---

### 5.4 场景编辑 `scene-edit`

| 属性 | 值 |
|-----|---|
| 路由 | `/scenes/:id/edit` |
| 页面 | `SceneEditPage` |
| 状态 | ✅ 已实现 |

**Update**：字段同创建，预填 + 增量图片管理。

---

### 5.5 我的场景 `my-scenes`

| 属性 | 值 |
|-----|---|
| 路由 | `/my-scenes` |
| 页面 | `MyScenesPage` |
| 状态 | ✅ 已实现 |

---

## 6. IP / 作品 CRUD

### 6.1 IP 列表（Wiki Tab）

| 属性 | 值 |
|-----|---|
| 入口 | Wiki Hub Tab 1 · `WikiIpTab` |
| Repository | `IpRepository` |
| 状态 | ✅ 已实现 |

**Read**：分页列表，支持搜索。

**Create**：`/ip/create` → `IpEditPage`（create 模式）

---

### 6.2 IP 详情 `ip-detail`

| 属性 | 值 |
|-----|---|
| 路由 | `/ip/:id` |
| 页面 | `IpDetailPage` |
| 状态 | ✅ 已实现 |

**Read 字段**：`title`, `workType`, `releaseYear`, `summary`, 关联角色列表

**操作**
- 编辑 → `/ip/:id/edit`
- 删除 → `IpRepository.delete()`
- 查看角色 → `/character?work_id=:id`

---

### 6.3 IP 创建/编辑 `ip-edit`

| 属性 | 值 |
|-----|---|
| 路由 | `/ip/create` · `/ip/:id/edit` |
| 页面 | `IpEditPage` |
| 状态 | ✅ 已实现 · 🔧 合并 create/edit 模式 |

**字段**

| 字段 | 必填 | 说明 |
|-----|------|------|
| `title` | ✅ | 作品名 |
| `workType` | — | 动画/漫画/游戏/原创等 |
| `releaseYear` | — | 年份 |
| `summary` | — | 简介 |

**验收标准**
- [ ] Create/Edit 共用同一 Form，减少重复代码
- [ ] 保存后跳转详情
- [ ] 删除仅 Edit 模式可见

---

## 7. 剧本 CRUD（创作主干）

### 7.1 剧本列表

| 入口 | 页面 | 数据源 |
|-----|------|--------|
| 模板市场（Shell L1） | `ExplorePage` → `TemplateMarketBody` · `/discovery` | `TemplateMarketRepository`（`GET /feed?kind=2`） |
| 我的作品 | `ProfileWorksPage` | 用户发布 / 本地草稿 |
| Legacy 深链 | `/community` · `/wiki/script` · `/script` | redirect → `/discovery?section=template` |

> 数据定义（`kind=2`、Fork 血缘、发布为模板）以 [refactor/SCREENPLAY_TEMPLATE_PRD.md](./refactor/SCREENPLAY_TEMPLATE_PRD.md) 为 SSOT。  
> UI 统一改造见 **§16 模板全链路 UI 统一**。

**本地 CRUD**（`ScreenplayLocalRepository`）
- Create：`publish(draft)`
- Read：`list()` / `getById()`
- Update：`update()` / `updateDocument()` / 树节点 mutation
- Delete：`delete()` / `deleteScreenplay()` / `deleteAct/Scene/Frame()`

**远程 CRUD**（`ScreenplayRemoteRepository` + `ScreenplayPublishService`）
- 发布、同步树、可见性切换、远程删除

---

### 7.2 剧本创建 `studio-create`

| 属性 | 值 |
|-----|---|
| 路由 | `/studio/create` · `/studio-editor/create` |
| 页面 | `ScriptStudioCreatePage` |
| 状态 | ✅ 已实现 |

**Create 流程**
1. 输入标题 / 简介 / 标签
2. 选择结构模板（可选）
3. 进入编辑器 Host

**UI 要求**
- 三 Tab：大纲 / 时间线 / 分镜板
- 内容编辑区占主视觉，工具栏浮动

---

### 7.3 剧本编辑 `studio-edit`

| 属性 | 值 |
|-----|---|
| 路由 | `/studio?edit=:id` |
| 页面 | `ScriptStudioPage` + `ScreenplayEditorHost` |
| 状态 | ✅ 已实现 · 🔧 大文件待拆分 |

**树结构 CRUD**

| 节点 | Create | Update | Delete | Reorder |
|-----|--------|--------|--------|---------|
| Act | ✅ | ✅ title/synopsis | ✅ | ✅ |
| Scene | ✅ | ✅ 全字段 | ✅ | ✅ |
| Frame | ✅ | ✅ 图/标注/参数 | ✅ | ✅ |

**子页面**

| 页面 | 路由 | 职责 |
|-----|------|------|
| 场景编辑 | `/studio/edit/:scriptId/scene/:sceneId` | 场次元数据 + 分镜列表 |
| 分镜编辑 | `.../frame/:frameId` | 图片/动作/拍摄参数 |
| 项目设置 | `.../settings` | 标题/可见性/标签 |

**验收标准**
- [ ] 拖拽排序有动画反馈
- [ ] 删除走 `GlassDialog` 确认
- [ ] 发布/同步进度用 `GlassProgressSheet`
- [ ] 自动保存本地草稿

---

### 7.4 剧本详情（阅读态）`screenplay-detail`

| 属性 | 值 |
|-----|---|
| 路由 | `/script/:id` |
| 页面 | `ScreenplayDetailPage` |
| 状态 | ✅ 已实现 |

**Read**：Act → Scene → Frame 结构树、封面、社交数据

**操作**
- 收藏 / 点赞
- 编辑（自己的）→ Studio
- Fork / 翻拍（他人模板）→ 本地副本 → Studio
- 导出 → `/script/:id/export`
- 阅读场景 → `/script/:id/scene/:sid` 🚧
- 阅读分镜 → `.../shot/:kid` 🚧

**UI 要求（与 §16 对齐）**
- 沉浸壳走 `GlassHeroPage`；Fork CTA 统一 `GlassButton filled`
- 「翻拍自」血缘链可跳转源模板
- 加载态骨架 / 空错态 `GlassEmptyState`

---

### 7.5 Discovery Feed 页面 `discovery`（UI）

| 属性 | 值 |
|-----|---|
| 路由 | `/discovery` · `/discovery?section=template` |
| 页面 | `ExplorePage` → `TemplateMarketBody` |
| 状态 | ✅ v2 Feed 布局已落地（见设计 SSOT） |
| 数据 | `TemplateMarketRepository` · `GET /feed?kind=2` · `GET /templates/featured` |

**视觉设计 SSOT**：[design/TEMPLATE_MARKET_UI_PRD.md](./design/TEMPLATE_MARKET_UI_PRD.md) v2（顶 Tab → 分类芯片 → 搜索+发布 → 双列 Feed 卡）

**页面结构（v2）**

| 层级 | 元素 | 规范 |
|-----|------|------|
| Level 0 | 双列 `GlassFeedCard`（时长 / 查看创作过程 / @作者 / 标题 / ☆） | 内容主导；无 Hero 主路径 |
| Level 1 | 顶 Tab（编辑精选/关注/热门推荐/最新发布）、分类芯片、搜索+发布、底栏 | 玻璃层；`FeedTabBar` + `GlassButton` |
| Level 2 | 筛选/更多 Sheet | `showGlassSheet` |

**API Tab 映射**
- 热门推荐 → `sort=hot`；最新发布 → `sort=latest`
- 关注 → `sort=recommend` + JWT（未登录空态）
- 编辑精选 → `GET /templates/featured`（空则降级 hot）

**验收标准**
- [ ] 对照 [TEMPLATE_MARKET_UI_PRD.md](./design/TEMPLATE_MARKET_UI_PRD.md) v2 合入前勾选清单
- [ ] 卡片字段对齐设计稿；点击进 `/script/:id`
- [ ] 明暗双模式玻璃文字可读；同屏 blur ≤ 2

---

## 8. 拍摄预设 CRUD

### 8.1 预设选择/管理 `preset-picker`

| 属性 | 值 |
|-----|---|
| 路由 | `/preset` · Frame Editor 内嵌 |
| 页面 | `ShootPresetPickerPage` · `PresetDetailPage` |
| Repository | `ShootPresetRepository` |
| 状态 | ✅ 已实现 |

**字段**：`label`, `ShootParams`（设备/画幅/灯光）, `scope`（官方/社区/个人）, 封面, 社交统计

**CRUD**
- Create/Update：`shoot_preset_edit_sheet`
- Delete：管理模式下
- Read：分类 Tab（官方 / 社区 / 我的）

**验收标准**
- [ ] 从 Frame Editor 进入时为「选择模式」，隐藏删除
- [ ] 编辑 Sheet 表单字段完整
- [ ] 详情页展示参数可视化

---

## 9. 灯光方案 CRUD

### 9.1 灯光 Wiki `lighting-wiki`

| 属性 | 值 |
|-----|---|
| 路由 | `/lighting` |
| 页面 | `LightingWikiPage` |
| Repository | `LightingRepository` |
| 状态 | ✅ 本地 CRUD · 无云端同步 |

**字段**：`title`, `category`, `lights[]`, `tags`, 关联角色/场景, `favorite`

**CRUD**
- 内置预设：只读
- 用户方案：`saveUserScheme()` / `deleteUserScheme()`
- 编辑器：`LightingEditorController`

**UI 要求**
- Unity 3D 预览占内容层
- 参数面板浮动玻璃层

**验收标准**
- [ ] 浏览/应用模式（从 Frame Editor 带 query params）
- [ ] 收藏切换即时反馈
- [ ] 远期：云端同步 API

---

## 10. 摄影器材 CRUD

### 10.1 器材 Wiki `camera-wiki`

| 属性 | 值 |
|-----|---|
| 路由 | `/equipment` · `/equipment/:kind/:id` |
| 页面 | `EquipmentHubPage` · `EquipmentDetailPage` |
| Repository | `EquipmentRepository` |
| 状态 | ✅ 已实现 |

**Catalog（只读）**：品牌、机身、镜头

**用户组合 CRUD**（`CineCameraSetup`）

| 字段 | 说明 |
|-----|------|
| `title` | 组合名 |
| `bodyId` | 机身 |
| `lensId` | 镜头 |
| `focalLengthMm` | 焦距 |
| `apertureF` | 光圈 |

**我的器材**：`/my-equipment` → `MyEquipmentPage`

**验收标准**
- [ ] 筛选 Chips 使用 `EquipmentGlassFilterChips`
- [ ] 创建/编辑走 Picker Sheet
- [ ] 收藏机身/镜头/组合

---

## 11. 制片资产 CRUD

### 11.1 资产中心 `assets-hub`

| 属性 | 值 |
|-----|---|
| 路由 | `/assets`（Shell 分支） |
| 页面 | `AssetsHubPage` → `WikiAssetsTab` |
| Repository | `AssetRepository` |
| 状态 | ✅ 已实现 · **CRUD 参考范例** |

### 11.2 分类 CRUD

| 字段 | 必填 | 说明 |
|-----|------|------|
| `label` | ✅ | 分类名 |
| `iconName` | — | 图标 |
| `sort` | — | 排序 |

**操作**：`AssetRepository` create/update/delete category  
**UI**：`asset_form_sheets.dart` — `showGlassSheet` 表单

### 11.3 资产项 CRUD

| 字段 | 必填 | 说明 |
|-----|------|------|
| `categoryId` | ✅ | 所属分类 |
| `name` | ✅ | 名称 |
| `brand` | — | 品牌 |
| `model` | — | 型号 |
| `notes` | — | 备注 |

**Tab**：内置库 / 我的

**验收标准（其他 CRUD 页面对标此模块）**
- [ ] 分类与条目分离管理
- [ ] 表单 Sheet 磨砂玻璃
- [ ] 空态 / 加载 / 错误三态完整
- [ ] API 同步失败有重试

---

## 12. 图库 CRUD

### 12.1 我的图库 `gallery-home`

| 属性 | 值 |
|-----|---|
| 路由 | `/library` |
| 页面 | `MyGalleryPage` |
| Repository | `ImageGalleryRepository` |
| 状态 | ✅ Read 为主 · 📋 Delete 待完善 |

**Read 字段**：`title`, `description`, URLs, `tags`

**操作**
- 查看详情 → `/image/:id`
- 视觉分析 → `/image/:id/analysis`
- 标签管理 → `ImageTagsRepository`
- 收藏 → `ImageFavoriteRepository`
- **删除** → 📋 待 UI

**关联（API 已有，UI 待建）**
- 图片 ↔ 角色：`/images/{id}/characters` 📋
- 图片 ↔ 场景：`/images/{id}/scenes` 📋
- 图片 ↔ IP：`IpRepository.linkToImage` ✅

**验收标准**
- [ ] 补充删除确认流程
- [ ] 详情页增加「关联角色/场景」入口
- [ ] 图片可追溯到剧本/分镜

---

## 13. 用户资料 CRUD

### 13.1 编辑资料 `profile-edit`

| 属性 | 值 |
|-----|---|
| 路由 | `/profile/edit` |
| 页面 | `EditProfilePage` |
| Repository | `AuthRepository` |
| 状态 | ✅ 已实现 |

**Update 字段**：头像、背景、昵称、简介等（API `PUT /users/me`）

**验收标准**
- [ ] 头像/背景上传进度
- [ ] 表单玻璃化
- [ ] 保存成功全局反馈

---

## 14. 占位 / 待建页面

| 页面 | 路由 | 当前状态 | 优先级 |
|-----|------|---------|--------|
| 消息中心 | `/messages` | 空列表占位 | P2 |
| 任务中心 | `/tasks` | 空态占位 | P2 |
| 场景阅读 | `/script/:id/scene/:sid` | Coming Soon | P1 |
| 分镜阅读 | `/script/:id/scene/:sid/shot/:kid` | Coming Soon | P1 |
| 图片关联角色/场景 | 详情页内 | API 待 UI | P1 |
| 角色/场景 AI | `/character/ai` `/scenes/ai` | Mock | P2 |
| 项目设置 | `/studio/edit/.../settings` | 部分在 Editor 内 | P1 |
| 分镜 Shell 槽 | Storyboard nav | Coming Soon | P3 |

---

## 15. 全局 UI 规范（CRUD 页面强制）

### 15.1 组件白名单

| 用途 | 必须使用 |
|-----|---------|
| 卡片容器 | `GlassCard` |
| Feed / 模板 / 作品网格卡 | `GlassFeedCard`（§16；抽取前禁止新增实心 Material Feed 卡） |
| 按钮 | `GlassButton` |
| 输入框 | `GlassTextField` |
| 分段控制 | `GlassSegmentedControl` |
| 底部菜单 | `showGlassSheet` |
| 对话框 | `showGlassDialog` / `GlassDialog` |
| 详情页 | `GlassHeroPage` |
| 搜索页 | `GlassSearchScaffold` |
| 空态 | `GlassEmptyState` |
| 列表骨架 | `FeedGridSkeleton` |
| 进度 | `GlassProgressSheet` |
| 顶栏 | `Rc0AppBar` / `WikiModeTagAppBar` |
| 底栏 | `AppBottomNavBar` |

### 15.2 Token 引用

| 类型 | 来源 |
|-----|------|
| 颜色 | `AppColors.*` |
| 间距/圆角 | `AppDimensions.*`（24/28/32/Pill） |
| 字体 | `AppTextStyles.*` |
| 阴影 | `AppShadows.*` |
| 动画 | `AppMotion.*`（150/250/350ms） |

### 15.3 页面三态

每个 CRUD 列表/详情页必须实现：

1. **加载态** — 列表首屏用 `FeedGridSkeleton`（或等价渐变骨架）；禁止用转圈遮罩挡内容
2. **空态** — `GlassEmptyState` + 引导 CTA
3. **错误态** — `GlassEmptyState` 或统一错误卡 + 重试按钮

分页「加载更多」可用轻量指示，但不得替换首屏骨架规范。

### 15.4 动效要求

- 页面进入/退出：`fade` / `slide` / `scale`
- Tab 内容切换：`FadeSlideTabSwitcher`
- 列表增删：`AnimatedList` 或等价过渡
- 禁止无动画的状态跳变

---

## 16. 模板全链路 UI 统一（Liquid Glass）

> 版本：1.0 · 2026-07-10  
> 范围：模板市场 → 详情 → Fork → Studio → 发布为模板 → 我的作品  
> 数据/血缘 SSOT：[refactor/SCREENPLAY_TEMPLATE_PRD.md](./refactor/SCREENPLAY_TEMPLATE_PRD.md)（本章只定 UI，不重复 `kind` / Fork 数据定义）  
> 视觉 SSOT：[design/UI_STYLE_GUIDE.md](./design/UI_STYLE_GUIDE.md) · [design/UX_GUIDELINES.md](./design/UX_GUIDELINES.md)

### 16.1 链路范围

```text
模板市场 /discovery
    → 剧本/模板详情 /script/:id
        → Fork 翻拍
            → Studio 编辑器 /studio
                → 发布为模板（可见性 Dialog / Progress Sheet）
                    → 我的作品 ProfileWorksPage
                        →（回流）模板市场
```

### 16.2 现状审计结论

| 环节 | 玻璃壳 | 卡片 | 三态 | 动效 | Token |
|-----|--------|------|------|------|-------|
| Discovery Feed | ✅ 顶Tab/搜索+发布 | ✅ `GlassFeedCard` overlay v2 | ✅ 骨架+GlassEmpty | ✅ Tab 切换 | ✅ |
| 剧本详情 | ✅ `GlassHeroPage` | ✅ 玻璃信息卡 | ✅ 骨架+GlassEmpty | ✅ 下拉刷新 | ⚠️ hero 高度固定 |
| 发布/可见性 | ✅ Glass 入口 | — | — | ✅ | ✅ |
| Studio 入口 | ✅ 浮动 AppBar + StudioGlassCard | ✅ | ✅ 最近空态 | ✅ | ✅ |
| 我的作品 | ✅ frosted AppBar | ✅ `GlassFeedCard` | ✅ 骨架 | ✅ | ✅ |
| 点赞/收藏 | ✅ `DesktopStackScaffold` | ✅ `GlassScreenplayRow` | ✅ 骨架+GlassEmpty | ✅ 下拉刷新 | ✅ |
| 角色/场景/图库/IP | ✅ 玻璃空态+CTA | — | ✅ 骨架+GlassEmpty | ✅ | ✅ |
| 登录/表单主按钮 | — | — | — | — | ✅ `GlassButton filled` |

**核心分裂点（已收敛）**

1. **卡片**：`TemplateGridCard` / `ExploreFeedGridCard` 已删除；全链路统一 `GlassFeedCard`。
2. **Fork CTA**：`FeedForkButton` 已委托 `GlassButton filled`；详情/模板列表统一玻璃 CTA。
3. **发布链路**：`showGlassDialog` / `showGlassSheet` / `showGlassProgressSheet` 已接入详情与 Studio。

**关键证据（代码锚点）**

| 组件 | 位置 |
|-----|------|
| `GlassFeedCard` SSOT | `lib/shared/widgets/glass_feed_card.dart` |
| `TemplateMarketHero` SSOT | `lib/shared/widgets/template_market_hero.dart` |
| `GlassScreenplayRow` | `lib/shared/widgets/glass_screenplay_row.dart` |
| 详情沉浸壳 | `screenplay_detail_page.dart` → `GlassHeroPage` |
| 发布玻璃入口 | `publish_visibility_dialog.dart`、`screenplay_visibility_sheet.dart` |

### 16.3 统一设计原则

1. **同一张卡**：全链路 Feed / 模板 / 作品网格共用 `GlassFeedCard`（图片主导 + 底部玻璃 caption + 浮层徽章）。
2. **同一个 Fork CTA**：一律 `GlassButton filled`；废弃业务层 `FeedForkButton` / 桌面 `PrimaryButton` 作为 Fork 主按钮。
3. **Level 2 一律玻璃入口**：`showGlassDialog` / `showGlassSheet` / `GlassProgressSheet`（组件已存在于 `lib/shared/widgets/glass/`）。
4. **列表三态**：首屏加载 `FeedGridSkeleton`；空/错 `GlassEmptyState`；禁止列表首屏转圈遮罩（见 UX_GUIDELINES）。
5. **Token 强制**：颜色 / 间距 / 圆角 / 时长禁止业务层硬编码；圆角优先 20/24/28/32/Pill。

### 16.4 共享组件需求（P0，先建再迁）

| 组件 | 职责 | 基线 / 替换对象 |
|-----|------|----------------|
| `GlassFeedCard` | 图片主导玻璃 Feed 卡；radius ≥ `radiusXl`(20)；底部玻璃 caption；热门/可见性徽章浮于图上 | 抽取 `_WorkLibraryCard` → `lib/shared/widgets/`；替换 `TemplateGridCard`、`ExploreFeedGridCard`、`profile_works_preview` |
| `GlassProgressSheet` | 发布/同步进度 | 已有实现；替换 `publish_visibility_dialog` / 详情页内原生 progress sheet |
| 统一玻璃 Chip | 分类 / 标签药丸 | 收敛 `_CategoryChipRow`、桌面 `ActionChip`、`TagChip` |
| `GlassListRow` | Sheet 内菜单行 | 替换详情「更多」、feed more 中的 `ListTile` |
| （可选）`GlassImageCaption` | 封面底部玻璃 caption / scrim | 合并 `ContentCardImageFooter`、`_CoverScrim`、overlay metric 多套实现 |

### 16.5 逐页改造需求

#### 16.5.1 模板市场 `/discovery`

| 项 | 要求 | 状态 |
|----|------|------|
| 网格卡 | `TemplateGridCard` → `GlassFeedCard` | ✅ |
| Hero / Banner | 实心 `FeaturedBanner` → `TemplateMarketHero` 全幅出血 | ✅ |
| 搜索 | `GlassTextField` / 玻璃搜索条 | ✅ |
| 分类 / 排序 | 浮动药丸 + `FeedTabBar` bareTrack | ✅ |
| 三态 | 骨架 / GlassEmpty / InlineError | ✅ |
| 桌面右栏 | 玻璃标签 + `GlassCard` + 玻璃创作区 | ✅ |

#### 16.5.2 剧本/模板详情 `/script/:id`

| 项 | 要求 | 状态 |
|----|------|------|
| 沉浸壳 | 移动端 `GlassHeroPage` + `heroScrim*` | ✅ |
| Fork CTA | 移动底栏与桌面主按钮 `GlassButton filled` | ✅ |
| 翻拍血缘 | 「翻拍自」可跳转源 | ✅ |
| 三态 | 加载骨架；错误 `GlassEmptyState` | ✅ |
| 更多菜单 | `showGlassSheet` + `GlassListRow` | ✅ |

#### 16.5.3 发布 / 可见性

| 项 | 要求 | 状态 |
|----|------|------|
| 发布选项 | `showGlassDialog` + `GlassSegmentedControl` + `GlassButton` | ✅ |
| 可见性 Sheet | `showGlassSheet` + `GlassListRow` | ✅ |
| 发布进度 | `showGlassProgressSheet` | ✅ |

#### 16.5.4 Studio 入口 `/studio`

| 项 | 要求 | 状态 |
|----|------|------|
| 行动卡 | 保持 `StudioGlassCard` | ✅ |
| 最近项目空态 | `GlassEmptyState` | ✅ |
| 更多菜单 | `showGlassSheet` 替代 `PopupMenuButton` | ✅ |

#### 16.5.5 我的作品

| 项 | 要求 | 状态 |
|----|------|------|
| 网格卡 | `GlassFeedCard` library 变体 | ✅ |
| 预览区 | `profile_works_preview` → `GlassFeedCard` | ✅ |
| 首屏加载 | `FeedGridSkeleton` | ✅ |
| AppBar | `Rc0AppBar(frosted: true)` | ✅ |
| 徽章 / scrim | `AppColors.heroScrim*` token | ✅ |

### 16.6 三态与动效验收

对照 §15 与 UI_STYLE_GUIDE 自检清单，全链路每页必须：

```
[ ] 内容层先于导航进入视野
[ ] 导航/Tab/搜索浮动，非贴边实心条
[ ] 卡片为 GlassFeedCard（或白名单 Glass*）
[ ] Fork / 主 CTA 为 GlassButton
[ ] Level 2 仅 showGlassDialog / showGlassSheet / GlassProgressSheet
[ ] 首屏加载 FeedGridSkeleton；空/错 GlassEmptyState
[ ] 颜色/间距/圆角/时长全部 Token
[ ] Tab/筛选切换有 FadeSlide 或等价过渡
[ ] 同屏 blur ≤ 2；明暗双模式可读
[ ] flutter analyze 0 error（改造涉及文件）
```

### 16.7 优先级路线

| 阶段 | 内容 | 影响面 |
|-----|------|--------|
| **P0** | 抽取 `GlassFeedCard`；模板市场 + 我的作品预览接入 | 全链路视觉一致性 |
| **P1** | 详情迁 `GlassHeroPage`；Fork CTA 统一；血缘链合并 | 阅读/翻拍体验 |
| **P2** | 发布链路：`showGlassDialog` + `showGlassSheet` + `GlassProgressSheet` | Level 2 合规 |
| **P3** | 桌面右栏玻璃化、Studio 菜单、FeaturedBanner→Hero、token 清理 | 打磨 |

### 16.8 非目标

- 不新增独立 `/template` 路由；模板市场保持 `/discovery`（及 `?section=template` 深链兼容）。
- 不在本章重定义 `kind` / Fork API；见 SCREENPLAY_TEMPLATE_PRD。
- 不强制一次改完编辑器内部大纲/时间线（仅 Studio 入口壳与发布出口）。

---

## 17. CRUD 改造优先级与路线图

### Phase 1 — 体验统一（当前建议）

> 目标：所有 CRUD 页面达到「制片资产」模块的体验水准。  
> 模板飞轮（市场→详情→Fork→发布→作品）另见 **§16**，与下表并行。

| 优先级 | 页面 | 改造项 |
|--------|------|--------|
| P0 | `CharacterCreatePage` / `CharacterEditPage` | 表单玻璃化、封面 Hero、共用 Form 组件 |
| P0 | `SceneCreatePage` / `SceneEditPage` | Sheet/全页统一、地图选点优化 |
| P0 | `IpEditPage` | Create/Edit 合并、字段校验 |
| P0 | 模板全链路（§16） | `GlassFeedCard` 抽取与市场/作品接入 |
| P1 | `CharacterDetailPage` / `SceneDetailPage` | Hero 布局、关联跳转 |
| P1 | `MyGalleryPage` | 补充删除、图片关联入口 |
| P1 | 列表页空态/错误态 | 全量审计三态 |
| P1 | 剧本详情 / 发布链路（§16） | `GlassHeroPage`、Glass 发布入口 |

### Phase 2 — 能力补全

| 优先级 | 功能 | 说明 |
|--------|------|------|
| P1 | 图片 ↔ 角色/场景关联 UI | API 已就绪 |
| P1 | 剧本场景/分镜阅读页 | 替代 Coming Soon |
| P2 | 灯光方案云端同步 | 新 API |
| P2 | AI 生成接入 | 角色/场景/分镜 |
| P2 | 消息/任务中心 | 后端 + UI |

### Phase 3 — 架构优化

- 大文件拆分：`screenplay_detail_page`、`screenplay_editor_host`
- 抽取共用 `CrudFormScaffold` 减少 Create/Edit 重复
- 统一 `Repository` 错误处理与重试策略
- 桌面 `DesktopCard` / 右栏与模板市场辅助面板玻璃化（§16 P3）

---

## 18. CRUD 页面改造检查清单

每个页面改造完成后，逐项勾选：

```
[ ] 内容层占主视觉 ≥ 60%
[ ] 导航/操作浮于玻璃层，非贴边实心条
[ ] 圆角使用 24/28/32/Pill（内容卡可用 radiusXl=20）
[ ] 全部组件来自 Glass* 白名单（Feed 卡用 GlassFeedCard）
[ ] 颜色/间距/动画使用 Token
[ ] 空/加载/错误三态完整（列表首屏用骨架）
[ ] 创建/编辑/删除有确认与反馈
[ ] 列表变更有过渡动画
[ ] 数据经 Repository，UI 不直连 HTTP
[ ] flutter analyze 0 error
```

---

## 19. 附录

### A. 路由速查

详见 [PAGE_ROUTE_AGENT_STRUCTURE.md](./PAGE_ROUTE_AGENT_STRUCTURE.md)

### B. API 覆盖

详见 [APP_API_MATRIX.md](./APP_API_MATRIX.md)

### C. 设计系统

详见 [DESIGN_SYSTEM.md](./DESIGN_SYSTEM.md) · [design/UI_STYLE_GUIDE.md](./design/UI_STYLE_GUIDE.md)

### D. 代码位置速查

| 实体 | Feature 目录 | Repository |
|-----|-------------|------------|
| 角色 | `lib/features/character/` | `CharacterRepository` |
| 场景 | `lib/features/scene/` | `SceneRepository` |
| IP | `lib/features/ip/` | `IpRepository` |
| 剧本 / 模板市场 | `lib/features/screenplay/` `explore/` `studio/` | `ScreenplayLocalRepository` · `TemplateMarketRepository` |
| 预设 | `lib/features/screenplay/` | `ShootPresetRepository` |
| 灯光 | `lib/features/lighting/` | `LightingRepository` |
| 器材 | `lib/features/cine_equipment/` | `EquipmentRepository` |
| 制片资产 | `lib/features/production_assets/` | `AssetRepository` |
| 图库 | `lib/features/gallery/` | `ImageGalleryRepository` |
| 用户 | `lib/features/auth/` `profile/` | `AuthRepository` |

### E. 模板相关文档

| 文档 | 职责 |
|-----|------|
| 本章 §7.5 · §16 | 模板市场页面与全链路 **UI** 统一 |
| [refactor/SCREENPLAY_TEMPLATE_PRD.md](./refactor/SCREENPLAY_TEMPLATE_PRD.md) | 模板 **数据定义**、Fork、发布为模板 API |
| [refactor/SHELL_NAV_PRD.md](./refactor/SHELL_NAV_PRD.md) | Shell 导航与 `/discovery` 入口 |

---

*本文档随产品迭代更新。改造 CRUD 页面时，以本章第 4–13 节字段与验收标准为 SSOT，以第 15 节 UI 规范为约束，以第 16 节模板全链路与第 17 节优先级排期。*
