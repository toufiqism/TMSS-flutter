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

SPM_RUN="${BUILD_DIR%/Build/*}/SourcePackages/checkouts/firebase-ios-sdk/Crashlytics/run"
PODS_RUN="${PODS_ROOT:-}/FirebaseCrashlytics/run"

if [ -x "$SPM_RUN" ] || [ -f "$SPM_RUN" ]; then
  exec "$SPM_RUN"
elif [ -f "$PODS_RUN" ]; then
  exec "$PODS_RUN"
fi

echo "warning: Firebase Crashlytics run script not found — dSYMs were not uploaded."
echo "warning: looked in '$SPM_RUN' and '$PODS_RUN'."
exit 0
