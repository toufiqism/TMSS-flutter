# TracGo — Transport Management System

Flutter client for the Bangla Trac / Carcopolo vehicle requisition module, targeting
Android and iOS from one codebase. Port of the native Android app
(`com.banglatrac.tmss`), matching its forest-green redesign.

**Login → Dashboard → My Requisitions → Requisition Detail → Edit**, plus New
Requisition in passenger and logistics variants, and a read-only Profile.

## Requirements

| Tool | Version |
|---|---|
| Flutter | 3.44.1 (stable) |
| Dart | 3.12.1 |
| Android minSdk / compileSdk | 30 / 37 |
| iOS deployment target | 13.0 |

`compileSdk` is pinned to 37 in `android/app/build.gradle.kts` rather than inherited
from `flutter.compileSdkVersion`: flutter_secure_storage ships AAR metadata requiring
it, and the Flutter default is lower, which fails `:app:checkDebugAarMetadata`.

## Getting started

```bash
flutter pub get
dart run build_runner build            # freezed models and unions
flutter run -d <device-id>
```

### Pointing at a backend

The base URL is compiled in, defaulting to production:

```bash
flutter run --dart-define=TMS_BASE_URL=https://tms.carcopolo.com/bt/api
```

Override it for a local or staging server. Android blocks cleartext HTTP by default on
API 28+, so a plain `http://` host needs a network security config before it connects.

## Commands

```bash
flutter analyze                        # static analysis — the standard verification step
flutter test                           # unit, mapper and notifier tests
flutter test test/path/to/file.dart    # a single target
dart run build_runner watch            # regenerate codegen while iterating

flutter build apk --debug
flutter build appbundle --release      # Play delivery — per-device ~20MB
flutter build apk --release --split-per-abi   # sideloading: one APK per ABI
flutter build ios --release            # requires macOS + Xcode
```

### Release signing

Release builds read `android/key.properties` (gitignored). If it is absent the build
still succeeds but falls back to the **debug** key and warns — convenient for
`flutter run --release`, useless for distribution. To turn that into a hard failure in CI
or before an upload:

```bash
cd android && ./gradlew verifyReleaseSigning
```

The keystore is `android/tms-release.jks`, alias `banglatrac`, certificate
`CN=B-Trac Solutions Limited, OU=TMS`, valid to 2053. Both it and `key.properties` are
gitignored and neither is tracked.

Signature schemes are set explicitly in `build.gradle.kts`: **v1 off** (only needed below
API 24; minSdk here is 30), **v3 on**. v3 carries the certificate lineage that allows a
published app to rotate to a new key later — it must be present from the first shipped
build, because an app released on v2 alone can never rotate afterwards.

> ⚠️ **Back up `tms-release.jks` and its passwords somewhere durable, before the first
> upload.** `com.btracsl.tracgo` is not yet published, so the key is still free to
> change; the moment it ships, that key *is* the app's identity. Without Play App Signing,
> losing it means never being able to update the listing again.
>
> Enrol in **Play App Signing** at first upload. Play then holds the app signing key and
> this one becomes a replaceable *upload* key, which turns "lost keystore, listing dead"
> into a support ticket.
>
> Rotate the passwords if they have been shared outside the team.

To replace the keystore, create one and repoint `key.properties` (see
`key.properties.example`). Keeping it outside the repo is preferable — `storeFile` is
resolved relative to `android/`, so `../../secrets/tms-release.jks` works:

```bash
keytool -genkeypair -v \
  -keystore ~/secrets/tms-release.jks -storetype JKS \
  -keyalg RSA -keysize 2048 -validity 10000 -alias banglatrac
```

### Android release shrinking

`isMinifyEnabled` (R8) and `isShrinkResources` are on for release. Note what that does
and does not buy on a Flutter app:

| Build | Size |
|---|---|
| Fat release APK (all 3 ABIs) | 53.6 MB |
| Per-ABI APK (arm64) | **19.6 MB** |
| App bundle | 51.7 MB upload, ~20 MB delivered |

R8 removed ~9,300 classes/members, but that is only worth ~0.1 MB: **51 of the 53 MB is
native `.so`** — the Flutter engine plus the Dart AOT snapshot — which R8 does not touch.
The real size lever is per-ABI splitting, which the app bundle does automatically.

Keep R8 on anyway: it obfuscates the Java/Kotlin surface and strips dead plugin code,
both worth having for a release artifact.

⚠️ **Retain `build/app/outputs/mapping/release/mapping.txt` for every release you ship.**
Release stack traces are obfuscated and cannot be read without the mapping file for that
exact build. Upload it to Play Console, or archive it alongside the artifact.

## Architecture

Clean Architecture, mirroring the Android app. Dependencies point inwards:
`presentation → domain ← data`, and `domain/` stays framework-free.

