# 角色体系 · 产品需求文档（PRD）

> 版本：v1.0 · 状态：**实施中**（D1–D10 已定稿；后端 migration + API 已落地；Flutter 主链路已接）  
> 范围：角色 Wiki / 我的角色 / Studio 绑定 / AI 一致性 / 后端持久化  
> 关联：[PRODUCT_CONCEPT.md](../design/PRODUCT_CONCEPT.md) · [UX_GUIDELINES.md](../design/UX_GUIDELINES.md) · [UI_STYLE_GUIDE.md](../design/UI_STYLE_GUIDE.md) · [全栈 PRD](PRD.md) · [TECHNICAL_DESIGN.md](TECHNICAL_DESIGN.md) · [SHELL_NAV_PRD.md](SHELL_NAV_PRD.md) · [SCREENPLAY_TEMPLATE_PRD.md](SCREENPLAY_TEMPLATE_PRD.md)  
> 仓库：Flutter `flutter_application_1` · Rust `rc0-rust`  
> 实现锚点：`lib/features/character/*` · `CharacterPickerPort` / `CharacterBindingPort` · `sp_frame.acgn_character_id` · `acgn_character` · `acgn_image_character`

---

## 0. 你改 PRD 时优先拍板的决策（默认已填）

| # | 决策点 | 本稿默认 | 你可改成 |
|---|---|---|---|
| D1 | 角色是什么 | **可复用演员（Cast）**：一次创建、多剧本/多 Frame 调度；不是单图附件 | 仅 Wiki 百科条目 / 仅生成 LoRA 配置 |
| D2 | 视觉一致性单位 | **角色本体 + 服装变体（Costume）**；Frame 绑定「角色 + 可选服装」 | 仅角色本体 / 服装即独立角色 |
| D3 | 道具归属 | **道具可挂角色或挂服装**；Frame 可再选 0–N 道具 | 仅挂角色 / 仅挂 Frame |
| D4 | Tag 与别名 | **正交**：`aliases`=称呼检索；`tags`=可筛选分类体系 | 全部塞进 aliases |
| D5 | 风格（Style） | 角色级默认风格 + Frame 可覆盖；**必须进入 AI Prompt 合成** | 仅 UI 展示 / 仅生成页临时选 |
| D6 | 适合场景 | **软关联**（推荐/筛选，不强制）；可双向：角色→场景、场景→角色 | 硬约束必须同场 / 不做 |
| D7 | 姿势（Pose） | **二期**：先 Costume + Ref 图；Pose 作为服装下可选姿态节点 | 一期就做独立 Pose 库 |
| D8 | 剧本卡司表 | **服务端权威**：`sp_screenplay_character`（或等价）；废弃仅本地 `linked_characters` | 继续只写树 JSON |
| D9 | 图片关系 | 统一走 **media `ImageRef` + `acgn_image_character.relation_type`**；封面/设定图/服装图分类型 | 继续 `cover_url` 字符串 + 本地 SharedPreferences |
| D10 | AI 落点 | `AiPromptBuilder` **必须注入** 角色名/外观/服装/风格/参考图策略；生成结果可回链角色 | 继续忽略角色字段 |

> 改完上表后，下文「目标模型 / 目标链路」以你的选择为准重构。

---

## 1. 背景与问题

### 1.1 产品心智（应对齐）

来自 [PRODUCT_CONCEPT](../design/PRODUCT_CONCEPT.md)：

- **资产是可复用的「演员与布景」**：角色 Wiki 像片场卡司，被调度进任意 Frame。
- **创作飞轮**：角色一次创建 → 多剧本复用 → 生成图沉淀 → 再被 Fork/分享。
- **AI 打样**：Prompt 应由 **角色 + 场景 + 动作 + 光 + 镜头** 结构化合成。
- **调度心智**：Picker Sheet 选角，不离开 Studio 上下文。

Shell 上角色挂在 L1 **资产** 下的 L2（角色 Wiki / 我的角色），见 [SHELL_NAV_PRD](SHELL_NAV_PRD.md)。

### 1.2 现状一句话

**后端：薄 Wiki 表** `acgn_character`（文本档案 + `work_id` + `cover_url`）+ Frame 上的 `acgn_character_id`。  
**前端：详情页「服装 / 姿势 / 作品」多为本地启发式 mock；封面与参考图只进 SharedPreferences；AI Prompt 完全不注入角色。**  
结果：产品说「演员」，实现是「带简介的名字」；视觉一致性无法跨剧本、跨设备成立。

