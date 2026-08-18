# Handoff — 18 August 2026

Written to resume this work on a different machine. Everything below was true at commit
`4cd20bd` on branch `dev`, which is pushed.

---

## 1. Repo state

| | |
|---|---|
| Branch | `dev` (up to date with `origin/dev`, 0 unpushed commits) |
| HEAD | `4cd20bd` Collapse password reset header when keyboard is visible |
| Gates | `flutter analyze` clean · `flutter test` **477 passing** |
| Uncommitted | `docs/play/privacy-policy.md`, `docs/play/data-safety.md` (finished this session — commit them), plus `.claude/skills/{caveman,grill-me}` staged |

Three commits landed this session:

- `74f2536` — unauthenticated email-OTP password reset flow + shared auth controls
- `f0cff4e` — Profile entry point, read-only (locked) email
- `4cd20bd` — header folds away while the keyboard is up

---

## 2. What another machine needs before it can do anything

**The signing material is deliberately not in git.** Without it, `flutter build apk/appbundle --release` still succeeds — signed with the *debug* key — and that artifact is silently unuploadable. `android/app/build.gradle.kts` prints a warning; the `verifyReleaseSigning` Gradle task is what actually fails the build.

Copy over a secure channel, never through the repo:

- `android/key.properties` (see `android/key.properties.example` for the shape)
- `android/tms-release.jks` — the keystore it points at

Also required:

| Tool | Version / note |
|---|---|
| Flutter | **3.44.1 stable** (Dart 3.12.1). Newer may work; this is what everything here was verified on |
| Android | compileSdk 37 pinned, minSdk 30, targetSdk 36 (`flutter.targetSdkVersion`) |
| Python 3 + Pillow | only for the store-graphics task in §5. Pillow 12.2.0 used here |
| adb | device must be authorised — the "Allow USB debugging" prompt bit us once mid-session |
| Test device | RMX5555 (`ab3c6283`), Android 16, arm64. Any arm64 Android works |

