import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/chat_service.dart';
import '../services/tts_service.dart';
import '../models/settings_model.dart';
import '../services/openai_tts_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // Piper-supported common languages (names map via TtsService)
  static const List<String> kLanguages = [
    'English', 'German', 'Spanish', 'French', 'Italian', 'Portuguese',
    'Dutch', 'Swedish', 'Norwegian', 'Danish', 'Polish', 'Russian',
    'Turkish', 'Japanese', 'Chinese', 'Korean'
  ];

  String _selectedLanguage = 'German';
  String _selectedOpenAIVoice = 'nova';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadSettings());
  }

  void _loadSettings() {
    final chat = context.read<ChatService>();
    final settings = context.read<SettingsModel>();
    _selectedLanguage = chat.targetLanguage;
    _selectedOpenAIVoice = settings.openaiTtsVoice;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Target Language Section
          Text('Target Language', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: _selectedLanguage,
            items: kLanguages.map((lang) => 
              DropdownMenuItem(value: lang, child: Text(lang))
            ).toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() => _selectedLanguage = value);
              }
            },
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              focusedBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: Color(0xFF2B80D4), width: 2.0),
              ),
            ),
            dropdownColor: const Color(0xFF1E1E1E),
            icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF2B80D4)),
          ),
          const SizedBox(height: 24),
          
          // OpenAI Voice Section
          Text('Voice', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedOpenAIVoice,
              items: OpenAITtsService.availableVoices.map((voice) => 
                DropdownMenuItem(
                  value: voice['id'],
                  child: Text('${voice['name']} - ${voice['description']}'),
                )
              ).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedOpenAIVoice = value);
                }
              },
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF2B80D4), width: 2.0),
                ),
              ),
              dropdownColor: const Color(0xFF1E1E1E),
              icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF2B80D4)),
            ),
            const SizedBox(height: 12),
            Consumer<TtsService>(
              builder: (context, tts, _) {
                return OutlinedButton.icon(
                  onPressed: tts.isSpeaking 
                    ? null // Disable when speaking
                    : () async {
                        try {
                          // Show loading indicator
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Loading voice preview...'),
                              duration: Duration(seconds: 1),
                            ),
                          );
                          
                          // Apply the voice and preview it
                          tts.setOpenAIVoice(_selectedOpenAIVoice);
                          await tts.previewVoice(_selectedOpenAIVoice, _selectedLanguage);
                        } catch (e) {
                          // Show error message
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
                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.volume_up),
                  label: Text(tts.isSpeaking ? 'Playing...' : 'Preview OpenAI Voice'),
                );
              },
            ),
            const SizedBox(height: 24),
          
          // Apply Button
          ElevatedButton.icon(
            onPressed: _apply,
            icon: const Icon(Icons.save),
            label: const Text('Apply'),
          ),
        ],
      ),
    );
  }

  void _apply() {
    final chat = context.read<ChatService>();
    final tts = context.read<TtsService>();
    final settings = context.read<SettingsModel>();

    // Apply language
    chat.setTargetLanguage(_selectedLanguage);
    tts.setPreferredLanguage(_selectedLanguage);
    
    // Apply OpenAI voice (always using OpenAI TTS now)
    tts.setTtsProvider(TtsProvider.openai);
    tts.setOpenAIVoice(_selectedOpenAIVoice);
    settings.setOpenAITtsVoice(_selectedOpenAIVoice);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Settings applied')),
    );
  }
}
