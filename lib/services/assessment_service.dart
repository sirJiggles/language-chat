import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'context_manager.dart';

/// Service for handling language assessment functionality
class AssessmentService extends ChangeNotifier {
  final String _ollamaBaseUrl;
  final String _ollamaModel;
  final ContextManager _contextManager;
  
  // Queue to store pending messages for assessment
  final List<Map<String, String>> _pendingAssessments = [];
  bool _isAssessing = false;
  
  // Store assessment results for debug viewing
  final List<Map<String, dynamic>> _assessmentResults = [];
  
  // Simple log of assessment results for display
  String _assessmentLog = '';
  
  AssessmentService({
    required String ollamaBaseUrl,
    required String ollamaModel,
    required ContextManager contextManager,
  })  : _ollamaBaseUrl = ollamaBaseUrl,
        _ollamaModel = ollamaModel,
        _contextManager = contextManager {
    // Load assessment results when service is created
    _loadAssessmentResults();
  }
  
  // Getters
  List<Map<String, dynamic>> get assessmentResults => _assessmentResults;
  String get assessmentLog => _assessmentLog;
  
  // Perform language assessment in the background
  void performBackgroundAssessment(
    String userMessage,
    String assistantMessage,
    String targetLanguage, {
    bool hideUserMessage = false,
  }) {
    // Skip assessment for hidden system messages like the initial greeting trigger
    if (hideUserMessage && userMessage == 'Hallo') {
      debugPrint('Skipping assessment for hidden system message');
      return;
    }

    // Add this conversation to the pending queue
    _pendingAssessments.add({
      'userMessage': userMessage,
      'assistantMessage': assistantMessage,
      'targetLanguage': targetLanguage,
    });

    // Start processing if not already in progress
    if (!_isAssessing) {
      _processAssessmentQueue();
    }
  }

  // Process the assessment queue in the background
  Future<void> _processAssessmentQueue() async {
    if (_pendingAssessments.isEmpty || _isAssessing) return;

    _isAssessing = true;

    try {
      // Process one assessment at a time to avoid overloading
      if (_pendingAssessments.isNotEmpty) {
        final conversation = _pendingAssessments.removeAt(0);
        final userMessage = conversation['userMessage']!;
        final assistantMessage = conversation['assistantMessage']!;
        final targetLanguage = conversation['targetLanguage']!;

        // Run this on a separate async task to avoid blocking the main conversation
        Future.delayed(Duration.zero, () async {
          try {
            // Assess language level
            final assessmentPrompt =
                'Based on the conversation:\\n\\nUser: "$userMessage"\\nAssistant: "$assistantMessage"\\n\\nAssess the user\'s proficiency level in $targetLanguage according to CEFR standards (A1-C2). Consider vocabulary range, grammatical accuracy, fluency, and complexity. First, provide your detailed reasoning about why you are choosing a particular level, analyzing the user\'s language use. Then, on a new line, write "LEVEL:" followed by the CEFR level (A1, A2, B1, B2, C1, or C2).';

            // Make API call for assessment
            final assessmentResponse = await http.post(
              Uri.parse('$_ollamaBaseUrl/api/chat'),
              headers: const {'Content-Type': 'application/json'},
              body: jsonEncode({
                'model': _ollamaModel,
                'messages': [
                  {
                    'role': 'system',
                    'content':
                        'You are a language assessment expert specializing in CEFR standards. Analyze the conversation and provide detailed reasoning about the user\'s language proficiency. Consider vocabulary range, grammatical accuracy, fluency, and complexity of language use. After your analysis, clearly state the CEFR level (A1, A2, B1, B2, C1, or C2) on a new line starting with "LEVEL:"',
                  },
                  {'role': 'user', 'content': assessmentPrompt},
                ],
                'stream': false,
                'options': {'temperature': 0.3},
              }),
            );

            if (assessmentResponse.statusCode == 200) {
              final assessmentData = jsonDecode(assessmentResponse.body);
              final aiAssessment = assessmentData['message']?['content'] ?? '';

              // Extract the CEFR level
              String assessedLevel = 'A1'; // Default level
              final levelMatch = RegExp(r'LEVEL:\s*(A1|A2|B1|B2|C1|C2)').firstMatch(aiAssessment);
              if (levelMatch != null) {
                assessedLevel = levelMatch.group(1)!;
              } else {
                // Fallback to just finding any CEFR level mention
                final simpleLevelMatch = RegExp(r'(A1|A2|B1|B2|C1|C2)').firstMatch(aiAssessment);
                if (simpleLevelMatch != null) {
                  assessedLevel = simpleLevelMatch.group(0)!;
                }
              }

              debugPrint('Background assessment complete: $assessedLevel');

              // Format the current time
              final now = DateTime.now();
              final timestamp =
                  '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}';

              // Update the assessment log
              _assessmentLog +=
                  '[$timestamp] Level: $assessedLevel - "${userMessage.length > 30 ? '${userMessage.substring(0, 30)}...' : userMessage}"\\n';

              // Store the assessment result for debug viewing
              _assessmentResults.add({
                'timestamp': now.toString(),
                'userMessage': userMessage,
                'assistantMessage': assistantMessage,
                'assessedLevel': assessedLevel,
                'reasoning': aiAssessment,
              });

              // Save assessment results to persistent storage
              _saveAssessmentResults();

              // Limit stored results to last 50
              if (_assessmentResults.length > 50) {
                _assessmentResults.removeAt(0);
              }

              // Update the profile with the assessment result
              if (_contextManager.isInitialized) {
                await _contextManager.updateProfileWithSession(
                  conversation: 'User: $userMessage\\nAssistant: $assistantMessage',
                  assessedLevel: assessedLevel,
                );
              }
            }
          } catch (e) {
            debugPrint('Error in background assessment: $e');
          } finally {
            // Process the next item in the queue
            _isAssessing = false;
            _processAssessmentQueue();
          }
        });
      } else {
        _isAssessing = false;
      }
    } catch (e) {
      debugPrint('Error starting assessment queue processing: $e');
      _isAssessing = false;
    }
  }

