/// Better Auth Error System
///
/// This file defines the error hierarchy for Better Auth following
/// the specification in ERRORS.md in the root repository.
library;

/// Base error class for all Better Auth errors
class BetterAuthError implements Exception {
  final String code;
  final String message;
  final Map<String, dynamic>? context;

  const BetterAuthError(this.code, this.message, [this.context]);

  Map<String, dynamic> toJson() => {
        'error': {
          'code': code,
          'message': message,
          if (context != null) 'context': context,
        }
      };

  @override
  String toString() => message;
}

// ============================================================================
// Validation Errors
// ============================================================================

/// Message structure is invalid or malformed (BA101)
class InvalidMessageError extends BetterAuthError {
  InvalidMessageError({String? field, String? details})
      : super(
          'BA101',
          _buildMessage(field, details),
          _buildContext(field, details),
        );

  static String _buildMessage(String? field, String? details) {
    if (field == null) return 'Message structure is invalid or malformed';
    var msg = 'Message structure is invalid: $field';
    if (details != null) msg += ' ($details)';
    return msg;
  }

  static Map<String, dynamic>? _buildContext(String? field, String? details) {
    if (field == null && details == null) return null;
    final ctx = <String, dynamic>{};
    if (field != null) ctx['field'] = field;
    if (details != null) ctx['details'] = details;
    return ctx;
  }
}

/// Identity verification failed (BA102)
class InvalidIdentityError extends BetterAuthError {
  InvalidIdentityError({String? provided, String? details})
      : super(
          'BA102',
          'Identity verification failed',
          _buildContext(provided, details),
        );

  static Map<String, dynamic>? _buildContext(
      String? provided, String? details) {
    if (provided == null && details == null) return null;
    final ctx = <String, dynamic>{};
    if (provided != null) ctx['provided'] = provided;
    if (details != null) ctx['details'] = details;
    return ctx;
  }
}

/// Device hash does not match hash(publicKey || rotationHash) (BA103)
class InvalidDeviceError extends BetterAuthError {
  InvalidDeviceError({String? provided, String? calculated})
      : super(
          'BA103',
          'Device hash does not match hash(publicKey || rotationHash)',
          _buildContext(provided, calculated),
        );

  static Map<String, dynamic>? _buildContext(
      String? provided, String? calculated) {
    if (provided == null && calculated == null) return null;
    final ctx = <String, dynamic>{};
    if (provided != null) ctx['provided'] = provided;
    if (calculated != null) ctx['calculated'] = calculated;
    return ctx;
  }
}

/// Hash validation failed (BA104)
class InvalidHashError extends BetterAuthError {
  InvalidHashError({String? expected, String? actual, String? hashType})
      : super(
          'BA104',
          'Hash validation failed',
          _buildContext(expected, actual, hashType),
        );

  static Map<String, dynamic>? _buildContext(
      String? expected, String? actual, String? hashType) {
    if (expected == null && actual == null && hashType == null) return null;
    final ctx = <String, dynamic>{};
    if (expected != null) ctx['expected'] = expected;
    if (actual != null) ctx['actual'] = actual;
    if (hashType != null) ctx['hashType'] = hashType;
    return ctx;
  }
}

// ============================================================================
// Cryptographic Errors
// ============================================================================

/// Signature verification failed (BA201)
class SignatureVerificationError extends BetterAuthError {
  SignatureVerificationError({String? publicKey, String? signedData})
      : super(
          'BA201',
          'Signature verification failed',
          _buildContext(publicKey, signedData),
        );

  static Map<String, dynamic>? _buildContext(
      String? publicKey, String? signedData) {
    if (publicKey == null && signedData == null) return null;
    final ctx = <String, dynamic>{};
    if (publicKey != null) ctx['publicKey'] = publicKey;
    if (signedData != null) ctx['signedData'] = signedData;
    return ctx;
  }
}

/// Response nonce does not match request nonce (BA203)
class IncorrectNonceError extends BetterAuthError {
  IncorrectNonceError({String? expected, String? actual})
      : super(
          'BA203',
          'Response nonce does not match request nonce',
          _buildContext(expected, actual),
        );

