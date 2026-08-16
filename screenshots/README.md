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
| `03-requisition-list.png` | My Requisitions — search, date filters, rows, New requisition FAB | viewport |
| `04-requisition-detail.png` | Requisition Details — trip, passenger, requester, assignment, activity | **full page**, 1344×4530 |
| `05-new-requisition-passenger.png` | New Vehicle Requisition — Passenger Vehicle variant | **full page**, 1344×3471 |
| `06-new-requisition-logistics.png` | New Vehicle Requisition — Logistics Support variant | **full page**, 1344×3711 |
| `07-profile.png` | Profile — contact and account | viewport |
| `08-login.png` | Sign In — the redesign from `TracGo Sign In.dc.html` | viewport |

The three "full page" images are stitched from several frames: the screen is scrolled in
slow, non-flinging swipes, rows that never change between frames are treated as chrome
(app bar, pinned Submit button, gesture pill) and drawn once, and the true scroll delta
between frames is recovered by matching a strip of the previous frame against the next —
`input swipe` is inertial and never travels exactly the requested distance.

`01` and `03` also scroll past one viewport and are captured at viewport height only.

Device: Pixel 9 Pro XL emulator, Android API 36, 1344×2992.
Build: `flutter build apk --release --target-platform android-arm64`, release signing.

Release rather than debug is not a preference: a debug APK is ~130 MB and the emulator's
`/data` had too little free space for PackageManager to accept it.

iOS equivalents are not captured here yet — the same screens were verified on an
iPhone 17 Pro simulator during development.
