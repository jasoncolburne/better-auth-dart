import 'request.dart';
import 'response.dart';

class ChangeRecoveryKeyRequest extends ClientRequest<Map<String, dynamic>> {
  ChangeRecoveryKeyRequest(super.request, super.nonce);

  static ChangeRecoveryKeyRequest parse(String message) {
    return ClientRequest.parse<Map<String, dynamic>>(
      message,
      (Map<String, dynamic> request, String nonce) =>
          ChangeRecoveryKeyRequest(request, nonce),
    ) as ChangeRecoveryKeyRequest;
  }
}

class ChangeRecoveryKeyResponse extends ServerResponse<Map<String, dynamic>> {
  ChangeRecoveryKeyResponse(super.response, super.serverIdentity, super.nonce);

  static ChangeRecoveryKeyResponse parse(String message) {
    return ServerResponse.parse<Map<String, dynamic>>(
      message,
      (Map<String, dynamic> response, String serverIdentity, String nonce) =>
          ChangeRecoveryKeyResponse(response, serverIdentity, nonce),
    ) as ChangeRecoveryKeyResponse;
  }
}