```
lib/
├── core/           ApiResult union, notifier lifecycle guards, API config,
│                   network messages, session expiry
│   ├── telemetry/  CrashReporter interface + Firebase impl, route breadcrumbs,
│   │               Firebase/error-handler bootstrap
│   └── remote_config/  AppRemoteConfig interface + Firebase impl and defaults
├── data/
│   ├── local/      Session storage (flutter_secure_storage + an install marker)
│   ├── remote/     Dio client, auth interceptor, safeApiCall, dto/ mappers
│   └── repository/ Remote*Repository — the only implementations
├── domain/         Models, repository interfaces, use cases, ApiCapabilities
├── presentation/   One folder per screen: screen + notifier + freezed UiState
├── theme/          Colors, typography, shapes
└── di/             Riverpod providers — these *are* the DI graph
```

- **State**: Riverpod `Notifier` + a freezed `UiState` per screen. One-shot events
  (navigation, toasts, session-expired) go through a `StreamController`, consumed with a
  subscription rather than `ref.watch` so a rebuild cannot replay them.
- **Lifecycle**: every notifier mixes in `NotifierLifecycle`, which guards `state` and
  event writes after disposal. Riverpod throws `UnmountedRefException` on a post-dispose
  `state` write, and a user backing out mid-request hits exactly that window.
- **Errors**: repositories return `ApiResult<T>` instead of throwing —
  `success` / `error` / `logout` / `maintenance` / `offline`. Every notifier handles
  every branch. HTTP 409 arrives as an `error` carrying `errorCode: 409` rather than a
  sixth union branch.
- **Navigation**: go_router with a session-gated redirect. Routes live in
  `route_paths.dart`; `/requisitions/new` must stay declared before `/requisitions/:id`,
  or `:id` swallows the literal "new".

### Refreshing versus invalidating

The dashboard and list notifiers are kept alive so they survive a trip to another screen
and back. That means `build()` — and their initial load — runs once per instance, so:

- **Refresh by calling a method** (`_refreshRequisitionViews`). `ref.invalidate` re-runs
  `build()` and closes the notifier's event stream out from under any screen still
  listening to it.
- **Except on logout**, where invalidation is correct and necessary: the session going
  null redirects to login and unmounts those screens, and without a reset a later
  sign-in returns the user to the stale error from the 401 that ended the last session.

## API status

Verified against the live server at `https://tms.carcopolo.com/bt/api`.
`api-contract/tms-requisition-api.json` is a draft reconstructed from a Postman
collection and is **wrong in several places** — see `lib/data/remote/README.md`, which
documents observed behaviour and where the contract diverges from it.

Endpoints used: `POST /login`, `POST /logout`, `GET /user`, `GET|POST /requisitions`,
`GET|PUT /requisitions/{id}`, `POST /requisitions/{id}/cancel`.

`GET /user` is the odd one out: it returns a **bare object** with no
`{success, message, data}` envelope, and carries no name or designation — those come from
the login response. So the Profile screen renders identity from the stored session and
account details from `/user`, and a failed fetch degrades only the latter. That response
also includes `remember_token` in plaintext; the client never reads it.

Search, sort and the dashboard counts have no endpoint behind them and are derived
client-side from the list (bounded — see `ApiConfig`). Employee lookup is the one
capability still unsupported: no endpoint exists, so that picker is disabled via
`ApiCapabilities` rather than sent speculatively.

DTO parsing is hand-written and tolerant rather than generated. Most response schemas in
the contract were guesses, and a strict generated parser would throw on the first field
that disagrees — taking a screen down over a value the UI may not even show.

To re-verify against the server:

```bash
# Drives the real Dio stack end-to-end and cancels every requisition it creates.
dart run test/live_api_check.dart --user <email> --pass <password>
```

UI behaviour is verified by running the app on a device or simulator — see
"Verifying on both" in `CLAUDE.md`.

### Session storage

The session (token, profile, expiry) is one JSON blob in flutter_secure_storage —
Keychain on iOS, Keystore-backed on Android. Three behaviours worth knowing:

- iOS Keychain items **survive app uninstall**, so a reinstall would otherwise resurrect
  a dead session. `SessionLocalDataSource` detects a fresh install via a marker in
  `shared_preferences` (which *is* wiped on uninstall) and clears the orphaned entry.
- The token's `expires_at` is stored and honoured: an expired session is dropped at
  launch rather than sent and bounced by a 401.
- Sign-out calls `POST /logout` to revoke server-side before clearing locally. Tokens
  last about a year, so a purely local sign-out would leave a working token behind.

iOS accessibility is pinned to `first_unlock_this_device` — readable after the first
unlock following a reboot, and never synced to iCloud Keychain, so a corporate session
does not travel to the user's other devices. Android needs no equivalent option;
flutter_secure_storage 11 already defaults to AES-GCM under an RSA-OAEP Keystore key.

## Firebase, Crashlytics and Remote Config

