# Data Safety form — answers

Play Console → App content → Data safety. Answers below are derived from the code, with
the source named for each, so they can be re-checked rather than trusted.

Play's definitions, which trip people up:

- **Collected** = leaves the device, to anyone, including your own servers.
- **Shared** = transferred to a *third party*. Data processed by a service provider on
  your behalf (Firebase Crashlytics is one) counts as collected, **not** shared.
- Data that never leaves the device — the stored session, local preferences — is not
  collected and must not be declared.

If the app changes, this form has to change with it. Play treats a stale declaration as a
policy violation, not a paperwork slip.

---

## Overview answers

| Question | Answer |
|---|---|
| Does your app collect or share any of the required user data types? | **Yes** |
| Is all of the user data collected by your app encrypted in transit? | **Yes** — every request goes to `https://tms.carcopolo.com/bt/api`; release builds set `android:usesCleartextTraffic="false"`, so a plaintext request cannot be made at all |
| Do you provide a way for users to request that their data be deleted? | **No** — see "Account deletion" below |

---

## Data types to declare

### Personal info → Name

- **Collected:** Yes · **Shared:** No · **Ephemeral:** No · **Required:** Yes
- **Purpose:** App functionality; Account management
- Source: `User.name`, returned by `POST /login` and shown on Profile and the dashboard
  greeting. Also `RequisitionDetails.customerName` and `Requisition.requesterName`, which
  are submitted with and returned for each requisition (`lib/domain/model/`).
- **This is not only the signed-in user.** `GET /requisitions/employees` returns a
  directory of colleagues — name, employee code, designation, department, company
  (`Employee`, `lib/domain/model/employee.dart`) — and whoever the user picks from it as a
  rider is submitted with the requisition. The app collects personal data about employees
  other than the account holder, which is why Name is Required rather than optional.

### Personal info → Email address

- **Collected:** Yes · **Shared:** No · **Ephemeral:** No · **Required:** Yes
- **Purpose:** App functionality; Account management
- Source: the sign-in credential, sent to `POST /login`; returned as `User.email` and
  shown on Profile. Also sent **unauthenticated** to `POST /forgot-password`, which has
  the server email a six-digit OTP, and then to `POST /reset-password` with that OTP and
  the new password (`lib/data/remote/tracgo_api_client.dart`). Profile's "Change password"
  button runs the same pair, so an email address can leave the device before any session
  exists.

### Personal info → Phone number

- **Collected:** Yes · **Shared:** No · **Ephemeral:** No · **Required:** No (optional)
- **Purpose:** App functionality
- Source: `User.phone` from the account record, and `AssignedDriver.phone` displayed on
  an assigned requisition. Not read from the device — the app requests no contacts or
  phone permission.

### Personal info → Other info

- **Collected:** Yes · **Shared:** No · **Ephemeral:** No · **Required:** Yes
- **Purpose:** App functionality
- Covers the employment and trip details a requisition carries: designation, employee
  code, department, company — of the signed-in user **and of any colleague named as a
  passenger** — plus the pickup/drop locations, dates, purpose and remarks the user types
  (`Requisition`, `RequisitionDetails`, `Employee`).
- **Declare pickup/drop under this, not under Location.** Play's Location category means
  location read from the device. This app holds no location permission and never calls a
  location API; these are addresses typed by the user.

### App activity → Other actions

- **Collected:** Yes · **Shared:** No · **Ephemeral:** No · **Required:** Yes
- **Purpose:** App functionality
- Source: creating, editing and cancelling requisitions — the actions themselves are
  recorded server-side as the app's core function.

### App info and performance → Crash logs

- **Collected:** Yes · **Shared:** No · **Ephemeral:** No · **Required:** No (optional)
- **Purpose:** Crash analytics
- Source: Firebase Crashlytics (`lib/core/telemetry/`). Fatal Flutter and platform
  errors, plus non-fatals for 5xx/timeout/TLS/undecodable responses. Off in debug builds.

### App info and performance → Diagnostics

- **Collected:** Yes · **Shared:** No · **Ephemeral:** No · **Required:** No (optional)
- **Purpose:** Crash analytics
- Source: the device/OS/app metadata and breadcrumbs Crashlytics attaches automatically —
  route changes (`CrashRouteObserver`) and request outcomes keyed by `operation` +
  `status`.

### Personal info → User IDs