First commands on a fresh clone:

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs   # freezed/json codegen
flutter analyze && flutter test
```

---

## 3. What the password-reset feature is, in one screen

Two unauthenticated endpoints from `api-contract/tms-auth-password-reset-openapi.json`:
`POST /forgot-password` (emails a 6-digit OTP, generic 200 either way, 5/min throttle) and
`POST /reset-password` (verifies OTP, sets the password, **invalidates the account's
api_token**).

- `domain/repository/auth_repository.dart` — `requestPasswordReset`, `resetPassword`
- `data/remote/auth_interceptor.dart` — both paths are in `_unauthenticatedPaths`; a stale
  token on them would 401 and bounce the user out of the flow they entered *because* they
  cannot sign in
- `data/remote/safe_api_call.dart` — new `429 → error(tooManyRequests)` branch
- `presentation/password_reset/` — one route, two steps (email → OTP + new password),
  6-box OTP over a single transparent field, 60s resend cooldown, 10-minute expiry
  estimate, header folds with the keyboard
- `presentation/password_reset/password_reset_handoff.dart` — a plain mailbox behind a
  `Provider`, **not** a `Notifier`: Riverpod forbids a provider modifying another provider
  during `build`, and `take()` is a write
- Entry points: Login ("Reset it") and Profile ("Change password", email locked). The
  Profile path clears the session on success and lands on Login, because the server has
  just killed the token

Two entry points, one difference: `initialEmail` + `lockEmail` on `PasswordResetScreen`.

---

## 4. Play submission — decisions already made

Reached through `/grill-me`; do not relitigate without reading the reasoning in
`docs/play/`.

| Topic | Decision |
|---|---|
| Channel | **Public production listing** (Managed Google Play private app was offered and declined) |
| Reviewer account | a demo account will be provided by B-Trac |
| Demo data | seed 5 requisitions spanning Pending / Approved / Assigned / Rejected / Cancelled; brief dispatch to ignore and cancel anything that account creates — reviewer actions hit the **production** TMS |
| Store graphics | generate 512×512 icon + 1024×500 feature graphic locally with Pillow from `refference-image/Logo1.png` + `assets/fonts/space_grotesk_bold.ttf` |
| Screenshots | capture from the demo account via `adb exec-out screencap`, then crop 1344×2992 → **1344×2688** (Play caps portrait at 1:2; this device's 20:9 panel produces 1:2.23 natively, which is rejected) |
| Old screenshots | `git rm` the eight in `screenshots/`, gitignore the folder, replace with clean captures |
| Pre-upload gates | run README §4 in full, **with** `--obfuscate --split-debug-info` |
| Privacy policy + Data Safety | **done** — 0 TODOs, mutually consistent, values from B-Trac |

Policy facts now published: B-Trac Solutions Limited, Plot 68, Road – 11, Block – H,
Banani, Dhaka - 1213; contact `psd.btraccl@gmail.com`; retention follows the company
schedule; deletion by writing to that address; the sign-in password is **declared** in the
Data Safety form (conservative reading, owner's decision).

---

## 5. Next actions, in order

Nothing here is started.

1. **README §4 gates**, all of them:
   ```bash
   flutter analyze && flutter test
   cd android && ./gradlew verifyReleaseSigning && cd ..
   flutter build appbundle --release --obfuscate --split-debug-info=build/symbols/1.0.0+1
   flutter build apk --release --target-platform android-arm64 \
     --obfuscate --split-debug-info=build/symbols/1.0.0+1
   tool/check_native_alignment.sh
   adb install -r build/app/outputs/flutter-apk/app-release.apk
   ```
   Then walk login → dashboard → list → detail → create (passenger) → create (logistics)
   → profile → logout **on hardware**. No release build so far has used the obfuscation
   flags, so this is the first time the real upload artifact runs anywhere.
2. **Generate store graphics** → `docs/play/assets/icon-512.png`,
   `feature-graphic-1024x500.png`; flip the status rows in `store-listing.md`.
3. **Screenshot hygiene** — `git rm` the eight in `screenshots/android/`, add
   `screenshots/` to `.gitignore`.
4. **`.gitignore` gaps** — `android/key.properties`, `*.jks`, `*.keystore`, `*.p12` are
   *not* ignored today. One `git add -A` publishes the signing passwords.
5. **Fill `store-listing.md`** — contact email, website `https://www.btracsolutions.com/`,
   privacy policy URL once hosted; correct the screenshot spec to the 1:2 crop.
6. **`app-access.md`** — record the seeded-5 + dispatch-briefing decision for whoever
   provisions the demo account.

Blocked on B-Trac, not on code:

- demo account + seeded requisitions + dispatch briefing → unblocks screenshots *and*
  review; per `docs/play/README.md` a missing reviewer login is the most common rejection
  for a login-walled app
- privacy policy URL — the text is final, it just needs hosting (owner is publishing it
  from a separate repo)
- decision to make `toufiqism/TMSS-flutter` public, and the cleanup the owner took on
  themselves: `api-contract/tms-requisition-api-updated.json` carries an example sign-in
  body that should not be in a public repo

---

## 6. Traps that already cost time here

- **Riverpod**: a provider may not modify another provider during `build` — that killed
  the first version of the reset→login handoff. Plain object behind a `Provider` instead.
- **`AnimatedSize` is the wrong tool for collapsing a header** — it animates to whatever
  the child reports, so the text reflows on the way out. `ClipRect` + `Align(heightFactor)`
  keeps the child at full size and clips it.
- **`MediaQuery.viewInsetsOf` must be read above the `Scaffold`** — the Scaffold strips the
  bottom inset from the MediaQuery it hands its body, so the same call inside always reads 0.
- **Widget tests catch layout defects unit tests cannot**: `responsive_layout_test.dart`
  found a 65–225px overflow in the reset screen at 2.0x text before any device saw it. Add
  new screens to that file.
- **The 60s resend cooldown is real time** — `fake_async` (dev dependency) is what keeps
  those tests instant.
- **`flutter install` uninstalls first**, so it wipes the session. Expect to sign in again
  after every install.
