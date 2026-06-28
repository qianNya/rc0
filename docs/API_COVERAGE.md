# API 覆盖表（Rust 后端）

> **Used** = App 已调用 · **Available** = lib/api 已封装未接 UI · **—** = 未封装

---

## auth

| 函数 | 路径 | 状态 |
|------|------|------|
| `login` | POST `/auth/login` | Used |
| `register` | POST `/auth/register` | Used |
| `refreshToken` | POST `/auth/refresh` | Used — `AuthRepository.tryRefreshToken` |

---

## user

| 函数 | 路径 | 状态 |
|------|------|------|
| `getProfile` | GET `/users/me` | Used |
| `updateProfile` | PUT `/users/me` | Used |
| `getPublicUserProfile` | GET `/users/{id}/profile` | Used |
| `listUserScreenplays` | GET `/users/{id}/screenplays` | Used |
| `listUserFavorites` | GET `/users/{id}/favorites` | Used |
| `listUserLikes` | GET `/users/{id}/likes` | Used |
| `followUser` | POST `/users/{id}/follow` | Used |
| `unfollowUser` | DELETE `/users/{id}/follow` | Used |

---

## screenplay

| 函数 | 路径 | 状态 |
|------|------|------|
| `listScreenplays` | GET `/screenplays` | Used |
| `createScreenplay` | POST `/screenplays` | Used |
| `updateScreenplay` | PUT `/screenplays/{id}` | Used — 发布/同步元数据 |
| `getScreenplayTree` | GET `/screenplays/{id}/tree` | Used |
| `getScreenplayDetail` | GET `/screenplays/{id}/detail` | Available — Repository 已封装 |
| `publishScreenplay` | POST `/screenplays/{id}/publish` | Used |
| `uploadScreenplayCover` | POST `/screenplays/{id}/cover` | Used |
| `createAct/Scene/Frame` | POST 分步 CRUD | Used — `ScreenplayPublishService` |
| `updateAct/Scene/Frame` | PUT 分步 CRUD | Used — 同步已有节点 |
| `deleteScreenplay/Act/Scene/Frame` | DELETE | Used |

---

## community

| 函数 | 路径 | 状态 |
|------|------|------|
| `toggleLike` | POST `/likes/{id}` | Used |
| `toggleFavorite` | POST `/favorites/{id}` | Available |

---

## image

| 函数 | 路径 | 状态 |
|------|------|------|
| `uploadImageFile` | POST `/images` | Used |
| `getImageDownloadUrl` | GET `/images/{id}/download` | Available |

---

## feed

| 函数 | 路径 | 状态 |
|------|------|------|
| `listFeed` | GET `/feed` | Available |
| `search` | GET `/search` | Available |

---

## frame

| 函数 | 路径 | 状态 |
|------|------|------|
| `getFrame` | GET `/frames/{id}` | Available |
| `getFrameDownloadUrl` | GET `/frames/{id}/download` | Available |
| `listSceneFrames` | GET `/screenplay-scenes/{id}/frames` | Available |
| `applyFramePreset` | POST `/frames/{id}/apply-preset` | — |

---

## scene

| 函数 | 路径 | 状态 |
|------|------|------|
| `listScenes` | GET `/scenes` | Available |
| `getScene` | GET `/scenes/{id}` | Available |
| `createScene` | POST `/scenes` | Available |
| `updateScene` | PUT `/scenes/{id}` | Available |
| `deleteScene` | DELETE `/scenes/{id}` | Available |
| `listImageScenes` | GET `/images/{id}/scenes` | Available |
| `linkImageScene` | POST `/images/{id}/scenes` | Available |
| `unlinkImageScene` | DELETE `/images/{id}/scenes/{scene_id}` | Available |

---

## system

| 函数 | 路径 | 状态 |
|------|------|------|
| `health` | GET `/health` | — |

---

## 已移除（Go 时代）

- `lib/api/admin` 31 表 CRUD
- bulk `PUT/POST /screenplays/{id}/tree`
- `/api/data/upload`、`presign/download`
- `gallery` / `monitor` / `reply` 模块
