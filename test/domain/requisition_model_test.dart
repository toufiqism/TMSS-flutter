import 'package:flutter_test/flutter_test.dart';
import 'package:tracgo/domain/model/requisition.dart';

void main() {
  group('LoadingCapacity', () {
    test('loading_capacity 1.5 Ton keeps its U+2219', () {
      // Asserted against the raw code unit, not against the constant itself. Comparing
      // `ton1Point5.label` to a pasted literal would pass even if an editor normalised
      // BOTH to '.', which is exactly the failure this guards.
      final label = LoadingCapacity.ton1Point5.label;
      expect(label.codeUnits, [0x31, 0x2219, 0x35, 0x20, 0x54, 0x6f, 0x6e]);
      expect(label.contains('.'), isFalse, reason: 'a full stop here is a 422');
    });

    test('reads back the separator the server sends, whichever it is', () {
      for (final raw in ['1∙5 Ton', '1.5 Ton', '1·5 Ton', '1∙5ton']) {
        expect(
          LoadingCapacity.fromWire(raw),
          LoadingCapacity.ton1Point5,
          reason: 'failed for $raw',
        );
      }
    });

    test('an unknown or absent capacity falls back rather than throwing', () {
      expect(LoadingCapacity.fromWire(null), LoadingCapacity.ton2);
      expect(LoadingCapacity.fromWire('9 Ton'), LoadingCapacity.ton2);
    });

    test('the other capacities still round-trip', () {
      for (final capacity in LoadingCapacity.values) {
        expect(LoadingCapacity.fromWire(capacity.label), capacity);
      }
    });
  });

  group('VehicleType', () {
    test('parses the values logistics sends in requisition_for', () {
      expect(VehicleType.fromWire('Cover Van'), VehicleType.coverVan);
      expect(VehicleType.fromWire('Open Truck'), VehicleType.openTruck);
      expect(VehicleType.fromWire('open truck'), VehicleType.openTruck);
    });

    test('falls back to Cover Van when the field is absent or unrecognised', () {
      expect(VehicleType.fromWire(null), VehicleType.coverVan);
      expect(VehicleType.fromWire('Flatbed'), VehicleType.coverVan);
    });
  });
}
