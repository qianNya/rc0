# Gear Cabinet / Media Vault 后端接入 PRD

> 版本：2026-07-07 · 关联：[GEAR_MEDIA_CRUD_PLAN.md](GEAR_MEDIA_CRUD_PLAN.md) · [TECHNICAL_DESIGN.md](TECHNICAL_DESIGN.md)

## 1. 背景

前端已完成两套新体验：

| 模块 | 路由 | 当前数据源 |
|------|------|------------|
| **Gear Cabinet** 器材柜 | `/library` | `GearCabinetSampleData`（样例） |
| **Media Vault** 图库流 | `/gallery` | 登录后 `/images` + `/image-tags`；相册/收藏/回收站仍为 sample 或本地态 |

后端已有 **`cine-equipment`** 与 **`/images`** 域，但尚未为保险箱 UI 提供完整契约。

## 2. 产品目标

1. **器材柜**：用户浏览的机身/镜头/组合来自真实后端目录；刷新后数据一致。
2. **图库流**：用户上传的图片进入瀑布流；标签、收藏、相册、回收站可持久化。
3. **创作联动**：从创作台进入器材柜后，仍可通过 picker/setup 应用到 frame（`CineCameraSetup`）。
4. **契约先行**：OpenAPI 与 `docs/refactor/GEAR_MEDIA_CRUD_PLAN.md` 为 SSOT，再落代码。

## 3. 用户故事

### Gear Cabinet

- 作为摄影师，我希望按「灯具 / 相机 / 镜头 / 配件」房间浏览设备，以便快速找到器材。
- 作为创作者，我希望收藏机身与镜头，并在器材柜中看到收藏状态。
- 作为编剧，我希望在编辑器里打开器材柜浏览，并通过「快速选择」应用摄影机组合到画格。

### Media Vault

- 作为用户，我希望上传图片后立即在瀑布流中看到，并支持捏合调整列数。
- 作为用户，我希望给图片打标签、加入专辑、收藏或移入回收站。
- 作为用户，我希望查看图库存储用量（已用 / 总量）。

## 4. 范围

### In Scope（第一期）

- 复用 `cine-equipment` API 填充相机/镜头/组合房间。
- 复用 `/images`、`/image-tags` 作为图库主数据。
- 新增 `media-vault` 后端域：album、image state（favorite/trash）、storage metrics。
- 前端 `GearCabinetRepository` / `MediaVaultRepository` 去除 sample-only 主路径。
- OpenAPI 补齐相关 paths。

### Out of Scope（第一期）

- 多人协作共享器材柜布局。
- 灯具实体入库（`cine-equipment` 暂无 lighting 表；灯具房可暂保留样例或空态）。
- 重写 `/images` 异步 worker 管线（见 [BACKEND_KICKOFF.md](BACKEND_KICKOFF.md)）。
- Gear Cabinet 3D 物理摆放编辑（仅只读浏览 + 收藏 + setup CRUD）。

## 5. 功能需求

### 5.1 Gear Cabinet

| ID | 需求 | 优先级 |
|----|------|--------|
| GC-01 | 相机房展示 `GET /cine-equipment/bodies` | P0 |
| GC-02 | 镜头房展示 `GET /cine-equipment/lenses` | P0 |
| GC-03 | 配件/组合房展示 setups（系统 + 我的） | P0 |
| GC-04 | 收藏态与 `POST /cine-equipment/favorites/toggle` 同步 | P1 |
| GC-05 | 用户 setup CRUD（已有 API）在详情/编辑流可用 | P1 |
| GC-06 | 灯具房：样例降级或后续 `production-assets` 扩展 | P2 |
| GC-07 | 用户自定义柜/架布局持久化 | P2 |

### 5.2 Media Vault

| ID | 需求 | 优先级 |
|----|------|--------|
| MV-01 | 列表/上传走 `/images` | P0（已部分实现） |
| MV-02 | 标签走 `/image-tags` + `/images/{id}/tags` | P0（已部分实现） |
| MV-03 | 专辑 CRUD ` /media-vault/albums` | P1 |
| MV-04 | 收藏/回收站 `PATCH /media-vault/images/{id}/state` | P1 |
| MV-05 | 存储指标 `GET /media-vault/metrics` | P2 |
| MV-06 | 作品关联沿用 `/images/{id}/works` | P2 |

## 6. 非功能需求

- **性能**：器材柜首屏 < 2s（缓存 + 分页可选）；图库瀑布流滚动 60fps。
- **离线**：未登录图库展示空态 + 登录引导；器材柜可只读浏览内置 catalog 种子。
- **安全**：setup/album/state 变更需 JWT；仅 creator 可改自己的资源。
- **兼容**：保留 `EquipmentRepository` 与 `ImageGalleryRepository`，新 repository 作 facade。

## 7. 验收标准

- [ ] 登录用户打开 `/library`，相机/镜头房数据来自 API（非纯 sample）。
- [ ] 登录用户打开 `/gallery`，图片列表来自 `/images`；上传后列表刷新可见。
- [ ] 收藏机身/镜头后刷新，收藏态与后端一致。
- [ ] 专辑创建/删除/重命名有 API 且刷新后保留（P1 完成后）。
- [ ] `flutter analyze` 0 error；后端 `cargo check` 通过。
- [ ] OpenAPI 与前端 `lib/api/*` 字段一致。

## 8. 风险与缓解

| 风险 | 缓解 |
|------|------|
| Gear UI 层级（Room/Cabinet/Shelf）与扁平 API 不匹配 | 前端 mapper 按品牌/分类自动分柜；布局持久化二期再做 |
| 灯具无后端表 | 灯具房保留 sample 或显示「即将接入」空态 |
| Media Vault 收藏与社区收藏重复 | 图库 state 表独立，仅服务 vault UI |
| OpenAPI 滞后于实现 | CRUD 计划要求先更 OpenAPI 再改 handler |

## 9. 里程碑

| 阶段 | 交付 | 目标日期 |
|------|------|----------|
| M0 | 本文档 + CRUD 计划 | 2026-07-07 |
| M1 | Gear 前端 API mapper + 灯具 sample 降级 | +3d |
| M2 | Media Vault 后端 album/state 骨架 + OpenAPI | +7d |
| M3 | 前端替换 album/favorite sample；存储指标 | +10d |
| M4 | 用户布局持久化（可选） | +14d |
