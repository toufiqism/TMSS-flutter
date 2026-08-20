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

**TracGo** (`D:\Projects\TMSS-flutter`) is a **Flutter port of the native Android TMSS app** (`K:\TMSS`, package `com.banglatrac.tmss`), which is itself a client for the real "Carcopolo TMS" web app (white-labeled "Bangla Trac TMS", `https://tms.carcopolo.com/bt/`). This is a **separate sibling repo** with its own git history — not a folder inside `K:\TMSS`. No git repo has been initialized here yet (plain folder); when one is, follow rule 6 (init only, never commit).

Goal: pixel-match the Android app's forest-green redesign (colors, Manrope/Inter fonts, pill UI, grouped forms, unified stat panel) across **Android + iOS**, backed by fake repositories behind real domain interfaces, ready to swap in real backend APIs later — same approach the Android app used, since real API endpoints aren't available yet.

**App identity:** Android applicationId `com.btracsl.tracgo`, **iOS bundle id `com.btracsl.tracgo.ios`**, display name **"TracGo"**.
> The two ids deliberately differ. `com.btracsl.tracgo` could not be registered on the
> Apple Developer portal, so iOS took the `.ios` suffix; Android keeps the unsuffixed id
> because it is already live on Play as versionCode 2002. Do not "tidy" them back into
> matching — changing either one starts a new store listing that existing installs will
> not update to. The iOS id is set in all six `PRODUCT_BUNDLE_IDENTIFIER` lines of
> `ios/Runner.xcodeproj/project.pbxproj` (three Runner configs + three RunnerTests, the
> latter as `com.btracsl.tracgo.ios.RunnerTests`).
> Rebranded from `com.banglatrac.tmss` / "TMS". The id now differs from the native Android app's, so the two **can** be installed side by side — the earlier "uninstall one first" constraint no longer applies. Note that changing applicationId makes this a new listing on Play: existing installs of the old id will not update to it.

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
| iOS deployment target | 15.0 — **raised from 13.0**, forced by the Firebase iOS SDK |

The iOS deployment target is 15.0 because the Firebase SPM products
(`firebase-core`, `firebase-crashlytics`, `firebase-remote-config`) declare a 15.0
minimum; at 13.0 the build fails with "Target Integrity (Xcode): The package product
… requires minimum platform version 15.0". It is set in all three build configs in
`ios/Runner.xcodeproj/project.pbxproj`. No device support is lost — every iPhone/iPad
that runs iOS 13 also runs iOS 15.

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
│   │   ├── tracgo_api_client.dart # Dio-based client
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
│   └── common/                  # Shared widgets (status chip, requisition row, date/time field, pill toggle, stat panel, TracGoLogoMark)
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

## Design System — the "daylight" redesign

**Source of truth is the claude.ai/design project `TracGo App Screens.dc.html`** (project
`eb218760-e6f1-4e91-9769-6b8454edf3fd`, with its companion `TracGo Sign In.dc.html`), **not**
the Android app's `Color.kt` any more. The two diverged with this redesign and are not
being resynced: the app is now navy ink on a warm off-white page, with green reserved for
actions and lime used once per surface. Do not reinterpret the values during a port.

Tokens live in `lib/theme/colors.dart` and are named for their *role*, so a future
repalette touches one file:

| Role | Token | Value |
|---|---|---|
| Action green / links | `tracGoGreen` | `#2E5C34` |
| Pressed green | `tracGoGreenDark` | `#24492A` |
| Lime accent | `tracGoLime` | `#7AB648` |
| Ink (headings, dark cards) | `tracGoInk` (= `tracGoTextDark`) | `#12122B` |
| Body / muted / caption / faint | `tracGoTextBody` `tracGoTextMuted` `tracGoTextMutedAlt` `tracGoTextFaint` | `#4A5148` `#6B7269` `#8D948B` `#7A8179` |
| Placeholder | `tracGoPlaceholder` | `#A2A9A0` |
| Card outline / inner rule | `tracGoBorder` / `tracGoDivider` | `#E8EAE3` / `#F0F1EC` |
| Page / inset field | `tracGoPageBackground` / `tracGoInputBackground` | both `#F4F5F0` |
| Soft tint (avatars, selected rows) | `tracGoSurfaceSoft` | `#F1F3EC` |
| Sign In page | `tracGoSignInBackground` | `#FBFBF7` |
| Destructive | `tracGoDestructiveRed` | `#A4413A` |

