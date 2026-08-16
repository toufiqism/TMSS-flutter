# API layer — verified against the live server

Implements `https://tms.carcopolo.com/bt/api`. **This document now describes observed
behaviour, not the contract.** `api-contract/tms-requisition-api.json` was reconstructed
from a Postman collection with no saved response examples, and probing the real server
contradicted it on almost every point — including two that had the client silently
broken and one whole feature disabled for no reason.

Reproduce with `dart run test/live_api_check.dart --user <email> --pass <pw>`. It drives
this app's own Dio stack end-to-end and cancels everything it creates.

## Where the contract was wrong

| Contract said | Reality | Consequence if unfixed |
|---|---|---|
| List rows at `data[]` | Rows at **`data.data[]`**, pagination at **`data.pagination`** | List permanently empty, no error anywhere |
| Pickup read back as `pick_up_date_time` | Response field is **`start_time`** | Every row's pickup time missing |
| `ReqType` = `passenger_vehicle` only | Also **`logistic_support`** | Entire Logistics feature disabled for nothing |
| `RequisitionFor` = `Own User` only | **`Someone Else`** also valid | Option withheld for nothing |
| `RequisitionForUser` = `Internal User` only | **`External User`** also valid | Option withheld for nothing |
| `UsedType` = `Drop`, `Pickup & Drop` | Bare **`Pickup`** also valid | Option withheld for nothing |
| Login returns only `data.token` | Also `name`, `designation`, `phone`, `company_name`, `expires_at` | An unnecessary second round-trip and failure mode |
| No logout endpoint | **`POST /logout` exists** and revokes the token — now documented in the updated contract as `Auth > Logout` | Year-long tokens surviving sign-out |
| Tokens may not expire | They **do** — `expires_at`, ~1 year out | — |
| Pagination Laravel-standard | Neither `meta` nor flat — a bespoke `pagination` object | Wasted request per list walk |
| `loading_capacity` includes `1∙5 Ton` | Rejected — the set is `2/3/5/7 Ton` | A 422 on the smallest truck size |
| Riders read back under `employee_id` | Read back under **`employees`**, as objects | Edit form seeded empty, wiping riders on save |
| (silent) No length rules | `min:3` / `max:200`\|`100`\|`25` on the text fields, `no_of_person` 1–15 | A 422 the form could not explain |
| (silent) `pick_up_date_time` validated | **Not validated** — bad formats store as `0000-00-00` | Silent destruction of the pickup time |
| Inactive employee 422 says "inactive" | Says `The selected employee_id.0 is invalid.`, under an indexed key | Stale-directory refetch never fired |
| `Accept: application/json` required | No longer — JSON is returned without it | (none; header still sent) |
| Foreign requisition returns 403 | Returns **404** `Requisition not found` | — |

Also wrong in the app itself: `LoadingCapacity` led with **`1-5 Ton`**, which the server
rejects — and it was the form's *default*, so every untouched logistics submission would
have failed validation.

## Verified reference

**Envelope** — every endpoint except `GET /user` returns
`{success: bool, message: string, data: …}`. `GET /user` returns a **bare object**.

**Errors** — `{success: false, message: "…", errors: {field: [msg]} | null}`.
Observed: 401 `Unauthenticated.` · 404 `Requisition not found` ·
409 `Only pending requisitions can be cancelled` · 422 `The given data was invalid.`
`Accept: application/json` is sent on every request and no longer appears to be
*required* — a bare `GET /requisitions` without it now answers `200 application/json`
rather than the HTML redirect it used to. The header stays; relying on the new behaviour
would be trading a guarantee for a coincidence.

**404, not 403**, for a requisition belonging to somebody else — `GET`, `PUT` and
`cancel` all answer `Requisition not found`, which is also what a genuinely missing id
returns. The two are indistinguishable from the client, so both are handled as "gone".

**Statuses** — `Pending` and **`Cancel`** confirmed live (note: the verb, not
`Cancelled`). `Approved` / `Assigned` / `Rejected` are expected but unobserved on this
account.

**`POST /logout`** — Bearer token, `Content-Type` + `Accept: application/json`, empty
body. Nulls `acc_user_info.api_token` and `api_token_expires_at`; the same token 401s on
every request afterwards, including a second `/logout`. The client treats that 401 as a
success (the token is dead, which is the goal) and clears the local session whatever the
server answers, reporting the failure to the user rather than blocking the sign-out.

