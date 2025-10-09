import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/conversation_archive.dart';
import 'chat_bubble.dart';

class ChatDrawer extends StatelessWidget {
  final VoidCallback onNewChat;

  const ChatDrawer({super.key, required this.onNewChat});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          // Simple header with padding
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Icon(
                    Icons.chat_bubble_outline,
                    size: 28,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Conversations',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // New Chat button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context); // Close drawer
                onNewChat();
              },
              icon: const Icon(Icons.add),
              label: const Text('New Chat'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                minimumSize: const Size(double.infinity, 48),
              ),
            ),
          ),

          const SizedBox(height: 8),
          const Divider(),

          // Archived chats list
          Expanded(
            child: Consumer<ConversationArchiveStore>(
              builder: (context, archiveStore, _) {
                final archives = archiveStore.archives;

                if (archives.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Text(
                        'No archived conversations yet',
                        style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: archives.length,
                  itemBuilder: (context, index) {
                    final archive = archives[index];
                    return _ArchiveListTile(
                      archive: archive,
                      onTap: () {
                        Navigator.pop(context); // Close drawer
                        _viewArchive(context, archive);
                      },
                      onDelete: () => _confirmDelete(context, archiveStore, archive),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _viewArchive(BuildContext context, ArchivedConversation archive) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => _ArchiveDetailScreen(archive: archive)),
    );
  }

  void _confirmDelete(
    BuildContext context,
    ConversationArchiveStore store,
    ArchivedConversation archive,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Conversation'),
        content: Text('Delete "${archive.title}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              store.deleteConversation(archive.id);
              Navigator.pop(context);
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Conversation deleted')));
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

// Archive list tile widget
class _ArchiveListTile extends StatelessWidget {
  final ArchivedConversation archive;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _ArchiveListTile({required this.archive, required this.onTap, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final dateStr = _formatDate(archive.timestamp);

    return ListTile(
      leading: const Icon(Icons.chat_bubble_outline, size: 20),
      title: Text(
        archive.title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontSize: 14),
      ),
      subtitle: Text(
        '$dateStr • ${archive.messages.length} messages',
        style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant),
      ),
      trailing: IconButton(
        icon: const Icon(Icons.delete_outline, size: 20),
        onPressed: onDelete,
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(),
      ),
      onTap: onTap,
      dense: true,
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays == 0) {
      return 'Today';
    } else if (diff.inDays == 1) {
      return 'Yesterday';
    } else if (diff.inDays < 7) {
      return '${diff.inDays} days ago';
    } else {
      return '${date.month}/${date.day}/${date.year}';
    }
  }
}

// Archive detail screen
class _ArchiveDetailScreen extends StatelessWidget {
  final ArchivedConversation archive;

  const _ArchiveDetailScreen({required this.archive});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(archive.title)),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: archive.messages.length,
        itemBuilder: (context, index) {
          final message = archive.messages[index];
          return ChatBubble(message: message.content, isUser: message.isUser);
        },
      ),
    );
  }
}