  static Map<String, dynamic>? _buildContext(String? expected, String? actual) {
    if (expected == null && actual == null) return null;
    final ctx = <String, dynamic>{};
    if (expected != null) ctx['expected'] = _truncate(expected);
    if (actual != null) ctx['actual'] = _truncate(actual);
    return ctx;
  }

  static String _truncate(String s) =>
      s.length > 16 ? '${s.substring(0, 16)}...' : s;
}

/// Authentication challenge has expired (BA204)
class ExpiredNonceError extends BetterAuthError {
  ExpiredNonceError({
    String? nonceTimestamp,
    String? currentTime,
    String? expirationWindow,
  }) : super(
          'BA204',
          'Authentication challenge has expired',
          _buildContext(nonceTimestamp, currentTime, expirationWindow),
        );

  static Map<String, dynamic>? _buildContext(
    String? nonceTimestamp,
    String? currentTime,
    String? expirationWindow,
  ) {
    if (nonceTimestamp == null &&
        currentTime == null &&
        expirationWindow == null) {
      return null;
    }
    final ctx = <String, dynamic>{};
    if (nonceTimestamp != null) ctx['nonceTimestamp'] = nonceTimestamp;
    if (currentTime != null) ctx['currentTime'] = currentTime;
    if (expirationWindow != null) ctx['expirationWindow'] = expirationWindow;
    return ctx;
  }
}

/// Nonce has already been used (replay attack detected) (BA205)
class NonceReplayError extends BetterAuthError {
  NonceReplayError({String? nonce, String? previousUsageTimestamp})
      : super(
          'BA205',
          'Nonce has already been used (replay attack detected)',
          _buildContext(nonce, previousUsageTimestamp),
        );

  static Map<String, dynamic>? _buildContext(
      String? nonce, String? previousUsageTimestamp) {
    if (nonce == null && previousUsageTimestamp == null) return null;
    final ctx = <String, dynamic>{};
    if (nonce != null) ctx['nonce'] = _truncate(nonce);
    if (previousUsageTimestamp != null) {
      ctx['previousUsageTimestamp'] = previousUsageTimestamp;
    }
    return ctx;
  }

  static String _truncate(String s) =>
      s.length > 16 ? '${s.substring(0, 16)}...' : s;
}

// ============================================================================
// Authentication/Authorization Errors
// ============================================================================

/// Link container identity does not match request identity (BA302)
class MismatchedIdentitiesError extends BetterAuthError {
  MismatchedIdentitiesError({
    String? linkContainerIdentity,
    String? requestIdentity,
  }) : super(
          'BA302',
          'Link container identity does not match request identity',
          _buildContext(linkContainerIdentity, requestIdentity),
        );

  static Map<String, dynamic>? _buildContext(
    String? linkContainerIdentity,
    String? requestIdentity,
  ) {
    if (linkContainerIdentity == null && requestIdentity == null) return null;
    final ctx = <String, dynamic>{};
    if (linkContainerIdentity != null) {
      ctx['linkContainerIdentity'] = linkContainerIdentity;
    }
    if (requestIdentity != null) ctx['requestIdentity'] = requestIdentity;
    return ctx;
  }
}

/// Insufficient permissions for requested operation (BA303)
class PermissionDeniedError extends BetterAuthError {
  PermissionDeniedError({
    List<String>? requiredPermissions,
    List<String>? actualPermissions,
    String? operation,
  }) : super(
          'BA303',
          'Insufficient permissions for requested operation',
          _buildContext(requiredPermissions, actualPermissions, operation),
        );

  static Map<String, dynamic>? _buildContext(
    List<String>? requiredPermissions,
    List<String>? actualPermissions,
    String? operation,
  ) {
    if (requiredPermissions == null &&
        actualPermissions == null &&
        operation == null) {
      return null;
    }
    final ctx = <String, dynamic>{};
    if (requiredPermissions != null) {
      ctx['requiredPermissions'] = requiredPermissions;
    }
    if (actualPermissions != null) ctx['actualPermissions'] = actualPermissions;
    if (operation != null) ctx['operation'] = operation;
    return ctx;
  }
}

