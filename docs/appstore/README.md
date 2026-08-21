# App Store release checklist — TracGo

Everything needed to get `com.btracsl.tracgo.ios` onto the App Store, in the order it has
to happen. The repo-side work is done and verified; the App Store Connect work needs data
only B-Trac holds, marked **TODO(owner)**.

The Play checklist in `../play/README.md` is the sibling of this file, and the three
content documents there — `store-listing.md`, `data-safety.md`, `app-access.md` — are
shared. Their content transfers to iOS with only the wording changes each store's own
fields force; they are not duplicated here.

| File | What it is for |
|---|---|
| `README.md` (this file) | build, sign, upload, submit — the ordered procedure |
| `graphics/README.md` | how the screenshots are captured and framed, and why there is no banner |
| `store-listing.md` | every App Store Connect text field, ready to paste |
| `../play/store-listing.md` | the source copy, plus the content-rating and target-audience answers |
| `../play/data-safety.md` | maps to the **App Privacy** questionnaire, question for question |
| `../play/app-access.md` | reviewer credentials and navigation steps — **without this, review fails** |

---

## 0. What is already true in the repo

Verified 2026-08-21, so none of this needs redoing:

| Thing | Value | Where |
|---|---|---|
| Bundle id | `com.btracsl.tracgo.ios` | all three Runner configs in `ios/Runner.xcodeproj/project.pbxproj` |
| Team | `KSDW9SX783` (B-Trac Solutions Limited) | `DEVELOPMENT_TEAM`, automatic signing |
| Version / build | `1.0.1` / `2003` | `pubspec.yaml`, read through `$(FLUTTER_BUILD_NAME)` / `$(FLUTTER_BUILD_NUMBER)` |
| Deployment target | 15.0 | forced by the Firebase iOS SDK, see the root `CLAUDE.md` |
| Devices | **iPhone only** — `TARGETED_DEVICE_FAMILY = 1` | set on the target, so the project-level `"1,2"` is inert |
| Display name | TracGo | `CFBundleDisplayName` **and** `CFBundleName` in `Info.plist` |
| Export compliance | declared | `ITSAppUsesNonExemptEncryption = false`, so uploads never stall on the question |
| Privacy manifest | present | `ios/Runner/PrivacyInfo.xcprivacy` |
| App icon | 1024×1024, **no alpha** | `Assets.xcassets/AppIcon.appiconset` — App Store Connect rejects alpha |
| Screenshots | six each at 1320×2868 and 1284×2778 | `graphics/screenshots/6.9-inch/` and `6.5-inch/`, regenerate per `graphics/README.md` |
| dSYM upload | automatic | "Upload Crashlytics dSYMs" build phase → `ios/scripts/upload_crashlytics_dsyms.sh` |

The bundle id deliberately differs from Android's `com.btracsl.tracgo` — see the root
`CLAUDE.md`. Do not "tidy" them into matching.

---

## 1. One-time App Store Connect setup

The App ID is **already registered**: automatic signing created `com.btracsl.tracgo.ios`
and its managed profile on the portal the first time the target was signed. There is
nothing to do under Certificates, Identifiers & Profiles.

In App Store Connect → Apps → **+** → New App:

- Platform **iOS**; Name **TracGo** (must be unique across the whole App Store — if it is
  taken, the listing name changes, not the bundle id); Primary language English (U.K.);
  Bundle ID `com.btracsl.tracgo.ios`; SKU `tracgo-ios-001`; User Access **Full Access**.

### Roles: App Manager covers the build, not the privacy answers

App Manager is enough to archive, sign, upload and manage the listing. It is **not** enough
to publish the App Privacy responses — see §5. Sort that out before submission day rather
than discovering it at the last step.

### The distribution certificate does not exist yet

The keychain holds only Apple **Development** certificates. Xcode mints the Apple
**Distribution** certificate the first time it archives — which requires the signing
Apple ID to hold Admin, App Manager or Account Holder on the team. **This account is App
Manager, which is sufficient.**

