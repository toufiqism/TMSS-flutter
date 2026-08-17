# App access — reviewer instructions

Play Console → App content → **App access**.

Every screen in TracGo is behind a login, and the app has no sign-up. A reviewer who
cannot get past the first screen sees a broken app, and the submission is rejected —
usually cited as "we were unable to access parts of your app". This is the most common
rejection for apps of this shape, and it is entirely avoidable.

Select **"All or some functionality is restricted"** and add one instruction set with the
details below.

---

## What to enter

**Name of the flow:** `Sign in — all functionality`

**Username / Email:** TODO(owner)
**Password:** TODO(owner)

**Any other instructions:**

> TracGo is an internal vehicle-requisition app for employees of B-Trac Solutions. There
> is no public sign-up; accounts are issued by the company. Sign in with the credentials
> above to reach every screen.
>
> 1. Launch the app. The Sign In screen appears.
> 2. Enter the email and password above and tap **Sign In**.
> 3. The Dashboard opens, showing requisition counts and recent requisitions.
> 4. Tap **My Requisitions** to see the full list, with search and date filters.
> 5. Tap any row to open its detail, including status history and, once assigned, the
>    vehicle and driver.
> 6. Tap **+ New** on the Dashboard to open the create form. It has two variants,
>    **Passenger** and **Logistics**, selected at the top of the form.
> 7. The menu (top left) opens the drawer, which reaches **Profile** and **Sign out**.
>
> The app needs an internet connection; it talks to https://tms.carcopolo.com/bt/api.
> It requests no runtime permissions and does not use location, camera or contacts.

---

## Requirements for the reviewer account — read before creating it

**TODO(owner): create a dedicated account for this.** Do not paste a real employee's
credentials into Play Console. Requirements:

1. **Permanent.** Play re-reviews on every update, and re-checks periodically between
   updates. An account that expires, or a password rotated out of the Console, takes the
   live listing down at the worst possible moment. Exempt it from any password-expiry
   policy, or set a calendar reminder to update the Console entry whenever it rotates.
2. **Populated.** The reviewer must see the app working, not an empty state. Seed the
   account with at least five requisitions spanning statuses — Pending, Approved,
   Assigned, Rejected, Cancelled — including one Assigned with a vehicle and driver so
   the detail screen shows its full form.
3. **Low privilege.** Requester role only. It must not be able to approve, to see other
   employees' requisitions, or to reach anything administrative.
4. **Fake data only.** Everything visible under this account is seen by an external
   reviewer, so it must contain no real employee names, no real phone numbers and no
   real trip records.
5. **Isolated.** Do not reuse this account for demos, screenshots or testing. A
   requisition cancelled during a demo is a screen the reviewer then cannot see.

## Before submitting, verify it yourself

Install the exact APK/AAB being uploaded on a device that has never run the app, sign in
with the reviewer credentials, and walk all seven steps above. Confirm specifically that:

- sign-in succeeds from a cold install with no stored session;
- the list is not empty and shows more than one status;
- the create form opens in both Passenger and Logistics variants;
- sign-out returns to the Sign In screen, and signing back in works.

Anything that fails here fails in review, a week later, with less explanation.

---

## Also on this Console page

- **Ads:** contains ads → **No**. The app has no ad SDK and no `AD_ID` permission.
- **Content rating** → answers are in `store-listing.md`.
- **Target audience:** 18 and over. Not designed for children.
- **Government apps:** No.
- **Financial features:** None.
- **Health apps:** No.
- **News apps:** No.
- **Data safety** → `data-safety.md`.
