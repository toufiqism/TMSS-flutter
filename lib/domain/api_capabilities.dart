/// What the API contract actually supports today.
///
/// These were originally derived from `api-contract/tms-requisition-api.json`, a draft
/// reconstructed from a Postman collection. Most have since been settled by probing the
/// live server directly, and the contract turned out to understate what the API
/// supports — logistics and "Someone Else" were both disabled on its word and are in
/// fact accepted.
///
/// The remaining `false` below is a real gap, verified rather than assumed. The rule
/// stands: disable the control rather than send a speculative payload.
class ApiCapabilities {
  ApiCapabilities._();

  /// Supported. The contract listed only `passenger_vehicle`, but the server's own 422
  /// names `user_department`, `loading_capacity`, `goods_weight`, `store_name` and
  /// `goods_details` as required fields, and `req_type: logistic_support` is accepted.
  static const logisticsRequisitions = true;

  /// Supported. `requisition_for: "Someone Else"` is accepted by the server, as is
  /// `requisition_for_user: "External User"` — both of which the contract listed as
  /// unverified.
  ///
  /// The picker is no longer gated: `employee_id[]` names the riders on the wire, and
  /// the server now requires it on every passenger requisition regardless of this
  /// choice.
  static const requisitionsForOthers = true;

  /// Supported since the updated contract: `GET /requisitions/employees` returns every
  /// employee with an active `acc_user_info` account.
  ///
  /// The earlier probes that found nothing were looking in the wrong place — they tried
  /// `/employees`, `/employee`, `/users` and `/user-list`, while the real route is
  /// nested under `/requisitions/`.
  ///
  /// The directory is a **whole-list** endpoint, not a search one: twelve candidate
  /// query parameters were probed and all twelve were ignored. See
  /// [serverSideEmployeeSearch].
  static const employeeDirectory = true;

  /// `GET /requisitions/employees` has no search parameter. Probed exhaustively —
  /// `search`, `q`, `keyword`, `name`, `term`, `filter`, `search_text`, `id_no`,
  /// `employee_id`, `id`, `per_page`, `page`, `limit` — and every one returned the same
  /// 537-row body byte for byte.
  ///
  /// So the picker filters the cached list in memory, over `full_name`, `id_no`,
  /// `designation_name` and `department_name`. Matching `id_no` matters: staff numbers
  /// like `2-765` are how people identify each other here, and they are not derivable
  /// from the name.
  static const serverSideEmployeeSearch = false;

  /// No summary/statistics endpoint exists. Counts are derived client-side from the
  /// requisition list instead, which is accurate but bounded by
  /// `ApiConfig.maxPagesPerFetch`.
  static const serverSideDashboardSummary = false;

  /// `GET /requisitions` takes only `per_page`, `page`, `fdate` and `tdate`. Search and
  /// sort are therefore applied client-side.
  static const serverSideSearchAndSort = false;
}
