import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/whisper_speech_service.dart';
import '../../services/chat_service.dart';
import '../../services/tts_service.dart';
import '../../models/settings_model.dart';
import '../audio_waveform.dart';

class ConversationModeBar extends StatefulWidget {
  final VoidCallback onScrollToBottom;

  const ConversationModeBar({super.key, required this.onScrollToBottom});

  @override
  State<ConversationModeBar> createState() => _ConversationModeBarState();
}

class _ConversationModeBarState extends State<ConversationModeBar> {
  bool _isRecording = false;
  bool _isProcessing = false;
  String _lastTranscription = '';

  Future<void> _toggleRecording() async {
    final speechService = Provider.of<WhisperSpeechService>(context, listen: false);
    final chatService = Provider.of<ChatService>(context, listen: false);

    if (_isRecording) {
      // Stop recording
      setState(() {
        _isRecording = false;
      });
      await speechService.stopListening(skipTranscription: true);
    } else {
      // Start recording
      setState(() {
        _isRecording = true;
        _isProcessing = false;
      });

      speechService.setLocaleFromLanguage(chatService.targetLanguage);
      await Future.delayed(const Duration(milliseconds: 50));
      await speechService.startListening();

      // Scroll to bottom
      Future.delayed(const Duration(milliseconds: 100), () {
        widget.onScrollToBottom();
      });

      // Start monitoring for silence
      _monitorSilence();
    }
  }

  Future<void> _monitorSilence() async {
    final speechService = Provider.of<WhisperSpeechService>(context, listen: false);

    int silenceCount = 0;
    int speechCount = 0;
    bool hadSpeech = false;
    const int silenceThreshold = 30; // ~1.5 seconds of silence (30 * 50ms)
    const int minSpeechDuration = 4; // Require at least 200ms of speech before detecting silence
    const double amplitudeThreshold = 0.15; // Minimum amplitude to consider as speech

    while (_isRecording && !_isProcessing && mounted) {
      await Future.delayed(const Duration(milliseconds: 50));

      final currentAmplitude = speechService.currentAmplitude;

      // Check if amplitude indicates speech
      if (currentAmplitude > amplitudeThreshold) {
        speechCount++;
        silenceCount = 0; // Reset silence counter
        if (speechCount >= minSpeechDuration) {
          hadSpeech = true;
        }
      } else {
        // Silence detected
        if (hadSpeech) {
          silenceCount++;
          speechCount = 0;
        }
      }

      // If we've had speech and then enough silence, auto-send
      if (hadSpeech && silenceCount >= silenceThreshold) {
        await _autoSendMessage();
        break;
      }
    }
  }

  Future<void> _autoSendMessage() async {
    if (!mounted || _isProcessing) return;

    final speechService = Provider.of<WhisperSpeechService>(context, listen: false);
    final chatService = Provider.of<ChatService>(context, listen: false);
    final ttsService = Provider.of<TtsService>(context, listen: false);
    final settings = Provider.of<SettingsModel>(context, listen: false);

    setState(() {
      _isProcessing = true;
    });

    // Stop recording and transcribe
    await speechService.stopListening();

    // Wait for transcription
    while (speechService.isTranscribing && mounted) {
      await Future.delayed(const Duration(milliseconds: 100));
    }

    final transcription = speechService.lastWords;

    if (transcription.isEmpty || transcription == _lastTranscription) {
      // No new transcription, restart recording
      setState(() {
        _isProcessing = false;
      });
      if (_isRecording) {
        speechService.setLocaleFromLanguage(chatService.targetLanguage);
        await speechService.startListening();
      }
      return;
    }

    _lastTranscription = transcription;

    // Send message and get response
    final response = await chatService.sendMessage(transcription);

    // Reveal the bot message immediately (removes thinking dots)
    chatService.revealBotMessage();

    // Stop processing state so UI updates
    if (mounted) {
      setState(() {
        _isProcessing = false;
      });
    }

    // Play audio if enabled and wait for it to finish
    if (settings.audioEnabled && response.isNotEmpty) {
      await ttsService.speak(response);

      // Wait for TTS to completely finish before restarting recording
      while (ttsService.isSpeaking && mounted) {
        await Future.delayed(const Duration(milliseconds: 100));
      }
    }

    // Only restart recording after bot is done speaking
    if (mounted && _isRecording) {
      speechService.setLocaleFromLanguage(chatService.targetLanguage);
      await speechService.startListening();
      _monitorSilence();
    }
  }

  @override
  void dispose() {
    // Stop recording if active
    if (_isRecording) {
      final speechService = Provider.of<WhisperSpeechService>(context, listen: false);
      speechService.stopListening(skipTranscription: true);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<WhisperSpeechService, TtsService>(
      builder: (context, speechService, ttsService, _) {
        final isBotSpeaking = ttsService.isSpeaking;
        final isButtonDisabled = _isProcessing || isBotSpeaking;

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
                padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Large mic button
                      GestureDetector(
                        onTap: isButtonDisabled ? null : _toggleRecording,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: _isRecording
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context).colorScheme.primaryContainer,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: _isRecording ? 16 : 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: _isProcessing || isBotSpeaking
                              ? Padding(
                                  padding: const EdgeInsets.all(20.0),
                                  child: CircularProgressIndicator(
                                    strokeWidth: 3,
                                    color: Theme.of(context).colorScheme.onPrimary,
                                  ),
                                )
                              : _isRecording
                              ? Padding(
                                  padding: const EdgeInsets.all(5.0),
                                  child: AudioWaveform(
                                    audioLevel: speechService.currentAmplitude,
                                    color: Theme.of(context).colorScheme.onPrimary,
                                    barCount: 7,
                                  ),
                                )
                              : Icon(
                                  Icons.mic,
                                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                                  size: 40,
                                ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      // Status text
                      Text(
                        isBotSpeaking
                            ? 'Bot speaking...'
                            : _isProcessing
                            ? 'Processing...'
                            : _isRecording
                            ? 'Listening...'
                            : 'Tap to start',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                          color: isBotSpeaking
                              ? Theme.of(context).colorScheme.onSurfaceVariant
                              : _isRecording
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
