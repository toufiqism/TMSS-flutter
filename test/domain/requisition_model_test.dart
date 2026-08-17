import 'package:flutter_test/flutter_test.dart';
import 'package:tracgo/domain/model/requisition.dart';

void main() {
  group('RequisitionStatus', () {
    test('keeps the server string verbatim, whatever it is', () {
      // The core contract: what the server said is what the UI shows. Nothing is
      // rewritten to a canonical spelling, and nothing is ever replaced by a placeholder.
      for (final raw in [
        // Every distinct value on a live GET /requisitions response.
        'Pending',
        'Rejected',
        'Vehicle Assigned',
        // Plus states this build has no knowledge of at all.
        'Trip Completed',
        'In Progress',
        'Teleported',
      ]) {
        final status = RequisitionStatus.fromWire(raw);
        expect(status.rawValue, raw, reason: 'failed for $raw');
        expect(status.hasValue, isTrue, reason: 'failed for $raw');
      }
    });

    test('interprets every status seen on a live list response', () {
      // `Vehicle Assigned` is the regression this group exists for: it used to fall
      // through to a hardcoded "Unknown" chip, because matching went through the display
      // label `Assigned`.
      expect(
        RequisitionStatus.fromWire('Pending').kind,
        RequisitionStatusKind.pending,
      );
      expect(
        RequisitionStatus.fromWire('Rejected').kind,
        RequisitionStatusKind.rejected,
      );
      expect(
        RequisitionStatus.fromWire('Vehicle Assigned').kind,
        RequisitionStatusKind.assigned,
      );
    });

    test('an unrecognised state shows its name and takes the neutral kind', () {
      final status = RequisitionStatus.fromWire('Trip Completed');
      expect(status.rawValue, 'Trip Completed');
      expect(status.kind, RequisitionStatusKind.unrecognised);
      expect(status.hasValue, isTrue, reason: 'there is a name to render');
    });

    test('the server sends the verb Cancel, not the adjective', () {
      for (final raw in ['Cancel', 'cancelled', 'Canceled', 'CANCELLATION']) {
        final status = RequisitionStatus.fromWire(raw);
        expect(status.kind, RequisitionStatusKind.cancelled, reason: 'failed for $raw');
        // Interpreted as cancelled, but still displayed as the server spelled it — the
        // canonical `Cancelled` never overwrites a real `Cancel`.
        expect(status.rawValue, raw, reason: 'failed for $raw');
      }
    });

    test('interpretation ignores case and separators', () {
      for (final raw in ['vehicle_assigned', 'VEHICLE-ASSIGNED', 'Vehicle/Assigned']) {
        expect(
          RequisitionStatus.fromWire(raw).kind,
          RequisitionStatusKind.assigned,
          reason: 'failed for $raw',
        );
      }
      expect(
        RequisitionStatus.fromWire('PENDING APPROVAL').kind,
        RequisitionStatusKind.pending,
      );
    });

    test('every canonical label parses back to its own kind', () {
      for (final kind in RequisitionStatusKind.values) {
        if (kind == RequisitionStatusKind.unrecognised) continue;
        expect(
          RequisitionStatus.fromWire(kind.canonicalLabel).kind,
          kind,
          reason: 'failed for ${kind.canonicalLabel}',
        );
      }
    });

    test('the client-originated constants agree with the parser', () {
      for (final status in [
        RequisitionStatus.pending,
        RequisitionStatus.approved,
        RequisitionStatus.assigned,
        RequisitionStatus.rejected,
        RequisitionStatus.cancelled,
      ]) {
        expect(
          RequisitionStatus.fromWire(status.rawValue),
          status,
          reason: 'failed for ${status.rawValue}',
        );
      }
    });

    test('a compound value resolves to the more terminal kind', () {
      // `canBeModified` is true only for pending, so an ambiguous value must not resolve
      // there and offer an edit the server will refuse.
      expect(
        RequisitionStatus.fromWire('Cancellation Pending').kind,
        RequisitionStatusKind.cancelled,
      );
      expect(
        RequisitionStatus.fromWire('Approved & Vehicle Assigned').kind,
        RequisitionStatusKind.assigned,
      );
    });

    test('a negated status word is never interpreted as its own opposite', () {
      for (final raw in ['Unassigned', 'Not Approved', 'un-approved', 'Not Confirmed']) {
        final status = RequisitionStatus.fromWire(raw);
        expect(
          status.kind,
          RequisitionStatusKind.unrecognised,
          reason: 'failed for $raw',
        );
        // Neutral colour, but the user still reads the real word.
        expect(status.rawValue, raw, reason: 'failed for $raw');
      }
    });

    test('only a genuinely absent status has nothing to show', () {
      for (final raw in [null, '', '   ', '\n\t']) {
        final status = RequisitionStatus.fromWire(raw);
        expect(status, RequisitionStatus.absent, reason: 'failed for ${raw?.trim()}');
        expect(status.hasValue, isFalse, reason: 'failed for ${raw?.trim()}');
        expect(status.rawValue, isEmpty);
      }
    });

    test('surrounding whitespace is trimmed off the display string', () {
      final status = RequisitionStatus.fromWire('  Vehicle Assigned  ');
      expect(status.rawValue, 'Vehicle Assigned');
      expect(status.kind, RequisitionStatusKind.assigned);
    });

    test('only pending is modifiable, whatever the spelling', () {
      Requisition at(RequisitionStatus status) => Requisition(
        id: '1',
        pickupDateTime: DateTime(2026, 8, 10, 11),
        pickupLocation: 'Bangla Trac, Banani',
        dropLocation: 'BTRC',
        status: status,
        createdAt: DateTime(2026, 8, 10, 4, 35),
        details: const RequisitionDetails.passenger(
          usedType: UsedType.pickup,
          customerName: 'BTRC',
          numberOfPersons: 2,
          requiredFor: RequiredFor.ownUser,
          purpose: 'Business Meeting',
        ),
      );

      // Wire values, not constants: `canBeModified` compares kind, so a live `Pending`
      // must be modifiable even though it is not equal to the canonical constant.
      expect(at(RequisitionStatus.fromWire('Pending')).canBeModified, isTrue);
      expect(at(RequisitionStatus.fromWire('pending approval')).canBeModified, isTrue);
      for (final raw in [
        'Approved',
        'Vehicle Assigned',
        'Rejected',
        'Cancel',
        'Trip Completed',
        'Unassigned',
      ]) {
        expect(
          at(RequisitionStatus.fromWire(raw)).canBeModified,
          isFalse,
          reason: 'failed for $raw',
        );
      }
      expect(at(RequisitionStatus.absent).canBeModified, isFalse);
    });

    test('lifecycle sort order is preserved', () {
      // RequisitionSortField.status sorts on kind.index, so declaration order is
      // behaviour, and unrecognised must stay last.
      expect(RequisitionStatusKind.values.map((k) => k.name), [
        'pending',
        'approved',
        'assigned',
        'rejected',
        'cancelled',
        'unrecognised',
      ]);
    });
  });

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
