# rc0 UI 风格规范（Apple Liquid Glass）

> 版本：v1.0 · 基线：**RC0 Apple Liquid Glass Design System v2.0**
> 视觉参照：iOS 26 Liquid Glass、visionOS、Apple Music / Photos / Journal / TV
> 实现锚点：`lib/app/theme/`（token）+ `lib/shared/widgets/glass/`（组件）
> 关联：[UX_GUIDELINES.md](UX_GUIDELINES.md) · [PRODUCT_CONCEPT.md](PRODUCT_CONCEPT.md) · [../DESIGN_SYSTEM.md](../DESIGN_SYSTEM.md)

---

## 1. 风格总纲

### 1.1 Liquid Glass 的定义（非普通毛玻璃）

Apple Liquid Glass 是一种**动态光学材质**，不是"透明容器 + blur"。rc0 中的任何玻璃表面必须同时具备四个属性：

| 属性 | 含义 | rc0 实现 |
|---|---|---|
| **Lensing 透镜感** | 玻璃折射并放大背后内容，边缘有折射高光 | `LiquidGlassSurface` 顶部 sheen（`glassHighlightLight/Dark`） |
| **Adaptivity 自适应** | 材质随背后内容明暗自动调整（亮底变暗字、暗底变亮字） | 明暗双 token（`glassSurfaceLight` `0xB8FFFFFF` / `glassSurfaceDark` `0x661E1E1E`） |
| **Fluidity 流动性** | 交互时材质如水滴般融合、分离、回弹 | `AppMotion.liquidTab`（`Cubic(0.33, 1.2, 0.48, 1.0)` 水滴回弹曲线） |
| **Depth 纵深** | 玻璃浮在内容之上，有环境光影投射 | `AppShadows.floatingBarNav`（-4 spread 柔和投影） |

**禁止**将 Liquid Glass 简化为：静态半透明面板、单纯 `BackdropFilter`、不响应内容的固定色卡片。

### 1.2 三层空间层级（强制）

```text
Level 0 内容层   角色图 / 场景图 / 分镜 / 生成图 —— 占据全部主视觉，延伸至屏幕边缘
Level 1 玻璃层   导航 / Tab / 搜索 / 工具栏 —— 浮动玻璃，永不贴边
Level 2 交互层   Dialog / Sheet / 关键操作 —— 按需短暂出现，用完即散
```

深度关系（z-order）：内容(0) < 导航(1) < Dialog(2) < Sheet(3) < Critical(4)。工具层不得在视觉上压制内容层。

### 1.3 一票否决项

- 页面看起来像 Material 设置页 / 后台 Dashboard → 立即重构。
- 导航/Tab/搜索条贴屏幕边缘的实心条 → 禁止。
- 业务层直接写 `BackdropFilter` / `ImageFilter.blur` → 禁止，必须走 `LiquidGlassSurface` 或 `Glass*` 组件。
- 业务层硬编码 `Color(0x...)` / 数字间距 / 数字时长 → 禁止（唯一例外：`preset_cover.dart` 调色板数据表）。

---

## 2. 色彩规范

### 2.1 色彩哲学：UI 中性，颜色来自内容

Liquid Glass 界面本身是**无色的光学介质**。彩色来自 Level 0 的内容（剧照、生成图、角色图）；UI 只在三处使用彩色：

1. **CTA / 主操作**：`AppColors.accent`（`#6B4FE0` 紫）
2. **激活态 / 焦点态**：`accentDark`（`#5A3FD4`）、`glassNavIconSelectedLight/Dark`
3. **语义徽章**：`badgeHot`（`#FF8C42`）/ `badgeNew`（`#34C759`）/ `badgeTemplate`（`#4A90D9`）

### 2.2 核心 token（SSOT：`lib/app/theme/app_colors.dart`）

| 用途 | Light | Dark |
|---|---|---|
| 画布 | `background` `#FAFAFA` | `backgroundDark` `#121212` |
| 表面 | `surface` `#FFFFFF` | `surfaceDark` `#1E1E1E` |
| 主文字 | `textPrimary` `#1F1F1F` | `textPrimaryDark` `#F5F5F5` |
| 次文字 | `textSecondary` `#8A8A8A` | `textSecondaryDark` `#B0B0B0` |
| 玻璃面 | `glassSurfaceLight` `#B8FFFFFF` | `glassSurfaceDark` `#661E1E1E` |
| 玻璃边 | `glassBorderLight` `#40FFFFFF` | `glassBorderDark` `#1AFFFFFF` |
| 玻璃高光 | `glassHighlightLight` `#26FFFFFF` | `glassHighlightDark` `#0FFFFFFF` |

