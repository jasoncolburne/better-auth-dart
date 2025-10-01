# better-auth-dart

A Dart port of the better-auth TypeScript authentication client.

## Overview

This is a pure-logic port of the better-auth client from TypeScript to Dart. The library provides a secure authentication client with support for:

- Account creation and recovery
- Device linking
- Key rotation
- Access token management
- Authenticated requests

## Project Structure

```
lib/
├── api/                    # Client API
│   └── client.dart        # Main BetterAuthClient class
├── interfaces/            # Abstract interfaces
│   ├── crypto.dart       # Cryptographic interfaces
│   ├── encoding.dart     # Encoding interfaces
│   ├── io.dart          # Network interfaces
│   ├── paths.dart       # Path configuration
│   └── storage.dart     # Storage interfaces
└── messages/             # Message classes
    ├── message.dart     # Base message classes
    ├── request.dart     # Client request classes
    ├── response.dart    # Server response classes
    └── ...              # Various message types

test/
├── implementation/       # Test implementations
│   ├── crypto/          # Crypto implementations (secp256r1, hash, nonce)
│   ├── encoding/        # Encoding implementations (base64, timestamper)
│   └── storage/         # Storage implementations (client stores)
└── integration_test.dart # Integration tests
```

## Dependencies

All dependencies are dev dependencies since this is pure protocol logic:

- `test` - Testing framework
- `http` - HTTP client for integration tests
- `pointycastle` - Cryptographic primitives for tests
- `crypto` - Hashing for tests

## Running Tests

To run the integration tests (requires a running better-auth server on localhost:8080):

```bash
dart test test/integration_test.dart
```

## Usage

See `test/integration_test.dart` for complete examples of how to instantiate and use the client.
