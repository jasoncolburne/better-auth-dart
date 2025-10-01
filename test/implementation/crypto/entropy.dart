import 'dart:math';
import 'dart:typed_data';

Future<Uint8List> getEntropy(int length) async {
  final random = Random.secure();
  final bytes = Uint8List(length);
  for (int i = 0; i < length; i++) {
    bytes[i] = random.nextInt(256);
  }
  return bytes;
}
