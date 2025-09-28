import 'dart:ui';
import 'package:flutter/material.dart';

class FrostedGlass extends StatelessWidget {
  final Widget child;
  final double blurAmount;
  final Color tintColor;
  final double tintOpacity;
  final BorderRadius? borderRadius;

  const FrostedGlass({
    super.key,
    required this.child,
    this.blurAmount = 10.0,
    this.tintColor = Colors.black,
    this.tintOpacity = 0.15,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.zero,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blurAmount, sigmaY: blurAmount),
        child: Container(
          decoration: BoxDecoration(
            color: tintColor.withOpacity(tintOpacity),
            borderRadius: borderRadius,
          ),
          child: child,
        ),
      ),
    );
  }
}
