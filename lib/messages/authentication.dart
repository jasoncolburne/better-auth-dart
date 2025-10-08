import 'dart:convert';
import 'message.dart';
import 'request.dart';
import 'response.dart';

class StartAuthenticationRequest extends SerializableMessage {
  final Map<String, dynamic> payload;

  StartAuthenticationRequest(this.payload);

  @override
  Future<String> serialize() async {
    return jsonEncode({
      'payload': payload,
    });
  }

  static StartAuthenticationRequest parse(String message) {
    final json = jsonDecode(message);
    return StartAuthenticationRequest(json['payload'] as Map<String, dynamic>);
  }
}

class StartAuthenticationResponse extends ServerResponse<Map<String, dynamic>> {
  StartAuthenticationResponse(
      super.response, super.serverIdentity, super.nonce);

  static StartAuthenticationResponse parse(String message) {
    return ServerResponse.parse<Map<String, dynamic>>(
      message,
      (Map<String, dynamic> response, String serverIdentity, String nonce) =>
          StartAuthenticationResponse(response, serverIdentity, nonce),
    ) as StartAuthenticationResponse;
  }
}

class FinishAuthenticationRequest extends ClientRequest<Map<String, dynamic>> {
  FinishAuthenticationRequest(super.request, super.nonce);

  static FinishAuthenticationRequest parse(String message) {
    return ClientRequest.parse<Map<String, dynamic>>(
      message,
      (Map<String, dynamic> request, String nonce) =>
          FinishAuthenticationRequest(request, nonce),
    ) as FinishAuthenticationRequest;
  }
}

class FinishAuthenticationResponse
    extends ServerResponse<Map<String, dynamic>> {
  FinishAuthenticationResponse(
      super.response, super.serverIdentity, super.nonce);

  static FinishAuthenticationResponse parse(String message) {
    return ServerResponse.parse<Map<String, dynamic>>(
      message,
      (Map<String, dynamic> response, String serverIdentity, String nonce) =>
          FinishAuthenticationResponse(response, serverIdentity, nonce),
    ) as FinishAuthenticationResponse;
  }
}
