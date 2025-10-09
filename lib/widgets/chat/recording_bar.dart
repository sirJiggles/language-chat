import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/whisper_speech_service.dart';
import '../audio_waveform.dart';

class RecordingBar extends StatefulWidget {
  final VoidCallback onCancel;
  final VoidCallback onConfirm;

  const RecordingBar({super.key, required this.onCancel, required this.onConfirm});

  @override
  State<RecordingBar> createState() => _RecordingBarState();
}

class _RecordingBarState extends State<RecordingBar> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: Theme.of(context).colorScheme.outline.withOpacity(0.2), width: 1),
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
            padding: EdgeInsets.fromLTRB(10, 8.0, 8.0, 8.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Waveform visualization
                Container(
                  height: 60,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Consumer<WhisperSpeechService>(
                    builder: (context, speechService, _) {
                      return AudioWaveform(
                        audioLevel: speechService.currentAmplitude,
                        color: Theme.of(context).colorScheme.primary,
                        barCount: 25,
                      );
                    },
                  ),
                ),

                const SizedBox(height: 5),

                // Control buttons
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // Cancel button (trash) - lighter outline style
                      Opacity(
                        opacity: 0.6,
                        child: IconButton(
                          onPressed: widget.onCancel,
                          icon: Icon(
                            Icons.delete_outline,
                            color: Theme.of(context).colorScheme.error,
                            size: 28,
                          ),
                          padding: const EdgeInsets.all(12),
                        ),
                      ),

                      // Recording indicator
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: Consumer<WhisperSpeechService>(
                          builder: (context, speechService, _) {
                            return Row(
                              children: [
                                Container(
                                  width: 12,
                                  height: 12,
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).colorScheme.error,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Recording',
                                  style: Theme.of(
                                    context,
                                  ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                                ),
                              ],
                            );
                          },
                        ),
                      ),

                      // Confirm button (check) - positioned like mic button
                      Container(
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
                        child: IconButton(
                          onPressed: widget.onConfirm,
                          icon: Icon(
                            Icons.check,
                            color: Theme.of(context).colorScheme.onPrimary,
                            size: 24,
                          ),
                          padding: EdgeInsets.zero,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
