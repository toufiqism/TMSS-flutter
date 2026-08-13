# TMS — Transport Management System

Flutter client for the Bangla Trac / Carcopolo vehicle requisition module, targeting
Android and iOS from one codebase. Port of the native Android app
(`com.banglatrac.tmss`), matching its forest-green redesign.

Screens: **Login → Dashboard → My Requisitions → New Requisition**.

## Requirements

| Tool | Version |
|---|---|
| Flutter | 3.44.1 (stable) |
| Dart | 3.12.1 |
| Android minSdk | 30 |
| iOS deployment target | 13.0 |

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

Override it for a local or staging server. Note that Android blocks cleartext HTTP by
default on API 28+, so a plain `http://` host needs a network security config before it
will connect.

## Commands

```bash
flutter analyze                        # static analysis — the standard verification step
flutter test                           # unit and notifier tests
flutter test test/path/to/file.dart    # a single target
dart run build_runner watch            # regenerate codegen while iterating

flutter build apk --debug
flutter build appbundle --release
flutter build ios --release            # requires macOS + Xcode
```

## Architecture

Clean Architecture, mirroring the Android app. Dependencies point inwards:
`presentation → domain ← data`, and `domain/` stays framework-free.

```
lib/
├── core/          ApiResult union, notifier lifecycle guards, session expiry
├── data/
│   ├── local/     Session storage (flutter_secure_storage)
│   ├── remote/    Dio client, interceptors, DTO mappers, safeApiCall
│   └── repository/
├── domain/        Models, repository interfaces, use cases
├── presentation/  One folder per screen: screen + notifier + freezed UiState
├── theme/         Colors, typography, shapes
└── di/            Riverpod providers — these *are* the DI graph
```

- **State**: Riverpod `Notifier` + a freezed `UiState` per screen. One-shot events
  (navigation, toasts, session-expired) go through a `StreamController`, consumed with a
  subscription rather than `ref.watch` so a rebuild cannot replay them.
- **Errors**: repositories return `ApiResult<T>` instead of throwing —
  `success` / `error` / `logout` / `maintenance` / `offline`. Every notifier handles
  every branch.
- **Navigation**: go_router with a session-gated redirect.

## API status

The client is verified against the live server at `https://tms.carcopolo.com/bt/api`.
`api-contract/tms-requisition-api.json` is a draft reconstructed from a Postman
collection and is **wrong in several places** — see `lib/data/remote/README.md`, which
documents observed behaviour and where the contract diverges from it.

Employee lookup is the one capability still unsupported (no endpoint exists), so that
picker is disabled rather than sent speculatively.

To re-verify against the server:

```bash
# API layer only — drives the real Dio stack, cancels every requisition it creates.
dart run test/live_api_check.dart --user <email> --pass <password>

# Full UI flow on a device/simulator, read-only against the server.
# Screenshots land in build/screenshots/.
flutter drive --driver=test_driver/integration_test.dart \
  --target=integration_test/smoke_test.dart -d <device-id> \
  --dart-define=TMS_USER=<email> --dart-define=TMS_PASS=<password>
```

### Session storage

The session (token, profile, expiry) is one JSON blob in flutter_secure_storage —
Keychain on iOS, Keystore-backed on Android. Two behaviours worth knowing:

- iOS Keychain items **survive app uninstall**, so a reinstall would otherwise resurrect
  a dead session. The data source detects a fresh install via a marker in
  `shared_preferences` (which *is* wiped on uninstall) and clears the orphaned entry.
- The token's `expires_at` is stored and honoured: an expired session is dropped at
  launch rather than being sent and bounced by a 401.

iOS accessibility is pinned to `first_unlock_this_device` — readable after the first
unlock following a reboot, and never synced to iCloud Keychain, so a corporate session
does not travel to the user's other devices.

## Testing

`flutter_test` + `mocktail`, with Riverpod providers overridden via `ProviderContainer`.
Notifier and mapper coverage; no widget or golden tests yet. Every notifier test covers
the success branch **and** each `ApiResult` failure branch.
