import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/student_profile_store.dart';
import '../models/language_level_tracker.dart';

/// Shows the background assessment bot's activity and what it's learning
class AssessmentActivityView extends StatelessWidget {
  const AssessmentActivityView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Assessment Bot Activity'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Info Card
            Card(
              color: Theme.of(context).colorScheme.primaryContainer,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'The assessment bot runs in the background, extracting facts and evaluating your language level.',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Recent Facts Extracted
            Text(
              'Recently Extracted Facts',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Consumer<StudentProfileStore>(
              builder: (context, profileStore, _) {
                final profile = profileStore.profile;
                
                if (profile.isEmpty) {
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Icon(
                            Icons.hourglass_empty,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Text(
                              'No facts extracted yet. Keep chatting and the bot will learn about you!',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                
                // Show last 5 facts
                final entries = profile.entries.toList();
                final recentFacts = entries.length > 5 
                    ? entries.sublist(entries.length - 5)
                    : entries;
                
                return Column(
                  children: recentFacts.map((entry) {
                    return Card(
                      child: ListTile(
                        leading: Icon(
                          Icons.lightbulb_outline,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        title: Text(
                          _formatKey(entry.key),
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Text('${entry.value}'),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
            
            const SizedBox(height: 32),
            
            // Level Assessment Activity
            Text(
              'Level Assessment Activity',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Consumer<LanguageLevelTracker>(
              builder: (context, levelTracker, _) {
                final history = levelTracker.levelHistory.reversed.take(3).toList();
                
                if (history.isEmpty) {
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Icon(
                            Icons.pending_outlined,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Text(
                              'No level assessments yet. The bot assesses your level every 5 messages.',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                
                return Column(
                  children: [
                    // Current Status
                    Card(
                      color: Theme.of(context).colorScheme.secondaryContainer,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            Icon(
                              Icons.analytics_outlined,
                              size: 32,
                              color: Theme.of(context).colorScheme.onSecondaryContainer,
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Current Assessment',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Theme.of(context).colorScheme.onSecondaryContainer.withOpacity(0.7),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Level ${levelTracker.currentLevel} • ${(levelTracker.confidence * 100).toStringAsFixed(0)}% confidence',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context).colorScheme.onSecondaryContainer,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Trend: ${levelTracker.getTrend()}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Theme.of(context).colorScheme.onSecondaryContainer,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    // Recent Assessments
                    ...history.map((assessment) {
                      final timeAgo = _getTimeAgo(assessment.timestamp);
                      return Card(
                        child: ExpansionTile(
                          leading: CircleAvatar(
                            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                            child: Text(
                              assessment.level,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.onPrimaryContainer,
                              ),
                            ),
                          ),
                          title: Text(
                            'Level ${assessment.level} Assessment',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          subtitle: Text(timeAgo),
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Bot\'s Reasoning:',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context).colorScheme.primary,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    assessment.reasoning,
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ],
                );
              },
            ),
            
            const SizedBox(height: 24),
            
            // Stats
            Consumer2<StudentProfileStore, LanguageLevelTracker>(
              builder: (context, profileStore, levelTracker, _) {
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Statistics',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildStatRow('Total Facts Collected', '${profileStore.profile.length}'),
                        _buildStatRow('Total Assessments', '${levelTracker.levelHistory.length}'),
                        _buildStatRow('Assessment Frequency', 'Every 5 messages'),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  String _formatKey(String key) {
    return key
        .replaceAll('_', ' ')
        .split(' ')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }

  String _getTimeAgo(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    
    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}
