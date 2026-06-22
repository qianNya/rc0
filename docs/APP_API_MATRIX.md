# App 接口使用矩阵（Rust 后端）

> App 经 `lib/api/*/api/*-api.dart` 手写客户端对接 `rc0-rust`（默认 `:8080`，无 `/api` 前缀）。

---

## 已接入

| Feature | Repository / 入口 | lib/api | HTTP |
|---------|---------------------|---------|------|
| 登录 | `AuthRepository.login` | `auth/api/auth-api.dart` → `login` | POST `/auth/login` |
| 注册 | `AuthRepository.register` | `register` | POST `/auth/register` |
| 当前用户资料 | `AuthRepository._fetchProfile` | `user/api/user-api.dart` → `getProfile` | GET `/users/me` |
| 更新资料 | `AuthRepository.updateProfile` | `updateProfile` | PUT `/users/me` |
| 公开用户资料 | `UserProfileRepository.fetchPublicProfile` | `getPublicUserProfile` | GET `/users/{id}/profile` |
| 用户作品列表 | `UserProfileRepository.listUserScreenplays` | `listUserScreenplays` | GET `/users/{id}/screenplays` |
| 用户收藏列表 | `ScreenplayFavoriteRepository.fetchFavorites` | `listUserFavorites` | GET `/users/{id}/favorites` |
| 用户点赞列表 | `ScreenplayLikeRepository.fetchLikes` | `listUserLikes` | GET `/users/{id}/likes` |
| 关注 / 取关 | `SocialRepository` | `followUser` / `unfollowUser` | POST/DELETE `/users/{id}/follow` |
| 剧本列表 | `ScreenplayRemoteRepository.fetchScreenplays` | `listScreenplays` | GET `/screenplays` |
| 剧本树（读） | `ScreenplayRemoteRepository.fetchScreenplayTree` | `getScreenplayTree` | GET `/screenplays/{id}/tree` |
| 剧本树（写） | `ScreenplayRemoteRepository.saveScreenplayTree` | `createScreenplayTree` / `updateScreenplayTree` | POST/PUT `/screenplays/{id}/tree` |
| 创建剧本 | `ScreenplayPublishService` | `createScreenplay` | POST `/screenplays` |
| 批量同步树 | `ScreenplayPublishService._syncTreeBulk` | `createScreenplayTree` / `updateScreenplayTree` | POST/PUT `/screenplays/{id}/tree` |
| 发布 | `ScreenplayPublishService._publish` | `publishScreenplay` | POST `/screenplays/{id}/publish` |
| 删除剧本 / 幕 / 场 / 帧 | `ScreenplayRemoteDeleteService` | `deleteScreenplay/Act/Scene/Frame` | DELETE `/screenplays/...` |
| 点赞切换 | `SocialRepository.toggleLikeScreenplay` | `community/api/community-api.dart` → `toggleLike` | POST `/likes/{id}` |
| 上传图片 | `DataUploadRepository` | `image/api/image-api.dart` → `uploadImageFile` | POST `/images` multipart |
| 图片列表 | `ImageGalleryRepository.loadFirstPage` | `listImages` | GET `/images` |
| 图片详情 | `ImageGalleryRepository.fetchDetail` | `getImageDetail` | GET `/images/{id}` |
| 图片下载 URL | `ImageGalleryRepository.fetchDownloadUrl` | `getImageDownloadUrl` | GET `/images/{id}/download` |
| 401 登出 | `main.dart` | `core/network/api_auth.dart` | — |

---

## 已移除

| 旧模块 | 说明 |
|--------|------|
| `lib/api/admin`（31 表 CRUD） | Rust 仅保留 RBAC/OAuth/审计，App 未接 Admin UI |
| `lib/features/admin` | 随 Admin CRUD 一并删除 |
| 分步 act/scene/frame CRUD 同步 | 已改为 bulk POST/PUT `/tree` |
| `gallery` / `monitor` / `reply` / 旧 `data` API | 未在 App 中使用或已替换 |

---

## 参考

- Rust：`rc0-rust/docs/http-api.md`
- API 结构：`lib/api/API_STRUCTURE.md`
