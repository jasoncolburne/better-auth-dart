import 'request.dart';
import 'response.dart';

class RecoverAccountRequest extends ClientRequest<Map<String, dynamic>> {
  RecoverAccountRequest(super.request, super.nonce);

  static RecoverAccountRequest parse(String message) {
    return ClientRequest.parse<Map<String, dynamic>>(
      message,
      (Map<String, dynamic> request, String nonce) =>
          RecoverAccountRequest(request, nonce),
    ) as RecoverAccountRequest;
  }
}

class RecoverAccountResponse extends ServerResponse<Map<String, dynamic>> {
  RecoverAccountResponse(super.response, super.publicKeyHash, super.nonce);

  static RecoverAccountResponse parse(String message) {
    return ServerResponse.parse<Map<String, dynamic>>(
      message,
      (Map<String, dynamic> response, String publicKeyHash, String nonce) =>
          RecoverAccountResponse(response, publicKeyHash, nonce),
    ) as RecoverAccountResponse;
  }
}
