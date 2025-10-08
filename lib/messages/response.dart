import 'dart:convert';
import 'message.dart';

class ServerResponse<T> extends SignableMessage {
  @override
  late final Map<String, dynamic> payload;

  ServerResponse(T response, String serverIdentity, String nonce) {
    payload = {
      'access': {
        'nonce': nonce,
        'serverIdentity': serverIdentity,
      },
      'response': response,
    };
  }

  static ServerResponse<T> parse<T>(
    String message,
    ServerResponse<T> Function(T response, String serverIdentity, String nonce)
        constructor,
  ) {
    final json = jsonDecode(message) as Map<String, dynamic>;
    final payload = json['payload'] as Map<String, dynamic>;
    final access = payload['access'] as Map<String, dynamic>;
    final result = constructor(
      payload['response'] as T,
      access['serverIdentity'] as String,
      access['nonce'] as String,
    );
    result.signature = json['signature'] as String?;
    return result;
  }
}

class ScannableResponse extends ServerResponse<Map<String, dynamic>> {
  ScannableResponse(super.response, super.serverIdentity, super.nonce);

  static ScannableResponse parse(String message) {
    return ServerResponse.parse<Map<String, dynamic>>(
      message,
      (Map<String, dynamic> response, String serverIdentity, String nonce) =>
          ScannableResponse(response, serverIdentity, nonce),
    ) as ScannableResponse;
  }
}