Firebase project **`tracgo-631b7`**, one app per platform, both under the bundle id
`com.btracsl.tracgo` (app ids `...:android:717e99075de2620daa30da` and
`...:ios:bd45970b8f04cb90aa30da`). The two apps registered under the pre-rebrand id
`com.banglatrac.tmss` still exist in the project, unused — `google-services.json` carries
both Android clients, which is harmless because the plugin matches on package name.
Config lives in three generated files, all committed: 
`lib/firebase_options.dart`, `android/app/google-services.json` and
`ios/Runner/GoogleService-Info.plist`. The keys in them are client identifiers, not
secrets — access is controlled by Firebase security rules, not by hiding them.

`main()` calls `bootstrapTelemetry()` before `runApp`. It **never throws**: if Firebase
fails to start, the app runs on `Telemetry.disabled` (a no-op reporter and the
compiled-in config defaults) with Flutter's own error handlers left untouched, so
errors still reach the console. Crash collection is currently **enabled in debug builds
too** — flip the `setCrashlyticsCollectionEnabled(true)` call in
`core/telemetry/telemetry_bootstrap.dart` to `!kDebugMode` to keep development crashes
out of the dashboard.

### What gets reported

| Source | Treatment |
|---|---|
| `FlutterError.onError` | fatal, chained to the previous handler so the console dump survives |
| `PlatformDispatcher.instance.onError` | fatal; returns `false` so the framework still prints |
| 5xx (except 503), timeouts, bad certificate, undecodable 2xx, unclassified throws | non-fatal, keyed with `operation` + `status` |
| 401/403/404/409/422/503, offline, cancelled | breadcrumb only — specified behaviour, not defects |
| Every navigation | breadcrumb (`CrashRouteObserver`, on both the root and shell navigators) |

The split is deliberate: a non-fatal per failed request would bury real defects under
the ones working as designed. Breadcrumbs still ride along with whatever is reported
next, so a crash after a run of 401s stays diagnosable.

User identity is `User.id` and nothing else — no name, no email. Crash reports are
retained by a third party and readable by anyone with console access.

Nothing in `domain/` or `presentation/` imports `firebase_*`. Everything talks to the
`CrashReporter` / `AppRemoteConfig` interfaces, bound in `di/providers.dart` and
overridden in `main`, which is what lets every test build the same graph with no
Firebase binding.

### Remote Config

Two keys, both defaulting to "do nothing" so a failed fetch can never lock users out or
invent an outage: `minimum_supported_build` (0 = gate off) and `maintenance_message`
(empty = nothing to show). **No UI consumes them yet** — the service is wired and
fetching, but the force-update and maintenance surfaces are not built.

`api_base_url` is deliberately *not* a remote key: it decides where the app sends a
bearer token and a password. It stays a compile-time `--dart-define` (see `ApiConfig`).

### iOS — one step needs a Mac

`flutterfire configure` cannot patch an Xcode project from Windows, so the iOS side was
wired by hand: `GoogleService-Info.plist` was fetched from the Firebase project and
added to the Runner target's Resources, and an **Upload Crashlytics dSYMs** build phase
was added that runs `ios/scripts/upload_crashlytics_dsyms.sh`. Because this project has
no Podfile — plugins come through Swift Package Manager — that script looks for the
helper under `SourcePackages/checkouts/firebase-ios-sdk/Crashlytics/run`, falling back
to the CocoaPods path, and warns rather than failing when neither exists.

None of that has been compiled or run: there is no macOS toolchain on this machine.
Open `ios/Runner.xcworkspace` and build once to confirm Xcode accepts the project edit,
that `GoogleService-Info.plist` appears under Build Phases → Copy Bundle Resources, and
that the dSYM phase runs on an Archive.

### Verifying it works

Force a crash from a debug build, then restart the app — Crashlytics uploads on the
next launch, never during the crash itself:

```dart
FirebaseCrashlytics.instance.crash();      // fatal
throw StateError('non-fatal smoke test');  // caught by PlatformDispatcher.onError
```

Reports land in the Firebase console within a few minutes. Android release builds
upload their R8 mapping automatically via the Crashlytics Gradle plugin
(`com.google.firebase.crashlytics` 3.0.7); Flutter's own `libapp.so` frames stay
unsymbolicated unless NDK symbol upload is added separately.

## Testing

`flutter_test` + `mocktail`, with Riverpod providers overridden via `ProviderContainer`.
**157 tests**, no widget or golden tests yet.

```
test/data/          mappers, timezone conversion, safeApiCall status branches,
                    repositories, session storage
test/presentation/  one notifier test per screen
test/live_api_check.dart      opt-in probe against the live server (not run by `flutter test`)
```

Two rules the suite holds to:

- Every notifier test covers the success branch **and** each `ApiResult` failure branch —
  `error`, `offline`, `maintenance`, `logout`.
- Notifiers using `isAutoDispose` need a held subscription in tests
  (`container.listen(...)`), or they are torn down before an awaited call resolves —
  exactly as a mounted screen holds them.

## Linting

`flutter_lints` plus `strict-casts`, `strict-inference` and `strict-raw-types`, with
`unawaited_futures` promoted to an error. The strict modes matter most in
`data/remote/dto/`, where every value arrives as `dynamic` off a decoded JSON map.
