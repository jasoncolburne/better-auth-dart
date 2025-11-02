import 'dart:convert';

import '../error.dart';
import '../interfaces/crypto.dart';

abstract class SerializableMessage {
  Future<String> serialize();
}

abstract class SignableMessage extends SerializableMessage {
  covariant dynamic payload;
  String? signature;

  String composePayload() {
    if (payload == null) {
      throw InvalidMessageError(
          field: 'payload', details: 'payload not defined');
    }
    return jsonEncode(payload);
  }

  @override
  Future<String> serialize() async {
    if (signature == null) {
      throw InvalidMessageError(
          field: 'signature', details: 'signature is null');
    }
    return '{"payload":${composePayload()},"signature":"$signature"}';
  }

  Future<void> sign(ISigningKey signer) async {
    signature = await signer.sign(composePayload());
  }

  Future<void> verify(IVerifier verifier, String publicKey) async {
    if (signature == null) {
      throw InvalidMessageError(
          field: 'signature', details: 'signature is null');
    }
    await verifier.verify(composePayload(), signature!, publicKey);
  }
}
