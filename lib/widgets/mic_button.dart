import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import '../services/chat_service.dart';
import '../services/speech_service.dart';
import '../services/tts_service.dart';
import 'sound_wave_animation.dart';

class MicButton extends StatefulWidget {
  final Function() onScrollToBottom;

  const MicButton({super.key, required this.onScrollToBottom});

  @override
  State<MicButton> createState() => _MicButtonState();
}

class _MicButtonState extends State<MicButton> {
  bool _cancelRecording = false;
  bool _isSpeaking = false;
  
  @override
  void initState() {
    super.initState();
    // Schedule a post-frame callback to add the TTS listener
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _addTtsListener();
    });
  }
  
  @override
  void dispose() {
    // Remove the TTS listener when disposing
    final ttsService = Provider.of<TtsService>(context, listen: false);
    ttsService.removeListener(_onTtsStateChanged);
    super.dispose();
  }
  
  void _addTtsListener() {
    final ttsService = Provider.of<TtsService>(context, listen: false);
    ttsService.addListener(_onTtsStateChanged);
    // Initialize state
    _isSpeaking = ttsService.isSpeaking;
  }
  
  void _onTtsStateChanged() {
    final ttsService = Provider.of<TtsService>(context, listen: false);
    final newIsSpeaking = ttsService.isSpeaking;
    
    debugPrint('MicButton: TTS state changed, isSpeaking=$newIsSpeaking');
    
    if (_isSpeaking != newIsSpeaking) {
      setState(() {
        _isSpeaking = newIsSpeaking;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        child: Consumer3<SpeechService, ChatService, TtsService>(
          builder: (context, speechService, chatService, ttsService, _) {
            final isListening = speechService.isListening;
            final isSpeaking = ttsService.isSpeaking;
            
            // Debug logs to track TTS state
            debugPrint('MicButton: TTS service.isSpeaking=$isSpeaking, local._isSpeaking=$_isSpeaking');
            
            // Use our local state for more reliable UI updates
            final bgColor = isListening
                ? (_cancelRecording
                      ? Colors.grey.shade400.withOpacity(0.8)
                      : Theme.of(context).colorScheme.primary.withOpacity(0.8))
                : (_isSpeaking ? Theme.of(context).colorScheme.primary.withOpacity(0.8) : Colors.transparent);
            final borderColor = isListening
                ? (_cancelRecording ? Colors.grey.withOpacity(0.9) : Theme.of(context).colorScheme.primary.withOpacity(0.9))
                : (_isSpeaking
                      ? Theme.of(context).colorScheme.primary.withOpacity(0.9)
                      : Theme.of(context).colorScheme.primary.withOpacity(0.8));
            final iconColor = (isListening || _isSpeaking)
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

                    // Always speak the response
                    final bool shouldSpeak = true;

                    debugPrint('Speaking response: $shouldSpeak');

                    if (shouldSpeak) {
                      try {
                        // Make sure the response is a valid string that can be spoken
                        final cleanResponse = response.replaceAll(RegExp(r'\([^)]*\)'), '');
                        debugPrint('MicButton: Speaking response: "${cleanResponse.substring(0, cleanResponse.length > 30 ? 30 : cleanResponse.length)}..."');
                        
                        // Get TTS service and ensure it's ready
                        final ttsService = context.read<TtsService>();
                        
                        // Stop any ongoing speech first
                        if (ttsService.isSpeaking) {
                          debugPrint('MicButton: Stopping ongoing speech before starting new one');
                          await ttsService.stop();
                          // Small delay to ensure stop completes
                          await Future.delayed(const Duration(milliseconds: 100));
                        }
                        
                        // Speak the response
                        debugPrint('MicButton: Calling TTS service speak method');
                        await ttsService.speak(cleanResponse);
                        debugPrint('MicButton: TTS speak method returned');
                      } catch (e) {
                        debugPrint('Error speaking response: $e');
                        // Try to stop any ongoing TTS that might be causing issues
                        try {
                          await context.read<TtsService>().stop();
                        } catch (stopError) {
                          debugPrint('Error stopping TTS: $stopError');
                        }
                      }
                    }

                    // Auto-scroll to bottom after message and response
                    widget.onScrollToBottom();
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
                width: 80, // Slightly smaller
                height: 80, // Slightly smaller
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
                    // Show sound wave animation when bot is talking, otherwise show mic icon
                    _isSpeaking 
                      ? SoundWaveAnimation(
                          color: Colors.white,
                          size: 48,
                          barCount: 9,
                          barWidth: 2.0,
                          barSpacing: 2.0,
                          minBarHeight: 2.0,
                          maxBarHeight: 18.0,
                          animationDuration: const Duration(milliseconds: 200),
                        )
                      : Icon(
                          isListening ? Icons.mic : Icons.mic_none,
                          size: 32, // Slightly smaller
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
    );
  }
}
