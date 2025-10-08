import 'dart:convert';
import 'message.dart';
import 'request.dart';
import 'response.dart';

class LinkContainer extends SignableMessage {
  @override
  final Map<String, dynamic> payload;

  LinkContainer(this.payload);

  @override
  String composePayload() {
    return jsonEncode(payload);
  }

  Map<String, dynamic> toJson() {
    return {
      'payload': payload,
      'signature': signature,
    };
  }

  static LinkContainer parse(String message) {
    final json = jsonDecode(message);
    final result = LinkContainer(json['payload']);
    result.signature = json['signature'];
    return result;
  }
}

class LinkDeviceRequest extends ClientRequest<Map<String, dynamic>> {
  LinkDeviceRequest(super.request, super.nonce);

  static LinkDeviceRequest parse(String message) {
    return ClientRequest.parse<Map<String, dynamic>>(
      message,
      (Map<String, dynamic> request, String nonce) =>
          LinkDeviceRequest(request, nonce),
    ) as LinkDeviceRequest;
  }
}

class LinkDeviceResponse extends ServerResponse<Map<String, dynamic>> {
  LinkDeviceResponse(super.response, super.serverIdentity, super.nonce);

  static LinkDeviceResponse parse(String message) {
    return ServerResponse.parse<Map<String, dynamic>>(
      message,
      (Map<String, dynamic> response, String serverIdentity, String nonce) =>
          LinkDeviceResponse(response, serverIdentity, nonce),
    ) as LinkDeviceResponse;
  }
}

class UnlinkDeviceRequest extends ClientRequest<Map<String, dynamic>> {
  UnlinkDeviceRequest(super.request, super.nonce);

  static UnlinkDeviceRequest parse(String message) {
    return ClientRequest.parse<Map<String, dynamic>>(
      message,
      (Map<String, dynamic> request, String nonce) =>
          UnlinkDeviceRequest(request, nonce),
    ) as UnlinkDeviceRequest;
  }
}

class UnlinkDeviceResponse extends ServerResponse<Map<String, dynamic>> {
  UnlinkDeviceResponse(super.response, super.serverIdentity, super.nonce);

  static UnlinkDeviceResponse parse(String message) {
    return ServerResponse.parse<Map<String, dynamic>>(
      message,
      (Map<String, dynamic> response, String serverIdentity, String nonce) =>
          UnlinkDeviceResponse(response, serverIdentity, nonce),
    ) as UnlinkDeviceResponse;
  }
}
