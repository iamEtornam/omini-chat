import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../models/conversation_model.dart';

/// Data source for local storage operations
abstract class LocalDataSource {
  Future<void> saveConversation(ConversationModel conversation);
  Future<List<ConversationModel>> getConversations();
  Future<ConversationModel?> getConversation(String id);
  Future<void> deleteConversation(String id);
  Future<String?> getActiveConversationId();
  Future<void> setActiveConversationId(String id);
}

class LocalDataSourceImpl implements LocalDataSource {
  final SharedPreferences sharedPreferences;

  LocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<void> saveConversation(ConversationModel conversation) async {
    try {
      // Get existing conversations
      final conversations = await getConversations();

      // Update or add the conversation
      final index = conversations.indexWhere((c) => c.id == conversation.id);
      if (index >= 0) {
        conversations[index] = conversation;
      } else {
        conversations.add(conversation);
      }

      // Save back to storage
      final jsonList =
          conversations.map((c) => json.encode(c.toJson())).toList();
      await sharedPreferences.setStringList(
        AppConstants.chatHistoryKey,
        jsonList,
      );
    } catch (e) {
      throw CacheException('Failed to save conversation: $e');
    }
  }

  @override
  Future<List<ConversationModel>> getConversations() async {
    try {
      final jsonList =
          sharedPreferences.getStringList(AppConstants.chatHistoryKey);
      if (jsonList == null) {
        return [];
      }

      return jsonList.map((jsonStr) {
        final jsonMap = json.decode(jsonStr) as Map<String, dynamic>;
        return ConversationModel.fromJson(jsonMap);
      }).toList();
    } catch (e) {
      throw CacheException('Failed to get conversations: $e');
    }
  }

  @override
  Future<ConversationModel?> getConversation(String id) async {
    try {
      final conversations = await getConversations();
      return conversations.cast<ConversationModel?>().firstWhere(
            (c) => c?.id == id,
            orElse: () => null,
          );
    } catch (e) {
      throw CacheException('Failed to get conversation: $e');
    }
  }

  @override
  Future<void> deleteConversation(String id) async {
    try {
      final conversations = await getConversations();
      conversations.removeWhere((c) => c.id == id);

      final jsonList =
          conversations.map((c) => json.encode(c.toJson())).toList();
      await sharedPreferences.setStringList(
        AppConstants.chatHistoryKey,
        jsonList,
      );
    } catch (e) {
      throw CacheException('Failed to delete conversation: $e');
    }
  }

  @override
  Future<String?> getActiveConversationId() async {
    try {
      return sharedPreferences.getString(AppConstants.activeConversationKey);
    } catch (e) {
      throw CacheException('Failed to get active conversation ID: $e');
    }
  }

  @override
  Future<void> setActiveConversationId(String id) async {
    try {
      await sharedPreferences.setString(
        AppConstants.activeConversationKey,
        id,
      );
    } catch (e) {
      throw CacheException('Failed to set active conversation ID: $e');
    }
  }
}