### 1.3 核心痛点

| 编号 | 痛点 | 证据 |
|---|---|---|
| C1 | **身份不完整** | 有 name/summary/appearance；无服务端设定图集；`avatar_image_id` 前端未映射 |
| C2 | **服装是假数据** | `CharacterCostumeItem` 硬编码「常服/礼服…」；无表、无 Frame 绑定 |
| C3 | **无道具模型** | 全栈零字段 |
| C4 | **风格不落库** | `CharacterAiPage` 风格 chip 只拼进创建页 summary 文案 |
| C5 | **Tag 与别名混用** | 分类/标签折进 `aliases`；详情 Tag 靠启发式上色 |
| C6 | **无适合场景** | 与 Scene Wiki 无关联；`sceneCount` 可伪造 |
| C7 | **卡司表仅本地** | `linked_characters` 写在树 JSON；后端无表；跨端丢卡司 |
| C8 | **AI 断链** | `AiPromptBuilder` 不用 characterId/Name/Note/appearance |
| C9 | **图链未用** | `acgn_image_character` API 存在；Flutter 无 client、无 UI |
| C10 | **OpenAPI 缺口** | `openapi.yaml` 无 `/characters`；`SpFrame` 未文档化 `acgn_character_id` |

---

## 2. 现状模型（As-Is）

### 2.1 后端实体（权威）

表：`acgn_character`

| 字段 | 含义 |
|---|---|
| `id` / `work_id` | 主键；`0`=独立 OC，否则属 IP |
| `name` / `name_orig` / `slug` | 显示名 / 原名 / slug |
| `gender` | 0 未知 · 1 男 · 2 女 · 3 其他 |
| `summary` / `appearance` / `personality` | 简介 / 外观文案 / 性格 |
| `cover_url` | 封面 URL 字符串（非 ImageRef） |
| `avatar_image_id` | 可选 `acgn_image.id`（App 未用） |
| `aliases` | JSONB 称呼数组（兼作伪 Tag） |

表：`acgn_image_character` — 图↔角色 M:N，`relation_type` 未定义语义。  
表：`sp_frame.acgn_character_id` — Frame 绑定；`extra_params.character_name` / `character_note` / `pose_id`。

**不存在：** costume / prop / style / tag / scene_affinity / screenplay_cast 表。

### 2.2 前端实体

| 层 | 内容 | 真假 |
|---|---|---|
| `CharacterEntry` | 与 API 对齐的薄档案 | 真 |
| `CharacterLocalStore` | 本地封面/参考图/收藏 | 真（仅本机） |
| `CharacterDetailSnapshot` | 服装/姿势/统计/作品 Tab | **多为合成** |
| `FrameDraft` | `characterId` / `Name` / `Note` / `poseId` | 真（树内） |
| `ScreenplayCharacterLink` | `{id,name}` 卡司 | 真（仅本地树） |

### 2.3 关键链路（As-Is）

```text
Wiki 创建角色（文本） → Studio Picker 绑 Frame.acgn_character_id
                  → 详情「服装/姿势」展示假数据
                  → AI 生成忽略角色
                  → 跨设备无参考图、无卡司同步
```

---

## 3. 目标心智与信息架构

### 3.1 一句话

**角色 = 可调度的演员档案**：稳定身份 + 可变外观（服装）+ 可携带道具 + 可检索标签 + 推荐场景 + 可注入 AI 的视觉风格。

### 3.2 对象层级（目标）

```text
Character（演员本体）
├── Identity        名 / 别名 / 性别 / 简介 / 性格 / 外观文案 / IP(work)
├── Visual          封面 · 头像 · 设定参考图集（ImageRef）
├── Style           默认视觉风格（token / 描述 / 可选模型侧写）
├── Tags            分类标签（与 aliases 正交）
├── Costumes[]      服装变体（各有封面/参考图/备注）
│   └── Props[]     可选：该服装默认携带的道具
├── Props[]         角色级道具（不绑特定服装）
├── SceneAffinities[]  适合的场景（软推荐）
└── Poses[]         （D7 二期）姿态节点，挂在 Costume 下

ScreenplayCast[]    本剧卡司（角色引用 + 默认服装）
FrameBinding        character_id + costume_id? + prop_ids[] + character_note?
```

### 3.3 与剧本树的关系