An account may hold at most three distribution certificates. This is the team's first, so
there is nothing to revoke; if that limit is ever hit, revoking one invalidates every
build signed with it.

---

## 2. Build the IPA

```bash
flutter clean
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter build ipa --release \
  --obfuscate --split-debug-info=build/symbols/ios
```

Produces `build/ios/ipa/tracgo.ipa` and `build/ios/archive/Runner.xcarchive`.

**Keep `build/symbols/ios/` for the life of the release.** It is the only thing that can
turn an obfuscated Dart frame back into a symbol name, exactly as on Android — see
"Obfuscation and symbols" in the root `README.md`. A crash from a build whose symbols
were thrown away can never be read again. Archive it beside the IPA.

The Crashlytics dSYM upload happens inside the build, from the Runner target's build
phase; native frames symbolicate without any further step.

---

## 3. Upload

Any one of these — they do the same thing:

```bash
xcrun altool --upload-app -f build/ios/ipa/tracgo.ipa -t ios \
  -u <apple-id> -p <app-specific-password>
```

The password is an **app-specific** one from appleid.apple.com → Sign-In and Security, not
the account password. Alternatives: the **Transporter** app, or Xcode → Window → Organizer
→ the archive → Distribute App → App Store Connect.

Processing takes 5–30 minutes; the build then appears under TestFlight and becomes
selectable on the version page.

---

## 4. Listing metadata

App Store Connect → the app → 1.0.1.

| Field | Value |
|---|---|
| Screenshots | `graphics/screenshots/6.9-inch/*.png` under the **iPhone 6.9" Display** tab. That one set is all Apple requires now the app is iPhone-only; it scales them for smaller devices. `6.5-inch/` holds 1284×2778 copies for the 6.5" tab — **each tab accepts only its own sizes**, and mixing them is what produces "the dimensions of one or more screenshots are wrong" |
| App Preview | none — optional, and a scripted one would be rejected. See `graphics/README.md` |
| Name / subtitle / description / keywords / promotional text / copyright | **`store-listing.md`** — paste-ready, every field counted against its limit |
| Version | `1.0.1` — must match the binary's `MARKETING_VERSION`; ASC pre-fills `1.0`, which fails validation |
| Support URL | `https://www.btracsolutions.com/` |
| Marketing URL | optional; the same URL is fine |
| Copyright | `2026 B-Trac Solutions Limited` |

Category, Content Rights, Age Rating and the Privacy Policy URL are **not** on this page —
see §4a. Leaving them unset is what produces "Unable to Add for Review".

Both URLs were checked on 2026-08-21 and return 200. The privacy policy covers what the
App Privacy questionnaire declares — account/email, Crashlytics crash data, Firebase and
Remote Config, retention, deletion, under-18s, and a contact address — so the two agree,
which is the thing Apple actually cross-checks.

> **TODO(owner): confirm the support URL names a way to reach support.** It is a
> JavaScript-rendered site, so its contents could not be verified from outside a browser.
> A corporate homepage with no support contact, no help page and no email on it is a
> routine guideline 1.5 rejection. If there is nothing suitable, point the field at a
> support page or a `mailto:` — the policy page already publishes `psd.btraccl@gmail.com`.

---

## 4a. App Information — the four fields that block "Add for Review"

These live under **App Information**, not the version page, which is why they are easy to
miss until App Store Connect refuses the submission with *"Unable to Add for Review"*.

| Field | Answer | Why |
|---|---|---|
| Primary category | **Business** | No secondary category needed |
| Content Rights | **No — does not contain, show or access third-party content** | Requisitions are the employer's own records, entered by its own staff. No licensed media, no embedded web content, no third-party feeds |
| Privacy Policy URL | `https://toufiqism.github.io/tracgo-privacy-policy/` | Required. Note it is entered under **App Privacy**, not beside the other URLs on the version page |
| Age Rating | every answer **None** / **No** → **4+** | See below |

### Age rating questionnaire

Every answer is the null one, same as the Play content rating in
`../play/store-listing.md`:

