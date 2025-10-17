import 'package:equatable/equatable.dart';

/// Message entity representing a chat message
class Message extends Equatable {
  final String id;
  final String content;
  final bool isUser;
  final DateTime timestamp;
  final MessageStatus status;
  final String? imagePath; // Path to image file if message contains an image

  const Message({
    required this.id,
    required this.content,
    required this.isUser,
    required this.timestamp,
    this.status = MessageStatus.sent,
    this.imagePath,
  });

  /// Create a user message
  factory Message.user({
    required String id,
    required String content,
    String? imagePath,
  }) {
    return Message(
      id: id,
      content: content,
      isUser: true,
      timestamp: DateTime.now(),
      status: MessageStatus.sent,
      imagePath: imagePath,
    );
  }

  /// Create an AI message
  factory Message.ai({
    required String id,
    required String content,
    MessageStatus status = MessageStatus.sent,
  }) {
    return Message(
      id: id,
      content: content,
      isUser: false,
      timestamp: DateTime.now(),
      status: status,
    );
  }

  /// Create a loading message
  factory Message.loading({required String id}) {
    return Message(
      id: id,
      content: '',
      isUser: false,
      timestamp: DateTime.now(),
      status: MessageStatus.loading,
    );
  }

  /// Copy with new values
  Message copyWith({
    String? id,
    String? content,
    bool? isUser,
    DateTime? timestamp,
    MessageStatus? status,
    String? imagePath,
  }) {
    return Message(
      id: id ?? this.id,
      content: content ?? this.content,
      isUser: isUser ?? this.isUser,
      timestamp: timestamp ?? this.timestamp,
      status: status ?? this.status,
      imagePath: imagePath ?? this.imagePath,
    );
  }

  @override
  List<Object?> get props => [
    id,
    content,
    isUser,
    timestamp,
    status,
    imagePath,
  ];
}

/// Message status
enum MessageStatus { sending, sent, loading, error }
