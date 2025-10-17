import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/conversation.dart';
import 'message_model.dart';

part 'conversation_model.g.dart';

/// Conversation model for data serialization
@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class ConversationModel {
  final String id;
  final String title;
  final List<MessageModel> messages;
  @JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson)
  final DateTime createdAt;
  @JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson)
  final DateTime updatedAt;

  const ConversationModel({
    required this.id,
    required this.title,
    required this.messages,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Convert from domain entity
  factory ConversationModel.fromEntity(Conversation conversation) {
    return ConversationModel(
      id: conversation.id,
      title: conversation.title,
      messages:
          conversation.messages.map((m) => MessageModel.fromEntity(m)).toList(),
      createdAt: conversation.createdAt,
      updatedAt: conversation.updatedAt,
    );
  }

  /// Convert to domain entity
  Conversation toEntity() {
    return Conversation(
      id: id,
      title: title,
      messages: messages.map((m) => m.toEntity()).toList(),
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  factory ConversationModel.fromJson(Map<String, dynamic> json) =>
      _$ConversationModelFromJson(json);

  Map<String, dynamic> toJson() => _$ConversationModelToJson(this);

  static DateTime _dateTimeFromJson(String date) => DateTime.parse(date);
  static String _dateTimeToJson(DateTime date) => date.toIso8601String();
}

