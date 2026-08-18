/// Plain Dart constants mirroring the Android app's strings.xml values verbatim.
/// Full ARB/flutter_localizations scaffolding wasn't in scope for this port — add it later
/// if/when multi-language support is actually needed.
class TracGoStrings {
  TracGoStrings._();

  static const appName = 'TracGo';

  /// Shown in the drawer footer. Hand-kept in step with `version:` in pubspec.yaml —
  /// there is no package_info dependency here, and adding one for a single caption
  /// would pull a platform channel into a screen that renders offline.
  static const appVersionLabel = 'v1.0.0';

  static const loginHeading = 'Welcome back.';
  static const loginSubheading =
      'Sign in to manage allocations, trips and vehicle requisitions.';
  static const loginUsernamePlaceholder = 'yourname@company.com';
  static const loginPasswordPlaceholder = '••••••••';
  static const loginUsernameLabel = 'Username';
  static const loginPasswordLabel = 'Password';
  static const loginForgotPassword = 'Forgotten password?';

  /// Describes what the button *does*, not what the field currently is — a screen
  /// reader announcing "password hidden" would read as a status, leaving the user to
  /// guess that activating it changes anything.
  static const loginShowPassword = 'Show password';
  static const loginHidePassword = 'Hide password';
  /// The link beside [loginForgotPassword]. Replaced "Contact admin", which was the
  /// honest answer only while there was no reset endpoint to send the user to.
  static const loginResetPassword = 'Reset it';
  static const loginSignInButton = 'Sign in';

  /// Label on the password reveal control. Short and uppercase per the Sign In design;
  /// the longer [loginShowPassword]/[loginHidePassword] stay as its semantics label,
  /// because "SHOW" alone tells a screen-reader user nothing about what it shows.
  static const loginShowPasswordShort = 'Show';
  static const loginHidePasswordShort = 'Hide';
  static const loginErrorRequiredFields = 'Username and password are required';
  static const loginErrorInvalidCredentials = 'Username/Password is invalid!';

  /// Shown on Login after the reset flow pops back to it.
  static const loginPasswordResetSuccess =
      'Password updated. Sign in with your new password.';

  // ---------------------------------------------------------------------------------
  // Password reset (POST /forgot-password, POST /reset-password)
  // ---------------------------------------------------------------------------------

  static const resetHeading = 'Reset password.';

  /// Step 1. Deliberately says "if we find your account" rather than promising an
  /// email: the endpoint answers identically for an address that is not registered, so
  /// any wording that implied delivery would be a claim the client cannot make.
  static const resetRequestSubheading =
      'Enter your work email and we will send a 6-digit code if we find your account.';
  static const resetVerifySubheading = 'Enter the 6-digit code sent to';
  static const resetEmailLabel = 'Work email';
  static const resetEmailPlaceholder = 'yourname@company.com';
  static const resetCodeLabel = 'Verification code';
  static const resetNewPasswordLabel = 'New password';
  static const resetConfirmPasswordLabel = 'Confirm new password';
  static const resetPasswordPlaceholder = '••••••••';
  static const resetSendCodeButton = 'Send code';
  static const resetSubmitButton = 'Reset password';
  static const resetResendButton = 'Resend code';
  static const resetBackToEmail = 'Use a different email';
  static const resetBackSemanticLabel = 'Back';

  static const profileChangePassword = 'Change password';

  /// Under the Profile button. The consequence is stated before the tap, not
  /// discovered after it: `POST /reset-password` invalidates the account's token,
  /// so finishing the flow ends this device's session.
  static const profileChangePasswordNote =
      "You'll be signed out and will need to sign in again with the new password.";

  /// Announced to a screen reader in place of the six boxes, which are one field as far
  /// as input is concerned.
  static const resetCodeSemanticLabel = 'Verification code, 6 digits';

  static const resetErrorEmailRequired = 'Enter your work email';
  static const resetErrorEmailInvalid = 'Enter a valid email address';
  static const resetErrorCodeRequired = 'Enter the 6-digit code';
  static const resetErrorPasswordRequired = 'Enter a new password';
  static const resetErrorPasswordTooShort =
      'Use at least 8 characters';
  static const resetErrorConfirmMismatch = 'Both passwords must match';

