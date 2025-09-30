import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/chat_service.dart';
import '../services/speech_service.dart';
import '../services/tts_service.dart';
import '../services/context_manager.dart';
import '../models/conversation_archive.dart';
import '../widgets/widgets.dart';
import '../screens/settings_screen.dart';
import '../debug/debug_menu.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  ChatScreenState createState() => ChatScreenState();
}

class ChatScreenState extends State<ChatScreen> {
  bool _botGreetingSent = false;
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _textController = TextEditingController();

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _initializeServices();

    // Schedule a check for initial assessment mode after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkForInitialAssessment();
    });

    // Listen to chat service changes to auto-scroll
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final chatService = Provider.of<ChatService>(context, listen: false);
      chatService.addListener(_handleChatServiceUpdate);
    });
  }

  // Start the conversation with the bot greeting automatically
  Future<void> _checkForInitialAssessment() async {
    final contextManager = Provider.of<ContextManager>(context, listen: false);
    final ttsService = Provider.of<TtsService>(context, listen: false);

    // Wait a moment to ensure the context manager is fully initialized
    await Future.delayed(const Duration(milliseconds: 800));

    if (contextManager.isInitialized && !_botGreetingSent) {
      setState(() {
        _botGreetingSent = true;
      });

      // Ensure TTS is fully initialized before sending the first message
      // This helps with the first message audio playback
      debugPrint('Ensuring TTS is ready before first message...');
      await ttsService.initialize();

      // Give a little more time for TTS to be fully ready
      await Future.delayed(const Duration(milliseconds: 300));

      // Start the conversation with an empty message to trigger the AI's initial greeting
      // Hide this message from the conversation display
      final chatService = Provider.of<ChatService>(context, listen: false);
      debugPrint('Sending initial greeting message');
      final response = await chatService.sendMessage('Hallo', hideUserMessage: true);

      // Explicitly trigger TTS for the first message
      debugPrint('Explicitly speaking first message: "$response"');
      await Future.delayed(const Duration(milliseconds: 500)); // Give UI time to update
      await ttsService.speak(response);
    }
  }

  Future<void> _initializeServices() async {
    final speechService = context.read<SpeechService>();
    final ttsService = context.read<TtsService>();

    await speechService.initialize();
    await ttsService.initialize();
  }

  // Handle chat service updates
  void _handleChatServiceUpdate() {
    // Schedule a scroll to bottom after the UI updates
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

  Future<void> _sendTextMessage() async {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    // Clear the text field
    _textController.clear();

    // Send the message
    final chatService = Provider.of<ChatService>(context, listen: false);
    final ttsService = Provider.of<TtsService>(context, listen: false);

    final response = await chatService.sendMessage(text);

    // Speak the response
    try {
      final cleanResponse = response.replaceAll(RegExp(r'\([^)]*\)'), '');
      await ttsService.speak(cleanResponse);
    } catch (e) {
      debugPrint('Error speaking response: $e');
    }

    // Auto-scroll to bottom
    _scrollToBottom();
  }

  @override
  void dispose() {
    // Remove listener when disposing
    final chatService = Provider.of<ChatService>(context, listen: false);
    chatService.removeListener(_handleChatServiceUpdate);
    _scrollController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Get the bottom safe area height
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: AppBar(
              backgroundColor: Theme.of(context).colorScheme.surface.withOpacity(0.7),
              elevation: 0,
              leading: Builder(
                builder: (context) => IconButton(
                  icon: const Icon(Icons.menu),
                  onPressed: () => Scaffold.of(context).openDrawer(),
                ),
              ),
              actions: [
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert),
                  onSelected: (value) {
                    if (value == 'settings') {
                      Navigator.of(
                        context,
                      ).push(MaterialPageRoute(builder: (_) => const SettingsScreen()));
                    } else if (value == 'debug') {
                      Navigator.of(
                        context,
                      ).push(MaterialPageRoute(builder: (_) => const DebugMenu()));
                    } else if (value == 'new_chat') {
                      _confirmNewChat(context);
                    }
                  },
                  itemBuilder: (BuildContext context) => [
                    const PopupMenuItem<String>(
                      value: 'new_chat',
                      child: Row(
                        children: [Icon(Icons.add_comment), SizedBox(width: 12), Text('New Chat')],
                      ),
                    ),
                    const PopupMenuItem<String>(
                      value: 'settings',
                      child: Row(
                        children: [Icon(Icons.settings), SizedBox(width: 12), Text('Settings')],
                      ),
                    ),
                    const PopupMenuItem<String>(
                      value: 'debug',
                      child: Row(
                        children: [Icon(Icons.bug_report), SizedBox(width: 12), Text('Debug Menu')],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      drawer: _buildDrawer(context),
      body: TiledBackground(
        assetPath: 'assets/tile.png',
        overlayOpacity: 0.5,
        overlayColor: const Color(0xFF261D45), // Purple overlay matching the theme
        child: Stack(
          children: [
            // Main chat content (full screen)
            Consumer<ChatService>(
              builder: (context, chatService, _) {
                final messages = chatService.conversationStore.messages;

                if (messages.isNotEmpty) {
                  final thinkingMessages = messages.where((msg) => msg.isThinking).toList();
                  final isThinking = thinkingMessages.isNotEmpty || chatService.isThinking;

                  final visibleMessages = messages
                      .where(
                        (msg) =>
                            !msg.isThinking &&
                            !msg.content.contains('<thinking id=') &&
                            msg.content.isNotEmpty,
                      )
                      .toList();

                  // Schedule a scroll to bottom after the UI updates
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    _scrollToBottom();
                  });

                  return ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.only(
                      top: kToolbarHeight + 40,
                      left: 10.0,
                      right: 10.0,
                      bottom: 80.0, // Extra padding for frosted glass bottom bar
                    ),
                    itemCount: isThinking ? visibleMessages.length + 1 : visibleMessages.length,
                    itemBuilder: (context, index) {
                      if (isThinking && index == visibleMessages.length) {
                        return const ThinkingBubble();
                      }

                      final message = visibleMessages[index];
                      return ChatBubble(message: message.content, isUser: message.isUser);
                    },
                  );
                } else {
                  return Consumer<ContextManager>(
                    builder: (context, contextManager, _) {
                      if (!_botGreetingSent) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const ThinkingDots(),
                              const SizedBox(height: 16),
                              Text(
                                'Starting conversation...',
                                style: TextStyle(
                                  fontSize: 16.0,
                                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        );
                      } else {
                        return Center(
                          child: Text(
                            'Welcome!',
                            style: TextStyle(
                              fontSize: 16.0,
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        );
                      }
                    },
                  );
                }
              },
            ),

            // Bottom elements positioned at the bottom
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // WhatsApp-style bottom input area with frosted glass
                  ClipRRect(
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        color: Theme.of(context).colorScheme.surface.withOpacity(0.7),
                        padding: EdgeInsets.fromLTRB(8.0, 8.0, 8.0, bottomPadding + 8.0),
                        child: Consumer<SpeechService>(
                          builder: (context, speechService, _) {
                            final isListening = speechService.isListening;

                            // Update text field with speech as user speaks
                            if (isListening) {
                              _textController.text = speechService.lastWords;
                            }

                            return Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                // Text input field
                                Expanded(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.surface.withOpacity(0.95),
                                      borderRadius: BorderRadius.circular(24),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.1),
                                          blurRadius: 4,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: TextField(
                                      controller: _textController,
                                      style: TextStyle(
                                        color: Theme.of(context).colorScheme.onSurface,
                                      ),
                                      decoration: InputDecoration(
                                        hintText: 'Message',
                                        hintStyle: TextStyle(
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.onSurface.withOpacity(0.5),
                                        ),
                                        border: InputBorder.none,
                                        contentPadding: const EdgeInsets.symmetric(
                                          horizontal: 20,
                                          vertical: 12,
                                        ),
                                      ),
                                      maxLines: null,
                                      textInputAction: TextInputAction.send,
                                      onSubmitted: (_) => _sendTextMessage(),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                // Mic/Send button
                                ValueListenableBuilder<TextEditingValue>(
                                  valueListenable: _textController,
                                  builder: (context, value, child) {
                                    final hasText = value.text.trim().isNotEmpty;

                                    // Show send button when there's text AND not listening
                                    // Show mic when empty OR currently listening
                                    return SizedBox(
                                      width: 48,
                                      height: 48,
                                      child: (hasText && !isListening)
                                          ? IconButton(
                                              onPressed: _sendTextMessage,
                                              icon: Container(
                                                width: 48,
                                                height: 48,
                                                decoration: BoxDecoration(
                                                  color: Theme.of(context).colorScheme.primary,
                                                  shape: BoxShape.circle,
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.black.withOpacity(0.2),
                                                      blurRadius: 8,
                                                      offset: const Offset(0, 4),
                                                    ),
                                                  ],
                                                ),
                                                child: Icon(
                                                  Icons.send,
                                                  color: Theme.of(context).colorScheme.onPrimary,
                                                  size: 24,
                                                ),
                                              ),
                                              padding: EdgeInsets.zero,
                                            )
                                          : MicButton(onScrollToBottom: _scrollToBottom),
                                    );
                                  },
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
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
                _confirmNewChat(context);
              },
              icon: const Icon(Icons.add),
              label: const Text('New Chat'),
              style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 48)),
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
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24.0),
                      child: Text(
                        'No archived conversations yet',
                        style: TextStyle(color: Colors.grey),
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

  void _confirmNewChat(BuildContext context) {
    final chatService = Provider.of<ChatService>(context, listen: false);

    // Check if there are messages to archive
    if (chatService.conversationStore.messages.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('No conversation to archive')));
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Start New Chat'),
        content: const Text(
          'This will archive your current conversation and start a new one. Continue?',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await chatService.archiveAndStartNew();
              setState(() {
                _botGreetingSent = false;
              });
              // Trigger new greeting
              _checkForInitialAssessment();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Conversation archived. Starting new chat...')),
              );
            },
            child: const Text('Start New Chat'),
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
        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
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
      return '${diff.inDays}d ago';
    } else {
      return '${date.month}/${date.day}';
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
      body: Column(
        children: [
          // Header with date
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16.0),
            color: Theme.of(context).colorScheme.surfaceVariant,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _formatDetailDate(archive.timestamp),
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${archive.messages.length} messages',
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
          // Messages
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: archive.messages.length,
              itemBuilder: (context, index) {
                final message = archive.messages[index];
                return ChatBubble(message: message.content, isUser: message.isUser);
              },
            ),
          ),
        ],
      ),
    );
  }

  String _formatDetailDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final hour = date.hour > 12 ? date.hour - 12 : (date.hour == 0 ? 12 : date.hour);
    final amPm = date.hour >= 12 ? 'PM' : 'AM';
    return '${months[date.month - 1]} ${date.day}, ${date.year} • $hour:${date.minute.toString().padLeft(2, '0')} $amPm';
  }
}
