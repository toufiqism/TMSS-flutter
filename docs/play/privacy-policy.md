# Privacy policy — draft

Play requires a privacy policy at a **public, stable URL** that anyone can open without
signing in, and that URL goes in both the store listing and the Data Safety form.

This is a draft written to match what the app actually does, not a legal document.
**TODO(owner): have B-Trac's legal or compliance owner review it before publishing**, and
fill every `TODO(owner)` below. Publish it at a company-controlled address — a page under
`btracsl.com` or `carcopolo.com` is better than a shared-document link, which can rot or
turn private and take the listing down with it.

Keep it in step with `data-safety.md`. Play compares the two, and a contradiction between
them is a rejection.

---

## Privacy Policy for TracGo

**Effective date:** TODO(owner)
**Last updated:** TODO(owner)

### Who we are

TracGo is provided by TODO(owner: full legal entity name, e.g. "B-Trac Solutions
Limited"), TODO(owner: registered address). In this policy, "we" and "us" mean that
company.

Contact for any privacy question or request: TODO(owner: privacy contact email —
must be monitored; Play displays it and users will write to it).

### Who this app is for

TracGo is an internal application for employees and authorised users of TODO(owner:
company name) and its affiliates. Accounts are created and managed by us — the app has
no sign-up. If you do not have an account issued by your organisation, you cannot use
the app.

### What we collect

**Information you give us when you sign in**

- Your work email address and password. The password is sent to our servers only to
  verify who you are and is not stored on your device.

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

### What we do not collect

- Your device's location.
- Your contacts, calendar, photos, files, camera or microphone. The app requests none of
  these permissions.
- Any advertising identifier. TracGo contains no advertising and no advertising or
  marketing analytics software.

### How we use it

- To let you sign in and to keep you signed in.
- To create, display, edit and cancel vehicle requisitions, and to route them to the
  approvers and transport staff who act on them.
- To diagnose crashes and errors so the app can be fixed.

We do not use your information for advertising, and we do not sell it.

### Who we share it with

- **Your organisation.** Requisitions are business records. Your requests, and your
  identity as the requester, are visible to the approvers, transport administrators and
  other authorised staff who process them.
- **Google (Firebase Crashlytics and Remote Config).** Google processes crash and
  diagnostic data on our behalf as our service provider. Remote Config only sends
  configuration *to* the app; it sends no information about you.
- **Where the law requires it**, or to protect our rights, safety, or those of others.

We do not sell your personal information or share it with third parties for their own
marketing.

### Where your information is stored

Requisition and account data is held on our servers at `tms.carcopolo.com`. Crash and
diagnostic data is held by Google on infrastructure that may be located outside your
country. All communication between the app and our servers uses encrypted HTTPS
connections.

### What is stored on your device

- Your sign-in session — an access token and your basic profile — is stored in the
  device's protected storage (the Android Keystore-backed store, or the iOS Keychain).
- Signing out deletes it from your device and revokes the token on our servers.
- The app's data is excluded from Android backup and from device-to-device transfer, so
  your session cannot be copied to another device. On a new device you sign in again.
- Uninstalling the app removes its local data.

### How long we keep it

- Requisition records are kept for as long as your organisation's record-retention rules
  require. TODO(owner: state the retention period, or the policy it follows.)
- Crash and diagnostic reports are retained by Firebase Crashlytics for up to 90 days.
- Sign-in tokens expire automatically; an expired session is discarded by the app without
  being used.

### Your choices and rights

- **Access or correction.** Your account details come from your employer's records —
  ask TODO(owner: name the internal team or role, e.g. "your HR or transport
  administrator") to correct them.
- **Deletion.** Because accounts are issued by your organisation, ask TODO(owner: same
  team/role) to close your account and remove your data. TODO(owner: confirm this route
  exists and name it precisely — Play checks this against the Data Safety form.)
- **Signing out** clears the session from your device at any time.
- Depending on where you live, you may have further rights over your personal data. Write
  to the contact address above to exercise them.

### Children

TracGo is a workplace application and is not directed at children. We do not knowingly
collect information from anyone under 18.

### Changes to this policy

If we change it we will update the date at the top of this page, and material changes
will be communicated through your organisation.

### Contact

TODO(owner: privacy contact email)
TODO(owner: postal address)