  /// Shown when the client-side countdown reaches zero. The server is still the
  /// authority — the code is submitted anyway if the user tries — so this reads as
  /// guidance, not as a refusal.
  static const resetCodeExpired = 'Code expired — request a new one.';

  static String resetCodeExpiresIn(String remaining) =>
      'Code expires in $remaining';
  static String resetResendIn(int seconds) => 'Resend code in ${seconds}s';

  // Announced in place of a screen full of placeholder blocks while data loads. A
  // skeleton is a visual affordance only — to a screen reader it is two dozen unlabelled
  // boxes, so each one is hidden behind a single sentence instead. See `SkeletonSemantics`.
  static const loadingDashboard = 'Loading dashboard';
  static const loadingRequisitions = 'Loading requisitions';
  static const loadingRequisitionDetails = 'Loading requisition details';
  static const loadingProfile = 'Loading profile';

  static const navDashboard = 'Dashboard';
  static const navMyRequisition = 'My Requisition';
  static const navLogout = 'Log Out';
  static const navLoggingOut = 'Logging out…';

  /// The sign-out itself succeeded locally; only the server-side token revoke did not.
  /// Worded to say exactly that, because the user *is* signed out and telling them
  /// otherwise would invite them to tap again for no reason.
  static const navLogoutRevokeFailed =
      'Signed out on this device. The server could not be reached, so the session may '
      'still be active until the token expires.';

  /// Shown on the dashboard's first back press. Worded as a prompt, not a warning: on
  /// iOS the second press does not actually close the app (see `DashboardBackScope`),
  /// so anything promising an exit would be a lie on half the platforms we ship.
  static const backExitPrompt = 'Press back again to exit';

  static const navOpenMenu = 'Open menu';
  static const navProfile = 'Profile';
  static const navNotifications = 'Notifications';

  /// Caption above the drawer's navigation rows.
  static const navMenuSectionLabel = 'Menu';

  static const dashboardErrorGeneric =
      'Something went wrong. Please try again.';
  static const dashboardNewRequisition = 'New';
  static const dashboardStatApproved = 'Approved';
  static const dashboardStatAssigned = 'Assigned';
  static const dashboardStatPending = 'Pending';
  static const dashboardStatRejected = 'Rejected';

  // Four tiles across a phone leaves each label roughly 62dp of room. These are the
  // design's own abbreviations, swapped in only when the full word does not fit — at a
  // large accessibility text scale, or in a narrow split view. Never shown when the
  // full label fits, because "Appr" is worse to read when there is space for
  // "Approved".
  static const dashboardStatApprovedShort = 'Appr';
  static const dashboardStatAssignedShort = 'Asgn';
  static const dashboardStatPendingShort = 'Pend';
  static const dashboardStatRejectedShort = 'Rejd';
  static const dashboardRecentRequisitions = 'Recent';
  static const dashboardViewAll = 'View all';

  /// Sits beside the hero count. Lower-case on purpose: it reads as the tail of the
  /// sentence "10 requisitions", not as a label of its own. Verbatim from the design.
  static const dashboardStatQualifier = 'requisitions';

  /// The period badge on the right of the hero row.
  ///
  /// The design says "Aug 2026". That is wrong for this number: `getDashboardSummary`
  /// fetches a rolling **365-day** window (`_dashboardWindow` in
  /// `RemoteRequisitionRepository`), not a calendar month, so a month badge beside the
  /// count would state a scope the count does not have. The design's slot is kept; its
  /// wording is not. Must stay in step with that duration.
  static const dashboardStatPeriod = 'Last 12 months';
  static const dashboardNoRecentRequisitions = 'No recent requisitions found';
  static const dashboardRetry = 'Retry';

  static const requisitionListTitle = 'My Requisitions';
  static const requisitionListSearchPlaceholder =
      'Search pickup, drop, purpose…';
  static const requisitionListReset = 'Reset';
  static const requisitionListEmpty = 'No requisitions found';
  static const requisitionListCancel = 'Cancel';
  static const requisitionListCancelConfirmTitle = 'Cancel this requisition?';
  static const requisitionListCancelConfirmBody = "This can't be undone.";
  static const requisitionListCancelConfirmYes = 'Yes, cancel';
  static const requisitionListCancelConfirmNo = 'Keep it';
  static const requisitionListCancelFailed =
      'Could not cancel this requisition';
  static const requisitionListLoadFailed = 'Could not load requisitions';
  static const requisitionListNewFab = 'New requisition';
  static const requisitionListDateRangeInvalid =
      "End date can't be before start date";
  static const requisitionListFilterFrom = 'From';
  static const requisitionListFilterTo = 'To';

