# rc0 全栈重构 · 产品需求文档（PRD）

> 版本：v1.0 · 状态：草案（待评审）
> 关联：[技术方案文档](TECHNICAL_DESIGN.md) · [重构计划](../../.cursor/plans) · 后端仓库 `C:/Users/qianlNya/RustroverProjects/rc0-rust`
> 说明：本 PRD 基于对两个真实仓库（Flutter 客户端 + Rust Axum 后端）的完整代码审阅编写，非推断。

---

## 1. 背景与产品定位

### 1.1 产品定位
rc0 是一套**面向摄影师、导演、设计师的视觉创作操作系统**。核心心智：以**剧本（Screenplay）**为主干，围绕它组织角色、场景、动作、打光、摄影等可复用视觉资产，并通过 AI 生成能力把创意落成画面，最终沉淀到图库与社区。

### 1.2 现有技术栈（真实）
- 前端：Flutter（单仓 900 文件，go_router，singleton `ChangeNotifier` 状态管理，无 codegen）。
- 后端：Rust Axum 0.8 单 crate 单体（`handler → service → repository → model` 分层，约 104 路由，33 张表）。
- 存储：PostgreSQL（业务数据） · Redis（当前仅存 refresh token） · MinIO（对象存储，MD5 内容寻址）。

### 1.3 本次重构的动机（当前六大问题）
| 编号 | 问题 | 真实根因（代码级） |
|---|---|---|
| P1 | 图片资产管理复杂 | 前端约 9 种图片引用方案并存、3–4 套解析逻辑、6 条上传路径；后端 frame 三重存储字段（`image_url`/`thumbnail_url`/`acgn_image_id`/`acgn_image_file_id`）同源 |
| P2 | 模块耦合增加 | 前端 `studio ↔ upload ↔ screenplay` 双向环、`frame_inspector_panel` 依赖 6 个 feature；后端 `service/screenplay.rs` 837 行 god module 吸收图片职责 |
| P3 | AI 图片未来数量爆炸 | 后端请求内同步编码 3 变体、进程内分析无队列、MinIO 扁平 key、无表分区、pg 连接池 10、无 AI 生成元数据 |
| P4 | Flutter 页面越来越多 | 28 个 feature，含 5 个空目录与 3 个 stub；路由 66 条散落含大量 legacy redirect |
| P5 | 数据模型需要重新规划 | 图片引用、剧本树、AI 生成缺乏统一模型；前后端各写一套图片字段 |
| P6 | 需要支持未来插件化扩展 | 无模块契约、无 DI、feature 直接互相 import 实现 |

### 1.4 目标（本次重构要达成）
- **G1 统一图片资产模型**：端到端单一 `ImageRef`，一处解析、一处显示、一处上传。
- **G2 模块解耦**：前端 feature 仅通过契约/端口交互；后端拆 god module、补齐分层。
- **G3 面向规模**：AI 图片走异步管线 + 分区 + 分片存储，支撑数量级增长。
- **G4 页面与目录治理**：清理死代码，收敛路由与导航。
- **G5 数据模型重规划**：统一剧本树与媒体/AI 生成数据结构。
- **G6 插件化就绪**：模块以可注册单元形式装配，新增能力不改内核。

### 1.5 非目标（本次不做）
- 不做后端微服务化拆分（保持单体部署 + 单个异步 worker）。
- 不更换核心技术栈（仍是 Flutter / Rust Axum / PG / Redis / MinIO）。
- 不改变 REST envelope `{code,message,data}` 与既有路径语义（保证前后端可分别推进）。
- 不重做 3D Runtime（`runtime_3d` 三层桥隔离良好，保留）。

---

## 2. 目标用户与核心场景

### 2.1 用户画像
- **导演 / 分镜师**：搭建剧本结构（幕/场/镜），设计分镜画面与镜头语言。
- **摄影师**：复用与管理摄影/打光/镜头预设，追求视觉一致性。
- **设计师 / 概念创作者**：生成与沉淀角色、场景视觉资产，构建可检索资产库。

### 2.2 核心用户旅程
1. 发现（Wiki/社区）→ 阅读剧本与资产。
2. 创作（Studio）→ 编辑剧本树 → 在 Frame 上绑定角色/场景/预设 → AI 生成画面。
3. 沉淀（图库/个人中心）→ 生成结果回看，追溯到剧本/场景/角色。
4. 分享（社区）→ 点赞、收藏、关注、Fork 模板。

### 2.3 关键实体
`Screenplay → Act → Scene → Frame`（主干）；`Character / Scene(资产) / Preset(动作·打光·摄影) / Image / GenerationJob / User`（能力与资产层）。

---

## 3. 功能需求（按模块）

> 标注：[保留]=现有能力保留；[重构]=能力不变但实现重做；[新增]=本次新增；[收敛]=合并/下线。

