import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/chat_service.dart';
import '../services/speech_service.dart';
import '../services/tts_service.dart';
import '../services/context_manager.dart';
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
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              if (value == 'settings') {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const SettingsScreen()),
                );
              } else if (value == 'debug') {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const DebugMenu()),
                );
              }
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem<String>(
                value: 'settings',
                child: Row(
                  children: [
                    Icon(Icons.settings),
                    SizedBox(width: 12),
                    Text('Settings'),
                  ],
                ),
              ),
              const PopupMenuItem<String>(
                value: 'debug',
                child: Row(
                  children: [
                    Icon(Icons.bug_report),
                    SizedBox(width: 12),
                    Text('Debug Menu'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: TiledBackground(
        assetPath: 'assets/tile.png',
        overlayOpacity: 0.2,
        child: Column(
          children: [
            // Main chat content
            Expanded(
              child: Consumer<ChatService>(
                builder: (context, chatService, _) {
                  final messages = chatService.conversationStore.messages;

                  if (messages.isNotEmpty) {
                    final thinkingMessages = messages.where((msg) => msg.isThinking).toList();
                    final isThinking = thinkingMessages.isNotEmpty || chatService.isThinking;
                    
                    final visibleMessages = messages.where((msg) => 
                      !msg.isThinking &&
                      !msg.content.contains('<thinking id=') &&
                      msg.content.isNotEmpty
                    ).toList();
                    
                    // Schedule a scroll to bottom after the UI updates
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      _scrollToBottom();
                    });
                    
                    return ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(16.0),
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
                          return const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                ThinkingDots(),
                                SizedBox(height: 16),
                                Text(
                                  'Starting conversation...',
                                  style: TextStyle(fontSize: 16.0, color: Colors.grey),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          );
                        } else {
                          return const Center(
                            child: Text(
                              'Welcome!',
                              style: TextStyle(fontSize: 16.0, color: Colors.grey),
                              textAlign: TextAlign.center,
                            ),
                          );
                        }
                      },
                    );
                  }
                },
              ),
            ),

            // Live transcription preview
            const TranscriptionPreview(cancelRecording: false),

            // WhatsApp-style bottom input area
            Container(
              padding: EdgeInsets.fromLTRB(8.0, 8.0, 8.0, bottomPadding + 8.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Text input field
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
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
                        style: const TextStyle(color: Colors.black87),
                        decoration: const InputDecoration(
                          hintText: 'Message',
                          hintStyle: TextStyle(color: Colors.black38),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
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
                  // Mic button - smaller and without background
                  SizedBox(
                    width: 48,
                    height: 48,
                    child: MicButton(onScrollToBottom: _scrollToBottom),
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
