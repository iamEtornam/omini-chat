import 'package:equatable/equatable.dart';
import 'message.dart';

/// Conversation entity representing a chat session
class Conversation extends Equatable {
  final String id;
  final String title;
  final List<Message> messages;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Conversation({
    required this.id,
    required this.title,
    required this.messages,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Create a new conversation
  factory Conversation.create({
    required String id,
    String title = 'New Conversation',
  }) {
    final now = DateTime.now();
    return Conversation(
      id: id,
      title: title,
      messages: const [],
      createdAt: now,
      updatedAt: now,
    );
  }

  /// Copy with new values
  Conversation copyWith({
    String? id,
    String? title,
    List<Message>? messages,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Conversation(
      id: id ?? this.id,
      title: title ?? this.title,
      messages: messages ?? this.messages,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Add a message to the conversation
  Conversation addMessage(Message message) {
    return copyWith(
      messages: [...messages, message],
      updatedAt: DateTime.now(),
    );
  }

  /// Update a message in the conversation
  Conversation updateMessage(String messageId, Message updatedMessage) {
    final updatedMessages = messages.map((msg) {
      return msg.id == messageId ? updatedMessage : msg;
    }).toList();

    return copyWith(
      messages: updatedMessages,
      updatedAt: DateTime.now(),
    );
  }

  /// Remove a message from the conversation
  Conversation removeMessage(String messageId) {
    return copyWith(
      messages: messages.where((msg) => msg.id != messageId).toList(),
      updatedAt: DateTime.now(),
    );
  }

  /// Get the last message
  Message? get lastMessage {
    return messages.isEmpty ? null : messages.last;
  }

  @override
  List<Object?> get props => [id, title, messages, createdAt, updatedAt];
}

