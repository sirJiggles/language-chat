import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/chat_service.dart';

/// A debug tool to view the assessment bot's thinking process as a chat
class AssessmentThinkingViewer extends StatefulWidget {
  const AssessmentThinkingViewer({super.key});

  @override
  State<AssessmentThinkingViewer> createState() => _AssessmentThinkingViewerState();
}

class _AssessmentThinkingViewerState extends State<AssessmentThinkingViewer> {
  final ScrollController _scrollController = ScrollController();
  
  // Selected assessment index
  int _selectedIndex = -1;

  @override
  void initState() {
    super.initState();
    // Scroll to bottom when the view is first shown
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Assessment Bot Conversation'),
        actions: [
          IconButton(
            icon: const Icon(Icons.vertical_align_bottom),
            tooltip: 'Scroll to bottom',
            onPressed: _scrollToBottom,
          ),
        ],
      ),
      body: Consumer<ChatService>(
        builder: (context, chatService, _) {
          final assessments = chatService.assessmentResults;
          
          if (assessments.isEmpty) {
            return const Center(
              child: Text('No assessment data available yet'),
            );
          }
          
          return Column(
            children: [
              // Assessment selector
              Container(
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const Text('Select Assessment:'),
                    const SizedBox(width: 16),
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: List.generate(
                            assessments.length,
                            (index) {
                              final reversedIndex = assessments.length - 1 - index;
                              final assessment = assessments[reversedIndex];
                              // Format timestamp
                              String timestamp = '';
                              try {
                                final timestampStr = assessment['timestamp']?.toString() ?? '';
                                if (timestampStr.contains(' ')) {
                                  timestamp = timestampStr.split(' ')[1].split('.')[0];
                                } else {
                                  timestamp = timestampStr.split('T').last.split('.')[0];
                                }
                              } catch (e) {
                                timestamp = 'Unknown';
                              }
                              final level = assessment['assessedLevel'] ?? 'Unknown';
                              
                              return Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                                child: ChoiceChip(
                                  label: Text('$level ($timestamp)'),
                                  selected: _selectedIndex == reversedIndex,
                                  onSelected: (selected) {
                                    if (selected) {
                                      setState(() {
                                        _selectedIndex = reversedIndex;
                                      });
                                    }
                                  },
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Chat view
              Expanded(
                child: _selectedIndex != -1 && _selectedIndex < assessments.length
                    ? _buildAssessmentChat(assessments[_selectedIndex])
                    : const Center(child: Text('Select an assessment to view')),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAssessmentChat(Map<String, dynamic> assessment) {
    final userMessage = assessment['userMessage'] ?? '';
    final assistantMessage = assessment['assistantMessage'] ?? '';
    final reasoning = assessment['reasoning'] ?? '';
    final level = assessment['assessedLevel'] ?? 'Unknown';
    
    // Format timestamp
    String timestamp = '';
    try {
      final timestampStr = assessment['timestamp']?.toString() ?? '';
      if (timestampStr.contains(' ')) {
        timestamp = timestampStr;
      } else if (timestampStr.contains('T')) {
        final datePart = timestampStr.split('T')[0];
        final timePart = timestampStr.split('T')[1].split('.')[0];
        timestamp = '$datePart $timePart';
      } else {
        timestamp = timestampStr;
      }
    } catch (e) {
      timestamp = 'Unknown time';
    }
    
    return Column(
      children: [
        // Assessment info
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Assessment from $timestamp',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Text('Detected Level: $level'),
            ],
          ),
        ),
        
        // Chat messages
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // System message
              _buildSystemMessage('Assessment started for conversation:'),
              
              // User message
              _buildUserMessage(userMessage),
              
              // Assistant message
              _buildAssistantMessage(assistantMessage),
              
              // System message
              _buildSystemMessage('Analyzing language level...'),
              
              // Assessment bot reasoning
              _buildAssessmentBotMessage(reasoning),
              
              // Final assessment
              _buildSystemMessage('Final assessment: Level $level'),
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildUserMessage(String message) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          message,
          style: TextStyle(color: Theme.of(context).colorScheme.onPrimaryContainer),
        ),
      ),
    );
  }
  
  Widget _buildAssistantMessage(String message) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceVariant,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          message,
          style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
        ),
      ),
    );
  }
  
  Widget _buildAssessmentBotMessage(String message) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.tertiaryContainer,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          message,
          style: TextStyle(color: Theme.of(context).colorScheme.onTertiaryContainer),
        ),
      ),
    );
  }
  
  Widget _buildSystemMessage(String message) {
    return Container(
      alignment: Alignment.center,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          message,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.8),
            fontSize: 12,
            fontStyle: FontStyle.italic,
          ),
        ),
      ),
    );
  }
  
  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
