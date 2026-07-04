#!/usr/bin/env bash
# Re-export Unity/Tuanjie iOS project (required after C# changes under Assets/RC0Runtime).
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
PROJECT="$ROOT/unity/rc0_runtime"
TUANJIE="${RC0_TUANJIE_EDITOR:-/Applications/Tuanjie/Hub/Editor/2022.3.62t10/Tuanjie.app/Contents/MacOS/Tuanjie}"
LOG="$PROJECT/Logs/export_ios.log"
LOCK="$PROJECT/Temp/UnityLockfile"

mkdir -p "$PROJECT/Logs"

editor_holding_project() {
  pgrep -f "Tuanjie.*-projectpath[[:space:]]+$PROJECT" >/dev/null 2>&1 ||
    pgrep -f "Tuanjie.*-projectPath[[:space:]]+$PROJECT" >/dev/null 2>&1
}

print_editor_open_help() {
  echo "" >&2
  echo "Tuanjie Editor is already running with this project." >&2
  echo "" >&2
  echo "Option A — export inside the open Editor (recommended):" >&2
  echo "  Menu: RC0 → Export iOS → ios/" >&2
  echo "  Then run: ./scripts/build_tuanjie_ios.sh device" >&2
  echo "" >&2
  echo "Option B — close Tuanjie completely, then rerun:" >&2
  echo "  ./scripts/export_tuanjie_ios.sh" >&2
  echo "" >&2
  echo "Manual path: File → Build Settings → iOS → Export → $PROJECT/ios" >&2
}

if [[ -f "$LOCK" ]] || editor_holding_project; then
  print_editor_open_help
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