  // Save assessment results to persistent storage
  Future<void> _saveAssessmentResults() async {
    try {
      // Get application documents directory
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/assessment_results.json');

      // Convert assessment results to JSON and save to file
      final jsonData = jsonEncode(_assessmentResults);
      await file.writeAsString(jsonData);

      debugPrint('Assessment results saved to ${file.path}');
    } catch (e) {
      debugPrint('Error saving assessment results: $e');
    }
  }

  // Load assessment results from persistent storage
  Future<void> _loadAssessmentResults() async {
    try {
      // Get application documents directory
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/assessment_results.json');

      // Check if file exists
      if (await file.exists()) {
        // Read file content and parse JSON
        final jsonData = await file.readAsString();
        final List<dynamic> data = jsonDecode(jsonData);

        // Convert to List<Map<String, dynamic>>
        _assessmentResults.clear();
        _assessmentResults.addAll(data.map((item) => Map<String, dynamic>.from(item)).toList());

        // Rebuild assessment log from loaded data
        _rebuildAssessmentLog();

        debugPrint('Loaded ${_assessmentResults.length} assessment results from ${file.path}');
      }
    } catch (e) {
      debugPrint('Error loading assessment results: $e');
    }
  }

  // Rebuild assessment log from loaded assessment results
  void _rebuildAssessmentLog() {
    _assessmentLog = '';
    for (final assessment in _assessmentResults) {
      try {
        final userMessage = assessment['userMessage'] ?? '';
        final assessedLevel = assessment['assessedLevel'] ?? 'Unknown';

        // Format timestamp
        String timestamp = 'Unknown';
        if (assessment['timestamp'] != null) {
          final dateTime = DateTime.parse(assessment['timestamp'].toString());
          timestamp =
              '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}:${dateTime.second.toString().padLeft(2, '0')}';
        }

        _assessmentLog +=
            '[$timestamp] Level: $assessedLevel - "${userMessage.length > 30 ? '${userMessage.substring(0, 30)}...' : userMessage}"\\n';
      } catch (e) {
        debugPrint('Error rebuilding log entry: $e');
      }
    }
  }
}
