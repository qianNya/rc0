# 01 — 模块地图

> SSOT：[refactor/TECHNICAL_DESIGN.md](refactor/TECHNICAL_DESIGN.md) §3

## 前端包层次

| 包 | 职责 |
|---|---|
| `rc0_core` | `ImageRef`、ports、`FeatureModule`、`ModuleRegistry` |
| `rc0_network` | API envelope、auth header、错误消息 |
| `rc0_media` | 上传契约、`ImageResolver`、URL 工具 |
| `rc0_ui` | Liquid Glass 共享视觉 primitive |
| `rc0_feature_editor` | 编辑器契约、路由常量、会话快照 |
| `rc0_runtime_3d` | 3D 运行时过渡包（见 `08-runtime-3d.md`） |
| `lib/features/*` | 业务 feature（data + presentation） |
| `lib/app` | 路由装配、providers、ports 实现 |

## 模块边界

- Feature **不得** import 其他 feature 的实现层。
- 跨域协作走 `rc0_core` ports 或 app 层 `ModuleRegistry`。
- `screenplay` 拥有树模型与同步；编辑器 UI 归 `studio`/`upload`，逐步迁入 `rc0_feature_editor`。
- 图片上传/显示统一经 `rc0_media` / `AppMediaUploadService`。

## 后端 crate（目标）

| crate | 职责 |
|---|---|
| `rc0-rust`（api） | HTTP handler、thin service 编排 |
| `rc0-media` | 图片上传、变体、presign、分析入队 |
| `rc0-worker` | Redis Stream 消费、异步图片处理 |

历史模块地图见 [archive/APP_ARCHITECTURE_OPTIMIZED.md](archive/APP_ARCHITECTURE_OPTIMIZED.md)。
