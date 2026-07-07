# 04 — 数据模型

> SSOT：[refactor/TECHNICAL_DESIGN.md](refactor/TECHNICAL_DESIGN.md) §6

## 前端核心类型

| 类型 | 位置 | 说明 |
|---|---|---|
| `ImageRef` | `rc0_core` | `imageId` / `fileId` / `remoteUrl` / `localPath` 统一引用 |
| `ScreenplayDraft` | `features/screenplay` | 本地编辑草稿（acts/scenes/frames） |
| `ScreenplayTreeDocument` | `features/screenplay` | 持久化树 JSON + meta |
| `GalleryImage` | `features/gallery` | 图库列表项 |

## 树 JSON 图片字段（双写兼容期）

帧/封面 map 同时支持：

- 旧：`image_url`、`thumbnail_url`、`acgn_image_id`
- 新：`ImageRef.applyToFrameMap` / `applyToCoverMap`

本地草稿读取须兼容旧字段；新写入经 `UploadedMediaResult.applyToFrameMap`。

## 后端核心表（摘要）

- `sp_screenplay` / `sp_act` / `sp_scene` / `sp_frame` — 剧本树
- `acgn_image` / `acgn_image_file` — 图片与变体文件
- `acgn_image_analysis` — 分析任务

详细字段见 OpenAPI 与 `rc0-rust/src/model/`。

历史树格式：[archive/SCREENPLAY_LOCAL_JSON.md](archive/SCREENPLAY_LOCAL_JSON.md)。
