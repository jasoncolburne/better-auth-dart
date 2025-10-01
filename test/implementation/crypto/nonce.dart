import 'dart:typed_data';
import 'package:better_auth_dart/interfaces/crypto.dart';
import '../encoding/base64.dart';
import 'entropy.dart';

class Noncer implements INoncer {
  @override
  Future<String> generate128() async {
    final entropy = await getEntropy(16);

    final padded = Uint8List.fromList([0, 0, ...entropy]);
    final base64 = Base64.encode(padded);

    return '0A${base64.substring(2)}';
  }
}
