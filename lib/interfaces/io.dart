abstract class INetwork {
  // returns the network response
  Future<String> sendRequest(String path, String message);
}
