import 'package:flutter/material.dart';
import '../screens/settings_screen.dart';
import '../debug/debug_menu.dart';

class NavButtons extends StatelessWidget {
  const NavButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Settings button
        Positioned(
          bottom: 16,
          left: 0,
          child: IconButton(
            onPressed: () {
              Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const SettingsScreen()));
            },
            icon: Icon(
              Icons.settings,
              color: Theme.of(context).colorScheme.tertiary.withOpacity(0.8), // Blue
              size: 26,
            ),
            tooltip: 'Settings',
          ),
        ),
        // Debug menu button
        Positioned(
          bottom: 16,
          right: 0,
          child: IconButton(
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (_) => const DebugMenu()));
            },
            icon: Icon(
              Icons.bug_report,
              color: Theme.of(context).colorScheme.tertiary.withOpacity(0.8), // Blue
              size: 26,
            ),
            tooltip: 'Debug Menu',
          ),
        ),
      ],
    );
  }
}
