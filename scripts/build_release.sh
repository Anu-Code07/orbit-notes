#!/usr/bin/env bash
# Build Orbit Notes release artifacts from release.json
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

CONFIG="${RELEASE_JSON:-release.json}"
DEFINES_OUT=".dart_defines.release.json"

if [[ ! -f "$CONFIG" ]]; then
  echo "Missing $CONFIG" >&2
  exit 1
fi

eval "$(python3 - <<PY
import json
from pathlib import Path

cfg = json.load(open("$CONFIG"))
defines = cfg.get("dart_defines") or {}
Path("$DEFINES_OUT").write_text(json.dumps(defines, indent=2) + "\n")

app = cfg["app"]
android = cfg.get("android", {})
print(f'VERSION_NAME={app["version"]!r}')
print(f'VERSION_CODE={app["build_number"]!r}')
print(f'BUILD_APK={str(android.get("apk", {}).get("enabled", False)).lower()!r}')
print(f'BUILD_AAB={str(android.get("appbundle", {}).get("enabled", False)).lower()!r}')
print(f'APK_OUT={android.get("apk", {}).get("output", "")!r}')
print(f'AAB_OUT={android.get("appbundle", {}).get("output", "")!r}')
PY
)"

echo "Orbit Notes release"
echo "  version: ${VERSION_NAME}+${VERSION_CODE}"
echo "  defines: $DEFINES_OUT (from $CONFIG)"
echo

flutter pub get

COMMON=(
  --release
  --dart-define-from-file="$DEFINES_OUT"
  --build-name="$VERSION_NAME"
  --build-number="$VERSION_CODE"
)

if [[ "$BUILD_APK" == "true" ]]; then
  echo "→ Building APK…"
  flutter build apk "${COMMON[@]}"
fi

if [[ "$BUILD_AAB" == "true" ]]; then
  echo "→ Building App Bundle…"
  flutter build appbundle "${COMMON[@]}"
fi

echo
echo "Done."
for path in "$APK_OUT" "$AAB_OUT"; do
  if [[ -n "$path" && -f "$path" ]]; then
    bytes="$(wc -c < "$path" | tr -d ' ')"
    echo "  $path ($bytes bytes)"
  elif [[ -n "$path" ]]; then
    echo "  $path (missing)"
  fi
done
