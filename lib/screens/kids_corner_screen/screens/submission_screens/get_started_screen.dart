import 'dart:math';
import 'dart:math' show sin, pi, Random;
import 'package:flutter/material.dart';
import 'package:zaitoon/constants/color_class.dart';
import 'package:zaitoon/helper/navigation_helper.dart';
import 'package:zaitoon/screens/kids_corner_screen/components/floating_bubbles.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter/services.dart';
import 'package:zaitoon/screens/kids_corner_screen/screens/submission_screens/submission_screen.dart';

class GetStartedScreen extends StatefulWidget {
  const GetStartedScreen({super.key});

  @override
  State<GetStartedScreen> createState() => _GetStartedScreenState();
}

class _GetStartedScreenState extends State<GetStartedScreen>
    with TickerProviderStateMixin {
  late AnimationController _buttonController;
  late AnimationController _backgroundController;
  late AnimationController _scaleController;
  bool _isButtonHovered = false;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _buttonController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _backgroundController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();

    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    HapticFeedback.lightImpact();
  }

  @override
  void dispose() {
    _buttonController.dispose();
    _backgroundController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  Widget _buildActionButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return FadeInLeft(
      duration: const Duration(milliseconds: 800),
      child: Container(
        decoration: BoxDecoration(
          color: ColorClass.primaryColor.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: ColorClass.primaryColor.withOpacity(0.3),
          ),
        ),
        child: IconButton(
          icon: Icon(icon, color: ColorClass.white, size: 20),
          onPressed: onPressed,
        ),
      ),
    );
  }

  List<Widget> _buildSparkles() {
    return List.generate(
      50,
      (index) => Positioned(
        top: _random.nextDouble() * MediaQuery.of(context).size.height,
        left: _random.nextDouble() * MediaQuery.of(context).size.width,
        child: AnimatedBuilder(
          animation: _backgroundController,
          builder: (context, child) {
            final sparkleOpacity =
                sin((_backgroundController.value * 2 * pi) + index);
            return Transform.rotate(
              angle: _backgroundController.value * 2 * pi,
              child: Icon(
                Icons.star,
                size: 12 + (index % 8),
                color: Colors.white.withOpacity(sparkleOpacity.abs() * 0.3),
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF7C53F4),
              const Color(0xFF4A25AA),
            ],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              ..._buildSparkles(),
              ...List.generate(
                8,
                (index) => Positioned(
                  left: (MediaQuery.of(context).size.width / 8) * index +
                      (index % 2 == 0 ? 20 : -20),
                  top: index % 3 == 0
                      ? MediaQuery.of(context).size.height * 0.2
                      : index % 3 == 1
                          ? MediaQuery.of(context).size.height * 0.5
                          : MediaQuery.of(context).size.height * 0.8,
                  child: SlideInUp(
                    duration: Duration(milliseconds: 1500 + (index * 300)),
                    child: FloatingBubble(
                      size: 20.0 + (Random().nextDouble() * 40),
                      delay: (index * 1.5).toInt(),
                      color: Colors.white.withOpacity(0.15 - (index * 0.01)),
                    ),
                  ),
                ),
              ),
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: MouseRegion(
                        onEnter: (_) => _scaleController.forward(),
                        onExit: (_) => _scaleController.reverse(),
                        child: ScaleTransition(
                          scale: Tween<double>(begin: 1.0, end: 1.1)
                              .animate(_scaleController),
                          child: _buildActionButton(
                            icon: Icons.arrow_back_ios_new,
                            onPressed: () {
                              HapticFeedback.lightImpact();
                              navigateBack(context);
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Bounce(
                            duration: const Duration(milliseconds: 1000),
                            child: ShakeX(
                              duration: const Duration(milliseconds: 3000),
                              from: 2,
                              child: Text(
                                'Kids Corner',
                                style: GoogleFonts.bubblegumSans(
                                  fontSize: 40,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  shadows: [
                                    Shadow(
                                      color: Colors.black.withOpacity(0.3),
                                      offset: const Offset(2, 2),
                                      blurRadius: 4,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 250,
                            child: Lottie.asset(
                              'assets/animations/loading.json',
                              fit: BoxFit.contain,
                            ),
                          ),
                          FadeInUp(
                            duration: const Duration(milliseconds: 1000),
                            child: ShakeX(
                              duration: const Duration(milliseconds: 2500),
                              child: Text(
                                'Upload your own stories, poems and drawings!',
                                style: GoogleFonts.quicksand(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.5,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                          const SizedBox(height: 32),
                          Pulse(
                            infinite: true,
                            duration: const Duration(milliseconds: 2000),
                            child: Text(
                              'Hey Kids! 👋',
                              style: GoogleFonts.fredoka(
                                color: Colors.white,
                                fontSize: 32,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          FadeInUp(
                            duration: const Duration(milliseconds: 1400),
                            child: Text(
                              'Share your amazing stories, express yourself through beautiful poems, and show off your creative drawings! Join our fun community of young artists and storytellers.',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.quicksand(
                                color: Colors.white,
                                fontSize: 18,
                                height: 1.5,
                              ),
                            ),
                          ),
                          const SizedBox(height: 48),
                          AnimatedBuilder(
                            animation: _buttonController,
                            builder: (context, child) {
                              return Transform.translate(
                                offset: Offset(
                                    0,
                                    sin(_buttonController.value * 3 * 3.14159) *
                                        5),
                                child: MouseRegion(
                                  onEnter: (_) =>
                                      setState(() => _isButtonHovered = true),
                                  onExit: (_) =>
                                      setState(() => _isButtonHovered = false),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    transform: Matrix4.identity()
                                      ..scale(_isButtonHovered ? 1.05 : 1.0),
                                    child: SizedBox(
                                      width: double.infinity,
                                      height: 60,
                                      child: ElevatedButton(
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  const SubmissionScreen(),
                                            ),
                                          );
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.white,
                                          foregroundColor:
                                              const Color(0xFF7C53F4),
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 16),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(30),
                                          ),
                                          elevation: _isButtonHovered ? 8 : 5,
                                        ),
                                        child: Text(
                                          'Get Started! ✨',
                                          style: GoogleFonts.fredoka(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
