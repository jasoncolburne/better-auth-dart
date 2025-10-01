import 'dart:convert';
import 'dart:typed_data';
import 'package:pointycastle/export.dart';
import 'package:better_auth_dart/interfaces/crypto.dart';
import '../encoding/base64.dart';

class Secp256r1Verifier implements IVerifier {
  @override
  int get signatureLength => 88;

  @override
  Future<void> verify(
      String message, String signature, String publicKey) async {
    final publicKeyBytes = Base64.decode(publicKey).sublist(3);
    final signatureBytes = Base64.decode(signature).sublist(2);
    final messageBytes = utf8.encode(message);

    // Decompress the public key
    final curve = ECCurve_prime256v1();
    final point = curve.curve.decodePoint(publicKeyBytes);
    if (point == null) {
      throw Exception('invalid public key');
    }

    final publicKeyParams =
        ECPublicKey(point, ECDomainParameters('prime256v1'));

    // Create ECSignature from raw signature bytes
    final r = BigInt.parse(
        signatureBytes
            .sublist(0, 32)
            .map((b) => b.toRadixString(16).padLeft(2, '0'))
            .join(),
        radix: 16);
    final s = BigInt.parse(
        signatureBytes
            .sublist(32, 64)
            .map((b) => b.toRadixString(16).padLeft(2, '0'))
            .join(),
        radix: 16);
    final ecSignature = ECSignature(r, s);

    final ecdsaSigner = ECDSASigner(SHA256Digest());
    ecdsaSigner.init(false, PublicKeyParameter<ECPublicKey>(publicKeyParams));

    if (!ecdsaSigner.verifySignature(
        Uint8List.fromList(messageBytes), ecSignature)) {
      throw Exception('invalid signature');
    }
  }
}

class Secp256r1 implements ISigningKey {
  AsymmetricKeyPair<ECPublicKey, ECPrivateKey>? _keyPair;
  final Secp256r1Verifier _verifier = Secp256r1Verifier();

  Future<void> generate() async {
    final keyGen = ECKeyGenerator();
    final secureRandom = FortunaRandom();

    final seedSource = Uint8List(32);
    for (int i = 0; i < 32; i++) {
      seedSource[i] = DateTime.now().millisecondsSinceEpoch % 256;
    }
    secureRandom.seed(KeyParameter(seedSource));

    final params = ECKeyGeneratorParameters(ECDomainParameters('prime256v1'));
    final parametersWithRandom = ParametersWithRandom(params, secureRandom);

    keyGen.init(parametersWithRandom);
    final pair = keyGen.generateKeyPair();
    _keyPair = AsymmetricKeyPair<ECPublicKey, ECPrivateKey>(
      pair.publicKey,
      pair.privateKey,
    );
  }

  @override
  Future<String> sign(String message) async {
    if (_keyPair == null) {
      throw Exception('keypair not generated');
    }

    final messageBytes = utf8.encode(message);

    final secureRandom = FortunaRandom();
    final seedSource = Uint8List(32);
    for (int i = 0; i < 32; i++) {
      seedSource[i] = DateTime.now().millisecondsSinceEpoch % 256;
    }
    secureRandom.seed(KeyParameter(seedSource));

    final signer = ECDSASigner(SHA256Digest());
    signer.init(
        true,
        ParametersWithRandom(
            PrivateKeyParameter(_keyPair!.privateKey), secureRandom));

    final signature = signer.generateSignature(Uint8List.fromList(messageBytes))
        as ECSignature;

    // Convert signature to bytes (r || s)
    final rBytes = _bigIntToBytes(signature.r, 32);
    final sBytes = _bigIntToBytes(signature.s, 32);
    final signatureBytes = Uint8List.fromList([...rBytes, ...sBytes]);

    final padded = Uint8List.fromList([0, 0, ...signatureBytes]);
    final base64 = Base64.encode(padded);

    return '0I${base64.substring(2)}';
  }

  @override
  Future<String> public() async {
    if (_keyPair == null) {
      throw Exception('keypair not generated');
    }

    final publicKey = _keyPair!.publicKey;
    final uncompressed = publicKey.Q!.getEncoded(false);
    final compressed = _compressPublicKey(uncompressed);

    final padded = Uint8List.fromList([0, 0, 0, ...compressed]);
    final base64 = Base64.encode(padded);

    return '1AAI${base64.substring(4)}';
  }

  @override
  IVerifier verifier() {
    return _verifier;
  }

  @override
  Future<void> verify(String message, String signature) async {
    await _verifier.verify(message, signature, await public());
  }

  Uint8List _compressPublicKey(Uint8List uncompressedKey) {
    if (uncompressedKey.length != 65) {
      throw Exception('invalid length');
    }

    if (uncompressedKey[0] != 0x04) {
      throw Exception('invalid byte header');
    }

    final x = uncompressedKey.sublist(1, 33);
    final y = uncompressedKey.sublist(33, 65);

    final yParity = y[31] & 1;
    final prefix = yParity == 0 ? 0x02 : 0x03;

    final compressedKey = Uint8List(33);
    compressedKey[0] = prefix;
    compressedKey.setRange(1, 33, x);

    return compressedKey;
  }

  Uint8List _bigIntToBytes(BigInt number, int length) {
    final bytes = Uint8List(length);
    var num = number;
    for (int i = length - 1; i >= 0; i--) {
      bytes[i] = (num & BigInt.from(0xff)).toInt();
      num = num >> 8;
    }
    return bytes;
  }
}
