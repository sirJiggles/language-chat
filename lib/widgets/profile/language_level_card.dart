import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/language_level_tracker.dart';

class LanguageLevelCard extends StatelessWidget {
  const LanguageLevelCard({super.key});

  Color _getTrendColor(BuildContext context, String trend) {
    if (trend.contains('↑')) {
      return Colors.green;
    } else if (trend.contains('↓')) {
      return Colors.red;
    } else {
      return Theme.of(context).colorScheme.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LanguageLevelTracker>(
      builder: (context, levelTracker, _) {
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.school,
                      size: 32,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Current Level', style: TextStyle(fontSize: 16)),
                        const SizedBox(height: 4),
                        Text(
                          levelTracker.currentLevel,
                          style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  levelTracker.getLevelDescription(),
                  style: const TextStyle(fontSize: 14),
                ),
                const Divider(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _StatColumn(
                      label: 'Confidence',
                      value: '${(levelTracker.confidence * 100).toStringAsFixed(0)}%',
                    ),
                    _StatColumn(
                      label: 'Trend',
                      value: levelTracker.getTrend(),
                      valueColor: _getTrendColor(context, levelTracker.getTrend()),
                    ),
                    _StatColumn(
                      label: 'Assessments',
                      value: '${levelTracker.levelHistory.length}',
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _StatColumn extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _StatColumn({
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: valueColor,
          ),
        ),
      ],
    );
  }
}
