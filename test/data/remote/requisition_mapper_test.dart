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