| 层级 | 角色相关职责 |
|---|---|
| Screenplay | 卡司表：本剧会出现哪些演员（及默认服装） |
| Scene | 可提示「本场推荐角色」（来自 SceneAffinity 反查，非强制） |
| Frame | **唯一强制绑定点**：本镜谁出场、穿哪套、带什么、外观覆写 note |

符合 PRODUCT_CONCEPT：**一切能力最终落在 Frame**。

### 3.4 导航与页面（目标）

| 层级 | 路由 / 入口 | 心智 |
|---|---|---|
| L2 | `/character` 角色 Wiki | 浏览 / 检索演员 |
| L2 | `/my-characters` | 我的 OC / 收藏 / 下载（下载二期） |
| L3 | `/character/:id` | 沉浸详情：资料 / 服装 / 道具 / 场景 / 作品 |
| L3 | 创建 / 编辑 | 构建档案（非浏览） |
| L5 | Character Picker Sheet | 调度：选角（可展开选服装） |
| Studio | 卡司区 + Frame Inspector | 构建：绑角 / 换装 / 写 note |

详情 Tab 目标收敛（替换现 mock）：

| Tab | 内容 |
|---|---|
| 资料 | 身份、风格、Tag、参考图 |
| 服装 | Costume 网格；点进变体详情 |
| 道具 | 角色级 + 各服装默认道具 |
| 场景 | 适合场景列表（链到 Scene Wiki） |
| 作品 | 使用该角色的剧本/模板（服务端查询） |
| 姿势 | D7 二期；一期可隐藏或「即将推出」 |

---

## 4. 领域模型（To-Be）

### 4.1 Character（演员本体）

| 字段 | 类型 | 说明 |
|---|---|---|
| `id` | int64 | |
| `work_id` | int64 | `0`=独立 OC |
| `name` / `name_orig` / `slug` | string | |
| `gender` | smallint | 同现网 |
| `summary` / `appearance` / `personality` | text | appearance 为**默认外观文案**（无服装时的 AI 底稿） |
| `cover` / `avatar` | ImageRef? | 取代裸 `cover_url`（迁移期可双写） |
| `style` | CharacterStyle | 见 4.5 |
| `aliases` | string[] | 仅称呼 |
| `tags` | TagRef[] | 见 4.4 |
| `visibility` | enum | 私密 / 未列出 / 公开（与剧本 visibility 语义对齐，可简化一期仅私密+公开） |
| `sort` | int | |
| audit | creator… | 同现网；编辑权=创建者（一期） |

### 4.2 Costume（服装变体）

| 字段 | 类型 | 说明 |
|---|---|---|
| `id` | int64 | |
| `character_id` | int64 | |
| `name` | string | 如「常服」「校服」「战斗装」 |
| `slug` | string | 角色内唯一 |
| `description` | text | 服装外观补充（优先于角色 appearance 注入 Prompt） |
| `cover` | ImageRef? | |
| `reference_images` | ImageRef[] | 该服装设定图 |
| `is_default` | bool | 卡司/绑定时默认选中 |
| `sort` | int | |
| `tags` | TagRef[] | 可选，如「正装」「夏」 |

**规则：**

- 每个角色至少隐式拥有一个「默认外观」：若无 Costume 行，用角色 `appearance` + 封面；创建第一套服装时可标 `is_default`。
- Frame 未选 `costume_id` 时用默认服装。
- 删除默认服装前必须指定新默认（或回退到角色本体）。

### 4.3 Prop（道具）

| 字段 | 类型 | 说明 |
|---|---|---|
| `id` | int64 | |
| `owner_type` | enum | `character` \| `costume` |
| `owner_id` | int64 | |
| `name` | string | 如「红伞」「武士刀」 |
| `description` | text | |
| `cover` | ImageRef? | |
| `sort` | int | |

Frame 绑定：`prop_ids: int64[]`（可空）。  
Prompt：道具名 + 短描述追加到角色段。

### 4.4 Tag（标签体系）

| 字段 | 类型 | 说明 |
|---|---|---|
| `id` | int64 | |
| `namespace` | string | 如 `character` / `costume` / `scene` |
| `name` | string | |
| `slug` | string | namespace 内唯一 |
| `color` | string? | 可选展示色（走 token，禁止业务硬编码） |

角色：`character_tag(character_id, tag_id)`。  
**禁止**再把分类写进 `aliases`。表单「分类」→ Tag；「别名」→ aliases。

一期可用种子 Tag（对齐现 `AppCatalog.characterCategoryChips`），并支持用户自定义（挂在 `namespace=character`）。

### 4.5 Style（视觉风格）

