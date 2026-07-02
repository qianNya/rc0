# RC0 Unity Widget

## iOS 一键运行（推荐）

```bash
cd /Users/qianl/flutter/rc0
chmod +x scripts/run_ios_unity.sh
PATH="$PWD/.local-bin:$HOME/.gem/ruby/2.6.0/bin:$PATH" ./scripts/run_ios_unity.sh
```

指定设备：

```bash
PATH="$PWD/.local-bin:$HOME/.gem/ruby/2.6.0/bin:$PATH" ./scripts/run_ios_unity.sh "iPhone 17 Pro Max"
```

**真机加载完整 Unity 3D：**

```bash
RC0_IOS_MODE=full PATH="$PWD/.local-bin:$HOME/.gem/ruby/2.6.0/bin:$PATH" ./scripts/run_ios_unity.sh <你的iPhone设备ID>
```

或手动：

```bash
cd /Users/qianl/flutter/rc0
PATH="$PWD/.local-bin:$HOME/.gem/ruby/2.6.0/bin:$PATH"

./scripts/link_unity_ios.sh
./scripts/build_tuanjie_ios.sh device
cd ios && RC0_TUANJIE_SUBSPEC=Full pod install && cd ..
flutter run -d <真机>
```

**模拟器**：当前 Unity 导出仅含真机静态库，模拟器默认 **Stub**（Flutter 可跑，3D 占位）。要在模拟器跑真实 3D，需在团结引擎开启 **Simulator (ARM64)** 后重新导出 iOS。

## 架构

```
Flutter RuntimeHost → rc0_unity_widget → TuanjieFramework (嵌入 PlatformView)
                                    ↕ JSON (FlutterBridge.OnFlutterMessage)
Unity RC0RuntimeBootstrap
```

## Unity 3D 能力

- **模型加载**：glTF / GLB / OBJ（`CharacterModule`）
- **触控交互**：单指旋转、双指缩放、双指平移（`CameraInteractionController`）
- **内置模型**：`assets/model/` 在 `build_tuanjie_ios.sh` 时同步到 `StreamingAssets/model/`

修改 `unity/rc0_runtime/Assets/RC0Runtime/` 后，需在 Tuanjie Editor **重新 Export iOS**，再跑 `./scripts/build_tuanjie_ios.sh device`。

## Channels

- `rc0_unity_widget` — `isUnityAvailable`, `createView`, `sendCommand`, `disposeView`
- `rc0_unity_widget/events` — Unity → Flutter JSON events
