import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'screens/chat_screen.dart';
import 'services/chat_service.dart';
import 'services/speech_service.dart';
import 'services/tts_service.dart';
import 'services/context_manager.dart';
import 'services/assessment_service.dart';
import 'services/word_definition_service.dart';
import 'models/settings_model.dart';
import 'models/student_profile_store.dart';
import 'models/language_level_tracker.dart';
import 'models/conversation_archive.dart';
import 'database/database_service.dart';

void main() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();

  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    debugPrint('Flutter error: ${details.exception}');
  };

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialize Isar database FIRST
  debugPrint('Initializing Isar database...');
  await DatabaseService.initialize();
  final stats = await DatabaseService.getStats();
  debugPrint('Database initialized with: $stats');

  // Initialize context manager
  final contextManager = ContextManager();
  await contextManager.initialize();

  // Initialize settings model
  final settingsModel = SettingsModel();

  // Initialize student profile store and level tracker
  final profileStore = StudentProfileStore();
  await profileStore.initialize();
  final levelTracker = LanguageLevelTracker();
  await levelTracker.initialize();

  // Create conversation archive store
  final archiveStore = ConversationArchiveStore();
  await archiveStore.initialize();

  // Create word definition service
  final wordDefinitionService = WordDefinitionService(
    openaiApiKey: const String.fromEnvironment('OPENAI_API_KEY', defaultValue: ''),
  );

  // Connect the new stores to the context manager
  contextManager.setStores(profileStore: profileStore, levelTracker: levelTracker);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: contextManager),
        ChangeNotifierProvider.value(value: settingsModel),
        ChangeNotifierProvider.value(value: profileStore),
        ChangeNotifierProvider.value(value: levelTracker),
        ChangeNotifierProvider.value(value: archiveStore),
        Provider.value(value: wordDefinitionService),

        // Create assessment service with new architecture
        ChangeNotifierProvider(
          create: (_) => AssessmentService(
            apiKey: const String.fromEnvironment('OPENAI_API_KEY', defaultValue: ''),
            profileStore: profileStore,
            levelTracker: levelTracker,
          ),
        ),

        // Other services
        ChangeNotifierProvider(
          create: (context) => ChatService(
            targetLanguage: const String.fromEnvironment('TARGET_LANGUAGE', defaultValue: 'German'),
            contextManager: contextManager,
            assessmentService: Provider.of<AssessmentService>(context, listen: false),
            archiveStore: archiveStore,
            openaiApiKey: const String.fromEnvironment('OPENAI_API_KEY', defaultValue: ''),
          ),
        ),
        ChangeNotifierProvider(create: (_) => SpeechService()),
        ChangeNotifierProvider(
          create: (context) => TtsService(
            settingsModel: settingsModel,
            openaiApiKey: const String.fromEnvironment('OPENAI_API_KEY', defaultValue: ''),
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
    // Define our custom colors based on cyberpunk theme
    const primaryColor = Color(0xFF00FF9C); // Bright cyan-green as primary
    const secondaryColor = Color(0xFF00ffc8); // Cyan as secondary
    const tertiaryColor = Color(0xFF00b0ff); // Blue as tertiary

    // Create italic text theme
    final baseTextTheme = ThemeData.dark().textTheme;
    final italicTextTheme = TextTheme(
      displayLarge: baseTextTheme.displayLarge?.copyWith(
        fontFamily: 'DankMono',
        fontStyle: FontStyle.italic,
      ),
      displayMedium: baseTextTheme.displayMedium?.copyWith(
        fontFamily: 'DankMono',
        fontStyle: FontStyle.italic,
      ),
      displaySmall: baseTextTheme.displaySmall?.copyWith(
        fontFamily: 'DankMono',
        fontStyle: FontStyle.italic,
      ),
      headlineLarge: baseTextTheme.headlineLarge?.copyWith(
        fontFamily: 'DankMono',
        fontStyle: FontStyle.italic,
      ),
      headlineMedium: baseTextTheme.headlineMedium?.copyWith(
        fontFamily: 'DankMono',
        fontStyle: FontStyle.italic,
      ),
      headlineSmall: baseTextTheme.headlineSmall?.copyWith(
        fontFamily: 'DankMono',
        fontStyle: FontStyle.italic,
      ),
      titleLarge: baseTextTheme.titleLarge?.copyWith(
        fontFamily: 'DankMono',
        fontStyle: FontStyle.italic,
      ),
      titleMedium: baseTextTheme.titleMedium?.copyWith(
        fontFamily: 'DankMono',
        fontStyle: FontStyle.italic,
      ),
      titleSmall: baseTextTheme.titleSmall?.copyWith(
        fontFamily: 'DankMono',
        fontStyle: FontStyle.italic,
      ),
      bodyLarge: baseTextTheme.bodyLarge?.copyWith(
        fontFamily: 'DankMono',
        fontStyle: FontStyle.italic,
      ),
      bodyMedium: baseTextTheme.bodyMedium?.copyWith(
        fontFamily: 'DankMono',
        fontStyle: FontStyle.italic,
      ),
      bodySmall: baseTextTheme.bodySmall?.copyWith(
        fontFamily: 'DankMono',
        fontStyle: FontStyle.italic,
      ),
      labelLarge: baseTextTheme.labelLarge?.copyWith(
        fontFamily: 'DankMono',
        fontStyle: FontStyle.italic,
      ),
      labelMedium: baseTextTheme.labelMedium?.copyWith(
        fontFamily: 'DankMono',
        fontStyle: FontStyle.italic,
      ),
      labelSmall: baseTextTheme.labelSmall?.copyWith(
        fontFamily: 'DankMono',
        fontStyle: FontStyle.italic,
      ),
    );

    return MaterialApp(
      title: 'Language Chat',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.dark(
          primary: primaryColor,
          secondary: secondaryColor,
          tertiary: tertiaryColor,
          surface: const Color(0xFF261D45), // Purple-ish dark background
          background: const Color(0xFF261D45),
          onPrimary: const Color(0xFF001107), // Dark text on bright primary
          onSecondary: const Color(0xFF001107),
          onTertiary: Colors.white,
          surfaceVariant: const Color(0xFF372963), // Lighter purple for cards
        ),
        useMaterial3: true,
        textTheme: italicTextTheme,
        cardColor: const Color(0xFF372963), // Lighter purple for cards
        dialogBackgroundColor: const Color(0xFF372963),
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.dark(
          primary: primaryColor,
          secondary: secondaryColor,
          tertiary: tertiaryColor,
          surface: const Color(0xFF261D45), // Purple-ish dark background
          background: const Color(0xFF261D45),
          onPrimary: const Color(0xFF001107), // Dark text on bright primary
          onSecondary: const Color(0xFF001107),
          onTertiary: Colors.white,
          surfaceVariant: const Color(0xFF372963), // Lighter purple for cards
        ),
        useMaterial3: true,
        textTheme: italicTextTheme,
        cardColor: const Color(0xFF372963), // Lighter purple for cards
        dialogBackgroundColor: const Color(0xFF372963),
      ),
      themeMode: ThemeMode.dark, // Force dark mode
      home: const ChatScreen(),
    );
  }
}
