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
| 用户作品列表 | `UserScreenplaysRepository` · `fetchUserScreenplaysPage` | `listScreenplays(creator)` → fallback `listUserScreenplays` | GET `/screenplays?creator={id}` · fallback GET `/users/{id}/screenplays` |
| 剧本可见性 | `ScreenplayVisibilityService.updateVisibility` · `UserScreenplaysRepository.updateItemVisibility` | `updateScreenplay` | PUT `/screenplays/{id}` body `{ visibility: 0\|1 }` |
| 用户收藏列表 | `ScreenplayFavoriteRepository.fetchFavorites` + `getScreenplayDetail` enrichment | `listUserFavorites` · `getScreenplayDetail` | GET `/users/{id}/favorites` · GET `/screenplays/{id}` |
| 用户点赞列表 | `ScreenplayLikeRepository.fetchLikes` + `getScreenplayDetail` enrichment | `listUserLikes` · `getScreenplayDetail` | GET `/users/{id}/likes` · GET `/screenplays/{id}` |
| 关注 / 取关 | `SocialRepository` | `followUser` / `unfollowUser` | POST/DELETE `/users/{id}/follow` |
| 剧本列表 | `ScreenplayRemoteRepository.loadFirstPage` / `loadMore` | `listScreenplays` | GET `/screenplays?page&page_size`（支持 `q` 搜索、`visibility=1` 公开流） |
| 发现页 Feed（桌面） | `FeedRepository.loadFirstPage` / `loadMore` | `feed/api/feed-api.dart` → `listFeed` | GET `/feed?page&page_size&sort&q&tag_id&kind` |
| 剧本树（读） | `ScreenplayRemoteRepository.fetchScreenplayTree` | `getScreenplayTree` | GET `/screenplays/{id}/tree?depth=3&act_page_size=0&scene_page_size=0&frame_page_size=0` |
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
| 图片标签列表 | `ImageTagsRepository.loadTags` | `listImageTags` | GET `/image-tags` |
| 图片标签创建 / 打标 | `ImageTagsRepository.applyTagsToImage` | `createImageTag` / `tagImage` / `untagImage` | POST `/image-tags` · POST/DELETE `/images/{id}/tags` |
| IP 列表 / 详情 | `IpRepository.loadFirstPage` / `fetchDetail` | `work/api/work-api.dart` → `listWorks` / `getWork` | GET `/works` · GET `/works/{id}` |
| IP 创建 / 更新 / 删除 | `IpRepository.create` / `update` / `delete` | `createWork` / `updateWork` / `deleteWork` | POST `/works` · PUT/DELETE `/works/{id}` |
| 图片关联 IP | `IpRepository.linkToImage` | `image/api/image-api.dart` → `linkImageWork` / `unlinkImageWork` | POST/DELETE `/images/{id}/works` |
| 角色库 / 详情 | `CharacterRepository.loadFirstPage` / `fetchDetail` | `character/api/character-api.dart` → `listCharacters` / `getCharacter` | GET `/characters` · GET `/characters/{id}` |
| 角色创建 / 更新 / 删除 | `CharacterRepository.create` / `update` / `delete` | `createCharacter` / `updateCharacter` / `deleteCharacter` | POST `/characters` · PUT/DELETE `/characters/{id}` |
| IP 下角色列表 | `CharacterRepository.fetchWorkCharacters` · IP 详情页 | `listWorkCharacters` / `createWorkCharacter` | GET/POST `/works/{id}/characters` |
| 图片关联角色 | — | `character-api.dart`（待 UI） | GET/POST `/images/{id}/characters` · DELETE `/images/{id}/characters/{character_id}` |
| 场景库 / 详情 | —（本地 `SceneRepository`） | `scene/api/scene-api.dart` → `listScenes` / `getScene` | GET `/scenes` · GET `/scenes/{id}` |
| 场景创建 / 更新 / 删除 | — | `createScene` / `updateScene` / `deleteScene` | POST `/scenes` · PUT/DELETE `/scenes/{id}` |
| 图片关联场景 | — | `scene-api.dart`（待 UI） | GET/POST `/images/{id}/scenes` · DELETE `/images/{id}/scenes/{scene_id}` |
| 剧本场景帧列表 | — | `frame/api/frame-api.dart` → `listSceneFrames` | GET `/screenplay-scenes/{id}/frames` |
| 分镜绑定角色 | Studio Inspector · tree sync | `FrameDraft.characterId` → `acgn_character_id` | PUT tree / PUT `.../frames/{id}` |
| 剧本标签同步 | `ScreenplayTagsRepository.applyTagsToScreenplay` · `syncTags` | `listScreenplayTags` / `createScreenplayTag` / `tagScreenplay` / `untagScreenplay` | GET/POST `/tags` · POST `/tags/{screenplayId}` · DELETE `/tags/{screenplayId}/{tagId}` |
| 拍摄参数预设 | `ShootPresetRepository` | `cine-preset/api/cine-preset-api.dart` → `listCinePresets` / `listMyCinePresets` / `createCinePreset` / `updateCinePreset` / `deleteCinePreset` | GET `/cine-presets?scope=0\|1` · GET `/cine-presets/mine` · POST `/cine-presets` · PUT/DELETE `/cine-presets/{id}` |
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
