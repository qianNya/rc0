# RC0 Unity Runtime

Unity 2022.3 LTS (URP) project for the RC0 plugin-based 3D runtime.

## Layout

```
Assets/RC0Runtime/
  Core/           Bootstrap, FlutterBridge, ModuleRegistry
  Contracts/      JSON message DTOs (mirror lib/runtime_3d/contracts)
  Modules/        Scene, Character, Lighting, Camera, Pose, Animation, ...
```

## Build targets

| Platform | Output | Flutter integration |
|----------|--------|---------------------|
| iOS | `UnityFramework` | `packages/rc0_unity_widget/ios/UnityLibrary/` |
| Android | `unityLibrary` AAR | `packages/rc0_unity_widget/android/unityLibrary/` |
| macOS | `UnityPlayer.bundle` | `packages/rc0_unity_widget/macos/UnityPlayer/` |
| Windows | `UnityPlayer.dll` + Data | `packages/rc0_unity_widget/windows/unity/` |
| WebGL | `web/unity/` in Flutter app | JS postMessage bridge |

## Runtime features (Assets/RC0Runtime)

- **CharacterModule** — runtime glTF / GLB / OBJ loading
- **CameraInteractionController** — touch orbit, pinch zoom, two-finger pan
- **RuntimeJson** — Flutter command payload parsing

After changing C# under `Assets/RC0Runtime/`, **re-export iOS** from Tuanjie/Unity Editor, then run:

```bash
./scripts/build_tuanjie_ios.sh device
```

Or close the Editor and run the full pipeline:

```bash
./scripts/export_tuanjie_ios.sh
```

**`RC0RuntimeBootstrap not found`:** the exported scene must contain a GameObject named
`RC0RuntimeBootstrap` (see `Assets/ios.scene` and `RuntimeBootstrapLoader.cs`). Re-export after
pulling runtime changes.

Bundled Flutter models (`assets/model/`) are copied into `Data/StreamingAssets/model/` during `build_tuanjie_ios.sh`.

## Build commands (from Unity Editor)

1. Open `unity/rc0_runtime` in Unity Hub 2022.3 LTS
2. Install URP package (already configured)
3. Use **File → Build Settings** or CI scripts under `unity/rc0_runtime/BuildScripts/`

After exporting, run `flutter pub get` and a full restart (not hot reload).
