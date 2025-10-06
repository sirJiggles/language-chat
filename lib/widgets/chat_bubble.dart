import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/settings_model.dart';
import '../services/tts_service.dart';
import '../services/word_definition_service.dart';
import '../services/clarification_service.dart';
import 'selectable_word_text.dart';

class ChatBubble extends StatelessWidget {
  final String message;
  final bool isUser;
  final String? targetLanguage;
  final VoidCallback? onClarificationRequested;
  final List<String>? recentMessages; // For context in clarification

  const ChatBubble({
    super.key, 
    required this.message, 
    required this.isUser,
    this.targetLanguage,
    this.onClarificationRequested,
    this.recentMessages,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4.0),
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
        decoration: BoxDecoration(
          color: isUser
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.secondary,
          borderRadius: BorderRadius.circular(20.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Use selectable word text for bot messages, regular text for user messages
            isUser
                ? Text(
                    message,
                    style: TextStyle(color: Theme.of(context).colorScheme.onPrimary, fontSize: 13),
                  )
                : Consumer<WordDefinitionService>(
                    builder: (context, definitionService, _) {
                      return SelectableWordText(
                        text: message,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSecondary,
                          fontSize: 13,
                        ),
                        definitionService: definitionService,
                      );
                    },
                  ),
            // Add control buttons for bot messages only
            if (!isUser)
              Consumer3<TtsService, SettingsModel, ClarificationService>(
                builder: (context, ttsService, settings, clarificationService, _) {
                  // Check if THIS specific message is currently playing
                  final isThisMessagePlaying =
                      ttsService.isSpeaking &&
                      ttsService.lastSpokenText != null &&
                      ttsService.lastSpokenText!.contains(
                        message.substring(0, message.length > 50 ? 50 : message.length),
                      );

                  return Align(
                    alignment: Alignment.bottomRight,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Question mark button for clarification (only if callback provided)
                        if (onClarificationRequested != null)
                          IconButton(
                            icon: Icon(
                              Icons.help_outline,
                              size: 20,
                              color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.8),
                            ),
                            constraints: const BoxConstraints(maxHeight: 20, maxWidth: 20),
                            padding: EdgeInsets.zero,
                            iconSize: 20,
                            visualDensity: VisualDensity.compact,
                            onPressed: () async {
                              debugPrint('ChatBubble: Requesting clarification');
                              
                              // Notify parent that clarification was requested (for metrics)
                              onClarificationRequested?.call();
                              
                              // Show loading dialog
                              if (!context.mounted) return;
                              showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder: (ctx) => const Center(
                                  child: CircularProgressIndicator(),
                                ),
                              );
                              
                              try {
                                final clarification = await clarificationService.getClarification(
                                  message: message,
                                  targetLanguage: targetLanguage ?? 'German',
                                  nativeLanguage: settings.nativeLanguage,
                                  recentMessages: recentMessages,
                                );
                                
                                // Close loading dialog
                                if (!context.mounted) return;
                                Navigator.of(context).pop();
                                
                                // Show clarification dialog
                                if (!context.mounted) return;
                                showDialog(
                                  context: context,
                                  builder: (ctx) => AlertDialog(
                                    title: const Text('Translation'),
                                    content: SingleChildScrollView(
                                      child: Text(clarification),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.of(ctx).pop(),
                                        child: const Text('Close'),
                                      ),
                                    ],
                                  ),
                                );
                              } catch (e) {
                                // Close loading dialog
                                if (!context.mounted) return;
                                Navigator.of(context).pop();
                                
                                // Show error
                                if (!context.mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Error: $e')),
                                );
                              }
                            },
                          ),
                        // Audio button (if audio is enabled)
                        if (settings.audioEnabled)
                          IconButton(
                            icon: Icon(
                              isThisMessagePlaying
                                  ? Icons.stop
                                  : Icons.volume_up,
                              size: 20,
                              color: isThisMessagePlaying
                                  ? Theme.of(context).colorScheme.onPrimary
                                  : Theme.of(context).colorScheme.onPrimary.withOpacity(0.8),
                            ),
                            constraints: const BoxConstraints(maxHeight: 20, maxWidth: 20),
                            padding: EdgeInsets.zero,
                            iconSize: 20,
                            visualDensity: VisualDensity.compact,
                            onPressed: isThisMessagePlaying
                                ? () {
                                    debugPrint('ChatBubble: Stopping TTS');
                                    ttsService.stop();
                                  }
                                : () async {
                                    final messageText = message;
                                    debugPrint('ChatBubble: Playing audio for message');

                                    if (ttsService.isSpeaking) {
                                      await ttsService.stop();
                                      await Future.delayed(const Duration(milliseconds: 100));
                                    }

                                    await ttsService.speak(messageText);
                                    debugPrint('ChatBubble: TTS speak method returned');
                                  },
                          ),
                      ],
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}

class ThinkingBubble extends StatelessWidget {
  const ThinkingBubble({super.key});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4.0),
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.secondary.withOpacity(0.9),
          borderRadius: BorderRadius.circular(20.0),
        ),
        child: SizedBox(
          height: 20, // Reduced height for the container
          child: Row(mainAxisSize: MainAxisSize.min, children: [_ThinkingDots()]),
        ),
      ),
    );
  }
}

// Internal thinking dots for the thinking bubble
class _ThinkingDots extends StatefulWidget {
  const _ThinkingDots();

  @override
  State<_ThinkingDots> createState() => _ThinkingDotsState();
}

class _ThinkingDotsState extends State<_ThinkingDots> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))
      ..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 14, // Reduced height
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final t = _controller.value; // 0..1
          int active = (t * 3).floor() % 3; // 0,1,2 cycling
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(3, (i) {
              final on = i <= active;
              return Container(
                width: 4,
                height: 4,
                margin: const EdgeInsets.symmetric(horizontal: 2),
                decoration: BoxDecoration(
                  color: on
                      ? Theme.of(context).colorScheme.onPrimary
                      : Theme.of(context).colorScheme.onPrimary.withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
              );
            }),
          );
        },
      ),
    );
  }
}
