import '../../core/api_config.dart';
import '../../core/api_result.dart';
import '../../core/network_messages.dart';
import '../../core/telemetry/crash_reporter.dart';
import '../../domain/model/employee.dart';
import '../../domain/model/requisition.dart';
import '../../domain/repository/requisition_repository.dart';
import '../remote/dto/json_reader.dart';
import '../remote/dto/requisition_mapper.dart';
import '../remote/dto/wire_date_time.dart';
import '../remote/safe_api_call.dart';
import '../remote/tracgo_api_client.dart';

/// Requisitions against `/requisitions`.
///
/// Two of this repository's jobs have no endpoint behind them, and both are solved by
/// deriving from the list rather than by pretending the endpoint exists:
///
/// - **Search and sort.** `GET /requisitions` accepts only `per_page`, `page`, `fdate`
///   and `tdate`. Filtering a single server page client-side would be worse than
///   useless — a match on page 3 would be invisible while page 1 showed "no results" —
///   so the date window is fetched in full (bounded by [ApiConfig.maxPagesPerFetch])
///   and then filtered, sorted and paged locally.
/// - **Dashboard counts.** No summary endpoint exists, so the counts are computed over
///   the same fetched set.
///
/// The bound is the honest limitation here: a user with more than
/// `maxPageSize * maxPagesPerFetch` requisitions inside the window would see counts
/// and search results computed over the first slice only. For a per-user requisition
/// list that ceiling is far above realistic volumes, and it is a deliberate stop
/// rather than an unbounded loop against an unverified pagination envelope.
class RemoteRequisitionRepository implements RequisitionRepository {
  RemoteRequisitionRepository(
    this._apiClient, {
    // Defaulted rather than required so tests and the live-API script keep their
    // single-argument construction; the real binding in `di/providers.dart` passes the
    // Firebase-backed reporter.
    // An initializing formal is impossible here: the field is private and a
    // named parameter cannot be, so the parameter and the field must differ.
    CrashReporter reporter = const NoOpCrashReporter(),
    // ignore: prefer_initializing_formals
  }) : _reporter = reporter;

  final TracGoApiClient _apiClient;
  final CrashReporter _reporter;

  /// How far back the dashboard looks. The server defaults to one month when no dates
  /// are sent, which would silently under-count the tiles, so a window is always sent
  /// explicitly.
  static const _dashboardWindow = Duration(days: 365);

  @override
  Future<ApiResult<DashboardSummary>> getDashboardSummary() async {
    final now = DateTime.now();
    final result = await _fetchWindow(
      from: now.subtract(_dashboardWindow),
      to: now,
    );

    return result.mapSuccess((all) {
      final sorted = [...all]..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return DashboardSummary(
        allCount: all.length,
        approvedCount: _countOf(all, RequisitionStatus.approved),
        assignedCount: _countOf(all, RequisitionStatus.assigned),
        pendingCount: _countOf(all, RequisitionStatus.pending),
        rejectedCount: _countOf(all, RequisitionStatus.rejected),
        recentRequisitions: sorted.take(5).toList(),
      );
    });
  }

  @override
  Future<ApiResult<List<Requisition>>> getRequisitions(
    RequisitionListFilter filter,
  ) async {
    final result = await _fetchWindow(from: filter.startDate, to: filter.endDate);
    return result.mapSuccess((all) => _applyFilterLocally(all, filter));
  }

  @override
  Future<ApiResult<Requisition>> submitRequisition(NewRequisitionRequest request) {
    return safeApiCall<Requisition>(
      () => _apiClient.createRequisition(RequisitionMapper.toWriteJson(request)),
      decode: _decodeSingle,
      reporter: _reporter,
      operation: 'POST /requisitions',
    );
  }

  @override
  Future<ApiResult<void>> cancelRequisition(String id) async {
    final result = await safeApiCall<void>(
      () => _apiClient.cancelRequisition(id),
      // The response echoes the cancelled requisition, but nothing needs it: the list
      // refetches after a successful cancel.
      decode: (_) {},
      reporter: _reporter,
      operation: 'POST /requisitions/{id}/cancel',
    );
    return result;
  }

  @override
  Future<ApiResult<Requisition>> getRequisition(String id) {
    return safeApiCall<Requisition>(
      () => _apiClient.getRequisition(id),
      decode: _decodeSingle,
      reporter: _reporter,
      // The id stays out of the label on purpose: it is the Crashlytics grouping key,
      // and one issue per requisition id would be one issue per user.
      operation: 'GET /requisitions/{id}',
    );
  }

  @override
  Future<ApiResult<Requisition>> updateRequisition(
    String id,
    NewRequisitionRequest request,
  ) {
    return safeApiCall<Requisition>(
      () => _apiClient.updateRequisition(id, RequisitionMapper.toWriteJson(request)),
      decode: _decodeSingle,
      reporter: _reporter,
      operation: 'PUT /requisitions/{id}',
    );
  }

  /// No employee directory endpoint exists in the contract.
  ///
  /// This returns a failure rather than an empty list on purpose: an empty list would
  /// render as "no employees matched", which is a lie. The picker that calls this is
  /// itself disabled via `ApiCapabilities.employeeDirectory`, so in practice this is
  /// unreachable — it exists so the interface stays honest.
  @override
  Future<ApiResult<List<Employee>>> searchEmployees(String query) {
    return Future.value(
      const ApiResult<List<Employee>>.error(NetworkMessages.unsupportedOperation),
    );
  }

