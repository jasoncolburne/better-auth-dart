import 'dart:convert';
import 'dart:typed_data';
import 'package:better_auth_dart/interfaces/crypto.dart';
import 'blake3.dart';
import '../encoding/base64.dart';

class Hasher implements IHasher {
  @override
  Future<String> sum(String message) async {
    final bytes = utf8.encode(message);
    final hash = await Blake3.sum256(Uint8List.fromList(bytes));
    final padded = Uint8List.fromList([0, ...hash]);
    final base64 = Base64.encode(padded);

    return 'E${base64.substring(1)}';
  }
}
