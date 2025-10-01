import 'dart:convert';
import '../interfaces/encoding.dart';
import '../interfaces/storage.dart';
import '../interfaces/crypto.dart';
import 'message.dart';

class AccessToken<T> extends SignableMessage {
  final String identity;
  final String publicKey;
  final String rotationHash;
  final String issuedAt;
  final String expiry;
  final String refreshExpiry;
  final T attributes;

  AccessToken({
    required this.identity,
    required this.publicKey,
    required this.rotationHash,
    required this.issuedAt,
    required this.expiry,
    required this.refreshExpiry,
    required this.attributes,
  });

  static Future<AccessToken<T>> parse<T>(
    String message,
    int publicKeyLength,
    ITokenEncoder tokenEncoder,
  ) async {
    final signature = message.substring(0, publicKeyLength);
    final rest = message.substring(publicKeyLength);

    final tokenString = await tokenEncoder.decode(rest);
    final json = jsonDecode(tokenString);

    final token = AccessToken<T>(
      identity: json['identity'],
      publicKey: json['publicKey'],
      rotationHash: json['rotationHash'],
      issuedAt: json['issuedAt'],
      expiry: json['expiry'],
      refreshExpiry: json['refreshExpiry'],
      attributes: json['attributes'],
    );

    token.signature = signature;
    return token;
  }

  @override
  String composePayload() {
    return jsonEncode({
      'identity': identity,
      'publicKey': publicKey,
      'rotationHash': rotationHash,
      'issuedAt': issuedAt,
      'expiry': expiry,
      'refreshExpiry': refreshExpiry,
      'attributes': attributes,
    });
  }

  Future<String> serializeToken(ITokenEncoder tokenEncoder) async {
    if (signature == null) {
      throw Exception('missing signature');
    }
    final token = await tokenEncoder.encode(composePayload());
    return signature! + token;
  }

  Future<void> verifyToken(
    IVerifier verifier,
    String publicKey,
    ITimestamper timestamper,
  ) async {
    await verify(verifier, publicKey);

    final now = timestamper.now();
    final issuedAtTime = timestamper.parse(issuedAt);
    final expiryTime = timestamper.parse(expiry);

    if (now.isBefore(issuedAtTime)) {
      throw Exception('token from future');
    }

    if (now.isAfter(expiryTime)) {
      throw Exception('token expired');
    }
  }
}

class AccessRequest<T> extends SignableMessage {
  @override
  final Map<String, dynamic> payload;

  AccessRequest(this.payload);

  Future<List<dynamic>> internalVerify<A>(
    IServerTimeLockStore nonceStore,
    IVerifier verifier,
    IVerifier tokenVerifier,
    String serverAccessPublicKey,
    ITokenEncoder tokenEncoder,
    ITimestamper timestamper,
  ) async {
    final accessToken = await AccessToken.parse<A>(
      payload['access']['token'],
      tokenVerifier.signatureLength,
      tokenEncoder,
    );

    await accessToken.verifyToken(
        tokenVerifier, serverAccessPublicKey, timestamper);
    await verify(verifier, accessToken.publicKey);

    final now = timestamper.now();
    final accessTime = timestamper.parse(payload['access']['timestamp']);
    final expiry =
        DateTime.fromMillisecondsSinceEpoch(accessTime.millisecondsSinceEpoch);
    final expiryWithLifetime = expiry.add(
      Duration(seconds: nonceStore.lifetimeInSeconds),
    );

    if (now.isAfter(expiryWithLifetime)) {
      throw Exception('stale request');
    }

    if (now.isBefore(accessTime)) {
      throw Exception('request from future');
    }

    await nonceStore.reserve(payload['access']['nonce']);

    return [accessToken.identity, accessToken.attributes];
  }

  static AccessRequest<T> parse<T>(String message) {
    final json = jsonDecode(message);
    final result = AccessRequest<T>(json['payload']);
    result.signature = json['signature'];
    return result;
  }
}
