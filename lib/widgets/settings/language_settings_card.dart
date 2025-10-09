import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/chat_service.dart';
import '../../services/tts_service.dart';
import '../../screens/language_selection_screen.dart';

class LanguageSettingsCard extends StatelessWidget {
  final String selectedLanguage;
  final String selectedNativeLanguage;
  final ValueChanged<String> onLanguageChanged;
  final ValueChanged<String> onNativeLanguageChanged;

  const LanguageSettingsCard({
    super.key,
    required this.selectedLanguage,
    required this.selectedNativeLanguage,
    required this.onLanguageChanged,
    required this.onNativeLanguageChanged,
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
                Icon(Icons.language, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Text('Languages', style: Theme.of(context).textTheme.titleLarge),
              ],
            ),
            const SizedBox(height: 16),
            Text('Target Language', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: selectedLanguage,
              items: kLanguages
                  .map((lang) => DropdownMenuItem(value: lang, child: Text(lang)))
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  onLanguageChanged(value);
                  context.read<ChatService>().setTargetLanguage(value);
                  context.read<TtsService>().setPreferredLanguage(value);
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
              icon: Icon(Icons.arrow_drop_down, color: Theme.of(context).colorScheme.primary),
            ),
            const SizedBox(height: 16),
            Text('Native Language', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: selectedNativeLanguage,
              items: kLanguages
                  .map((lang) => DropdownMenuItem(value: lang, child: Text(lang)))
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  onNativeLanguageChanged(value);
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
              icon: Icon(Icons.arrow_drop_down, color: Theme.of(context).colorScheme.primary),
            ),
          ],
        ),
      ),
    );
  }
}