- Violence (cartoon, realistic, prolonged), horror, profanity, crude humour: **None**
- Sexual content, nudity, alcohol, tobacco, drugs, gambling: **None**
- Medical or treatment information: **None**
- **Unrestricted web access: No.** The app has no in-app browser and opens no arbitrary URLs
- **User-generated content: No.** Requisition text goes into the employer's internal
  workflow; it is never published to other app users. This is the one question where the
  intuitive answer is wrong — "users type things" is not user-generated content in
  Apple's sense unless other users see it
- Contests, in-app controls, age assurance: **No**

Expected result: **4+**. If any of these stops being true, the questionnaire has to be
retaken — a stale rating is a policy violation in both stores.

---

## 5. App Privacy

> ⚠️ **This section needs Admin or Account Holder. App Manager is not enough.**
> The signing account is App Manager, which is sufficient to archive and upload but not to
> publish privacy answers — App Store Connect says so directly: *"an Admin must provide
> information about the app's privacy practices."* Either have an Admin on the B-Trac team
> fill this in, or have the Account Holder raise the role. Nothing in the repo can work
> around it.

App Store Connect → App Privacy → Get Started. Answer it from `../play/data-safety.md`;
the two forms ask the same questions in a different order.

- **Contact Info → Email Address** and **Identifiers → User ID**: collected, linked to the
  user, used for **App Functionality**. This is the work account the app signs in with.
- **Diagnostics → Crash Data** and **Performance Data**: collected via Crashlytics, **not**
  linked to the user, used for App Functionality.
- **Tracking: No.** The app shows no ATT prompt, shares nothing with data brokers and runs
  no advertising SDK. Answering yes here would require an `NSUserTrackingUsageDescription`
  and an ATT prompt that does not exist.

---

## 6. App Review Information

**This is the single most common rejection for an app shaped like this one.** Every screen
is behind a login and there is no sign-up, so a reviewer without credentials sees a wall
and files "we were unable to access parts of your app".

- **Sign-in required: Yes.**
- Username: `tofiq.akbar@btracsl.com`. The owner's live account, by explicit decision on
  2026-08-21; `../play/app-access.md` records what that exposes to a reviewer and what
  would have to change to move to a dedicated one.
- Password: **type it into App Store Connect directly.** It is deliberately not in any
  tracked file — a live credential committed once stays in git history after it rotates.
- Notes: the seven-step walkthrough in `../play/app-access.md` transfers verbatim.
- Contact name, phone and email for the reviewer to reach.

> **A password rotation breaks the next review in both stores.** Nothing warns you: the
> submission simply comes back as "we were unable to access parts of your app", a week
> later. Update App Store Connect and Play Console on the same day the password changes.

---

## 7. Age rating, pricing, availability

- Age rating questionnaire: every answer **None** → 4+.
- Price: **Free**.
- Availability: all territories, or Bangladesh only if this stays internal. Note that a
  public App Store listing is visible to anyone; `../play/README.md` §0 makes the case for
  a private distribution channel instead, and the equivalent here is **Apple Business
  Manager** custom app distribution. That decision applies to both stores or neither.

---

## 8. TestFlight before submitting

TestFlight → the build → Internal Testing → add yourself → install on a **real iPhone**.
Walk sign-in → dashboard → list → detail → create (both variants) → drawer → profile →
sign out, and confirm the session survives a cold start.

A simulator proves none of this: it does not exercise the Keychain the way a device does,
and the release build is the first build that is AOT-compiled, obfuscated and signed for
distribution.

---

## 9. Submit

Version page → select build 2003 → **Add for Review** → **Submit for Review**. Choose
**Manual release** for the first version, so approval does not put it on sale at 3am
before anyone has looked at it.

Review is typically 24–48 hours.

---

## 10. After it is live

- Archive `build/symbols/ios/` and the `.xcarchive` together, tagged with `1.0.1+2003`.
- Confirm a real crash symbolicates in the Firebase console before trusting the pipeline.
- The next upload needs a build number strictly greater than 2003. `pubspec.yaml` is the
  single source for it — Android and iOS read the same line, and Play has already consumed
  2002 and 2003, so the next release is 2004 on both.
