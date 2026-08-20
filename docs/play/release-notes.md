# Release notes

Play Console → Release → "What's new in this release". **500 characters maximum per
language**, and the count includes line breaks. Only `en-US` is configured, so this is
the one that ships.

Play shows this text on the store listing under "What's new", and it is the first thing
an existing user sees after an update. Keep it about what changed for *them* — build
numbers, refactors and dependency bumps belong in the internal changelog below, not here.

---

## 1.0.1 (versionCode 2003) — en-US

```
Password fixes.

• A new password now needs 6 characters, not 8 — the rule the server actually enforces
```

---

## 1.0.0 (versionCode 2002) — en-US

```
First release of TracGo.

• Raise passenger or logistics vehicle requisitions from your phone
• Follow each request through Pending, Approved, Assigned, Rejected or Cancelled
• See the assigned vehicle, driver name and contact number
• Edit or cancel a requisition while it is still pending
• Search your requisitions and filter them by date
• Reset a forgotten password by email

Accounts are issued by your organisation.
```

Shorter alternative, if the bullets read as too much for a first release:

```
First release of TracGo — raise a company vehicle requisition from your phone, follow it
through approval, and see the vehicle and driver assigned to your trip. Passenger and
logistics requests, status tracking, date search, and edit or cancel while pending.

Accounts are issued by your organisation; there is no public sign-up.
```

Every line above is a feature that exists in this build. Nothing claims offline support,
push notifications or in-app account creation, none of which ship in 1.0.0.

---

## Internal changelog — not for the store

Kept here so the release record sits beside the artifact it describes.

**1.0.1 (versionCode 2003)**

- `app-release.aab`, versionCode 2003, versionName 1.0.1, 52.3 MB
  (`build/app/outputs/bundle/release/`)
- Signature verified on the arm64 release APK: B-Trac upload key, SHA-256
  `1B:DE:67:…:AA:A2` — the same key as 1.0.0
- 16 KB page-size check passed, 8 native libraries
- Symbols in `build/symbols/1.0.1+2003/` (arm, arm64, x64) and `mapping.txt` in
  `build/app/outputs/mapping/release/` — archive both before the next build overwrites them
- Password reset: the client-side minimum length dropped from 8 to 6
  (`PasswordResetUiState.minPasswordLength`). The contract documents no password policy,
  so this floor was always the client's own; 8 was rejecting passwords the server takes.
- `TracGoStrings.resetErrorPasswordTooShort` became `resetErrorPasswordTooShort(int
  minimum)` so the message cannot drift from the constant that gates submit again.
- `TracGoStrings.appVersionLabel` → `v1.0.1`. The drawer caption is a hand-kept constant;
  `test/presentation/app_version_label_test.dart` is what catches it when a release bump
  forgets it.
- Everything else — signing key, ABIs, R8, obfuscation, archived symbols — is unchanged
  from 1.0.0 below.

**Artifact (1.0.0)**

- `app-release.aab`, versionCode 2002, versionName 1.0.0, 52.3 MB
- `applicationId` / bundle id `com.btracsl.tracgo`; minSdk 30, targetSdk 36
- ABIs: arm64-v8a, armeabi-v7a, x86_64
- Signed with the B-Trac upload key (`android/tms-release.jks`), SHA-256
  `1B:DE:67:…:AA:A2`, valid to 2053. v2 + v3 signing; v1 off (minSdk 30).
- R8 and resource shrinking on; Dart symbols obfuscated
  (`--obfuscate --split-debug-info`)
- Archived with `mapping.txt` and the three `.symbols` files — **required** to read any
  crash from this build, and not reproducible after the fact

**What is in it**

- Login, session persisted in Keystore/Keychain, session-gated routing
- Dashboard: 12-month counts by status, recent requisitions
- My Requisitions: day-grouped list, text search, from/to date filters, cancel
- New requisition: passenger and logistics variants, employee picker for riders
- Requisition detail: trip, passengers, requester, assignment (driver + vehicle),
  activity trail
- Edit and cancel while Pending
- Profile, and password reset by email OTP (`/forgot-password` + `/reset-password`)
- Firebase Crashlytics and Remote Config behind `CrashReporter` / `AppRemoteConfig`

**Known gaps, deliberate in 1.0.0**

- No offline cache — every screen needs the network
- No push notifications, so an approval is only visible on next open
- No in-app account creation or deletion; both are administrator actions
- iOS is built and verified but not published
