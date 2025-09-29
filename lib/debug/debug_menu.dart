import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import '../services/context_manager.dart';
import '../services/chat_service.dart';
import '../models/language_level_tracker.dart';
import 'student_profile_view.dart';
import 'assessment_activity_view.dart';

/// A debug menu to access debugging tools
class DebugMenu extends StatelessWidget {
  const DebugMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final contextManager = Provider.of<ContextManager>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Debug Menu')),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Current level display
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Consumer2<LanguageLevelTracker, ChatService>(
              builder: (context, levelTracker, chatService, _) {
                final currentLevel = levelTracker.currentLevel;
                final targetLanguage = chatService.targetLanguage;
                
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Icon(
                          Icons.school,
                          size: 32,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '$targetLanguage Level',
                                style: const TextStyle(fontSize: 16),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                currentLevel,
                                style: TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                levelTracker.getTrend(),
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          
          // Menu options
          Expanded(
            child: ListView(
              children: [
                ListTile(
                  leading: const Icon(Icons.person),
                  title: const Text('Student Profile & Assessment'),
                  subtitle: const Text('View personal facts, language level, and assessment history'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const StudentProfileView()),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.psychology),
                  title: const Text('Assessment Bot Activity'),
                  subtitle: const Text('See what the background bot is learning about you'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AssessmentActivityView()),
                    );
                  },
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.delete, color: Colors.red),
                  title: const Text('Reset Student Profile', style: TextStyle(color: Colors.red)),
                  subtitle: const Text('Delete current profile and start fresh'),
                  onTap: () {
                    _confirmResetProfile(context, contextManager);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _confirmResetProfile(BuildContext context, ContextManager contextManager) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Student Profile'),
        content: const Text(
          'This will delete the current student profile and all conversation history. Are you sure?',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _resetProfile(context);
              if (context.mounted) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('Profile reset successfully')));
              }
            },
            child: const Text('Reset', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _resetProfile(BuildContext context) async {
    try {
      // Try application support directory first
      Directory baseDir;
      try {
        baseDir = await getApplicationSupportDirectory();
        debugPrint('Using application support directory: ${baseDir.path}');
      } catch (e) {
        // Fall back to documents directory
        baseDir = await getApplicationDocumentsDirectory();
        debugPrint('Using documents directory: ${baseDir.path}');
      }

      final profileFile = File('${baseDir.path}/context/student_profile.json');
      debugPrint('Checking for profile at: ${profileFile.path}');

      if (await profileFile.exists()) {
        await profileFile.delete();
        debugPrint('Deleted student profile');
      }

      final conversationsDir = Directory('${baseDir.path}/context/conversations');
      debugPrint('Checking for conversations at: ${conversationsDir.path}');
      if (await conversationsDir.exists()) {
        await conversationsDir.delete(recursive: true);
        debugPrint('Deleted conversations directory');
      }

      // Reinitialize context manager
      final contextManager = Provider.of<ContextManager>(context, listen: false);
      await contextManager.initialize();
    } catch (e) {
      debugPrint('Error resetting profile: $e');
    }
  }
}
