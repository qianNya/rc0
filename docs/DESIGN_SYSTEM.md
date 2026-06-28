# rc0 设计系统（Liquid Glass Design System）

苹果液态玻璃（Liquid Glass / Glassmorphism）为全局视觉基准，Material 3 之上扩展，支持 Light/Dark。

## 1. 设计 Token

全部位于 `lib/app/theme/`，禁止在业务层硬编码颜色/间距/阴影/动画。

| Token 类 | 文件 | 用途 |
|---|---|---|
| `AppColors` | `app_colors.dart` | 颜色（暗色 `*Dark`；玻璃 `glass*`；阴影 `shadow*`） |
| `AppDimensions` | `app_dimensions.dart` | 间距 4/8/16/24/32、圆角、`pagePadding`、玻璃模糊 sigma |
| `AppTextStyles` | `app_text_styles.dart` | `display`/`title`/`body`/`bodySecondary`/`label`/`caption` |
| `AppShadows` | `app_shadows.dart` | `card`/`bottomNav`/`floatingBar`/`floatingBarNav`（颜色走 `AppColors.shadow*`） |
| `AppMotion` | `app_motion.dart` | 动画时长 `fast/normal/slow` + 曲线 `standard/emphasized/smooth` |

```dart
// BAD
color: Color(0xFF6B4FE0)
padding: EdgeInsets.all(12)
duration: Duration(milliseconds: 250)

// GOOD
color: AppColors.accent
padding: const EdgeInsets.all(AppDimensions.spacingMd)
duration: AppMotion.normal
```

### 新增语义色（替代历史硬编码）
- profile：`profileIcon` / `profileIconBg` / `membershipGradientStart|End`
- explore 占位：`explorePlaceholderStart|End`
- macOS 窗口控件：`macWindowClose|Minimize|Zoom`
- 预设封面渐变：`presetCoverStart|End`
- 玻璃高光：`glassHighlightLight|Dark`
- 阴影：`shadowSoft|Faint|Ambient|NavCast|NavFaint`

## 2. 玻璃组件库

位于 `lib/shared/widgets/glass/`，统一 `import '.../glass/glass.dart';`。
所有玻璃效果必须复用这些组件或底层 `LiquidGlassSurface`，**禁止在业务层直接写 `BackdropFilter` / `ImageFilter.blur`**。

| 组件 | 文件 | 用途 |
|---|---|---|
| `LiquidGlassSurface` | `liquid_glass_surface.dart` | 底层 primitive（`standard` / `navigation`） |
| `GlassCard` | `glass/glass_card.dart` | 可点击磨砂卡片（替代裸 `Container+BoxDecoration`） |
| `GlassButton` | `glass/glass_button.dart` | 胶囊按钮（`filled` 主操作 / 玻璃次操作，支持 `loading`） |
| `GlassTextField` | `glass/glass_text_field.dart` | 玻璃输入框（无下划线，背景由玻璃提供） |
| `GlassSegmentedControl` | `glass/glass_segmented_control.dart` | 分段控件（玻璃轨道 + 动画选中药丸） |
| `GlassSheet` + `showGlassSheet` | `glass/glass_sheet.dart` | 玻璃底部弹窗（含 grab handle 与 SafeArea） |

### 用法示例
```dart
GlassCard(
  onTap: () => context.push(route),
  child: Text('标题', style: AppTextStyles.label),
);

GlassButton(label: '发布到云端', filled: true, loading: publishing, onPressed: onPublish);

showGlassSheet(context, child: const VisibilityOptions());
```

## 3. 布局与交互规范
- 页面壳：`AppScaffold` / `AppCard`；外壳玻璃化由 shell + `Rc0AppBar` 提供。
- 响应式：`Breakpoints`（≥840 桌面侧栏）+ `ResponsiveBuilder`。
- 列表/数据页必须有空状态、加载中、错误三态。
- UI 不直接调用 API（经 Repository），不暴露 raw DTO。
- 动画优先隐式动画 + `AppMotion` token。

## 4. 进度
改造进度与逐文件清单见 `docs/UI_REFACTOR_TRACKER.md`。
