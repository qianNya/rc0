# RC0 Flutter API 结构（Rust 后端）

手写 Dart HTTP 客户端，对接 `rc0-rust` REST API（默认 `http://host:8080`）。

## 目录

| 路径 | 职责 |
| --- | --- |
| `lib/api/http/api_client.dart` | 统一传输层（GET/POST/PUT/DELETE/multipart + 信封解析） |
| `lib/api/auth/` | 注册 / 登录 / 刷新令牌 / Token 持久化 |
| `lib/api/user/` | 当前用户、公开资料、关注、用户剧本/收藏/点赞列表 |
| `lib/api/character/` | 角色库 CRUD、作品/图片关联 |
| `lib/api/scene/` | 场景库 CRUD、图片关联 |
| `lib/api/screenplay/` | 剧本 CRUD、层级树、分步 act/scene/frame、发布 |
| `lib/api/community/` | 点赞 / 收藏切换 |
| `lib/api/feed/` | 发现 Feed、全局搜索 |
| `lib/api/frame/` | 单帧详情、下载、场景帧列表 |
| `lib/api/image/` | 图片上传与 presigned 下载 |
| `lib/api/system/` | 健康检查 |

## 约定

- 路径**无** `/api` 前缀
- 响应信封：`{ code, message, data }`，`code == 0` 为成功
- 认证：`Authorization: Bearer <access_token>`
- UI / Repository **不直接**拼 HTTP；经 `lib/api/*/api/*-api.dart` 调用

## 与 Go 时代差异

- 已移除 31 表 Admin CRUD、`gallery`/`monitor`/`reply`/旧 `data` 模块
- 无 bulk `PUT /tree`；发布走分步 CRUD + `POST /screenplays/{id}/publish`
- 上传：`POST /images`（multipart），下载：`GET /images/{id}/download`

## 参考

- Rust HTTP 调试参考：`lib/api/http/*.http`（来自 `rc0-rust/docs/http`）
- Rust 文档：`rc0-rust/docs/http-api.md`
- 应用矩阵：`docs/APP_API_MATRIX.md`
