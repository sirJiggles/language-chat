import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/student_profile_store.dart';

class ProfileDataCard extends StatefulWidget {
  const ProfileDataCard({super.key});

  @override
  State<ProfileDataCard> createState() => ProfileDataCardState();
}

class ProfileDataCardState extends State<ProfileDataCard> {
  bool _isEditing = false;
  final Map<String, Map<String, TextEditingController>> _controllers = {};

  @override
  void dispose() {
    for (final categoryControllers in _controllers.values) {
      for (final controller in categoryControllers.values) {
        controller.dispose();
      }
    }
    super.dispose();
  }

  void _deleteField(StudentProfileStore profileStore, String category, String key) {
    profileStore.removeProfileItem(category, key);
    _controllers[category]?.remove(key);
  }

  String _formatCategoryName(String category) {
    return category.split('_').map((word) => 
      word.isEmpty ? '' : word[0].toUpperCase() + word.substring(1)
    ).join(' ');
  }

  String _formatKey(String key) {
    return key.split('_').map((word) => 
      word.isEmpty ? '' : word[0].toUpperCase() + word.substring(1)
    ).join(' ');
  }

  Map<String, TextEditingController> getControllers(String category) {
    return _controllers[category] ?? {};
  }

  void _toggleEdit(StudentProfileStore profileStore) {
    if (_isEditing) {
      // Save changes
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
    setState(() => _isEditing = !_isEditing);
  }

  // Fields to exclude from Personal Facts (these are in settings or system fields)
  static const _excludedFields = {
    'native_language',
    'target_language',
    'onboarding_completed',
    'self_assessed_level',
    'self_assessment_date',
  };

  Map<String, Map<String, dynamic>> _filterCategories(Map<String, Map<String, dynamic>> categorized) {
    final filtered = <String, Map<String, dynamic>>{};
    
    for (final entry in categorized.entries) {
      final category = entry.key;
      final items = entry.value;
      
      // Filter out excluded fields
      final filteredItems = Map<String, dynamic>.from(items)
        ..removeWhere((key, value) => _excludedFields.contains(key));
      
      if (filteredItems.isNotEmpty) {
        filtered[category] = filteredItems;
      }
    }
    
    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<StudentProfileStore>(
      builder: (context, profileStore, _) {
        final categorized = _filterCategories(profileStore.getProfileByCategory());
        final hasData = categorized.isNotEmpty;

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
                    const Expanded(
                      child: Text(
                        'Personal Facts',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                    if (hasData)
                      IconButton(
                        icon: Icon(_isEditing ? Icons.check : Icons.edit),
                        tooltip: _isEditing ? 'Save Changes' : 'Edit Profile',
                        onPressed: () => _toggleEdit(profileStore),
                        color: Theme.of(context).colorScheme.primary,
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

                    return _CategorySection(
                      category: category,
                      items: items,
                      isEditing: _isEditing,
                      controllers: _controllers[category] ?? {},
                      onDeleteField: (key) => _deleteField(profileStore, category, key),
                      formatCategoryName: _formatCategoryName,
                      formatKey: _formatKey,
                    );
                  }).toList(),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _CategorySection extends StatelessWidget {
  final String category;
  final Map<String, dynamic> items;
  final bool isEditing;
  final Map<String, TextEditingController> controllers;
  final Function(String) onDeleteField;
  final String Function(String) formatCategoryName;
  final String Function(String) formatKey;

  const _CategorySection({
    required this.category,
    required this.items,
    required this.isEditing,
    required this.controllers,
    required this.onDeleteField,
    required this.formatCategoryName,
    required this.formatKey,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          formatCategoryName(category),
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(height: 8),
        ...items.entries.map((entry) {
          if (isEditing) {
            return _EditableProfileField(
              fieldKey: entry.key,
              controller: controllers[entry.key]!,
              onDelete: () => onDeleteField(entry.key),
              formatKey: formatKey,
            );
          } else {
            return _ReadOnlyProfileField(
              fieldKey: entry.key,
              value: entry.value.toString(),
              formatKey: formatKey,
            );
          }
        }).toList(),
        const SizedBox(height: 12),
      ],
    );
  }
}

class _EditableProfileField extends StatelessWidget {
  final String fieldKey;
  final TextEditingController controller;
  final VoidCallback onDelete;
  final String Function(String) formatKey;

  const _EditableProfileField({
    required this.fieldKey,
    required this.controller,
    required this.onDelete,
    required this.formatKey,
  });

  @override
  Widget build(BuildContext context) {
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
                  formatKey(fieldKey),
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
            onPressed: onDelete,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }
}

class _ReadOnlyProfileField extends StatelessWidget {
  final String fieldKey;
  final String value;
  final String Function(String) formatKey;

  const _ReadOnlyProfileField({
    required this.fieldKey,
    required this.value,
    required this.formatKey,
  });

  @override
  Widget build(BuildContext context) {
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
                    text: '${formatKey(fieldKey)}: ',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  TextSpan(text: value),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
