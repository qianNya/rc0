# API 覆盖表

> 状态：**Used** = App 已调用 · **Available** = 已封装 repository 未接 UI · **Admin** = Admin CRUD 注册表 · **—** = 未封装

---

## auth

| 函数 | 路径 | 状态 |
|------|------|------|
| `login` | POST `/api/auth/login` | Used |
| `register` | POST `/api/auth/register` | Used |
| `ping` | GET `/api/auth/ping` | — |

---

## admin（社交 / Profile）

| 函数 | 路径 | 状态 |
|------|------|------|
| `getProfile` | GET `/api/admin/profile` | Used |
| `updateProfile` | POST `/api/admin/profile` | — |
| `getPublicUserProfile` | GET `/api/admin/social/users/:id/public` | Used |
| `followUser` | POST `/api/admin/social/users/:id/follow` | Used |
| `unfollowUser` | POST `/api/admin/social/users/:id/follow` | Used |
| `listUserScreenplays` | GET `/api/admin/social/users/:id/screenplays` | Used |

---

## screenplay（C 端）

| 函数 | 状态 |
|------|------|
| `listScreenplays` | Used |
| `getScreenplayTree` | Used |
| `getScreenplayTree`（depth / 分页 query） | Available — 需 shim |
| `saveScreenplayTree` | Used — `ScreenplayPublishService` + `core/network/screenplay_tree_http.dart` PUT |
| `createScreenplayTree` | Available |
| `deleteScreenplayTree` | Available — shim 已实现，UI 未接 |
| `batchUploadTreeAssets` | Available — multipart shim 未接（发布用 data batch） |
| `createScreenplay` | Used（发布时创建壳剧本） |
| `createAct` / `createScene` / `createFrame` | —（已迁移至聚合树 PUT） |
| `updateScreenplay` | —（发布元数据由树 PUT 写入） |
| `deleteScreenplay` / `deleteAct` / `deleteScene` / `deleteFrame` | Used（细粒度） |
| `likeScreenplay` / `unlikeScreenplay` | Used |
| `favoriteScreenplay` / `unfavoriteScreenplay` | — |
| `reorderActs` / `reorderScenes` / `reorderFrames` | — |
| CRUD `SpFavorite` / `SpLike` 等 | — |

---

## data

| 函数 | 路径 | 状态 |
|------|------|------|
| `upload()`（生成 stub） | POST `/api/data/upload` | Stub — 使用 `core/network/data_upload.dart` |
| multipart upload（实际） | POST `/api/data/upload` | Used（`core/network/data_upload.dart`） |
| `batchUpload`（生成 stub） | POST `/api/data/upload/batch` | Used — `core/network/batch_upload.dart` + `DataUploadRepository.uploadBatch` |
| `presignDownload` | POST `/api/data/presign/download` | Used |
| `deleteObject` / `statObject` / `ping` | — | — |

---

## gallery

| 函数 | 状态 |
|------|------|
| ACGN 8 表 CRUD | Available（`GalleryRepository.listImages`） |
| `uploadImage()`（生成 stub） | Stub — multipart 需 codegen 侧修复或 app 层封装 |

---

## reply

| 函数 | 状态 |
|------|------|
| `listComments` / `createComment` / `getComment` / `updateComment` / `deleteComment` | Available（`ReplyRepository.listComments`） |

---

## monitor

| 函数 | 状态 |
|------|------|
| `getHealth` / `listServices` / `listInfra` / `listLogs` / `getMetrics` / `getTraceChain` | Available（`MonitorRepository`） |

---

## admin CRUD（31 表 + RBAC 4 实体 = 33 注册项）

全部映射至 `admin/api/admin-api.dart`，状态：**Admin**

### 用户域
`user`, `user_profile`, `follow`, `log`, `oauth`

### RBAC
`menu`, `role`, `role_menu`, `user_role`

### 剧本域（16）
`sp_screenplay`, `sp_act`, `sp_scene`, `sp_frame`, `sp_tag`, `sp_screenplay_tag`, `sp_comment`, `sp_like`, `sp_favorite`, `sp_fork`, `sp_view_log`, `sp_featured_collection`, `sp_featured_collection_item`, `sp_template_related`, `sp_cine_preset_category`, `sp_cine_preset`

### ACGN 域（8）
`acgn_image`, `acgn_image_analysis`, `acgn_image_file`, `acgn_image_metrics`, `acgn_image_tag`, `acgn_tag`, `acgn_work`, `acgn_image_work`

---

## 允许 / 禁止的 import

**允许（App 层）：**
- `lib/api/{module}/api/*-api.dart`
- `lib/api/{module}/data/*-api.dart`
- `lib/api/{module}/vars/kv.dart`
- `lib/api/{module}/data/tokens.dart`
- `lib/core/network/*`

**禁止（已移除）：**
- `lib/api/**/**_ext.dart`
- `lib/api/http/*.dart`（App 层）
- `lib/api/data/api/upload.dart`
