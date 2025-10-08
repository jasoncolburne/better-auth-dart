import 'package:test/test.dart';
import 'package:http/http.dart' as http;
import 'package:better_auth_dart/api/api.dart';
import 'package:better_auth_dart/interfaces/interfaces.dart';
import 'package:better_auth_dart/messages/messages.dart';
import 'implementation/implementation.dart';

const debugLogging = false;

class Secp256r1VerificationKey implements IVerificationKey {
  final String publicKey;
  final Secp256r1Verifier secpVerifier;

  Secp256r1VerificationKey(this.publicKey) : secpVerifier = Secp256r1Verifier();

  @override
  Future<String> public() async {
    return publicKey;
  }

  @override
  IVerifier verifier() {
    return secpVerifier;
  }

  @override
  Future<void> verify(String message, String signature) async {
    return secpVerifier.verify(message, signature, publicKey);
  }
}

final authenticationPaths = IAuthenticationPaths(
  account: AccountPaths(
    create: '/account/create',
    recover: '/account/recover',
  ),
  session: SessionPaths(
    request: '/session/request',
    create: '/session/create',
    refresh: '/session/refresh',
  ),
  device: DevicePaths(
    rotate: '/device/rotate',
    link: '/device/link',
    unlink: '/device/unlink',
  ),
);

class Network implements INetwork {
  @override
  Future<String> sendRequest(String path, String message) async {
    if (debugLogging) {
      print(message);
    }

    final response = await http.post(
      Uri.parse('http://localhost:8080$path'),
      headers: {'Content-Type': 'application/json'},
      body: message,
    );

    final reply = response.body;

    if (debugLogging) {
      print(reply);
    }

    return reply;
  }
}

class FakeResponse extends ServerResponse<Map<String, dynamic>> {
  FakeResponse(super.response, super.serverIdentity, super.nonce);

  static FakeResponse parse(String message) {
    return ServerResponse.parse<Map<String, dynamic>>(
      message,
      (Map<String, dynamic> response, String serverIdentity, String nonce) =>
          FakeResponse(response, serverIdentity, nonce),
    ) as FakeResponse;
  }
}

Future<void> executeFlow(
  BetterAuthClient betterAuthClient,
  IVerifier eccVerifier,
  IVerificationKey responseVerificationKey,
) async {
  await betterAuthClient.rotateDevice();
  await betterAuthClient.createSession();
  await betterAuthClient.refreshSession();

  await testAccess(betterAuthClient, eccVerifier, responseVerificationKey);
}

Future<void> testAccess(
  BetterAuthClient betterAuthClient,
  IVerifier eccVerifier,
  IVerificationKey responseVerificationKey,
) async {
  final message = {
    'foo': 'bar',
    'bar': 'foo',
  };
  final reply = await betterAuthClient.makeAccessRequest('/foo/bar', message);
  final response = FakeResponse.parse(reply);

  await response.verify(eccVerifier, await responseVerificationKey.public());

  if (response.payload['response']['wasFoo'] != 'bar' ||
      response.payload['response']['wasBar'] != 'foo') {
    throw Exception('invalid data returned');
  }
}

