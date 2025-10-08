import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/whisper_speech_service.dart';
import '../services/chat_service.dart';
import 'recording_bar.dart';

class ChatInputBar extends StatefulWidget {
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
  State<ChatInputBar> createState() => _ChatInputBarState();
}

class _ChatInputBarState extends State<ChatInputBar> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  String _lastTranscription = '';

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _handleMicTap() async {
    final speechService = Provider.of<WhisperSpeechService>(context, listen: false);
    final chatService = Provider.of<ChatService>(context, listen: false);

    if (!speechService.isListening) {
      // Start recording
      speechService.setLocaleFromLanguage(chatService.targetLanguage);
      await Future.delayed(const Duration(milliseconds: 50));
      await speechService.startListening();
    }
  }

  Future<void> _handleRecordingCancel() async {
    final speechService = Provider.of<WhisperSpeechService>(context, listen: false);

    await speechService.stopListening(skipTranscription: true);
    speechService.clearLastWords();
  }

  Future<void> _handleRecordingConfirm() async {
    final speechService = Provider.of<WhisperSpeechService>(context, listen: false);

    await speechService.stopListening(skipTranscription: false);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<WhisperSpeechService>(
      builder: (context, speechService, _) {
        final isListening = speechService.isListening;
        final isTranscribing = speechService.isTranscribing;

        // Show recording bar when actively recording
        if (isListening && !isTranscribing) {
          return RecordingBar(onCancel: _handleRecordingCancel, onConfirm: _handleRecordingConfirm);
        }

        return ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              color: Theme.of(context).colorScheme.surface.withOpacity(0.7),
              padding: EdgeInsets.fromLTRB(8.0, 15, 8.0, 15),
              child: Builder(
                builder: (context) {
                  // Update text field when transcription completes
                  if (speechService.lastWords.isNotEmpty &&
                      speechService.lastWords != _lastTranscription) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      widget.textController.text = speechService.lastWords;
                      _lastTranscription = speechService.lastWords;
                    });
                  }

                  // Clear the last transcription when listening starts
                  if (isListening && _lastTranscription.isNotEmpty) {
                    _lastTranscription = '';
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
                                child: AnimatedBuilder(
                                  animation: _pulseAnimation,
                                  builder: (context, child) {
                                    return TextField(
                                      controller: widget.textController,
                                      style: const TextStyle(color: Colors.black87),
                                      decoration: InputDecoration(
                                        hintText: isTranscribing ? 'Transcribing...' : 'Message',
                                        hintStyle: TextStyle(
                                          color: isTranscribing
                                              ? Theme.of(context).colorScheme.primary.withOpacity(0.6)
                                              : Colors.black38,
                                          fontWeight: isTranscribing
                                              ? FontWeight.w500
                                              : FontWeight.normal,
                                        ),
                                        border: InputBorder.none,
                                        contentPadding: const EdgeInsets.symmetric(
                                          horizontal: 20,
                                          vertical: 12,
                                        ),
                                      ),
                                      maxLines: null,
                                      textInputAction: TextInputAction.send,
                                      onSubmitted: (_) => widget.onSendMessage(),
                                    );
                                  },
                                ),
                              ),
                              // Clear button
                              ValueListenableBuilder<TextEditingValue>(
                                valueListenable: widget.textController,
                                builder: (context, value, child) {
                                  if (value.text.isEmpty) return const SizedBox.shrink();
                                  return IconButton(
                                    icon: const Icon(Icons.clear, size: 20),
                                    color: Colors.black54,
                                    onPressed: () {
                                      widget.textController.clear();
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
                        valueListenable: widget.textController,
                        builder: (context, value, child) {
                          final hasText = value.text.trim().isNotEmpty;

                          // Show send button when there's text
                          // Show mic when empty
                          return SizedBox(
                            width: 48,
                            height: 48,
                            child: (hasText && !isTranscribing)
                                ? IconButton(
                                    onPressed: widget.onSendMessage,
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
                                : GestureDetector(
                                    onTap: _handleMicTap,
                                    child: Container(
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
                                      child: isTranscribing
                                          ? const Padding(
                                              padding: EdgeInsets.all(12.0),
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                color: Colors.white,
                                              ),
                                            )
                                          : Icon(
                                              Icons.mic,
                                              color: Theme.of(context).colorScheme.onPrimary,
                                              size: 24,
                                            ),
                                    ),
                                  ),
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
      },
    );
  }
}