// ============================================================================
// Token Errors
// ============================================================================

/// Token has expired (BA401)
class ExpiredTokenError extends BetterAuthError {
  ExpiredTokenError(
      {String? expiryTime, String? currentTime, String? tokenType})
      : super(
          'BA401',
          'Token has expired',
          _buildContext(expiryTime, currentTime, tokenType),
        );

  static Map<String, dynamic>? _buildContext(
    String? expiryTime,
    String? currentTime,
    String? tokenType,
  ) {
    if (expiryTime == null && currentTime == null && tokenType == null) {
      return null;
    }
    final ctx = <String, dynamic>{};
    if (expiryTime != null) ctx['expiryTime'] = expiryTime;
    if (currentTime != null) ctx['currentTime'] = currentTime;
    if (tokenType != null) ctx['tokenType'] = tokenType;
    return ctx;
  }
}

/// Token structure or format is invalid (BA402)
class InvalidTokenError extends BetterAuthError {
  InvalidTokenError({String? details})
      : super(
          'BA402',
          'Token structure or format is invalid',
          details != null ? {'details': details} : null,
        );
}

/// Token issued_at timestamp is in the future (BA403)
class FutureTokenError extends BetterAuthError {
  FutureTokenError({
    String? issuedAt,
    String? currentTime,
    double? timeDifference,
  }) : super(
          'BA403',
          'Token issued_at timestamp is in the future',
          _buildContext(issuedAt, currentTime, timeDifference),
        );

  static Map<String, dynamic>? _buildContext(
    String? issuedAt,
    String? currentTime,
    double? timeDifference,
  ) {
    if (issuedAt == null && currentTime == null && timeDifference == null) {
      return null;
    }
    final ctx = <String, dynamic>{};
    if (issuedAt != null) ctx['issuedAt'] = issuedAt;
    if (currentTime != null) ctx['currentTime'] = currentTime;
    if (timeDifference != null) ctx['timeDifference'] = timeDifference;
    return ctx;
  }
}

// ============================================================================
// Temporal Errors
// ============================================================================

/// Request timestamp is too old (BA501)
class StaleRequestError extends BetterAuthError {
  StaleRequestError({
    String? requestTimestamp,
    String? currentTime,
    int? maximumAge,
  }) : super(
          'BA501',
          'Request timestamp is too old',
          _buildContext(requestTimestamp, currentTime, maximumAge),
        );

  static Map<String, dynamic>? _buildContext(
    String? requestTimestamp,
    String? currentTime,
    int? maximumAge,
  ) {
    if (requestTimestamp == null && currentTime == null && maximumAge == null) {
      return null;
    }
    final ctx = <String, dynamic>{};
    if (requestTimestamp != null) ctx['requestTimestamp'] = requestTimestamp;
    if (currentTime != null) ctx['currentTime'] = currentTime;
    if (maximumAge != null) ctx['maximumAge'] = maximumAge;
    return ctx;
  }
}

/// Request timestamp is in the future (BA502)
class FutureRequestError extends BetterAuthError {
  FutureRequestError({
    String? requestTimestamp,
    String? currentTime,
    double? timeDifference,
  }) : super(
          'BA502',
          'Request timestamp is in the future',
          _buildContext(requestTimestamp, currentTime, timeDifference),
        );

  static Map<String, dynamic>? _buildContext(
    String? requestTimestamp,
    String? currentTime,
    double? timeDifference,
  ) {
    if (requestTimestamp == null &&
        currentTime == null &&
        timeDifference == null) {
      return null;
    }
    final ctx = <String, dynamic>{};
    if (requestTimestamp != null) ctx['requestTimestamp'] = requestTimestamp;
    if (currentTime != null) ctx['currentTime'] = currentTime;
    if (timeDifference != null) ctx['timeDifference'] = timeDifference;
    return ctx;
  }
}

