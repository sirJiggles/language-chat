import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/settings_model.dart';
import '../../models/student_profile_store.dart';

class ProfilePictureCard extends StatelessWidget {
  const ProfilePictureCard({super.key});

  Future<void> _pickImage(BuildContext context) async {
    final source = await showDialog<ImageSource>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choose Photo Source'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take Photo'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from Gallery'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );

    if (source != null && context.mounted) {
      try {
        final ImagePicker picker = ImagePicker();
        final XFile? image = await picker.pickImage(
          source: source,
          maxWidth: 512,
          maxHeight: 512,
          imageQuality: 85,
        );
        if (image != null && context.mounted) {
          await context.read<SettingsModel>().setProfilePicture(image.path);
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${e.toString()}'),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Center the avatar content
            Center(
              child: Column(
                children: [
            Consumer2<SettingsModel, StudentProfileStore>(
              builder: (context, settings, profileStore, _) {
                final profilePicture = settings.profilePicturePath;

                if (profilePicture != null && File(profilePicture).existsSync()) {
                  return CircleAvatar(
                    radius: 60,
                    backgroundImage: FileImage(File(profilePicture)),
                  );
                } else {
                  // Get user's name initial - check multiple possible keys
                  String initial = 'U';
                  final name = profileStore.getValue('student_name') ?? 
                              profileStore.getValue('name') ?? 
                              profileStore.getValue('user_name');
                  if (name != null && name.toString().isNotEmpty) {
                    initial = name.toString()[0].toUpperCase();
                  }
                  
                  return CircleAvatar(
                    radius: 60,
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    child: Text(
                      initial,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 48,
                      ),
                    ),
                  );
                }
              },
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () => _pickImage(context),
              icon: const Icon(Icons.camera_alt),
              label: const Text('Change Photo'),
            ),
            const SizedBox(height: 8),
            Consumer<SettingsModel>(
              builder: (context, settings, _) {
                if (settings.profilePicturePath != null) {
                  return TextButton.icon(
                    onPressed: () {
                      context.read<SettingsModel>().setProfilePicture(null);
                    },
                    icon: const Icon(Icons.delete_outline),
                    label: const Text('Remove Photo'),
                    style: TextButton.styleFrom(
                      foregroundColor: Theme.of(context).colorScheme.error,
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
