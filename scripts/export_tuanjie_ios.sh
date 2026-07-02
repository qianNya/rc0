#!/usr/bin/env bash
# Re-export Unity/Tuanjie iOS project (required after C# changes under Assets/RC0Runtime).
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
PROJECT="$ROOT/unity/rc0_runtime"
TUANJIE="${RC0_TUANJIE_EDITOR:-/Applications/Tuanjie/Hub/Editor/2022.3.62t10/Tuanjie.app/Contents/MacOS/Tuanjie}"
LOG="$PROJECT/Logs/export_ios.log"
LOCK="$PROJECT/Temp/UnityLockfile"

mkdir -p "$PROJECT/Logs"

if [[ -f "$LOCK" ]]; then
  echo "Tuanjie already has this project open (lock: $LOCK)." >&2
  echo "Close the Tuanjie Editor, or export manually:" >&2
  echo "  File → Build Settings → iOS → Export → $PROJECT/ios" >&2
  exit 2
fi

echo "==> Exporting iOS from Tuanjie"
echo "    Project: $PROJECT"
echo "    Editor:  $TUANJIE"
echo "    Log:     $LOG"

"$TUANJIE" \
  -batchmode \
  -nographics \
  -quit \
  -projectPath "$PROJECT" \
  -executeMethod RC0.Runtime.Editor.Rc0ExportIos.Export \
  -logFile "$LOG"

echo "==> Export complete. Building TuanjieFramework..."
"$ROOT/scripts/build_tuanjie_ios.sh" device

echo "OK: iOS Unity export + framework build finished"
