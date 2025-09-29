import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/tts_service.dart';

class ChatBubble extends StatelessWidget {
  final String message;
  final bool isUser;

  const ChatBubble({
    super.key,
    required this.message,
    required this.isUser,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4.0),
        padding: const EdgeInsets.symmetric(
          horizontal: 16.0,
          vertical: 10.0,
        ),
        decoration: BoxDecoration(
          color: isUser
              ? Theme.of(context)
                    .colorScheme
                    .tertiary
                    .withOpacity(0.9) // Slightly transparent blue for user
              : const Color(0xFF1E1E1E).withOpacity(0.85), // Slightly transparent dark for bot
          borderRadius: BorderRadius.circular(20.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message,
              style: TextStyle(
                color: isUser
                    ? Colors.white
                    : Colors.white.withOpacity(0.9),
              ),
            ),
            // Add play button for bot messages only
            if (!isUser)
              Consumer<TtsService>(
                builder: (context, ttsService, _) {
                  return Align(
                    alignment: Alignment.centerRight,
                    child: IconButton(
                      icon: Icon(
                        ttsService.isSpeaking 
                            ? Icons.stop // Show stop icon when speaking
                            : Icons.volume_up, // Show play icon when not speaking
                        size: 16,
                        color: ttsService.isSpeaking 
                            ? Theme.of(context).colorScheme.tertiary // Brighter when speaking
                            : Theme.of(context).colorScheme.tertiary.withOpacity(0.8), // Normal color
                      ),
                      constraints: const BoxConstraints(
                        maxHeight: 24,
                        maxWidth: 24,
                      ),
                      padding: EdgeInsets.zero,
                      iconSize: 16,
                      visualDensity: VisualDensity.compact,
                      onPressed: ttsService.isSpeaking 
                          ? () {
                              // Stop speaking if already speaking
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
        padding: const EdgeInsets.symmetric(
          horizontal: 16.0,
          vertical: 10.0,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E).withOpacity(0.85),
          borderRadius: BorderRadius.circular(20.0),
        ),
        child: SizedBox(
          height: 20, // Reduced height for the container
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _ThinkingDots(),
            ],
          ),
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
