# 08 — 3D 运行时

## 过渡策略（2026-07）

`packages/rc0_runtime_3d` 已建立为**契约包**；完整实现仍位于：

| 位置 | 内容 |
|---|---|
| `lib/runtime_3d/` | Flutter 侧 session、command、module facade |
| `packages/rc0_unity_widget` | Unity 嵌入 widget |

### 为何暂不整体搬迁

- `runtime_3d` 与 `studio`/`lighting` ports 仍有 app 层绑定。
- Unity 原生插件路径与构建钩子未纳入 melos 独立包测试。

### 迁移顺序

1. ✅ `rc0_runtime_3d` 导出模块 ID、会话契约占位
2. 将 `pose_contract` / `lighting_contract` 迁入包内
3. App ports（`AppCameraBindingPort` 等）保持 app 层实现
4. 最终 deprecate `lib/runtime_3d` 根导入，改 `package:rc0_runtime_3d`

历史文档：[archive/RUNTIME_3D.md](archive/RUNTIME_3D.md)、[archive/RUNTIME_3D_RUST_CONTRACTS.md](archive/RUNTIME_3D_RUST_CONTRACTS.md)。