  /// Day header above a group of rows, for requisitions whose pickup falls today or
  /// tomorrow — a date there would make the reader do arithmetic.
  static const requisitionListToday = 'Today';
  static const requisitionListTomorrow = 'Tomorrow';
  static const requisitionListYesterday = 'Yesterday';
  static const dialogOk = 'OK';
  static const dialogCancel = 'Cancel';

  static const newRequisitionTitle = 'New Vehicle Requisition';
  static const newRequisitionTogglePassenger = 'Passenger Vehicle';
  static const newRequisitionToggleLogistics = 'Logistics Support';
  static const newRequisitionSectionTripDetails = 'Trip Details';
  static const newRequisitionSectionPassengerDetails = 'Passenger Details';
  static const newRequisitionSectionPurpose = 'Purpose';
  static const newRequisitionSectionVehicleDetails = 'Vehicle Details';
  static const newRequisitionSectionRequesterDetails = 'Requester Details';
  static const newRequisitionFieldPickupDatetime = 'Pickup Date & Time';
  static const newRequisitionFieldPickupLocation = 'Pickup Location';
  static const newRequisitionFieldDropLocation = 'Drop Location';
  static const newRequisitionFieldUsedType = 'Trip Type';
  static const newRequisitionFieldCustomerName = 'Customer Name';
  static const newRequisitionFieldNumberOfPersons = 'No. of Persons';
  static const newRequisitionFieldRequiredFor = 'Required For';
  static const newRequisitionFieldUserType = 'User Type';
  static const newRequisitionFieldSelectEmployees = 'Select Employees';
  static const newRequisitionFieldPurpose = 'Purpose of trip';
  static const newRequisitionFieldRemarks = 'Remarks (optional)';
  static const newRequisitionFieldUserDepartment = 'User Department';
  static const newRequisitionFieldLoadingCapacity = 'Loading Capacity';
  static const newRequisitionFieldGoodsWeight = 'Goods Weight';
  static const newRequisitionFieldStoreName = 'Store Name';
  static const newRequisitionFieldGoodsDetails = 'Goods Details';
  // Placeholders. The grouped form gives every field a caption above it, which frees
  // the input itself to say what a *good* answer looks like instead of repeating the
  // label — the one thing a bare Material field could never do here.
  static const newRequisitionHintPickupDatetime = 'Select date and time';
  static const newRequisitionHintPickupLocation = 'Where should we collect?';
  static const newRequisitionHintDropLocation = 'Where to?';
  static const newRequisitionHintPickupSite = 'Store or site';
  static const newRequisitionHintDropSite = 'Destination';
  static const newRequisitionHintCustomerName = 'Who is it for?';
  static const newRequisitionHintPurpose = 'e.g. Client site visit';
  static const newRequisitionHintRemarks =
      'Anything the fleet desk should know';
  static const newRequisitionHintUserDepartment = 'Requesting department';
  static const newRequisitionHintStoreName = 'Origin store';
  static const newRequisitionHintGoodsDetails = 'What is being moved?';
  static const newRequisitionHintGoodsWeight = 'in kg';
  static const newRequisitionHintEmployeeSearch =
      'Search by name or staff number';

  static const newRequisitionSubmit = 'Submit Requisition';

  /// Second line on each vehicle card — what the type is actually for. Without it
  /// "Cover Van" and "Open Truck" are two names with no stated difference.
  static const vehicleTypeCoverVanHint = 'Enclosed cargo';
  static const vehicleTypeOpenTruckHint = 'Bulk / oversize';
  static const newRequisitionErrorRequired = 'This field is required';
  static const newRequisitionErrorNumberInvalid =
      'Enter a valid number of persons';
  static const newRequisitionErrorSelectEmployee =
      'Select at least one employee';

  /// The server's `min:3` rule, worded for a person rather than echoing Laravel.
  static String newRequisitionErrorTooShort(int minimum) =>
      'Enter at least $minimum characters';

