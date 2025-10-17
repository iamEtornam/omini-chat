import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/message.dart';

part 'message_model.g.dart';

/// Message model for data serialization
@JsonSerializable(fieldRename: FieldRename.snake)
class MessageModel {
  final String id;
  final String content;
  final bool isUser;
  @JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson)
  final DateTime timestamp;
  final String status;
  final String? imagePath;

  const MessageModel({
    required this.id,
    required this.content,
    required this.isUser,
    required this.timestamp,
    required this.status,
    this.imagePath,
  });

  /// Convert from domain entity
  factory MessageModel.fromEntity(Message message) {
    return MessageModel(
      id: message.id,
      content: message.content,
      isUser: message.isUser,
      timestamp: message.timestamp,
      status: message.status.name,
      imagePath: message.imagePath,
    );
  }

  /// Convert to domain entity
  Message toEntity() {
    return Message(
      id: id,
      content: content,
      isUser: isUser,
      timestamp: timestamp,
      status: _statusFromString(status),
      imagePath: imagePath,
    );
  }

  factory MessageModel.fromJson(Map<String, dynamic> json) =>
      _$MessageModelFromJson(json);

  Map<String, dynamic> toJson() => _$MessageModelToJson(this);

  static DateTime _dateTimeFromJson(String date) => DateTime.parse(date);
  static String _dateTimeToJson(DateTime date) => date.toIso8601String();

  static MessageStatus _statusFromString(String status) {
    switch (status) {
      case 'sending':
        return MessageStatus.sending;
      case 'sent':
        return MessageStatus.sent;
      case 'loading':
        return MessageStatus.loading;
      case 'error':
        return MessageStatus.error;
      default:
        return MessageStatus.sent;
    }
  }
}
