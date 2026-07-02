#!/usr/bin/env bash
# Symlinks the Tuanjie iOS export into the Flutter iOS project.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SRC="${RC0_UNITY_IOS_EXPORT:-$ROOT/unity/rc0_runtime/ios}"
DEST="$ROOT/ios/UnityLibrary"

if [[ ! -d "$SRC/Tuanjie-iPhone.xcodeproj" ]]; then
  echo "Tuanjie iOS export not found: $SRC" >&2
  exit 1
fi

mkdir -p "$(dirname "$DEST")"
rm -f "$DEST"
ln -sfn "$SRC" "$DEST"

echo "Linked Tuanjie iOS export:"
echo "  $DEST -> $SRC"
