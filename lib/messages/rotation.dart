import 'request.dart';
import 'response.dart';

class RotateAuthenticationKeyRequest
    extends ClientRequest<Map<String, dynamic>> {
  RotateAuthenticationKeyRequest(super.request, super.nonce);

  static RotateAuthenticationKeyRequest parse(String message) {
    return ClientRequest.parse<Map<String, dynamic>>(
      message,
      (Map<String, dynamic> request, String nonce) =>
          RotateAuthenticationKeyRequest(request, nonce),
    ) as RotateAuthenticationKeyRequest;
  }
}

class RotateAuthenticationKeyResponse
    extends ServerResponse<Map<String, dynamic>> {
  RotateAuthenticationKeyResponse(
      super.response, super.serverIdentity, super.nonce);

  static RotateAuthenticationKeyResponse parse(String message) {
    return ServerResponse.parse<Map<String, dynamic>>(
      message,
      (Map<String, dynamic> response, String serverIdentity, String nonce) =>
          RotateAuthenticationKeyResponse(response, serverIdentity, nonce),
    ) as RotateAuthenticationKeyResponse;
  }
}
