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
  /// Note this only covers the *choice*. There is still no wire field naming which
  /// employees the requisition is for, and the server does not ask for one, so the
  /// picker stays gated behind [employeeDirectory].
  static const requisitionsForOthers = true;

  /// Still unsupported: no employee directory endpoint exists. Probes for `/employees`,
  /// `/employee`, `/users` and `/user-list` all fall through to the auth middleware.
  static const employeeDirectory = false;

  /// No summary/statistics endpoint exists. Counts are derived client-side from the
  /// requisition list instead, which is accurate but bounded by
  /// `ApiConfig.maxPagesPerFetch`.
  static const serverSideDashboardSummary = false;

  /// `GET /requisitions` takes only `per_page`, `page`, `fdate` and `tdate`. Search and
  /// sort are therefore applied client-side.
  static const serverSideSearchAndSort = false;
}
