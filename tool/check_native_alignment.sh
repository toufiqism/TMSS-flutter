#!/usr/bin/env bash
#
# Verify that every native library in a release APK is 16 KB page-size compatible.
#
#     tool/check_native_alignment.sh [path/to/app-release.apk]
#
# Defaults to build/app/outputs/flutter-apk/app-release.apk.
#
# Why this check exists
# ---------------------
# Google Play requires apps targeting Android 15 (API 35) and above to work on devices
# with 16 KB memory pages. This app targets 36, so it is in scope. Failing it is not a
# warning at upload time — Play rejects the bundle.
#
# Two independent things have to be right, which is why this script runs two tools:
#
#   1. ELF segment alignment. Every PT_LOAD segment inside each .so must be aligned to
#      at least 0x4000 (16 KB). This is baked in by whoever compiled the library, so a
#      failure here is a dependency problem — bump the plugin, or the Flutter SDK — and
#      cannot be fixed from this repo.
#   2. Zip alignment. Uncompressed .so entries must start on a 16 KB boundary *within
#      the APK*, so the loader can mmap them in place. AGP handles this; the check
#      guards against a build config that turns it off.
#
# The APK is the artifact under test even though Play receives an app bundle: the
# bundle's libraries are the same files, and the per-device APKs Play generates from it
# inherit both properties. Build the APK the same way as the bundle (release, same
# plugins) and the result transfers.
#
# Requires: an Android SDK with build-tools (zipalign) and an NDK (llvm-readelf).
# Set ANDROID_HOME, or let the script fall back to the default Windows/macOS/Linux SDK
# locations.
set -euo pipefail

APK="${1:-build/app/outputs/flutter-apk/app-release.apk}"
REQUIRED_ALIGNMENT=16384 # 0x4000

if [ ! -f "$APK" ]; then
  echo "error: no APK at $APK" >&2
  echo "       build one first: flutter build apk --release" >&2
  exit 1
fi

# --- locate the SDK -----------------------------------------------------------------

sdk_root() {
  if [ -n "${ANDROID_HOME:-}" ]; then echo "$ANDROID_HOME"; return; fi
  if [ -n "${ANDROID_SDK_ROOT:-}" ]; then echo "$ANDROID_SDK_ROOT"; return; fi
  for candidate in "${LOCALAPPDATA:-}/Android/Sdk" "$HOME/Library/Android/sdk" "$HOME/Android/Sdk"; do
    if [ -d "$candidate" ]; then echo "$candidate"; return; fi
  done
  echo ""
}

SDK="$(sdk_root)"
if [ -z "$SDK" ]; then
  echo "error: could not find the Android SDK; set ANDROID_HOME" >&2
  exit 1
fi

# Highest-versioned build-tools and NDK present, rather than a pinned version: this
# script only reads files, so a newer tool is never the wrong tool here.
newest() { ls -1 "$1" 2>/dev/null | sort -V | tail -n 1; }

ZIPALIGN="$SDK/build-tools/$(newest "$SDK/build-tools")/zipalign"
[ -x "$ZIPALIGN" ] || ZIPALIGN="$ZIPALIGN.exe"

NDK_DIR="$SDK/ndk/$(newest "$SDK/ndk")"
READELF=""
for host in windows-x86_64 darwin-x86_64 linux-x86_64; do
  candidate="$NDK_DIR/toolchains/llvm/prebuilt/$host/bin/llvm-readelf"
  for exe in "$candidate" "$candidate.exe"; do
    if [ -x "$exe" ]; then READELF="$exe"; break 2; fi
  done
done

if [ ! -x "$ZIPALIGN" ]; then
  echo "error: zipalign not found under $SDK/build-tools" >&2
  exit 1
fi
if [ -z "$READELF" ]; then
  echo "error: llvm-readelf not found under $SDK/ndk — install an NDK via the SDK Manager" >&2
  exit 1
fi

# --- 1. ELF segment alignment -------------------------------------------------------

WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT

# Extracting the whole archive rather than a lib/* pattern: pattern matching is unreliable
# under MSYS/Git Bash, which rewrites arguments that look like paths.
unzip -o -q "$APK" -d "$WORK"

failures=0
found=0

if [ -d "$WORK/lib" ]; then
  while IFS= read -r so; do
    found=$((found + 1))
    # Every PT_LOAD alignment in the file; the smallest one is what decides the verdict.
    min_align=""
    while IFS= read -r hex; do
      dec=$((hex))
      if [ -z "$min_align" ] || [ "$dec" -lt "$min_align" ]; then min_align="$dec"; fi
    done < <("$READELF" -l "$so" 2>/dev/null | awk '/LOAD/ {print $NF}' | sort -u)

    name="${so#"$WORK"/}"
    if [ -z "$min_align" ]; then
      echo "  ?? $name — no PT_LOAD segments read"
      failures=$((failures + 1))
    elif [ "$min_align" -lt "$REQUIRED_ALIGNMENT" ]; then
      printf '  FAIL %s — min LOAD alignment 0x%x (needs 0x%x)\n' \
        "$name" "$min_align" "$REQUIRED_ALIGNMENT"
      failures=$((failures + 1))
    else
      printf '  ok   %s — 0x%x\n' "$name" "$min_align"
    fi
  done < <(find "$WORK/lib" -name '*.so' | sort)
fi

if [ "$found" -eq 0 ]; then
  echo "error: no .so files in $APK — is this really a release build?" >&2
  exit 1
fi

# --- 2. zip alignment ---------------------------------------------------------------

echo
if "$ZIPALIGN" -c -P 16 4 "$APK" >/dev/null 2>&1; then
  echo "  ok   zip entries aligned for 16 KB pages"
else
  echo "  FAIL zip entries not aligned for 16 KB pages"
  failures=$((failures + 1))
fi

echo
if [ "$failures" -gt 0 ]; then
  echo "16 KB page-size check: FAILED ($failures problem(s)) — do not upload this build" >&2
  exit 1
fi
echo "16 KB page-size check: PASSED ($found libraries)"
