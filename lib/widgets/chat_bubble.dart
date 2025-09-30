import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/settings_model.dart';
import '../services/tts_service.dart';
import '../services/word_definition_service.dart';
import 'selectable_word_text.dart';

class ChatBubble extends StatelessWidget {
  final String message;
  final bool isUser;

  const ChatBubble({super.key, required this.message, required this.isUser});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4.0),
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
        decoration: BoxDecoration(
          color: isUser
              ? Theme.of(context)
                    .colorScheme
                    .tertiary // Slightly transparent blue for user
              : const Color(0xFF372963), // Lighter purple for bot messages
          borderRadius: BorderRadius.circular(20.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Use selectable word text for bot messages, regular text for user messages
            isUser
                ? Text(
                    message,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      height: 1.4,
                      fontStyle: FontStyle.italic,
                    ),
                  )
                : Consumer<WordDefinitionService>(
                    builder: (context, definitionService, _) {
                      return SelectableWordText(
                        text: message,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 12,
                          height: 1.4,
                          fontStyle: FontStyle.italic,
                        ),
                        definitionService: definitionService,
                      );
                    },
                  ),
            // Add play button for bot messages only (if audio is enabled)
            if (!isUser)
              Consumer2<TtsService, SettingsModel>(
                builder: (context, ttsService, settings, _) {
                  // Don't show button if audio is disabled
                  if (!settings.audioEnabled) {
                    return const SizedBox.shrink();
                  }

                  // Check if THIS specific message is currently playing
                  final isThisMessagePlaying =
                      ttsService.isSpeaking &&
                      ttsService.lastSpokenText != null &&
                      ttsService.lastSpokenText!.contains(
                        message.substring(0, message.length > 50 ? 50 : message.length),
                      );

                  return Align(
                    alignment: Alignment.bottomRight,
                    child: IconButton(
                      icon: Icon(
                        isThisMessagePlaying
                            ? Icons
                                  .stop // Show stop icon when THIS message is speaking
                            : Icons.volume_up, // Show play icon when not speaking
                        size: 20,
                        color: isThisMessagePlaying
                            ? Theme.of(context)
                                  .colorScheme
                                  .tertiary // Brighter when speaking
                            : Theme.of(
                                context,
                              ).colorScheme.tertiary.withOpacity(0.3), // Normal color
                      ),
                      constraints: const BoxConstraints(maxHeight: 20, maxWidth: 20),
                      padding: EdgeInsets.zero,
                      iconSize: 20,
                      visualDensity: VisualDensity.compact,
                      onPressed: isThisMessagePlaying
                          ? () {
                              // Stop speaking if THIS message is playing
                              debugPrint('ChatBubble: Stopping TTS');
                              ttsService.stop();
                            }
                          : () async {
                              // Get the message text
                              final messageText = message;
                              debugPrint('ChatBubble: Playing audio for message');

                              // Make sure any ongoing TTS is stopped
                              if (ttsService.isSpeaking) {
                                await ttsService.stop();
                                // Small delay to ensure stop completes
                                await Future.delayed(const Duration(milliseconds: 100));
                              }

                              // Play the audio
                              await ttsService.speak(messageText);
                              debugPrint('ChatBubble: TTS speak method returned');
                            },
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
          color: const Color(0xFF372963).withOpacity(0.9),
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
                      ? Theme.of(context).colorScheme.secondary
                      : Theme.of(context).colorScheme.secondary.withOpacity(0.3),
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
