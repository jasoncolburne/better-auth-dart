import 'dart:convert';
import 'message.dart';

class ClientRequest<T> extends SignableMessage {
  @override
  late final Map<String, dynamic> payload;

  ClientRequest(T request, String nonce) {
    payload = {
      'access': {
        'nonce': nonce,
      },
      'request': request,
    };
  }

  static ClientRequest<T> parse<T>(
    String message,
    ClientRequest<T> Function(T request, String nonce) constructor,
  ) {
    final json = jsonDecode(message) as Map<String, dynamic>;
    final payload = json['payload'] as Map<String, dynamic>;
    final result = constructor(
      payload['request'] as T,
      (payload['access'] as Map<String, dynamic>)['nonce'] as String,
    );
    result.signature = json['signature'] as String?;
    return result;
  }
}
