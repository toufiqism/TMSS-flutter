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
| No logout endpoint | **`POST /logout` exists** and revokes the token | Year-long tokens surviving sign-out |
| Tokens may not expire | They **do** — `expires_at`, ~1 year out | — |
| Pagination Laravel-standard | Neither `meta` nor flat — a bespoke `pagination` object | Wasted request per list walk |

Also wrong in the app itself: `LoadingCapacity` led with **`1-5 Ton`**, which the server
rejects — and it was the form's *default*, so every untouched logistics submission would
have failed validation.

## Verified reference

**Envelope** — every endpoint except `GET /user` returns
`{success: bool, message: string, data: …}`. `GET /user` returns a **bare object**.

**Errors** — `{success: false, message: "…", errors: {field: [msg]} | null}`.
Observed: 401 `Unauthenticated.` · 404 `Requisition not found` ·
409 `Only pending requisitions can be cancelled` · 422 `The given data was invalid.`
`Accept: application/json` is **required** — without it Laravel answers with HTML
redirects instead of this envelope.

**Statuses** — `Pending` and **`Cancel`** confirmed live (note: the verb, not
`Cancelled`). `Approved` / `Assigned` / `Rejected` are expected but unobserved on this
account.

**Detail response** adds fields the list omits: `end_time`, `department_name`,
`company_name`, `driver`, `vehicle`, and `audit_logs[]`. The audit-log entry shape is
confirmed — `{id, requisition_status, remarks, created_by_name, created_by_id_no,
created_at}`, with `created_at` in UTC like the requisition's own. `driver` and `vehicle`
are **not** confirmed; see the open questions below.

**`PUT`** is a full replacement carrying exactly the `POST` body — no `id`, no partial
patch, no `X-Requisition-Source`. `req_type` must equal the stored value, which is why
the edit form locks its type toggle. Verified live for both passenger and logistics,
including that the change lands and the type is preserved.

**Required fields**, read off the server's own 422:

- passenger: `req_type`, `requisition_for`, `requisition_for_user`, `used_type`,
  `purpose`, `customer_name`, `pickup_location`, `drop_location`, `pick_up_date_time`,
  `no_of_person`
- logistics: `req_type`, `requisition_for`, `customer_name`, `user_department`,
  `pickup_location`, `drop_location`, `pick_up_date_time`, `loading_capacity`,
  `goods_weight`, `store_name`, `goods_details`
- `remarks` optional for both. `vehicle_type` is **not validated or stored** — a nonsense
  value was accepted silently — so it is not sent.

**Enums** — `loading_capacity` is exactly `2 Ton`, `3 Ton`, `5 Ton`, `7 Ton` (probed
exhaustively). `req_type`: `passenger_vehicle`, `logistic_support`.

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
  walks the whole date window then filters, sorts and pages in memory.
- **Dashboard counts** — computed over the same set, with an explicit 1-year window
  since the server otherwise defaults to one month.

Bounded by `ApiConfig.maxPagesPerFetch × maxPageSize` (20 × 100 = 2000 rows). Beyond
that, results reflect the first slice only.

## Still unsupported

- **Employee directory.** No endpoint — `/employees`, `/employee`, `/users`,
  `/user-list` all fall through to auth middleware. `requisition_for: "Someone Else"` is
  accepted *without* naming anyone, and there is no wire field for employee ids, so the
  option is offered and the picker is not (`ApiCapabilities.employeeDirectory`).

## Open questions for the backend team

1. Full `status` vocabulary and legal transitions — only `Pending` and `Cancel` observed.
2. Is an employee-directory endpoint planned, and will `requisition_for: "Someone Else"`
   ever carry the people it is for?
3. `GET /user` returns `remember_token` in plaintext. That looks unintended and is worth
   a look regardless of this client.
4. Should `vehicle_type` be stored for logistics? The form collects it; the API ignores it.
5. Field names for the `driver` and `vehicle` objects on the detail response. Both were
   null on every requisition observed, so the mapper reads a list of plausible keys and
   the UI renders only what parses. This needs one genuinely assigned requisition to
   confirm — until then, the Assignment section is unverified against real data.
