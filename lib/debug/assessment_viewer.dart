import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/chat_service.dart';

/// A debug tool to view background assessment results
class AssessmentViewer extends StatefulWidget {
  const AssessmentViewer({super.key});

  @override
  State<AssessmentViewer> createState() => _AssessmentViewerState();
}

class _AssessmentViewerState extends State<AssessmentViewer> {
  final ScrollController _scrollController = ScrollController();
  int _selectedIndex = -1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Background Assessment Results'),
        actions: [
          Consumer<ChatService>(
            builder: (context, chatService, _) {
              final assessments = chatService.assessmentResults;
              if (assessments.isNotEmpty) {
                return Padding(
                  padding: const EdgeInsets.only(right: 16.0),
                  child: Center(
                    child: Text(
                      'Latest Level: ${assessments.last['assessedLevel']}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: Consumer<ChatService>(
        builder: (context, chatService, _) {
          final assessments = chatService.assessmentResults;
          
          if (assessments.isEmpty) {
            return const Center(
              child: Text('No assessment results available yet'),
            );
          }
          
          // Select the first assessment if none is selected
          if (_selectedIndex < 0 && assessments.isNotEmpty) {
            _selectedIndex = assessments.length - 1;
          }
          
          return Column(
            children: [
              // Assessment selector
              Container(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
                  border: Border(
                    bottom: BorderSide(color: Theme.of(context).dividerColor),
                  ),
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 16),
                    const Text('Select Assessment:', style: TextStyle(fontWeight: FontWeight.bold)),
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
                              // Handle timestamp formatting safely
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
              
              // Chat display
              Expanded(
                child: _selectedIndex < 0
                    ? const Center(child: Text('Select an assessment to view details'))
                    : Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: _buildChatView(assessments[_selectedIndex]),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
  
  Widget _buildChatView(Map<String, dynamic> assessment) {
    final userMessage = assessment['userMessage'] ?? '';
    final assistantMessage = assessment['assistantMessage'] ?? '';
    final level = assessment['assessedLevel'] ?? 'Unknown';
    // Format the timestamp for display
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Assessment Result: $level',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 4),
              Text('Time: $timestamp', style: const TextStyle(fontSize: 12)),
            ],
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Chat messages
        Expanded(
          child: ListView(
            controller: _scrollController,
            children: [
              // User message
              Align(
                alignment: Alignment.centerRight,
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12.0),
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  child: Text(
                    userMessage,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
              ),
              
              // Assistant message
              Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12.0),
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceVariant,
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  child: Text(
                    assistantMessage,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