  /// Walks the server's pages for a date window and returns everything in it.
  ///
  /// Stops at the first failure and propagates it, so a mid-walk 401 surfaces as
  /// `logout` rather than as a partial list the caller would treat as complete.
  Future<ApiResult<List<Requisition>>> _fetchWindow({
    DateTime? from,
    DateTime? to,
  }) async {
    final collected = <Requisition>[];

    for (var page = 1; page <= ApiConfig.maxPagesPerFetch; page++) {
      final pageResult = await safeApiCall<_RequisitionPage>(
        () => _apiClient.listRequisitions(
          page: page,
          perPage: ApiConfig.maxPageSize,
          fromDate: from == null ? null : WireDateTime.formatDate(from),
          toDate: to == null ? null : WireDateTime.formatDate(to),
        ),
        decode: _decodePage,
        reporter: _reporter,
        operation: 'GET /requisitions',
      );

      switch (pageResult) {
        case ApiSuccess<_RequisitionPage>(:final response):
          collected.addAll(response.items);
          if (response.items.isEmpty ||
              !response.pageInfo.hasMoreAfter(
                page,
                response.items.length,
                ApiConfig.maxPageSize,
              )) {
            return ApiResult.success(collected);
          }
        case ApiError<_RequisitionPage>(:final message, :final errorCode, :final fieldErrors):
          return ApiResult.error(message, errorCode, fieldErrors);
        case ApiLogout<_RequisitionPage>(:final message, :final code):
          return ApiResult.logout(message, code);
        case ApiMaintenance<_RequisitionPage>(:final message, :final code):
          return ApiResult.maintenance(message, code);
        case ApiOffline<_RequisitionPage>(:final message):
          return ApiResult.offline(message);
      }
    }

    // Cap reached. Returning what we have beats failing outright: a truncated list is
    // still usable, whereas an error would leave the screen empty.
    return ApiResult.success(collected);
  }

  /// Client-side stand-in for the query parameters the contract does not define.
  List<Requisition> _applyFilterLocally(
    List<Requisition> all,
    RequisitionListFilter filter,
  ) {
    var result = all;

    final query = filter.searchQuery.trim().toLowerCase();
    if (query.isNotEmpty) {
      result = result
          .where((r) =>
              r.pickupLocation.toLowerCase().contains(query) ||
              r.dropLocation.toLowerCase().contains(query) ||
              r.purposeText.toLowerCase().contains(query))
          .toList();
    }

    // The server filters on its own date semantics, which are unverified; re-applying
    // the bounds locally makes the visible result match the pickers regardless.
    final start = filter.startDate;
    if (start != null) {
      result = result.where((r) => !r.pickupDateTime.isBefore(start)).toList();
    }
    final end = filter.endDate;
    if (end != null) {
      result = result.where((r) => !r.pickupDateTime.isAfter(end)).toList();
    }

    int compare(Requisition a, Requisition b) => switch (filter.sortBy) {
          RequisitionSortField.date => a.pickupDateTime.compareTo(b.pickupDateTime),
          RequisitionSortField.pickup => a.pickupLocation.compareTo(b.pickupLocation),
          RequisitionSortField.destination => a.dropLocation.compareTo(b.dropLocation),
          RequisitionSortField.purpose => a.purposeText.compareTo(b.purposeText),
          RequisitionSortField.status => a.status.index.compareTo(b.status.index),
        };

    final sorted = [...result]
      ..sort(filter.sortDescending ? (a, b) => compare(b, a) : compare);

    final fromIndex = (filter.page - 1) * filter.pageSize;
    if (fromIndex >= sorted.length || fromIndex < 0) return const [];
    final toIndex = fromIndex + filter.pageSize;
    return sorted.sublist(fromIndex, toIndex > sorted.length ? sorted.length : toIndex);
  }

  static int _countOf(List<Requisition> all, RequisitionStatus status) =>
      all.where((r) => r.status == status).length;

  /// Unwraps `{success, message, data: {...requisition}}`.
  ///
  /// Throws on an unusable payload; `safeApiCall` converts that into an error result.
  static Requisition _decodeSingle(dynamic body) {
    final data = body is Map<String, dynamic> ? body.mapOrNull('data') : null;
    final requisition = data == null ? null : RequisitionMapper.fromJson(data);
    if (requisition == null) {
      throw const FormatException('Response contained no usable requisition');
    }
    return requisition;
  }

  /// Unwraps the list's **doubly-nested** envelope:
  /// `{success, message, data: {data: [...rows], pagination: {...}}}`.
  ///
  /// The rows are at `data.data`, not `data`. Reading the outer `data` as the array —
  /// which is what the contract's schema implied — yields a Map where a List was
  /// expected and produces a permanently empty list with no error anywhere.
  static _RequisitionPage _decodePage(dynamic body) {
    if (body is! Map<String, dynamic>) {
      throw const FormatException('Expected a JSON object');
    }
    final envelope = body.mapOrNull('data');
    if (envelope == null) {
      throw const FormatException('Response contained no data envelope');
    }
    final items = envelope
        .objectListOrEmpty('data')
        .map(RequisitionMapper.fromJson)
        .nonNulls
        .toList();
    return _RequisitionPage(items, PageInfo.fromEnvelope(envelope));
  }
}

class _RequisitionPage {
  const _RequisitionPage(this.items, this.pageInfo);

  final List<Requisition> items;
  final PageInfo pageInfo;
}