Status colours are text/background/**dot** triples, reached through
`StatusPalette.of(status)` in `presentation/common/status_chip.dart` rather than by
picking constants at call sites: Pending `#7A5A00`/`#FBF0D5`/`#E0A82E`, Approved
`#2E5C34`/`#E2EFDE`/`#7AB648`, Assigned `#22254F`/`#E5E7F1`/`#3D4189`, Rejected
`#8C3E38`/`#F6E5E2`/`#A4413A`, Cancelled *and* Unknown neutral
`#5A6058`/`#E8EAE3`/`#B9BEB5`.

The violet "All Requisitions" hero ramp (`tracGoStatHero*`) is **gone** — the dashboard
replaced that tile with a plain eyebrow-plus-count. So are `tracGoGreenLight`,
`tracGoGreenLightAlt` and `tracGoLoginAccentGreen`; use `tracGoSurfaceSoft`,
`tracGoStatusApprovedBg` and `tracGoLime` instead.

**Fonts:** ~~Manrope + Inter~~ → **Space Grotesk** (400/500/700, display) + **Plus Jakarta Sans** (400/500/600/700, body), app-wide, adopted with the Sign In redesign. Manrope and Inter and their `.ttf` files are deleted — this is now the divergence point from the Android app's type scale.

Google publishes both families as variable fonts only; the static per-weight `.ttf` files in `assets/fonts/` were cut from the `wght` axis with `fontTools` (see README "Fonts"). Space Grotesk's axis stops at **700**, so the three roles that used Manrope's 800 now use 700 — asking for a weight a family does not ship makes the engine synthesise a fake bold.

Constants are role-named (`displayFontFamily`, `bodyFontFamily`) rather than family-named, so the next swap does not have to touch every call site.

**Shapes:** `extraSmall` 10 (icon wells), `small` 14 (inset fields, drawer rows), `medium` 16,
`stat tile` 18, `large` 20 (vehicle cards), **`card` 22 — the workhorse**, `extraLarge` 24
(dark hero cards), plus a fully-rounded `pillShape` / `pillBorderRadius`
(`BorderRadius.circular(999)`) for every button, toggle, chip and badge.

**Assets:** copy the launcher icon source and Font Awesome vector icons (clipboard-list, calendar-check, check-square, clock-outline, times-circle) from `K:\TMSS\app\src\main\res\drawable-nodpi\` / `drawable\` into `assets/images/`. `login_bg.jpg` is **gone** — the Sign In redesign replaced the photo hero with a centred logo, so the 370 KB asset and the `loginTagline*` strings were deleted rather than left orphaned.

**Brand mark.** `TracGoLogoMark` no longer draws the Android app's compass badge. It renders the real TracGo pin — green swoosh, navy road, car, traffic light, signal arcs — from `assets/images/tracgo_logo.svg` via `flutter_svg`, in two cuts:

| Variant | Asset | Where |
|---|---|---|
| `TracGoLogoVariant.color` | `tracgo_logo.svg` | login hero, top bar |
| `TracGoLogoVariant.mono` | `tracgo_logo_mono.svg` | drawer header (navy `#12122B` with a lime radial glow) |

The old `badgeColor`/`glyphColor` parameters are **gone**, not deprecated: the artwork is ten fixed brand colours and cannot honour a caller's two.

Both SVGs are traced from `refference-image/Logo1.png`, and every launcher/splash asset is derived from them (see "Regenerating the brand assets" in the README). The wordmark is deliberately cropped out — the top bar and drawer already set "TracGo" in text beside the mark.

**Shared components — build screens out of these, not out of stock Material.** The
daylight language is a small kit, and a screen that hand-rolls one of these will look
subtly wrong beside every other:

| Component | File | What it is |
|---|---|---|
| `SurfaceCard` / `SurfaceCard.rows` | `common/surface_card.dart` | The white, hairline-outlined container everything groups into. `.rows` inserts the inner rule *between* children only — never above the first. (The design file draws a leading rule; on device it reads as a stray line under the card's own border, so it was dropped everywhere.) Never a Material `Card` with elevation. |
| `DashedSurfaceCard` | `common/surface_card.dart` | Dashed-outline placeholder for a slot that is legitimately empty. |
| `SectionLabel` / `StepSectionLabel` | `common/section_label.dart` | The uppercase micro-caption; the numbered variant heads each step of the create form. Pass sentence case — it uppercases for display and keeps the readable string for screen readers. |
| `KeyValueRow` | `common/key_value_row.dart` | Label left, value hard right. Used by detail and profile. |
| `ChoicePill` / `ChoicePillRow` / `FilterPill` | `common/choice_pill.dart` | Inline enum choice (lime-tinted when selected); the list screen's heavier navy filter chip. **Replaced the old `DropdownField` and `RadioRow`, both deleted.** |
| `StatusChip` / `StatusDot` / `StatusPalette` | `common/status_chip.dart` | Renders `status.rawValue` — the server's own wording — one line, ellipsised, so callers must bound its width. Both render nothing when `status.hasValue` is false. `onDark: true` inverts the chip for the navy hero. Palettes are keyed on `RequisitionStatusKind`, never on the raw string. |
| `RequisitionRow` | `common/requisition_row.dart` | The **only** requisition row. Borderless, meant to live inside a `SurfaceCard.rows`. Used by both the list screen (`timeOnly: true`, under day headers) and the dashboard's Recent card (`timeOnly: false` + `showStatusDot: true`, no headers). **Replaced `RequisitionRecentRow`, deleted** — the dashboard's dot-plus-folded-timing variant was a second take on the same data and the two drifted apart; differences are now flags on one widget. |
| `FormCard` / `FormFieldRow` / `InlineTextField` / `DerivedValueRow` / `SelectableTypeCard` | `requisition_create/form_controls.dart` | The grouped form: fields are *rows in a shared card*, so the inputs themselves are borderless (`SyncedTextField(bare: true)`). |
| `DateTimeField` | `common/date_time_field.dart` | Value row only — its caption and error belong to the enclosing `FormFieldRow`. |

Typography roles live in `theme/typography.dart`; `tracGoScreenTitleStyle` is the top-bar
title and `tracGoChipTextStyle` the status pill. Both carry their tracking already — do
not reapply `letterSpacing` at call sites.

**Deliberate divergences from the design file** (each one is a data problem, not an
oversight; re-adding them needs backend support first):
- No "Aug 2026 / this month" badge on the dashboard hero — `allCount` is the whole
  history, not the current month.
- No ±  stepper on `No. of Persons` — the server requires it to equal the rider count
  exactly, so it renders as a derived value (`DerivedValueRow`).
- Profile's "Change password" button runs the **unauthenticated email-OTP reset**
  (`/forgot-password` + `/reset-password`), because no authenticated
  change-password endpoint exists. It therefore never asks for the current
  password, and succeeding invalidates the account's `api_token` — so the flow
  ends by clearing the session and landing on Login. The button's caption says so
  before the tap.
- The list screen keeps its existing date-range filters rather than the design's
  status/"This week" chips, which the list API does not support.
- The dashboard's **`+ New` button is unchanged** (small pill in the "Recent" header row)
  rather than the design's full-width button, by explicit request.

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
| firebase_core | Firebase initialisation (project `tracgo-631b7`) |
| firebase_crashlytics | Crash + non-fatal reporting, behind the `CrashReporter` interface |
| firebase_remote_config | Server-controlled flags, behind the `AppRemoteConfig` interface |

No `get_it`, no Bloc — deliberate exclusions per the decisions above.

Firebase **was** on that exclusion list and no longer is: Core, Crashlytics and
Remote Config were added deliberately. They are confined to
`core/telemetry/` and `core/remote_config/`, reached only through the
`CrashReporter` and `AppRemoteConfig` interfaces, and bound in `di/providers.dart`
with no-op defaults that `main` overrides — so `domain/`, `presentation/` and every
test still run with no Firebase binding present. See README "Firebase, Crashlytics
and Remote Config".

---

## Common Development Tasks

### Add a new screen
1. `presentation/<feature>/<feature>_screen.dart` (widget).
2. `presentation/<feature>/<feature>_notifier.dart` — Riverpod `AsyncNotifier`/`StateNotifier`.
3. Freezed `UiState` union (Loading/Success/Error, matching the Android sealed-state shape) + an events `StreamController` for one-shot signals (toast, navigation, `SessionExpired`).
4. Repository in `data/repository/` if it needs data, behind a `domain/repository/` interface.
5. Register the route in `presentation/nav/`; wire providers in `di/`.

### Add an API endpoint
1. Add the method to `data/remote/tracgo_api_client.dart` (Dio).
2. Once `SafeApiCall` is wired up, wrap the call and return `ApiResult<T>` from the repository instead of throwing.
3. Handle `ApiResult.logout()` in the notifier; emit a `SessionExpired` event through the events stream once real auth exists.

---

## Version & Release

- **Current version:** `1.0.1+2003` (`pubspec.yaml`) — update this line when it changes.
  Started at `1.0.0+1`; the build number jumped to the 2000s because `1.0.0` shipped to
  Play as versionCode 2002, and Play refuses any code not strictly greater than one it
  has already seen on any track.
- **Android minSdk / iOS deployment target:** 30 / 15.0.
