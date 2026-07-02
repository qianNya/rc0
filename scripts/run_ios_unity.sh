#!/usr/bin/env bash
# 一键：链接 Unity iOS 导出 → 构建 TuanjieFramework → pod install → flutter run
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
export PATH="$ROOT/.local-bin:${HOME}/.gem/ruby/2.6.0/bin:${PATH:-}"

DEVICE_ID="${1:-}"
MODE="${RC0_IOS_MODE:-auto}" # auto | full | stub

cd "$ROOT"

echo "==> 1/4 链接 Unity iOS 导出"
"$ROOT/scripts/link_unity_ios.sh"

pick_mode() {
  if [[ "$MODE" == "stub" ]]; then
    echo stub
    return
  fi
  if [[ "$MODE" == "full" ]]; then
    echo full
    return
  fi
  # auto: 有真机 framework 且目标不是模拟器 → full
  local fw="$ROOT/unity/rc0_runtime/ios/build/Release-iphoneos/TuanjieFramework.framework/TuanjieFramework"
  if [[ -f "$fw" ]] && [[ -n "$DEVICE_ID" ]] && ! flutter devices 2>/dev/null | grep -F "$DEVICE_ID" | grep -qi simulator; then
    echo full
  elif [[ -f "$ROOT/unity/rc0_runtime/ios/build/Release-iphonesimulator/TuanjieFramework.framework/TuanjieFramework" ]]; then
    echo full
  else
    echo stub
  fi
}

RESOLVED="$(pick_mode)"

if [[ "$RESOLVED" == "full" ]]; then
  echo "==> 2/4 构建 TuanjieFramework (device)"
  "$ROOT/scripts/build_tuanjie_ios.sh" device
  export RC0_TUANJIE_SUBSPEC=Full
  echo "    Unity: Full（嵌入 TuanjieFramework）"
else
  export RC0_TUANJIE_SUBSPEC=Stub
  echo "==> 2/4 跳过 Unity 构建（Stub 模式，模拟器或无真机 framework）"
  echo "    模拟器要跑真实 3D：团结引擎开启 Simulator(ARM64) 重新导出后执行 RC0_IOS_MODE=full $0"
fi

echo "==> 3/4 pod install (subspec=$RC0_TUANJIE_SUBSPEC)"
cd "$ROOT/ios"
pod install
cd "$ROOT"

echo "==> 4/4 flutter run"
RUN_ARGS=()
if [[ -n "$DEVICE_ID" ]]; then
  RUN_ARGS+=(-d "$DEVICE_ID")
fi

flutter pub get
flutter run "${RUN_ARGS[@]}"
