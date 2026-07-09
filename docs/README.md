# rc0 文档入口

> 本目录已收敛为“权威文档 + 历史参考”的结构。新需求、重构、架构讨论优先阅读 `docs/refactor/`，旧文档仅作为现状追溯，不再作为新方案的唯一依据。

## 权威文档

| 文档 | 用途 |
|---|---|
| `00-overview.md` | 编号化文档地图与 refactor 入口 |
| `refactor/README.md` | 全栈重构文档索引与核心结论 |
| `refactor/PRD.md` | rc0 全栈重构产品需求文档 |
| `refactor/SHELL_NAV_PRD.md` | Shell 导航优化 PRD（PC 侧栏 + App 底栏） |
| `refactor/DESKTOP_WINDOW_CHROME_PRD.md` | 桌面窗口栏 PRD（拖拽 / 缩放 / 红绿灯） |
| `refactor/SCREENPLAY_TEMPLATE_PRD.md` | 剧本↔模板关系与全链路 PRD |
| `refactor/CHARACTER_SYSTEM_PRD.md` | 角色体系 PRD（身份/服装/道具/风格/Tag/场景/AI） |
| `refactor/TECHNICAL_DESIGN.md` | rc0 全栈重构技术方案 |
| `refactor/BACKEND_KICKOFF.md` | 后端 media/screenplay/worker 启动审阅 |
| `design/UI_STYLE_GUIDE.md` | UI 风格规范（Apple Liquid Glass 视觉/材质/token/组件） |
| `design/UX_GUIDELINES.md` | 用户体验规范（信息架构、核心旅程、状态反馈、可访问性） |
| `design/PRODUCT_CONCEPT.md` | 产品创意设计规范（定位、创作飞轮、关键机制、品牌表达） |
| `07-design-system.md` | Liquid Glass 设计系统速查（token/组件对照，细节以 `design/UI_STYLE_GUIDE.md` 为准） |
| `01-module-map.md` … `10-migration-plan.md` | 编号化架构文档（见 `00-overview.md`） |

## 历史参考文档

这些文档已移至 `docs/archive/`，记录阶段性设计或局部实现，内容可能与 `docs/refactor/` 的目标方案不一致。

| 文档 | 状态 | 备注 |
|---|---|---|
| `APP_ARCHITECTURE_OPTIMIZED.md` | archived | `docs/archive/` |
| `PRODUCT_FUNCTION_ARCHITECTURE.md` | archived | `docs/archive/` |
| `PAGE_ROUTE_AGENT_STRUCTURE.md` | archived | `docs/archive/` |
| `API_COVERAGE.md` | archived | `docs/archive/` |
| `APP_API_MATRIX.md` | archived | `docs/archive/` |
| `SCREENPLAY_FLOW.md` | archived | `docs/archive/` |
| `SCRIPT_CONCEPT_TREE.md` | archived | `docs/archive/` |
| `SCREENPLAY_TREE_UNIFIED.md` | archived | `docs/archive/` |
| `SCREENPLAY_TREE_API.md` | archived | `docs/archive/` |
| `SCREENPLAY_LOCAL_JSON.md` | archived | `docs/archive/` |
| `SCREENPLAY_EXPORT.md` | archived | `docs/archive/` |
| `RUNTIME_3D.md` | archived | `docs/archive/` |
| `RUNTIME_3D_RUST_CONTRACTS.md` | archived | `docs/archive/` |
| `UI_REFACTOR_TRACKER.md` | archived | `docs/archive/` |

## Agent 使用规则

- 若需求涉及重构、模块边界、图片资产、AI 生成、插件化或前后端协同，先读 `docs/refactor/PRD.md` 与 `docs/refactor/TECHNICAL_DESIGN.md`。
- 若需求涉及 UI/UX/视觉/交互/新页面设计，先读 `docs/design/UI_STYLE_GUIDE.md` 与 `docs/design/UX_GUIDELINES.md`；全部界面统一使用 Apple Liquid Glass 设计风格。
- 若需求涉及页面路由或旧页面识别，可查 `docs/archive/PAGE_ROUTE_AGENT_STRUCTURE.md`，但不得覆盖 `docs/refactor/` 的目标架构。
- 若需求涉及 API，优先核对后端仓库 `C:/Users/qianlNya/RustroverProjects/rc0-rust/docs/openapi.yaml` 与真实 handler/service 代码。
- 不要继续新增同主题散落文档；新增重构文档应放入 `docs/refactor/` 或更新本索引。
