import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/student_profile_store.dart';
import '../../models/settings_model.dart';
import '../../services/chat_service.dart';
import '../../database/database_service.dart';

class DangerZoneCard extends StatelessWidget {
  const DangerZoneCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.errorContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.warning, color: Theme.of(context).colorScheme.onErrorContainer),
                const SizedBox(width: 8),
                Text(
                  'Danger Zone',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Theme.of(context).colorScheme.onErrorContainer,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Warning: This will permanently delete all your data',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onErrorContainer,
                  ),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () => _confirmResetAllData(context),
              icon: Icon(
                Icons.delete_forever,
                color: Theme.of(context).colorScheme.onErrorContainer,
              ),
              label: Text(
                'Reset All Data',
                style: TextStyle(color: Theme.of(context).colorScheme.onErrorContainer),
              ),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: Theme.of(context).colorScheme.onErrorContainer),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmResetAllData(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset All Data?'),
        content: const Text(
          'This will permanently delete:\n'
          '• All conversations\n'
          '• Your profile information\n'
          '• Language level history\n'
          '• All settings\n\n'
          'This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _resetAllData(context);
            },
            child: const Text('Delete Everything', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _resetAllData(BuildContext context) async {
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Resetting all data...'), duration: Duration(seconds: 2)),
      );

      // Clear all stores
      final profileStore = context.read<StudentProfileStore>();
      final chatService = context.read<ChatService>();
      final settingsModel = context.read<SettingsModel>();
      
      await profileStore.clearProfile();
      chatService.clearConversation();
      
      // Remove profile picture
      await settingsModel.setProfilePicture(null);
      
      // Reset database
      await DatabaseService.clearAllData();

      if (!context.mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('All data has been reset'), backgroundColor: Colors.green),
      );
      
      // Go back to avoid errors
      Navigator.of(context).pop();
    } catch (e) {
      if (!context.mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error resetting data: $e'), backgroundColor: Colors.red),
      );
    }
  }
}
