# UI 重构 / 代码治理 进度跟踪

关联计划：液态玻璃设计语言全量重构（Liquid Glass Refactor）。

## 指标基线 vs 现状

| 指标 | 基线 | 当前 | 目标 |
|---|---|---|---|
| presentation 文件数 | 162 | 153 | ~135 |
| presentation 行数 | ~32,014 | 31,113 | ~26,000 |
| shared/widgets 文件数 | 33 | 32（+glass/ 子目录 6 文件） | — |
| analyze 错误 | 0 | 0 | 0 |
| analyze 提示/警告 | 62 | 44 | 持续下降 |

## 阶段进度总览

| 阶段 | 状态 | 说明 |
|---|---|---|
| 0 设计系统强化 | 完成 | token 扩充 + 玻璃组件库 + 文档 |
| 1 路由/结构治理 | 完成（含决策） | 路由收口（编辑器内导航集中化）；深拆单体随阶段4-5重写 |
| 1.5 精简治理 | 完成 | 见下 |
| 2 全局外壳重绘 | 完成 | 外壳已玻璃化；mac 窗口色 token 化 |
| 应用级主题 | 完成 | `AppTheme` 新增 dialog/bottomSheet 圆角与表面；card 阴影 token 化（全 App 生效） |
| 3 Feed 域重绘 | 完成（主surface） | 共享 feed more-sheet → `showGlassSheet`；卡片收敛；explore 占位 token |
| 4 编辑器域重绘 | 完成（交互面玻璃化） | 全部动作/筛选/排序 sheet → glass；表单/进度 sheet 有意保留（见下）；大文件拆分留待运行期 QA |
| 5 详情域重绘 | 完成（交互面玻璃化） | scene/character 动作面板 + 结构树画格菜单 + 详情更多菜单 → glass |
| 6 账户域重绘 | 完成 | auth 表单 → 磨砂 GlassCard + accent 背景；profile 外观 sheet → glass；硬编码已清 |
| 7 硬编码审计 | 完成 | EdgeInsets.all 全量 token 化（lib 内 0 残留）；features 内 raw Color(0x) = 0（仅保留 preset_cover 调色板数据表） |

### 本轮新增（应用级 + 代表性玻璃化）
- `AppTheme`：新增 `dialogTheme`（圆角 radiusXl）、`bottomSheetTheme`（顶部 floatingBarRadius 圆角 + 透明 tint）、card 阴影改 `AppColors.shadowSoft`。
- `content_card_shared.dart` `showFeedMoreSheet` → `showGlassSheet`（全 Feed 通用）。
- `scene_action_sheet.dart` / `character_action_sheet.dart` → `showGlassSheet` 磨砂动作面板。

### 阶段 4/5/6 玻璃化（交互面，完成）
- `showGlassSheet` 增加 `padding` / `useRootNavigator` 透传与 `kGlassSheetMenuPadding`（列表菜单贴边）。
- 转为磨砂玻璃 sheet 的调用点：`studio_editor_add_sheet`、`editor_quick_action_row`、`editor_param_select_row`、`shoot_preset_picker_page`、`scene_frame_list_view`（筛选/排序）、`script_editor_left_panel`（场次菜单 + 分镜删除）、`screenplay_structure_tree`（画格菜单）、`screenplay_detail_page`（更多操作）、`profile_page`（外观设置）、`scene_list_page`（筛选）、`content_card_shared`（feed 更多）、`scene_action_sheet`、`character_action_sheet`。
- 账户域：`auth_page_scaffold` 表单改 `GlassCard` + accent 渐变背景（磨砂效果有了可模糊的背景）。
- **有意保留 `showModalBottomSheet`**（不玻璃化，需运行期 QA）：发布/导出进度 sheet（`publish_visibility_dialog`、`screenplay_editor_host`、`screenplay_detail_page` 进度）— 长任务期间不能半透明；键盘感知可滚动表单 sheet（`shoot_preset_edit_sheet`、`script_editor_batch_edit_sheet`、`screenplay_visibility_sheet`）；自定义滚动选择器（`scene_picker_sheet`、`character_picker_sheet`）。

### 阶段 7 硬编码审计（完成）
- `EdgeInsets.all(4/8/16/20/24/32)` → `AppDimensions.spacingXs/Sm/Md/pagePadding/Lg/Xl`，覆盖 features + shared 约 35 处（值等价，零视觉变化），lib 内 0 残留。
- 新增精确值阴影/遮罩 token：`AppColors.shadowStrong(0x1A)`、`shadowDrag(0x22)`、`scrimStrong(0xCC)`；替换 `scene_frame_stack_preview` / `upload_structure_drag` / `explore_featured_carousel` 中 raw `Color(0x..)`。
- features 内 raw `Color(0x` 归零（仅保留 `preset_cover.dart` 的封面渐变调色板，作为设计数据表有意保留）。
- `flutter analyze`：0 error，44 lint（与改造前一致，无新增）。

