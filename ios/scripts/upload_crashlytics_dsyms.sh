#!/bin/sh
#
# Uploads dSYMs to Firebase Crashlytics so release crash reports symbolicate.
# Invoked from the Runner target's "Upload Crashlytics dSYMs" build phase.
#
# This project has no Podfile — Flutter plugins are consumed through Swift Package
# Manager — so the helper lives in the SPM checkouts directory, NOT the
# ${PODS_ROOT}/FirebaseCrashlytics/run path the Firebase docs show by default.
# Both are probed so this keeps working if the project is migrated to CocoaPods.
#
# A missing helper warns instead of failing the build: it is absent on a clean
# checkout before the first package resolve, and on Debug configurations that
# produce no dSYM at all. Neither is a reason to fail a build.

set -u

# `flutter build ios` passes -clonedSourcePackagesDirPath <project>/build/ios/SourcePackages,
# so the checkouts are NOT under DerivedData. A plain `xcodebuild`/Xcode-GUI build has no
# such override and does put them under DerivedData. Probe both, then CocoaPods.
FLUTTER_SPM_RUN="${SRCROOT:-}/../build/ios/SourcePackages/checkouts/firebase-ios-sdk/Crashlytics/run"
DERIVED_SPM_RUN="${BUILD_DIR:-}"
DERIVED_SPM_RUN="${DERIVED_SPM_RUN%/Build/*}/SourcePackages/checkouts/firebase-ios-sdk/Crashlytics/run"
PODS_RUN="${PODS_ROOT:-}/FirebaseCrashlytics/run"

for CANDIDATE in "$FLUTTER_SPM_RUN" "$DERIVED_SPM_RUN" "$PODS_RUN"; do
  [ -f "$CANDIDATE" ] || continue
  # The checkout normally ships mode 555, but a filesystem or transfer that drops the
  # exec bit would otherwise turn this into a hard build failure.
  if [ -x "$CANDIDATE" ]; then
    exec "$CANDIDATE"
  else
    exec /bin/sh "$CANDIDATE"
  fi
done

echo "warning: Firebase Crashlytics run script not found — dSYMs were not uploaded."
echo "warning: looked in '$FLUTTER_SPM_RUN', '$DERIVED_SPM_RUN' and '$PODS_RUN'."
exit 0
