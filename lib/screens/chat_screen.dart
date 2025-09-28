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
  }

  // Start the conversation with the bot greeting automatically
  Future<void> _checkForInitialAssessment() async {
    final contextManager = Provider.of<ContextManager>(context, listen: false);

    // Wait a moment to ensure the context manager is fully initialized
    await Future.delayed(const Duration(milliseconds: 500));

    if (contextManager.isInitialized && !_botGreetingSent) {
      setState(() {
        _botGreetingSent = true;
      });

      // Start the conversation with an empty message to trigger the AI's initial greeting
      // Hide this message from the conversation display
      final chatService = Provider.of<ChatService>(context, listen: false);
      await chatService.sendMessage('Hallo', hideUserMessage: true);
    }
  }

  Future<void> _initializeServices() async {
    final speechService = context.read<SpeechService>();
    final ttsService = context.read<TtsService>();

    await speechService.initialize();
    await ttsService.initialize();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Get the bottom safe area height
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    // Height for the controls area (adjust as needed)
    final controlsHeight = 160.0 + bottomPadding;

    return Scaffold(
      // No AppBar to maximize space for chat content
      body: TiledBackground(
        assetPath: 'assets/tile.png',
        overlayOpacity: 0.2, // Lighter overlay to see more of the tile pattern
        child: Stack(
          children: [
            // Main chat content - full screen with padding at bottom for controls
            Positioned.fill(
              child: Consumer<ChatService>(
                builder: (context, chatService, _) {
                  if (chatService.conversation.isNotEmpty) {
                    return ListView.builder(
                      controller: _scrollController,
                      // Add padding at the bottom to ensure messages aren't hidden behind controls
                      padding: EdgeInsets.fromLTRB(16.0, 16.0, 16.0, controlsHeight),
                      itemCount: chatService.conversation
                          .split('\n')
                          .where((line) => line.isNotEmpty)
                          .length,
                      itemBuilder: (context, index) {
                        final lines = chatService.conversation
                            .split('\n')
                            .where((line) => line.isNotEmpty)
                            .toList();
                        final line = lines[index];
                        final isUser = line.startsWith('User:');

                        // Check if this is a thinking message
                        if (line.contains('<thinking id=')) {
                          return const ThinkingBubble();
                        } else {
                          return ChatBubble(
                            message: line
                                .replaceFirst('User:', '')
                                .replaceFirst('Assistant:', '')
                                .trim(),
                            isUser: isUser,
                          );
                        }
                      },
                    );
                  } else {
                    // Show loading message while bot is preparing greeting
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

            // Bottom controls container with frosted glass effect
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                decoration: BoxDecoration(
                  // Add a subtle shadow at the top of the controls area
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: FrostedGlass(
                  blurAmount: 5.0,
                  tintColor: Colors.black,
                  tintOpacity: 0.8,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Live transcription preview
                        const TranscriptionPreview(cancelRecording: false),
                        // Bottom row with mic button and nav buttons
                        Row(
                          children: [
                            // Settings button
                            IconButton(
                              onPressed: () {
                                Navigator.of(
                                  context,
                                ).push(MaterialPageRoute(builder: (_) => const SettingsScreen()));
                              },
                              icon: Icon(
                                Icons.settings,
                                color: Theme.of(context).colorScheme.tertiary.withOpacity(0.8),
                                size: 26,
                              ),
                              tooltip: 'Settings',
                            ),
                            // Microphone button (centered)
                            Expanded(child: MicButton(onScrollToBottom: _scrollToBottom)),
                            // Debug button
                            IconButton(
                              onPressed: () {
                                Navigator.of(
                                  context,
                                ).push(MaterialPageRoute(builder: (_) => const DebugMenu()));
                              },
                              icon: Icon(
                                Icons.bug_report,
                                color: Theme.of(context).colorScheme.tertiary.withOpacity(0.8),
                                size: 26,
                              ),
                              tooltip: 'Debug Menu',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
