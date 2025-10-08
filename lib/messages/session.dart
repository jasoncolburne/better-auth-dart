import 'dart:convert';
import 'message.dart';
import 'request.dart';
import 'response.dart';

class RequestSessionRequest extends SerializableMessage {
  final Map<String, dynamic> payload;

  RequestSessionRequest(this.payload);

  @override
  Future<String> serialize() async {
    return jsonEncode({
      'payload': payload,
    });
  }

  static RequestSessionRequest parse(String message) {
    final json = jsonDecode(message);
    return RequestSessionRequest(json['payload'] as Map<String, dynamic>);
  }
}

class RequestSessionResponse extends ServerResponse<Map<String, dynamic>> {
  RequestSessionResponse(super.response, super.serverIdentity, super.nonce);

  static RequestSessionResponse parse(String message) {
    return ServerResponse.parse<Map<String, dynamic>>(
      message,
      (Map<String, dynamic> response, String serverIdentity, String nonce) =>
          RequestSessionResponse(response, serverIdentity, nonce),
    ) as RequestSessionResponse;
  }
}

class CreateSessionRequest extends ClientRequest<Map<String, dynamic>> {
  CreateSessionRequest(super.request, super.nonce);

  static CreateSessionRequest parse(String message) {
    return ClientRequest.parse<Map<String, dynamic>>(
      message,
      (Map<String, dynamic> request, String nonce) =>
          CreateSessionRequest(request, nonce),
    ) as CreateSessionRequest;
  }
}

class CreateSessionResponse extends ServerResponse<Map<String, dynamic>> {
  CreateSessionResponse(super.response, super.serverIdentity, super.nonce);

  static CreateSessionResponse parse(String message) {
    return ServerResponse.parse<Map<String, dynamic>>(
      message,
      (Map<String, dynamic> response, String serverIdentity, String nonce) =>
          CreateSessionResponse(response, serverIdentity, nonce),
    ) as CreateSessionResponse;
  }
}

class RefreshSessionRequest extends ClientRequest<Map<String, dynamic>> {
  RefreshSessionRequest(super.request, super.nonce);

  static RefreshSessionRequest parse(String message) {
    return ClientRequest.parse<Map<String, dynamic>>(
      message,
      (Map<String, dynamic> request, String nonce) =>
          RefreshSessionRequest(request, nonce),
    ) as RefreshSessionRequest;
  }
}

class RefreshSessionResponse extends ServerResponse<Map<String, dynamic>> {
  RefreshSessionResponse(super.response, super.serverIdentity, super.nonce);

  static RefreshSessionResponse parse(String message) {
    return ServerResponse.parse<Map<String, dynamic>>(
      message,
      (Map<String, dynamic> response, String serverIdentity, String nonce) =>
          RefreshSessionResponse(response, serverIdentity, nonce),
    ) as RefreshSessionResponse;
  }
}
