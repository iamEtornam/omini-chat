import 'dart:developer' show log;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/model_info.dart';
import '../providers/chat_state_provider.dart';
import '../widgets/conversation_list_item.dart';
import '../widgets/message_bubble.dart';
import '../widgets/message_input.dart';

/// Main chat page
class ChatPage extends ConsumerStatefulWidget {
  const ChatPage({super.key});

  @override
  ConsumerState<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends ConsumerState<ChatPage> {
  final _scrollController = ScrollController();
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    // Initialize on first load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      log('ChatPage: Initializing...');
      ref.read(chatStateProvider.notifier).initialize();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final chatState = ref.read(chatStateProvider);
    log('chatState: ${chatState.modelInfo.status}');
    log('chatState: ${chatState.modelInfo.name}');
    if (chatState.error != null) {
      log('Error: ${chatState.error}');
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(chatStateProvider);
    final theme = Theme.of(context);

    // Auto-scroll when new messages arrive
    if (chatState.currentConversation != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
    }
    log('chatState: ${chatState.modelInfo.status}');
    log('chatState: ${chatState.modelInfo.name}');

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(chatState.currentConversation?.title ?? 'Omini Chat'),
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              ref.read(chatStateProvider.notifier).createNewConversation();
            },
          ),
        ],
      ),
      drawer: _buildDrawer(chatState, theme),
      body: Column(
        children: [
          if (chatState.modelInfo.status == ModelStatus.loading)
            Container(
              width: double.infinity,
              color: theme.colorScheme.primaryContainer,
              padding: const EdgeInsets.all(12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Loading AI model...',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                ],
              ),
            )
          else if (chatState.error != null)
            Container(
              width: double.infinity,
              color: theme.colorScheme.errorContainer,
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.error_outline,
                        color: theme.colorScheme.onErrorContainer,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          chatState.error!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onErrorContainer,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          ref.read(chatStateProvider.notifier).initialize();
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: theme.colorScheme.onErrorContainer,
                        ),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Check console logs for details. Ensure model file is in assets/ folder.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onErrorContainer.withValues(
                        alpha: 0.8,
                      ),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          Expanded(child: _buildChatArea(chatState, theme)),
          MessageInput(
            onSend: (message, {String? imagePath}) {
              ref
                  .read(chatStateProvider.notifier)
                  .sendMessage(message, imagePath: imagePath);
            },
            isEnabled:
                chatState.modelInfo.status == ModelStatus.ready &&
                !chatState.isGenerating,
            supportsImages: !kIsWeb,
          ),
        ],
      ),
    );
  }

  Widget _buildDrawer(ChatState chatState, ThemeData theme) {
    return Drawer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Icon(
                  Icons.chat_bubble_outline,
                  size: 48,
                  color: theme.colorScheme.onPrimaryContainer,
                ),
                const SizedBox(height: 8),
                Text(
                  'Omini Chat',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: theme.colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Powered by ${chatState.modelInfo.name}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: FilledButton.icon(
              onPressed: () {
                Navigator.of(context).pop();
                ref.read(chatStateProvider.notifier).createNewConversation();
              },
              icon: const Icon(Icons.add),
              label: const Text('New Conversation'),
            ),
          ),
          const Divider(),
          Expanded(
            child: chatState.conversations.isEmpty
                ? Center(
                    child: Text(
                      'No conversations yet',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  )
                : ListView.builder(
                    itemCount: chatState.conversations.length,
                    itemBuilder: (context, index) {
                      final conversation = chatState.conversations[index];
                      final isSelected =
                          chatState.currentConversation?.id == conversation.id;

                      return ConversationListItem(
                        conversation: conversation,
                        isSelected: isSelected,
                        onTap: () {
                          Navigator.of(context).pop();
                          ref
                              .read(chatStateProvider.notifier)
                              .switchConversation(conversation.id);
                        },
                        onDelete: () {
                          ref
                              .read(chatStateProvider.notifier)
                              .deleteConversation(conversation.id);
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatArea(ChatState chatState, ThemeData theme) {
    if (chatState.currentConversation == null ||
        chatState.currentConversation!.messages.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.chat_bubble_outline,
              size: 64,
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'Start a conversation',
              style: theme.textTheme.titleLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Type a message below to begin',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(vertical: 16),
      itemCount: chatState.currentConversation!.messages.length,
      itemBuilder: (context, index) {
        final message = chatState.currentConversation!.messages[index];
        return MessageBubble(message: message);
      },
    );
  }
}
