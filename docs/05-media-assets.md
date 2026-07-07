# 05 — 媒体资产

> SSOT：[refactor/TECHNICAL_DESIGN.md](refactor/TECHNICAL_DESIGN.md) §4 · PRD §3.8

## 前端入口（强制）

| 操作 | 入口 |
|---|---|
| 单文件上传 | `AppMediaUploadService.uploadLocalFile` |
| 剧本封面 | `AppMediaUploadService.uploadScreenplayCover` |
| 批量上传 | `AppMediaUploadService.uploadLocalBatch` |
| 网络/本地显示 | `Rc0Image` + `ImageResolver` |

**禁止** feature 层直接 `DataUploadRepository.instance`（仅 `AppMediaUploadService` 内部委托）。

## ImageRef 序列化

```dart
ImageRef(
  imageId: '123',
  fileId: '456',
  remoteUrl: 'https://…',
  localPath: '/path/to/local.webp',
)
```

`UploadedMediaResult.applyToFrameMap` 双写 legacy 字段。

## 待迁移（TODO）

以下页面仍使用裸 `Image.network` / `NetworkImage`，后续迁到 `Rc0Image`：

- `character_form_sections.dart`
- `scene_form_sections.dart`
- `explore_feed_grid_card.dart` / `explore_desktop_header.dart`
- `profile_widgets.dart` / `favorites_page.dart` / `profile_likes_page.dart`

## 后端异步管线（目标）

1. `POST /images` 落原图 + `processing` 状态
2. 入队 `media.process` Redis Stream
3. `rc0-worker` 生成 display/feed/thumb WebP 并回写