角色库等影视化场景使用暗色优先表面：`characterBackgroundDark` `#0F1115` / `characterCardDark` `#171A21`。

### 2.3 沉浸页遮罩

Hero 沉浸页统一使用三段式渐变 scrim，保证图上文字可读且不遮蔽内容：
`heroScrimTop`（透明）→ `heroScrimMid`（`0x33000000`）→ `heroScrimBottom`（`0x99000000`）。

---

## 3. 材质与玻璃组件

### 3.1 组件映射（统一入口 `lib/shared/widgets/glass/glass.dart`）

| 语义角色 | 组件 | Liquid Glass 要点 |
|---|---|---|
| 底层材质 | `LiquidGlassSurface` | `standard`（内容玻璃 sigma 24）/ `navigation`（导航玻璃 sigma 16） |
| 卡片 | `GlassCard` | 顶部 sheen 高光 + 可点击缩放反馈 |
| 按钮 | `GlassButton` | 胶囊；`filled` 主操作用 accent，次操作用玻璃 |
| 输入框 | `GlassTextField` | 无下划线，背景由玻璃提供 |
| 分段控件 | `GlassSegmentedControl` | 玻璃轨道 + 动画选中药丸 |
| 底部弹窗 | `GlassSheet` + `showGlassSheet` | grab handle + SafeArea |
| 对话框 | `GlassDialog` + `showGlassDialog` | Level 2，短暂出现 |
| 沉浸详情壳 | `GlassHeroPage` | Hero 图 + 渐变 scrim + 浮动信息卡 |
| 列表行 | `GlassListRow` | 设置/消息列表 |
| 搜索壳 | `GlassSearchScaffold` | 全局搜索页 |
| 空状态 | `GlassEmptyState` | 玻璃包裹的空态 |
| 顶部导航 | `Rc0AppBar` + `GlassAppBarBackground` | 浮动，radius 28 |
| 底部导航 | `AppBottomNavBar` | 浮动药丸，水滴指示器 |
| Tab | `FeedTabBar` | 液态胶囊 |

禁止业务层直接使用 `AppBar` / `BottomNavigationBar` / `Card` 等 Material 默认壳。

### 3.2 模糊参数

| 场景 | Sigma | Token |
|---|---|---|
| 内容玻璃（卡片/弹窗） | 24 | `AppDimensions.glassBlurSigma` |
| 导航玻璃（更通透） | 16 | `AppDimensions.glassNavBlurSigma` |

性能红线：同屏避免堆叠多层 blur；玻璃层必须复用共享组件，不新建独立 `BackdropFilter`。

---

## 4. 形状：连续曲率（Continuous Curvature）

Apple Liquid Glass 全面使用连续曲率圆角（squircle 感），rc0 规定：

| 元素 | 圆角 | Token |
|---|---|---|
| 顶部导航 | 28 | `topNavFloatingRadius` |
| 底部导航 / Tab | 32 | `bottomNavFloatingRadius` / `tabFloatingRadius` |
| 浮动工具条 | 28 | `floatingBarRadius` |
| 内容卡片 | 16–20 | `radiusLg` / `radiusXl` |
| 按钮 | Pill（全圆） | `GlassButton` 内建 |

**避免** 4/6/8 的小圆角——那是直角化的 Material 语感，与液态玻璃冲突。`radiusSm(8)`/`radiusMd(12)` 仅限内嵌小元素（缩略图、徽章）。

---

## 5. 排版

字阶（SSOT：`app_text_styles.dart`），中性色文字 + 内容主导，不使用彩色标题：

| 样式 | 字号/字重/行高 | 用途 |
|---|---|---|
| `display` | 28 / w700 / 1.25 | 页面主标题、Hero 标题 |
| `title` | 20 / w600 / 1.3 | 区块标题、卡片标题 |
| `body` | 16 / w400 / 1.5 | 正文 |
| `bodySecondary` | 14 / w400 / 1.45 | 次要说明 |
| `label` | 14 / w600 / 1.2 | 按钮、表单标签 |
| `caption` | 12 / w400 / 1.3 | 元数据、徽章、辅助说明 |

