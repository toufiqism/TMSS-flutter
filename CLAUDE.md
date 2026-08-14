# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

---

# WORKING STYLE (portable — keep across repos)

### Communication mode

**Always reply in `caveman` mode.** Ultra-compressed prose — drop articles, filler, pleasantries, hedging. Keep full technical accuracy: file paths, line numbers, exact API names, build commands, error codes. Applies to every response regardless of topic. If the `caveman` skill is loaded, invoke it; otherwise apply the style manually. **Code blocks and file contents are exempt** (write code normally).

### Core rules (apply to every task)

1. **Read files first.** Open and inspect the relevant code before proposing or writing changes — never edit blind.
2. **Write a complete solution.** Ship the full change in one pass; no half-finished implementations, TODOs, or stubs for the user to fill in.
3. **Test once.** Run the appropriate verification (`flutter analyze`, the relevant `flutter test` target, or a manual smoke for UI) one time after the change. Don't loop on green builds; don't skip the check entirely.
4. **Always check nulls and handle errors.** Every nullable value is null-checked before use. Every API call, repository result, and user input has explicit error handling — never assume success.
5. **No happy-path-only code.** Never implement only the success path. Every change explicitly handles failure, empty, null, timeout, offline, cancellation, concurrency, and lifecycle/disposal edge cases that apply. Before finishing, enumerate the non-happy paths for the code touched and confirm each is handled (early-return guard, error branch, fallback, or user-facing message) — not silently ignored. If a path is intentionally out of scope, say so explicitly.
6. **Never commit or push.** Do not run `git commit`, `git push`, `git tag`, `git merge`, `git rebase`, or any history/remote-modifying git command. Stop at staged/unstaged changes and let the user commit. This holds even if a plan lists a "commit" step — treat it as the user's. Read-only git (`status`, `diff`, `log`, `show`, `branch --list`) is fine.
7. **Match existing conventions.** Prefer the patterns already in the codebase over introducing new ones. If a better pattern exists, propose it explicitly rather than silently mixing paradigms.
8. **Both platforms, every time.** This app ships Android *and* iOS. Any change touching config, permissions, storage, or platform APIs must be made — and checked — on both, not on whichever one is convenient to run. When something genuinely only applies to one, say so explicitly rather than leaving the other silently unhandled. If a change was only *verified* on one platform, state that plainly in the report instead of implying parity. See "Platform parity" below for the paired locations.

### Clarify before acting

**Always ask clarifying questions before doing anything the user asks.** Do not jump into code as soon as a request arrives — confirm scope and intent first, whether it is a feature, bug fix, refactor, or UI change.

**For any non-trivial task, follow this sequence before writing code:**

1. **`/grill-me`** — interview the user relentlessly until every branch of the decision tree is resolved. Runs *before* Plan.
2. **Plan** — outline approach and architectural decisions.
3. **Design** — component structure, data flow, UI layout if applicable.
4. **Requirements** — acceptance criteria (golden path + error/edge cases).
5. **Task breakdown** — discrete implementation steps in order.
6. **Wait for approval** — present the above and pause. Do not execute until the user explicitly approves.

Skip steps 1–6 only for clearly trivial one-liners (typo, single rename, one-line config). Everything else goes through the sequence.

**For feature requests, ask (only the non-obvious ones):**
- Exact user-facing behavior — golden path and each error/edge case?
- Where it lives (which screen; new screen vs. extension of existing).
- Data source — existing endpoint, new endpoint, or local-only?
- Lifecycle/scope — one-shot, polling, persisted across sessions, or per-screen?
- Visual reference — Figma link, mockup, or existing screen to mirror?
- Out-of-scope items the user explicitly does NOT want changed.

**For bug fixes, ask (only the non-obvious ones):**
- Exact reproduction steps and the device/build where observed.
- Expected vs. actual behavior.
- Regression (when did it last work) or long-standing?
- Logs, stack traces, or screenshots if available.
- Acceptable scope — minimal patch vs. root-cause refactor.

Use `AskUserQuestion`, batched into one round when possible. Skip questions whose answers are already in the request, the code, or recent context.

