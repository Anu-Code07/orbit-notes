#!/usr/bin/env bash
# Build Orbit Notes release artifacts from release.build.json + release.json
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

CONFIG="${RELEASE_BUILD_JSON:-release.build.json}"
DEFINES="${DART_DEFINE_FILE:-release.json}"

if [[ ! -f "$CONFIG" ]]; then
  echo "Missing $CONFIG" >&2
  exit 1
fi
if [[ ! -f "$DEFINES" ]]; then
  echo "Missing $DEFINES" >&2
  exit 1
fi

VERSION_NAME="$(python3 -c "import json; print(json.load(open('$CONFIG'))['version']['name'])")"
VERSION_CODE="$(python3 -c "import json; print(json.load(open('$CONFIG'))['version']['code'])")"
BUILD_APK="$(python3 -c "import json; print(str(json.load(open('$CONFIG'))['build']['android']['apk']).lower())")"
BUILD_AAB="$(python3 -c "import json; print(str(json.load(open('$CONFIG'))['build']['android']['appbundle']).lower())")"

echo "Orbit Notes release"
echo "  version: $VERSION_NAME+$VERSION_CODE"
echo "  defines: $DEFINES"
echo

flutter pub get

COMMON=(
  --release
  --dart-define-from-file="$DEFINES"
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
python3 - <<PY
import json
from pathlib import Path
cfg = json.load(open("$CONFIG"))
for label, path in cfg.get("artifacts", {}).items():
    p = Path(path)
    status = f"{p.stat().st_size:,} bytes" if p.exists() else "missing"
    print(f"  {label}: {path} ({status})")
PY
