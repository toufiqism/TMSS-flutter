import 'dart:async';
import 'dart:math';

import '../../core/api_result.dart';
import '../../domain/model/employee.dart';
import '../../domain/model/requisition.dart';
import '../../domain/repository/requisition_repository.dart';

/// Serializes access to the shared mutable requisition list across concurrent calls that each
/// await mid-operation (e.g. a refresh() and a cancelRequisition() launched together) — Dart's
/// single-isolate event loop still interleaves at await points, same reason Kotlin's fake repo
/// needs a Mutex even without real threads.
class _AsyncLock {
  Future<void> _last = Future<void>.value();

  Future<T> synchronized<T>(Future<T> Function() action) {
    final previous = _last;
    final completer = Completer<void>();
    _last = completer.future;
    return previous.then((_) async {
      try {
        return await action();
      } finally {
        completer.complete();
      }
    });
  }
}

/// In-memory stand-in for the real backend (see FakeAuthRepository for why). Employee names here
/// are synthetic, not the real company directory pulled up while inspecting the web app's
/// "Select Employees" picker — that was real personnel data and doesn't belong hardcoded into
/// app source. Same seed data as the Android app's FakeRequisitionRepository.kt.
class FakeRequisitionRepository implements RequisitionRepository {
  FakeRequisitionRepository() {
    final now = DateTime.now();
    _requisitions = [
      Requisition(
        id: 'r1',
        pickupDateTime: DateTime(now.year, now.month, now.day - 1, 9, 0),
        pickupLocation: 'Head Office, Tejgaon, Dhaka',
        dropLocation: 'Hazrat Shahjalal International Airport',
        status: RequisitionStatus.approved,
        details: const RequisitionDetails.passenger(
          usedType: UsedType.pickupAndDrop,
          customerName: 'Md. Tofiq Akbar',
          numberOfPersons: 1,
          requiredFor: RequiredFor.ownUser,
          purpose: 'Client meeting airport pickup',
        ),
        createdAt: DateTime(now.year, now.month, now.day - 1, 8, 10),
      ),
      Requisition(
        id: 'r2',
        pickupDateTime: now.subtract(const Duration(hours: 6)),
        pickupLocation: 'Gulshan-1, Dhaka',
        dropLocation: 'Head Office, Tejgaon, Dhaka',
        remarks: 'Please confirm 30 minutes before pickup',
        status: RequisitionStatus.pending,
        details: const RequisitionDetails.passenger(
          usedType: UsedType.pickup,
          customerName: 'Md. Tofiq Akbar',
          numberOfPersons: 3,
          requiredFor: RequiredFor.someoneElse,
          userType: RequisitionUserType.internal,
          employeeIds: ['e1', 'e4'],
          purpose: 'Vendor negotiation meeting',
        ),
        createdAt: now.subtract(const Duration(hours: 7)),
      ),
      Requisition(
        id: 'r3',
        pickupDateTime: DateTime(now.year, now.month, now.day - 3, 14, 30),
        pickupLocation: 'Central Warehouse, Tongi',
        dropLocation: 'Chattogram Depot',
        status: RequisitionStatus.assigned,
        details: const RequisitionDetails.logistics(
          vehicleType: VehicleType.openTruck,
          customerName: 'Md. Tofiq Akbar',
          userDepartment: 'Operations',
          loadingCapacity: LoadingCapacity.ton5,
          goodsWeight: '4.2 Ton',
          storeName: 'Central Warehouse',
          goodsDetails: 'Network equipment pallets (12 boxes)',
        ),
        createdAt: DateTime(now.year, now.month, now.day - 3, 11, 0),
      ),
      Requisition(
        id: 'r4',
        pickupDateTime: DateTime(now.year, now.month, now.day - 5, 10, 0),
        pickupLocation: 'Uttara Sector 7, Dhaka',
        dropLocation: 'Head Office, Tejgaon, Dhaka',
        remarks: 'Requested on short notice',
        status: RequisitionStatus.rejected,
        details: const RequisitionDetails.passenger(
          usedType: UsedType.drop,
          customerName: 'Md. Tofiq Akbar',
          numberOfPersons: 1,
          requiredFor: RequiredFor.ownUser,
          purpose: 'Personal errand',
        ),
        createdAt: DateTime(now.year, now.month, now.day - 5, 9, 45),
      ),
      Requisition(
        id: 'r5',
        pickupDateTime: DateTime(now.year, now.month, now.day - 8, 8, 30),
        pickupLocation: 'Head Office, Tejgaon, Dhaka',
        dropLocation: 'Savar Plant',
        status: RequisitionStatus.approved,
        details: const RequisitionDetails.logistics(
          vehicleType: VehicleType.coverVan,
          customerName: 'Md. Tofiq Akbar',
          userDepartment: 'Operations',
          loadingCapacity: LoadingCapacity.ton2,
          goodsWeight: '1.8 Ton',
          storeName: 'Head Office Stores',
          goodsDetails: 'Spare parts for Savar plant maintenance',
        ),
        createdAt: DateTime(now.year, now.month, now.day - 8, 8, 0),
      ),
    ];
  }