/// Client and server clock difference exceeds tolerance (BA503)
class ClockSkewError extends BetterAuthError {
  ClockSkewError({
    String? clientTime,
    String? serverTime,
    double? timeDifference,
    double? maxTolerance,
  }) : super(
          'BA503',
          'Client and server clock difference exceeds tolerance',
          _buildContext(clientTime, serverTime, timeDifference, maxTolerance),
        );

  static Map<String, dynamic>? _buildContext(
    String? clientTime,
    String? serverTime,
    double? timeDifference,
    double? maxTolerance,
  ) {
    if (clientTime == null &&
        serverTime == null &&
        timeDifference == null &&
        maxTolerance == null) {
      return null;
    }
    final ctx = <String, dynamic>{};
    if (clientTime != null) ctx['clientTime'] = clientTime;
    if (serverTime != null) ctx['serverTime'] = serverTime;
    if (timeDifference != null) ctx['timeDifference'] = timeDifference;
    if (maxTolerance != null) ctx['maxTolerance'] = maxTolerance;
    return ctx;
  }
}

// ============================================================================
// Storage Errors
// ============================================================================

/// Resource not found (BA601)
class NotFoundError extends BetterAuthError {
  NotFoundError({String? resourceType, String? resourceIdentifier})
      : super(
          'BA601',
          _buildMessage(resourceType),
          _buildContext(resourceType, resourceIdentifier),
        );

  static String _buildMessage(String? resourceType) {
    if (resourceType == null) return 'Resource not found';
    return 'Resource not found: $resourceType';
  }

  static Map<String, dynamic>? _buildContext(
    String? resourceType,
    String? resourceIdentifier,
  ) {
    if (resourceType == null && resourceIdentifier == null) return null;
    final ctx = <String, dynamic>{};
    if (resourceType != null) ctx['resourceType'] = resourceType;
    if (resourceIdentifier != null) {
      ctx['resourceIdentifier'] = resourceIdentifier;
    }
    return ctx;
  }
}

/// Resource already exists (BA602)
class AlreadyExistsError extends BetterAuthError {
  AlreadyExistsError({String? resourceType, String? resourceIdentifier})
      : super(
          'BA602',
          _buildMessage(resourceType),
          _buildContext(resourceType, resourceIdentifier),
        );

  static String _buildMessage(String? resourceType) {
    if (resourceType == null) return 'Resource already exists';
    return 'Resource already exists: $resourceType';
  }

  static Map<String, dynamic>? _buildContext(
    String? resourceType,
    String? resourceIdentifier,
  ) {
    if (resourceType == null && resourceIdentifier == null) return null;
    final ctx = <String, dynamic>{};
    if (resourceType != null) ctx['resourceType'] = resourceType;
    if (resourceIdentifier != null) {
      ctx['resourceIdentifier'] = resourceIdentifier;
    }
    return ctx;
  }
}

/// Storage backend is unavailable (BA603)
class StorageUnavailableError extends BetterAuthError {
  StorageUnavailableError({
    String? backendType,
    String? connectionDetails,
    String? backendError,
  }) : super(
          'BA603',
          'Storage backend is unavailable',
          _buildContext(backendType, connectionDetails, backendError),
        );

  static Map<String, dynamic>? _buildContext(
    String? backendType,
    String? connectionDetails,
    String? backendError,
  ) {
    if (backendType == null &&
        connectionDetails == null &&
        backendError == null) {
      return null;
    }
    final ctx = <String, dynamic>{};
    if (backendType != null) ctx['backendType'] = backendType;
    if (connectionDetails != null) ctx['connectionDetails'] = connectionDetails;
    if (backendError != null) ctx['backendError'] = backendError;
    return ctx;
  }
}

/// Stored data is corrupted or invalid (BA604)
class StorageCorruptionError extends BetterAuthError {
  StorageCorruptionError({
    String? resourceType,
    String? resourceIdentifier,
    String? corruptionDetails,
  }) : super(
          'BA604',
          'Stored data is corrupted or invalid',
          _buildContext(resourceType, resourceIdentifier, corruptionDetails),
        );

