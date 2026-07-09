# rc0 全栈重构文档

本目录是 rc0 全栈模块化重构的交付文档，基于对两个真实仓库的完整代码审阅编写：
- 前端 Flutter：`C:/Users/qianlNya/flutter/flutter_application_1`
- 后端 Rust Axum：`C:/Users/qianlNya/RustroverProjects/rc0-rust`

## 文档索引
| 文档 | 内容 |
|---|---|
| [../README.md](../README.md) | docs 总入口：权威文档与历史参考文档分级 |
| [PRD.md](PRD.md) | 产品需求文档：定位、六大问题、功能/非功能需求、里程碑、成功指标、风险 |
| [TECHNICAL_DESIGN.md](TECHNICAL_DESIGN.md) | 技术方案：目标架构、前端(melos+Riverpod+插件化)、后端(workspace+media+worker)、数据模型、迁移与分阶段 |
| [BACKEND_KICKOFF.md](BACKEND_KICKOFF.md) | 后端 media/screenplay/worker 启动审阅与落地顺序 |
| [GEAR_MEDIA_BACKEND_PRD.md](GEAR_MEDIA_BACKEND_PRD.md) | Gear Cabinet / Media Vault 后端接入 PRD：目标、用户故事、范围、验收与风险 |
| [GEAR_MEDIA_CRUD_PLAN.md](GEAR_MEDIA_CRUD_PLAN.md) | Gear Cabinet / Media Vault CRUD 实施计划：模型、端点、分阶段任务 |
| [SHELL_NAV_PRD.md](SHELL_NAV_PRD.md) | Shell 导航优化 PRD：PC 侧栏 + App 底栏统一 L1、标签治理与验收 |
| [DESKTOP_WINDOW_CHROME_PRD.md](DESKTOP_WINDOW_CHROME_PRD.md) | 桌面窗口栏 PRD：拖拽区、缩放/全屏、macOS 红绿灯 |
| [SCREENPLAY_TEMPLATE_PRD.md](SCREENPLAY_TEMPLATE_PRD.md) | 剧本↔模板关系与全链路 PRD（待改后定稿重构） |
| [CHARACTER_SYSTEM_PRD.md](CHARACTER_SYSTEM_PRD.md) | 角色体系 PRD：演员本体、服装、道具、风格、Tag、适合场景、卡司与 AI |

## 核心结论速览
- **P1 图片资产**：端到端统一 `ImageRef`，前端单一 resolver/显示/上传，后端 media crate + 队列 + 分片 key。
- **P2 解耦**：前端拆 `studio↔upload↔screenplay` 环 + 端口注入；后端拆 837 行 `service/screenplay.rs`、补齐分层。
- **P3 AI 图爆炸**：异步 worker + Redis 队列 + 时间分区 + AI 生成侧表。
- **P4 页面治理**：清死代码、收敛路由。
- **P5 数据模型**：统一图片引用与剧本树的单一权威定义。
- **P6 插件化**：`FeatureModule` + `ModuleRegistry` 可注册模块。

## 落地阶段
阶段0 基座 → 阶段1 图片统一 → 阶段2 解环 → 阶段3 规模化 → 阶段4 插件化。详见技术方案第 9 节。

## 实施进度（2026-07-07）

| 大项 | 状态 | 说明 |
|---|---|---|
| Melos + 内核包 | 进行中 | `rc0_core` / `rc0_network` / `rc0_media` / `rc0_feature_editor` / `rc0_ui` / `rc0_runtime_3d` 已建 |
| ImageRef 统一 | 前端基本完成 | feature 层上传已收口至 `AppMediaUploadService`；`Rc0Image` 迁移进行中 |
| studio/upload/screenplay 解环 | 进行中 | `EditorControllerView` 契约；controller 仍在 app feature |
| Riverpod 迁移 | 进行中 | `ImageGalleryNotifier` / `SceneListNotifier` 试点 + providers 桥接 |
| 死代码/路由 | 部分完成 | `social` 保留 facade；`tasks` 统一 ComingSoon；`FeatureModule` nav 扩展 |
| 插件化 | 部分完成 | editor/explore/library/profile 模块注册 + `shell_nav_registry` |
| 文档编号化 | 完成 | `00`–`10` 编号文档 + legacy 归档至 `docs/archive/` |
| 后端 media/worker | 骨架已建 | `crates/rc0-media`、`rc0-worker` bin、`screenplay_tree`/`screenplay_media` 拆分 |
| Gear Cabinet 后端对齐 | 进行中 | `gear_cabinet_api_mapper` 接 `EquipmentRepository`；灯具房暂保留 sample |
| Media Vault 后端对齐 | 进行中 | 登录态 `/images` + `/media-vault` 专辑/状态/指标；API 失败时本地降级 |