  final _lock = _AsyncLock();

  static const _employees = [
    Employee(id: 'e1', name: 'Rafiq Hasan', employeeCode: '1-101', designation: 'Deputy Manager', department: 'Operations', company: 'Bangla Trac Communications Ltd.'),
    Employee(id: 'e2', name: 'Nusrat Jahan', employeeCode: '1-102', designation: 'Assistant Manager', department: 'Finance & Accounts', company: 'Bangla Trac Communications Ltd.'),
    Employee(id: 'e3', name: 'Shahriar Kabir', employeeCode: '1-103', designation: 'Senior Executive', department: 'Administration', company: 'B-Trac Solutions Limited'),
    Employee(id: 'e4', name: 'Farhana Islam', employeeCode: '1-104', designation: 'Manager', department: 'Human Resources', company: 'Bangla Trac Communications Ltd.'),
    Employee(id: 'e5', name: 'Imran Chowdhury', employeeCode: '1-105', designation: 'Executive', department: 'Core Network', company: 'B-Trac Solutions Limited'),
    Employee(id: 'e6', name: 'Sabbir Ahmed', employeeCode: '1-106', designation: 'Senior Manager', department: 'Corporate Affairs', company: 'Bangla Trac Communications Ltd.'),
  ];

  late final List<Requisition> _requisitions;

  @override
  Future<ApiResult<DashboardSummary>> getDashboardSummary() {
    return _lock.synchronized(() async {
      await Future<void>.delayed(const Duration(milliseconds: 400));
      final sorted = [..._requisitions]..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return ApiResult.success(DashboardSummary(
        allCount: _requisitions.length,
        approvedCount: _requisitions.where((r) => r.status == RequisitionStatus.approved).length,
        assignedCount: _requisitions.where((r) => r.status == RequisitionStatus.assigned).length,
        pendingCount: _requisitions.where((r) => r.status == RequisitionStatus.pending).length,
        rejectedCount: _requisitions.where((r) => r.status == RequisitionStatus.rejected).length,
        recentRequisitions: sorted.take(5).toList(),
      ));
    });
  }

