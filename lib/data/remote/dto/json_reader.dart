/// Tolerant accessors for decoded JSON.
///
/// Almost every response schema in the contract is marked `x-status: inferred` or
/// `additionalProperties: true`, and `RequisitionId` is explicitly documented as
/// "could be an integer or a string". Generated strict parsers would throw on the
/// first response that disagrees with a guess, taking a screen down over a field the
/// UI may not even display — so parsing is hand-written and every read is total:
/// a wrong-typed or absent value yields null, never an exception.
extension JsonReader on Map<String, dynamic> {
  /// First non-null value among [keys]. The contract does not pin field names for the
  /// user object at all ("field set entirely unknown"), so readers try the plausible
  /// spellings rather than betting on one.
  Object? firstOf(List<String> keys) {
    for (final key in keys) {
      final value = this[key];
      if (value != null) return value;
    }
    return null;
  }

  /// Reads a string, coercing numbers and bools. Blank strings read as null so that
  /// `""` from the server and "absent" collapse to the same case.
  String? stringOrNull(String key) => _asString(this[key]);

  String? stringFrom(List<String> keys) => _asString(firstOf(keys));

  /// Reads an id that the contract allows to arrive as either an integer or a string,
  /// and normalises it to the String the domain model uses. Numbers are stringified
  /// rather than parsed, so an id that later becomes a UUID keeps working.
  String? idOrNull(String key) {
    final value = this[key];
    if (value == null) return null;
    if (value is String) return value.trim().isEmpty ? null : value.trim();
    if (value is num) return value.toString();
    return null;
  }

  int? intOrNull(String key) {
    final value = this[key];
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value.trim());
    return null;
  }

  Map<String, dynamic>? mapOrNull(String key) {
    final value = this[key];
    return value is Map<String, dynamic> ? value : null;
  }

  /// Returns only the well-formed object entries, skipping malformed ones rather than
  /// failing the whole page — one bad row should not blank the list.
  List<Map<String, dynamic>> objectListOrEmpty(String key) {
    final value = this[key];
    if (value is! List) return const [];
    return value.whereType<Map<String, dynamic>>().toList();
  }
}

String? _asString(Object? value) {
  if (value == null) return null;
  if (value is String) return value.trim().isEmpty ? null : value.trim();
  if (value is num || value is bool) return value.toString();
  return null;
}