## 阶段 0 · 设计系统强化（完成）
- token 扩充：`app_colors.dart` 新增 glass 高光 / shadow* / profile / 分类图标调色板 / explore 占位 / mac 窗口 / preset 渐变；`app_shadows.dart` 颜色改引用 `AppColors.shadow*`；`app_text_styles.dart` 新增 `caption`；新增 `app_motion.dart`。
- 玻璃组件库 `lib/shared/widgets/glass/`：`GlassCard` / `GlassButton` / `GlassTextField` / `GlassSegmentedControl` / `GlassSheet`(+`showGlassSheet`) + `glass.dart` barrel。
- 文档：新增 `docs/DESIGN_SYSTEM.md`。

## 阶段 1 · 路由/结构治理（完成 + 决策）
- 编辑器内导航集中化：`script_editor_navigation.dart` 新增 `openSceneTimeline` / `openShotList`；`scene_editor_detail_page` 与 `script_editor_outline_tab` 改调用集中 helper（移除内联 `MaterialPageRoute` 与随之产生的未用 import）。
- 决策：`SceneEditorDetailPage`/`FrameEditorDetailPage`/`ProjectSettingsPage` 接收**活动控制器对象**（非可序列化参数），属模态编辑子屏，**保持 `Navigator.push` 而非强转 GoRoute**（强转 `extra` 是反模式）。
- 决策：`screenplay_detail_page`(1250)/`screenplay_editor_host`(991)/`outline|timeline|inspector` 深拆放到阶段 4-5 重写时一并进行，避免对同文件改两次。

## 阶段 2 · 全局外壳重绘（基本完成）
- 外壳已产品化玻璃（底栏 `LiquidGlassSurface`、AppBar `GlassAppBarBackground`）。
- `desktop_title_bar.dart` mac 窗口红黄绿 → `AppColors.macWindow*`。

## 阶段 6/7 · 账户域 + 硬编码（进行中）
- `profile_page.dart` 8 组菜单图标色 → `AppColors.cat*` 分类调色板。
- `profile_header_card.dart` 会员 banner 渐变/图标 → `AppColors.membership*`。
- `explore_featured_carousel.dart` 占位渐变 → `AppColors.explorePlaceholder*`。
- `auth_page_scaffold.dart` `EdgeInsets.all(20/24)` → `AppDimensions.pagePadding/spacingLg`。

## 后续滚动应用 pattern（阶段 3-6）
对每个 feature presentation 文件按统一手法处理，保持 analyze 绿：
1. 裸 `Container+BoxDecoration` 卡片 → `GlassCard`；按钮 → `GlassButton`；输入 → `GlassTextField`；分段 → `GlassSegmentedControl`；底部弹窗 → `showGlassSheet`。
2. 硬编码 `Color(0x..)` / `EdgeInsets.all(n)` → `AppColors.*` / `AppDimensions.*`。
3. 动画时长/曲线 → `AppMotion.*`。
4. 单体文件（>600 行）先抽组件到同目录分组文件，page 仅编排。

## 阶段 1.5 · 精简治理（进行中）

### 已完成
- B 删除死代码（含各自仅被其引用的依赖）：
  - `features/upload/presentation/pages/upload_page.dart`（+ 其专属 `widgets/upload_screenplay_preview_section.dart`）
  - `features/studio/presentation/pages/script_studio_workspace_page.dart`（+ 其专属 `widgets/script_studio_workspace_app_bar.dart`）
  - `features/explore/presentation/widgets/explore_desktop_sidebar.dart`（1 行 re-export）
  - `shared/widgets/desktop_sidebar.dart` 中废弃 typedef `ExploreDesktopSidebar` / `ExploreSidebarItem`
- A 移除纯委托壳 `shared/widgets/screenplay_card.dart`，3 处调用点切换到 `TemplateGridCard`：
  - `features/profile/presentation/pages/profile_works_page.dart`
  - `features/gallery/presentation/widgets/gallery_works_tab.dart`
  - `features/community/presentation/pages/community_page.dart`
- C 合并碎片文件：`features/scene/presentation/widgets/detail/` 下 5 个 tab（17–55 行）→ 单文件 `widgets/scene_detail_tabs.dart`，删除 `detail/` 子目录
- 治理：清理 15+ 处未用 import 与 1 处 duplicate import（analyze 62→44）

### 决策记录
- 不强行合并 `ScriptFeedCard` / `TemplateFeedCard` / `TemplateGridCard` / `ExploreFeedGridCard` / `CommunityTemplateCard`：它们是**差异化布局**且已通过 `content_card_shared.dart` 共享构件，强行合并会降低可读性并引入回归风险。
- D（配置化双布局：`ResponsiveScaffold` / `TwoPaneLayout`）**延后到对应 feature 重绘阶段（3–6）**执行，避免与后续 UI 重写重复改动 `scene_editor_detail_page` / `explore_page` / `profile_page`。

### 待办
- D 配置化双布局（随阶段 3–6 一并落地）
- 进一步去重与体积削减将在各 feature 重绘时进行（目标 ~26k 行）

## 剩余 analyze 提示（非本阶段范围）
- `lib/api/**` 文件名 `xxx-api.dart` 命名（项目约定只读，不改）
- 多处 `value`/`groupValue`/`onChanged`/`activeColor` 等 Flutter 版本弃用（统一在组件重绘阶段处理）
- `core/utils/state_listeners.dart` 的 `invalid_use_of_protected_member`（架构封装，重绘阶段评估）
