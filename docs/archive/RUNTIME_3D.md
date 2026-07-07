# RC0 3D Runtime

> Legacy-reference：当前重构方案保留 `runtime_3d` 三层桥，本文件仅作 runtime 现状参考；文档状态见 `docs/README.md`。

Plugin-based Unity 3D runtime replacing flutter_gl + three_dart.

## Layers

| Layer | Path | Role |
|-------|------|------|
| Flutter 产品层 | `lib/runtime_3d/` | `RuntimeHost`, module facades, contracts |
| Flutter 嵌入 | `packages/rc0_unity_widget/` | PlatformView + JSON bridge |
| Unity 引擎 | `unity/rc0_runtime/` | `ModuleRegistry`, 12 modules |
| Rust 服务 | `lib/api/runtime/` + `docs/RUNTIME_3D_RUST_CONTRACTS.md` | 离线导出 / 资产优化 / AI 布光 |

## Pages using RuntimeHost

- `lib/features/action/presentation/pages/action_wiki_page.dart`
- `lib/features/lighting/presentation/pages/lighting_wiki_page.dart`

## Next steps (local dev)

1. Open `unity/rc0_runtime` in Unity 2022.3 LTS
2. Export platform libraries per `packages/rc0_unity_widget/README.md`
3. `flutter clean && flutter pub get && flutter run` (full restart)
