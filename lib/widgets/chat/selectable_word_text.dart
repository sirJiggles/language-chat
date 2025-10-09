import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/settings_model.dart';
import '../../services/word_definition_service.dart';
import '../../services/chat_service.dart';

class SelectableWordText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final WordDefinitionService definitionService;

  const SelectableWordText({
    super.key,
    required this.text,
    this.style,
    required this.definitionService,
  });

  @override
  Widget build(BuildContext context) {
    // Split text into words while preserving spaces and punctuation
    final words = _splitIntoWords(text);

    return Wrap(
      children: words.map((wordData) {
        if (wordData['isWord'] == true) {
          return _SelectableWord(
            word: wordData['text']!,
            style: style,
            definitionService: definitionService,
          );
        } else {
          // Non-word text (spaces, punctuation)
          return Text(wordData['text']!, style: style);
        }
      }).toList(),
    );
  }

  List<Map<String, dynamic>> _splitIntoWords(String text) {
    final List<Map<String, dynamic>> result = [];
    final RegExp wordPattern = RegExp(r'[\w\u00C0-\u024F\u1E00-\u1EFF]+');

    int lastEnd = 0;
    for (final match in wordPattern.allMatches(text)) {
      // Add non-word text before this word
      if (match.start > lastEnd) {
        result.add({'text': text.substring(lastEnd, match.start), 'isWord': false});
      }

      // Add the word
      result.add({'text': match.group(0)!, 'isWord': true});

      lastEnd = match.end;
    }

    // Add remaining non-word text
    if (lastEnd < text.length) {
      result.add({'text': text.substring(lastEnd), 'isWord': false});
    }

    return result;
  }
}

class _SelectableWord extends StatefulWidget {
  final String word;
  final TextStyle? style;
  final WordDefinitionService definitionService;

  const _SelectableWord({required this.word, this.style, required this.definitionService});

  @override
  State<_SelectableWord> createState() => _SelectableWordState();
}

class _SelectableWordState extends State<_SelectableWord> {
  bool _isPressed = false;

  void _showDefinition(BuildContext context) async {
    final settings = context.read<SettingsModel>();
    final chatService = context.read<ChatService>();
    final nativeLanguage = settings.nativeLanguage;
    final targetLanguage = chatService.targetLanguage;

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final definition = await widget.definitionService.getWordDefinition(
        word: widget.word,
        targetLanguage: targetLanguage,
        nativeLanguage: nativeLanguage,
      );

      if (!context.mounted) return;

      // Close loading dialog
      Navigator.of(context).pop();

      // Show definition dialog
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(widget.word, style: const TextStyle(fontWeight: FontWeight.bold)),
          content: Text(definition),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Close')),
          ],
        ),
      );
    } catch (e) {
      if (!context.mounted) return;

      // Close loading dialog
      Navigator.of(context).pop();

      // Show error dialog
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Error'),
          content: Text('Failed to get definition: $e'),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Close')),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPressStart: (_) {
        setState(() => _isPressed = true);
      },
      onLongPressEnd: (_) {
        setState(() => _isPressed = false);
        _showDefinition(context);
      },
      onLongPressCancel: () {
        setState(() => _isPressed = false);
      },
      child: Container(
        decoration: _isPressed
            ? BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                borderRadius: BorderRadius.circular(4),
              )
            : null,
        child: Text(widget.word, style: widget.style),
      ),
    );
  }
}
