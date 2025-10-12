# better-auth-dart

**Dart client-only implementation** of [Better Auth](https://github.com/jasoncolburne/better-auth) - a multi-repository, multi-language authentication protocol.

This implementation provides client-side protocol handling for Dart and Flutter applications. For server functionality, use TypeScript, Python, Rust, Go, or Ruby implementations.

## What's Included

- ✅ **Client Only** - All client-side protocol operations
- ✅ **Dart + Flutter** - Works with pure Dart and Flutter projects
- ✅ **Async/Await** - Built with Dart's Future-based async
- ✅ **Null-Safe** - Leverages Dart's sound null safety
- ✅ **JSON Serialization** - Type-safe with toJson()/fromJson()
- ✅ **Pub Package** - Distributed via pub.dev

## Quick Start

This repository is a submodule of the [main spec repository](https://github.com/jasoncolburne/better-auth). For the full multi-language setup, see the parent repository.

### Setup

```bash
make setup          # dart pub get
```

### Running Tests

```bash
make test           # Run dart test
make lint           # Run dart analyze
make format-check   # Check code formatting
```

### Integration Testing

```bash
# Start a server (TypeScript, Python, Rust, Go, or Ruby)
# In the server repository:
make server

# In this repository, run integration tests:
make test-integration
```

## Development

This implementation uses:
- **Dart 3.0+** for null safety and modern features
- **Pub** for dependency management
- **Abstract classes** for interface definitions
- **JSON serialization** via toJson()/fromJson()
- **Future-based async** for all async operations

All development commands use standardized `make` targets:

```bash
make setup          # dart pub get
make test           # dart test
make lint           # dart analyze
make format         # dart format lib/ test/
make format-check   # dart format --output=none --set-exit-if-changed lib/ test/
make build          # dart compile (if applicable)
make clean          # Remove build artifacts
make test-integration  # Run integration tests
```

## Architecture

See [CLAUDE.md](CLAUDE.md) for detailed architecture documentation including:
- Directory structure and key components
- Dart-specific patterns (abstract classes, null safety, error handling)
- Message types and interface definitions
- Usage examples and API patterns

### Key Features

- **Abstract Classes for Interfaces**: Hasher, Noncer, Verifier, SigningKey, VerificationKey
- **Class-Based Messages**: Immutable properties with JSON serialization
- **Error Handling**: Dart-style exception handling with custom exception classes
- **JSON Serialization**: toJson() returns Map<String, dynamic>, fromJson() factory constructors
- **Null Safety**: Sound null safety with non-nullable types by default

### Platform Support

- **Dart** 3.0+
- **Flutter** 3.0+
  - Android
  - iOS
  - Web
  - Desktop (Windows, macOS, Linux)

### Reference Implementations

Reference implementations should use:
- **pointycastle** or **cryptography** for cryptographic primitives
- **http** package for networking
- **flutter_secure_storage** for secure storage (Flutter)
- **shared_preferences** for simple storage (Flutter)

## Integration with Server Implementations

This Dart client is designed to work with any Better Auth server:
- **TypeScript server** (better-auth-ts)
- **Python server** (better-auth-py)
- **Rust server** (better-auth-rs)
- **Go server** (better-auth-go)
- **Ruby server** (better-auth-rb)

## Related Implementations

**Full Implementations (Client + Server):**
- [TypeScript](https://github.com/jasoncolburne/better-auth-ts) - Reference implementation
- [Python](https://github.com/jasoncolburne/better-auth-py)
- [Rust](https://github.com/jasoncolburne/better-auth-rs)

**Server-Only:**
- [Go](https://github.com/jasoncolburne/better-auth-go)
- [Ruby](https://github.com/jasoncolburne/better-auth-rb)

**Client-Only:**
- [Swift](https://github.com/jasoncolburne/better-auth-swift)
- [Dart](https://github.com/jasoncolburne/better-auth-dart) - **This repository**
- [Kotlin](https://github.com/jasoncolburne/better-auth-kt)

## License

MIT
