import 'dart:convert';
import 'dart:typed_data';

class Base64 {
  static String encode(Uint8List data) {
    String base64 = base64Encode(data);
    return base64.replaceAll('/', '_').replaceAll('+', '-');
  }

  static Uint8List decode(String base64Str) {
    final normalized = base64Str.replaceAll('_', '/').replaceAll('-', '+');
    return base64Decode(normalized);
  }
}
