# Discovery Feed · 视觉设计 PRD（v2）

> 版本：2.0 · 2026-07-10 · 状态：**已实现**  
> 设计稿：`image-e6f4721f-b754-42e6-bb75-a0906021f4fa.png`（TapNow 风格社区 Feed）  
> 路由：`/discovery` · `/discovery?section=template`  
> 实现入口：`ExplorePage` → `TemplateMarketBody`

**关联文档**

| 文档 | 职责 |
|------|------|
| [UI_STYLE_GUIDE.md](./UI_STYLE_GUIDE.md) | Liquid Glass 视觉/token/组件白名单 |
| [UX_GUIDELINES.md](./UX_GUIDELINES.md) | 三态、动效、首屏加载规范 |
| [PRODUCT_CONCEPT.md](./PRODUCT_CONCEPT.md) | 内容是世界、Fork 飞轮 |
| [../PRD.md](../PRD.md) §7.5 · §16 | 产品需求与全链路 UI 统一 |
| [../refactor/SCREENPLAY_TEMPLATE_PRD.md](../refactor/SCREENPLAY_TEMPLATE_PRD.md) | 模板 `kind=2`、Fork；列表源契约 |

**产品心智（一句话）**  
封面剧照占据主视觉；顶 Tab / 分类 / 搜索 / 发布为浮动玻璃层；卡片展示时长、作者、标题与收藏星标，点击进入剧本详情（创作过程入口）。

**相对 v1 变更**  
去掉全幅 Hero 主路径；排序 Tab 改为 Feed 流 Tab（编辑精选 / 关注 / 热门推荐 / 最新发布）；搜索旁增加「发布作品」；`GlassFeedCard` overlay 对齐设计稿字段。

---

## 1. 页面结构（自上而下）

```text
┌─────────────────────────────────────┐
│ 编辑精选  关注  热门推荐  最新发布     │  Level 1 顶 Tab（下划线选中）
│ (精选画布) 人像 风景 …               │  Level 1 分类芯片
│ ┌──────────────┐ ┌────────────┐    │
│ │🔍 搜索…       │ │＋发布作品  │    │  Level 1 搜索 + CTA
│ └──────────────┘ └────────────┘    │
│ ┌──────────┐ ┌──────────┐          │
│ │10:26  查看创作过程│ │ … │          │  Level 0 双列卡
│ │@author           │ │    │          │
│ │标题…        ☆67  │ │    │          │
│ └──────────┘ └──────────┘          │
│         ╭─────────────────╮         │
│         │  浮动底栏        │         │  Level 1 Shell
│         ╰─────────────────╯         │
└─────────────────────────────────────┘
```

桌面：同一节奏；宽屏可保留 `ExploreDesktopRightPanel` 辅助，不挡主 Feed。

### 1.1 顶 Tab（浮动顶栏）

| 属性 | 规格 |
|------|------|
| 位置 | **WikiHub 浮动顶栏**（`DiscoveryHubAppBar`），不在内容流滚动区内 |
| 文案 | `编辑精选` · `关注` · `热门推荐` · `最新发布` |
| 选中 | 白字 + 底部短下划线（`FeedTabBar` underline / bareTrack） |
| 内容区 | 顶栏以下直接接分类芯片 → 搜索/发布 → 双列 Grid（`topPadding` 适配状态栏+Tab 高度） |

### 1.2 分类芯片

| 属性 | 规格 |
|------|------|
| 选项 | `AppCatalog.communityCategoryChips`（可微调文案） |
| 选中 | 半透明玻璃高亮 / accent 填充 |
| 未选 | 深色玻璃底 + 描边 |
| 行为 | 有 `tag_id` 走服务端；否则客户端标签过滤 |

### 1.3 搜索 + 发布

| 属性 | 规格 |
|------|------|
| 搜索 | 玻璃胶囊 `LiquidGlassSurface` / `GlassTextField`；placeholder「搜索模板…」；提交带 `q` |
| 发布 | 实心/高对比 `GlassButton filled`「发布作品」→ `/studio`；未登录 → 登录引导 |
| 布局 | 同行：搜索 `Expanded` + 发布固定宽 |

### 1.4 Feed 卡（`GlassFeedCard` overlay）

| 元素 | 规格 |
|------|------|
| 容器 | 图片即卡；圆角 `radiusXl`；按压 scale |
| 左上 | `duration_sec` → `mm:ss` 弱玻璃 pill；无数据则隐藏 |
| 右上 | 「查看创作过程」弱玻璃 pill；点击同进 `/script/:id` |
| 底部 | `@author`（次级）+ 标题（1–2 行）+ `☆ favorite_count` |
| 精选角标 | `is_featured` 时可显示精选/热门徽章 |

禁止实心白/灰卡底、Material elevation。

---

## 2. Token

沿用 UI_STYLE_GUIDE：`glassSurface*`、`heroScrim*`、`radiusXl`、`tabFloatingRadius`、`AppMotion.*`。同屏 blur ≤ 2。

---

## 3. 三态

| 状态 | 组件 |
|------|------|
| 首屏加载 | `FeedGridSkeleton` |
| 空 | `GlassEmptyState`（关注未登录：「去登录」） |
| 错误 | `GlassEmptyState` / `InlineErrorBanner` + 重试 |
| 分页 | 尾部骨架条；禁止全屏转圈 |

---

## 4. API 映射

默认 `kind=2`（模板市场列表源）。

| Tab | API | 降级 |
|-----|-----|------|
| 热门推荐 | `GET /feed?kind=2&sort=hot` | — |
| 最新发布 | `GET /feed?kind=2&sort=latest` | — |
| 关注 | `GET /feed?kind=2&sort=recommend` + JWT | 未登录空态；后端为关注加权非纯关注流 |
| 编辑精选 | `GET /templates/featured` → 取集合详情模板；或 `sort=hot` + `is_featured` 过滤 | 集合空 → hot 列表 |

其它：

- 搜索：`q`；分类：`tag_id`（有则传）。
- DTO 补齐：`duration_sec`、`is_featured`、`featured_at`、`hot_score`、`published_at`。
- 「查看创作过程」无独立 API → 详情页。
- 星标计数：`favorite_count`。

**本轮不做**：纯关注流后端、创作过程时间线 API、恢复 `/community`。

---

## 5. 合入前勾选

```
[x] 顶 Tab 四项 + 真实 API / 降级
[x] 分类芯片 + 搜索/发布同行玻璃化
[x] 无 Hero 主路径；双列 GlassFeedCard 字段对齐设计稿
[x] duration / @author / ☆ / 查看创作过程
[x] 关注未登录空态；发布未登录引导
[x] 三态完整；analyze 0 error
```

---

## 6. 实现锚点

| 组件 | 路径 |
|------|------|
| Body | `lib/features/explore/presentation/widgets/template_market_body.dart` |
| Repo | `lib/features/explore/data/template_market_repository.dart` |
| Card | `lib/shared/widgets/glass_feed_card.dart` |
| Catalog | `lib/core/data/app_catalog.dart` → `discoveryFeedTabs` |
| Featured API | `lib/api/screenplay/` featured client |
| Mapper | `lib/features/screenplay/data/screenplay_api_mapper.dart` |

*v1 Hero 模板市场规格归档；以本文 v2 为 Discovery UI SSOT。*
