import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/settings_model.dart';
import '../models/student_profile_store.dart';
import '../services/chat_service.dart';
import '../services/context_manager.dart';
import '../services/whisper_speech_service.dart';
import '../services/tts_service.dart';
import '../widgets/widgets.dart';
import 'onboarding_screen.dart';
import 'language_selection_screen.dart';

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
    final profileStore = Provider.of<StudentProfileStore>(context, listen: false);
    final ttsService = Provider.of<TtsService>(context, listen: false);

    // Wait a moment to ensure the context manager is fully initialized
    await Future.delayed(const Duration(milliseconds: 800));

    // Check if user has completed onboarding
    final onboardingCompleted = profileStore.getValue('onboarding_completed');
    if (onboardingCompleted == null && !_botGreetingSent) {
      // Show language selection first
      if (mounted) {
        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => LanguageSelectionScreen(
              onLanguagesSelected: (nativeLanguage, targetLanguage) async {
                // Navigate to level selection screen
                await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => OnboardingScreen(
                      nativeLanguage: nativeLanguage,
                      targetLanguage: targetLanguage,
                    ),
                  ),
                );
              },
            ),
          ),
        );
      }
    }

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
      final settings = Provider.of<SettingsModel>(context, listen: false);

      debugPrint('Sending initial greeting message');
      final response = await chatService.sendMessage('Hallo', hideUserMessage: true);

      // Handle audio based on settings
      if (settings.audioEnabled) {
        // Explicitly trigger TTS for the first message
        debugPrint('Explicitly speaking first message: "$response"');
        await Future.delayed(const Duration(milliseconds: 500)); // Give UI time to update
        // Start audio (don't await - let it play in background)
        ttsService.speak(response);
        // Reveal message after audio starts (not finishes)
        await Future.delayed(const Duration(milliseconds: 200));
        chatService.revealBotMessage();
      } else {
        // No audio, reveal immediately
        chatService.revealBotMessage();
      }
    }
  }

  Future<void> _initializeServices() async {
    final speechService = context.read<WhisperSpeechService>();
    final ttsService = context.read<TtsService>();
    final chatService = context.read<ChatService>();

    await speechService.initialize();
    await ttsService.initialize();

    speechService.setLocaleFromLanguage(chatService.targetLanguage);
  }

  // Handle chat service updates
  void _handleChatServiceUpdate() {
    final chatService = Provider.of<ChatService>(context, listen: false);

    // Reset greeting flag if conversation is empty (user cleared/reset data)
    if (chatService.conversationStore.messages.isEmpty && _botGreetingSent) {
      setState(() {
        _botGreetingSent = false;
      });
      // Trigger initial greeting again
      _checkForInitialAssessment();
    }

    // Auto-scroll to bottom when new messages arrive
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
    final settings = Provider.of<SettingsModel>(context, listen: false);

    final response = await chatService.sendMessage(text);

    // If audio is enabled, keep thinking indicator until audio starts
    // Otherwise, reveal message immediately
    if (settings.audioEnabled) {
      // Speak the response (don't await - let it play in background)
      try {
        final cleanResponse = response.replaceAll(RegExp(r'\([^)]*\)'), '').trim();
        debugPrint(
          'ChatScreen: Audio enabled, speaking response (length: ${cleanResponse.length})',
        );

        if (cleanResponse.isNotEmpty) {
          // Start audio (don't await - let it play in background)
          ttsService.speak(cleanResponse);
          // Give a tiny delay for audio to start, then reveal message
          await Future.delayed(const Duration(milliseconds: 200));
        } else {
          debugPrint('ChatScreen: Response empty after cleaning, skipping TTS');
        }

        chatService.revealBotMessage();
      } catch (e) {
        debugPrint('ChatScreen: Error speaking response: $e');
        // On error, reveal message anyway
        chatService.revealBotMessage();
      }
    } else {
      debugPrint('ChatScreen: Audio disabled, revealing message immediately');
      // Audio disabled, reveal immediately
      chatService.revealBotMessage();
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
      appBar: ChatAppBar(
        onNewChat: () => _confirmNewChat(context),
        onOpenDrawer: () => Scaffold.of(context).openDrawer(),
      ),
      drawer: ChatDrawer(onNewChat: () => _confirmNewChat(context)),
      body: IconTiledBackground(
        overlayOpacity: 0.9,
        spacing: 40,
        iconSize: 18.0,
        iconOpacity: 1,
        child: Stack(
          children: [
            // Main chat content (full screen)
            ChatMessagesList(
              scrollController: _scrollController,
              botGreetingSent: _botGreetingSent,
              onScrollToBottom: _scrollToBottom,
            ),

            // Bottom elements positioned at the bottom
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Consumer<SettingsModel>(
                builder: (context, settings, _) {
                  if (settings.conversationMode) {
                    // Conversation mode - large mic button with continuous recording
                    return ConversationModeBar(onScrollToBottom: _scrollToBottom);
                  } else {
                    // Normal mode - text input with mic button
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ChatInputBar(
                          textController: _textController,
                          onSendMessage: _sendTextMessage,
                          onScrollToBottom: _scrollToBottom,
                        ),
                      ],
                    );
                  }
                },
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
