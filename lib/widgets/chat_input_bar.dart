import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/speech_service.dart';
import 'mic_button.dart';

class ChatInputBar extends StatelessWidget {
  final TextEditingController textController;
  final VoidCallback onSendMessage;
  final VoidCallback onScrollToBottom;

  const ChatInputBar({
    super.key,
    required this.textController,
    required this.onSendMessage,
    required this.onScrollToBottom,
  });

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          color: Theme.of(context).colorScheme.surface.withOpacity(0.7),
          padding: EdgeInsets.fromLTRB(8.0, 20.0, 8.0, bottomPadding + 8.0),
          child: Consumer<SpeechService>(
            builder: (context, speechService, _) {
              final isListening = speechService.isListening;

              // Update text field with speech as user speaks
              if (isListening) {
                textController.text = speechService.lastWords;
              }

              return Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Text input field
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: textController,
                              style: const TextStyle(
                                color: Colors.black87,
                                fontStyle: FontStyle.italic,
                              ),
                              decoration: const InputDecoration(
                                hintText: 'Message',
                                hintStyle: TextStyle(color: Colors.black38),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 12,
                                ),
                              ),
                              maxLines: null,
                              textInputAction: TextInputAction.send,
                              onSubmitted: (_) => onSendMessage(),
                            ),
                          ),
                          // Clear button
                          ValueListenableBuilder<TextEditingValue>(
                            valueListenable: textController,
                            builder: (context, value, child) {
                              if (value.text.isEmpty) return const SizedBox.shrink();
                              return IconButton(
                                icon: const Icon(Icons.clear, size: 20),
                                color: Colors.black54,
                                onPressed: () {
                                  textController.clear();
                                },
                                padding: const EdgeInsets.all(8),
                                constraints: const BoxConstraints(),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Mic/Send button
                  ValueListenableBuilder<TextEditingValue>(
                    valueListenable: textController,
                    builder: (context, value, child) {
                      final hasText = value.text.trim().isNotEmpty;

                      // Show send button when there's text AND not listening
                      // Show mic when empty OR currently listening
                      return SizedBox(
                        width: 48,
                        height: 48,
                        child: (hasText && !isListening)
                            ? IconButton(
                                onPressed: onSendMessage,
                                icon: Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).colorScheme.primary,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.2),
                                        blurRadius: 8,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Icon(
                                    Icons.send,
                                    color: Theme.of(context).colorScheme.onPrimary,
                                    size: 24,
                                  ),
                                ),
                                padding: EdgeInsets.zero,
                              )
                            : MicButton(onScrollToBottom: onScrollToBottom),
                      );
                    },
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
