#!/usr/bin/env bash
# Links the Tuanjie/Unity macOS player into the Flutter plugin.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SRC="${RC0_UNITY_MAC_BUILD:-$ROOT/unity/rc0_runtime/ios:UnityLibrary.app}"
DEST_DIR="$ROOT/packages/rc0_unity_widget/macos/UnityPlayer"
DEST="$DEST_DIR/rc0_runtime.app"

if [[ ! -d "$SRC" ]]; then
  echo "Unity macOS build not found: $SRC" >&2
  echo "Export macOS Standalone from unity/rc0_runtime, or set RC0_UNITY_MAC_BUILD." >&2
  exit 1
fi

mkdir -p "$DEST_DIR"
rm -f "$DEST"
ln -sfn "$SRC" "$DEST"

echo "Linked Unity macOS player:"
echo "  $DEST -> $SRC"
