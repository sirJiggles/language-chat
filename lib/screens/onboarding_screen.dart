import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/student_profile_store.dart';
import '../models/language_level_tracker.dart';
import '../services/comprehensive_assessment_service.dart';

class OnboardingScreen extends StatefulWidget {
  final String nativeLanguage;
  final String targetLanguage;

  const OnboardingScreen({super.key, required this.nativeLanguage, required this.targetLanguage});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  double _levelIndex = 0; // 0-5 for A1-C2
  bool _isLoading = false;

  final List<String> _levels = ['A1', 'A2', 'B1', 'B2', 'C1', 'C2'];

  Map<String, Map<String, dynamic>> _getLevelDescriptions(BuildContext context) {
    return {
      'A1': {
        'title': 'Beginner',
        'description':
            'Can understand and use familiar everyday expressions and very basic phrases.',
      },
      'A2': {
        'title': 'Elementary',
        'description':
            'Can communicate in simple routine tasks requiring direct exchange of information.',
      },
      'B1': {
        'title': 'Intermediate',
        'description':
            'Can handle most situations while traveling. Can describe experiences and events.',
      },
      'B2': {
        'title': 'Upper Intermediate',
        'description':
            'Can interact with fluency and spontaneity. Can produce clear, detailed text.',
      },
      'C1': {
        'title': 'Advanced',
        'description':
            'Can express themselves fluently and spontaneously for social and professional purposes.',
      },
      'C2': {
        'title': 'Proficient',
        'description':
            'Can understand virtually everything with ease and express themselves very fluently.',
      },
    };
  }

  String get _currentLevel => _levels[_levelIndex.round()];
  
  String _getLanguageName(String code) {
    const languageNames = {
      'en': '🇬🇧 English',
      'es': '🇪🇸 Spanish',
      'fr': '🇫🇷 French',
      'de': '🇩🇪 German',
      'it': '🇮🇹 Italian',
      'pt': '🇵🇹 Portuguese',
      'nl': '🇳🇱 Dutch',
      'ru': '🇷🇺 Russian',
      'ja': '🇯🇵 Japanese',
      'zh': '🇨🇳 Chinese',
      'ko': '🇰🇷 Korean',
      'ar': '🇸🇦 Arabic',
    };
    return languageNames[code] ?? code.toUpperCase();
  }

  Future<void> _completeOnboarding() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final profileStore = context.read<StudentProfileStore>();
      final levelTracker = context.read<LanguageLevelTracker>();
      final assessmentService = context.read<ComprehensiveAssessmentService>();

      // Save the self-assessed level
      final selectedLevel = _currentLevel;

      // Set initial profile data
      await profileStore.setValue('onboarding_completed', 'true');
      await profileStore.setValue('self_assessed_level', selectedLevel);
      await profileStore.setValue('self_assessment_date', DateTime.now().toIso8601String());
      await profileStore.setValue('native_language', widget.nativeLanguage);
      await profileStore.setValue('target_language', widget.targetLanguage);

      // Set the initial level in the tracker
      await levelTracker.updateLevel(
        selectedLevel,
        'Self-assessed level during onboarding',
        confidence: 0.5, // Medium confidence for self-assessment
      );

      // Start a fresh assessment session
      await assessmentService.startNewSession();

      if (mounted) {
        // Pop both onboarding screens to return to chat
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } catch (e) {
      debugPrint('Error completing onboarding: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final levelDescriptions = _getLevelDescriptions(context);
    final currentDescription = levelDescriptions[_currentLevel]!;
    final themeColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).colorScheme.primaryContainer,
              Theme.of(context).colorScheme.secondaryContainer,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Scrollable content
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24.0, 0, 24.0, 24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 20),

                        // Step indicator
                        Text(
                          'Step 2/2',
                          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),

                        // Title
                        Text(
                          _getLanguageName(widget.targetLanguage),
                          style: Theme.of(context).textTheme.displaySmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),

                        Text(
                          'What\'s your current level?',
                          style: Theme.of(context).textTheme.titleLarge,
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: 32),

                        // Level display card
                        Card(
                          elevation: 8,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                          child: Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: Column(
                              children: [
                                // Level name
                                Text(
                                  _currentLevel,
                                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: themeColor,
                                  ),
                                ),
                                const SizedBox(height: 8),

                                Text(
                                  currentDescription['title'] as String,
                                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                                  ),
                                ),
                                const SizedBox(height: 20),

                                // Description
                                Text(
                                  currentDescription['description'] as String,
                                  style: Theme.of(context).textTheme.bodyLarge,
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 32),

                        // Slider
                        Column(
                          children: [
                            SliderTheme(
                              data: SliderTheme.of(context).copyWith(
                                trackHeight: 6,
                                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
                                overlayShape: const RoundSliderOverlayShape(overlayRadius: 24),
                                activeTrackColor: themeColor,
                                thumbColor: themeColor,
                              ),
                              child: Slider(
                                value: _levelIndex,
                                min: 0,
                                max: 5,
                                divisions: 5,
                                onChanged: (value) {
                                  setState(() {
                                    _levelIndex = value;
                                  });
                                },
                              ),
                            ),

                            // Level markers
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: _levels.map((level) {
                                  final isSelected = level == _currentLevel;
                                  return Text(
                                    level,
                                    style: TextStyle(
                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                      fontSize: isSelected ? 16 : 14,
                                      color: isSelected
                                          ? themeColor
                                          : Theme.of(context).colorScheme.onSurfaceVariant,
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ),

              // Fixed button at bottom
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: FilledButton(
                  onPressed: _isLoading ? null : _completeOnboarding,
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    minimumSize: const Size.fromHeight(56),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text(
                          'Start Learning',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
