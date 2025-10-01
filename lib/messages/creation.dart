import 'request.dart';
import 'response.dart';

class CreationRequest extends ClientRequest<Map<String, dynamic>> {
  CreationRequest(super.request, super.nonce);

  static CreationRequest parse(String message) {
    return ClientRequest.parse<Map<String, dynamic>>(
      message,
      (Map<String, dynamic> request, String nonce) =>
          CreationRequest(request, nonce),
    ) as CreationRequest;
  }
}

class CreationResponse extends ServerResponse<Map<String, dynamic>> {
  CreationResponse(super.response, super.publicKeyHash, super.nonce);

  static CreationResponse parse(String message) {
    return ServerResponse.parse<Map<String, dynamic>>(
      message,
      (Map<String, dynamic> response, String publicKeyHash, String nonce) =>
          CreationResponse(response, publicKeyHash, nonce),
    ) as CreationResponse;
  }
}