| 字段 | 类型 | 说明 |
|---|---|---|
| `preset_key` | string? | 如 `anime_cel` / `photoreal` / `ink`（对齐/演进 `characterAiStyles`） |
| `label` | string | 展示名 |
| `prompt_fragment` | string | 注入 AI 的风格短语 |
| `negative_fragment` | string? | 可选 |
| `model_hint` | string? | 二期：LoRA / 模型侧写 ID |

存储：角色表 JSON 列 `style_json` 或侧表；Frame 可 `style_override`（二期）。

### 4.6 Scene Affinity（适合场景）

| 字段 | 类型 | 说明 |
|---|---|---|
| `character_id` | int64 | |
| `scene_id` | int64 | Scene Wiki 条目（非剧本树 Scene 节点） |
| `weight` | int | 默认 1；用于排序 |
| `note` | string? | 「适合夜景雨巷」 |

**软关联：** Picker / 详情推荐；不阻止用户把角色绑到任意 Frame。

### 4.7 Screenplay Cast（剧卡司）

| 字段 | 类型 | 说明 |
|---|---|---|
| `screenplay_id` | int64 | |
| `character_id` | int64 | |
| `default_costume_id` | int64? | |
| `billing_name` | string? | 本剧显示名覆写 |
| `sort` | int | |

替代仅本地的 `linked_characters`。同步策略：编辑器改卡司 → API upsert；打开剧本 hydrate 卡司。

### 4.8 Frame Binding（分镜绑定）

| 字段 | 存哪 | 说明 |
|---|---|---|
| `acgn_character_id` | 列（已有） | 必选（若本镜有人） |
| `costume_id` | `extra_params` 或新列 | 可选 |
| `prop_ids` | `extra_params` JSON 数组 | 可选 |
| `character_name` | `extra_params` | 冗余展示/离线 |
| `character_note` | `extra_params` | 本镜外观覆写（最高优先） |
| `pose_id` | `extra_params` | D7 |

**Prompt 合成优先级（高→低）：**  
`character_note` → Costume.description → Character.appearance → Style.prompt_fragment → Prop 描述。

### 4.9 图片关系类型（`relation_type` 定稿）

| 值 | 语义 |
|---|---|
| 0 | 未分类 / 通用关联 |
| 1 | 封面 `cover` |
| 2 | 头像 `avatar` |
| 3 | 设定参考图 `reference` |
| 4 | 服装封面 |
| 5 | 服装参考图 |
| 6 | 道具图 |
| 7 | 生成结果回链（打样归档） |

创建/编辑必须走 `AppMediaUploadService` → ImageRef，再 link；禁止只写本地 path 当权威。

---

## 5. 用户故事

1. **作为概念设计师**，我创建 OC：姓名、别名、Tag、默认风格、上传三视图设定图，并添加「常服 / 礼服」两套服装。  
2. **作为分镜师**，我在 Studio 卡司中加入该角色；在 Frame 上选「礼服」并加道具「红伞」，生成打样时 Prompt 自动带上外观与风格。  
3. **作为摄影师**，我从角色详情「适合场景」跳到夜景雨巷场景 Wiki，再带回 Studio 绑定。  
4. **作为回流用户**，我换设备登录后仍能看到参考图、服装与剧卡司，而不是空壳名字。  
5. **作为浏览者**，我在角色 Wiki 按 Tag/风格筛选，打开详情看到真实服装网格而非占位。  
6. **作为 IP 运营**，我在 `work_id` 下维护官方角色，创作者可引用但不可改官方档案（一期可先：仅创建者可改；二期权限）。

---

## 6. 核心旅程

### 6.1 创建完整角色

```text
资产 → 角色 → 新建
  → 身份（名/别名/性别/简介/性格/外观文案）
  → Tag + Style
  → 上传封面 + 参考图（media）
  → 添加 Costume（可稍后）
  → 可选：关联适合场景、道具
  → 保存 → 详情页可调度
```

### 6.2 Studio 调度

```text
打开剧本 → 卡司「添加角色」→ Picker（搜索/Tag）
  → 可选展开选默认服装
  → 写入 ScreenplayCast
选中 Frame → Inspector「角色」
  → 选卡司角色 / 换装 / 勾选道具 / 写 note
  → 保存树（含 costume_id / prop_ids）
AI 打样 → AiPromptBuilder 注入角色段 → 结果可 link relation_type=7
```

### 6.3 从角色发起创作

