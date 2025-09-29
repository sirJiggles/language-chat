import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/chat_service.dart';
import '../models/message.dart';

class MessageDebugView extends StatelessWidget {
  const MessageDebugView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Message Debug View'),
      ),
      body: Consumer<ChatService>(
        builder: (context, chatService, _) {
          final messages = chatService.conversationStore.messages;
          
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Total Messages: ${messages.length}',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    return MessageDebugCard(message: message, index: index);
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class MessageDebugCard extends StatelessWidget {
  final Message message;
  final int index;
  
  const MessageDebugCard({
    super.key,
    required this.message,
    required this.index,
  });
  
  @override
  Widget build(BuildContext context) {
    // Determine the card color based on message source
    Color cardColor;
    String sourceText;
    
    switch (message.source) {
      case MessageSource.user:
        cardColor = Colors.blue.withOpacity(0.2);
        sourceText = 'User';
        break;
      case MessageSource.conversationBot:
        cardColor = Colors.green.withOpacity(0.2);
        sourceText = 'Bot';
        break;
      case MessageSource.assessmentBot:
        cardColor = Colors.orange.withOpacity(0.2);
        sourceText = 'Assessment';
        break;
      case MessageSource.system:
        cardColor = Colors.red.withOpacity(0.2);
        sourceText = 'System';
        break;
    }
    
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      color: cardColor,
      child: ExpansionTile(
        title: Text(
          '#$index: $sourceText ${message.isThinking ? "(Thinking)" : ""}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          message.content.length > 50 
              ? '${message.content.substring(0, 50)}...' 
              : message.content,
          style: const TextStyle(fontStyle: FontStyle.italic),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('ID: ${message.id ?? "none"}'),
                Text('Timestamp: ${message.timestamp}'),
                Text('Is Thinking: ${message.isThinking}'),
                Text('Is User: ${message.isUser}'),
                const Divider(),
                const Text('Content:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(message.content),
                ),
                const SizedBox(height: 16),
                // Check for <think> tags
                if (message.content.contains('<think>') || message.content.contains('</think>'))
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text('Contains <think> tags!', 
                      style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
