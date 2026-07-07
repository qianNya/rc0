# 本地剧本 JSON 规范

> Legacy-reference：本文件保留用于迁移旧草稿。全栈重构后的本地/云端媒体引用请以 `docs/refactor/TECHNICAL_DESIGN.md` 中的 ImageRef 方案为准；文档状态见 `docs/README.md`。

App 持久化格式：`ScreenplayTreeDocument` = `{ "tree", "meta" }`，存于 SharedPreferences `rc0_screenplay_trees`。

## meta（仅 App，不上传）

| 字段 | 说明 |
|------|------|
| `local_id` | App 主键，如 `script-1739123456789` |
| `remote_screenplay_id` | 数据库 ID；`null` = 未发布 |
| `is_local` / `tags` / `author` | 本地元数据 |
| `published_at` / `visibility` | 发布后填充 |

## tree（与 API 同构 + App 扩展字段）

### 图片字段（严格分离）

| 字段 | 内容 |
|------|------|
| `cover_url` / `image_url` / `thumbnail_url` | **仅** `https://...` 或空字符串 |
| `local_cover_path` / `local_image_path` / `local_thumbnail_path` | **仅** 本地绝对路径 |

本地图片目录：

```
{ApplicationDocuments}/screenplays/{local_id}/frames/
```

### 未发布示例

```json
{
  "meta": { "local_id": "script-1739...", "remote_screenplay_id": null },
  "tree": {
    "screenplay": {
      "cover_url": "",
      "local_cover_path": "/data/.../frame-0.jpg"
    },
    "acts": [{
      "scenes": [{
        "frames": [{
          "image_url": "",
          "local_image_path": "/data/.../frame-0.jpg"
        }]
      }]
    }]
  }
}
```

### 单张上传后

`*_url` 写入 CDN URL；`local_*` 保留。UI **优先显示本地路径**；有 `*_url` 时显示 cloud 角标。

### ID 体系

| 场景 | `tree.screenplay.id` | `meta.remote_screenplay_id` |
|------|---------------------|----------------------------|
| 未发布 | 伪整数（时间戳） | `null` |
| 已发布 | 数据库 ID | 同左 |

`act` / `scene` / `frame` 的 `id`：未发布多为 `0`；发布后为服务端分配 ID。

## 上传请求（SaveScreenplayTreeReq）

与本地 JSON 不同：含 `asset_map`、`*_ref`，不含 `meta` 与 `local_*`。

- 首次创建树：`POST /api/screenplay/screenplays/:id/tree`
- 已发布同步：`PUT /api/screenplay/screenplays/:id/tree`