```text
角色详情 → 开始创作
  → 新建剧本 + Cast 预填 + 首个空 Frame 绑定默认服装
```

（保留现 `studioEditorCreateWithCharacter` 行为并升级为带 `costume_id`。）

---

## 7. API 与契约（目标）

> 实施时以 `rc0-rust` handler + 更新 `openapi.yaml` 为准；下列为产品契约。

### 7.1 Character CRUD（演进现网）

| Method | Path | 说明 |
|---|---|---|
| GET | `/characters` | `q`, `work_id`, `tag_id`, `style`, `page`… |
| POST | `/characters` | 写身份 + style + tags；封面用 image id |
| GET | `/characters/{id}` | 含 style、tags、默认服装摘要、统计 |
| PUT/DELETE | `/characters/{id}` | 创建者 |

### 7.2 Costume / Prop / Affinity

| Method | Path | 说明 |
|---|---|---|
| GET/POST | `/characters/{id}/costumes` | 列表/创建 |
| PUT/DELETE | `/characters/{id}/costumes/{costume_id}` | |
| POST | `/characters/{id}/costumes/{id}/set-default` | |
| GET/POST | `/characters/{id}/props` | 角色级道具 |
| GET/POST | `/costumes/{id}/props` | 服装级道具 |
| GET/PUT | `/characters/{id}/scene-affinities` | 适合场景 |

### 7.3 Tags

| Method | Path | 说明 |
|---|---|---|
| GET | `/tags?namespace=character` | |
| POST | `/tags` | 自定义（鉴权） |
| PUT | `/characters/{id}/tags` | 全量或增量绑定 |

### 7.4 Cast & 使用查询

| Method | Path | 说明 |
|---|---|---|
| GET/PUT | `/screenplays/{id}/cast` | 剧卡司权威 |
| GET | `/characters/{id}/screenplays` | 作品 Tab 真数据 |

### 7.5 Images（沿用并文档化）

| Method | Path | 说明 |
|---|---|---|
| GET/POST/DELETE | `/images/{id}/characters` | `relation_type` 按 §4.9 |

### 7.6 Frame 载荷补充

`SpFrame` / tree JSON 明确：

```json
{
  "acgn_character_id": 12,
  "extra_params": {
    "character_name": "林夏",
    "character_note": "被雨打湿的刘海",
    "costume_id": 3,
    "prop_ids": [9, 11],
    "pose_id": null
  }
}
```

OpenAPI 必须补齐 Character 与上述字段（关闭 C10）。

---

## 8. 前端改造要点

| 模块 | 要求 |
|---|---|
| `CharacterEntry` | 扩展 style、tags、defaultCostume、ImageRef 封面 |
| 删除/降级 mock | `buildCharacterDetailSnapshot` 服装/姿势改为 API；统计禁伪造 |
| `CharacterLocalStore` | 迁移期缓存；权威改服务端后只作离线草稿 |
| `CharacterFormSections` | 分类→Tag；别名单独；封面/参考图走 `AppMediaUploadService` |
| 详情 Tabs | 资料/服装/道具/场景/作品；（姿势二期） |
| Picker | 支持搜索 Tag；选角后可选服装 |
| `FrameDraft` + mapper | `costumeId` / `propIds` |
| `AiPromptBuilder` | 注入角色段（D10） |
| `CharacterAiPage` | 真生成或降级为「从风格预填创建表」；禁止假进度条糊弄 |
| Ports | `CharacterRef` 含 `defaultCostumeId`、`appearance`、`styleLabel`；补齐 `createAndApplyCharacter` |
| PC Hub | 资产→角色走 `DesktopHubHeader`（已有脚手架） |

模块边界：角色实现不进 `studio` 内部；Studio 只依赖 `rc0_core` ports（TECHNICAL_DESIGN）。

---

## 9. UI / UX 规范（角色域）

- 遵守 Liquid Glass：内容（设定图/服装图）为 Level 0；筛选/Tab 为浮动玻璃 Level 1。  
- 详情用 `GlassHeroPage` 思路：封面沉浸 + 玻璃信息卡。  
- Picker 用 `GlassSheet`；选服装为二级展开，避免另开全屏打断调度心智。  
- 空态：无服装时引导「添加第一套服装」；无参考图时引导上传三视图。  
- 禁止详情再展示无法点击的假「礼服」卡片。

---

## 10. 非目标（本期不做）

