import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/conversation.dart';
import '../repositories/chat_repository.dart';

/// Use case for getting all conversations
class GetConversations {
  final ChatRepository repository;

  GetConversations(this.repository);

  Future<Either<Failure, List<Conversation>>> call() async {
    return await repository.getConversations();
  }
}

