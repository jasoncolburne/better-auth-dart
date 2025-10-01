import 'package:better_auth_dart/interfaces/interfaces.dart';
import '../crypto/hash.dart';
import '../crypto/secp256r1.dart';

class ClientRotatingKeyStore implements IClientRotatingKeyStore {
  ISigningKey? _current;
  ISigningKey? _next;
  final IHasher _hasher = Hasher();

  @override
  Future<List<String>> initialize([String? extraData]) async {
    final current = Secp256r1();
    final next = Secp256r1();

    await current.generate();
    await next.generate();

    _current = current;
    _next = next;

    String suffix = '';
    if (extraData != null) {
      suffix = extraData;
    }

    final publicKey = await current.public();
    final rotationHash = await _hasher.sum(await next.public());
    final identity = await _hasher.sum(publicKey + rotationHash + suffix);

    return [identity, publicKey, rotationHash];
  }

  @override
  Future<List<String>> rotate() async {
    if (_next == null) {
      throw Exception('call initialize() first');
    }

    final next = Secp256r1();
    await next.generate();

    _current = _next;
    _next = next;

    final rotationHash = await _hasher.sum(await next.public());

    return [await _current!.public(), rotationHash];
  }

  @override
  Future<ISigningKey> signer() async {
    if (_current == null) {
      throw Exception('call initialize() first');
    }

    return _current!;
  }
}

class ClientValueStore implements IClientValueStore {
  String? _value;

  @override
  Future<void> store(String value) async {
    _value = value;
  }

  @override
  Future<String> get() async {
    if (_value == null) {
      throw Exception('nothing to get');
    }

    return _value!;
  }
}
