import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/tts_service.dart';
import '../../services/openai_tts_service.dart';
import '../../models/settings_model.dart';

class AudioSettingsCard extends StatelessWidget {
  final bool audioEnabled;
  final bool conversationMode;
  final String selectedLanguage;
  final String selectedOpenAIVoice;
  final ValueChanged<bool> onAudioEnabledChanged;
  final ValueChanged<bool> onConversationModeChanged;
  final ValueChanged<String> onVoiceChanged;

  const AudioSettingsCard({
    super.key,
    required this.audioEnabled,
    required this.conversationMode,
    required this.selectedLanguage,
    required this.selectedOpenAIVoice,
    required this.onAudioEnabledChanged,
    required this.onConversationModeChanged,
    required this.onVoiceChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.volume_up, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Text('Audio', style: Theme.of(context).textTheme.titleLarge),
              ],
            ),
            SwitchListTile(
              title: const Text('Enable Audio'),
              subtitle: const Text('Play bot responses with voice'),
              value: audioEnabled,
              onChanged: onAudioEnabledChanged,
              activeColor: Theme.of(context).colorScheme.primary,
              contentPadding: EdgeInsets.zero,
            ),
            const Divider(),
            SwitchListTile(
              title: const Text('Conversation Mode'),
              subtitle: Text(
                audioEnabled
                    ? 'Hands-free continuous conversation with automatic silence detection'
                    : 'Requires audio to be enabled',
              ),
              value: conversationMode,
              onChanged: audioEnabled ? onConversationModeChanged : null,
              activeColor: Theme.of(context).colorScheme.primary,
              contentPadding: EdgeInsets.zero,
            ),
            // Voice settings - only show when audio is enabled
            if (audioEnabled) ...[
              const Divider(),
              const SizedBox(height: 8),
              Text('Voice', style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: selectedOpenAIVoice,
                items: OpenAITtsService.availableVoices
                    .map(
                      (voice) => DropdownMenuItem(
                        value: voice['id'],
                        child: Text('${voice['name']} - ${voice['description']}'),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    onVoiceChanged(value);
                    context.read<TtsService>().setOpenAIVoice(value);
                    context.read<SettingsModel>().setOpenAITtsVoice(value);
                  }
                },
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.primary,
                      width: 2.0,
                    ),
                  ),
                ),
                dropdownColor: Theme.of(context).cardColor,
                icon: Icon(
                  Icons.arrow_drop_down,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 12),
              Consumer<TtsService>(
                builder: (context, tts, _) {
                  return OutlinedButton.icon(
                    onPressed: tts.isSpeaking
                        ? null
                        : () async {
                            try {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Loading voice preview...'),
                                  duration: Duration(seconds: 1),
                                ),
                              );

                              tts.setOpenAIVoice(selectedOpenAIVoice);
                              await tts.previewVoice(selectedOpenAIVoice, selectedLanguage);
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Error previewing voice: $e'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            }
                          },
                    icon: tts.isSpeaking
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.volume_up),
                    label: Text(tts.isSpeaking ? 'Playing...' : 'Preview Voice'),
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}
