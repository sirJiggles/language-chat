import 'package:flutter/material.dart';

class TiledBackground extends StatelessWidget {
  final String assetPath;
  final Widget child;
  final double overlayOpacity;
  final Color overlayColor;
  final double scale;

  const TiledBackground({
    super.key,
    required this.assetPath,
    required this.child,
    this.overlayOpacity = 0.3,
    this.overlayColor = Colors.black,
    this.scale = 1.0,
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
                scale: scale,
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
