import 'package:flutter/material.dart';
import 'dart:math' as math;

class AudioWaveform extends StatefulWidget {
  final double audioLevel; // 0.0 to 1.0
  final Color color;
  final int barCount;
  
  const AudioWaveform({
    super.key,
    required this.audioLevel,
    this.color = Colors.blue,
    this.barCount = 40,
  });

  @override
  State<AudioWaveform> createState() => _AudioWaveformState();
}

class _AudioWaveformState extends State<AudioWaveform> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<double> _barHeights = [];
  final List<double> _targetHeights = [];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    )..addListener(() {
        setState(() {
          _smoothUpdateBarHeights();
        });
      });
    _controller.repeat();
    
    // Initialize bar heights
    for (int i = 0; i < widget.barCount; i++) {
      _barHeights.add(0.2);
      _targetHeights.add(0.2);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _smoothUpdateBarHeights() {
    final random = math.Random();
    final baseHeight = widget.audioLevel * 0.6 + 0.2; // Min 0.2, max 0.8
    
    for (int i = 0; i < widget.barCount; i++) {
      // Update target heights occasionally
      if (random.nextDouble() < 0.3) {
        final variation = (random.nextDouble() - 0.5) * 0.2;
        _targetHeights[i] = (baseHeight + variation).clamp(0.15, 0.85);
      }
      
      // Smoothly interpolate current height to target
      final diff = _targetHeights[i] - _barHeights[i];
      _barHeights[i] += diff * 0.2; // Smooth interpolation
    }
  }

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final totalWidth = constraints.maxWidth;
          final barWidth = (totalWidth / (widget.barCount * 2 - 1)).clamp(2.0, 4.0);
          final spacing = barWidth * 0.5;
          
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: List.generate(widget.barCount, (index) {
              return Container(
                width: barWidth,
                height: constraints.maxHeight * _barHeights[index],
                margin: EdgeInsets.symmetric(horizontal: spacing),
                decoration: BoxDecoration(
                  color: widget.color,
                  borderRadius: BorderRadius.circular(barWidth / 2),
                ),
              );
            }),
          );
        },
      ),
    );
  }
}
