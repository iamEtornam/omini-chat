import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/chat_repository.dart';

/// Use case for initializing the AI model
class InitializeModel {
  final ChatRepository repository;

  InitializeModel(this.repository);

  Future<Either<Failure, void>> call() async {
    return await repository.initializeModel();
  }
}

