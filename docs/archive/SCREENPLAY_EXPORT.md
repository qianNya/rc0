# 剧本导出范围说明

> Legacy-reference：本文件保留用于导出功能回归。重构范围与优先级请以 `docs/refactor/PRD.md` 与 `docs/refactor/TECHNICAL_DESIGN.md` 为准；文档状态见 `docs/README.md`。

## 当前支持

| 格式 | 入口 | 说明 |
|------|------|------|
| **`.rc0.json`** | `ScriptExportPage`（`/script/:id/export`） | 完整 `ScreenplayTreeDocument`（`meta` + `tree`） |
| **`.rc0.json`** | `ScreenplayDetailPage` → 结构预览 → 导出 | 同上 |
| **导入** | `ScriptEditorBottomToolbar`（桌面底栏，待挂接主路由） | `ScreenplayBundleService.importFromFile` |

实现：`lib/features/screenplay/data/screenplay_bundle_service.dart`

### JSON 包内容

- 剧本元信息、幕 / 场 / 画层级结构
- 拍摄默认参数、角色 / 场景库链接
- 每帧：`CineParams`、Prompt、拍摄覆盖、本地图片路径、`reference_local_paths`
- 客户端 `meta`（`local_id`、`sync_state` 等）

### 不包含

- 独立图片 zip（需从应用文档目录 `screenplays/{id}/frames/` 手动拷贝，或未来扩展）
- PDF / 分镜表 Markdown
- 视频时间线渲染输出
- 云端已发布剧本的实时同步（导出为导出时刻快照）

## 未来扩展（单独立项）

1. **镜头表导出** — Markdown / CSV：场序、景别、时长、Prompt 摘要
2. **素材包** — zip：JSON + 所有帧图与参考图
3. **发布用 PDF** — 排版分镜板

扩展导出不应替代 `.rc0.json`；JSON 仍是跨设备完整还原的唯一标准格式。
