import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zaitoon/constants/color_class.dart';
import 'dart:ui';

import 'package:zaitoon/screens/version_check/provider/version_check_provider.dart';

class UpdateDialog extends StatefulWidget {
  const UpdateDialog({super.key});

  @override
  State<UpdateDialog> createState() => _UpdateDialogState();
}

class _UpdateDialogState extends State<UpdateDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildWhatsNewSection(BuildContext context, String? changes) {
    if (changes == null || changes.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Theme.of(context).colorScheme.outlineVariant,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.new_releases_rounded,
                size: 20,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'What\'s New',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...changes.split('\n').map((change) {
            if (change.trim().isEmpty) return const SizedBox.shrink();

            final cleanedChange =
                change.trim().replaceAll(RegExp(r'^[-•]\s*'), '');
            IconData icon = _getIconForChange(cleanedChange.toLowerCase());

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    icon,
                    size: 18,
                    color:
                        Theme.of(context).colorScheme.primary.withOpacity(0.7),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      cleanedChange,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            height: 1.4,
                          ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  IconData _getIconForChange(String change) {
    if (change.contains('language') ||
        change.contains('translation') ||
        change.contains('word')) {
      return Icons.translate_rounded;
    } else if (change.contains('audio') ||
        change.contains('sound') ||
        change.contains('playback')) {
      return Icons.music_note_rounded;
    } else if (change.contains('design') ||
        change.contains('theme') ||
        change.contains('ui')) {
      return Icons.palette_rounded;
    } else if (change.contains('reminder') || change.contains('notification')) {
      return Icons.notifications_rounded;
    } else if (change.contains('performance') || change.contains('speed')) {
      return Icons.speed_rounded;
    } else if (change.contains('bug') || change.contains('fix')) {
      return Icons.bug_report_rounded;
    } else if (change.contains('security')) {
      return Icons.security_rounded;
    }
    return Icons.check_circle_outline_rounded;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<VersionCheckProvider>(
      builder: (context, provider, child) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: const EdgeInsets.symmetric(horizontal: 20),
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 20,
                        spreadRadius: 5,
                        offset: Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Update Icon with Animation
                      TweenAnimationBuilder<double>(
                        duration: const Duration(seconds: 1),
                        tween: Tween(begin: 0, end: 1),
                        builder: (context, value, child) {
                          return Transform.rotate(
                            angle: value * 2 * 3.14,
                            child: Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: ColorClass.black.withOpacity(0.8),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: ColorClass.black.withOpacity(0.3),
                                    blurRadius: 20,
                                    spreadRadius: value * 5,
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.system_update_rounded,
                                size: 48,
                                color: ColorClass.white,
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 24),

                      // Title with Gradient
                      ShaderMask(
                        shaderCallback: (bounds) => LinearGradient(
                          colors: [
                            Theme.of(context).colorScheme.primary,
                            Theme.of(context).colorScheme.secondary,
                          ],
                        ).createShader(bounds),
                        child: Text(
                          'Update Available!',
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.2,
                                  ),
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Version Info with Animation
                      TweenAnimationBuilder<double>(
                        duration: const Duration(milliseconds: 800),
                        tween: Tween(begin: 0, end: 1),
                        builder: (context, value, child) {
                          return Opacity(
                            opacity: value,
                            child: Transform.translate(
                              offset: Offset(0, 20 * (1 - value)),
                              child: Text('Version ${provider.newVersion}',
                                  style: TextStyle(
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                    fontWeight: FontWeight.normal,
                                    letterSpacing: 0.5,
                                  )),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 20),

                      // Mandatory Update Badge
                      if (provider.forceUpdate)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.errorContainer,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Theme.of(context)
                                    .colorScheme
                                    .error
                                    .withOpacity(0.3),
                                blurRadius: 8,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.warning_rounded,
                                size: 16,
                                color: Colors.white,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Mandatory Update',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      const SizedBox(height: 24),

                      // What's New Section
                      _buildWhatsNewSection(context, provider.changes),
                      const SizedBox(height: 32),

                      // Action Buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          if (!provider.forceUpdate)
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 12,
                                ),
                              ),
                              child: const Text(
                                'Later',
                                style: TextStyle(
                                  color: ColorClass.primaryColor,
                                ),
                              ),
                            ),
                          const SizedBox(width: 12),
                          ElevatedButton(
                            onPressed: () {
                              provider.launchAppStore(context: context);
                            },
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 28,
                                vertical: 14,
                              ),
                              backgroundColor: ColorClass.primaryColor,
                              foregroundColor:
                                  Theme.of(context).colorScheme.onPrimary,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Update Now',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                SizedBox(width: 8),
                                Icon(Icons.arrow_forward_rounded, size: 18),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
