<!--
  PUBLISHED TEXT — not a draft. This file is the policy itself; copy it verbatim to the
  public repository that serves it, and edit it here first so the two never disagree.

  Play compares this document against the Data Safety form (`data-safety.md`). A
  contradiction between them is a rejection, so any change to what is collected, how long
  it is kept, or how deletion is requested must be made in BOTH files in the same pass.

  Every factual claim below was checked against the code on 18 August 2026:
    - INTERNET is the only Android permission; no location, contacts, camera or photo
      keys exist on either platform (AndroidManifest.xml, ios/Runner/Info.plist)
    - allowBackup="false" + dataExtractionRules exclude the app from backup and
      device-to-device transfer (AndroidManifest.xml)
    - setCrashlyticsCollectionEnabled(!kDebugMode) disables crash reporting in debug
      builds (core/telemetry/telemetry_bootstrap.dart)
    - only the internal account id is attached to crash reports; name and email are never
      sent (di/providers.dart, crashReporterIdentityProvider)
  Re-check them before changing this text.
-->

# Privacy Policy for TracGo

**Effective date:** 18 August 2026
**Last updated:** 18 August 2026

## Who we are

TracGo is provided by **B-Trac Solutions Limited**, Plot 68, Road – 11, Block – H,
Banani, Dhaka - 1213, Bangladesh (<https://www.btracsolutions.com/>). In this policy,
"we", "us" and "our" mean that company.

For any privacy question or request, write to **psd.btraccl@gmail.com**.

## Who this app is for

TracGo is an internal application for employees and authorised users of B-Trac Solutions
Limited and its affiliates. Accounts are created and managed by us — the app has no
sign-up. If you do not have an account issued by your organisation, you cannot use the
app.

## What we collect

**Information you give us when you sign in**

- **Your work email address.** It identifies your account.
- **Your password.** It is collected when you sign in and sent, over an encrypted
  connection, only to our own authentication service, for the sole purpose of verifying
  who you are. It is never stored on your device, never written to our application logs,
  and never shared with anyone.

**Information from your employee record**

- Your name, job designation, employee code, department, company, and phone number where
  your organisation has recorded one.

**Information you enter when you raise a vehicle requisition**

- Pickup and drop-off locations, dates and times, purpose, number of passengers, vehicle
  or load details, and any remarks you add.
- These locations are what you type. **The app does not access your device's location.**
  It holds no location permission and cannot determine where you are.

**Information about assigned trips**

- Once a requisition is assigned, the app displays the assigned vehicle, and the driver's
  name and phone number, so you can be reached and can reach them.

**Diagnostic information**

- If the app crashes or encounters an unexpected error, we receive a crash report through
  Google Firebase Crashlytics. It contains the error and its stack trace, your device
  model, operating system version, app version, and a record of the screens visited and
  server responses received shortly before the problem.
- Crash reports identify you only by the internal account identifier your organisation's
  system assigns. **Your name and email are never sent to Crashlytics.**
- Crash reporting is disabled in development builds.

## What we do not collect

- Your device's location.
- Your contacts, calendar, photos, files, camera or microphone. The app requests none of
  these permissions.
- Any advertising identifier. TracGo contains no advertising and no advertising or
  marketing analytics software.

## How we use it

- To verify your identity when you sign in, and to keep you signed in afterwards.
- To create, display, edit and cancel vehicle requisitions, and to route them to the
  approvers and transport staff who act on them.
- To diagnose crashes and errors so the app can be fixed.

We do not use your information for advertising, and we do not sell it.

## Who we share it with

- **Your organisation.** Requisitions are business records. Your requests, and your
  identity as the requester, are visible to the approvers, transport administrators and
  other authorised staff who process them.
- **Google (Firebase Crashlytics and Remote Config).** Google processes crash and
  diagnostic data on our behalf as our service provider. Remote Config only sends
  configuration *to* the app; it sends no information about you.
- **Where the law requires it**, or to protect our rights, safety, or those of others.

We do not sell your personal information, and we do not share it with third parties for
their own marketing. Your password is shared with nobody.

## Where your information is stored

Requisition and account data is held on our servers at `tms.carcopolo.com`. Crash and
diagnostic data is held by Google on infrastructure that may be located outside your
country. All communication between the app and our servers uses encrypted HTTPS
connections.

## What is stored on your device

- Your sign-in session — an access token and your basic profile — is stored in the
  device's protected storage (the Android Keystore-backed store, or the iOS Keychain).
  Your password is not among it.
- Signing out deletes the session from your device and revokes the token on our servers.
- The app's data is excluded from Android backup and from device-to-device transfer, so
  your session cannot be copied to another device. On a new device you sign in again.
- Uninstalling the app removes its local data.

## How long we keep it

- Requisition records are kept for as long as B-Trac Solutions Limited's
  record-retention rules require.
- Crash and diagnostic reports are retained by Firebase Crashlytics for up to 90 days.
- Sign-in tokens expire automatically; an expired session is discarded by the app without
  being used.
- Your password is not retained by the app at all — it exists only for the moment of the
  sign-in request.

## Your choices and rights

- **Access or correction.** Your account details come from your employer's records. Write
  to **psd.btraccl@gmail.com** to see what we hold about you or to have it corrected.
- **Deletion.** Because accounts are issued by your organisation, write to
  **psd.btraccl@gmail.com** to request that your account be closed and your personal data
  removed. We will confirm what has been removed and what we are required to retain as a
  business record.
- **Changing your password.** You can change it yourself from the app, using the reset
  link on the sign-in screen or the option on your profile. A reset requires access to
  your work email address.
- **Signing out** clears the session from your device at any time.
- Depending on where you live, you may have further rights over your personal data. Write
  to the address above to exercise them.

## Children

TracGo is a workplace application and is not directed at children. We do not knowingly
collect information from anyone under 18.

## Changes to this policy

If we change it we will update the date at the top of this page, and material changes
will be communicated through your organisation.

## Contact

**B-Trac Solutions Limited**
Plot 68, Road – 11, Block – H
Banani, Dhaka - 1213
Bangladesh

Email: **psd.btraccl@gmail.com**
Web: <https://www.btracsolutions.com/>
