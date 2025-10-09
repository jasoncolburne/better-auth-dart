import 'package:better_auth_dart/interfaces/interfaces.dart';
import '../crypto/hash.dart';
import '../crypto/secp256r1.dart';

class ClientRotatingKeyStore implements IClientRotatingKeyStore {
  ISigningKey? _currentKey;
  ISigningKey? _nextKey;
  ISigningKey? _futureKey;
  final IHasher _hasher = Hasher();

  @override
  Future<List<String>> initialize([String? extraData]) async {
    final current = Secp256r1();
    final next = Secp256r1();

    await current.generate();
    await next.generate();

    _currentKey = current;
    _nextKey = next;

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
  Future<List<dynamic>> next() async {
    if (_nextKey == null) {
      throw Exception('call initialize() first');
    }

    if (_futureKey == null) {
      final key = Secp256r1();
      await key.generate();
      _futureKey = key;
    }

    final rotationHash = await _hasher.sum(await _futureKey!.public());

    return [_nextKey!, rotationHash];
  }

  @override
  Future<void> rotate() async {
    if (_nextKey == null) {
      throw Exception('call initialize() first');
    }

    if (_futureKey == null) {
      throw Exception('call next() first');
    }

    _currentKey = _nextKey;
    _nextKey = _futureKey;
    _futureKey = null;
  }

  @override
  Future<ISigningKey> signer() async {
    if (_currentKey == null) {
      throw Exception('call initialize() first');
    }

    return _currentKey!;
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

class VerificationKeyStore implements IVerificationKeyStore {
  final Map<String, IVerificationKey> _keys = {};

  void add(String identity, IVerificationKey key) {
    _keys[identity] = key;
  }

  @override
  Future<IVerificationKey> get(String identity) async {
    if (!_keys.containsKey(identity)) {
      throw Exception('key not found for identity: $identity');
    }
    return _keys[identity]!;
  }
}
