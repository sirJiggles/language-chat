import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/student_profile_store.dart';
import '../models/language_level_tracker.dart';
import '../services/assessment_service.dart';

/// Consolidated view for student profile, language level, and assessment data
class StudentProfileView extends StatefulWidget {
  const StudentProfileView({super.key});

  @override
  State<StudentProfileView> createState() => _StudentProfileViewState();
}

class _StudentProfileViewState extends State<StudentProfileView> {
  bool _isEditing = false;
  final Map<String, Map<String, TextEditingController>> _controllers = {};

  @override
  void dispose() {
    // Dispose all text controllers
    for (final categoryControllers in _controllers.values) {
      for (final controller in categoryControllers.values) {
        controller.dispose();
      }
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        actions: [
          Consumer<StudentProfileStore>(
            builder: (context, profileStore, _) {
              if (profileStore.profile.isEmpty) return const SizedBox.shrink();
              return IconButton(
                icon: Icon(_isEditing ? Icons.check : Icons.edit),
                tooltip: _isEditing ? 'Save Changes' : 'Edit Profile',
                onPressed: () {
                  if (_isEditing) {
                    _saveChanges(context);
                  }
                  setState(() => _isEditing = !_isEditing);
                },
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Language Level Card
            Consumer<LanguageLevelTracker>(
              builder: (context, levelTracker, _) {
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
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
                                const Text('Current Level', style: TextStyle(fontSize: 16)),
                                const SizedBox(height: 4),
                                Text(
                                  levelTracker.currentLevel,
                                  style: TextStyle(
                                    fontSize: 36,
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).colorScheme.primary,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          levelTracker.getLevelDescription(),
                          style: const TextStyle(fontSize: 14),
                        ),
                        const Divider(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Confidence',
                                  style: TextStyle(fontSize: 12, color: Colors.grey),
                                ),
                                Text(
                                  '${(levelTracker.confidence * 100).toStringAsFixed(0)}%',
                                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Trend',
                                  style: TextStyle(fontSize: 12, color: Colors.grey),
                                ),
                                Text(
                                  levelTracker.getTrend(),
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: _getTrendColor(context, levelTracker.getTrend()),
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Assessments',
                                  style: TextStyle(fontSize: 12, color: Colors.grey),
                                ),
                                Text(
                                  '${levelTracker.levelHistory.length}',
                                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 16),

            // Student Profile Card
            Consumer<StudentProfileStore>(
              builder: (context, profileStore, _) {
                final categorized = profileStore.getProfileByCategory();
                final hasData = profileStore.profile.isNotEmpty;

                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.person,
                              size: 28,
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              'Personal Facts',
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        if (!hasData)
                          const Text(
                            'No personal information collected yet. The bot will learn about you as you chat!',
                            style: TextStyle(fontSize: 14, color: Colors.grey),
                          )
                        else
                          ...categorized.entries.map((categoryEntry) {
                            final category = categoryEntry.key;
                            final items = categoryEntry.value;

                            if (items.isEmpty) return const SizedBox.shrink();

                            // Initialize controllers for this category if editing
                            if (_isEditing && !_controllers.containsKey(category)) {
                              _controllers[category] = {};
                              for (final entry in items.entries) {
                                _controllers[category]![entry.key] = TextEditingController(
                                  text: entry.value.toString(),
                                );
                              }
                            }

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _formatCategoryName(category),
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).colorScheme.primary,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                ...items.entries.map((entry) {
                                  if (_isEditing) {
                                    // Editable field
                                    final controller = _controllers[category]![entry.key]!;
                                    return Padding(
                                      padding: const EdgeInsets.only(bottom: 12.0),
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Text('• ', style: TextStyle(fontSize: 16)),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  _formatKey(entry.key),
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 14,
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                TextField(
                                                  controller: controller,
                                                  decoration: InputDecoration(
                                                    isDense: true,
                                                    contentPadding: const EdgeInsets.symmetric(
                                                      horizontal: 12,
                                                      vertical: 8,
                                                    ),
                                                    border: OutlineInputBorder(
                                                      borderRadius: BorderRadius.circular(8),
                                                    ),
                                                  ),
                                                  maxLines: null,
                                                ),
                                              ],
                                            ),
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.delete_outline, size: 20),
                                            onPressed: () => _deleteField(profileStore, category, entry.key),
                                            padding: EdgeInsets.zero,
                                            constraints: const BoxConstraints(),
                                          ),
                                        ],
                                      ),
                                    );
                                  } else {
                                    // Read-only display
                                    return Padding(
                                      padding: const EdgeInsets.only(bottom: 4.0),
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Text('• ', style: TextStyle(fontSize: 16)),
                                          Expanded(
                                            child: RichText(
                                              text: TextSpan(
                                                style: DefaultTextStyle.of(context).style,
                                                children: [
                                                  TextSpan(
                                                    text: '${_formatKey(entry.key)}: ',
                                                    style: const TextStyle(
                                                      fontWeight: FontWeight.w600,
                                                    ),
                                                  ),
                                                  TextSpan(text: '${entry.value}'),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }
                                }).toList(),
                                const SizedBox(height: 12),
                              ],
                            );
                          }).toList(),
                      ],
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 24),

            // Reset button at bottom
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Center(
                child: OutlinedButton.icon(
                  onPressed: () => _confirmReset(context),
                  icon: const Icon(Icons.refresh, color: Colors.red),
                  label: const Text(
                    'Reset All Data',
                    style: TextStyle(color: Colors.red),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.red),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),
            // Assessment History Card
            Consumer<LanguageLevelTracker>(
              builder: (context, levelTracker, _) {
                final history = levelTracker.levelHistory.reversed.take(5).toList();

                if (history.isEmpty) {
                  return const SizedBox.shrink();
                }

                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.history,
                              size: 28,
                              color: Theme.of(context).colorScheme.tertiary,
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              'Recent Assessments',
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        ...history.map((assessment) {
                          final timeAgo = _getTimeAgo(assessment.timestamp);
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      assessment.level,
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(context).colorScheme.primary,
                                      ),
                                    ),
                                    Text(
                                      timeAgo,
                                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  assessment.reasoning.length > 150
                                      ? '${assessment.reasoning.substring(0, 150)}...'
                                      : assessment.reasoning,
                                  style: const TextStyle(fontSize: 13),
                                ),
                                const Divider(height: 16),
                              ],
                            ),
                          );
                        }).toList(),
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

  void _saveChanges(BuildContext context) {
    final profileStore = Provider.of<StudentProfileStore>(context, listen: false);

    // Update profile with new values
    for (final category in _controllers.keys) {
      for (final key in _controllers[category]!.keys) {
        final newValue = _controllers[category]![key]!.text.trim();
        if (newValue.isNotEmpty) {
          profileStore.updateProfileItem(category, key, newValue);
        }
      }
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile updated successfully')),
    );
  }

  void _deleteField(StudentProfileStore profileStore, String category, String key) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Field'),
        content: Text('Delete "${_formatKey(key)}" from your profile?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              profileStore.removeProfileItem(category, key);
              setState(() {
                _controllers[category]?.remove(key);
              });
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Color _getTrendColor(BuildContext context, String trend) {
    if (trend.contains('Improving')) {
      return Colors.green;
    } else if (trend.contains('attention')) {
      return Colors.orange;
    } else {
      return Theme.of(context).colorScheme.primary;
    }
  }

  String _formatCategoryName(String category) {
    return category[0].toUpperCase() + category.substring(1);
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

  void _confirmReset(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset All Data'),
        content: const Text(
          'This will delete all student profile data and assessment history. Are you sure?',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);

              // Reset all data
              final profileStore = Provider.of<StudentProfileStore>(context, listen: false);
              final levelTracker = Provider.of<LanguageLevelTracker>(context, listen: false);
              final assessmentService = Provider.of<AssessmentService>(context, listen: false);

              await profileStore.clearProfile();
              await levelTracker.reset();
              await assessmentService.reset();

              if (context.mounted) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('All data reset successfully')));
              }
            },
            child: const Text('Reset', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