玻璃上的文字必须依赖 Adaptivity（明暗 token 切换）保证对比度，不允许为可读性给玻璃加实心底。

---

## 6. 布局与间距

- 间距阶梯：4 / 8 / 16 / 24 / 32（`spacingXs..Xl`），页面边距 `pagePadding = 20`。
- 浮动导航参数：顶部导航高 56、top margin 8、bottom margin 12；底部导航高 56、距底 16、水平边距 16。
- 底部浮动清空区：滚动内容底部预留 `floatingBottomClearance = 72`，防止被浮动导航遮挡。
- 平板/宽屏：底部导航居中收窄，`floatingBottomNavMaxWidth = 420`（编辑器 560）。
- 响应式断点（`Breakpoints`）：compact 600 / medium 840（侧栏壳切换）/ expanded 1024（桌面）。禁止 magic width。

---

## 7. 动效：液态过渡

### 7.1 时长与曲线（SSOT：`app_motion.dart`）

| Token | 值 | 用途 |
|---|---|---|
| `fast` | 150ms | Micro：按压反馈、图标切换 |
| `normal` | 250ms | Small：卡片进出、Tab 切换 |
| `slow` | 400ms | Medium：页面级过渡、面板展开 |
| `standard` | easeOutCubic | 默认进场/淡入 |
| `emphasized` | easeOutBack | 按压/缩放反馈 |
| `smooth` | easeInOut | 开关、交叉淡化 |
| `liquidTab` | Cubic(0.33, 1.2, 0.48, 1.0) | 水滴指示器回弹（轻微 overshoot） |

### 7.2 液态动效原则

- 一切状态切换 **Emerges / Dissolves**（浮现/消融），禁止瞬时跳变。
- 底部导航选中态是**水滴药丸**（`glassNavIndicator*` token + `liquidTab` 曲线）：药丸滑向新 tab 时轻微过冲回弹，模拟液体表面张力。
- 结构增删（编辑器大纲、列表项）用 `AnimatedSize` / `AnimatedSwitcher` 过渡。
- 允许 Fade / Scale / Slide / Blend；**禁止**激进 bounce / shake / overshoot（`liquidTab` 的轻微回弹是唯一例外）。
- 总时长不超过 400ms；玻璃材质变化（如导航从内容上滚过时）应连续响应滚动，而非离散切换。

---

## 8. 阴影与光

Liquid Glass 的投影是**环境光影**，不是 Material elevation：

| Token | 构成 | 用途 |
|---|---|---|
| `AppShadows.card` | soft 8/2 | 内容卡片 |
| `AppShadows.floatingBar` | ambient 20/8 + faint 6/2 | 浮动工具条 |
| `AppShadows.floatingBarNav` | navCast 24/10 spread -4 + navFaint 8/2 | 半透明浮动导航（更柔） |

高光（sheen）永远在玻璃**顶部边缘**，模拟环境光从上方入射：`glassHighlightLight/Dark`、导航用 `glassNavHighlightLight/Dark`。

---

## 9. 平台差异

- **移动**：底部浮动导航药丸 + 顶部浮动 AppBar；沉浸页 Hero 全屏延伸至状态栏后。
- **桌面（≥840）**：侧栏壳；macOS 窗口控件使用 `macWindowClose/Minimize/Zoom` token；标题栏高 40，mac 左侧预留 72。
- **暗色模式**：所有玻璃/文字/边框 token 有 `*Dark` 对应项，由 `ThemeModeNotifier` 全局切换；页面画布 `pageBackground` 保持浅色调例外需评审。

---

## 10. 自检清单（合入前必查）

1. 内容层是否先于导航层进入视野？
2. 所有玻璃是否走 `Glass*` / `LiquidGlassSurface`？
3. 圆角是否为 24/28/32/Pill 连续曲率？
4. 颜色/间距/圆角/阴影/时长是否全部使用 token？
5. 状态切换是否有 Emerges/Dissolves 动效？
6. 导航/Tab 是否浮动且不贴边？
7. 同屏 blur 层是否 ≤ 2？
8. 明暗两套模式下玻璃文字是否可读？
