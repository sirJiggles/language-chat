import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../services/chat_service.dart';
import '../services/speech_service.dart';
import '../services/tts_service.dart';
import 'settings_screen.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  ChatScreenState createState() => ChatScreenState();
}

class ChatScreenState extends State<ChatScreen> with SingleTickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  bool _cancelRecording = false;

  Future<void> _scrollToBottom() async {
    await Future.delayed(const Duration(milliseconds: 50));
    if (!_scrollController.hasClients) return;
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  @override
  void initState() {
    super.initState();
    _initializeServices();
  }

  Future<void> _initializeServices() async {
    final speechService = context.read<SpeechService>();
    final ttsService = context.read<TtsService>();

    await speechService.initialize();
    await ttsService.initialize();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // No AppBar to maximize space for chat content
      body: Stack(
        children: [
          // Main chat content
          Column(
            children: [
              Expanded(
                child: Consumer<ChatService>(
                  builder: (context, chatService, _) {
                    if (chatService.conversation.isNotEmpty) {
                      return ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(16.0),
                        itemCount: chatService.conversation
                            .split('\n')
                            .where((line) => line.isNotEmpty)
                            .length,
                        itemBuilder: (context, index) {
                          final lines = chatService.conversation
                              .split('\n')
                              .where((line) => line.isNotEmpty)
                              .toList();
                          final line = lines[index];
                          final isUser = line.startsWith('User:');

                          return Align(
                            alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                            child: Container(
                              margin: const EdgeInsets.symmetric(vertical: 4.0),
                              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
                              decoration: BoxDecoration(
                                color: isUser
                                    ? Theme.of(context).colorScheme.primaryContainer
                                    : Theme.of(context).colorScheme.surfaceVariant,
                                borderRadius: BorderRadius.circular(20.0),
                              ),
                              child: Text(
                                line
                                    .replaceFirst('User:', '')
                                    .replaceFirst('Assistant:', '')
                                    .trim(),
                                style: TextStyle(
                                  color: isUser
                                      ? Theme.of(context).colorScheme.onPrimaryContainer
                                      : Theme.of(context).colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    } else {
                      return const Center(
                        child: Text(
                          'Hold the microphone and start speaking to begin learning!',
                          style: TextStyle(fontSize: 16.0, color: Colors.grey),
                          textAlign: TextAlign.center,
                        ),
                      );
                    }
                  },
                ),
              ),
              // Thinking indicator
              Consumer<ChatService>(
                builder: (context, chatService, _) {
                  if (chatService.isThinking) {
                    return const Padding(
                      padding: EdgeInsets.only(bottom: 8.0),
                      child: _ThinkingDots(),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
              // Live transcription preview while listening
              Consumer<SpeechService>(
                builder: (context, speech, _) {
                  if (speech.isListening) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Column(
                        children: [
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.surfaceVariant,
                              borderRadius: BorderRadius.circular(16.0),
                              border: Border.all(
                                color: _cancelRecording
                                    ? Colors.red
                                    : Theme.of(context).dividerColor,
                              ),
                            ),
                            child: Text(
                              speech.lastWords.isNotEmpty
                                  ? speech.lastWords
                                  : 'Listening... speak now',
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                          const SizedBox(height: 8.0),
                          Text(
                            _cancelRecording
                                ? 'Release to cancel'
                                : 'Slide finger off the button to cancel',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: _cancelRecording ? Colors.red : Theme.of(context).hintColor,
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
              // Removed fading message area per request
              // Microphone button
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Consumer3<SpeechService, ChatService, TtsService>(
                  builder: (context, speechService, chatService, ttsService, _) {
                    final isListening = speechService.isListening;
                    final isSpeaking = ttsService.isSpeaking;
                    final bgColor = isListening
                        ? (_cancelRecording ? Colors.grey.shade400 : Colors.red)
                        : (isSpeaking ? Colors.red : Colors.transparent);
                    final borderColor = isListening
                        ? (_cancelRecording ? Colors.grey : Colors.red)
                        : (isSpeaking ? Colors.red : Theme.of(context).colorScheme.primary);
                    final iconColor = (isListening || isSpeaking)
                        ? Colors.white
                        : Theme.of(context).colorScheme.primary;

                    return GestureDetector(
                      onTapDown: (_) async {
                        if (isSpeaking) {
                          await ttsService.stop();
                          return;
                        }
                        if (!speechService.isListening) {
                          setState(() => _cancelRecording = false);
                          // Align speech recognizer locale with target language
                          speechService.setLocaleFromLanguage(chatService.targetLanguage);
                          await speechService.startListening();
                        }
                      },
                      onTapUp: (_) async {
                        if (isSpeaking) {
                          await ttsService.stop();
                          return;
                        }
                        if (speechService.isListening) {
                          await speechService.stopListening();
                          if (!_cancelRecording && speechService.lastWords.isNotEmpty) {
                            final response = await chatService.sendMessage(speechService.lastWords);
                            await context.read<TtsService>().speak(response);
                            // Auto-scroll to bottom after message and response
                            _scrollToBottom();
                          } else {
                            // canceled
                            speechService.clearLastWords();
                          }
                          setState(() => _cancelRecording = false);
                        }
                      },
                      onTapCancel: () async {
                        if (isSpeaking) {
                          await ttsService.stop();
                          return;
                        }
                        if (speechService.isListening) {
                          await speechService.stopListening();
                          speechService.clearLastWords();
                          setState(() => _cancelRecording = false);
                        }
                      },
                      onPanStart: (_) {
                        if (isSpeaking) return; // ignore drag in speaking mode
                        if (isListening) setState(() => _cancelRecording = false);
                      },
                      onPanUpdate: (details) {
                        if (isSpeaking) return; // ignore drag in speaking mode
                        // If user drags upward away from the mic, mark as cancel
                        if (details.localPosition.dy < -30) {
                          if (!_cancelRecording) {
                            setState(() => _cancelRecording = true);
                            HapticFeedback.mediumImpact();
                          }
                        } else {
                          if (_cancelRecording) {
                            setState(() => _cancelRecording = false);
                            HapticFeedback.selectionClick();
                          }
                        }
                      },
                      onPanEnd: (_) async {
                        // Do nothing here; final handling occurs onTapUp
                      },
                      child: Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          color: bgColor,
                          shape: BoxShape.circle,
                          border: Border.all(color: borderColor, width: 3),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Icon(
                              isSpeaking ? Icons.stop : (isListening ? Icons.mic : Icons.mic_none),
                              size: 36,
                              color: iconColor,
                            ),
                            if (_cancelRecording && isListening)
                              const Positioned(
                                bottom: 10,
                                child: Icon(Icons.cancel, size: 18, color: Colors.white),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          // Top-right subtle settings icon
          Positioned(
            bottom: 16,
            left: 0,
            child: IconButton(
              onPressed: () {
                Navigator.of(
                  context,
                ).push(MaterialPageRoute(builder: (_) => const SettingsScreen()));
              },
              icon: Icon(
                Icons.settings,
                color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.6),
                size: 26,
              ),
              tooltip: 'Settings',
            ),
          ),
        ],
      ),
    );
  }
}

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
      height: 28,
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
                width: 8,
                height: 8,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  color: on
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.primary.withOpacity(0.3),
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