### 3.1 用户系统 [保留 + 重构]
- 登录/注册/刷新令牌（后端 JWT + Argon2 + Redis refresh，已实现，保留）。
- 用户资料、关注/取关、我的作品/喜欢/收藏（保留）。
- [重构] 前端 `AuthRepository` 迁移到 Riverpod provider；401 统一处理保留。
- [收敛] `social` 数据模块折入 user 域。

### 3.2 剧本系统 [保留 + 重构]
- 剧本树 CRUD、分步节点 CRUD、发布、封面、Fork 模板（后端 `sp_*` 表 + fork 单事务，保留）。
- 本地草稿、离线编辑、远端同步、导出（前端 `screenplay/data`，保留语义）。
- [重构] `screenplay` 收敛为纯数据/领域层，不再持有编辑器 UI。
- [新增] 阅读态场景/分镜页（`screenplay-scene-read` / `screenplay-frame-read`，当前为 coming_soon）。

### 3.3 分镜系统（Frame）[保留 + 重构]
- Frame 承载对白、动作说明、镜头参数、绑定图片/角色/预设（后端 `sp_frame`，保留）。
- [重构] 编辑器统一到新的 `rc0_feature_editor`（吸收现 `upload` 57 个 UI 文件 + `studio` 编排）。
- [重构] `frame_inspector_panel` 对角色/场景/打光/摄影/预设的依赖改为端口注入。

### 3.4 场景库 / 动作库 / ACG 图片库 [保留 + 重构]
- 场景资产 CRUD + 地理信息、动作/打光/摄影预设、图库作品与图片（后端 `acgn_*`、`sp_cine_*`，保留）。
- [重构] 前端 character/scene/action/lighting/camera 统一为可插拔 Wiki 模块，共享设计系统 chrome。
- [收敛] 与创作链路的关联改为通过 ID/DTO/端口传递，去除跨 feature presentation import。

### 3.5 AI 生成图片 [重构 + 新增]（P3 核心）
- [保留] 生成结果沉淀为图库图片，可关联剧本/场景/角色/分镜。
- [新增] 生成任务元数据：prompt / model / seed / 参数 / 状态 / 成本（后端新增侧表 `acgn_generation_job`）。
- [重构] 生成与图片处理走**异步队列 + 独立 worker**，不阻塞请求；结果异步回写。
- 需求：单用户可产生大量生成图，系统需在图片量级增长下保持列表、检索、存储稳定。

### 3.6 社区 Feed / 收藏点赞 [保留 + 重构]
- Feed、点赞、收藏、评论（含嵌套）、浏览日志、热度（后端 `sp_like/favorite/comment/view_log`，保留）。
- [已完成] 模板浏览合并至 `/discovery?section=template`（`TemplateMarketRepository` + `TemplateMarketBody`）；`/community` 重定向兼容旧链接。
- [后续] `/community` 在后端动态/关注流 API 就绪后重建为发布/互动社交 Feed（`rc0_feature_community`）。
- [重构] 前端 `explore/favorites` 通过统一 Repository/provider 读取聚合数据。
- [新增] 后端落地 Redis 热点 feed/screenplay 缓存（`docs/ARCHITECTURE.md` 已规划未实现）。

### 3.7 搜索系统 [保留 + 重构]
- 剧本全文检索（后端 `sp_screenplay.search_vector` GIN 索引，保留）。
- [重构] 前端搜索入口统一；[新增] 图片/资产检索随 AI 图库扩展评估独立索引。

### 3.8 图片资产管理 [重构]（P1 核心）
- [重构] 端到端统一 `ImageRef`：`{ imageId, fileId, remoteUrl?, localPath? }`。
- 前端：单一 `ImageResolver`、单一 `Rc0Image` 显示组件、单一 `MediaUploadService`。
- 后端：`MediaService` 统一变体生成/内容寻址/presign/去重/GC；MinIO key 分片。

---

## 4. 文档治理需求

### 4.1 权威文档入口
- `docs/README.md` 是前端仓库文档入口，必须维护“权威文档 / 历史参考文档”分级。
- 本次全栈重构的权威文档为 `docs/refactor/PRD.md` 与 `docs/refactor/TECHNICAL_DESIGN.md`。
- 后端 API 契约以 `C:/Users/qianlNya/RustroverProjects/rc0-rust/docs/openapi.yaml` 与真实 handler/service 代码为准，前端历史 API 表仅作覆盖情况参考。

### 4.2 历史文档清理
- 不再新增同主题散落文档；新增重构内容应更新 `docs/refactor/` 或 `docs/README.md`。
- 旧架构、剧本树、API、Runtime 文档进入 legacy/reference 状态；后续阶段 0 可合并为编号化文档。
- `UI_REFACTOR_TRACKER.md` 标记为 archive-candidate，不作为新任务来源。

---

## 5. 非功能需求

