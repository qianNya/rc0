# 09 — 插件系统

> SSOT：[refactor/TECHNICAL_DESIGN.md](refactor/TECHNICAL_DESIGN.md) §3.5

## FeatureModule 契约

```dart
abstract interface class FeatureModule {
  String get id;
  List<RouteBase> get routes;
  List<NavEntry> get navEntries;
  Map<Type, Object> get ports;
}
```

## 注册流程

1. `AppModuleRegistry.initialize(modules: [...])`
2. `registerAppPorts` 注入 picker / editor host 等
3. `bootstrapFromModules` 合并 module ports
4. Router 从 module 收集 `navEntries`（`shell_nav_registry.dart`）

## 已注册模块

| Module | id | navEntries |
|---|---|---|
| `EditorFeatureModule` | `editor` | 创作 /studio |
| `ExploreFeatureModule` | `explore` | 发现 /discovery |
| `LibraryFeatureModule` | `library` | 库 /library |
| `ProfileFeatureModule` | `profile` | 我的 /profile |

## Ports（rc0_core）

- `ScenePickerPort` / `CharacterPickerPort` / `PresetPickerPort`
- `EditorHostPort`（`rc0_feature_editor`）

Feature 通过 `ModuleRegistry.port<T>()` 获取，禁止直接 import 其他 feature。
