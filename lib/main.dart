import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'screens/chat_screen.dart';
import 'services/chat_service.dart';
import 'services/speech_service.dart';
import 'services/tts_service.dart';
import 'services/context_manager.dart';
import 'services/assessment_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize context manager first
  final contextManager = ContextManager();
  await contextManager.initialize();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: contextManager),

        // Create assessment service
        ChangeNotifierProvider(
          create: (_) => AssessmentService(
            ollamaBaseUrl: const String.fromEnvironment(
              'OLLAMA_BASE_URL',
              defaultValue: 'http://localhost:11434',
            ),
            ollamaModel: const String.fromEnvironment(
              'OLLAMA_MODEL',
              defaultValue: 'deepseek-r1:8b',
            ),
            contextManager: contextManager,
          ),
        ),

        // Other services
        ChangeNotifierProvider(
          create: (context) => ChatService(
            ollamaBaseUrl: const String.fromEnvironment(
              'OLLAMA_BASE_URL',
              defaultValue: 'http://localhost:11434',
            ),
            ollamaModel: const String.fromEnvironment(
              'OLLAMA_MODEL',
              defaultValue: 'deepseek-r1:8b',
            ),
            targetLanguage: const String.fromEnvironment(
              'TARGET_LANGUAGE',
              defaultValue: 'Spanish',
            ),
            contextManager: contextManager,
            assessmentService: Provider.of<AssessmentService>(context, listen: false),
          ),
        ),
        ChangeNotifierProvider(create: (_) => SpeechService()),
        ChangeNotifierProvider(create: (_) => TtsService()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue, brightness: Brightness.light),
        useMaterial3: true,
        textTheme: GoogleFonts.nunitoTextTheme(Theme.of(context).textTheme),
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue, brightness: Brightness.dark),
        useMaterial3: true,
        textTheme: GoogleFonts.nunitoTextTheme(
          Theme.of(context).textTheme.apply(bodyColor: Colors.white, displayColor: Colors.white),
        ),
      ),
      themeMode: ThemeMode.system,
      home: const ChatScreen(),
    );
  }
}
