import '../interfaces/interfaces.dart';
import '../messages/messages.dart';

class BetterAuthClient {
  final IHasher _hasher;
  final INoncer _noncer;
  final IVerificationKeyStore _verificationKeyStore;
  final ITimestamper _timestamper;
  final INetwork _network;
  final IAuthenticationPaths _paths;
  final IClientValueStore _deviceIdentifierStore;
  final IClientValueStore _identityIdentifierStore;
  final IClientRotatingKeyStore _accessKeyStore;
  final IClientRotatingKeyStore _authenticationKeyStore;
  final IClientValueStore _accessTokenStore;

  BetterAuthClient({
    required IHasher hasher,
    required INoncer noncer,
    required IVerificationKeyStore verificationKeyStore,
    required ITimestamper timestamper,
    required INetwork network,
    required IAuthenticationPaths paths,
    required IClientValueStore deviceIdentifierStore,
    required IClientValueStore identityIdentifierStore,
    required IClientRotatingKeyStore accessKeyStore,
    required IClientRotatingKeyStore authenticationKeyStore,
    required IClientValueStore accessTokenStore,
  })  : _hasher = hasher,
        _noncer = noncer,
        _verificationKeyStore = verificationKeyStore,
        _timestamper = timestamper,
        _network = network,
        _paths = paths,
        _deviceIdentifierStore = deviceIdentifierStore,
        _identityIdentifierStore = identityIdentifierStore,
        _accessKeyStore = accessKeyStore,
        _authenticationKeyStore = authenticationKeyStore,
        _accessTokenStore = accessTokenStore;

  Future<String> identity() async {
    return await _identityIdentifierStore.get();
  }

  Future<String> device() async {
    return await _deviceIdentifierStore.get();
  }

  Future<void> _verifyResponse(
      SignableMessage response, String serverIdentity) async {
    final verificationKey = await _verificationKeyStore.get(serverIdentity);
    final publicKey = await verificationKey.public();
    final verifier = verificationKey.verifier();
    await response.verify(verifier, publicKey);
  }

  Future<void> createAccount(String recoveryHash) async {
    final result = await _authenticationKeyStore.initialize(recoveryHash);
    final identity = result[0];
    final publicKey = result[1];
    final rotationHash = result[2];
    final device = await _hasher.sum(publicKey);

    final nonce = await _noncer.generate128();

    final request = CreationRequest({
      'authentication': {
        'device': device,
        'identity': identity,
        'publicKey': publicKey,
        'recoveryHash': recoveryHash,
        'rotationHash': rotationHash,
      },
    }, nonce);

    await request.sign(await _authenticationKeyStore.signer());
    final message = await request.serialize();
    final reply = await _network.sendRequest(_paths.account.create, message);

    final response = CreationResponse.parse(reply);
    await _verifyResponse(
        response, response.payload['access']['serverIdentity']);

    if (response.payload['access']['nonce'] != nonce) {
      throw Exception('incorrect nonce');
    }

    await _identityIdentifierStore.store(identity);
    await _deviceIdentifierStore.store(device);
  }

  // happens on the new device
  // send identity by qr code or network from the existing device
  Future<String> generateLinkContainer(String identity) async {
    final result = await _authenticationKeyStore.initialize();
    final publicKey = result[1];
    final rotationHash = result[2];
    final device = await _hasher.sum(publicKey);

    await _identityIdentifierStore.store(identity);
    await _deviceIdentifierStore.store(device);

    final linkContainer = LinkContainer({
      'authentication': {
        'device': device,
        'identity': identity,
        'publicKey': publicKey,
        'rotationHash': rotationHash,
      },
    });

    await linkContainer.sign(await _authenticationKeyStore.signer());

    return await linkContainer.serialize();
  }

  // happens on the existing device (share with qr code + camera)
  // use a 61x61 module layout and a 53x53 module code, centered on the new device, at something
  // like 244x244px (61*4x61*4)
  Future<void> linkDevice(String linkContainer) async {
    final container = LinkContainer.parse(linkContainer);
    final nonce = await _noncer.generate128();

    // Rotate authentication key
    final result = await _authenticationKeyStore.rotate();
    final publicKey = result[0];
    final rotationHash = result[1];

    final request = LinkDeviceRequest({
      'authentication': {
        'device': await _deviceIdentifierStore.get(),
        'identity': await _identityIdentifierStore.get(),
        'publicKey': publicKey,
        'rotationHash': rotationHash,
      },
      'link': container.toJson(),
    }, nonce);

    await request.sign(await _authenticationKeyStore.signer());
    final message = await request.serialize();
    final reply = await _network.sendRequest(_paths.device.link, message);

    final response = LinkDeviceResponse.parse(reply);
    await _verifyResponse(
        response, response.payload['access']['serverIdentity']);

    if (response.payload['access']['nonce'] != nonce) {
      throw Exception('incorrect nonce');
    }
  }

  Future<void> unlinkDevice(String device) async {
    final nonce = await _noncer.generate128();

    final [publicKey, rotationHash] = await _authenticationKeyStore.rotate();

    var hash = rotationHash;
    if (device == await _deviceIdentifierStore.get()) {
      // if we're disabling the current device, this stops rotations
      hash = await _hasher.sum(rotationHash);
    }

    final request = UnlinkDeviceRequest({
      'authentication': {
        'device': await _deviceIdentifierStore.get(),
        'identity': await _identityIdentifierStore.get(),
        'publicKey': publicKey,
        'rotationHash': hash,
      },
      'link': {
        'device': device,
      },
    }, nonce);

    await request.sign(await _authenticationKeyStore.signer());
    final message = await request.serialize();
    final reply = await _network.sendRequest(_paths.device.unlink, message);

    final response = UnlinkDeviceResponse.parse(reply);
    await _verifyResponse(
        response, response.payload['access']['serverIdentity']);

    if (response.payload['access']['nonce'] != nonce) {
      throw Exception('incorrect nonce');
    }
  }

