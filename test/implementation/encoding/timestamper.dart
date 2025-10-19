import 'package:better_auth_dart/interfaces/encoding.dart';

class Rfc3339Nano implements ITimestamper {
  @override
  String format(DateTime when) {
    // Use standard RFC3339 format with millisecond precision (3 digits)
    final isoString = when.toUtc().toIso8601String();
    // Dart's toIso8601String() already uses millisecond precision by default
    return isoString;
  }

  @override
  DateTime parse(dynamic when) {
    if (when is DateTime) {
      return when;
    }
    return DateTime.parse(when as String);
  }

  @override
  DateTime now() {
    return DateTime.now();
  }
}