  /// Reached only by pasting: the inputs also hard-limit their length, so typing
  /// cannot get here. Kept because a paste that silently loses its tail is worse than
  /// one that says so.
  static String newRequisitionErrorTooLong(int maximum) =>
      'Use at most $maximum characters';

  /// The server caps `no_of_person` at 15 and requires it to equal the rider count.
  static String newRequisitionErrorTooManyEmployees(int maximum) =>
      'Select at most $maximum employees';

  /// Shown under the picker when a search matched nobody, which is otherwise
  /// indistinguishable from the dropdown simply not having opened.
  static const newRequisitionEmployeeNoMatches =
      'No employees match this search';

  /// Screen-reader label for the × on a selected-rider chip. The bare glyph announces
  /// as "close", which says nothing about which of several chips it closes.
  static String newRequisitionRemoveEmployee(String name) => 'Remove $name';

  /// Shown for a rider the edit form knows only by id, while the directory loads — and
  /// permanently for one who is no longer in it (an employee who has since left is
  /// still on the requisition).
  static const newRequisitionRiderUnresolved = 'Employee details unavailable';
  static const newRequisitionSubmitFailed =
      'Could not submit requisition. Please try again.';
  static const newRequisitionEmployeeSearchFailed =
      'Could not search employees';

  // Capabilities the API contract does not define. Shown in place of the control
  // rather than letting the user submit a payload the backend cannot accept.
  static const unsupportedEmployeePicker =
      'Naming specific passengers is not supported yet — add them to the purpose or remarks.';

  static const requisitionListRetry = 'Retry';

  static const profileTitle = 'Profile';
  static const profileSectionContact = 'Contact';
  static const profileSectionAccount = 'Account';
  static const profileEmail = 'Email';
  static const profilePhone = 'Phone';
  static const profileCompany = 'Company';
  static const profileDesignation = 'Designation';
  static const profileEmployeeId = 'Employee ID';
  static const profileRole = 'Role';
  static const profileStatus = 'Status';
  static const profileMemberSince = 'Member since';
  static const profilePasswordChanged = 'Password last changed';
  static const profileAccountUnavailable = 'Could not load account details';
  static const profileNotProvided = 'Not provided';

  static const requisitionDetailTitle = 'Requisition Details';

  /// Eyebrow on the detail hero. The server exposes no separate human-readable
  /// reference, so this is the row id with a prefix — not an invented format.
  static String requisitionDetailReference(String id) => 'REQ-$id';
  static const requisitionDetailEdit = 'Edit';
  static const requisitionDetailCancelled = 'Requisition cancelled';
  static const requisitionDetailSectionTrip = 'Trip';
  static const requisitionDetailSectionPassenger = 'Passenger Details';
  static const requisitionDetailSectionLogistics = 'Logistics Details';
  static const requisitionDetailSectionRequester = 'Requester';
  static const requisitionDetailSectionAssignment = 'Assignment';
  static const requisitionDetailSectionActivity = 'Activity';
  static const requisitionDetailPickup = 'Pickup';
  static const requisitionDetailDrop = 'Drop';
  static const requisitionDetailPickupAt = 'Pickup at';
  static const requisitionDetailEndsAt = 'Ends at';
  static const requisitionDetailRaisedOn = 'Raised on';
  static const requisitionDetailDepartment = 'Department';
  static const requisitionDetailCompany = 'Company';
  static const requisitionDetailRequestedBy = 'Requested by';

  /// Label for the rider list when the response carried none — the list endpoint omits
  /// `employees[]`, so this is "not reported here", not "nobody is riding".
  static const requisitionDetailPassengers = 'Passengers';
  static String requisitionDetailPassengerNumbered(int position) =>
      'Passenger $position';
  static const requisitionDetailDriver = 'Driver';
  static const requisitionDetailVehicle = 'Vehicle';
  static const requisitionDetailNotAssigned =
      'No driver or vehicle assigned yet';
  static const requisitionDetailNoActivity = 'No activity recorded';
  static const requisitionDetailNotEditable =
      'Only pending requisitions can be edited or cancelled.';

  static const editRequisitionTitle = 'Edit Requisition';
  static const editRequisitionSave = 'Save Changes';
  static const editRequisitionTypeLocked =
      'The requisition type cannot be changed after it is created.';
}
