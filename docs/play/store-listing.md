# Store listing — copy, graphics and ratings

Play Console → Grow → Store presence → **Main store listing**, plus the App content
questionnaires. Drafts below; **TODO(owner)** marks anything only B-Trac can supply.

---

## Categorisation

| Field | Value |
|---|---|
| App name (30 char max) | `TracGo` |
| App type | App |
| Category | **Business** |
| Tags | Business → Fleet management, Productivity (choose at most 5; Play uses them for discovery only) |
| Free or paid | Free |
| Contains ads | **No** |
| In-app purchases | **No** |
| Default language | English (United States) |

---

## Short description (80 characters max)

> `Request and track company vehicles — raise, follow and manage trip requisitions.`

79 characters. This line is what appears under the icon in search results and does more
for installs than the full description, which most users never open.

Alternatives if the wording needs to change:

- `Company vehicle requisitions — request a trip, track approval, see your driver.` (78)
- `Raise vehicle requisitions and track them from request to assigned driver.` (73)

---

## Full description (4000 characters max)

> **TracGo — vehicle requisition, made simple**
>
> TracGo is the mobile companion to the Bangla Trac transport management system. Raise a
> vehicle requisition from your phone, watch it move through approval, and see the
> vehicle and driver assigned to your trip — without a phone call or an email chain.
>
> **Raise a requisition in a minute**
> Pick the date and time, the pickup and drop-off points, and the purpose. TracGo
> supports both kinds of request your transport team already handles:
> • Passenger vehicles — for staff, guests and visitors
> • Logistics support — for goods, with vehicle type, load capacity and consignment
> details
>
> **Know where your request stands**
> Every requisition carries a clear status — Pending, Approved, Assigned, Rejected or
> Cancelled — and a full activity trail showing who acted on it and when. No more
> wondering whether a request was seen.
>
> **See your vehicle and driver**
> Once transport assigns a vehicle, the requisition shows the vehicle details and the
> driver's name and contact number, so you can coordinate the pickup directly.
>
> **Find any request, fast**
> Search your requisitions and filter them by date range. The dashboard opens on your
> counts and your most recent requests.
>
> **Change your mind**
> Edit a requisition while it is still pending, or cancel it — plans change, and a
> cancelled trip frees a vehicle for someone else.
>
> **Built for the people who use it daily**
> A clean, quick interface that respects your device's text size settings, works with
> the system back gesture, and gets out of the way.
>
> ---
>
> **TracGo is a company application.** Accounts are issued by your organisation; there is
> no public sign-up. If you are a B-Trac employee and need access, contact your transport
> or IT administrator.
>
> An internet connection is required. TracGo does not use your location, camera,
> contacts or files, and contains no advertising.

Two notes on this copy, deliberately:

- It says plainly that there is no public sign-up, near the top of the visible region.
  Anyone who installs it without an account leaves a one-star review otherwise.
- It claims nothing the build does not do. No offline mode, no notifications, no employee
  picker — all three are absent from this version, and a store listing that promises them
  earns both refunds and rejections.

---

## Graphics

| Asset | Spec | Status |
|---|---|---|
| App icon | 512×512 PNG, 32-bit, ≤1 MB, no transparency, no rounded corners | **TODO(owner)** — export from `assets/images/tracgo_logo.svg` on a solid background. `tool/brand/generate_brand_assets.py` produces launcher assets, not this one |
| Feature graphic | 1024×500 PNG or JPG, no transparency, no text near the edges | **TODO(owner)** — required for the listing to publish |
| Phone screenshots | 2–8 images, PNG/JPG, 16:9 or 9:16, each side 320–3840 px | **TODO(owner)** — see below |
| 7" and 10" tablet screenshots | optional | skip unless tablets are supported officially |
| Promo video | optional YouTube URL | skip |

### The screenshots in `screenshots/` cannot be used

Two independent reasons, both blocking:

1. **They contain real production data** — a real employee's name, email, phone number
   and employee ID, and real requisition records. Uploading them publishes that
   information to anyone on the internet. `screenshots/README.md` says so already.
2. **The aspect ratios are wrong.** Several are full-page captures (1344×4662 for the
   detail screen). Play requires each side between 320 and 3840 px and a ratio no more
   extreme than 2:1 — a 1:3.5 image is rejected at upload.

Capture new ones from the **reviewer account** created in `app-access.md`, which holds
only synthetic data, at device-viewport size:

```bash
adb exec-out screencap -p > 01-dashboard.png
```

Suggested set of five, in this order — the first two are what most users actually look
at:

1. Dashboard — counts and recent requisitions
2. New Requisition (Passenger) — the form, part-filled
3. Requisition Detail — an Assigned trip showing vehicle and driver
4. My Requisitions — the list with statuses visible
5. New Requisition (Logistics) — the goods variant

Check every one for real names, phone numbers and email addresses before uploading.

---

## Contact details and links

| Field | Value |
|---|---|
| Email | **TODO(owner)** — shown publicly on the listing; use a monitored support alias, not a personal address |
| Phone | optional, **TODO(owner)** |
| Website | **TODO(owner)** — e.g. `https://btracsl.com` |
| Privacy policy URL | **TODO(owner)** — the published `privacy-policy.md`; required |

---

## Content rating questionnaire

Play Console → App content → Content rating. Category: **Utility, Productivity,
Communication or Other**.

Every content question is **No** for this app:

| Question | Answer |
|---|---|
| Violence, sexual content, profanity, controlled substances | No |
| Gambling or simulated gambling | No |
| User-generated content shared with other users | **No** — requisition text is submitted to the employer's internal workflow, not published to other app users |
| In-app user-to-user communication (chat, messaging) | No |
| Shares user's current location with other users | No |
| Allows purchase of digital goods | No |
| Collects or shares personal information | **Yes** — as declared in `data-safety.md` |

Expected outcome: **Everyone / PEGI 3 / rated for all audiences**, with a data-collection
note. The rating is issued automatically once submitted; it is not reviewed by a human.

If any answer above stops being true — a chat feature, say — the questionnaire must be
retaken. Play treats a stale rating as a policy violation.

---

## Target audience and content

- **Target age group:** 18 and over only.
- Do not tick any group under 18. Ticking one pulls the app into the Families policy
  programme, which brings its own SDK, ads and content requirements — none of which this
  app is set up to satisfy, and none of which it needs, since it is a workplace tool.
- **Appeals to children:** No.
