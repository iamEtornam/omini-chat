import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/conversation.dart';
import '../../domain/entities/message.dart';
import '../../domain/entities/model_info.dart';
import '../../domain/usecases/send_message.dart';
import 'chat_providers.dart';

/// State for chat
class ChatState {
  final Conversation? currentConversation;
  final List<Conversation> conversations;
  final ModelInfo modelInfo;
  final bool isLoading;
  final String? error;
  final bool isGenerating;

  const ChatState({
    this.currentConversation,
    this.conversations = const [],
    required this.modelInfo,
    this.isLoading = false,
    this.error,
    this.isGenerating = false,
  });

  ChatState copyWith({
    Conversation? currentConversation,
    List<Conversation>? conversations,
    ModelInfo? modelInfo,
    bool? isLoading,
    String? error,
    bool? isGenerating,
  }) {
    return ChatState(
      currentConversation: currentConversation ?? this.currentConversation,
      conversations: conversations ?? this.conversations,
      modelInfo: modelInfo ?? this.modelInfo,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isGenerating: isGenerating ?? this.isGenerating,
    );
  }
}

/// Chat state notifier
class ChatStateNotifier extends StateNotifier<ChatState> {
  final Ref ref;

  ChatStateNotifier(this.ref)
    : super(
        const ChatState(
          modelInfo: ModelInfo(
            name: 'Gemma 3 1B',
            status: ModelStatus.notLoaded,
          ),
        ),
      );

  /// Initialize the app
  Future<void> initialize() async {
    state = state.copyWith(isLoading: true, error: null);

    // Check model status
    final modelInfoResult = await ref
        .read(chatRepositoryProvider)
        .getModelInfo();

    modelInfoResult.fold(
      (failure) {
        state = state.copyWith(isLoading: false, error: failure.message);
      },
      (modelInfo) async {
        state = state.copyWith(modelInfo: modelInfo);

        // If model is ready, initialize it, otherwise load it
        if (modelInfo.status == ModelStatus.ready) {
          await _initializeModel();
        } else {
          // Model not loaded, initialize it (will load from assets)
          await _initializeModel();
        }

        // Load conversations
        await _loadConversations();

        state = state.copyWith(isLoading: false);
      },
    );
  }

  /// Initialize the model
  Future<void> _initializeModel() async {
    // Show loading status
    state = state.copyWith(
      modelInfo: state.modelInfo.copyWith(status: ModelStatus.loading),
    );

    final result = await ref.read(initializeModelUseCaseProvider).call();

    result.fold(
      (failure) {
        state = state.copyWith(
          modelInfo: state.modelInfo.copyWith(status: ModelStatus.error),
          error: failure.message,
        );
      },
      (_) {
        state = state.copyWith(
          modelInfo: state.modelInfo.copyWith(status: ModelStatus.ready),
        );
      },
    );
  }

  /// Load conversations
  Future<void> _loadConversations() async {
    final result = await ref.read(getConversationsUseCaseProvider).call();

    result.fold(
      (failure) {
        state = state.copyWith(error: failure.message);
      },
      (conversations) {
        state = state.copyWith(conversations: conversations);

        // Load active conversation if exists
        _loadActiveConversation();
      },
    );
  }

  /// Load active conversation
  Future<void> _loadActiveConversation() async {
    final activeIdResult = await ref
        .read(chatRepositoryProvider)
        .getActiveConversationId();

    activeIdResult.fold((failure) {}, (activeId) {
      if (activeId != null) {
        final conversation = state.conversations
            .cast<Conversation?>()
            .firstWhere((c) => c?.id == activeId, orElse: () => null);
        if (conversation != null) {
          state = state.copyWith(currentConversation: conversation);
        }
      }
    });
  }

