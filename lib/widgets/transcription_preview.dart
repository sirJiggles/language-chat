import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/speech_service.dart';

class TranscriptionPreview extends StatelessWidget {
  final bool cancelRecording;
  
  const TranscriptionPreview({
    super.key,
    required this.cancelRecording,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<SpeechService>(
      builder: (context, speech, _) {
        if (speech.isListening) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(16.0),
                    border: Border.all(
                      color: cancelRecording
                          ? Colors.red
                          : Theme.of(context).dividerColor.withOpacity(0.5),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
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
                  cancelRecording
                      ? 'Release to cancel'
                      : 'Slide finger off the button to cancel',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: cancelRecording ? Colors.red : Theme.of(context).hintColor,
                  ),
                ),
              ],
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}
