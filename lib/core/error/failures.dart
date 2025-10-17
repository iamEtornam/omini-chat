import 'package:equatable/equatable.dart';

/// Base class for all failures in the application
abstract class Failure extends Equatable {
  final String message;

  const Failure(this.message);

  @override
  List<Object> get props => [message];
}

/// Failure when the model is not initialized
class ModelNotInitializedFailure extends Failure {
  const ModelNotInitializedFailure([
    super.message = 'Model is not initialized',
  ]);
}

/// Failure when model download fails
class ModelDownloadFailure extends Failure {
  const ModelDownloadFailure([super.message = 'Failed to download model']);
}

/// Failure when model initialization fails
class ModelInitializationFailure extends Failure {
  const ModelInitializationFailure([
    super.message = 'Failed to initialize model',
  ]);
}

/// Failure when message generation fails
class MessageGenerationFailure extends Failure {
  const MessageGenerationFailure([
    super.message = 'Failed to generate message',
  ]);
}

/// Failure when local storage operation fails
class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Cache operation failed']);
}

/// Failure when network operation fails
class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'Network error occurred']);
}

/// Failure when validation fails
class ValidationFailure extends Failure {
  const ValidationFailure([super.message = 'Validation failed']);
}

/// Failure when an unknown error occurs
class UnknownFailure extends Failure {
  const UnknownFailure([super.message = 'An unknown error occurred']);
}