  /// Create a new conversation
  Future<void> createNewConversation() async {
    final newConversation = Conversation.create(
      id: const Uuid().v4(),
      title: 'New Conversation',
    );

    state = state.copyWith(currentConversation: newConversation);

    // Save and set as active
    await ref.read(saveConversationUseCaseProvider).call(newConversation);
    await ref
        .read(chatRepositoryProvider)
        .setActiveConversationId(newConversation.id);

    // Reload conversations
    await _loadConversations();
  }

  /// Switch to a conversation
  Future<void> switchConversation(String conversationId) async {
    final conversation = state.conversations.cast<Conversation?>().firstWhere(
      (c) => c?.id == conversationId,
      orElse: () => null,
    );

    if (conversation != null) {
      state = state.copyWith(currentConversation: conversation);
      await ref
          .read(chatRepositoryProvider)
          .setActiveConversationId(conversationId);
    }
  }

  /// Send a message
  Future<void> sendMessage(String content, {String? imagePath}) async {
    if (state.currentConversation == null) {
      await createNewConversation();
    }

    if (state.modelInfo.status != ModelStatus.ready) {
      state = state.copyWith(error: 'Model is not ready');
      return;
    }

    // Create user message
    final userMessage = Message.user(
      id: const Uuid().v4(),
      content: content,
      imagePath: imagePath,
    );

    // Add user message to conversation
    var updatedConversation = state.currentConversation!.addMessage(
      userMessage,
    );

    // Update title if it's the first message
    if (updatedConversation.messages.length == 1) {
      final title = content.length > 30
          ? '${content.substring(0, 30)}...'
          : content;
      updatedConversation = updatedConversation.copyWith(title: title);
    }

    state = state.copyWith(
      currentConversation: updatedConversation,
      isGenerating: true,
      error: null,
    );

    // Save conversation
    await ref.read(saveConversationUseCaseProvider).call(updatedConversation);

    // Create loading message
    final loadingMessageId = const Uuid().v4();
    final loadingMessage = Message.loading(id: loadingMessageId);
    updatedConversation = updatedConversation.addMessage(loadingMessage);

    state = state.copyWith(currentConversation: updatedConversation);

    // Generate response
    final result = await ref
        .read(sendMessageUseCaseProvider)
        .call(
          SendMessageParams(
            conversationHistory: updatedConversation.messages
                .where((m) => m.status != MessageStatus.loading)
                .toList(),
            userMessage: content,
          ),
        );

    result.fold(
      (failure) {
        // Remove loading message and show error
        updatedConversation = updatedConversation.removeMessage(
          loadingMessageId,
        );

        final errorMessage = Message.ai(
          id: const Uuid().v4(),
          content: 'Error: ${failure.message}',
          status: MessageStatus.error,
        );

        updatedConversation = updatedConversation.addMessage(errorMessage);

        state = state.copyWith(
          currentConversation: updatedConversation,
          isGenerating: false,
          error: failure.message,
        );
      },
      (response) async {
        // Replace loading message with actual response
        final aiMessage = Message.ai(id: loadingMessageId, content: response);

        updatedConversation = updatedConversation.updateMessage(
          loadingMessageId,
          aiMessage,
        );

        state = state.copyWith(
          currentConversation: updatedConversation,
          isGenerating: false,
        );

        // Save conversation
        await ref
            .read(saveConversationUseCaseProvider)
            .call(updatedConversation);

        // Reload conversations to update the list
        await _loadConversations();
      },
    );
  }

  /// Delete a conversation
  Future<void> deleteConversation(String conversationId) async {
    final result = await ref
        .read(chatRepositoryProvider)
        .deleteConversation(conversationId);

    result.fold(
      (failure) {
        state = state.copyWith(error: failure.message);
      },
      (_) async {
        // If we deleted the current conversation, clear it
        if (state.currentConversation?.id == conversationId) {
          state = state.copyWith(currentConversation: null);
        }

        // Reload conversations
        await _loadConversations();
      },
    );
  }
}

/// Provider for chat state
final chatStateProvider = StateNotifierProvider<ChatStateNotifier, ChatState>((
  ref,
) {
  return ChatStateNotifier(ref);
});
