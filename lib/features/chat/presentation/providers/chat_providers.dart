import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/datasources/gemma_data_source.dart';
import '../../data/datasources/local_data_source.dart';
import '../../data/repositories/chat_repository_impl.dart';
import '../../domain/repositories/chat_repository.dart';
import '../../domain/usecases/get_conversations.dart';
import '../../domain/usecases/initialize_model.dart';
import '../../domain/usecases/save_conversation.dart';
import '../../domain/usecases/send_message.dart';

/// Provider for SharedPreferences
final sharedPreferencesProvider = FutureProvider<SharedPreferences>((
  ref,
) async {
  return await SharedPreferences.getInstance();
});

/// Provider for Gemma data source
final gemmaDataSourceProvider = Provider<GemmaDataSource>((ref) {
  return GemmaDataSourceImpl();
});

/// Provider for local data source
final localDataSourceProvider = Provider<LocalDataSource>((ref) {
  final sharedPreferences = ref.watch(sharedPreferencesProvider).asData?.value;
  if (sharedPreferences == null) {
    throw Exception('SharedPreferences not initialized');
  }
  return LocalDataSourceImpl(sharedPreferences: sharedPreferences);
});

/// Provider for chat repository
final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  return ChatRepositoryImpl(
    gemmaDataSource: ref.watch(gemmaDataSourceProvider),
    localDataSource: ref.watch(localDataSourceProvider),
  );
});

/// Provider for initialize model use case
final initializeModelUseCaseProvider = Provider<InitializeModel>((ref) {
  return InitializeModel(ref.watch(chatRepositoryProvider));
});

/// Provider for send message use case
final sendMessageUseCaseProvider = Provider<SendMessage>((ref) {
  return SendMessage(ref.watch(chatRepositoryProvider));
});

/// Provider for get conversations use case
final getConversationsUseCaseProvider = Provider<GetConversations>((ref) {
  return GetConversations(ref.watch(chatRepositoryProvider));
});

/// Provider for save conversation use case
final saveConversationUseCaseProvider = Provider<SaveConversation>((ref) {
  return SaveConversation(ref.watch(chatRepositoryProvider));
});
