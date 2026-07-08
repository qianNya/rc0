# 10 — 迁移计划

> 进度表：[refactor/README.md](refactor/README.md)

## 阶段与状态

| 阶段 | 内容 | 状态 |
|---|---|---|
| 1 | 文档编号化 + legacy 归档 | ✅ |
| 2 | 前端媒体统一（`rc0_media`） | 🔄 |
| 3 | 编辑器解环（`rc0_feature_editor`） | 🔄 |
| 4 | Riverpod Notifier + 插件路由 | 🔄 |
| 5 | 死代码 / stub 收敛 | 🔄 |
| 6 | 后端 media facade + worker | 🔄 |
| 7 | 后端 schema 规模化 | 📋 |

## Stub 收敛策略

| Feature | 决策 |
|---|---|
| `social` | **保留** — 点赞/关注 facade，由 `user`/`screenplay` 页面消费；未来并入 `community` |
| `tasks` | **Coming soon** — 桌面端占位，合并到通知中心 |
| `messages` | **保留 stub** — 桌面消息列表占位，未来并入 `notifications` |

## 验收命令

```bash
flutter analyze
dart run tool/check_module_boundaries.dart
```

## 不回退原则

- 不恢复已删除空目录
- 不新增散落架构文档（更新 `docs/refactor/*` 或本编号系列）
- Legacy 仅存在于 `docs/archive/`
