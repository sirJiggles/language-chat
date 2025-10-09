import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/whisper_speech_service.dart';
import '../services/chat_service.dart';
import '../services/tts_service.dart';
import '../models/settings_model.dart';
import 'recording_bar.dart';
import 'sound_wave_animation.dart';

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
  Future<String>? _speculativeResponse;
  bool _speculativeRequestActive = false;
  bool _speculativeAudioReady = false;

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

    // Cancel speculative request if active
    _speculativeRequestActive = false;
    _speculativeResponse = null;
    _speculativeAudioReady = false;

    await speechService.stopListening(skipTranscription: true);
    speechService.clearLastWords();
  }

  Future<void> _handleRecordingConfirm() async {
    final speechService = Provider.of<WhisperSpeechService>(context, listen: false);

    await speechService.stopListening(skipTranscription: false);
    // Transcription will complete and text will appear in the text field
    // The speculative request will start automatically when transcription finishes
  }

  void _startSpeculativeRequest(String text) async {
    if (text.trim().isEmpty) return;

    debugPrint('ChatInputBar: Starting speculative request for: $text');
    _speculativeRequestActive = true;
    _speculativeAudioReady = false;

    final chatService = Provider.of<ChatService>(context, listen: false);
    final ttsService = Provider.of<TtsService>(context, listen: false);
    final settings = Provider.of<SettingsModel>(context, listen: false);

    // Use the speculative method that doesn't update UI
    _speculativeResponse = chatService.fetchResponseSpeculatively(text);

    // Also speculatively generate audio if enabled
    if (settings.audioEnabled) {
      try {
        final response = await _speculativeResponse!;
        if (!mounted || !_speculativeRequestActive) return;

        debugPrint('ChatInputBar: Speculative response received, pre-generating audio');
        final cleanResponse = response.replaceAll(RegExp(r'\([^)]*\)'), '').trim();

        if (cleanResponse.isNotEmpty) {
          // Pre-generate audio (but don't play it yet)
          await ttsService.preGenerateAudio(cleanResponse);
          if (mounted && _speculativeRequestActive) {
            _speculativeAudioReady = true;
            debugPrint('ChatInputBar: Speculative audio ready!');
          }
        }
      } catch (e) {
        debugPrint('ChatInputBar: Error pre-generating audio: $e');
      }
    }
  }

  Future<void> _handleSendWithSpeculation() async {
    // Get the message text before clearing
    final messageText = widget.textController.text.trim();

    // Always clear the text field immediately
    widget.textController.clear();

    // Clear speech service lastWords to prevent re-population
    final speechService = Provider.of<WhisperSpeechService>(context, listen: false);
    speechService.clearLastWords();

    if (_speculativeRequestActive &&
        _speculativeResponse != null &&
        messageText == _lastTranscription &&
        messageText.isNotEmpty) {
      debugPrint('ChatInputBar: Sending with speculative response');

      try {
        // Wait for the speculative response (might already be ready)
        final cachedResponse = await _speculativeResponse!;
        _speculativeRequestActive = false;
        _speculativeResponse = null;
        _lastTranscription = '';

        if (!mounted) return;

        debugPrint('ChatInputBar: Speculative response received, using it');

        // Send message with cached response
        final chatService = Provider.of<ChatService>(context, listen: false);
        final ttsService = Provider.of<TtsService>(context, listen: false);
        final settings = Provider.of<SettingsModel>(context, listen: false);

        // Send message and get response
        final response = await chatService.sendMessage(messageText, cachedResponse: cachedResponse);

        // Reveal immediately since we have the response text
        chatService.revealBotMessage();

        // Start audio playback in background (don't wait)
        if (settings.audioEnabled) {
          final cleanResponse = response.replaceAll(RegExp(r'\([^)]*\)'), '').trim();
          if (cleanResponse.isNotEmpty) {
            if (_speculativeAudioReady) {
              debugPrint('ChatInputBar: Using pre-generated audio - instant playback!');
            }
            // Fire and forget - audio plays in background
            ttsService.speak(cleanResponse).catchError((e) {
              debugPrint('ChatInputBar: Error speaking response: $e');
            });
          }
        }

        _speculativeAudioReady = false;
        widget.onScrollToBottom();
        return;
      } catch (e) {
        debugPrint('ChatInputBar: Error with speculative response: $e');
        // Fall through to normal send
      }
    }

    // Reset speculative state and send normally (without cached response)
    _speculativeRequestActive = false;
    _speculativeResponse = null;
    _speculativeAudioReady = false;
    _lastTranscription = '';

    if (messageText.isEmpty) return;

    // Send message normally
    final chatService = Provider.of<ChatService>(context, listen: false);
    final ttsService = Provider.of<TtsService>(context, listen: false);
    final settings = Provider.of<SettingsModel>(context, listen: false);

    final response = await chatService.sendMessage(messageText);

    // Reveal immediately since we have the response text
    chatService.revealBotMessage();

    // Start audio playback in background (don't wait)
    if (settings.audioEnabled) {
      final cleanResponse = response.replaceAll(RegExp(r'\([^)]*\)'), '').trim();
      if (cleanResponse.isNotEmpty) {
        // Fire and forget - audio plays in background
        ttsService.speak(cleanResponse).catchError((e) {
          debugPrint('ChatInputBar: Error speaking response: $e');
        });
      }
    }

    widget.onScrollToBottom();
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

        return Container(
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(
                color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                width: 1,
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: ClipRRect(
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

                        // Speculatively send the message (optimistic execution)
                        debugPrint(
                          'ChatInputBar: Transcription complete, starting speculative request',
                        );
                        _startSpeculativeRequest(speechService.lastWords);
                      });
                    }

                    // Clear the last transcription when listening starts
                    if (isListening && _lastTranscription.isNotEmpty) {
                      _lastTranscription = '';
                      // Reset speculative request state when starting new recording
                      _speculativeRequestActive = false;
                      _speculativeResponse = null;
                      _speculativeAudioReady = false;
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
                                                ? Theme.of(
                                                    context,
                                                  ).colorScheme.primary.withOpacity(0.6)
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
                                        onSubmitted: (_) => _handleSendWithSpeculation(),
                                      );
                                    },
                                  ),
                                ),
                                // Retry button for transcription errors
                                if (speechService.hasRetryableError)
                                  IconButton(
                                    icon: const Icon(Icons.refresh, size: 20),
                                    color: Theme.of(context).colorScheme.error,
                                    tooltip: 'Retry transcription',
                                    onPressed: () {
                                      speechService.retryTranscription();
                                    },
                                    padding: const EdgeInsets.all(8),
                                    constraints: const BoxConstraints(),
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
                                        // Cancel any speculative request
                                        _speculativeRequestActive = false;
                                        _speculativeResponse = null;
                                        _speculativeAudioReady = false;
                                        _lastTranscription = '';
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
                        const SizedBox(width: 5),
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
                                      onPressed: _handleSendWithSpeculation,
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
                                  : Consumer<TtsService>(
                                      builder: (context, ttsService, _) {
                                        final isSpeaking = ttsService.isSpeaking;
                                        
                                        return GestureDetector(
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
                                                ? Padding(
                                                    padding: const EdgeInsets.all(12.0),
                                                    child: CircularProgressIndicator(
                                                      strokeWidth: 2,
                                                      color: Colors.white,
                                                    ),
                                                  )
                                                : isSpeaking
                                                    ? SoundWaveAnimation(
                                                        color: Theme.of(context).colorScheme.onPrimary,
                                                        size: 28,
                                                        barCount: 5,
                                                        barWidth: 2.5,
                                                        barSpacing: 2,
                                                        minBarHeight: 4,
                                                        maxBarHeight: 16,
                                                      )
                                                    : Icon(
                                                        Icons.mic,
                                                        color: Theme.of(context).colorScheme.onPrimary,
                                                        size: 24,
                                                      ),
                                          ),
                                        );
                                      },
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
          ),
        );
      },
    );
  }
}
