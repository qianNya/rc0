# 06 — API 契约

> SSOT：后端 `C:/Users/qianlNya/RustroverProjects/rc0-rust/docs/openapi.yaml`

## 原则

- Handler 薄：校验 → service → DTO 响应。
- 跨域编排只在 service 层；repository 不跨域调用。
- 前端代码生成：`lib/api/**`（由 OpenAPI / 内部生成器维护）。

## 关键端点（摘要）

| 域 | 端点 | 说明 |
|---|---|---|
| Auth | `POST /auth/login` | JWT |
| Images | `POST /images` | 上传（将异步化） |
| Screenplay | `GET/PUT /screenplays/{id}` | CRUD |
| Tree | `PUT /screenplays/{id}/tree` | 树同步 |
| Gallery | `GET /images` | 分页列表 |
| Feed | `GET /feed?kind=2` | 发现页模板市场（与 `GET /screenplays?visibility=1` 等价降级源） |
| Community | `POST /screenplays/{id}/like` | 互动 |

## 与前端对齐

- 上传响应字段映射到 `UploadedMediaResult`。
- 树 `asset_map` 与 `ImageRef` 远程字段对齐（`remote_image_id`、`remote_url`）。
- Presign URL 由服务端签发；前端持久化 id，展示 URL 可过期重建。

历史矩阵：[archive/APP_API_MATRIX.md](archive/APP_API_MATRIX.md)（仅供参考）。
