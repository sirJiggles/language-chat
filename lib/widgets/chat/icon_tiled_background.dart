import 'package:flutter/material.dart';
import 'dart:math';

class IconTiledBackground extends StatelessWidget {
  final Widget child;
  final double overlayOpacity;
  final double spacing;
  final double iconSize;
  final double iconOpacity;

  static const List<String> iconPaths = [
    'assets/icons/001-ideas.png',
    'assets/icons/002-translate.png',
    'assets/icons/003-comment.png',
    'assets/icons/004-planet-earth.png',
    'assets/icons/005-speak.png',
    'assets/icons/006-speech-bubble.png',
    'assets/icons/007-sound-waves.png',
  ];

  const IconTiledBackground({
    super.key,
    required this.child,
    this.overlayOpacity = 0.92,
    this.spacing = 120.0,
    this.iconSize = 40.0,
    this.iconOpacity = 0.15,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Stack(
      children: [
        // Background color
        Positioned.fill(child: Container(color: isDark ? Colors.black : Colors.white)),
        // Icon grid
        Positioned.fill(
          child: _IconGrid(
            iconPaths: iconPaths,
            spacing: spacing,
            iconSize: iconSize,
            isDarkMode: isDark,
            iconOpacity: iconOpacity,
          ),
        ),
        // Semi-transparent overlay
        Positioned.fill(
          child: Container(
            color: Theme.of(context).colorScheme.surface.withOpacity(overlayOpacity),
          ),
        ),
        // Content
        child,
      ],
    );
  }
}

class _IconGrid extends StatelessWidget {
  final List<String> iconPaths;
  final double spacing;
  final double iconSize;
  final bool isDarkMode;
  final double iconOpacity;

  const _IconGrid({
    required this.iconPaths,
    required this.spacing,
    required this.iconSize,
    required this.isDarkMode,
    required this.iconOpacity,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final random = Random(42); // Fixed seed for consistent pattern
        final columns = (constraints.maxWidth / spacing).ceil() + 2;
        final rows = (constraints.maxHeight / spacing).ceil() + 1;

        final widgets = <Widget>[];

        for (int row = 0; row < rows; row++) {
          // Offset every other row by half spacing (brick pattern)
          final isEvenRow = row % 2 == 0;
          final rowOffset = isEvenRow ? 0.0 : spacing / 2;

          for (int col = 0; col < columns; col++) {
            // Pick random icon
            final iconPath = iconPaths[random.nextInt(iconPaths.length)];

            // Calculate position with offset for brick pattern
            final x = col * spacing + rowOffset;
            final y = row * spacing;

            widgets.add(
              Positioned(
                left: x,
                top: y,
                child: ColorFiltered(
                  colorFilter: ColorFilter.mode(
                    Theme.of(context).colorScheme.onSurface,
                    BlendMode.srcIn,
                  ),
                  child: Opacity(
                    opacity: iconOpacity,
                    child: Image.asset(
                      iconPath,
                      width: iconSize,
                      height: iconSize,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
            );
          }
        }

        return Stack(children: widgets);
      },
    );
  }
}
