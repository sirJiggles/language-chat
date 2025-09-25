import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import '../services/context_manager.dart';
import 'conversation_viewer.dart';

/// A debug menu to access debugging tools
class DebugMenu extends StatelessWidget {
  const DebugMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final contextManager = Provider.of<ContextManager>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Debug Menu'),
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.history),
            title: const Text('View Conversation History'),
            subtitle: const Text('Browse saved conversation summaries'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ConversationViewer()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('View Student Profile'),
            subtitle: const Text('See current student profile data'),
            onTap: () {
              _showStudentProfile(context, contextManager);
            },
          ),
          ListTile(
            leading: const Icon(Icons.folder),
            title: const Text('View Context Files'),
            subtitle: const Text('Browse context files'),
            onTap: () {
              _showContextFiles(context, contextManager);
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete),
            title: const Text('Reset Student Profile'),
            subtitle: const Text('Delete current profile and start fresh'),
            onTap: () {
              _confirmResetProfile(context, contextManager);
            },
          ),
        ],
      ),
    );
  }
  
  void _showStudentProfile(BuildContext context, ContextManager contextManager) {
    if (contextManager.studentProfile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No student profile found')),
      );
      return;
    }
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Student Profile'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Name: ${contextManager.studentProfile!.name}'),
              Text('Target Language: ${contextManager.studentProfile!.targetLanguage}'),
              Text('Native Language: ${contextManager.studentProfile!.nativeLanguage}'),
              Text('Proficiency Level: ${contextManager.studentProfile!.proficiencyLevel}'),
              Text('Session Count: ${contextManager.studentProfile!.sessionCount}'),
              Text('Last Interaction: ${contextManager.studentProfile!.lastInteraction}'),
              const Divider(),
              Text('Interests: ${contextManager.studentProfile!.interests.join(", ")}'),
              const Divider(),
              Text('Recent Topics: ${contextManager.studentProfile!.recentTopics.join(", ")}'),
              const Divider(),
              Text('Vocabulary Progress (${contextManager.studentProfile!.vocabularyProgress.length} words)'),
              const Divider(),
              Text('Grammar Progress (${contextManager.studentProfile!.grammarProgress.length} points)'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
  
  void _showContextFiles(BuildContext context, ContextManager contextManager) {
    if (contextManager.contextFiles.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No context files found')),
      );
      return;
    }
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Context Files'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: contextManager.contextFiles.length,
            itemBuilder: (context, index) {
              final fileName = contextManager.contextFiles.keys.elementAt(index);
              return ListTile(
                title: Text(fileName),
                onTap: () {
                  Navigator.pop(context);
                  _showFileContent(context, fileName, contextManager.contextFiles[fileName]!);
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
  
  void _showFileContent(BuildContext context, String fileName, String content) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(fileName),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: SingleChildScrollView(
            child: Text(content),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
  
  void _confirmResetProfile(BuildContext context, ContextManager contextManager) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Student Profile'),
        content: const Text('This will delete the current student profile and all conversation history. Are you sure?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _resetProfile(context);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Profile reset successfully')),
                );
              }
            },
            child: const Text('Reset', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
  
  Future<void> _resetProfile(BuildContext context) async {
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
      
      final profileFile = File('${baseDir.path}/context/student_profile.json');
      debugPrint('Checking for profile at: ${profileFile.path}');
      
      if (await profileFile.exists()) {
        await profileFile.delete();
        debugPrint('Deleted student profile');
      }
      
      final conversationsDir = Directory('${baseDir.path}/context/conversations');
      debugPrint('Checking for conversations at: ${conversationsDir.path}');
      if (await conversationsDir.exists()) {
        await conversationsDir.delete(recursive: true);
        debugPrint('Deleted conversations directory');
      }
      
      // Reinitialize context manager
      final contextManager = Provider.of<ContextManager>(context, listen: false);
      await contextManager.initialize();
      
    } catch (e) {
      debugPrint('Error resetting profile: $e');
    }
  }
}