  Future<void> rotateAuthenticationKey() async {
    final result = await _authenticationKeyStore.rotate();
    final publicKey = result[0];
    final rotationHash = result[1];
    final nonce = await _noncer.generate128();

    final request = RotateAuthenticationKeyRequest({
      'authentication': {
        'device': await _deviceIdentifierStore.get(),
        'identity': await _identityIdentifierStore.get(),
        'publicKey': publicKey,
        'rotationHash': rotationHash,
      },
    }, nonce);

    await request.sign(await _authenticationKeyStore.signer());
    final message = await request.serialize();
    final reply = await _network.sendRequest(_paths.device.rotate, message);

    final response = RotateAuthenticationKeyResponse.parse(reply);
    await _verifyResponse(
        response, response.payload['access']['serverIdentity']);

    if (response.payload['access']['nonce'] != nonce) {
      throw Exception('incorrect nonce');
    }
  }

  Future<void> authenticate() async {
    final startNonce = await _noncer.generate128();

    final startRequest = StartAuthenticationRequest({
      'access': {
        'nonce': startNonce,
      },
      'request': {
        'authentication': {
          'identity': await _identityIdentifierStore.get(),
        },
      },
    });

    final startMessage = await startRequest.serialize();
    final startReply =
        await _network.sendRequest(_paths.session.request, startMessage);

    final startResponse = StartAuthenticationResponse.parse(startReply);
    await _verifyResponse(
        startResponse, startResponse.payload['access']['serverIdentity']);

    if (startResponse.payload['access']['nonce'] != startNonce) {
      throw Exception('incorrect nonce');
    }

    final accessResult = await _accessKeyStore.initialize();
    final currentKey = accessResult[1];
    final nextKeyHash = accessResult[2];
    final finishNonce = await _noncer.generate128();

    final finishRequest = FinishAuthenticationRequest({
      'access': {
        'publicKey': currentKey,
        'rotationHash': nextKeyHash,
      },
      'authentication': {
        'device': await _deviceIdentifierStore.get(),
        'nonce': startResponse.payload['response']['authentication']['nonce'],
      },
    }, finishNonce);

    await finishRequest.sign(await _authenticationKeyStore.signer());
    final finishMessage = await finishRequest.serialize();
    final finishReply =
        await _network.sendRequest(_paths.session.connect, finishMessage);

    final finishResponse = FinishAuthenticationResponse.parse(finishReply);
    await _verifyResponse(
        finishResponse, finishResponse.payload['access']['serverIdentity']);

    if (finishResponse.payload['access']['nonce'] != finishNonce) {
      throw Exception('incorrect nonce');
    }

    await _accessTokenStore
        .store(finishResponse.payload['response']['access']['token']);
  }

  Future<void> refreshAccessToken() async {
    final result = await _accessKeyStore.rotate();
    final publicKey = result[0];
    final rotationHash = result[1];
    final nonce = await _noncer.generate128();

    final request = RefreshAccessTokenRequest({
      'access': {
        'publicKey': publicKey,
        'rotationHash': rotationHash,
        'token': await _accessTokenStore.get(),
      },
    }, nonce);

    await request.sign(await _accessKeyStore.signer());
    final message = await request.serialize();
    final reply = await _network.sendRequest(_paths.session.refresh, message);

    final response = RefreshAccessTokenResponse.parse(reply);
    await _verifyResponse(
        response, response.payload['access']['serverIdentity']);

    if (response.payload['access']['nonce'] != nonce) {
      throw Exception('incorrect nonce');
    }

    await _accessTokenStore
        .store(response.payload['response']['access']['token']);
  }

  Future<void> recoverAccount(
      String identity, ISigningKey recoveryKey, String recoveryHash) async {
    final result = await _authenticationKeyStore.initialize();
    final current = result[1];
    final rotationHash = result[2];
    final device = await _hasher.sum(current);
    final nonce = await _noncer.generate128();

    final request = RecoverAccountRequest({
      'authentication': {
        'device': device,
        'identity': identity,
        'publicKey': current,
        'recoveryHash': recoveryHash,
        'recoveryKey': await recoveryKey.public(),
        'rotationHash': rotationHash,
      },
    }, nonce);

    await request.sign(recoveryKey);
    final message = await request.serialize();
    final reply = await _network.sendRequest(_paths.account.recover, message);

    final response = RecoverAccountResponse.parse(reply);
    await _verifyResponse(
        response, response.payload['access']['serverIdentity']);

    if (response.payload['access']['nonce'] != nonce) {
      throw Exception('incorrect nonce');
    }

    await _identityIdentifierStore.store(identity);
    await _deviceIdentifierStore.store(device);
  }

  Future<String> makeAccessRequest<T>(String path, T request) async {
    final accessRequest = AccessRequest<T>({
      'access': {
        'nonce': await _noncer.generate128(),
        'timestamp': _timestamper.format(_timestamper.now()),
        'token': await _accessTokenStore.get(),
      },
      'request': request,
    });

    await accessRequest.sign(await _accessKeyStore.signer());
    final message = await accessRequest.serialize();
    final reply = await _network.sendRequest(path, message);
    final response = ScannableResponse.parse(reply);

    if (response.payload['access']['nonce'] !=
        accessRequest.payload['access']['nonce']) {
      throw Exception('incorrect nonce');
    }

    return reply;
  }
}
