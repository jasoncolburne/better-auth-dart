import 'package:better_auth_dart/interfaces/encoding.dart';

class Rfc3339Nano implements ITimestamper {
  @override
  String format(DateTime when) {
    final isoString = when.toUtc().toIso8601String();
    return isoString.replaceAll('Z', '000000Z');
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
