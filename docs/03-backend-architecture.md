# 03 — 后端架构

> SSOT：[refactor/BACKEND_KICKOFF.md](refactor/BACKEND_KICKOFF.md) · OpenAPI：`rc0-rust/docs/openapi.yaml`

## 当前（单体）

```
handler/*  →  service/*  →  repository/*
                ↓
         image_processing（同步变体）
         jobs/image_analysis（tokio::spawn）
```

痛点：`service/screenplay.rs` god module；`POST /images` 请求内同步编码。

## 目标

```
rc0-api (handler) → MediaService facade → repository/image
                  → Redis Stream (media.process)
rc0-worker        → 消费队列 → 变体生成 + 分析回写
```

## 服务拆分（进行中）

| 模块 | 职责 |
|---|---|
| `screenplay` | CRUD、engagement、列表 |
| `screenplay_tree` | `save_tree_initial` / `save_tree_sync`、resolve |
| `screenplay_media` | presign、下载 URL、封面、分析重试 |
| `rc0-media` crate | 上传管线 facade、分片 key、GC 契约 |

## 规模化（规划）

- MinIO key：`{ab}/{cd}/{md5}.ext`
- `acgn_image*` 时间分区
- 引用计数 GC
- AI generation job 侧表
