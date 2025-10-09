import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../models/settings_model.dart';
import '../../models/student_profile_store.dart';
import '../../services/tts_service.dart';
import '../../screens/settings_screen.dart';
import '../../screens/student_profile_view.dart';
import '../sound_wave_animation.dart';

class ChatAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback onNewChat;
  final VoidCallback onOpenDrawer;

  const ChatAppBar({
    super.key,
    required this.onNewChat,
    required this.onOpenDrawer,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return PreferredSize(
      preferredSize: preferredSize,
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
              width: 1,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: AppBar(
              backgroundColor: Theme.of(context).colorScheme.surfaceBright.withOpacity(0.7),
              elevation: 0,
              leading: _RobotIcon(),
              actions: [
                _MenuButton(
                  onNewChat: onNewChat,
                  onOpenDrawer: onOpenDrawer,
                ),
                _ProfileAvatar(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RobotIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<TtsService>(
      builder: (context, ttsService, _) {
        final isBotSpeaking = ttsService.isSpeaking;
        return Container(
          padding: const EdgeInsets.all(0),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Robot SVG icon
              SvgPicture.asset(
                'assets/icons/robo.svg',
                colorFilter: ColorFilter.mode(
                  Theme.of(context).colorScheme.primary,
                  BlendMode.srcIn,
                ),
                width: 35,
                height: 35,
              ),
              // Wave animation overlay when bot is speaking
              if (isBotSpeaking)
                Positioned(
                  bottom: 10,
                  child: SoundWaveAnimation(
                    color: Theme.of(context).colorScheme.primary,
                    size: 20,
                    barCount: 4,
                    barWidth: 2,
                    barSpacing: 1,
                    minBarHeight: 3,
                    maxBarHeight: 8,
                    animationDuration: const Duration(milliseconds: 100),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _MenuButton extends StatelessWidget {
  final VoidCallback onNewChat;
  final VoidCallback onOpenDrawer;

  const _MenuButton({
    required this.onNewChat,
    required this.onOpenDrawer,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert),
      iconColor: Theme.of(context).colorScheme.primary,
      offset: const Offset(0, 50),
      onSelected: (value) {
        if (value == 'settings') {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const SettingsScreen()),
          );
        } else if (value == 'chats') {
          onOpenDrawer();
        } else if (value == 'new_chat') {
          onNewChat();
        }
      },
      itemBuilder: (BuildContext context) => [
        const PopupMenuItem<String>(
          value: 'new_chat',
          child: Row(
            children: [
              Icon(Icons.chat_bubble),
              SizedBox(width: 12),
              Text('New Chat'),
            ],
          ),
        ),
        const PopupMenuItem<String>(
          value: 'chats',
          child: Row(
            children: [Icon(Icons.history), SizedBox(width: 12), Text('Chats')],
          ),
        ),
        const PopupMenuItem<String>(
          value: 'settings',
          child: Row(
            children: [
              Icon(Icons.settings),
              SizedBox(width: 12),
              Text('Settings'),
            ],
          ),
        ),
      ],
    );
  }
}

class _ProfileAvatar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: GestureDetector(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const StudentProfileView()),
          );
        },
        child: Consumer2<SettingsModel, StudentProfileStore>(
          builder: (context, settings, profileStore, _) {
            final profilePicture = settings.profilePicturePath;

            if (profilePicture != null && File(profilePicture).existsSync()) {
              // Show uploaded profile picture
              return CircleAvatar(
                radius: 18,
                backgroundImage: FileImage(File(profilePicture)),
              );
            } else {
              // Get user's name initial - check multiple possible keys
              String initial = 'U';
              final name = profileStore.getValue('student_name') ??
                  profileStore.getValue('name') ??
                  profileStore.getValue('user_name');
              if (name != null && name.toString().isNotEmpty) {
                initial = name.toString()[0].toUpperCase();
              }

              // Show colored circle with initial as gravatar
              return CircleAvatar(
                radius: 18,
                backgroundColor: Theme.of(context).colorScheme.primary,
                child: Text(
                  initial,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              );
            }
          },
        ),
      ),
    );
  }
}
