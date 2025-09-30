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
  TtsService? _ttsService;

  @override
  void initState() {
    super.initState();

    // Initialize scale animation
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.5,
    ).animate(CurvedAnimation(parent: _scaleController, curve: Curves.easeOut));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Store TTS service reference safely
    if (_ttsService == null) {
      _ttsService = Provider.of<TtsService>(context, listen: false);
      _ttsService!.addListener(_onTtsStateChanged);
      _isSpeaking = _ttsService!.isSpeaking;
    }
  }

  @override
  void dispose() {
    // Remove the TTS listener using stored reference
    _ttsService?.removeListener(_onTtsStateChanged);
    _scaleController.dispose();
    super.dispose();
  }

  void _onTtsStateChanged() {
    if (!mounted) return; // Check if widget is still mounted

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
            ? (_cancelRecording ? Colors.grey.shade400 : Theme.of(context).colorScheme.primary)
            : (_isSpeaking
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.primary);
        final iconColor = const Color(0xFF261D45); // Purple icon color matching theme

        return GestureDetector(
          onTapDown: (_) async {
            // Scale up the button
            _scaleController.forward();

            if (isSpeaking) {
              await ttsService.stop();
              return;
            }
            if (!speechService.isListening) {
              if (mounted) setState(() => _cancelRecording = false);
              // Align speech recognizer locale with target language
              speechService.setLocaleFromLanguage(chatService.targetLanguage);
              // Small delay to ensure locale is set before starting
              await Future.delayed(const Duration(milliseconds: 50));
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

              // If canceled (swiped up), clear the text
              if (_cancelRecording) {
                speechService.clearLastWords();
              }
              // Otherwise, text stays in field - user can edit and send manually

              if (mounted) setState(() => _cancelRecording = false);
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
              if (mounted) setState(() => _cancelRecording = false);
            }
          },
          onPanStart: (_) {
            if (isSpeaking) return; // ignore drag in speaking mode
            if (isListening && mounted) setState(() => _cancelRecording = false);
          },
          onPanUpdate: (details) {
            if (isSpeaking) return; // ignore drag in speaking mode
            // If user drags upward away from the mic, mark as cancel
            if (details.localPosition.dy < -30) {
              if (!_cancelRecording && mounted) {
                setState(() => _cancelRecording = true);
                HapticFeedback.mediumImpact();
              }
            } else {
              if (_cancelRecording && mounted) {
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
                          ? const SoundWaveAnimation(
                              color: Color(0xFF261D45), // Purple wave matching theme
                              size: 48,
                              barCount: 9,
                              barWidth: 2.0,
                              barSpacing: 2.0,
                              minBarHeight: 2.0,
                              maxBarHeight: 18.0,
                              animationDuration: Duration(milliseconds: 200),
                            )
                          : Icon(Icons.mic, size: iconSize, color: iconColor),
                      if (_cancelRecording && isListening && size > 60)
                        Positioned(
                          bottom: size * 0.125,
                          child: Icon(
                            Icons.cancel,
                            size: size * 0.225,
                            color: const Color(0xFF261D45),
                          ),
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