  @override
  Future<ApiResult<List<Requisition>>> getRequisitions(RequisitionListFilter filter) {
    return _lock.synchronized(() async {
      await Future<void>.delayed(const Duration(milliseconds: 500));
      var result = [..._requisitions];

      if (filter.searchQuery.trim().isNotEmpty) {
        final q = filter.searchQuery.trim().toLowerCase();
        result = result
            .where((r) =>
                r.pickupLocation.toLowerCase().contains(q) ||
                r.dropLocation.toLowerCase().contains(q) ||
                r.purposeText.toLowerCase().contains(q))
            .toList();
      }
      if (filter.startDate != null) {
        result = result.where((r) => !r.pickupDateTime.isBefore(filter.startDate!)).toList();
      }
      if (filter.endDate != null) {
        result = result.where((r) => !r.pickupDateTime.isAfter(filter.endDate!)).toList();
      }

      int Function(Requisition, Requisition) comparator = switch (filter.sortBy) {
        RequisitionSortField.date => (a, b) => a.pickupDateTime.compareTo(b.pickupDateTime),
        RequisitionSortField.pickup => (a, b) => a.pickupLocation.compareTo(b.pickupLocation),
        RequisitionSortField.destination => (a, b) => a.dropLocation.compareTo(b.dropLocation),
        RequisitionSortField.purpose => (a, b) => a.purposeText.compareTo(b.purposeText),
        RequisitionSortField.status => (a, b) => a.status.index.compareTo(b.status.index),
      };
      result.sort(filter.sortDescending ? (a, b) => comparator(b, a) : comparator);

      final fromIndex = max(0, (filter.page - 1) * filter.pageSize);
      final page = fromIndex >= result.length
          ? <Requisition>[]
          : result.sublist(fromIndex, min(fromIndex + filter.pageSize, result.length));
      return ApiResult.success(page);
    });
  }

  @override
  Future<ApiResult<Requisition>> submitRequisition(NewRequisitionRequest request) {
    return _lock.synchronized(() async {
      await Future<void>.delayed(const Duration(milliseconds: 700));
      final details = switch (request) {
        PassengerRequest(:final usedType, :final customerName, :final numberOfPersons, :final requiredFor, :final userType, :final employeeIds, :final purpose) =>
          RequisitionDetails.passenger(
            usedType: usedType,
            customerName: customerName,
            numberOfPersons: numberOfPersons,
            requiredFor: requiredFor,
            userType: userType,
            employeeIds: employeeIds,
            purpose: purpose,
          ),
        LogisticsRequest(:final vehicleType, :final customerName, :final userDepartment, :final loadingCapacity, :final goodsWeight, :final storeName, :final goodsDetails) =>
          RequisitionDetails.logistics(
            vehicleType: vehicleType,
            customerName: customerName,
            userDepartment: userDepartment,
            loadingCapacity: loadingCapacity,
            goodsWeight: goodsWeight,
            storeName: storeName,
            goodsDetails: goodsDetails,
          ),
      };
      final created = Requisition(
        id: _generateId(),
        pickupDateTime: request.pickupDateTime,
        pickupLocation: request.pickupLocation,
        dropLocation: request.dropLocation,
        remarks: request.remarks,
        status: RequisitionStatus.pending,
        details: details,
        createdAt: DateTime.now(),
      );
      _requisitions.insert(0, created);
      return ApiResult.success(created);
    });
  }

  @override
  Future<ApiResult<void>> cancelRequisition(String id) {
    return _lock.synchronized(() async {
      await Future<void>.delayed(const Duration(milliseconds: 300));
      Requisition? target;
      for (final r in _requisitions) {
        if (r.id == id) {
          target = r;
          break;
        }
      }
      if (target == null) {
        return const ApiResult.error('Requisition not found');
      }
      if (target.status != RequisitionStatus.pending) {
        return const ApiResult.error('Only pending requisitions can be cancelled');
      }
      _requisitions.removeWhere((r) => r.id == id);
      return const ApiResult.success(null);
    });
  }

  @override
  Future<ApiResult<List<Employee>>> searchEmployees(String query) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    final matches = query.trim().isEmpty
        ? _employees
        : _employees.where((e) => e.name.toLowerCase().contains(query.toLowerCase()));
    return ApiResult.success(matches.take(10).toList());
  }

  String _generateId() {
    final random = Random.secure();
    return List<int>.generate(16, (_) => random.nextInt(256))
        .map((b) => b.toRadixString(16).padLeft(2, '0'))
        .join();
  }
}
