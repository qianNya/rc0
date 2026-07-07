# 02 — 前端架构

> SSOT：[refactor/TECHNICAL_DESIGN.md](refactor/TECHNICAL_DESIGN.md)

## 分层

```
lib/app/          → 壳层：路由、Riverpod、ports 注册
lib/core/         → 跨 feature 基础设施（network、auth bridge、media facade）
lib/features/     → 垂直切片（auth、screenplay、studio、gallery…）
lib/shared/       → 通用 widget（Rc0Image、Glass*）
packages/rc0_*    → 可复用 kernel / feature 包
```

## 状态管理（迁移中）

| 阶段 | 模式 |
|---|---|
| 当前 | `ChangeNotifier` 单例 + Riverpod `Provider` 桥接 |
| 目标 | `Notifier` / `AsyncNotifier` + repository 注入 |

入口：`ProviderScope`（`main.dart`）→ `goRouterProvider` / `authSessionProvider`。

## 路由

- `AppRouter.buildRouter` 负责 shell 与全量页面装配。
- `FeatureModule` 贡献 `navEntries` 与可选 `routes`（编辑器已试点）。
- 路径常量逐步迁入 feature package（`EditorRoutes` 已在 `rc0_feature_editor`）。

## 媒体

- 上传：`MediaUploadService` ← `AppMediaUploadService` ← `DataUploadRepository`（legacy HTTP）
- 显示：`Rc0Image` + `ImageResolver`；禁止新增裸 `Image.network`。

## 3D 运行时

过渡策略见 [08-runtime-3d.md](08-runtime-3d.md)。
