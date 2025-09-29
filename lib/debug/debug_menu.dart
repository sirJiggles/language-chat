import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/chat_service.dart';
import '../models/language_level_tracker.dart';
import 'student_profile_view.dart';
import 'assessment_activity_view.dart';

/// A debug menu to access debugging tools
class DebugMenu extends StatelessWidget {
  const DebugMenu({super.key});

  @override
  Widget build(BuildContext context) {

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
              ],
            ),
          ),
        ],
      ),
    );
  }
}
