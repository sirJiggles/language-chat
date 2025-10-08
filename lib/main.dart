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
import 'theme/util.dart';
import 'theme/theme.dart';

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
    TextTheme textTheme = createTextTheme(context, "DM Sans", "DM Sans");
    MaterialTheme theme = MaterialTheme(textTheme);

    return Consumer<SettingsModel>(
      builder: (context, settings, _) {
        return MaterialApp(
          title: 'Language Chat',
          debugShowCheckedModeBanner: false,
          theme: theme.lightMediumContrast(),
          darkTheme: theme.dark(),
          themeMode: settings.isDarkMode ? ThemeMode.dark : ThemeMode.light,
          home: const ChatScreen(),
        );
      },
    );
  }
}
