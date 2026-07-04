#!/usr/bin/env bash
# Remove regenerable Unity/Tuanjie caches and iOS Xcode build artifacts.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
UNITY="${RC0_UNITY_PROJECT:-$ROOT/unity/rc0_runtime}"

if [[ ! -d "$UNITY/Assets" ]]; then
  echo "Unity project not found: $UNITY" >&2
  exit 1
fi

remove_if_exists() {
  local path="$1"
  if [[ -e "$path" ]]; then
    echo "  rm -rf $path"
    rm -rf "$path"
  fi
}

echo "==> Cleaning Unity project: $UNITY"

for dir in Library Temp Logs obj UserSettings; do
  remove_if_exists "$UNITY/$dir"
done

# Xcode IL2CPP / framework build output (rebuild: scripts/build_tuanjie_ios.sh)
remove_if_exists "$UNITY/ios/build"

# Bee IL2CPP artifact cache inside Library is already removed with Library/

echo "==> Done. Re-export or rebuild when needed:"
echo "    ./scripts/export_tuanjie_ios.sh"
echo "    ./scripts/build_tuanjie_ios.sh device"
