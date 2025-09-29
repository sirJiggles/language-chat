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
  String _selectedVoiceName = '';
  ChatProvider _selectedChatProvider = ChatProvider.ollama;
  TtsProvider _selectedTtsProvider = TtsProvider.system;
  String _selectedOpenAIVoice = 'alloy';

  @override
  void initState() {
    super.initState();
    final chat = context.read<ChatService>();
    final tts = context.read<TtsService>();
    final settings = context.read<SettingsModel>();
    _selectedLanguage = chat.targetLanguage;
    _selectedVoiceName = tts.voiceName;
    _selectedChatProvider = settings.chatProvider;
    _selectedTtsProvider = settings.ttsProvider;
    _selectedOpenAIVoice = settings.openaiTtsVoice;
  }

  @override
  Widget build(BuildContext context) {
    final tts = context.watch<TtsService>();
    final voices = tts.availableVoices;

    // Derive available language codes from device voices (e.g., 'de' from 'de-DE')
    final Set<String> availableCodes = voices
        .map((v) => (v['locale'] ?? '').split('-').first)
        .where((code) => code.isNotEmpty)
        .toSet();
        
    debugPrint('Available language codes: $availableCodes');

    String _langToCode(String lang) {
      final l = lang.toLowerCase();
      if (l == 'english') return 'en';
      if (l == 'german') return 'de';
      if (l == 'spanish') return 'es';
      if (l == 'french') return 'fr';
      if (l == 'italian') return 'it';
      if (l == 'portuguese') return 'pt';
      if (l == 'dutch') return 'nl';
      if (l == 'swedish') return 'sv';
      if (l == 'norwegian') return 'no';
      if (l == 'danish') return 'da';
      if (l == 'polish') return 'pl';
      if (l == 'russian') return 'ru';
      if (l == 'turkish') return 'tr';
      if (l == 'japanese') return 'ja';
      if (l == 'chinese') return 'zh';
      if (l == 'korean') return 'ko';
      return 'en';
    }

    final filteredLanguages = kLanguages
        .where((lang) => availableCodes.contains(_langToCode(lang)))
        .toList();

    // Ensure selected language is valid given available voices
    if (!filteredLanguages.contains(_selectedLanguage) && filteredLanguages.isNotEmpty) {
      _selectedLanguage = filteredLanguages.first;
    }

    final selectedCode = _langToCode(_selectedLanguage);
    final filteredVoices = voices
        .where((v) => (v['locale'] ?? '').toLowerCase().startsWith(selectedCode))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Chat Provider', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          DropdownButtonFormField<ChatProvider>(
            value: _selectedChatProvider,
            items: const [
              DropdownMenuItem(value: ChatProvider.ollama, child: Text('Ollama (Local)')),
              DropdownMenuItem(value: ChatProvider.chatgpt, child: Text('ChatGPT')),
            ],
            onChanged: (value) {
              if (value != null) {
                setState(() => _selectedChatProvider = value);
              }
            },
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              focusedBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: Color(0xFF2B80D4), width: 2.0), // Primary blue
              ),
            ),
            dropdownColor: const Color(0xFF1E1E1E), // Dark background
            icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF2B80D4)),
          ),
          const SizedBox(height: 16),
          
          Text('Text-to-Speech Provider', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          DropdownButtonFormField<TtsProvider>(
            value: _selectedTtsProvider,
            items: const [
              DropdownMenuItem(value: TtsProvider.system, child: Text('System (Default)')),
              DropdownMenuItem(value: TtsProvider.openai, child: Text('OpenAI (Premium)')),
            ],
            onChanged: (value) {
              if (value != null) {
                setState(() => _selectedTtsProvider = value);
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
          const SizedBox(height: 16),
          
          if (_selectedTtsProvider == TtsProvider.openai) ...[  
            Text('OpenAI Voice', style: Theme.of(context).textTheme.titleMedium),
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
            const SizedBox(height: 16),
          ],
          
          Text('Target Language', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: filteredLanguages.contains(_selectedLanguage) && filteredLanguages.isNotEmpty
                ? _selectedLanguage
                : (filteredLanguages.isNotEmpty ? filteredLanguages.first : null),
            items: filteredLanguages
                .map((lang) => DropdownMenuItem(value: lang, child: Text(lang)))
                .toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() => _selectedLanguage = value);
                // Reset voice selection when language changes
                _selectedVoiceName = '';
              }
            },
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              focusedBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: Color(0xFF2B80D4), width: 2.0), // Primary blue
              ),
            ),
            dropdownColor: const Color(0xFF1E1E1E), // Dark background
            icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF2B80D4)),
          ),
          const SizedBox(height: 16),
          Text('Voice', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: _selectedVoiceName.isEmpty ? null : _selectedVoiceName,
            items: [
              const DropdownMenuItem<String>(value: '', child: Text('None (system default)')),
              ...filteredVoices.map((v) {
                final name = v['name'] ?? '';
                final locale = v['locale'] ?? '';
                final label = locale.isNotEmpty ? '$name ($locale)' : name;
                return DropdownMenuItem<String>(value: name, child: Text(label));
              }),
            ],
            onChanged: (value) {
              setState(() => _selectedVoiceName = value ?? '');
            },
            decoration: const InputDecoration(border: OutlineInputBorder()),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: _selectedVoiceName.isEmpty
                ? null
                : () async {
                    await context.read<TtsService>().previewVoice(
                          _selectedVoiceName,
                          _selectedLanguage,
                        );
                  },
            icon: const Icon(Icons.volume_up),
            label: const Text('Preview'),
          ),
          const SizedBox(height: 24),
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

    chat.setTargetLanguage(_selectedLanguage);
    tts.setPreferredLanguage(_selectedLanguage);
    tts.setVoiceName(_selectedVoiceName);
    settings.setChatProvider(_selectedChatProvider);
    
    // Apply TTS provider settings
    tts.setTtsProvider(_selectedTtsProvider);
    if (_selectedTtsProvider == TtsProvider.openai) {
      tts.setOpenAIVoice(_selectedOpenAIVoice);
    }

    // Also map this voice as default for the selected language
    final code = _langToCode(_selectedLanguage);
    tts.setPreferredVoiceForLanguage(code, _selectedVoiceName);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Settings applied')),
    );
  }

  String _langToCode(String lang) {
    final l = lang.toLowerCase();
    if (l == 'english') return 'en';
    if (l == 'german') return 'de';
    if (l == 'spanish') return 'es';
    if (l == 'french') return 'fr';
    if (l == 'italian') return 'it';
    if (l == 'portuguese') return 'pt';
    if (l == 'dutch') return 'nl';
    if (l == 'swedish') return 'sv';
    if (l == 'norwegian') return 'no';
    if (l == 'danish') return 'da';
    if (l == 'polish') return 'pl';
    if (l == 'russian') return 'ru';
    if (l == 'turkish') return 'tr';
    if (l == 'japanese') return 'ja';
    if (l == 'chinese') return 'zh';
    if (l == 'korean') return 'ko';
    return 'en';
  }
}
