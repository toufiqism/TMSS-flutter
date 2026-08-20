# Google Play release checklist — TracGo

Everything needed to get `com.btracsl.tracgo` onto Google Play, in the order it has to
happen. The repo-side work is done and verified; the Console-side work needs data only
B-Trac holds, marked **TODO(owner)** throughout these files.

| File | What it is for |
|---|---|
| `README.md` (this file) | build, verify, archive, upload — the ordered procedure |
| `data-safety.md` | question-by-question answers for the Data Safety form |
| `privacy-policy.md` | final policy text — no placeholders; publish as-is at a public URL |
| `app-access.md` | reviewer credentials and navigation steps — **without this, review fails** |
| `store-listing.md` | title, descriptions, graphics spec, content rating answers |

---

## 0. Decide the distribution channel first

This is an employee app. There is no sign-up: accounts are provisioned in the Carcopolo
TMS backend by B-Trac, and someone without one cannot get past the first screen.

That makes **Managed Google Play (private app)** the better fit than a public listing —
published to your Google Workspace organisation only, no store listing copy, no content
rating, no reviewer credentials, no "why can't I register" one-star reviews from people
who found it by accident.

A public production listing still works, and everything below assumes it, because that
is the harder path and the one that was asked for. If you switch to a private app, skip
§6 and `store-listing.md`; the rest still applies.

---

## 1. One-time Console setup

1. Create the app in Play Console: **TracGo**, default language English (United States),
   type **App**, **Free**.
2. **Enrol in Play App Signing at the first upload.** Play then holds the real signing
   key and `android/tms-release.jks` becomes a replaceable *upload* key. Without it, a
   lost keystore means the listing can never be updated again — a permanent, unfixable
   failure. With it, the same event is a support ticket.
3. Back up `android/tms-release.jks`, `android/key.properties` and their passwords
   somewhere durable and off this machine, **before** the first upload.
4. Fill in Store settings → app category **Business**, contact email, and the privacy
   policy URL from §6.

---

## 2. Set the version

`pubspec.yaml` → `version: 1.0.0+1`. The `+N` build number becomes Android's
`versionCode`.

Play refuses any upload whose `versionCode` is not strictly greater than every code
already uploaded to any track — including one that was uploaded and then discarded. Bump
`+N` for every single upload attempt, not for every user-visible release.

The first upload goes out as `1.0.0+1`.

---

## 3. Build the upload artifact

From a clean tree, with `android/key.properties` present:

```bash
flutter clean
flutter pub get
dart run build_runner build --delete-conflicting-outputs

flutter build appbundle --release \
  --obfuscate --split-debug-info=build/symbols/1.0.0+1
```

The obfuscation flags are not optional — see README "Obfuscation and symbols". The
version in the symbol path must match the version being shipped, or the symbols are
useless later.

---

## 4. Pre-upload gates

Every one of these must pass. They are ordered cheapest-first.

```bash
flutter analyze                        # no issues
flutter test                           # all green

cd android && ./gradlew verifyReleaseSigning && cd ..
# Fails the build if key.properties is missing. Without this check a release signed with
# the DEBUG key looks completely normal locally and is rejected at upload — or worse,
# ships to a track as an app nobody can ever update with the real key.

flutter build apk --release --target-platform android-arm64 \
  --obfuscate --split-debug-info=build/symbols/1.0.0+1
tool/check_native_alignment.sh
# 16 KB page-size compliance, required for targetSdk 35+. Checks the APK because the
# bundle's libraries are the same files.
```

Then the part no script covers — **install that release APK on a real device and use it**:

```bash
adb install -r build/app/outputs/flutter-apk/app-release.apk
```

Walk **login → dashboard → requisition list → detail → create (passenger) → create
(logistics) → profile → logout**. R8 and Dart obfuscation both change the artifact in
ways that unit tests cannot see; a screen that dies only in an obfuscated build is the
specific failure this step exists to catch. Do not upload a build that has not been
opened on hardware.

---

## 5. Archive, before the build directory is touched again

`build/` is gitignored and `flutter clean` deletes it. Copy these three, per release, to
durable storage:

| From | Keep as |
|---|---|
| `build/app/outputs/bundle/release/app-release.aab` | the artifact that shipped |
| `build/app/outputs/mapping/release/mapping.txt` | reads Java/Kotlin frames |
| `build/symbols/1.0.0+1/` | reads Dart frames (`flutter symbolize`) |

Upload `mapping.txt` to Play Console (App bundle explorer → Downloads) as well. The
Crashlytics Gradle plugin uploads its own copy automatically; Play's copy is what makes
Android vitals readable.

A release whose symbols were discarded can never have its crash reports decoded. There
is no recovery path.

---

## 6. Console content

Fill these in from the companion files:

- **App access** → `app-access.md`. The app is entirely behind a login, so Play *will*
  reject it without working reviewer credentials. This is the single most common
  rejection reason for apps like this one.
- **Data safety** → `data-safety.md`.
- **Privacy policy URL** → publish `privacy-policy.md` at a public, stable URL first.
- **Content rating** questionnaire, **Target audience** (18+), **Ads: no**,
  **Government app: no**, **Financial features: none**, **Health: no**, **News: no** →
  `store-listing.md` has the full answer set.
- **Store listing** copy and graphics → `store-listing.md`.

---

## 7. Roll out through tracks

Do not publish straight to production.

1. **Internal testing** — up to 100 testers, available in minutes. Install from Play (not
   adb) and repeat the §4 device walk. This is the first time the artifact runs as Play
   actually delivers it: re-signed by Play App Signing, split per-ABI and per-density.
2. **Closed testing** — a handful of real drivers/requesters on real devices, at least
   one full working day.
3. **Production**, staged: 10% → 50% → 100%, watching Android vitals and Crashlytics
   between steps. A staged rollout can be halted; a full one cannot be recalled.

---

## What is deliberately not in place

Stated plainly so nobody discovers it during an incident:

- **No remote kill switch.** `minimum_supported_build` and `maintenance_message` are
  fetched from Remote Config but no UI consumes them, so a bad build cannot be gated
  remotely — the only remedy is halting the rollout and shipping a fix. Deferred by
  explicit decision; worth building before the user base grows.
- **No native crash capture.** Crashes inside `libflutter.so`/`libapp.so` need
  Crashlytics NDK, which is not wired up. Dart exceptions report normally.
- **No CI.** Every gate in §4 is run by hand, in that order, by whoever is releasing.
- **iOS is untouched by this checklist.** The App Store path has its own requirements and
  needs a Mac; nothing here has been verified on iOS.
