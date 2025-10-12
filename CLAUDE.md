# Better Auth - Dart Implementation

## Project Context

This is a **Dart client-only implementation** of [Better Auth](https://github.com/jasoncolburne/better-auth), a multi-repository authentication protocol.

This implementation provides **client-side only** components for Dart and Flutter applications. For server functionality, use one of the server implementations (TypeScript, Python, Rust, Go, or Ruby).

## Related Repositories

**Specification:** [better-auth](https://github.com/jasoncolburne/better-auth)

**Reference Implementation:** [better-auth-ts](https://github.com/jasoncolburne/better-auth-ts) (TypeScript - Client + Server)

**Other Implementations:**
- Full (Client + Server): [Python](https://github.com/jasoncolburne/better-auth-py), [Rust](https://github.com/jasoncolburne/better-auth-rs)
- Server Only: [Go](https://github.com/jasoncolburne/better-auth-go), [Ruby](https://github.com/jasoncolburne/better-auth-rb)
- Client Only: [Swift](https://github.com/jasoncolburne/better-auth-swift), [Kotlin](https://github.com/jasoncolburne/better-auth-kt)

## Repository Structure

This repository is a **git submodule** of the parent [better-auth](https://github.com/jasoncolburne/better-auth) specification repository. The parent repository includes all 8 language implementations as submodules and provides orchestration scripts for cross-implementation testing.

### Standardized Build System

All implementations use standardized `Makefile` targets for consistency:

```bash
make setup          # Get dependencies (dart pub get)
make test           # Run tests (dart test)
make lint           # Run linter (dart analyze)
make format         # Format code (dart format lib/ test/)
make format-check   # Check formatting (dart format --output=none --set-exit-if-changed)
make build          # Build project (dart compile if applicable)
make clean          # Clean artifacts
make test-integration  # Run integration tests (dart test test/integration_test.dart)
```

### Parent Repository Orchestration

The parent repository provides scripts in `scripts/` for running operations across all implementations:

- `scripts/run-setup.sh` - Setup all implementations
- `scripts/run-unit-tests.sh` - Run tests across all implementations
- `scripts/run-type-checks.sh` - Run type checkers across all implementations
- `scripts/run-lints.sh` - Run linters across all implementations
- `scripts/run-format-checks.sh` - Check formatting across all implementations
- `scripts/run-integration-tests.sh` - Run cross-language integration tests
- `scripts/run-all-checks.sh` - Run all checks in sequence
- `scripts/pull-repos.sh` - Update all submodules

These scripts automatically skip implementations where tooling is not available.

## Architecture

### Directory Structure

```
lib/
├── better_auth.dart        # Main library export file
├── api/                    # Client API implementation
│   ├── api.dart            # API exports
│   └── client.dart         # BetterAuthClient class
├── interfaces/             # Interface definitions
│   ├── interfaces.dart     # Interface exports
│   ├── crypto.dart         # Hasher, Noncer, Verifier, SigningKey, VerificationKey
│   ├── encoding.dart       # Timestamper interface
│   ├── io.dart             # Network interface
│   ├── paths.dart          # AuthenticationPaths interface
│   └── storage.dart        # Client storage interfaces
└── messages/               # Protocol message types
    ├── messages.dart       # Message exports
    ├── message.dart        # Base message types
    ├── request.dart        # Base request types
    ├── response.dart       # Base response types
    ├── account.dart        # Account protocol messages
    ├── device.dart         # Device protocol messages
    ├── session.dart        # Session protocol messages
    └── access.dart         # Access protocol messages

test/
└── better_auth_test.dart   # Test suite
```

### Key Components

**BetterAuthClient** (`lib/api/client.dart`)
- Implements all client-side protocol operations
- Manages authentication state and key rotation
- Handles token lifecycle
- Composes crypto, storage, and encoding interfaces

**Message Types** (`lib/messages/`)
- Dart classes with JSON serialization
- Type-safe request/response pairs
- `toJson()` / `fromJson()` methods

**Interface Definitions** (`lib/interfaces/`)
- Abstract classes define contracts
- Enable dependency injection
- Platform-agnostic abstractions

## Dart-Specific Patterns

### Abstract Classes for Interfaces

This implementation uses abstract classes to define interfaces:
- `Hasher`, `Noncer`, `Verifier` for crypto operations
- `SigningKey`, `VerificationKey` for key operations
- Storage interfaces for client state management
- `Network`, `Timestamper`, `AuthenticationPaths`, etc.

Abstract classes provide:
- Clear contracts
- Type safety
- Documentation

### Class-Based Messages

All message types are classes:
- Immutable properties (final fields)
- JSON serialization via `toJson()` / `fromJson()`
- Factory constructors for deserialization
- Named constructors for variants

### Error Handling

Dart-style error handling:
- Custom exception classes
- `throw` to raise exceptions
- `try-catch` to handle exceptions
- `rethrow` to propagate
- Stack traces preserved

### JSON Serialization

Messages use Dart's `dart:convert`:
- `toJson()` returns `Map<String, dynamic>`
- `fromJson()` factory constructors
- `jsonEncode()` / `jsonDecode()` for strings
- Type-safe serialization

### Async/Await

All async operations use Dart's async/await:
- `async` functions return `Future<T>`
- `await` for awaiting futures
- `Future.wait()` for parallel operations
- Stream support where applicable

### Null Safety

Leverages Dart's sound null safety:
- Non-nullable types by default
- `?` for nullable types
- `!` for null assertion
- `??` for null coalescing
- Compile-time null safety

## Testing

### Dart Tests
Tests use the `test` package:
- Test all client protocol operations
- Mock implementations for dependencies
- Cover account, device, session, and access flows

Run with: `dart test` or `flutter test`

### Running Tests
```bash
dart test                     # Run all tests (Dart)
flutter test                  # Run all tests (Flutter)
dart test --coverage          # With coverage
dart test test/better_auth_test.dart  # Specific file
```

## Usage Patterns

### Client Initialization

```dart
import 'package:better_auth/better_auth.dart';

final client = BetterAuthClient(
  crypto: CryptoConfig(
    hasher: yourHasher,
    noncer: yourNoncer,
    responsePublicKey: serverPublicKey,
  ),
  encoding: EncodingConfig(
    timestamper: yourTimestamper,
  ),
  io: IOConfig(
    network: yourNetwork,
  ),
  paths: yourPaths,
  store: StoreConfig(
    identity: identityStore,
    device: deviceStore,
    key: KeyStoreConfig(
      authentication: authKeyStore,
      access: accessKeyStore,
    ),
    token: TokenStoreConfig(
      access: tokenStore,
    ),
  ),
);
```

### Client Operations

```dart
// Create account
await client.createAccount(recoveryHash: recoveryHash);

// Authenticate
await client.authenticate();

// Make access request
final response = await client.makeAccessRequest(
  path: '/api/resource',
  payload: {'data': 'value'},
);

// Rotate authentication key
await client.rotateAuthenticationKey();

// Refresh access token
await client.refreshAccessToken();
```

### Error Handling

```dart
try {
  await client.authenticate();
} on BetterAuthException catch (e) {
  // Handle specific error
  print('Authentication failed: $e');
} catch (e, stackTrace) {
  // Handle generic error
  print('Unexpected error: $e\n$stackTrace');
}
```

## Development Workflow

### Installing Dependencies
```bash
dart pub get                  # Dart
flutter pub get               # Flutter
```

### Building
```bash
dart compile exe bin/main.dart  # Compile to native (if applicable)
flutter build apk             # Build Android app
flutter build ios             # Build iOS app
```

### Testing
```bash
dart test                     # Run tests (Dart)
flutter test                  # Run tests (Flutter)
dart test --coverage          # With coverage
```

### Linting & Formatting
```bash
dart format lib/ test/        # Format code
dart analyze                  # Analyze code
```

## Platform Support

This Dart package supports:
- **Dart** 3.0+
- **Flutter** 3.0+
  - Android
  - iOS
  - Web
  - Desktop (Windows, macOS, Linux)

Platform-specific considerations:
- `flutter_secure_storage` for secure storage on mobile
- `shared_preferences` for simple storage
- `http` package for networking
- `pointycastle` or platform crypto for cryptography

## Integration with Server Implementations

This Dart client is designed to work with any Better Auth server:
- Go server (`better-auth-go`)
- Ruby server (`better-auth-rb`)
- TypeScript server (`better-auth-ts`)
- Python server (`better-auth-py`)
- Rust server (`better-auth-rs`)

## Flutter Usage

When using with Flutter:
```dart
dependencies:
  better_auth:
    git:
      url: https://github.com/jasoncolburne/better-auth-dart
```

Example Flutter integration:
```dart
import 'package:flutter/material.dart';
import 'package:better_auth/better_auth.dart';

class AuthService {
  final BetterAuthClient client;

  AuthService(this.client);

  Future<void> login() async {
    try {
      await client.authenticate();
      // Update UI
    } catch (e) {
      // Handle error
    }
  }
}
```

## Making Changes

When making changes to this implementation:
1. Update the code
2. Run tests: `dart test` or `flutter test`
3. Format code: `dart format lib/ test/`
4. Analyze: `dart analyze`
5. If protocol changes: sync with the TypeScript reference implementation
6. If breaking changes: update documentation and version
7. Update this CLAUDE.md if architecture changes

## Key Files to Know

- `lib/api/client.dart` - All client logic
- `lib/messages/` - Protocol message definitions
- `lib/interfaces/` - Interface definitions
- `test/better_auth_test.dart` - Test suite
- `pubspec.yaml` - Package manifest

## Pub Package

This is a Dart/Flutter package:
- `pubspec.yaml` defines the package
- Add as dependency in other projects:
  ```yaml
  dependencies:
    better_auth:
      git:
        url: https://github.com/jasoncolburne/better-auth-dart
  ```
- Import with: `import 'package:better_auth/better_auth.dart';`

## Example Implementations

Reference implementations for interfaces should use:
- **pointycastle** for cryptography (pure Dart)
- **cryptography** package as alternative
- **http** package for network operations
- **flutter_secure_storage** for secure storage (Flutter)
- **shared_preferences** for simple storage (Flutter)
- **hive** for local database (Dart/Flutter)

## Dart/Flutter Version

Requires:
- **Dart** 3.0+ for null safety and modern features
- **Flutter** 3.0+ for Flutter applications
