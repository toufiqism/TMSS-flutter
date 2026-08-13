class RoutePaths {
  RoutePaths._();

  static const splash = '/splash';
  static const login = '/login';
  static const dashboard = '/dashboard';
  static const requisitionList = '/requisitions';
  static const newRequisition = '/requisitions/new';

  /// ⚠️ Order matters in the router: `/requisitions/new` must be registered *before*
  /// `/requisitions/:id`, or `:id` swallows the literal "new" and the create screen
  /// becomes unreachable. go_router matches routes in declaration order.
  static const requisitionDetail = '/requisitions/:id';
  static const requisitionEdit = '/requisitions/:id/edit';

  static String detailFor(String id) => '/requisitions/$id';
  static String editFor(String id) => '/requisitions/$id/edit';
}