  static Map<String, dynamic>? _buildContext(
    String? resourceType,
    String? resourceIdentifier,
    String? corruptionDetails,
  ) {
    if (resourceType == null &&
        resourceIdentifier == null &&
        corruptionDetails == null) {
      return null;
    }
    final ctx = <String, dynamic>{};
    if (resourceType != null) ctx['resourceType'] = resourceType;
    if (resourceIdentifier != null) {
      ctx['resourceIdentifier'] = resourceIdentifier;
    }
    if (corruptionDetails != null) ctx['corruptionDetails'] = corruptionDetails;
    return ctx;
  }
}

// ============================================================================
// Encoding Errors
// ============================================================================

/// Failed to serialize message (BA701)
class SerializationError extends BetterAuthError {
  SerializationError({String? messageType, String? format, String? details})
      : super(
          'BA701',
          'Failed to serialize message',
          _buildContext(messageType, format, details),
        );

  static Map<String, dynamic>? _buildContext(
    String? messageType,
    String? format,
    String? details,
  ) {
    if (messageType == null && format == null && details == null) return null;
    final ctx = <String, dynamic>{};
    if (messageType != null) ctx['messageType'] = messageType;
    if (format != null) ctx['format'] = format;
    if (details != null) ctx['details'] = details;
    return ctx;
  }
}

/// Failed to deserialize message (BA702)
class DeserializationError extends BetterAuthError {
  DeserializationError({String? messageType, String? rawData, String? details})
      : super(
          'BA702',
          'Failed to deserialize message',
          _buildContext(messageType, rawData, details),
        );

  static Map<String, dynamic>? _buildContext(
    String? messageType,
    String? rawData,
    String? details,
  ) {
    if (messageType == null && rawData == null && details == null) return null;
    final ctx = <String, dynamic>{};
    if (messageType != null) ctx['messageType'] = messageType;
    if (rawData != null) ctx['rawData'] = _truncateData(rawData);
    if (details != null) ctx['details'] = details;
    return ctx;
  }

  static String _truncateData(String s) =>
      s.length > 100 ? '${s.substring(0, 100)}...' : s;
}

/// Failed to compress or decompress data (BA703)
class CompressionError extends BetterAuthError {
  CompressionError({String? operation, int? dataSize, String? details})
      : super(
          'BA703',
          'Failed to compress or decompress data',
          _buildContext(operation, dataSize, details),
        );

  static Map<String, dynamic>? _buildContext(
    String? operation,
    int? dataSize,
    String? details,
  ) {
    if (operation == null && dataSize == null && details == null) return null;
    final ctx = <String, dynamic>{};
    if (operation != null) ctx['operation'] = operation;
    if (dataSize != null) ctx['dataSize'] = dataSize;
    if (details != null) ctx['details'] = details;
    return ctx;
  }
}

// ============================================================================
// Network Errors
// ============================================================================

/// Failed to connect to server (BA801)
class ConnectionError extends BetterAuthError {
  ConnectionError({String? serverUrl, String? details})
      : super(
          'BA801',
          'Failed to connect to server',
          _buildContext(serverUrl, details),
        );

  static Map<String, dynamic>? _buildContext(
      String? serverUrl, String? details) {
    if (serverUrl == null && details == null) return null;
    final ctx = <String, dynamic>{};
    if (serverUrl != null) ctx['serverUrl'] = serverUrl;
    if (details != null) ctx['details'] = details;
    return ctx;
  }
}

/// Request timed out (BA802)
class TimeoutError extends BetterAuthError {
  TimeoutError({int? timeoutDuration, String? endpoint})
      : super(
          'BA802',
          'Request timed out',
          _buildContext(timeoutDuration, endpoint),
        );

  static Map<String, dynamic>? _buildContext(
      int? timeoutDuration, String? endpoint) {
    if (timeoutDuration == null && endpoint == null) return null;
    final ctx = <String, dynamic>{};
    if (timeoutDuration != null) ctx['timeoutDuration'] = timeoutDuration;
    if (endpoint != null) ctx['endpoint'] = endpoint;
    return ctx;
  }
}

