import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import '../services/context_manager.dart';
import '../services/chat_service.dart';
import 'assessment_view.dart';
import 'assessment_thinking_viewer.dart';
import '../screens/assessment_screen.dart';
import 'message_debug_view.dart';

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
            child: Consumer2<ContextManager, ChatService>(
              builder: (context, contextManager, chatService, _) {
                final currentLevel = contextManager.studentProfile?.proficiencyLevel ?? 'Unknown';
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
                        Column(
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
                          ],
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
                  leading: const Icon(Icons.assessment),
                  title: const Text('View Language Assessment'),
                  subtitle: const Text('See detailed assessment results'),
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const AssessmentView()));
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.chat),
                  title: const Text('View Assessment Bot Conversation'),
                  subtitle: const Text('See the assessment reasoning process as a chat'),
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const AssessmentThinkingViewer()));
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.psychology),
                  title: const Text('New Assessment View'),
                  subtitle: const Text('View assessments with the new message model'),
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const AssessmentScreen()));
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.message),
                  title: const Text('Message Debug View'),
                  subtitle: const Text('Inspect all messages in the conversation store'),
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const MessageDebugView()));
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.delete),
                  title: const Text('Reset Student Profile'),
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
