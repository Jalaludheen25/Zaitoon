// lib/screens/user_data_collection/screens/avatar_customizer_screen.dart

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zaitoon/constants/color_class.dart';
import 'package:zaitoon/constants/image_class.dart';
import 'package:zaitoon/screens/user_data_collection_screen/provider/user_data_provider.dart';

class AvatarCustomizerScreen extends StatefulWidget {
  const AvatarCustomizerScreen({super.key});

  @override
  State<AvatarCustomizerScreen> createState() => _AvatarCustomizerScreenState();
}

class _AvatarCustomizerScreenState extends State<AvatarCustomizerScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  int _currentIndex = 0;
  double _dragOffset = 0.0;
  bool _isDragging = false;
  final List<String> _avatars = const [
    ImageClass.avatar1,
    ImageClass.avatar2,
    ImageClass.avatar3,
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    // Set initial avatar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<UserDataProvider>(context, listen: false);
      provider.setAvatar(_avatars[_currentIndex]);
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _navigateToIndex(int newIndex) {
    if (newIndex >= 0 &&
        newIndex < _avatars.length &&
        newIndex != _currentIndex) {
      setState(() {
        _currentIndex = newIndex;
        _dragOffset = 0.0;
        _isDragging = false;
      });
      _animationController.forward().then((_) {
        _animationController.reset();
      });

      final provider = Provider.of<UserDataProvider>(context, listen: false);
      provider.setAvatar(_avatars[_currentIndex]);
    }
  }

  void _handleDragStart(DragStartDetails details) {
    setState(() {
      _isDragging = true;
    });
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    if (_isDragging) {
      setState(() {
        _dragOffset += details.delta.dx;
      });
    }
  }

  void _handleDragEnd(DragEndDetails details) {
    if (!_isDragging) return;

    const double threshold = 50.0;
    final double velocity = details.velocity.pixelsPerSecond.dx;

    setState(() {
      _isDragging = false;
    });

    // Determine direction based on drag distance and velocity
    if (_dragOffset > threshold || velocity > 300) {
      // Swipe right - go to previous avatar
      _navigateToIndex((_currentIndex - 1 + _avatars.length) % _avatars.length);
    } else if (_dragOffset < -threshold || velocity < -300) {
      // Swipe left - go to next avatar
      _navigateToIndex((_currentIndex + 1) % _avatars.length);
    } else {
      // Snap back to center
      setState(() {
        _dragOffset = 0.0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double maxWidth = constraints.maxWidth;
        final double big = (maxWidth * 0.32).clamp(100.0, 140.0);
        final double small = (big * 0.6).clamp(60.0, 90.0);

        // Avatar sizes are calculated based on screen width

        return SizedBox(
          height: big + 20,
          child: GestureDetector(
            onPanStart: _handleDragStart,
            onPanUpdate: _handleDragUpdate,
            onPanEnd: _handleDragEnd,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Left avatar (previous)
                Transform.translate(
                  offset: Offset(_dragOffset * 0.3, 0),
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 200),
                    opacity: _isDragging ? 0.8 : 0.6,
                    child: _buildAvatarCircle(
                      _avatars[(_currentIndex - 1 + _avatars.length) %
                          _avatars.length],
                      small,
                      false,
                      blurred: true,
                    ),
                  ),
                ),

                // Center avatar (current)
                Transform.translate(
                  offset: Offset(_dragOffset * 0.5, 0),
                  child: AnimatedBuilder(
                    animation: _animation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: 1.0 + (_animation.value * 0.05),
                        child: _buildAvatarCircle(
                          _avatars[_currentIndex],
                          big,
                          true,
                          blurred: false,
                        ),
                      );
                    },
                  ),
                ),

                // Right avatar (next)
                Transform.translate(
                  offset: Offset(_dragOffset * 0.3, 0),
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 200),
                    opacity: _isDragging ? 0.8 : 0.6,
                    child: _buildAvatarCircle(
                      _avatars[(_currentIndex + 1) % _avatars.length],
                      small,
                      false,
                      blurred: true,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAvatarCircle(String assetPath, double size, bool highlight,
      {bool blurred = false}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: highlight ? ColorClass.violet30 : Colors.transparent,
          width: highlight ? 3 : 0,
        ),
      ),
      child: ClipOval(
        child: ImageFiltered(
          imageFilter: ImageFilter.blur(
            sigmaX: blurred ? 2.5 : 0.0,
            sigmaY: blurred ? 2.5 : 0.0,
          ),
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 300),
            opacity: blurred ? 0.6 : 1.0,
            child: Image.asset(
              assetPath,
              fit: BoxFit.cover,
              width: size,
              height: size,
            ),
          ),
        ),
      ),
    );
  }
}
