#!/usr/bin/env bash
# Builds TuanjieFramework.framework for device and/or simulator.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
UNITY_IOS="${RC0_UNITY_IOS_EXPORT:-$ROOT/unity/rc0_runtime/ios}"
TARGET="${1:-all}" # device | simulator | all

cd "$UNITY_IOS"

build_one() {
  local sdk="$1"
  local dest_name="$2"
  echo "==> Building TuanjieFramework ($sdk)"
  xcodebuild \
    -project Tuanjie-iPhone.xcodeproj \
    -target TuanjieFramework \
    -configuration Release \
    -sdk "$sdk" \
    ONLY_ACTIVE_ARCH=NO \
    BUILD_DIR="$(pwd)/build" \
    CODE_SIGNING_ALLOWED=NO \
    | tail -20

  local fw="build/Release-${dest_name}/TuanjieFramework.framework/TuanjieFramework"
  if [[ ! -f "$fw" ]]; then
    echo "Build failed: missing $fw" >&2
    return 1
  fi
  echo "OK: $fw"
}

bundle_unity_data() {
  local dest_name="$1"
  local fw_dir="build/Release-${dest_name}/TuanjieFramework.framework"
  local metadata="$fw_dir/Data/Managed/Metadata/global-metadata.dat"
  local streaming_assets="Data/StreamingAssets/model"

  if [[ ! -d "Data" ]]; then
    echo "Missing Unity Data export: $(pwd)/Data" >&2
    return 1
  fi

  if [[ -d "$ROOT/assets/model" ]]; then
    echo "==> Sync Flutter bundled models → Unity StreamingAssets"
    mkdir -p "$streaming_assets"
    rsync -a --delete "$ROOT/assets/model/" "$streaming_assets/"
  fi

  echo "==> Bundling Unity Data into TuanjieFramework ($dest_name)"
  rsync -a --delete "Data/" "$fw_dir/Data/"

  if [[ ! -f "$metadata" ]]; then
    echo "Bundle failed: missing $metadata" >&2
    return 1
  fi
  echo "OK: $metadata"
}

case "$TARGET" in
  device)
    build_one iphoneos iphoneos
    bundle_unity_data iphoneos
    ;;
  simulator)
    build_one iphonesimulator iphonesimulator
    bundle_unity_data iphonesimulator
    ;;
  all)
    build_one iphoneos iphoneos || exit 1
    bundle_unity_data iphoneos || exit 1
    build_one iphonesimulator iphonesimulator || {
      echo ""
      echo "Simulator build failed (libiPhone-lib.a is device-only)." >&2
      echo "In Tuanjie: Player Settings → iOS → enable Simulator (ARM64), re-export iOS, then rerun." >&2
      exit 1
    }
    bundle_unity_data iphonesimulator || exit 1
    ;;
  *) echo "Usage: $0 [device|simulator|all]" >&2; exit 1 ;;
esac

# Stage for CocoaPods
STAGE="$ROOT/ios/UnityLibrary/Frameworks"
mkdir -p "$STAGE"
if [[ -d "build/Release-iphoneos/TuanjieFramework.framework" ]]; then
  rsync -a --delete build/Release-iphoneos/TuanjieFramework.framework "$STAGE/TuanjieFramework-iphoneos.framework"
fi
if [[ -d "build/Release-iphonesimulator/TuanjieFramework.framework/TuanjieFramework" ]]; then
  rsync -a --delete build/Release-iphonesimulator/TuanjieFramework.framework "$STAGE/TuanjieFramework-iphonesimulator.framework"
fi

echo "Staged frameworks under ios/UnityLibrary/Frameworks/"