- 完整 3D 角色绑定（`character_module_facade` 仍服务动作模型，不与 Wiki 强绑）。  
- 团队协作编辑权限矩阵（二期）。  
- 独立 Pose 库与动作捕捉（D7）。  
- 角色市场付费 / 下载商店（「下载角色」Tab 可继续占位）。  
- 用角色替换 Scene Wiki 或设备柜。

---

## 11. 里程碑与验收

### M1 — 真档案（身份 + 图 + Tag + Style）

- [x] 创建/编辑上传封面与参考图并持久化（ImageRef + relation_type）  
- [x] Tag 与 aliases 分离；列表可按 Tag 筛  
- [x] Style 落库并在详情展示  
- [x] OpenAPI 出现 Character schema  

### M2 — 服装与道具

- [x] Costume CRUD；默认服装；详情服装 Tab 为真数据  
- [x] Prop CRUD（角色/服装）；Frame 可选 prop_ids  
- [x] Picker / Inspector 支持选服装  

### M3 — 卡司与 AI

- [x] `GET/PUT /screenplays/{id}/cast`；编辑器读写服务端卡司（best-effort hydrate/sync）  
- [x] `AiPromptBuilder` 注入角色/服装/风格/道具/note  
- [x] 生成结果可回链角色（relation_type=7 API 已备；UI 回链随 generation 接入）  

### M4 — 场景亲和与作品图

- [x] Scene affinity CRUD + 详情「场景」Tab  
- [x] `GET /characters/{id}/screenplays` 驱动「作品」Tab  
- [x] 清除详情统计造假（改为 API 真数据）  

### 成功指标（产品）

| 指标 | 目标（上线 4 周） |
|---|---|
| 有 ≥1 参考图的角色占比 | ≥ 40%（活跃创建） |
| 有 ≥1 服装的角色占比 | ≥ 25% |
| 含角色绑定的 Frame 生成次数占比 | 上升且 Prompt 含角色段 |
| 跨设备打开角色详情参考图可见率 | ≈ 100%（登录用户） |

---

## 12. 风险与依赖

| 风险 | 缓解 |
|---|---|
| 现详情 UI 依赖 mock，切换真数据会「变空」 | M1 先图+资料；服装空态引导创建 |
| `cover_url` 与 ImageRef 双轨 | 迁移期双写；读取优先 ImageRef |
| Frame `extra_params` 膨胀 | costume/prop 先放 extra；稳定后加列 |
| AI 无真后端 | 仍先做 Prompt 合成与字段就绪，对接 generation worker |
| handler 无 service 层 | 新表 CRUD 按 TECHNICAL_DESIGN 走 service，禁止 handler 直 SQL 扩散 |

依赖：`rc0_media` / `AppMediaUploadService`、Scene Wiki id 稳定、Screenplay 树保存链路、OpenAPI 更新流程。

---

## 13. 决策落地对照（实施清单）

| 决策 | 落地物 |
|---|---|
| D1 Cast | 文档+导航文案统一「角色/演员」；卡司表 |
| D2 Costume | `acgn_character_costume` + Frame `costume_id` |
| D3 Prop | `acgn_character_prop` + Frame `prop_ids` |
| D4 Tag | `acgn_tag` + `acgn_character_tag`；aliases 纯化 |
| D5 Style | `style_json` + AiPromptBuilder |
| D6 Affinity | `acgn_character_scene` |
| D7 Pose | 二期；隐藏或 ComingSoon |
| D8 Cast 服务端 | `sp_screenplay_character` |
| D9 ImageRef | relation_type 枚举 + Flutter media 上传 |
| D10 AI | `ai_prompt_builder.dart` 角色段 |

---

## 14. 附录：与现文件映射

| 现文件 | 处置 |
|---|---|
| `character_entry.dart` | 扩展字段 |
| `character_detail_data.dart` | 改为 API DTO 组装；删除假服装/姿势生成 |
| `character_local_store.dart` | 降级缓存 |
| `character_form_sections.dart` | Tag/上传改造 |
| `character_costumes_tab.dart` | 接 Costume API |
| `character_poses_tab.dart` | 二期或占位 |
| `character_ai_page.dart` | 真能力或诚实降级 |
| `ai_prompt_builder.dart` | 注入角色 |
| `screenplay_draft.dart` / mapper | costume/prop |
| `character.rs`（Rust） | 扩表 + service 层 |
| `openapi.yaml` | 补 Character 与 Frame 字段 |

---

**文档维护：** 角色域需求变更优先改本稿与决策表，再改代码；勿再新增平行「角色设计」散落文档。
