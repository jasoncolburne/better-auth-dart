abstract class ITimestamper {
  String format(DateTime when);
  DateTime parse(dynamic when);
  DateTime now();
}

abstract class ITokenEncoder {
  Future<String> encode(String object);
  Future<String> decode(String rawToken);
}

abstract class IIdentityVerifier {
  Future<void> verify(
    String identity,
    String publicKey,
    String rotationHash, [
    String? extraData,
  ]);
}
