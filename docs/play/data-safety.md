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
| Do you provide a way for users to request that their data be deleted? | **Yes** — by writing to psd.btraccl@gmail.com; give the published privacy-policy URL as the request URL. See "Account deletion" below |

---

## Data types to declare

### Personal info → Name

- **Collected:** Yes · **Shared:** No · **Ephemeral:** No · **Required:** Yes
- **Purpose:** App functionality; Account management
- Source: `User.name`, returned by `POST /login` and shown on Profile and the dashboard
  greeting. Also `RequisitionDetails.customerName` and `Requisition.requesterName`, which
  are submitted with and returned for each requisition (`lib/domain/model/`).

### Personal info → Email address

- **Collected:** Yes · **Shared:** No · **Ephemeral:** No · **Required:** Yes
- **Purpose:** App functionality; Account management
- Source: the sign-in credential, sent to `POST /login`; returned as `User.email` and
  shown on Profile.

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
  code, department, company, and the pickup/drop locations, dates, purpose and remarks
  the user types (`Requisition`, `RequisitionDetails`).
- **Declare pickup/drop under this, not under Location.** Play's Location category means
  location read from the device. This app holds no location permission and never calls a
  location API; these are addresses typed by the user.
- **Also covers the sign-in password**, by decision of the owner on 18 August 2026: the
  conservative reading, declared rather than omitted. Play publishes no "Passwords"
  category, so credentials belong here. `POST /login` sends it over HTTPS to our own
  authentication service, which answers with a token; it is never written to device
  storage and never reaches the logs (the Dio logger is debug-only and masks `password`,
  `password_confirmation`, `otp_code` and bearer tokens — `di/providers.dart`). The same
  statement appears in `privacy-policy.md` under "What we collect", and the two must stay
  identical.
- **Why "Ephemeral: No" despite the password being ephemeral.** The flag applies to the
  whole category, and this row also carries requisition details that the server stores.
  One row cannot be both; the answer that is true of the category is the one to give.

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
| Installed apps, Device or other IDs (advertising) | no analytics SDK, no ads SDK. Confirmed by the merged manifest: the release APK declares only `INTERNET`, `ACCESS_NETWORK_STATE` and Firebase's own `DYNAMIC_RECEIVER_NOT_EXPORTED_PERMISSION` — no `AD_ID` |

**Passwords / credentials are NOT in this table.** Play's guidance would have allowed
omitting them — credentials sent solely to authenticate against your own service need not
be declared — but the owner chose the conservative reading on 18 August 2026, so the
password is declared above under Personal info → Other info. Do not re-add it here
without changing `privacy-policy.md` in the same pass: the policy states plainly that the
password is collected, and a form that says otherwise is the contradiction Play rejects
on.

---

## Account deletion

Play requires an in-app deletion path and a web deletion URL **for apps that let users
create an account in the app**. TracGo does not: accounts exist in the Carcopolo TMS
backend and are provisioned by B-Trac, and the app offers no sign-up, so the requirement
does not apply.

What the app *does* offer is a request route, so answer **Yes** to "Do you provide a way
for users to request that their data be deleted?" and give the published privacy-policy
URL as the request URL — that page names the channel:

> Write to **psd.btraccl@gmail.com** to request that your account be closed and your
> personal data removed.

Two conditions this answer commits the company to, both outside the app:

1. **Somebody reads that mailbox and can act on it.** A published deletion route that goes
   unanswered is a policy violation, not merely bad service. The address is a free-mail
   account belonging to one person; if it stops being monitored, this answer becomes
   false — a role address on `btracsolutions.com` would not have that failure mode.
2. **The request reaches whoever can delete rows in the TMS.** The app cannot delete an
   account; the backend administrator does. Requisitions kept as business records may
   lawfully survive the account — the policy says so, and the reply to a request should
   say which records were removed and which were retained.

In-app deletion remains genuinely not required: Play mandates it only for apps that let
users create an account in the app, and TracGo has no sign-up.

---

## Third parties with access

| Party | What they get | Why |
|---|---|---|
| B-Trac Solutions Ltd (own backend, `tms.carcopolo.com`) | everything above except crash data | it is the system of record |
| Google (Firebase Crashlytics) | crash logs, diagnostics, `User.id` | crash reporting; processor acting on B-Trac's behalf |
| Google (Firebase Remote Config) | no user data — config is fetched, nothing is sent | feature flags |

Crash reports are retained by Google and readable by anyone with Firebase console
access. Keep that access list short; it is the one place user identifiers leave the
company's own infrastructure.
