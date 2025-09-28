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