- **Collected:** Yes · **Shared:** No · **Ephemeral:** No · **Required:** No (optional)
- **Purpose:** Crash analytics
- Source: `crashReporterIdentityProvider` sets the Crashlytics user id to `User.id` — the
  backend's opaque identifier, and nothing else. No name or email is ever sent to
  Crashlytics.

---

## Data types NOT collected — do not tick these

| Category | Why not |
|---|---|
| Location (approximate or precise) | no location permission, no location API call anywhere in `lib/` |
| Financial info | none handled |
| Health and fitness | none |
| Messages, Photos, Videos, Audio, Files | no such permissions; no picker, no camera, no storage access |
| Contacts, Calendar | not requested |
| Web browsing history, Search history | none |
| Installed apps, Device or other IDs (advertising) | no analytics SDK, no ads SDK. Confirmed by the merged manifest: the release APK declares only `INTERNET`, `ACCESS_NETWORK_STATE` and Firebase's own `DYNAMIC_RECEIVER_NOT_EXPORTED_PERMISSION` — no `AD_ID`. **Judgement call:** Crashlytics and Remote Config each mint a per-installation identifier of their own. It is scoped to one install, is not an advertising id and does not survive an uninstall, and Play's category targets cross-app device identifiers — so it is left undeclared. **TODO(owner):** on the conservative reading, tick Device or other IDs with purpose "Crash analytics" and say so in the privacy policy |
| Passwords / credentials | **Judgement call.** The password is transmitted to the company's own authentication endpoint to obtain a token, and is never stored or logged (the Dio logger is debug-only and redacts secrets — `di/providers.dart`). Play's guidance is that credentials sent solely to authenticate the user against your own service need not be declared. **TODO(owner):** if legal prefers the conservative reading, declare it under Personal info → Other info and say so in the privacy policy |

---

## Account deletion

Play requires an in-app deletion path and a web deletion URL **for apps that let users
create an account in the app**. TracGo does not: accounts live in the Carcopolo TMS backend
and are provisioned automatically when a person is hired. The app has no sign-up screen and
no way to create an account, so the requirement does not apply.

Answer "No" to the deletion question, and give the contact route in the privacy policy
instead. The published policy names it: an employee asks their **IT or TMS system
administrator**, who closes the account and removes the data server-side, subject to
business records that have to be retained. Play checks the policy text against this form,
so the two wordings must not drift apart.

---

## Third parties with access

| Party | What they get | Why |
|---|---|---|
| B-Trac Solutions Ltd (own backend, `tms.carcopolo.com`) | everything above except crash data | it is the system of record |
| Google (Firebase Crashlytics) | crash logs, diagnostics, `User.id` | crash reporting; processor acting on B-Trac's behalf |
| Google (Firebase Remote Config) | no personal data; the fetch itself carries a Firebase per-installation id plus app version, device model and OS version | feature flags |

Crash reports are retained by Google and readable by anyone with Firebase console
access. Keep that access list short; it is the one place user identifiers leave the
company's own infrastructure.

---

## The iOS half of the same answers

App Store Connect asks the same questions under **App Privacy**, and the app ships a
privacy manifest, `ios/Runner/PrivacyInfo.xcprivacy`, that has to agree with them. The two
forms use different vocabularies for one set of facts, so they are mapped here rather than
answered twice from memory:

| This form (Play) | `PrivacyInfo.xcprivacy` / App Store Connect |
|---|---|
| Personal info → Name | `NSPrivacyCollectedDataTypeName` |
| Personal info → Email address | `NSPrivacyCollectedDataTypeEmailAddress` |
| Personal info → Phone number | `NSPrivacyCollectedDataTypePhoneNumber` |
| Personal info → User IDs | `NSPrivacyCollectedDataTypeUserID` |
| Personal info → Other info (requisition content) | `NSPrivacyCollectedDataTypeOtherUserContent` |
| App activity → Other actions | `NSPrivacyCollectedDataTypeProductInteraction` |
| App info and performance → Crash logs | `NSPrivacyCollectedDataTypeCrashData` |
| App info and performance → Diagnostics | `NSPrivacyCollectedDataTypeOtherDiagnosticData` |

Every entry is **linked to the user** and **not used for tracking**; `NSPrivacyTracking`
is `false` and `NSPrivacyTrackingDomains` is empty, which is what lets the app ship
without an App Tracking Transparency prompt.

Changing what the app collects means changing three things together — this file, the
manifest, and the privacy policy. A change to one alone is the failure that gets caught at
review.
