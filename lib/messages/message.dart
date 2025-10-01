import 'dart:convert';
import '../interfaces/crypto.dart';

abstract class SerializableMessage {
  Future<String> serialize();
}

abstract class SignableMessage extends SerializableMessage {
  covariant dynamic payload;
  String? signature;

  String composePayload() {
    if (payload == null) {
      throw Exception('payload not defined');
    }
    return jsonEncode(payload);
  }

  @override
  Future<String> serialize() async {
    if (signature == null) {
      throw Exception('null signature');
    }
    return '{"payload":${composePayload()},"signature":"$signature"}';
  }

  Future<void> sign(ISigningKey signer) async {
    signature = await signer.sign(composePayload());
  }

  Future<void> verify(IVerifier verifier, String publicKey) async {
    if (signature == null) {
      throw Exception('null signature');
    }
    await verifier.verify(composePayload(), signature!, publicKey);
  }
}
