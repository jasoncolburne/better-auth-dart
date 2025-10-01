import 'request.dart';
import 'response.dart';

class RefreshAccessTokenRequest extends ClientRequest<Map<String, dynamic>> {
  RefreshAccessTokenRequest(super.request, super.nonce);

  static RefreshAccessTokenRequest parse(String message) {
    return ClientRequest.parse<Map<String, dynamic>>(
      message,
      (Map<String, dynamic> request, String nonce) =>
          RefreshAccessTokenRequest(request, nonce),
    ) as RefreshAccessTokenRequest;
  }
}

class RefreshAccessTokenResponse extends ServerResponse<Map<String, dynamic>> {
  RefreshAccessTokenResponse(super.response, super.publicKeyHash, super.nonce);

  static RefreshAccessTokenResponse parse(String message) {
    return ServerResponse.parse<Map<String, dynamic>>(
      message,
      (Map<String, dynamic> response, String publicKeyHash, String nonce) =>
          RefreshAccessTokenResponse(response, publicKeyHash, nonce),
    ) as RefreshAccessTokenResponse;
  }
}
