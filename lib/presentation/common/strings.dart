/// Plain Dart constants mirroring the Android app's strings.xml values verbatim.
/// Full ARB/flutter_localizations scaffolding wasn't in scope for this port — add it later
/// if/when multi-language support is actually needed.
class TracGoStrings {
  TracGoStrings._();

  static const appName = 'TracGo';

  static const loginHeading = 'Sign In';
  static const loginSubheading = 'Enter your username and password';
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
  static const loginContactAdmin = 'Contact system admin.';
  static const loginSignInButton = 'Sign In';
  static const loginTaglineTitle = 'Transport Management System';
  static const loginTaglineBody =
      'One platform for fleet allocation, tracking, and vehicle requisitions across your enterprise.';
  static const loginErrorRequiredFields = 'Username and password are required';
  static const loginErrorInvalidCredentials = 'Username/Password is invalid!';

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
  static const navOpenMenu = 'Open menu';
  static const navProfile = 'Profile';
  static const navNotifications = 'Notifications';

  static const dashboardErrorGeneric = 'Something went wrong. Please try again.';
  static const dashboardNewRequisition = 'New';
  static const dashboardStatAll = 'All Requisitions';
  static const dashboardStatApproved = 'Approved';
  static const dashboardStatAssigned = 'Assigned';
  static const dashboardStatPending = 'Pending';
  static const dashboardStatRejected = 'Rejected';
  static const dashboardRecentRequisitions = 'Recent Req.';
  static const dashboardViewAll = 'View All';
  static const dashboardNoRecentRequisitions = 'No recent requisitions found';
  static const dashboardRetry = 'Retry';

  static const requisitionListTitle = 'My Requisitions';
  static const requisitionListSearchPlaceholder = 'Search pickup, drop, purpose…';
  static const requisitionListReset = 'Reset';
  static const requisitionListEmpty = 'No requisitions found';
  static const requisitionListCancel = 'Cancel';
  static const requisitionListCancelConfirmTitle = 'Cancel this requisition?';
  static const requisitionListCancelConfirmBody = "This can't be undone.";
  static const requisitionListCancelConfirmYes = 'Yes, cancel';
  static const requisitionListCancelConfirmNo = 'Keep it';
  static const requisitionListCancelFailed = 'Could not cancel this requisition';
  static const requisitionListLoadFailed = 'Could not load requisitions';
  static const requisitionListNewFab = 'New requisition';
  static const requisitionListDateRangeInvalid = "End date can't be before start date";
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
  static const newRequisitionSubmit = 'Submit Requisition';
  static const newRequisitionErrorRequired = 'This field is required';
  static const newRequisitionErrorNumberInvalid = 'Enter a valid number of persons';
  static const newRequisitionErrorSelectEmployee = 'Select at least one employee';

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
  static const newRequisitionEmployeeNoMatches = 'No employees match this search';

  /// Shown for a rider the edit form knows only by id, while the directory loads — and
  /// permanently for one who is no longer in it (an employee who has since left is
  /// still on the requisition).
  static const newRequisitionRiderUnresolved = 'Employee details unavailable';
  static const newRequisitionSubmitFailed = 'Could not submit requisition. Please try again.';
  static const newRequisitionEmployeeSearchFailed = 'Could not search employees';

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
  static const requisitionDetailNotAssigned = 'No driver or vehicle assigned yet';
  static const requisitionDetailNoActivity = 'No activity recorded';
  static const requisitionDetailNotEditable =
      'Only pending requisitions can be edited or cancelled.';

  static const editRequisitionTitle = 'Edit Requisition';
  static const editRequisitionSave = 'Save Changes';
  static const editRequisitionTypeLocked =
      'The requisition type cannot be changed after it is created.';
}
