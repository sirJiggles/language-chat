import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'screens/chat_screen.dart';
import 'services/chat_service.dart';
import 'services/whisper_speech_service.dart';
import 'services/tts_service.dart';
import 'services/context_manager.dart';
import 'services/comprehensive_assessment_service.dart';
import 'services/word_definition_service.dart';
import 'services/clarification_service.dart';
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

  // Create clarification service
  final clarificationService = ClarificationService(
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
        ChangeNotifierProvider.value(value: clarificationService),

        // Create comprehensive assessment service
        ChangeNotifierProvider(
          create: (_) => ComprehensiveAssessmentService(
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
            assessmentService: Provider.of<ComprehensiveAssessmentService>(context, listen: false),
            archiveStore: archiveStore,
            openaiApiKey: const String.fromEnvironment('OPENAI_API_KEY', defaultValue: ''),
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => WhisperSpeechService(
            apiKey: const String.fromEnvironment('OPENAI_API_KEY', defaultValue: ''),
          ),
        ),
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
    return Consumer<SettingsModel>(
      builder: (context, settings, _) {
        return MaterialApp(
          title: 'Language Chat',
          debugShowCheckedModeBanner: false,
          theme: _buildLightTheme(),
          darkTheme: _buildDarkTheme(),
          themeMode: settings.isDarkMode ? ThemeMode.dark : ThemeMode.light,
          home: const ChatScreen(),
        );
      },
    );
  }

  ThemeData _buildLightTheme() {
    // Blue Material Design theme - light mode
    const primary = Color(0xFF36618E); // Blue
    const secondary = Color(0xFF535F70); // Blue-gray
    const tertiary = Color(0xFF6B5778); // Purple
    const surface = Color(0xFFF8F9FF); // Light blue-white
    
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.light(
        primary: primary,
        secondary: secondary,
        tertiary: tertiary,
        surface: surface,
        background: surface,
        onPrimary: const Color(0xFFFFFFFF),
        onSecondary: const Color(0xFFFFFFFF),
        onTertiary: const Color(0xFFFFFFFF),
        onSurface: const Color(0xFF191C20),
        onBackground: const Color(0xFF191C20),
        surfaceVariant: const Color(0xFFE1E2E8),
        outline: const Color(0xFF73777F),
        outlineVariant: const Color(0xFFC3C7CF),
        primaryContainer: const Color(0xFFD1E4FF),
        secondaryContainer: const Color(0xFFD7E3F7),
        tertiaryContainer: const Color(0xFFF2DAFF),
      ),
      cardColor: surface,
      scaffoldBackgroundColor: surface,
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFFF8F9FF),
        foregroundColor: Color(0xFF191C20),
        elevation: 0,
        centerTitle: false,
      ),
    );
  }

  ThemeData _buildDarkTheme() {
    // Blue Material Design theme - dark mode
    const primary = Color(0xFFA0CAFD); // Light blue
    const secondary = Color(0xFFBBC7DB); // Light blue-gray
    const tertiary = Color(0xFFD6BEE4); // Light purple
    const surface = Color(0xFF111418); // Very dark
    const background = Color(0xFF0B0E13); // Darker
    
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.dark(
        primary: primary,
        secondary: secondary,
        tertiary: tertiary,
        surface: surface,
        background: background,
        onPrimary: const Color(0xFF003258),
        onSecondary: const Color(0xFF253140),
        onTertiary: const Color(0xFF3B2948),
        onSurface: const Color(0xFFE1E2E8),
        onBackground: const Color(0xFFE1E2E8),
        surfaceVariant: const Color(0xFF43474E),
        outline: const Color(0xFF8D9199),
        outlineVariant: const Color(0xFF43474E),
        primaryContainer: const Color(0xFF194975),
        secondaryContainer: const Color(0xFF3B4858),
        tertiaryContainer: const Color(0xFF523F5F),
      ),
      cardColor: surface,
      scaffoldBackgroundColor: background,
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF111418),
        foregroundColor: Color(0xFFE1E2E8),
        elevation: 0,
        centerTitle: false,
      ),
    );
  }
}
