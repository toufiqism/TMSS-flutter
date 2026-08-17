# Screenshots

Captured from a live signed-in session, so **these images contain real production data** —
employee name, email, phone number, employee ID and real requisition records. They are not
gitignored: decide whether they belong in the repo before committing, and scrub or replace
them if this repository is shared beyond the team.

## android/

| File | Screen | Size |
|---|---|---|
| `01-dashboard.png` | Dashboard — stat panel + recent requisitions | viewport |
| `02-drawer.png` | Navigation drawer (mono brand mark on the gradient header) | viewport |
| `03-requisition-list.png` | My Requisitions — search, date filters, rows, New requisition FAB | **full page**, 1344×4512 |
| `04-requisition-detail.png` | Requisition Details — trip, passenger, requester, assignment, activity | **full page**, 1344×4662 |
| `05-new-requisition-passenger.png` | New Vehicle Requisition — Passenger Vehicle variant | **full page**, 1344×3855 |
| `06-new-requisition-logistics.png` | New Vehicle Requisition — Logistics Support variant | **full page**, 1344×4266 |
| `07-profile.png` | Profile — contact and account | viewport |
| `08-login.png` | Sign In — the redesign from `TracGo Sign In.dc.html` | viewport |

The four "full page" images are stitched from several frames: the screen is scrolled in
slow, non-flinging swipes, rows that never change between frames are treated as chrome
(app bar, pinned Submit button, gesture pill) and drawn once, and the true scroll delta
between frames is recovered by matching a strip of the previous frame against the next —
`input swipe` is inertial and never travels exactly the requested distance. The match
ignores the right-hand 40 px: the scrollbar thumb lives there and moves independently of
the content, which flattens the minimum and lets a wrong delta win (it did once, and the
seam double-exposed a row of the activity timeline).

`01`, `02` and `07` fit inside one viewport at this device size and are not stitched.

The Requisition **edit** screen is missing from this set on purpose: only pending
requisitions can be edited, this account currently has none (the dashboard reads 0
pending, every row is Cancelled), and creating one would write a real record to the
production TMS.

Device: Pixel 9 Pro XL emulator, Android API 36, 1344×2992.
Build: `flutter build apk --release --target-platform android-arm64`, release signing.

Release rather than debug is not a preference: a debug APK is ~124 MB and the emulator's
`/data` had too little free space for PackageManager to accept it (514 MB free at the
last capture; the release build is 20 MB).

System animations are set to 0 before capturing (`settings put global
window_animation_scale 0`, plus the transition and animator scales) and restored to 1
afterwards — otherwise a screenshot taken right after a navigation catches the screen
mid-fade.

iOS equivalents are not captured here yet — the same screens were verified on an
iPhone 17 Pro simulator during development.
