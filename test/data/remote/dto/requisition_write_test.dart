import 'package:flutter_test/flutter_test.dart';
import 'package:tracgo/data/remote/dto/requisition_mapper.dart';
import 'package:tracgo/domain/model/requisition.dart';

NewRequisitionRequest passenger({
  List<String> employeeIds = const ['1036', '1404', '2872'],
  int numberOfPersons = 3,
  RequiredFor requiredFor = RequiredFor.ownUser,
}) =>
    NewRequisitionRequest.passenger(
      pickupDateTime: DateTime(2026, 8, 13, 16, 50),
      pickupLocation: 'Banani',
      dropLocation: 'Mirpur',
      usedType: UsedType.pickupAndDrop,
      customerName: 'Synthetic Customer',
      numberOfPersons: numberOfPersons,
      requiredFor: requiredFor,
      employeeIds: employeeIds,
      purpose: 'test',
    );

NewRequisitionRequest logistics({VehicleType vehicleType = VehicleType.openTruck}) =>
    NewRequisitionRequest.logistics(
      pickupDateTime: DateTime(2026, 7, 26, 8, 0),
      pickupLocation: 'Head Office, Tejgaon',
      dropLocation: 'Chittagong Depot',
      vehicleType: vehicleType,
      customerName: 'Synthetic Ltd.',
      userDepartment: 'Logistics',
      loadingCapacity: LoadingCapacity.ton1Point5,
      goodsWeight: '500 kg',
      storeName: 'Chittagong Store',
      goodsDetails: 'Spare parts',
    );

void main() {
  group('passenger employee_id', () {
    test('is sent as integers, because the server compares numerically', () {
      final body = RequisitionMapper.toWriteJson(passenger());

      expect(body['employee_id'], [1036, 1404, 2872]);
      expect(body['employee_id'], isA<List<int>>());
    });

    test('is sent for Own User too, not only Someone Else', () {
      // The contract's worked example is an Own User trip with three riders; the old
      // build sent none, which the count rule now rejects.
      final body = RequisitionMapper.toWriteJson(
        passenger(requiredFor: RequiredFor.ownUser),
      );

      expect(body['employee_id'], hasLength(3));
      expect(body['requisition_for'], 'Own User');
    });

    test('matches no_of_person, which is what the count rule checks', () {
      final body = RequisitionMapper.toWriteJson(passenger());

      expect((body['employee_id'] as List).length, body['no_of_person']);
    });

    test('drops a non-numeric id rather than coercing it to a wrong rider', () {
      final body = RequisitionMapper.toWriteJson(
        passenger(employeeIds: const ['1036', 'not-an-id', '2872']),
      );

      expect(body['employee_id'], [1036, 2872]);
    });

    test('an empty selection sends an empty list, not a missing key', () {
      final body = RequisitionMapper.toWriteJson(
        passenger(employeeIds: const [], numberOfPersons: 0),
      );

      expect(body.containsKey('employee_id'), isTrue);
      expect(body['employee_id'], isEmpty);
    });
  });

  group('logistics requisition_for', () {
    test('carries the vehicle type, not "Own User"', () {
      // Regression: this field used to send RequiredFor.ownUser.label, borrowed from
      // the passenger meaning. The updated contract 422s anything that is not a
      // vehicle type.
      expect(
        RequisitionMapper.toWriteJson(logistics(vehicleType: VehicleType.openTruck))[
            'requisition_for'],
        'Open Truck',
      );
      expect(
        RequisitionMapper.toWriteJson(logistics(vehicleType: VehicleType.coverVan))[
            'requisition_for'],
        'Cover Van',
      );
    });

    test('never sends Own User for a logistics requisition', () {
      final body = RequisitionMapper.toWriteJson(logistics());

      expect(body['requisition_for'], isNot('Own User'));
    });

    test('sends the bullet-operator loading capacity verbatim', () {
      final body = RequisitionMapper.toWriteJson(logistics());

      expect((body['loading_capacity'] as String).codeUnits[1], 0x2219);
    });

    test('carries no employee_id — riders are a passenger-only concept', () {
      expect(
        RequisitionMapper.toWriteJson(logistics()).containsKey('employee_id'),
        isFalse,
      );
    });
  });
}
