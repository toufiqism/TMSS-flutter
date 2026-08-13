/// Network configuration.
///
/// The base URL is compiled in but overridable, so switching between production and a
/// local server is a build flag rather than a source edit:
///
/// ```
/// flutter run --dart-define=TMS_BASE_URL=http://10.0.2.2/api
/// ```
///
/// Note the contract's own default (`http://localhost/api`) is cleartext and would be
/// blocked by Android's default network security config on API 28+; the production
/// host below is HTTPS, so no manifest exemption is needed.
class ApiConfig {
  ApiConfig._();

  static const baseUrl = String.fromEnvironment(
    'TMS_BASE_URL',
    defaultValue: 'https://tms.carcopolo.com/bt/api',
  );

  static const connectTimeout = Duration(seconds: 15);
  static const receiveTimeout = Duration(seconds: 30);
  static const sendTimeout = Duration(seconds: 30);

  /// The server pages the list, but exposes no search or sort parameter, so both are
  /// applied client-side over the fetched set (see `RemoteRequisitionRepository`).
  /// These bound that fetch.
  ///
  /// `per_page: 100` is honoured — confirmed with the project owner, so the walk
  /// really does cover 2000 rows rather than silently collapsing to a server default.
  static const maxPageSize = 100;
  static const maxPagesPerFetch = 20;
}
