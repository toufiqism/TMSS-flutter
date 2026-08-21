# Store listing — App Store

Copy for App Store Connect → the app → **1.0.1** → App Information and the version page.
Paste verbatim; every field is inside its limit, counted on 2026-08-21.

The wording is `../play/store-listing.md`'s, reviewed once and reused, with three
Apple-specific changes: **Apple renders none of Play's formatting**, so the bold headings
became plain capitals; the "system back gesture" line is gone because it describes an
Android affordance; and Play's 80-character short description became Apple's 30-character
subtitle, which is a different field with a different job.

| Field | Limit | Used |
|---|---|---|
| Name | 30 | 6 |
| Subtitle | 30 | 28 |
| Promotional Text | 170 | 126 |
| Description | 4000 | 1751 |
| Keywords | 100 | 94 |
| Copyright | 200 | 29 |

---

## Name

```
TracGo
```

## Subtitle

```
Company vehicle requisitions
```

Shown under the name in search results and on the product page. Apple indexes it for
search, so it earns its keywords rather than repeating the name.

## Promotional Text

```
Raise a vehicle requisition from your phone, follow it through approval, and see the vehicle and driver assigned to your trip.
```

The only listing field that can be changed **without submitting a new build**. Worth
keeping for announcements — a maintenance window, a new feature — rather than treating it
as a second subtitle.

## Description

```
TracGo is the mobile companion to the Bangla Trac transport management system. Raise a vehicle requisition from your phone, watch it move through approval, and see the vehicle and driver assigned to your trip - without a phone call or an email chain.

RAISE A REQUISITION IN A MINUTE
Pick the date and time, the pickup and drop-off points, and the purpose. TracGo supports both kinds of request your transport team already handles:
• Passenger vehicles - for staff, guests and visitors
• Logistics support - for goods, with vehicle type, load capacity and consignment details

KNOW WHERE YOUR REQUEST STANDS
Every requisition carries a clear status - Pending, Approved, Assigned, Rejected or Cancelled - and a full activity trail showing who acted on it and when. No more wondering whether a request was seen.

SEE YOUR VEHICLE AND DRIVER
Once transport assigns a vehicle, the requisition shows the vehicle details and the driver's name and contact number, so you can coordinate the pickup directly.

FIND ANY REQUEST, FAST
Search your requisitions and filter them by date range. The dashboard opens on your counts and your most recent requests.

CHANGE YOUR MIND
Edit a requisition while it is still pending, or cancel it - plans change, and a cancelled trip frees a vehicle for someone else.

BUILT FOR THE PEOPLE WHO USE IT DAILY
A clean, quick interface that respects your device's text size settings and gets out of the way.

TracGo is a company application. Accounts are issued by your organisation; there is no public sign-up. If you are a B-Trac employee and need access, contact your transport or IT administrator.

An internet connection is required. TracGo does not use your location, camera, contacts or files, and contains no advertising.
```

Two things in this copy are deliberate and should survive editing:

- **It says there is no public sign-up, in the last third and again nowhere else needed.**
  Anyone who installs a login-walled app without an account leaves a one-star review
  otherwise. Apple's product page collapses the description after about three lines, so
  the first paragraph carries the whole pitch.
- **It claims nothing the build does not do.** No offline mode, no push notifications, no
  employee picker beyond what ships. A listing that promises absent features earns
  rejections under guideline 2.3.1 and refunds afterwards.

## Keywords

```
vehicle,requisition,fleet,transport,trip,driver,logistics,booking,approval,staff,corporate,car
```

94 characters, 12 terms. **Commas with no spaces after them** — a space costs a character
against the 100 and buys nothing. Do not repeat "TracGo" or any word already in the name
or subtitle: Apple indexes those fields separately, and a duplicate wastes the budget.

## Support URL

```
https://www.btracsolutions.com/
```

**TODO(owner): confirm this page names a way to reach support.** It is JavaScript-rendered,
so its contents could not be verified from outside a browser. A corporate homepage with no
help page, support email or contact form is a routine guideline 1.5 rejection. The privacy
policy already publishes `psd.btraccl@gmail.com` if a fallback is needed.

## Marketing URL

```
https://www.btracsolutions.com/
```

Optional. Same URL is fine; leaving it blank is also fine.

## Version

```
1.0.1
```

**Must equal the binary's `MARKETING_VERSION`**, which is `1.0.1` — set from
`pubspec.yaml`'s `version: 1.0.1+2003` via `$(FLUTTER_BUILD_NAME)`. App Store Connect
pre-fills `1.0` on a new app; leaving it there fails validation against the uploaded
build.

## Copyright

```
2026 B-Trac Solutions Limited
```

No `©` — Apple adds the symbol itself. Year is first publication, not the current year, so
this stays `2026` in later releases.

---

## Fields not on this page

| Field | Where | Value |
|---|---|---|
| Category | App Information | Business (primary); no secondary needed |
| Age rating | App Information | every answer None → 4+; see `../play/store-listing.md` |
| Privacy Policy URL | App Information | `https://toufiqism.github.io/tracgo-privacy-policy/` |
| Screenshots | version page | `graphics/screenshots/6.9-inch/*.png` under **iPhone 6.9" Display**; `6.5-inch/*.png` if using that tab instead |
| App Review Information | version page | see `README.md` §6 |
| App Privacy | its own section | see `README.md` §5 and `../play/data-safety.md` |
