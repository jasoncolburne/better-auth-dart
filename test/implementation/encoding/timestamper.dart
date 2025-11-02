import 'package:better_auth_dart/interfaces/encoding.dart';

class Rfc3339 implements ITimestamper {
  @override
  String format(DateTime when) {
    // Use standard RFC3339 format with millisecond precision (3 digits)
    final isoString = when.toUtc().toIso8601String();
    // Dart's toIso8601String() produces microsecond precision (6 digits)
    // Truncate to milliseconds (3 digits) using regex
    return isoString.replaceFirstMapped(
      RegExp(r'\.(\d{3})\d+Z$'),
      (match) => '.${match.group(1)}Z',
    );
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
