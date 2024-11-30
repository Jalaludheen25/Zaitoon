// ignore_for_file: use_build_context_synchronously

import 'dart:math';
import 'dart:ui';

import 'package:zaitoon/constants/color_class.dart';
import 'package:zaitoon/constants/textstyle_class.dart';
import 'package:zaitoon/helper/navigation_helper.dart';
import 'package:zaitoon/screens/bottom_navigation/bottom_navigation.dart';
import 'package:flutter/material.dart';

class AknowledgeScreen extends StatelessWidget {
  const AknowledgeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Animated Background
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  ColorClass.primaryColor.withOpacity(0.2),
                  ColorClass.black,
                ],
              ),
            ),
            child: CustomPaint(
              painter: StarfieldPainter(),
              size: Size.infinite,
            ),
          ),

          // Floating Elements
          const Positioned(
            top: 80,
            left: 30,
            child: FloatingElement(emoji: '✨', size: 20),
          ),
          const Positioned(
            top: 120,
            right: 40,
            child: FloatingElement(emoji: '✨', size: 24),
          ),
          const Positioned(
            top: 200,
            left: 60,
            child: FloatingElement(emoji: '🦋', size: 28),
          ),
          const Positioned(
            top: 180,
            right: 70,
            child: FloatingElement(emoji: '🦋', size: 26),
          ),

          // Animated Mascots
          Positioned(
            top: MediaQuery.of(context).size.height * 0.15,
            right: MediaQuery.of(context).size.width * 0.1,
            child: const EnhancedAnimatedFairy(
              image: 'assets/images/tiger3.png',
              rotationRange: 0.1,
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).size.height * 0.25,
            left: MediaQuery.of(context).size.width * 0.1,
            child: const EnhancedAnimatedFairy(
              image: 'assets/images/tiger4.png',
              rotationRange: -0.1,
            ),
          ),

          // Content Card with Glass Effect
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(32),
                topRight: Radius.circular(32),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: ColorClass.black.withOpacity(0.8),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(32),
                      topRight: Radius.circular(32),
                    ),
                    border: Border.all(
                      color: ColorClass.primaryColor.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ShaderMask(
                        shaderCallback: (bounds) => LinearGradient(
                          colors: [
                            ColorClass.primaryColor,
                            ColorClass.primaryColor.withOpacity(0.8),
                          ],
                        ).createShader(bounds),
                        child: Text(
                          'Unlock the Magic of Reading',
                          style: TextStyleClass.poppinsBold(
                            color: Colors.white,
                            fontSize: 28,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 24),
                      const EnhancedBulletPoint(
                        icon: '🌟',
                        text:
                            'Just one story a day makes a huge positive impact for kids.',
                        highlightedWord: 'positive',
                      ),
                      const SizedBox(height: 16),
                      const EnhancedBulletPoint(
                        icon: '📚',
                        text:
                            'Our stories include moral lessons as well as educational topics.',
                        highlightedWord: 'educational',
                      ),
                      const SizedBox(height: 32),
                      PulsatingButton(
                        onPressed: () {
                          navigateAndRemove(
                            context: context,
                            screen: const BottomNavigationScreen(),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class EnhancedBulletPoint extends StatelessWidget {
  final String text;
  final String highlightedWord;
  final String icon;

  const EnhancedBulletPoint({
    super.key,
    required this.text,
    required this.highlightedWord,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final parts = text.split(highlightedWord);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$icon ',
          style: const TextStyle(fontSize: 20),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: TextStyleClass.poppinsRegular(
                color: ColorClass.white.withOpacity(0.9),
                fontSize: 16,
              ),
              children: [
                TextSpan(text: parts[0]),
                TextSpan(
                  text: highlightedWord,
                  style: TextStyle(
                    color: ColorClass.primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextSpan(text: parts[1]),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class PulsatingButton extends StatefulWidget {
  final VoidCallback onPressed;

  const PulsatingButton({super.key, required this.onPressed});

  @override
  State<PulsatingButton> createState() => _PulsatingButtonState();
}

class _PulsatingButtonState extends State<PulsatingButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: LinearGradient(
                colors: [
                  ColorClass.primaryColor,
                  ColorClass.primaryColor.withOpacity(0.8),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: ColorClass.primaryColor.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: widget.onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Start Reading',
                style: TextStyleClass.poppinsRegular(
                  fontSize: 18,
                  color: ColorClass.white,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class EnhancedAnimatedFairy extends StatefulWidget {
  final String image;
  final double rotationRange;

  const EnhancedAnimatedFairy({
    super.key,
    required this.image,
    this.rotationRange = 0.1,
  });

  @override
  State<EnhancedAnimatedFairy> createState() => _EnhancedAnimatedFairyState();
}

class _EnhancedAnimatedFairyState extends State<EnhancedAnimatedFairy>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _floatAnimation;
  late Animation<double> _rotateAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);

    _floatAnimation = Tween<double>(begin: -15.0, end: 15.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _rotateAnimation = Tween<double>(
      begin: -widget.rotationRange,
      end: widget.rotationRange,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _floatAnimation.value),
          child: Transform.rotate(
            angle: _rotateAnimation.value,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: ColorClass.primaryColor.withOpacity(0.2),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Image.asset(
                widget.image,
                fit: BoxFit.contain,
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class StarfieldPainter extends CustomPainter {
  final Random _random = Random();
  final List<Offset> _stars = [];
  final Paint _paint = Paint()..color = Colors.white.withOpacity(0.5);

  StarfieldPainter() {
    for (int i = 0; i < 50; i++) {
      _stars.add(Offset(
        _random.nextDouble() * 400,
        _random.nextDouble() * 400,
      ));
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    for (var star in _stars) {
      canvas.drawCircle(star, 1, _paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class FloatingElement extends StatefulWidget {
  final String emoji;
  final double size;

  const FloatingElement({
    super.key,
    required this.emoji,
    required this.size,
  });

  @override
  State<FloatingElement> createState() => _FloatingElementState();
}

class _FloatingElementState extends State<FloatingElement>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _floatAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(seconds: 2 + Random().nextInt(2)),
      vsync: this,
    )..repeat(reverse: true);

    _floatAnimation = Tween<double>(begin: -10.0, end: 10.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(_floatAnimation.value, _floatAnimation.value),
          child: Text(
            widget.emoji,
            style: TextStyle(fontSize: widget.size),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
