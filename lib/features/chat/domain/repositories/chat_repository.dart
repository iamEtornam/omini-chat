import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/conversation.dart';
import '../entities/message.dart';
import '../entities/model_info.dart';

/// Repository interface for chat operations
abstract class ChatRepository {
  /// Initialize the AI model
  Future<Either<Failure, void>> initializeModel();

  /// Generate a response to a message
  Future<Either<Failure, String>> generateResponse({
    required List<Message> conversationHistory,
    required String userMessage,
  });

  /// Get the current model information
  Future<Either<Failure, ModelInfo>> getModelInfo();

  /// Save a conversation
  Future<Either<Failure, void>> saveConversation(Conversation conversation);

  /// Get all conversations
  Future<Either<Failure, List<Conversation>>> getConversations();

  /// Get a specific conversation
  Future<Either<Failure, Conversation>> getConversation(String id);

  /// Delete a conversation
  Future<Either<Failure, void>> deleteConversation(String id);

  /// Get the active conversation ID
  Future<Either<Failure, String?>> getActiveConversationId();

  /// Set the active conversation ID
  Future<Either<Failure, void>> setActiveConversationId(String id);

  /// Check if model is ready
  Future<Either<Failure, bool>> isModelReady();
}
