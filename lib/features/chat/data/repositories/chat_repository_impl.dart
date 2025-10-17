import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/conversation.dart';
import '../../domain/entities/message.dart';
import '../../domain/entities/model_info.dart';
import '../../domain/repositories/chat_repository.dart';
import '../datasources/gemma_data_source.dart';
import '../datasources/local_data_source.dart';
import '../models/conversation_model.dart';

/// Implementation of the chat repository
class ChatRepositoryImpl implements ChatRepository {
  final GemmaDataSource gemmaDataSource;
  final LocalDataSource localDataSource;

  ChatRepositoryImpl({
    required this.gemmaDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, void>> initializeModel() async {
    try {
      await gemmaDataSource.initialize();
      return const Right(null);
    } on ModelException catch (e) {
      return Left(ModelInitializationFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> generateResponse({
    required List<Message> conversationHistory,
    required String userMessage,
  }) async {
    try {
      final response = await gemmaDataSource.generateResponse(
        conversationHistory: conversationHistory,
        userMessage: userMessage,
      );
      return Right(response);
    } on ModelException catch (e) {
      return Left(MessageGenerationFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ModelInfo>> getModelInfo() async {
    try {
      final isReady = await gemmaDataSource.isModelReady();
      return Right(
        ModelInfo(
          name: 'Gemma 3 1B',
          status: isReady ? ModelStatus.ready : ModelStatus.notLoaded,
        ),
      );
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> saveConversation(
    Conversation conversation,
  ) async {
    try {
      final model = ConversationModel.fromEntity(conversation);
      await localDataSource.saveConversation(model);
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Conversation>>> getConversations() async {
    try {
      final models = await localDataSource.getConversations();
      final conversations = models.map((m) => m.toEntity()).toList();
      // Sort by updated date, newest first
      conversations.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      return Right(conversations);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Conversation>> getConversation(String id) async {
    try {
      final model = await localDataSource.getConversation(id);
      if (model == null) {
        return const Left(CacheFailure('Conversation not found'));
      }
      return Right(model.toEntity());
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteConversation(String id) async {
    try {
      await localDataSource.deleteConversation(id);
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String?>> getActiveConversationId() async {
    try {
      final id = await localDataSource.getActiveConversationId();
      return Right(id);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> setActiveConversationId(String id) async {
    try {
      await localDataSource.setActiveConversationId(id);
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> isModelReady() async {
    try {
      final isReady = await gemmaDataSource.isModelReady();
      return Right(isReady);
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }
}
