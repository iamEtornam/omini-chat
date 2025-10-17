/// Base class for all exceptions in the application
class AppException implements Exception {
  final String message;

  AppException(this.message);

  @override
  String toString() => message;
}

/// Exception when model operations fail
class ModelException extends AppException {
  ModelException(super.message);
}

/// Exception when cache operations fail
class CacheException extends AppException {
  CacheException(super.message);
}

/// Exception when network operations fail
class NetworkException extends AppException {
  NetworkException(super.message);
}

/// Exception when validation fails
class ValidationException extends AppException {
  ValidationException(super.message);
}

