import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'screens/chat_screen.dart';
import 'services/chat_service.dart';
import 'services/speech_service.dart';
import 'services/tts_service.dart';
import 'services/context_manager.dart';
import 'services/assessment_service.dart';
import 'models/settings_model.dart';
import 'models/student_profile_store.dart';
import 'models/language_level_tracker.dart';

void main() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();
  
  // Set up error handling
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    debugPrint('Flutter error: ${details.exception}');
  };
  
  // Initialize platform channels early
  try {
    const platform = MethodChannel('com.language_learning_chat/audio_player');
    await platform.invokeMethod('initialize');
  } catch (e) {
    // Ignore errors, this is just to ensure the channel is registered
    debugPrint('Audio player initialization: $e');
  }

  // Initialize context manager first
  final contextManager = ContextManager();
  await contextManager.initialize();
  
  // Initialize settings model
  final settingsModel = SettingsModel();
  
  // Initialize student profile store and level tracker
  final profileStore = StudentProfileStore();
  final levelTracker = LanguageLevelTracker();
  
  // Connect the new stores to the context manager
  contextManager.setStores(
    profileStore: profileStore,
    levelTracker: levelTracker,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: contextManager),
        ChangeNotifierProvider.value(value: settingsModel),
        ChangeNotifierProvider.value(value: profileStore),
        ChangeNotifierProvider.value(value: levelTracker),

        // Create assessment service with new architecture
        ChangeNotifierProvider(
          create: (_) => AssessmentService(
            apiKey: const String.fromEnvironment(
              'OPENAI_API_KEY',
              defaultValue: '',
            ),
            profileStore: profileStore,
            levelTracker: levelTracker,
          ),
        ),

        // Other services
        ChangeNotifierProvider(
          create: (context) => ChatService(
            targetLanguage: const String.fromEnvironment(
              'TARGET_LANGUAGE',
              defaultValue: 'Spanish',
            ),
            contextManager: contextManager,
            assessmentService: Provider.of<AssessmentService>(context, listen: false),
            openaiApiKey: const String.fromEnvironment(
              'OPENAI_API_KEY',
              defaultValue: '',
            ),
          ),
        ),
        ChangeNotifierProvider(create: (_) => SpeechService()),
        ChangeNotifierProvider(
          create: (context) => TtsService(
            settingsModel: settingsModel,
            openaiApiKey: const String.fromEnvironment(
              'OPENAI_API_KEY',
              defaultValue: '',
            ),
          ),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Define our custom colors
    const primaryColor = Color(0xFF3090cf); // Green as primary
    const secondaryColor = Color(0xFF3090cf); // Teal as secondary
    const tertiaryColor = Color(0xFF3090cf); // Blue as tertiary

    return MaterialApp(
      title: 'Language Chat',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.dark(
          primary: primaryColor,
          secondary: secondaryColor,
          tertiary: tertiaryColor,
          surface: const Color(0xFF121212),
          background: const Color(0xFF121212),
          onPrimary: Colors.white,
          onSecondary: Colors.black,
          onTertiary: Colors.black,
        ),
        useMaterial3: true,
        textTheme: GoogleFonts.nunitoTextTheme(ThemeData.dark().textTheme),
        cardColor: const Color(0xFF1E1E1E),
        dialogBackgroundColor: const Color(0xFF1E1E1E),
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.dark(
          primary: primaryColor,
          secondary: secondaryColor,
          tertiary: tertiaryColor,
          surface: const Color(0xFF121212),
          background: const Color(0xFF121212),
          onPrimary: Colors.white,
          onSecondary: Colors.black,
          onTertiary: Colors.black,
        ),
        useMaterial3: true,
        textTheme: GoogleFonts.nunitoTextTheme(ThemeData.dark().textTheme),
        cardColor: const Color(0xFF1E1E1E),
        dialogBackgroundColor: const Color(0xFF1E1E1E),
      ),
      themeMode: ThemeMode.dark, // Force dark mode
      home: const ChatScreen(),
    );
  }
}
