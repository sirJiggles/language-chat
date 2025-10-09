import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/settings_model.dart';
import '../services/chat_service.dart';
import '../widgets/settings/language_settings_card.dart';
import '../widgets/settings/appearance_settings_card.dart';
import '../widgets/settings/audio_settings_card.dart';
import '../widgets/settings/danger_zone_card.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late String _selectedLanguage;
  late String _selectedNativeLanguage;
  late bool _audioEnabled;
  late bool _isDarkMode;
  late bool _conversationMode;
  late String _selectedOpenAIVoice;

  @override
  void initState() {
    super.initState();
    // Load settings from SettingsModel
    final settings = context.read<SettingsModel>();
    final chat = context.read<ChatService>();
    
    _selectedLanguage = chat.targetLanguage;
    _selectedNativeLanguage = settings.nativeLanguage;
    _audioEnabled = settings.audioEnabled;
    _isDarkMode = settings.isDarkMode;
    _conversationMode = settings.conversationMode;
    _selectedOpenAIVoice = settings.openaiTtsVoice;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          LanguageSettingsCard(
            selectedLanguage: _selectedLanguage,
            selectedNativeLanguage: _selectedNativeLanguage,
            onLanguageChanged: (value) => setState(() => _selectedLanguage = value),
            onNativeLanguageChanged: (value) {
              setState(() => _selectedNativeLanguage = value);
              context.read<SettingsModel>().setNativeLanguage(value);
            },
          ),
          const SizedBox(height: 16),
          AppearanceSettingsCard(
            isDarkMode: _isDarkMode,
            onDarkModeChanged: (value) {
              setState(() => _isDarkMode = value);
              context.read<SettingsModel>().setDarkMode(value);
            },
          ),
          const SizedBox(height: 16),
          AudioSettingsCard(
            audioEnabled: _audioEnabled,
            conversationMode: _conversationMode,
            selectedLanguage: _selectedLanguage,
            selectedOpenAIVoice: _selectedOpenAIVoice,
            onAudioEnabledChanged: (value) {
              setState(() => _audioEnabled = value);
              context.read<SettingsModel>().setAudioEnabled(value);
            },
            onConversationModeChanged: (value) {
              setState(() => _conversationMode = value);
              context.read<SettingsModel>().setConversationMode(value);
            },
            onVoiceChanged: (value) => setState(() => _selectedOpenAIVoice = value),
          ),
          const SizedBox(height: 16),
          const DangerZoneCard(),
        ],
      ),
    );
  }
}