### 5.1 可扩展性 / 规模（P3）
- 图片处理与 AI 生成从请求路径解耦，支持水平扩展 worker。
- `acgn_image` / `acgn_image_file` / `acgn_image_analysis` 按时间分区，支撑图片量级增长。
- MinIO 对象 key 分片前缀（`{ab}/{cd}/{md5}.ext`），避免扁平命名空间在海量对象下退化。
- 数据库连接池上限可配置并经压测校准（现硬编码 10）。

### 5.2 性能
- `POST /images` 请求内不再做同步多变体编码，响应时间与并发上传解耦。
- 图片列表消除 N+1（批量加载 files）。
- 客户端图片显示统一走磁盘缓存 + WebP 处理，禁用裸 `Image.network`。

### 5.3 可维护性 / 解耦（P2、P6）
- 前端依赖铁律：feature 之间禁止互相 import 实现；仅经 `rc0_core` 契约/端口。
- 后端：handler 不直连 repository；跨域仅经 service；repository 不跨域。
- 两者以 CI 校验依赖方向。

### 5.4 兼容性 / 迁移安全
- REST 契约与路径不变；前后端可独立发布，仅 `ImageRef` 规范化需一个协同窗口。
- 旧本地草稿（SharedPreferences `rc0_screenplay_trees`）经迁移脚本转换。
- 存量 MinIO 对象采用双读兼容或后台 rekey，不影响线上。

### 5.5 可观测性 / 安全
- 保留后端 `sys_log` 审计中间件、trace_id、tracing JSON 日志。
- 保留 JWT/Argon2/Casbin；评估是否为共享工作区引入策略级访问控制。

---

## 6. 范围与里程碑

| 阶段 | 目标 | 关键交付 | 对应问题 |
|---|---|---|---|
| 阶段 0 | 基座 | 两仓文档重组；前端 melos 骨架 + 后端 workspace 骨架；依赖/分层 CI | P4/P6 |
| 阶段 1 | 图片资产统一（优先） | 前端 `ImageRef`/resolver/显示/上传；后端 `media` crate + 队列 + worker | P1 |
| 阶段 2 | 编辑器解环 | 前端 `rc0_feature_editor` + Riverpod（编辑器域）；后端拆 `service/screenplay.rs` + 补 service 层 | P2 |
| 阶段 3 | 规模化 + 迁移 | 后端图片分区 + key 分片 + GC + AI 生成侧表；前端 Wiki/图库/社区/用户迁移 + 死代码清理 | P3/P4/P5 |
| 阶段 4 | 插件化 + 收口 | 前端 `FeatureModule` 装配；后端 Redis 缓存/限流；契约文档收口 | P6 |

每阶段可独立交付、独立回滚。

---

## 7. 成功指标（验收）
- **P1**：图片引用方案从 ~9 种收敛为 1 种 `ImageRef`；显示/上传/解析各仅 1 条实现路径。
- **P2**：前端 feature 间实现级 import = 0（CI 校验）；后端无 handler 直连 repository；`service/screenplay.rs` < 300 行。
- **P3**：`POST /images` p95 响应不随变体数增长；图片处理可通过增加 worker 线性扩容；单表分区后大表查询稳定。
- **P4**：空目录/stub feature 清零；路由常量集中，legacy redirect 收敛。
- **P5**：剧本树与媒体/AI 生成模型在两仓有单一权威定义（当前为 `docs/refactor/TECHNICAL_DESIGN.md`；阶段 0 后可拆为编号化数据模型/媒体资产文档）。
- **P6**：新增一个能力 = 新增一个可注册模块，内核零改动可演示。

---

## 8. 风险与应对
| 风险 | 影响 | 应对 |
|---|---|---|
| ImageRef 规范化需前后端协同 | 发布窗口耦合 | 后端读时回填旧 URL 字段，双写过渡，兼容期后再删列 |
| 编辑器拆环回归面大 | 创作主链路 | 先建回归用例，按域分批迁移，旧模式共存过渡 |
| 图片存量数据迁移 | 线上对象/DB | 分区与 rekey 后台执行，双读兼容，可回滚 |
| 引入 worker 增加运维单元 | 部署复杂度 | 复用同一 workspace crate，单体 + 一 worker，队列可重试 |
| Riverpod 全量迁移工作量 | 排期 | 逐包迁移，与 ChangeNotifier 共存，不阻塞其他阶段 |

---

## 9. 待决策项（需产品/技术确认）
1. AI 生成的模型/供应商与成本计费口径（影响 `acgn_generation_job` 字段）。
2. 是否引入 CDN 及其回源/鉴权策略（影响 presign vs 公开 URL）。
3. 共享工作区/协作是否需要策略级权限（当前仅创建者 owner 校验）。
4. 图片检索是否需要独立搜索引擎（随 AI 图库规模评估）。
