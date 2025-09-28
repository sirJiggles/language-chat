import 'package:flutter/material.dart';

class TiledBackground extends StatelessWidget {
  final String assetPath;
  final Widget child;
  final double overlayOpacity;
  final Color overlayColor;

  const TiledBackground({
    super.key,
    required this.assetPath,
    required this.child,
    this.overlayOpacity = 0.3,
    this.overlayColor = Colors.black,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Tiled background
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(assetPath),
                repeat: ImageRepeat.repeat,
              ),
            ),
          ),
        ),
        // Semi-transparent overlay for better readability
        Positioned.fill(
          child: Container(
            color: overlayColor.withOpacity(overlayOpacity),
          ),
        ),
        // Content
        child,
      ],
    );
  }
}