void main() {
  group('integration', () {
    test('completes auth flows', () async {
      final eccVerifier = Secp256r1Verifier();
      final hasher = Hasher();
      final noncer = Noncer();

      final recoverySigner = Secp256r1();
      await recoverySigner.generate();

      final network = Network();

      final responsePublicKey = await network.sendRequest('/key/response', '');
      final responseVerificationKey =
          Secp256r1VerificationKey(responsePublicKey);

      // Server identity is the public key itself (not hashed)
      final serverIdentity = responsePublicKey;
      final verificationKeyStore = VerificationKeyStore();
      verificationKeyStore.add(serverIdentity, responseVerificationKey);

      final betterAuthClient = BetterAuthClient(
        hasher: hasher,
        noncer: noncer,
        verificationKeyStore: verificationKeyStore,
        timestamper: Rfc3339Nano(),
        network: network,
        paths: authenticationPaths,
        deviceIdentifierStore: ClientValueStore(),
        identityIdentifierStore: ClientValueStore(),
        accessKeyStore: ClientRotatingKeyStore(),
        authenticationKeyStore: ClientRotatingKeyStore(),
        accessTokenStore: ClientValueStore(),
      );

      final recoveryHash = await hasher.sum(await recoverySigner.public());
      await betterAuthClient.createAccount(recoveryHash);
      await executeFlow(betterAuthClient, eccVerifier, responseVerificationKey);
    });

    test('recovers from loss', () async {
      final eccVerifier = Secp256r1Verifier();
      final hasher = Hasher();
      final noncer = Noncer();

      final recoverySigner = Secp256r1();
      await recoverySigner.generate();

      final network = Network();

      final responsePublicKey = await network.sendRequest('/key/response', '');
      final responseVerificationKey =
          Secp256r1VerificationKey(responsePublicKey);

      // Server identity is the public key itself (not hashed)
      final serverIdentity = responsePublicKey;
      final verificationKeyStore = VerificationKeyStore();
      verificationKeyStore.add(serverIdentity, responseVerificationKey);

      final betterAuthClient = BetterAuthClient(
        hasher: hasher,
        noncer: noncer,
        verificationKeyStore: verificationKeyStore,
        timestamper: Rfc3339Nano(),
        network: network,
        paths: authenticationPaths,
        deviceIdentifierStore: ClientValueStore(),
        identityIdentifierStore: ClientValueStore(),
        accessKeyStore: ClientRotatingKeyStore(),
        authenticationKeyStore: ClientRotatingKeyStore(),
        accessTokenStore: ClientValueStore(),
      );

      final recoveredVerificationKeyStore = VerificationKeyStore();
      recoveredVerificationKeyStore.add(
          serverIdentity, responseVerificationKey);

      final recoveredBetterAuthClient = BetterAuthClient(
        hasher: Hasher(),
        noncer: Noncer(),
        verificationKeyStore: recoveredVerificationKeyStore,
        timestamper: Rfc3339Nano(),
        network: network,
        paths: authenticationPaths,
        deviceIdentifierStore: ClientValueStore(),
        identityIdentifierStore: ClientValueStore(),
        accessKeyStore: ClientRotatingKeyStore(),
        authenticationKeyStore: ClientRotatingKeyStore(),
        accessTokenStore: ClientValueStore(),
      );

      final recoveryHash = await hasher.sum(await recoverySigner.public());
      await betterAuthClient.createAccount(recoveryHash);

      final nextRecoverySigner = Secp256r1();
      await nextRecoverySigner.generate();
      final nextRecoveryHash =
          await hasher.sum(await nextRecoverySigner.public());
      final identity = await betterAuthClient.identity();
      await recoveredBetterAuthClient.recoverAccount(
          identity, recoverySigner, nextRecoveryHash);
      await executeFlow(
          recoveredBetterAuthClient, eccVerifier, responseVerificationKey);
    });

    test('links another device', () async {
      final eccVerifier = Secp256r1Verifier();
      final hasher = Hasher();
      final noncer = Noncer();

      final recoverySigner = Secp256r1();
      await recoverySigner.generate();

      final network = Network();

      final responsePublicKey = await network.sendRequest('/key/response', '');
      final responseVerificationKey =
          Secp256r1VerificationKey(responsePublicKey);

      // Server identity is the public key itself (not hashed)
      final serverIdentity = responsePublicKey;
      final verificationKeyStore = VerificationKeyStore();
      verificationKeyStore.add(serverIdentity, responseVerificationKey);

      final betterAuthClient = BetterAuthClient(
        hasher: hasher,
        noncer: noncer,
        verificationKeyStore: verificationKeyStore,
        timestamper: Rfc3339Nano(),
        network: network,
        paths: authenticationPaths,
        deviceIdentifierStore: ClientValueStore(),
        identityIdentifierStore: ClientValueStore(),
        accessKeyStore: ClientRotatingKeyStore(),
        authenticationKeyStore: ClientRotatingKeyStore(),
        accessTokenStore: ClientValueStore(),
      );

      final linkedVerificationKeyStore = VerificationKeyStore();
      linkedVerificationKeyStore.add(serverIdentity, responseVerificationKey);

      final linkedBetterAuthClient = BetterAuthClient(
        hasher: Hasher(),
        noncer: Noncer(),
        verificationKeyStore: linkedVerificationKeyStore,
        timestamper: Rfc3339Nano(),
        network: network,
        paths: authenticationPaths,
        deviceIdentifierStore: ClientValueStore(),
        identityIdentifierStore: ClientValueStore(),
        accessKeyStore: ClientRotatingKeyStore(),
        authenticationKeyStore: ClientRotatingKeyStore(),
        accessTokenStore: ClientValueStore(),
      );

      final recoveryHash = await hasher.sum(await recoverySigner.public());
      await betterAuthClient.createAccount(recoveryHash);
      final identity = await betterAuthClient.identity();

      // get link container from the new device
      final linkContainer =
          await linkedBetterAuthClient.generateLinkContainer(identity);
      if (debugLogging) {
        print(linkContainer);
      }

      // submit an endorsed link container with existing device
      await betterAuthClient.linkDevice(linkContainer);

      await executeFlow(
          linkedBetterAuthClient, eccVerifier, responseVerificationKey);

      // unlink the original device
      await linkedBetterAuthClient
          .unlinkDevice(await betterAuthClient.device());
    });

    test('detects mismatched access nonce', () async {
      final hasher = Hasher();
      final noncer = Noncer();

      final recoverySigner = Secp256r1();
      await recoverySigner.generate();

      final network = Network();

      final responsePublicKey = await network.sendRequest('/key/response', '');
      final responseVerificationKey =
          Secp256r1VerificationKey(responsePublicKey);

      // Server identity is the public key itself (not hashed)
      final serverIdentity = responsePublicKey;
      final verificationKeyStore = VerificationKeyStore();
      verificationKeyStore.add(serverIdentity, responseVerificationKey);

      final accessTokenStore = ClientValueStore();
      final betterAuthClient = BetterAuthClient(
        hasher: hasher,
        noncer: noncer,
        verificationKeyStore: verificationKeyStore,
        timestamper: Rfc3339Nano(),
        network: network,
        paths: authenticationPaths,
        deviceIdentifierStore: ClientValueStore(),
        identityIdentifierStore: ClientValueStore(),
        accessKeyStore: ClientRotatingKeyStore(),
        authenticationKeyStore: ClientRotatingKeyStore(),
        accessTokenStore: accessTokenStore,
      );

      final recoveryHash = await hasher.sum(await recoverySigner.public());
      await betterAuthClient.createAccount(recoveryHash);

      try {
        await betterAuthClient.createSession();
        final message = {
          'foo': 'bar',
          'bar': 'foo',
        };
        await betterAuthClient.makeAccessRequest('/bad/nonce', message);

        throw Exception('expected a failure');
      } catch (e) {
        expect(e.toString(), contains('incorrect nonce'));
      }
    });
  });
}
