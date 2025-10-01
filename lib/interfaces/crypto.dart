abstract class IHasher {
  Future<String> sum(String message);
}

abstract class INoncer {
  // 128 bits of entropy
  Future<String> generate128();
}

abstract class IVerifier {
  int get signatureLength;

  // this is typically just a verification algorithm
  //
  // throw exceptions when verification fails
  Future<void> verify(String message, String signature, String publicKey);
}

abstract class IVerificationKey {
  // fetches the public key
  Future<String> public();

  // returns the algorithm verifier
  IVerifier verifier();

  // verifies using the verifier and public key, this is a convenience method
  //
  // throw exceptions when verification fails
  Future<void> verify(String message, String signature);
}

abstract class ISigningKey implements IVerificationKey {
  // signs with the key it represents (could be backed by an HSM for instance)
  Future<String> sign(String message);
}