---

# PROJECT-SPECIFIC

## Project Overview

**TMS** (`K:\TMSS-flutter`) is a **Flutter port of the native Android TMSS app** (`K:\TMSS`, package `com.banglatrac.tmss`), which is itself a client for the real "Carcopolo TMS" web app (white-labeled "Bangla Trac TMS", `https://tms.carcopolo.com/bt/`). This is a **separate sibling repo** with its own git history — not a folder inside `K:\TMSS`. No git repo has been initialized here yet (plain folder); when one is, follow rule 6 (init only, never commit).

Goal: pixel-match the Android app's forest-green redesign (colors, Manrope/Inter fonts, pill UI, grouped forms, unified stat panel) across **Android + iOS**, backed by fake repositories behind real domain interfaces, ready to swap in real backend APIs later — same approach the Android app used, since real API endpoints aren't available yet.

**App identity:** applicationId / bundle id `com.banglatrac.tmss` (same as the native app), display name **"TMS"**.
> ⚠️ Same package ID as the native Android app — the two cannot be installed on one device at the same time. During side-by-side testing, uninstall one before installing the other.

**Feature scope (build all at once, matching what's verified on the Android side):**
Login → Dashboard → My Requisition list → New Requisition (Passenger + Logistics variants).

## Toolchain & Versions

Pinned to what's installed on this machine (confirmed via `flutter --version` on 2026-08-13):

| Tool | Version |
|---|---|
| Flutter | 3.44.1 (stable channel) |
| Dart | 3.12.1 |
| Android minSdk | 30 (matches native app) |
| Android compileSdk | 37 — **pinned**, not `flutter.compileSdkVersion` |
| iOS deployment target | 13.0 |

`compileSdk` is pinned in `android/app/build.gradle.kts` because flutter_secure_storage
ships AAR metadata requiring 37, and the Flutter default is lower — the Android build
fails `:app:checkDebugAarMetadata` without it. Do not "tidy" it back to the inherited value.

## Platform parity

Android and iOS are both first-class. These things live in **two places** — changing one
without the other is the recurring failure mode here, and it is silent on whichever
platform you did not run:

| Concern | Android | iOS |
|---|---|---|
| App display name | `AndroidManifest.xml` `android:label` | `Info.plist` `CFBundleDisplayName` **and** `CFBundleName` |
| Network access | `<uses-permission android:name="android.permission.INTERNET"/>` in the **main** manifest (the Flutter template only adds it to debug/profile, so release builds have no network) | nothing needed |
| Min OS | `minSdk` in `build.gradle.kts` | `IPHONEOS_DEPLOYMENT_TARGET` in `project.pbxproj` |
| Cleartext HTTP | blocked by default on API 28+; needs a network security config | needs an ATS exception |

Real divergences already encountered — do not assume symmetry:

- **Secure storage lifetime.** iOS Keychain items **survive app uninstall**; Android's do
  not. A reinstall would otherwise resurrect a dead session, so `SessionLocalDataSource`
  clears it using a `shared_preferences` marker (prefs *are* wiped on uninstall).
- **Secure storage options.** iOS needs an explicit `KeychainAccessibility`; Android on
  flutter_secure_storage 11 needs nothing — its defaults are already AES-GCM under an
  RSA-OAEP Keystore key. The `encryptedSharedPreferences` flag is v9-era and no longer
  exists. Check the installed package's source before adding platform options.
- **Text scaling.** Both platforms scale text, by different mechanisms and to different
  maxima (iOS reaches ~3.1x). Layout verified on one is not verified on the other.

### Verifying on both

`flutter analyze` and `flutter test` are platform-agnostic and prove neither. For anything
touching UI or platform behaviour, build **and run**:

```bash
flutter build apk --debug             # Android compiles
flutter build ios --simulator --debug # iOS compiles
flutter run -d <device-id>            # and actually run it on each
```

Compiling proves nothing about layout. Run the app on an Android emulator *and* an iOS
simulator, and scan the log for `overflowed by`, `EXCEPTION CAUGHT BY` and
`Failed assertion` — layout defects frequently do not surface any other way.

Known Android friction: a fat debug APK is ~166MB, and installs fail with
`INSTALL_FAILED_INSUFFICIENT_STORAGE` on an emulator whose userdata is near full.
`flutter build apk --debug --target-platform android-arm64` roughly halves it; otherwise
free space on the AVD.

To exercise text scaling, iOS: `xcrun simctl ui <device> content_size accessibility-extra-extra-extra-large`;
Android: `adb shell settings put system font_scale 1.5` (and `wm density` for display size).

## Build System & Commands

```bash
# Fetch dependencies
flutter pub get

# Codegen (freezed models/unions, json_serializable, go_router if annotation-based)
dart run build_runner build --delete-conflicting-outputs
dart run build_runner watch --delete-conflicting-outputs   # while iterating

# Static analysis (fast verification — preferred for the "Test once" rule)
flutter analyze

# Run unit/notifier tests
flutter test

# Run a specific test file
flutter test test/presentation/login/login_notifier_test.dart

# Run on a connected device/emulator
flutter run -d <device-id>

# Build
flutter build apk --debug
flutter build appbundle --release
flutter build ios --release   # requires macOS/Xcode toolchain

# Clean
flutter clean
```

**Manual smoke testing is done by the user, not Claude, for this project.** After a UI change, run `flutter analyze` + relevant `flutter test`, then tell the user what to check — do not attempt `adb`/simulator automation here unless explicitly asked. The user will report back pass/fail.

---

## Architecture (Clean Architecture, mirrors the Android app)

```
lib/
├── core/
│   ├── api_result.dart          # Freezed sealed union: Success/Error/Logout/Maintenance/Offline
│   └── session_expiration_handler.dart
│
├── data/
│   ├── local/                   # flutter_secure_storage (session) + shared_preferences (prefs)
│   ├── remote/
│   │   ├── tmss_api_client.dart # Dio-based client
│   │   └── safe_api_call.dart   # Error-handling wrapper — not yet used until real API exists
│   └── repository/              # Fake*Repository implementations (see below)
│
├── domain/
│   ├── model/                   # Freezed data classes + unions (mirrors Kotlin domain/model)
│   ├── repository/              # Abstract repository interfaces
│   └── usecase/                 # One class per use case, mirrors Android's usecase/ 1:1
│
├── presentation/
│   ├── login/
│   ├── dashboard/
│   ├── requisition_list/
│   ├── requisition_create/
│   ├── nav/                     # go_router config, session-gated redirect
│   └── common/                  # Shared widgets (status chip, requisition row, date/time field, pill toggle, stat panel, TmsLogoMark)
│
├── theme/                       # Colors, typography (Manrope/Inter), shapes (incl. PillShape)
│
└── di/                          # Riverpod provider graph (repositories, use cases, Dio client)
```

Dependency direction is the same as the Android app: `presentation → domain ← data`. `domain/` stays framework-free (no Flutter/Dio/Riverpod imports).

### DI

**Riverpod providers *are* the DI graph** — no separate service locator (no `get_it`). Repositories, use cases, and the Dio client are all exposed via `Provider`/`Provider.family`. Don't run two DI systems side by side.

### State management

**Riverpod**, mapped from the Android ViewModel/StateFlow pattern:
- `AsyncNotifier`/`StateNotifier` + a Freezed `UiState` union ≈ `ViewModel` + `StateFlow<UiState>`.
- One-shot events (navigation, toasts, session-expired) have no native Riverpod equivalent to Kotlin's `Channel`/`receiveAsFlow` — use a dedicated `StreamController.broadcast()` exposed via a provider, consumed with `ref.listen` in the widget (not `ref.watch`, to avoid rebuild-driven replay).
- ViewModels/Notifiers take no `BuildContext`; user-facing strings go through Flutter's own localization (`AppLocalizations`) once needed — no `ResourceProvider` indirection layer required here since Dart already separates that concern.

### Networking & serialization

- **dio** for HTTP — interceptor chain mirrors the Android app's OkHttp interceptors (auth/token, logging, connectivity). Base URL is a placeholder constant for now (no real API yet), same caveat as the Android app's `TmssApiService.BASE_URL`.
- **freezed + json_serializable** for models and sealed unions. `ApiResult<T>` is a Freezed union with branches `success(T)` / `error(String? message, int? code)` / `logout(String message, int code)` / `maintenance(String message, int code)` / `offline(String message)` — no `loading` branch, same reasoning as the Kotlin version (a `Future`/async call returning "loading" is nonsensical).
- **SafeApiCall wrapper**: prepared (`data/remote/safe_api_call.dart`) but unused until real endpoints exist. Maps `401` → `logout`, `503` → `maintenance`, `SocketException`/no connectivity → `offline`, other non-2xx → `error`.
- Token refresh (proactive + reactive via a Dio `Interceptor`) is a stub for later — not wired up until real auth exists, same as the Android app.

### Local persistence

- **flutter_secure_storage** for the session/auth token (Keystore/Keychain-backed) — this is credentials-adjacent data, so it does not belong in plain prefs, unlike the Android app's current DataStore-based session store which predates this distinction.
- **shared_preferences** for non-sensitive app prefs.
- No offline cache/local DB yet (mirrors `TmssRepositoryImpl` on the Android side — no local cache today either).

### Fake repositories

`data/repository/fake_*_repository.dart` implement the `domain/repository/` interfaces in-memory, ready to swap for real Dio-backed implementations later. **Reuse the exact same synthetic seed data as the Android app**: demo username `tofiq.akbar@btracsl.com` / synthetic password `demo1234` (never the real password), the same synthetic (non-real) employee names, the same 5 sample requisitions spanning statuses. Never embed the real scraped employee directory or the real login password in source — same constraint as the Android app.

### Navigation

**go_router**. Routes mirror `Route.kt`'s sealed set (Login/Dashboard/RequisitionList/NewRequisition). Session-gated redirect (logged-out → Login) via `redirect:` + a `Listenable` driven by the session provider, equivalent to `SessionViewModel`'s `Loading`/`Resolved` gate in `AppShell.kt`.

---

## Design System — pixel-match the Android redesign

Port these verbatim from `K:\TMSS\app\src\main\java\com\banglatrac\tmss\ui\theme\Color.kt` — do not reinterpret or "clean up" during the port:

TmsGreen `#2F5A3F`, TmsGreenDark `#1F3B2C`, TmsGreenLight `#EAF3E4`, TmsGreenLightAlt `#DCEFD3`, TmsLoginAccentGreen `#8FD98F`, TmsTextDark `#16231A`, TmsTextMuted `#7A857E`, TmsTextMutedAlt `#8A938C`, TmsTextSubtle `#5B6660`, TmsPlaceholder `#B8BFB6`, TmsBorder `#E3E9DF`, TmsDivider `#EDF0EA`, TmsInputBackground `#FAFCF9`, TmsScreenBackground `#F6F8F5`, TmsPageBackground `#F0F3EE`, TmsSurfaceWhite, status colors (All/Approved/Assigned/Pending/Rejected — purple/green/teal/orange/red variants incl. text+bg pairs), TmsDestructiveRed `#C4453A` (distinct from TmsStatusRejectedRed), TmsLauncherNavy.

**Fonts:** Manrope (medium/bold/extrabold) + Inter (regular/medium/semibold). Copy the `.ttf` files directly from `K:\TMSS\app\src\main\res\font\` into `assets/fonts/` — already downloaded from Google Fonts, no need to re-fetch.

**Shapes:** `extraSmall` 10dp, `small` 14dp, `medium` 16dp, `large` 20dp, `extraLarge` 24dp, plus a fully-rounded `PillShape` (`BorderRadius.circular(999)`), matching `Shape.kt`.

**Assets:** copy `login_bg.jpg`, launcher icon source, and Font Awesome vector icons (clipboard-list, calendar-check, check-square, clock-outline, times-circle) from `K:\TMSS\app\src\main\res\drawable-nodpi\` / `drawable\` into `assets/images/`. `TmsLogoMark` (the compass-icon badge) was originally a Canvas-drawn Composable — port it as a `CustomPainter`, not a rasterized image, to keep it crisp at any size.

**Custom widgets to port 1:1** (not stock Material defaults): pill-shaped status chip, bordered (non-elevated) requisition row card, unified 2-column stat panel with full-width rejected row, custom pill-segmented toggle (Passenger/Logistics), radio-row pill chips with dot indicator, combined date+time picker field, gradient hero card + gradient nav-drawer header.

**Platform note (iOS is in scope):** stick to Material 3 widgets everywhere for pixel-match fidelity — do not substitute Cupertino widgets. Do still respect iOS safe-area insets (`SafeArea`/`MediaQuery.padding`) the same way `statusBarsPadding()` was needed on the Android Login screen; screens without a `Scaffold`+`AppBar` need explicit safe-area handling on both platforms.

---

## Testing

**Stack:** `flutter_test` + `mocktail` + Riverpod's `ProviderContainer` (override providers with fakes/mocks in tests — the Dart equivalent of the Android app's fake-repo-backed ViewModel tests).

**Scope for now:** notifier/unit tests only — no widget or golden tests yet (matches the Android app's current test scope; add golden tests later only if visual regressions become a real problem).

Cover the success branch **and** each `ApiResult` failure branch (`error`/`offline`/`logout`) for every notifier under test — a test that only asserts the success case is incomplete, same rule as the Android side.

```dart
test('emits error state when repository returns failure', () async {
  final container = ProviderContainer(overrides: [
    requisitionRepositoryProvider.overrideWithValue(FakeFailingRepository()),
  ]);
  addTearDown(container.dispose);

  final notifier = container.read(requisitionListProvider.notifier);
  await notifier.load();

  expect(container.read(requisitionListProvider), isA<RequisitionListError>());
});
```

---

## Linting

`flutter_lints` (official Flutter defaults) via `analysis_options.yaml`. `flutter analyze` is the "Test once" verification step for non-UI changes.

---

## Key Dependencies

Exact versions get pinned once `flutter pub get` first resolves them — list here for reference, don't hand-pick versions without checking `pub.dev` for current stable releases at scaffold time:

| Package | Purpose |
|---|---|
| flutter_riverpod | State management + DI (plain `Notifier`/`NotifierProvider`, no codegen — `riverpod_generator`'s current release lags `riverpod_annotation`'s, so codegen was dropped after a real version-solve conflict) |
| go_router | Routing, session-gated redirect |
| dio | HTTP client + interceptors |
| freezed / freezed_annotation | Sealed unions, immutable models |
| json_serializable | JSON codegen |
| build_runner | Codegen runner (freezed/json_serializable) |
| flutter_secure_storage | Session/token storage |
| shared_preferences | Non-sensitive local prefs |
| mocktail | Test doubles (no codegen, unlike mockito) |
| flutter_lints | Lint ruleset |

No Firebase, no `get_it`, no Bloc — deliberate exclusions per the decisions above.

---

## Common Development Tasks

### Add a new screen
1. `presentation/<feature>/<feature>_screen.dart` (widget).
2. `presentation/<feature>/<feature>_notifier.dart` — Riverpod `AsyncNotifier`/`StateNotifier`.
3. Freezed `UiState` union (Loading/Success/Error, matching the Android sealed-state shape) + an events `StreamController` for one-shot signals (toast, navigation, `SessionExpired`).
4. Repository in `data/repository/` if it needs data, behind a `domain/repository/` interface.
5. Register the route in `presentation/nav/`; wire providers in `di/`.

### Add an API endpoint
1. Add the method to `data/remote/tmss_api_client.dart` (Dio).
2. Once `SafeApiCall` is wired up, wrap the call and return `ApiResult<T>` from the repository instead of throwing.
3. Handle `ApiResult.logout()` in the notifier; emit a `SessionExpired` event through the events stream once real auth exists.

---

## Version & Release

- **Starting version:** `1.0.0+1` (`pubspec.yaml`) — update this line when it changes.
- **Android minSdk / iOS deployment target:** 30 / 13.0.
