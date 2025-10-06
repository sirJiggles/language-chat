import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/chat_service.dart';
import '../services/comprehensive_assessment_service.dart';
import '../services/tts_service.dart';
import '../models/settings_model.dart';
import '../models/student_profile_store.dart';
import '../models/language_level_tracker.dart';
import '../models/conversation_archive.dart';
import '../services/openai_tts_service.dart';
import '../database/database_service.dart';

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
  String _selectedNativeLanguage = 'English';
  bool _audioEnabled = true;
  bool _isDarkMode = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Reload settings when returning to this screen
    _loadSettings();
  }

  void _loadSettings() {
    final chat = context.read<ChatService>();
    final settings = context.read<SettingsModel>();
    if (mounted) {
      setState(() {
        _selectedLanguage = chat.targetLanguage;
        _audioEnabled = settings.audioEnabled;
        _selectedOpenAIVoice = settings.openaiTtsVoice;
        _selectedNativeLanguage = settings.nativeLanguage;
        _isDarkMode = settings.isDarkMode;
      });
    }
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
                final chat = context.read<ChatService>();
                final tts = context.read<TtsService>();
                chat.setTargetLanguage(value);
                tts.setPreferredLanguage(value);
              }
            },
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2.0),
              ),
            ),
            dropdownColor: Theme.of(context).cardColor,
            icon: Icon(Icons.arrow_drop_down, color: Theme.of(context).colorScheme.primary),
          ),
          const SizedBox(height: 24),
          
          // Native Language Section
          Text('Native Language', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: _selectedNativeLanguage,
            items: kLanguages.map((lang) => 
              DropdownMenuItem(value: lang, child: Text(lang))
            ).toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() => _selectedNativeLanguage = value);
                context.read<SettingsModel>().setNativeLanguage(value);
              }
            },
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2.0),
              ),
            ),
            dropdownColor: Theme.of(context).cardColor,
            icon: Icon(Icons.arrow_drop_down, color: Theme.of(context).colorScheme.primary),
          ),
          const SizedBox(height: 24),
          
          // Appearance Section
          Text('Appearance', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          SwitchListTile(
            title: const Text('Dark Mode'),
            subtitle: const Text('Use dark theme'),
            value: _isDarkMode,
            onChanged: (value) {
              setState(() => _isDarkMode = value);
              context.read<SettingsModel>().setDarkMode(value);
            },
            activeColor: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 24),
          
          // Audio Section
          Text('Audio', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          SwitchListTile(
            title: const Text('Enable Audio'),
            subtitle: const Text('Play bot responses with voice'),
            value: _audioEnabled,
            onChanged: (value) {
              setState(() => _audioEnabled = value);
              context.read<SettingsModel>().setAudioEnabled(value);
            },
            activeColor: Theme.of(context).colorScheme.primary,
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
                  final tts = context.read<TtsService>();
                  final settings = context.read<SettingsModel>();
                  tts.setOpenAIVoice(value);
                  settings.setOpenAITtsVoice(value);
                }
              },
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2.0),
                ),
              ),
              dropdownColor: Theme.of(context).cardColor,
              icon: Icon(Icons.arrow_drop_down, color: Theme.of(context).colorScheme.primary),
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
          
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 16),
          
          // Danger Zone
          Text(
            'Danger Zone',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.red,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Warning: This will permanently delete all your data',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 16),
          
          // Reset All Data Button
          OutlinedButton.icon(
            onPressed: _confirmResetAllData,
            icon: const Icon(Icons.delete_forever, color: Colors.red),
            label: const Text('Reset All Data', style: TextStyle(color: Colors.red)),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
  
  void _confirmResetAllData() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset All Data?'),
        content: const Text(
          'This will permanently delete:\n\n'
          '• All archived conversations\n'
          '• All student profile facts\n'
          '• All language level assessments\n'
          '• Current conversation\n\n'
          'This action cannot be undone!',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _resetAllData();
            },
            child: const Text('Delete Everything', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
  
  Future<void> _resetAllData() async {
    try {
      // Show loading
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Deleting all data...')),
      );
      
      // Clear all database data
      await DatabaseService.clearAllData();
      
      // Clear current conversation and start fresh
      final chatService = context.read<ChatService>();
      final assessmentService = context.read<ComprehensiveAssessmentService>();
      final archiveStore = context.read<ConversationArchiveStore>();
      
      // Delete all archived conversations
      await archiveStore.clearAll();
      
      await chatService.archiveAndStartNew();
      await assessmentService.startNewSession();
      
      // Reload stores to reflect empty state
      final profileStore = context.read<StudentProfileStore>();
      final levelTracker = context.read<LanguageLevelTracker>();
      
      await profileStore.initialize();
      await levelTracker.initialize();
      await archiveStore.initialize();
      
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('All data deleted successfully. Starting new chat...'),
          backgroundColor: Colors.green,
        ),
      );
      
      // Go back to chat screen with fresh session
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error resetting data: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

}
