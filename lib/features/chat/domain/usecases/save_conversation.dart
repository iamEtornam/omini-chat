import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/conversation.dart';
import '../repositories/chat_repository.dart';

/// Use case for saving a conversation
class SaveConversation {
  final ChatRepository repository;

  SaveConversation(this.repository);

  Future<Either<Failure, void>> call(Conversation conversation) async {
    return await repository.saveConversation(conversation);
  }
}

