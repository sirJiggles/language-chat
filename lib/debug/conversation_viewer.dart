import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

/// A debug tool to view saved conversation summaries
class ConversationViewer extends StatefulWidget {
  const ConversationViewer({super.key});

  @override
  State<ConversationViewer> createState() => _ConversationViewerState();
}

class _ConversationViewerState extends State<ConversationViewer> {
  List<FileSystemEntity> _conversationFiles = [];
  String _selectedContent = '';
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadConversationFiles();
  }

  Future<void> _loadConversationFiles() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      // Try application support directory first
      Directory baseDir;
      try {
        baseDir = await getApplicationSupportDirectory();
        debugPrint('Using application support directory: ${baseDir.path}');
      } catch (e) {
        // Fall back to documents directory
        baseDir = await getApplicationDocumentsDirectory();
        debugPrint('Using documents directory: ${baseDir.path}');
      }
      
      final conversationsDir = Directory('${baseDir.path}/context/conversations');
      debugPrint('Looking for conversations in: ${conversationsDir.path}');
      
      if (!await conversationsDir.exists()) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'No conversation history found. Start a conversation first.';
        });
        return;
      }
      
      final files = await conversationsDir.list().toList();
      files.sort((a, b) => b.path.compareTo(a.path)); // Sort newest first
      
      setState(() {
        _conversationFiles = files;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error loading conversation files: $e';
      });
    }
  }

  Future<void> _viewConversation(String path) async {
    try {
      final content = await File(path).readAsString();
      setState(() {
        _selectedContent = content;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error reading file: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Conversation History'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadConversationFiles,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
              ? Center(child: Text(_errorMessage))
              : _conversationFiles.isEmpty
                  ? const Center(child: Text('No conversation history found'))
                  : Row(
                      children: [
                        // File list
                        SizedBox(
                          width: 300,
                          child: ListView.builder(
                            itemCount: _conversationFiles.length,
                            itemBuilder: (context, index) {
                              final file = _conversationFiles[index];
                              final fileName = file.path.split('/').last;
                              
                              return ListTile(
                                title: Text(fileName),
                                subtitle: FutureBuilder<FileStat>(
                                  future: file.stat(),
                                  builder: (context, snapshot) {
                                    if (!snapshot.hasData) {
                                      return const Text('Loading...');
                                    }
                                    final date = snapshot.data!.modified;
                                    return Text(date.toString().split('.')[0]);
                                  },
                                ),
                                onTap: () => _viewConversation(file.path),
                              );
                            },
                          ),
                        ),
                        
                        // Vertical divider
                        const VerticalDivider(width: 1),
                        
                        // Content viewer
                        Expanded(
                          child: _selectedContent.isEmpty
                              ? const Center(child: Text('Select a conversation to view'))
                              : SingleChildScrollView(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Text(_selectedContent),
                                ),
                        ),
                      ],
                    ),
    );
  }
}
