/// Conversion for the contract's `LocalDateTime`: `YYYY-MM-DD HH:mm:ss`, space
/// separator, **no timezone offset**.
///
/// The contract raised that missing offset as an open question and guessed Asia/Dhaka;
/// the project owner has since confirmed the server does read and write Dhaka
/// wall-clock. It stays pinned here rather than inferred from the device, because the
/// contract's warning still holds: "a one-hour drift misdispatches a driver".
///
/// On a phone set to Dhaka (all current users) this is a no-op; on a phone set to
/// anything else it is the difference between showing the driver's actual pickup time
/// and showing the user's own local time by accident.
///
/// Dhaka has not observed daylight saving since a brief 2009–2010 experiment, so a
/// fixed offset is correct today. If that changes this needs the `timezone` package
/// and a real tz database — a fixed offset cannot express a DST rule.
class WireDateTime {
  WireDateTime._();

  static const dhakaOffset = Duration(hours: 6);

  /// Matches the documented `YYYY-MM-DD HH:mm:ss`, a bare `YYYY-MM-DD` (the shape the
  /// list's `fdate`/`tdate` use, which a server may echo back), and either of those
  /// carrying an explicit `Z` or `±HH:MM` offset.
  ///
  /// Parsing is done by hand rather than via `DateTime.tryParse`, which is wrong for
  /// this input in both directions: it rejects `2026-07-25Z` outright, and it silently
  /// *rolls over* nonsense like `2026-13-45` into a real date in the following year
  /// instead of reporting it.
  static final _pattern = RegExp(
    r'^(\d{4})-(\d{2})-(\d{2})'
    r'(?:[ T](\d{2}):(\d{2})(?::(\d{2}))?)?'
    r'(Z|[+-]\d{2}:?\d{2})?$',
  );

  /// Parses server wall-clock into an absolute instant, returned in device-local time
  /// so the existing UI formatters keep working unchanged.
  ///
  /// Returns null for anything unparseable rather than throwing — a malformed date on
  /// one row should not blank the whole list.
  static DateTime? parse(String? raw) => _parse(raw, dhakaOffset);

  /// Parses a server timestamp that is already UTC.
  ///
  /// Needed because this API mixes zones within one payload: `start_time` round-trips
  /// as Dhaka wall-clock, but `created_at` is UTC. Verified live — a row created at
  /// 00:34 Dhaka came back as `created_at: 2026-08-13 18:34:51`. Running `created_at`
  /// through [parse] would place it six hours early.
  static DateTime? parseUtc(String? raw) => _parse(raw, Duration.zero);

  /// [defaultOffset] is the zone an offset-less string is assumed to be in. A string
  /// that carries its own `Z` or `±HH:MM` ignores it and uses what it was given.
  static DateTime? _parse(String? raw, Duration defaultOffset) {
    if (raw == null) return null;
    final match = _pattern.firstMatch(raw.trim());
    if (match == null) return null;

    final year = int.parse(match.group(1)!);
    final month = int.parse(match.group(2)!);
    final day = int.parse(match.group(3)!);
    final hour = int.tryParse(match.group(4) ?? '') ?? 0;
    final minute = int.tryParse(match.group(5) ?? '') ?? 0;
    final second = int.tryParse(match.group(6) ?? '') ?? 0;

    if (month < 1 || month > 12) return null;
    if (day < 1 || day > 31) return null;
    if (hour > 23 || minute > 59 || second > 59) return null;

    final wallClock = DateTime.utc(year, month, day, hour, minute, second);
    // Rejects dates that exist syntactically but not on a calendar (31 February), which
    // DateTime.utc would otherwise normalise into the following month.
    if (wallClock.month != month || wallClock.day != day) return null;

    final offsetText = match.group(7);
    // An explicit offset always wins over the caller's assumption.
    final offset = offsetText == null ? defaultOffset : _parseOffset(offsetText);
    return wallClock.subtract(offset).toLocal();
  }

  static Duration _parseOffset(String text) {
    if (text == 'Z') return Duration.zero;
    final sign = text.startsWith('-') ? -1 : 1;
    final digits = text.substring(1).replaceAll(':', '');
    final hours = int.tryParse(digits.substring(0, 2)) ?? 0;
    final minutes = int.tryParse(digits.substring(2)) ?? 0;
    return Duration(hours: sign * hours, minutes: sign * minutes);
  }

  /// Formats an instant back into Dhaka wall-clock for the request body.
  static String format(DateTime value) {
    final dhaka = value.toUtc().add(dhakaOffset);
    final y = dhaka.year.toString().padLeft(4, '0');
    final mo = dhaka.month.toString().padLeft(2, '0');
    final d = dhaka.day.toString().padLeft(2, '0');
    final h = dhaka.hour.toString().padLeft(2, '0');
    final mi = dhaka.minute.toString().padLeft(2, '0');
    final s = dhaka.second.toString().padLeft(2, '0');
    return '$y-$mo-$d $h:$mi:$s';
  }

  /// Formats the bare `date` used by the list's `fdate`/`tdate` query parameters. The
  /// contract is explicit that these are *not* interchangeable with the date-time
  /// format above.
  static String formatDate(DateTime value) {
    final dhaka = value.toUtc().add(dhakaOffset);
    final y = dhaka.year.toString().padLeft(4, '0');
    final mo = dhaka.month.toString().padLeft(2, '0');
    final d = dhaka.day.toString().padLeft(2, '0');
    return '$y-$mo-$d';
  }
}
