/// Length and range rules the server enforces on requisition bodies.
///
/// Every number here was read off the API's own 422, not inferred: one `POST
/// /requisitions` with every text field at 600 characters and one with every text field
/// at a single character make the server name each rule and its limit in a single
/// response. Re-derive them the same way if the backend changes.
///
/// These matter more than they look. The rules are **not** symmetric across the two
/// requisition types (`user_department` and `store_name` cap at 100 where the rest cap
/// at 200; `goods_weight` caps at 25 and has no minimum at all), and the minimum is 3
/// rather than 1 — so a form that only checked "not empty" let a user type `Ab` into
/// Purpose and hit a server 422 on submit with no way to have known in advance.
class RequisitionFieldLimits {
  RequisitionFieldLimits._();

  /// Applies to every required text field on both requisition types.
  ///
  /// Not applied to `remarks` or `goods_weight`: both were accepted at 1 and 2
  /// characters, so a client-side minimum there would reject input the server takes.
  static const minTextLength = 3;

  /// `purpose`, `customer_name`, `pickup_location`, `drop_location`, `goods_details`,
  /// `remarks`.
  static const defaultMaxLength = 200;

  /// `user_department` and `store_name` — logistics only, and half the usual cap.
  static const shortMaxLength = 100;

  /// `goods_weight`. It is a free-text quantity ("500 kg"), not a number, and the
  /// tightest cap on the API.
  static const goodsWeightMaxLength = 25;

  /// `no_of_person`, which the form derives from the rider selection. The server's rule
  /// is `min:1` / `max:15`, so the picker caps at [maxPassengers] rather than letting
  /// the user build a selection that can only ever 422.
  static const minPassengers = 1;
  static const maxPassengers = 15;
}