Two things end with the session and are **not** rebuilt by Riverpod when it does: the
cached employee directory (real staff data, held for the app's lifetime) and the stored
token. `LogoutUseCase` and `SessionExpirationHandler` drop both explicitly. The expiry
path deliberately does *not* call `/logout` — the token it holds is the one the server
just rejected.

**Detail response** adds fields the list omits: `end_time`, `department_name`,
`company_name`, `created_by_name`, `created_by_id_no`, `driver`, `vehicle`,
`audit_logs[]` and **`employees[]`**. `created_by_name` / `created_by_id_no` are the
requester, shown on the detail screen and above the edit form; when they are absent
(any list-sourced row) the mapper falls back to the *creating* audit entry — the
earliest, never the newest, which belongs to whoever approved or cancelled. The audit-log
entry shape is confirmed — `{id, requisition_status, remarks, created_by_name,
created_by_id_no, created_at}`, with `created_at` in UTC like the requisition's own.
`driver` and `vehicle` are **not** confirmed; see the open questions below.

**`employees[]` is the rider list read back** — `[{id, id_no, full_name}]`, present on
the detail, create and update responses and **absent from list rows**. All three fields
are kept (`RequisitionRider`): `full_name` and `id_no` are what the detail screen lists
as passengers and what seeds the edit form's chips, so neither screen has to wait on the
92KB employee directory to show a name. Only `id` is submittable. Note the
asymmetry with the request, which sends `employee_id: [3035, 670]`: different key, and
objects out where ids go in. `[]` on logistics, never null.

**`POST` answers 201 with the whole detail object** — envelope, `audit_logs`,
`employees` and all — so nothing needs re-fetching after a create. `cancel` likewise
returns the full object with `status: "Cancel"` and a new audit entry appended.

**`PUT`** is a full replacement carrying exactly the `POST` body — no `id`, no partial
patch, no `X-Requisition-Source`. `req_type` must equal the stored value, which is why
the edit form locks its type toggle. Verified live for both passenger and logistics,
including that the change lands, the type is preserved, and `employee_id` **replaces**
the rider list rather than adding to it (2 riders → 1 confirmed).

**Required fields**, read off the server's own 422:

- passenger: `req_type`, `requisition_for`, `requisition_for_user`, `used_type`,
  `purpose`, `customer_name`, `pickup_location`, `drop_location`, `pick_up_date_time`,
  `no_of_person`, `employee_id`
- logistics: `req_type`, `requisition_for`, `customer_name`, `user_department`,
  `pickup_location`, `drop_location`, `pick_up_date_time`, `loading_capacity`,
  `goods_weight`, `store_name`, `goods_details`
- `remarks` optional for both. `vehicle_type` is **not validated or stored** — a nonsense
  value was accepted silently — so it is not sent.
- Omitting `req_type` falls through to the *logistics* validator, so a body missing it
  gets a confusing list of logistics field errors. Always send it.

**Enums** — `loading_capacity` is exactly `2 Ton`, `3 Ton`, `5 Ton`, `7 Ton` (probed
exhaustively; `1.5 Ton` and `1-5 Ton` are both rejected, and the `1∙5 Ton` that the
updated Postman collection advertises is not a value this server accepts). `req_type`:
`passenger_vehicle`, `logistic_support`.

### Length and range rules — the client's own gap, not the contract's

Neither contract mentions these and the app did not enforce them, so a user typing `Ab`
into Purpose got a server 422 with no way to have known. Mirrored in
`domain/requisition_field_limits.dart`. Re-derive by posting one body with every text
field at 600 characters and one with every text field at a single character — the 422
names every rule and its limit in one response.

| Field | Min | Max |
|---|---|---|
| `purpose`, `customer_name`, `pickup_location`, `drop_location`, `goods_details` | 3 | 200 |
| `user_department`, `store_name` | 3 | 100 |
| `goods_weight` | — | 25 |
| `remarks` | — | 200 |
| `no_of_person` | 1 | **15** |

The asymmetries are the point: the two 100s, the 25, and the absent minimum on
`goods_weight` and `remarks` are all real. `no_of_person` capping at 15 also caps the
rider picker, since the two must be equal.

**`pick_up_date_time` is not validated at all — and that is dangerous.** `01/09/2026
10:00` was accepted with a 201 and stored as `0000-00-00 00:00:00`, destroying the
requisition's pickup time with no error anywhere. `2026-09-01T10:00:00`, `2026-09-01
10:00` and a bare `2026-09-01` are all accepted too, as is a pickup time in the past.
The format is entirely the client's responsibility: everything goes through
`WireDateTime.format`. (`WireDateTime.parse` returns null for `0000-00-00 00:00:00`, so
a row already corrupted this way renders as a missing time rather than crashing.)

**`employee_id` 422s are reported per item, under indexed keys** — `employee_id.0`, not
`employee_id` — except the count rule, which uses the bare key:

| Cause | Key | Message |
|---|---|---|
| Count ≠ `no_of_person` | `employee_id` | `The number of selected employees must equal no_of_person (3).` |
| Duplicate id | `employee_id.0`, `employee_id.1` | `The employee_id.0 field has a duplicate value.` |
| Unknown / inactive id | `employee_id.0` | `The selected employee_id.0 is invalid.` |
| `Own User` + `External User` | `requisition_for_user` | `requisition_for_user must be 'Internal User' when requisition_for is 'Own User'.` |

The indexing is why `_mapWireFieldErrors` trims at the first `.`, and the third row's
wording — plain `exists`-rule boilerplate, not the contract's "inactive or do not have
an active user account" — is why the stale-cache check matches on it too.

**Pagination** — `per_page` honoured up to at least 100; default 15. `last_page` is `0`
for an empty result, not 1.

**Timezones — the API mixes them within one payload.** `start_time` round-trips verbatim
as Dhaka wall-clock; `created_at` is UTC. Verified: a row created at 00:34 Dhaka came
back as `created_at: 2026-08-13 18:34:51`. Hence `WireDateTime.parse` vs `parseUtc` —
using one for both puts every `createdAt` six hours out.

## Still derived client-side

No endpoint backs these, so they are computed from `GET /requisitions`:

- **Search and sort** — the list takes only `per_page`, `page`, `fdate`, `tdate`.
  Filtering one server page locally would hide matches on later pages, so the repository
  walks the whole date window then filters, sorts and pages in memory. `per_page` is
  clamped server-side: asking for 200 comes back as 100. Rows arrive newest-first.
- **Employee search** — `GET /requisitions/employees` ignores every query parameter, so
  the picker filters the cached directory locally over name, staff number, designation
  and department.
- **Dashboard counts** — computed over the same set, with an explicit 1-year window
  since the server otherwise defaults to one month.

Bounded by `ApiConfig.maxPagesPerFetch × maxPageSize` (20 × 100 = 2000 rows). Beyond
that, results reflect the first slice only.

## Employee directory — now supported

`GET /requisitions/employees` returns every employee with an active `acc_user_info`
account. The earlier probes missed it because they guessed top-level routes
(`/employees`, `/users`, …) rather than one nested under `/requisitions/`.

- **Unpaginated, and it ignores every query parameter.** 537 rows / 92KB in one
  response. `search`, `q`, `keyword`, `name`, `term`, `filter`, `search_text`, `id_no`,
  `employee_id`, `id`, `per_page`, `page` and `limit` were each probed and all thirteen
  returned the identical body byte for byte. `RemoteRequisitionRepository` fetches it
  once per session and filters in memory because there is nothing else on offer.
- **`id` vs `id_no`.** `id` (1073) is the surrogate key that goes in `employee_id[]`.
  `id_no` ("298", "4-112", "AP-203", "BE-117") is the staff number — not always numeric,
  never submittable, and the thing colleagues actually quote at each other, so the local
  filter matches on it as well as the name. Both are unique across the 537 rows, and the
  list arrives sorted by `full_name`.
- **Finding yourself in it.** `GET /user` returns `employee_id: 3035` alongside its own
  `id: 864`; the former is the directory's `id`, the latter is the account row. That is
  the only link between the session and a directory entry — the login response carries
  no id whatsoever — and it is what the create form uses to pre-select the requester as
  a rider on an "Own User" trip.
- **Rows are 6 fields, always populated** — `id`, `id_no`, `full_name`,
  `designation_name`, `department_name`, `company_name`. No nulls, no empty strings and
  one single row shape across all 537, spanning 15 companies.
- **`employee_id` is required on every passenger requisition** and must hold exactly
  `no_of_person` distinct, active ids — including for `requisition_for: "Own User"`.
  The form derives `no_of_person` from the selection so the counts cannot disagree.
- **Documented 422s**: count mismatch, inactive employee, duplicate ids, and
  `Own User` paired with `External User`. The first three map onto the picker; an
  "inactive" rejection also drops the cached directory, since it proves the cache is
  stale.

## Open questions for the backend team

1. Full `status` vocabulary and legal transitions — only `Pending` and `Cancel` observed.
2. **`pick_up_date_time` accepts anything.** `01/09/2026 10:00` stores as
   `0000-00-00 00:00:00` with a 201 and no error. Any client that formats dates
   differently from this one silently destroys the field. A `date_format` rule would
   cost one line. Past pickup times are accepted too, which may or may not be intended.
3. `GET /user` returns `remember_token` in plaintext. That looks unintended and is worth
   a look regardless of this client.
4. Should `vehicle_type` be stored for logistics? The form collects it; the API ignores it.
5. Field names for the `driver` and `vehicle` objects on the detail response. Both were
   null on every requisition observed, so the mapper reads a list of plausible keys and
   the UI renders only what parses. This needs one genuinely assigned requisition to
   confirm — until then, the Assignment section is unverified against real data.
6. `GET /requisitions/employees` ships 92KB on every cold start and ignores all query
   parameters. A `?search=` (or any paging at all) would remove the need for this client
   to hold the entire staff directory in memory.
7. The `employee_id`-is-invalid 422 is `exists`-rule boilerplate, so "this employee went
   inactive" and "this id does not exist" are indistinguishable. The client currently
   treats both as a stale cache and refetches.
8. Reading riders back uses `employees`, writing them uses `employee_id`, and the read
   returns objects where the write takes ids. Deliberate?
9. A requisition observed as `Pending` (id 2845) 404'd on both `GET` and `cancel` minutes
   later, having vanished from the list entirely — so something hard-deletes rows. Worth
   knowing what, since the client can only report it as "not found".
