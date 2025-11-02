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
