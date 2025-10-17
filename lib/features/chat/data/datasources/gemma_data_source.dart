import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_gemma/flutter_gemma.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/utils/logger.dart';
import '../../domain/entities/message.dart' as domain;

/// Data source for interacting with the Gemma AI model
abstract class GemmaDataSource {
  Future<void> initialize();
  Future<String> generateResponse({
    required List<domain.Message> conversationHistory,
    required String userMessage,
  });
  Future<bool> isModelReady();
}

class GemmaDataSourceImpl implements GemmaDataSource {
  InferenceModel? _model;
  InferenceChat? _chat;

  @override
  Future<void> initialize() async {
    try {
      Logger.log('Starting model initialization...');
      Logger.log('Platform: ${kIsWeb ? "Web" : "Mobile"}');

      // Initialize Flutter Gemma
      FlutterGemma.initialize();
      Logger.log('FlutterGemma initialized');

      // Always install/register the model to set it as active
      // This is required even if the file exists
      Logger.log(
        'Installing model from bundled: ${AppConstants.modelFileName}',
      );

      await FlutterGemma.installModel(
        modelType: ModelType.gemmaIt,
        fileType: ModelFileType.task,
      ).fromBundled(AppConstants.modelFileName).install();
      Logger.log('Model installed and set as active');

      Logger.log('Creating model with maxTokens: ${AppConstants.maxTokens}');
      // Create model with configuration
      _model = await FlutterGemma.getActiveModel(
        maxTokens: AppConstants.maxTokens,
        preferredBackend: PreferredBackend.gpu,
      );
      Logger.log('Model created successfully');

      Logger.log('Creating chat session...');
      // Create chat session with optimal settings for Gemma 3 1B
      _chat = await _model!.createChat(
        temperature: AppConstants.temperature,
        topK: AppConstants.topK,
        topP: AppConstants.topP,
      );
      Logger.log('Chat session created successfully');
    } catch (e, stackTrace) {
      Logger.error(
        'Failed to initialize model',
        error: e,
        stackTrace: stackTrace,
      );

      throw ModelException('Failed to initialize model: $e');
    }
  }

  @override
  Future<String> generateResponse({
    required List<domain.Message> conversationHistory,
    required String userMessage,
  }) async {
    try {
      if (_chat == null || _model == null) {
        throw ModelException('Model not initialized');
      }

      // Create message
      final queryMessage = Message(text: userMessage, isUser: true);

      // Add the user message to the chat
      await _chat!.addQuery(queryMessage);

      // Generate response using async streaming
      final responseStream = _chat!.generateChatResponseAsync();
      final StringBuffer responseBuffer = StringBuffer();

      await for (final response in responseStream) {
        if (response is TextResponse) {
          responseBuffer.write(response.token);
        } else if (response is FunctionCallResponse) {
          // For now, return a message about function calls
          return 'Function call requested: ${response.name}';
        }
      }

      final finalResponse = responseBuffer.toString();
      return finalResponse.isNotEmpty ? finalResponse : 'No response generated';
    } catch (e) {
      throw ModelException('Failed to generate response: $e');
    }
  }

  @override
  Future<bool> isModelReady() async {
    try {
      return await FlutterGemma.isModelInstalled(AppConstants.modelFileName);
    } catch (e) {
      return false;
    }
  }
}
