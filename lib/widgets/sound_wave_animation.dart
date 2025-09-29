import 'dart:math';
import 'package:flutter/material.dart';

class SoundWaveAnimation extends StatefulWidget {
  final Color color;
  final double size;
  final int barCount;
  final double minBarHeight;
  final double maxBarHeight;
  final Duration animationDuration;
  final double barWidth;
  final double barSpacing;
  
  const SoundWaveAnimation({
    super.key,
    this.color = Colors.white,
    this.size = 32.0,
    this.barCount = 9,
    this.minBarHeight = 2.0,
    this.maxBarHeight = 16.0,
    this.animationDuration = const Duration(milliseconds: 250),
    this.barWidth = 2.0,
    this.barSpacing = 2.0,
  });

  @override
  State<SoundWaveAnimation> createState() => _SoundWaveAnimationState();
}

class _SoundWaveAnimationState extends State<SoundWaveAnimation> with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _animations;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    
    // Create controllers and animations for each bar
    _controllers = List.generate(
      widget.barCount,
      (_) => AnimationController(
        vsync: this,
        duration: widget.animationDuration,
      ),
    );
    
    _animations = List.generate(
      widget.barCount,
      (index) => Tween<double>(
        begin: widget.minBarHeight,
        end: _randomHeight(),
      ).animate(
        CurvedAnimation(
          parent: _controllers[index],
          curve: Curves.easeInOut,
        ),
      ),
    );
    
    // Start animations with staggered delays
    for (var i = 0; i < widget.barCount; i++) {
      Future.delayed(Duration(milliseconds: i * 30), () {
        if (mounted) {
          _animateBar(i);
        }
      });
    }
  }
  
  void _animateBar(int index) {
    if (!mounted) return;
    
    // Update the end value to a new random height
    _animations[index] = Tween<double>(
      begin: _animations[index].value,
      end: _randomHeight(),
    ).animate(
      CurvedAnimation(
        parent: _controllers[index],
        curve: Curves.easeInOut,
      ),
    );
    
    // Reset and start the animation
    _controllers[index].reset();
    _controllers[index].forward().then((_) {
      // Add a tiny random delay before starting the next animation
      // This creates a more natural, less synchronized wave pattern
      Future.delayed(Duration(milliseconds: _random.nextInt(50)), () {
        if (mounted) {
          // When animation completes, start the next one
          _animateBar(index);
        }
      });
    });
  }
  
  double _randomHeight() {
    return widget.minBarHeight + _random.nextDouble() * (widget.maxBarHeight - widget.minBarHeight);
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(
          widget.barCount,
          (index) => Padding(
            padding: EdgeInsets.symmetric(horizontal: widget.barSpacing / 2),
            child: AnimatedBuilder(
              animation: _controllers[index],
              builder: (context, child) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: widget.barWidth,
                      height: _animations[index].value,
                      decoration: BoxDecoration(
                        color: widget.color,
                        borderRadius: BorderRadius.circular(widget.barWidth / 2),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
