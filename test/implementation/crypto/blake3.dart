import 'dart:typed_data';
import 'package:thirds/blake3.dart';

class Blake3 {
  static Future<Uint8List> sum256(Uint8List bytes) async {
    // Note: Dart's crypto package doesn't have blake3, using sha256 as fallback
    // In production, you'd want to use a proper blake3 package
    final digest = blake3(bytes);
    return Uint8List.fromList(digest);
  }
}
