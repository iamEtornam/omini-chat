import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/message.dart';
import '../repositories/chat_repository.dart';

/// Parameters for sending a message
class SendMessageParams {
  final List<Message> conversationHistory;
  final String userMessage;

  const SendMessageParams({
    required this.conversationHistory,
    required this.userMessage,
  });
}

/// Use case for sending a message and getting a response
class SendMessage {
  final ChatRepository repository;

  SendMessage(this.repository);

  Future<Either<Failure, String>> call(SendMessageParams params) async {
    return await repository.generateResponse(
      conversationHistory: params.conversationHistory,
      userMessage: params.userMessage,
    );
  }
}

