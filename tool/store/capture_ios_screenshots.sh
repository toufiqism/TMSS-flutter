#!/bin/sh
#
# Captures the App Store raw screenshots on an iOS Simulator.
#
#     ./tool/store/capture_ios_screenshots.sh                    # iPhone 17 Pro Max
#     ./tool/store/capture_ios_screenshots.sh "iPhone 16 Pro Max"
#
# Writes docs/appstore/graphics/screenshots/raw/*.png at the simulator's native
# resolution, then leaves the framing to generate_ios_store_screenshots.py.
#
# Starts tool/store/mock_api_server.py itself unless something is already listening on
# the port, and stops it again on the way out — the captures must never come from the
# live account, which holds a real employee's identity and real business records.
#
# Debug, not profile: Flutter cannot build profile or release for the iOS Simulator, and
# unlike the Android pipeline there is nothing to gain from it anyway. The Android build
# needs profile because the main manifest forbids cleartext and only the debug/profile
# manifests override it; on iOS the question does not arise, because Dart's HttpClient
# is its own socket-level stack and App Transport Security never sees these requests.
# The UI is pure Flutter, so debug and release rasterise identically.

set -eu

REPO=$(cd "$(dirname "$0")/../.." && pwd)
DEVICE_NAME=${1:-iPhone 17 Pro Max}
PORT=${TRACGO_MOCK_PORT:-8099}
RAW="$REPO/docs/appstore/graphics/screenshots/raw"

MOCK_PID=""
cleanup() {
  if [ -n "$MOCK_PID" ]; then
    kill "$MOCK_PID" 2>/dev/null || true
    echo "stopped mock API server (pid $MOCK_PID)"
  fi
}
trap cleanup EXIT INT TERM

# -- mock API ------------------------------------------------------------------------
if nc -z 127.0.0.1 "$PORT" 2>/dev/null; then
  echo "mock API already listening on $PORT — reusing it"
else
  python3 "$REPO/tool/store/mock_api_server.py" "$PORT" >/dev/null 2>&1 &
  MOCK_PID=$!
  # Poll rather than sleep a fixed amount: the server binds in well under a second, and
  # a hard sleep is either wasted time or an intermittent failure.
  i=0
  until nc -z 127.0.0.1 "$PORT" 2>/dev/null; do
    i=$((i + 1))
    [ "$i" -gt 50 ] && { echo "mock API did not come up on $PORT" >&2; exit 1; }
    sleep 0.2
  done
  echo "started mock API server on $PORT (pid $MOCK_PID)"
fi

# -- simulator -----------------------------------------------------------------------
# `simctl list` prints one line per device; take the first match's UDID. A name with no
# match is a typo, not an empty capture set, so fail loudly.
UDID=$(xcrun simctl list devices available \
  | grep -F "$DEVICE_NAME (" \
  | head -1 \
  | sed -E 's/.*\(([0-9A-F-]{36})\).*/\1/')

if [ -z "$UDID" ]; then
  echo "no available simulator named '$DEVICE_NAME'" >&2
  echo "available 6.9\" devices:" >&2
  xcrun simctl list devices available | grep -E "Pro Max|Plus" >&2
  exit 1
fi

echo "booting $DEVICE_NAME ($UDID)"
xcrun simctl boot "$UDID" 2>/dev/null || true
xcrun simctl bootstatus "$UDID" -b

# Belt and braces, not a requirement: `integration_test`'s `takeScreenshot` reads back
# the Flutter surface, which does not include the iOS status bar, so these captures have
# an empty band where the clock would be. The override matters only if the capture ever
# falls back to `xcrun simctl io <udid> screenshot`, which grabs the whole screen — and
# then Apple's own marketing convention is 9:41 with full bars.
xcrun simctl status_bar "$UDID" override \
  --time "9:41" \
  --cellularMode active \
  --cellularBars 4 \
  --wifiMode active \
  --wifiBars 3 \
  --batteryState charged \
  --batteryLevel 100 2>/dev/null || echo "warning: could not override the status bar" >&2

# Default text size, in case a previous session left it scaled.
xcrun simctl ui "$UDID" content_size medium 2>/dev/null || true

# -- capture -------------------------------------------------------------------------
# Clear first. A run that dies halfway leaves the frames it did manage next to the ones
# from the run before, and the framing pass cannot tell them apart — it would compose a
# listing that is half current UI and half whatever the UI looked like last month. An
# empty directory after a failure is an obvious problem; a stale one is invisible.
rm -rf "$RAW"
mkdir -p "$RAW"
cd "$REPO"
flutter drive \
  --driver test_driver/store_screenshots_test.dart \
  --target integration_test/store_screenshots_test.dart \
  -d "$UDID" \
  --dart-define=TMS_BASE_URL="http://127.0.0.1:$PORT"

echo
echo "raw captures:"
for f in "$RAW"/*.png; do
  [ -e "$f" ] || { echo "  none written — the run captured nothing" >&2; exit 1; }
  echo "  $(basename "$f")  $(sips -g pixelWidth -g pixelHeight "$f" \
    | awk '/pixelWidth/{w=$2} /pixelHeight/{h=$2} END{print w"x"h}')"
done

echo
echo "next: python3 tool/store/generate_ios_store_screenshots.py"
