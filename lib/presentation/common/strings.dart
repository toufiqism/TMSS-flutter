/// Plain Dart constants mirroring the Android app's strings.xml values verbatim.
/// Full ARB/flutter_localizations scaffolding wasn't in scope for this port — add it later
/// if/when multi-language support is actually needed.
class TmsStrings {
  TmsStrings._();

  static const appName = 'TMS';

  static const loginHeading = 'Sign In';
  static const loginSubheading = 'Enter your username and password';
  static const loginUsernamePlaceholder = 'yourname@company.com';
  static const loginPasswordPlaceholder = '••••••••';
  static const loginUsernameLabel = 'Username';
  static const loginPasswordLabel = 'Password';
  static const loginForgotPassword = 'Forgotten password?';
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
  static const navOpenMenu = 'Open menu';
  static const navProfile = 'Profile';
  static const navNotifications = 'Notifications';

  static const dashboardErrorGeneric = 'Something went wrong. Please try again.';
  static const dashboardNeedVehicleTitle = 'Need a vehicle?';
  static const dashboardNeedVehicleSubtitle = 'Submit a request in under a minute';
  static const dashboardRequisitionNow = 'Requisition Now';
  static const dashboardStatAll = 'All Requisitions';
  static const dashboardStatApproved = 'Approved';
  static const dashboardStatAssigned = 'Assigned';
  static const dashboardStatPending = 'Pending';
  static const dashboardStatRejected = 'Rejected';
  static const dashboardRecentRequisitions = 'Recent Requisitions';
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
  static const newRequisitionSubmitFailed = 'Could not submit requisition. Please try again.';
}
