import 'package:flutter_test/flutter_test.dart';
import 'package:tmss/data/remote/dto/wire_date_time.dart';

void main() {
  group('parse', () {
    test('reads server wall-clock as Asia/Dhaka, not as device-local time', () {
      // The contract gives no offset and reasons it is Dhaka wall-clock. 09:30 in
      // Dhaka is 03:30 UTC; if this were read as device-local the instant would shift
      // by the device's own offset, which the contract warns "misdispatches a driver".
      final parsed = WireDateTime.parse('2026-07-25 09:30:00');

      expect(parsed, isNotNull);
      expect(parsed!.toUtc(), DateTime.utc(2026, 7, 25, 3, 30));
    });

    test('honours a real offset when the server sends one', () {
      final parsed = WireDateTime.parse('2026-07-25T09:30:00+00:00');

      expect(parsed!.toUtc(), DateTime.utc(2026, 7, 25, 9, 30));
    });

    test('reads a bare date, which the list filter parameters use', () {
      final parsed = WireDateTime.parse('2026-07-25');

      expect(parsed!.toUtc(), DateTime.utc(2026, 7, 24, 18));
    });

    test('returns null rather than throwing on junk, so one bad row cannot blank a list', () {
      expect(WireDateTime.parse(null), isNull);
      expect(WireDateTime.parse(''), isNull);
      expect(WireDateTime.parse('   '), isNull);
      expect(WireDateTime.parse('not a date'), isNull);
      expect(WireDateTime.parse('2026-13-45 99:99:99'), isNull);
    });
  });

  group('format', () {
    test('writes Dhaka wall-clock in the documented shape', () {
      final formatted = WireDateTime.format(DateTime.utc(2026, 7, 25, 3, 30, 5));

      expect(formatted, '2026-07-25 09:30:05');
    });

    test('round-trips through parse', () {
      const wire = '2026-02-09 17:05:00';

      expect(WireDateTime.format(WireDateTime.parse(wire)!), wire);
    });

    test('formatDate emits a bare date, which is not interchangeable with the date-time', () {
      expect(WireDateTime.formatDate(DateTime.utc(2026, 7, 24, 20)), '2026-07-25');
    });
  });
}
