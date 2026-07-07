# rc0 产品功能架构图（当前）

> Legacy：本文件记录旧产品功能架构。全栈重构请以 `docs/refactor/PRD.md` 与 `docs/refactor/TECHNICAL_DESIGN.md` 为准；文档状态见 `docs/README.md`。

> 面向当前 Flutter 客户端（`lib/features/*`）的功能架构梳理。

## 1) 功能架构总览

```mermaid
flowchart TB
  A["客户端入口\nRc0App + AppRouter"] --> B["壳层导航\nShell（底部Tab/桌面侧栏）"]

  subgraph C["内容消费域"]
    C1["探索 Explore\n推荐流/筛选/搜索"]
    C2["社区 Community\n精选与互动入口"]
    C3["详情阅读\nScreenplay/Scene/IP/Character"]
    C4["收藏 Favorites\n点赞/收藏清单"]
    C5["图库 Gallery\n图片资源浏览"]
  end

  subgraph D["创作生产域"]
    D1["创作入口\n右侧独立 rc0 小Tab"]
    D2["Studio\n剧本工作台/结构编辑"]
    D3["Upload Editor\n分镜/场景/参数编辑"]
    D4["发布与同步\nScreenplayPublishService"]
  end

  subgraph E["资产与设定域"]
    E1["角色库 Character\nCRUD/关联"]
    E2["场景库 Scene\nCRUD/关联"]
    E3["IP库 IP(Works)\nCRUD/关联"]
    E4["拍摄预设 Preset\n创建/选择/管理"]
  end

  subgraph F["用户与系统域"]
    F1["认证 Auth\n登录/注册/会话"]
    F2["个人中心 Profile/User\n资料/作品/点赞/设置"]
    F3["主题外观\nThemeModeNotifier"]
    F4["更新与系统能力\nAppUpdate/桌面窗口能力"]
  end

  B --> C
  B --> D
  B --> E
  B --> F

  C --> G["Repository 层\nChangeNotifier 单例"]
  D --> G
  E --> G
  F --> G

  G --> H["API Client 层\nlib/api/* 手写客户端"]
  G --> I["本地存储\nSharedPreferences/本地文件"]
  H --> J["rc0-rust REST API"]
```

## 2) 端内核心导航结构

```mermaid
flowchart LR
  S["Shell"] --> T1["主 TabBar\nWiki / 图库 / 通知 / 我的"]
  S --> T2["独立创作 Tab\nrc0 小胶囊入口"]
  T1 --> P1["Explore"]
  T1 --> P2["Gallery"]
  T1 --> P3["Community/消息相关入口"]
  T1 --> P4["Profile"]
  T2 --> P5["Studio / Upload 创作链路"]
```

## 3) 功能分层（代码映射）

| 层级 | 主要模块 | 代码位置 |
|---|---|---|
| 应用壳 | 路由、主题、平台壳 | `lib/app/` |
| 核心能力 | domain/network/responsive/theme/utils | `lib/core/` |
| 功能域 | `auth` `explore` `community` `favorites` `gallery` `screenplay` `studio` `upload` `character` `scene` `ip` `profile` `user` `shell` | `lib/features/` |
| 共享UI | 玻璃组件、导航组件、通用卡片/空态 | `lib/shared/widgets/` |
| API访问 | 各业务 API 客户端 + HTTP 传输层 | `lib/api/` |

## 4) 关键业务链路

1. **消费链路**：Explore/Community/Favorites/Gallery → Repository → API(`screenplays/feed/images/...`)  
2. **创作链路**：rc0 创作入口 → Studio/Upload Editor → Draft/Repository → 发布同步  
3. **资产链路**：Character/Scene/IP/Preset 管理 → 关联到分镜与图片  
4. **用户链路**：Auth → Profile/User 页 → 外观/版本/资料等设置  

## 5) 当前架构特征

- 采用 **Feature-first** 组织，页面与数据按业务拆分；
- 状态管理以 **Singleton Repository + ChangeNotifier** 为主；
- API 调用统一经 `lib/api/*/api/*-api.dart`，避免 UI 直连 HTTP；
- 移动端以 Shell 浮动导航为中心，创作入口从主 Tab 分离为独立胶囊按钮；
- 支持多端（移动/桌面/Web）自适应布局。

