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

class _MicButtonState extends State<MicButton> with SingleTickerProviderStateMixin {
  bool _cancelRecording = false;
  bool _isSpeaking = false;
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;
  
  @override
  void initState() {
    super.initState();
    
    // Initialize scale animation
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeOut),
    );
    
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
    _scaleController.dispose();
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
    return Consumer3<SpeechService, ChatService, TtsService>(
          builder: (context, speechService, chatService, ttsService, _) {
            final isListening = speechService.isListening;
            final isSpeaking = ttsService.isSpeaking;
            
            // Debug logs to track TTS state
            debugPrint('MicButton: TTS service.isSpeaking=$isSpeaking, local._isSpeaking=$_isSpeaking');
            
            // Use our local state for more reliable UI updates
            final bgColor = isListening
                ? (_cancelRecording
                      ? Colors.grey.shade400
                      : Theme.of(context).colorScheme.primary)
                : (_isSpeaking ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.primary);
            final iconColor = Colors.white;

            return GestureDetector(
              onTapDown: (_) async {
                // Scale up the button
                _scaleController.forward();
                
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
                // Scale down the button
                _scaleController.reverse();
                
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
                // Scale down the button
                _scaleController.reverse();
                
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
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                  // Adapt size based on available space
                  final size = constraints.maxWidth > 0 && constraints.maxWidth < 60 
                      ? constraints.maxWidth 
                      : 80.0;
                  final iconSize = size * 0.4;
                  
                  return Container(
                    width: size,
                    height: size,
                    decoration: BoxDecoration(
                      color: bgColor,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
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
                              size: size * 0.6,
                              barCount: size > 60 ? 9 : 5,
                              barWidth: size > 60 ? 2.0 : 1.5,
                              barSpacing: size > 60 ? 2.0 : 1.5,
                              minBarHeight: 2.0,
                              maxBarHeight: size > 60 ? 18.0 : 12.0,
                              animationDuration: const Duration(milliseconds: 200),
                            )
                          : Icon(
                              Icons.mic,
                              size: iconSize,
                              color: iconColor,
                            ),
                        if (_cancelRecording && isListening && size > 60)
                          Positioned(
                            bottom: size * 0.125,
                            child: Icon(Icons.cancel, size: size * 0.225, color: Colors.white),
                          ),
                      ],
                    ),
                  );
                },
                ),
              ),
            );
          },
        );
  }
}
