import 'package:flutter_test/flutter_test.dart';
import 'package:tmss/data/remote/dto/requisition_mapper.dart';
import 'package:tmss/domain/model/requisition.dart';

void main() {
  group('fromJson', () {
    test('maps a fully-populated row', () {
      final requisition = RequisitionMapper.fromJson({
        'id': 42,
        'status': 'Pending',
        'req_type': 'passenger_vehicle',
        'requisition_for': 'Own User',
        'requisition_for_user': 'Internal User',
        'used_type': 'Pickup & Drop',
        'purpose': 'Client meeting',
        'customer_name': 'Bangla Trac Ltd.',
        'pickup_location': 'Head Office, Tejgaon',
        'drop_location': 'Gulshan-2, Dhaka',
        'start_time': '2026-07-25 09:30:00',
        'no_of_person': 3,
        'remarks': 'AC vehicle please',
        'created_at': '2026-07-24 11:00:00',
      });

      expect(requisition, isNotNull);
      expect(requisition!.id, '42', reason: 'an integer id normalises to the domain String');
      expect(requisition.status, RequisitionStatus.pending);
      expect(requisition.pickupLocation, 'Head Office, Tejgaon');
      expect(requisition.remarks, 'AC vehicle please');
      expect(requisition.type, RequisitionType.passenger);
      expect(requisition.purposeText, 'Client meeting');

      final details = requisition.details as PassengerDetails;
      expect(details.usedType, UsedType.pickupAndDrop);
      expect(details.numberOfPersons, 3);
      expect(details.customerName, 'Bangla Trac Ltd.');
    });

    test('accepts a string id, which the contract says is equally possible', () {
      final requisition = RequisitionMapper.fromJson({
        'id': 'a3f-9921',
        'start_time': '2026-07-25 09:30:00',
      });

      expect(requisition!.id, 'a3f-9921');
    });

    test('returns null without an id, since such a row has no working actions', () {
      expect(RequisitionMapper.fromJson({'status': 'Pending'}), isNull);
      expect(RequisitionMapper.fromJson({'id': null}), isNull);
    });

    test('survives a row where everything optional is missing', () {
      final requisition = RequisitionMapper.fromJson({'id': 7});

      expect(requisition, isNotNull);
      expect(requisition!.pickupLocation, '');
      expect(requisition.dropLocation, '');
      expect(requisition.remarks, isNull);
      expect(requisition.status, RequisitionStatus.unknown);
      expect((requisition.details as PassengerDetails).numberOfPersons, 1);
    });

    test('an unrecognised status renders as unknown instead of throwing', () {
      // The contract flags the status vocabulary as its biggest gap, so the client
      // must not assume it has seen every value.
      final requisition = RequisitionMapper.fromJson({
        'id': 7,
        'status': 'Awaiting Fleet Approval',
      });

      expect(requisition!.status, RequisitionStatus.unknown);
    });

    test('falls back to the pickup time when created_at is absent', () {
      // `created_at` is not in the contract at all; ordering must still work.
      final requisition = RequisitionMapper.fromJson({
        'id': 7,
        'start_time': '2026-07-25 09:30:00',
      });

      expect(requisition!.createdAt, requisition.pickupDateTime);
    });

    test('a malformed date does not discard the row', () {
      final requisition = RequisitionMapper.fromJson({
        'id': 7,
        'start_time': 'sometime next week',
      });

      expect(requisition, isNotNull);
    });
  });

  group('detail-only fields', () {
    test('parses the audit log, including its UTC timestamps', () {
      final requisition = RequisitionMapper.fromJson({
        'id': 2836,
        'start_time': '2026-08-20 10:00:00',
        'audit_logs': [
          {
            'id': 5124,
            'requisition_status': 'Pending',
            'remarks': 'Requisition Created',
            'created_by_name': 'Md. Tofiq Akbar',
            'created_by_id_no': '2-765',
            'created_at': '2026-08-13 18:34:51',
          },
        ],
      });

      final entry = requisition!.auditLog.single;
      expect(entry.id, '5124');
      expect(entry.status, RequisitionStatus.pending);
      expect(entry.remarks, 'Requisition Created');
      expect(entry.actorName, 'Md. Tofiq Akbar');
      expect(entry.actorCode, '2-765');
      // created_at is UTC on this API, unlike start_time.
      expect(entry.at!.toUtc(), DateTime.utc(2026, 8, 13, 18, 34, 51));
    });

    test('drops audit entries with no id instead of failing the whole requisition', () {
      final requisition = RequisitionMapper.fromJson({
        'id': 1,
        'audit_logs': [
          {'requisition_status': 'Pending'},
          {'id': 2, 'requisition_status': 'Approved'},
        ],
      });

      expect(requisition!.auditLog, hasLength(1));
      expect(requisition.auditLog.single.status, RequisitionStatus.approved);
    });

    test('null driver and vehicle mean unassigned, not a broken row', () {
      // Both were null on every requisition observed; this is the normal pending case.
      final requisition = RequisitionMapper.fromJson({
        'id': 1,
        'driver': null,
        'vehicle': null,
      });

      expect(requisition!.driver, isNull);
      expect(requisition.vehicle, isNull);
      expect(requisition.hasAssignment, isFalse);
    });

    test('reads driver and vehicle across the plausible key spellings', () {
      // The server's field names for these are unverified, so the mapper tries several.
      final requisition = RequisitionMapper.fromJson({
        'id': 1,
        'driver': {'driver_name': 'Karim Mia', 'mobile': '01700000000'},
        'vehicle': {'registration_no': 'DHAKA-METRO-GA-1234', 'model': 'Hiace'},
      });

      expect(requisition!.driver!.name, 'Karim Mia');
      expect(requisition.driver!.phone, '01700000000');
      expect(requisition.vehicle!.registrationNumber, 'DHAKA-METRO-GA-1234');
      expect(requisition.vehicle!.model, 'Hiace');
      expect(requisition.hasAssignment, isTrue);
    });

    test('an object with no recognisable keys is treated as unassigned', () {
      final requisition = RequisitionMapper.fromJson({
        'id': 1,
        'driver': {'totally_unexpected': 'x'},
      });

      expect(requisition!.driver, isNull, reason: 'nothing usable parsed');
    });

    test('department, company and end time come through', () {
      final requisition = RequisitionMapper.fromJson({
        'id': 1,
        'department_name': 'Android Applications',
        'company_name': 'B-Trac Solutions Limited',
        'end_time': '2026-08-20 14:00:00',
      });

      expect(requisition!.departmentName, 'Android Applications');
      expect(requisition.companyName, 'B-Trac Solutions Limited');
      expect(requisition.endDateTime!.toUtc(), DateTime.utc(2026, 8, 20, 8));
    });

    test('list rows carry no detail fields, which stays distinguishable from empty', () {
      final requisition = RequisitionMapper.fromJson({'id': 1});

      expect(requisition!.departmentName, isNull);
      expect(requisition.endDateTime, isNull);
      expect(requisition.auditLog, isEmpty);
    });
  });

  group('canBeModified', () {
    test('mirrors the server rule: pending only', () {
      Requisition withStatus(RequisitionStatus status) => RequisitionMapper.fromJson({
            'id': 1,
            'status': status == RequisitionStatus.unknown ? 'Whatever' : status.label,
          })!;

      expect(withStatus(RequisitionStatus.pending).canBeModified, isTrue);
      expect(withStatus(RequisitionStatus.approved).canBeModified, isFalse);
      expect(withStatus(RequisitionStatus.assigned).canBeModified, isFalse);
      expect(withStatus(RequisitionStatus.rejected).canBeModified, isFalse);
      expect(withStatus(RequisitionStatus.unknown).canBeModified, isFalse,
          reason: 'an unrecognised status must never be treated as cancellable');
    });
  });

  group('status parsing', () {
    test('ignores case, spacing and separators, since the vocabulary is unconfirmed', () {
      expect(RequisitionStatus.fromWire('pending'), RequisitionStatus.pending);
      expect(RequisitionStatus.fromWire('PENDING'), RequisitionStatus.pending);
      expect(RequisitionStatus.fromWire(' Approved '), RequisitionStatus.approved);
      expect(RequisitionStatus.fromWire('as_signed'), RequisitionStatus.assigned);
    });

    test('reads the server\'s bare `Cancel`, not just the adjective', () {
      // Verified live: cancelling a requisition sets status to `Cancel`.
      expect(RequisitionStatus.fromWire('Cancel'), RequisitionStatus.cancelled);
      expect(RequisitionStatus.fromWire('Cancelled'), RequisitionStatus.cancelled);
      expect(RequisitionStatus.fromWire('canceled'), RequisitionStatus.cancelled);
    });

    test('null and empty read as unknown', () {
      expect(RequisitionStatus.fromWire(null), RequisitionStatus.unknown);
      expect(RequisitionStatus.fromWire('  '), RequisitionStatus.unknown);
    });
  });

  group('toWriteJson', () {
    final request = NewRequisitionRequest.passenger(
      pickupDateTime: DateTime.utc(2026, 7, 25, 3, 30),
      pickupLocation: 'Head Office, Tejgaon',
      dropLocation: 'Gulshan-2, Dhaka',
      remarks: '  ',
      usedType: UsedType.pickupAndDrop,
      customerName: 'Bangla Trac Ltd.',
      numberOfPersons: 3,
      requiredFor: RequiredFor.ownUser,
      userType: RequisitionUserType.internal,
      purpose: 'Client meeting',
    );

    test('emits exactly the contract field names and enum spellings', () {
      final json = RequisitionMapper.toWriteJson(request);

      expect(json['req_type'], 'passenger_vehicle');
      expect(json['requisition_for'], 'Own User');
      expect(json['requisition_for_user'], 'Internal User');
      expect(json['used_type'], 'Pickup & Drop',
          reason: 'exact-match string, ampersand and spacing included');
      expect(json['pick_up_date_time'], '2026-07-25 09:30:00');
      expect(json['no_of_person'], 3);
      expect(json['pickup_location'], 'Head Office, Tejgaon');
    });

    test('omits blank remarks rather than sending an empty string', () {
      expect(RequisitionMapper.toWriteJson(request).containsKey('remarks'), isFalse);
    });

    test('emits the logistics body the server validates', () {
      final logistics = NewRequisitionRequest.logistics(
        pickupDateTime: DateTime.utc(2026, 7, 25, 3, 30),
        pickupLocation: 'Test',
        dropLocation: 'Test',
        vehicleType: VehicleType.coverVan,
        customerName: 'Test',
        userDepartment: 'Test',
        loadingCapacity: LoadingCapacity.ton5,
        goodsWeight: 'Test',
        storeName: 'Test',
        goodsDetails: 'Test',
      );

      final json = RequisitionMapper.toWriteJson(logistics);

      expect(json['req_type'], 'logistic_support');
      expect(json['loading_capacity'], '5 Ton');
      expect(json['user_department'], 'Test');
      expect(json['store_name'], 'Test');
      expect(json['goods_details'], 'Test');
      expect(json['pick_up_date_time'], '2026-07-25 09:30:00');
      // requisition_for is required for logistics too, even though the form never asks.
      expect(json['requisition_for'], 'Own User');
      // The server neither requires nor validates vehicle_type; sending it is noise.
      expect(json.containsKey('vehicle_type'), isFalse);
    });
  });

  group('PageInfo', () {
    test('reads the API Resource shape, where pagination nests under meta', () {
      final info = PageInfo.fromEnvelope({
        'data': <dynamic>[],
        'meta': {'current_page': 2, 'last_page': 3, 'total': 25},
      });

      expect(info.lastPage, 3);
      expect(info.hasMoreAfter(2, 10, 100), isTrue);
      expect(info.hasMoreAfter(3, 5, 100), isFalse);
    });

    test('reads the flat LengthAwarePaginator shape, where it sits at top level', () {
      // A bare ->paginate() has no meta wrapper. Missing this would cost one wasted
      // request at the end of every walk.
      final info = PageInfo.fromEnvelope({
        'data': <dynamic>[],
        'current_page': 1,
        'last_page': 2,
        'total': 15,
      });

      expect(info.lastPage, 2);
      expect(info.hasMoreAfter(1, 10, 100), isTrue);
      expect(info.hasMoreAfter(2, 5, 100), isFalse);
    });

    test('with no pagination at all, a short page ends the walk', () {
      final info = PageInfo.fromEnvelope({'data': <dynamic>[]});

      expect(info.lastPage, isNull);
      expect(info.hasMoreAfter(1, 4, 100), isFalse);
    });
  });
}
