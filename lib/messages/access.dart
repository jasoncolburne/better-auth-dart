import 'package:better_auth_dart/messages/message.dart';

class AccessRequest<T> extends SignableMessage {
  AccessRequest(T request, String nonce, String timestamp, String token) {
    super.payload = {
      'access': {
        'nonce': nonce,
        'timestamp': timestamp,
        'token': token,
      },
      "request": request,
    };
  }
}
