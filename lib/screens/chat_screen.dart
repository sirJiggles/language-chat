import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/chat_service.dart';
import '../services/context_manager.dart';
import '../services/speech_service.dart';
import '../services/tts_service.dart';
import '../widgets/chat_bubble.dart';
import '../widgets/chat_drawer.dart';
import '../widgets/chat_input_bar.dart';
import '../widgets/thinking_dots.dart';
import '../widgets/tiled_background.dart';
import 'settings_screen.dart';
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
    final chatService = context.read<ChatService>();

    await speechService.initialize();
    await ttsService.initialize();

    // Set the speech recognition locale to target language
    speechService.setLocaleFromLanguage(chatService.targetLanguage);
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
      drawer: ChatDrawer(onNewChat: () => _confirmNewChat(context)),
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
                  ChatInputBar(
                    textController: _textController,
                    onSendMessage: _sendTextMessage,
                    onScrollToBottom: _scrollToBottom,
                  ),
                ],
              ),
            ),
          ],
        ),
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

}
