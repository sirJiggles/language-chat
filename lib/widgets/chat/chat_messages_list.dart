import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/chat_service.dart';
import '../../services/comprehensive_assessment_service.dart';
import '../../services/context_manager.dart';
import '../../models/settings_model.dart';
import 'chat_bubble.dart';
import 'thinking_dots.dart';

class ChatMessagesList extends StatelessWidget {
  final ScrollController scrollController;
  final bool botGreetingSent;
  final VoidCallback onScrollToBottom;

  const ChatMessagesList({
    super.key,
    required this.scrollController,
    required this.botGreetingSent,
    required this.onScrollToBottom,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer2<ChatService, SettingsModel>(
      builder: (context, chatService, settings, _) {
        final messages = chatService.conversationStore.messages;

        if (messages.isNotEmpty) {
          final thinkingMessages = messages.where((msg) => msg.isThinking).toList();
          final isThinking = thinkingMessages.isNotEmpty || chatService.isThinking;

          final visibleMessages = messages
              .where(
                (msg) =>
                    !msg.isThinking &&
                    !msg.content.contains('<thinking id=') &&
                    msg.content.isNotEmpty,
              )
              .toList();

          // Schedule a scroll to bottom after the UI updates
          WidgetsBinding.instance.addPostFrameCallback((_) {
            onScrollToBottom();
          });

          // Adjust bottom padding based on conversation mode
          final bottomPadding = settings.conversationMode ? 180.0 : 95.0;

          return ListView.builder(
            controller: scrollController,
            padding: EdgeInsets.only(
              top: kToolbarHeight + 40,
              left: 10.0,
              right: 10.0,
              bottom: bottomPadding,
            ),
            itemCount: isThinking ? visibleMessages.length + 1 : visibleMessages.length,
            itemBuilder: (context, index) {
              if (isThinking && index == visibleMessages.length) {
                return const ThinkingBubble();
              }

              final message = visibleMessages[index];
              final chatService = Provider.of<ChatService>(context, listen: false);

              // Get recent messages for context (last 5 messages before this one)
              final startIndex = (index - 5).clamp(0, index);
              final recentMessages = visibleMessages
                  .sublist(startIndex, index)
                  .map((m) => m.toString())
                  .toList();

              return ChatBubble(
                message: message.content,
                isUser: message.isUser,
                targetLanguage: chatService.targetLanguage,
                recentMessages: recentMessages.isNotEmpty ? recentMessages : null,
                onClarificationRequested: message.isUser
                    ? null
                    : () {
                        // Track clarification request for bot messages
                        final assessmentService = Provider.of<ComprehensiveAssessmentService>(
                          context,
                          listen: false,
                        );
                        final sessionId = assessmentService.currentSessionId;
                        assessmentService.incrementClarificationCount(sessionId);
                      },
              );
            },
          );
        } else {
          return Consumer<ContextManager>(
            builder: (context, contextManager, _) {
              if (!botGreetingSent) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const ThinkingDots(),
                      const SizedBox(height: 16),
                      Text(
                        'Starting conversation...',
                        style: TextStyle(
                          fontSize: 16.0,
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          );
        }
      },
    );
  }
}

class ThinkingBubble extends StatelessWidget {
  const ThinkingBubble({super.key});

  @override
  Widget build(BuildContext context) {
    return const Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: EdgeInsets.only(left: 10, bottom: 10, top: 10),
        child: ThinkingDots(),
      ),
    );
  }
}