/// Invalid HTTP response or protocol violation (BA803)
class ProtocolError extends BetterAuthError {
  ProtocolError({int? httpStatusCode, String? details})
      : super(
          'BA803',
          'Invalid HTTP response or protocol violation',
          _buildContext(httpStatusCode, details),
        );

  static Map<String, dynamic>? _buildContext(
      int? httpStatusCode, String? details) {
    if (httpStatusCode == null && details == null) return null;
    final ctx = <String, dynamic>{};
    if (httpStatusCode != null) ctx['httpStatusCode'] = httpStatusCode;
    if (details != null) ctx['details'] = details;
    return ctx;
  }
}

// ============================================================================
// Protocol Errors
// ============================================================================

/// Operation not allowed in current state (BA901)
class InvalidStateError extends BetterAuthError {
  InvalidStateError({
    String? currentState,
    String? attemptedOperation,
    String? requiredState,
  }) : super(
          'BA901',
          'Operation not allowed in current state',
          _buildContext(currentState, attemptedOperation, requiredState),
        );

  static Map<String, dynamic>? _buildContext(
    String? currentState,
    String? attemptedOperation,
    String? requiredState,
  ) {
    if (currentState == null &&
        attemptedOperation == null &&
        requiredState == null) {
      return null;
    }
    final ctx = <String, dynamic>{};
    if (currentState != null) ctx['currentState'] = currentState;
    if (attemptedOperation != null) {
      ctx['attemptedOperation'] = attemptedOperation;
    }
    if (requiredState != null) ctx['requiredState'] = requiredState;
    return ctx;
  }
}

/// Key rotation failed (BA902)
class RotationError extends BetterAuthError {
  RotationError({String? rotationType, String? details})
      : super(
          'BA902',
          'Key rotation failed',
          _buildContext(rotationType, details),
        );

  static Map<String, dynamic>? _buildContext(
      String? rotationType, String? details) {
    if (rotationType == null && details == null) return null;
    final ctx = <String, dynamic>{};
    if (rotationType != null) ctx['rotationType'] = rotationType;
    if (details != null) ctx['details'] = details;
    return ctx;
  }
}

/// Account recovery failed (BA903)
class RecoveryError extends BetterAuthError {
  RecoveryError({String? details})
      : super(
          'BA903',
          'Account recovery failed',
          details != null ? {'details': details} : null,
        );
}

/// Device has been revoked (BA904)
class DeviceRevokedError extends BetterAuthError {
  DeviceRevokedError({String? deviceIdentifier, String? revocationTimestamp})
      : super(
          'BA904',
          'Device has been revoked',
          _buildContext(deviceIdentifier, revocationTimestamp),
        );

  static Map<String, dynamic>? _buildContext(
    String? deviceIdentifier,
    String? revocationTimestamp,
  ) {
    if (deviceIdentifier == null && revocationTimestamp == null) return null;
    final ctx = <String, dynamic>{};
    if (deviceIdentifier != null) ctx['deviceIdentifier'] = deviceIdentifier;
    if (revocationTimestamp != null) {
      ctx['revocationTimestamp'] = revocationTimestamp;
    }
    return ctx;
  }
}

/// Identity has been deleted (BA905)
class IdentityDeletedError extends BetterAuthError {
  IdentityDeletedError({String? identityIdentifier, String? deletionTimestamp})
      : super(
          'BA905',
          'Identity has been deleted',
          _buildContext(identityIdentifier, deletionTimestamp),
        );

  static Map<String, dynamic>? _buildContext(
    String? identityIdentifier,
    String? deletionTimestamp,
  ) {
    if (identityIdentifier == null && deletionTimestamp == null) return null;
    final ctx = <String, dynamic>{};
    if (identityIdentifier != null) {
      ctx['identityIdentifier'] = identityIdentifier;
    }
    if (deletionTimestamp != null) ctx['deletionTimestamp'] = deletionTimestamp;
    return ctx;
  }
}
