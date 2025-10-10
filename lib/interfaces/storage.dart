import 'crypto.dart';

// client

abstract class IClientValueStore {
  Future<void> store(String value);

  // throw an exception if:
  // - nothing has been stored
  Future<String> get();
}

abstract class IClientRotatingKeyStore {
  // returns: [identity, publicKey, rotationHash]
  Future<(String, String, String)> initialize([String? extraData]);

  // returns: [key, rotationHash]
  //
  // this should return the _next_ signing key and a hash of the subsequent key
  // if no subsequent key exists yet, it should first be generated
  //
  // this facilitates a failed network request during a rotation operation
  Future<(ISigningKey, String)> next();

  // throw an exception if:
  // - next() has not been called since the last call to initialize() or rotate()
  //
  // this is the commit operation of next()
  Future<void> rotate();

  // returns: effectively, a handle to a signing key
  Future<ISigningKey> signer();
}

// server

abstract class IServerAuthenticationNonceStore {
  int get lifetimeInSeconds;

  // probably want to implement exponential backoff delay on generation, per identity
  //
  // returns: nonce
  Future<String> generate(String identity);

  // throw an exception if:
  // - nonce is not in the store
  //
  // returns: identity
  Future<String> validate(String nonce);
}

abstract class IServerAuthenticationKeyStore {
  // throw exceptions for:
  // - identity exists bool set and identity is not found in data store
  // - identity exists bool unset and identity is found in data store
  // - identity and device combination exists
  Future<void> register(
    String identity,
    String device,
    String publicKey,
    String rotationHash,
    bool existingIdentity,
  );

  // throw exceptions for:
  // - identity and device combination does not exist
  // - previous next hash doesn't match current hash
  Future<void> rotate(
    String identity,
    String device,
    String current,
    String rotationHash,
  );

  // returns: encoded key
  Future<String> public(String identity, String device);
}

abstract class IServerRecoveryHashStore {
  Future<void> register(String identity, String keyHash);

  // throw exceptions if:
  // - not found
  // - hash does not match
  Future<void> validate(String identity, String keyHash);
}

abstract class IServerTimeLockStore {
  int get lifetimeInSeconds;

  // throw an exception if:
  // - value is still alive in the store
  Future<void> reserve(String value);
}

abstract class IVerificationKeyStore {
  // throw an exception if:
  // - identity is not found
  Future<IVerificationKey> get(String identity);
}
