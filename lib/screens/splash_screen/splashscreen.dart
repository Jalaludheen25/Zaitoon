// ignore_for_file: use_build_context_synchronously

import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:zaitoon/constants/color_class.dart';
import 'package:zaitoon/constants/image_class.dart';
import 'package:zaitoon/helper/navigation_helper.dart';
import 'package:zaitoon/screens/bottom_navigation/bottom_navigation.dart';
import 'package:zaitoon/screens/home_screen/provider/home_provider.dart';
import 'package:zaitoon/screens/language_selection/language_selection.dart';
import 'package:zaitoon/screens/login_screen/login_screen.dart';
import 'package:zaitoon/screens/login_screen/provider/auth_provider.dart';
import 'package:zaitoon/screens/splash_screen/onboarding_screens.dart';
import 'package:zaitoon/screens/user_data_collection_screen/provider/user_data_provider.dart';
import 'package:zaitoon/screens/user_data_collection_screen/user_data_collection_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _mainController;
  late AnimationController _bounceController;
  late AnimationController _glowController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _bounceAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAndNavigate();
    _initializeAnimations();
  }

  Future<void> _initializeAndNavigate() async {
    final homeProvider = Provider.of<HomeProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    await Future.wait([
      homeProvider.loadSelectedLanguage(),
      authProvider.checkUserStatus(),
    ]);

    await Future.delayed(const Duration(seconds: 3));

    final bool isOnboardingCompleted =
        await homeProvider.isOnboardingCompleted();

    if (!isOnboardingCompleted) {
      navigateAndRemove(context: context, screen: const OnboardingScreen());
      return;
    }

    if (authProvider.isSignedIn) {
      // User is signed in, check if they've completed the full onboarding flow
      await _checkUserFlowCompletion();
    } else {
      navigateAndRemove(context: context, screen: const AuthScreen());
    }
  }

  Future<void> _checkUserFlowCompletion() async {
    try {
      final homeProvider = Provider.of<HomeProvider>(context, listen: false);
      final userDataProvider = Provider.of<UserDataProvider>(context, listen: false);
      
      // Check if language is selected
      if (homeProvider.selectedLanguage.isEmpty) {
        navigateAndRemove(context: context, screen: const LanguageSelection());
        return;
      }
      
      // Load user data and check if it's complete
      await userDataProvider.loadUserDetails();
      
      if (userDataProvider.name == null ||
          userDataProvider.name!.isEmpty ||
          userDataProvider.age == null ||
          userDataProvider.age! <= 0 ||
          userDataProvider.gender.isEmpty) {
        // User data is incomplete, go to user data collection
        navigateAndRemove(
          context: context,
          screen: const UserDataCollection(isFromOnboarding: true),
        );
      } else {
        // Everything is complete, go to home screen
        navigateAndRemove(context: context, screen: const BottomNavigationScreen());
      }
    } catch (e) {
      print('Error checking user flow completion: $e');
      // On error, start from language selection
      navigateAndRemove(context: context, screen: const LanguageSelection());
    }
  }

  void _initializeAnimations() {
    _mainController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _glowController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    )..repeat(reverse: true);

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _mainController, curve: Curves.easeIn),
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _mainController, curve: Curves.elasticOut),
    );

    _bounceAnimation = TweenSequence([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0, end: -15),
        weight: 1,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: -15, end: 0),
        weight: 1,
      ),
    ]).animate(
      CurvedAnimation(parent: _bounceController, curve: Curves.easeInOut),
    );

    _mainController.forward();
    _bounceController.repeat();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorClass.black,
      body: Stack(
        children: [
          // Animated Background
          CustomPaint(
            painter: StarfieldPainter(
              glowAnimation: _glowController,
              primaryColor: ColorClass.primaryColor,
            ),
            size: Size.infinite,
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: MediaQuery.of(context).size.height -
                        MediaQuery.of(context).padding.top -
                        MediaQuery.of(context).padding.bottom,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        children: [
                          // First section - mascot and animations
                          FadeTransition(
                            opacity: _fadeAnimation,
                            child: AnimatedBuilder(
                              animation: _bounceAnimation,
                              builder: (context, child) {
                                return Transform.translate(
                                  offset: Offset(0, _bounceAnimation.value),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20),
                                      boxShadow: [
                                        BoxShadow(
                                          color: ColorClass.primaryColor
                                              .withOpacity(0.3),
                                          spreadRadius: 10,
                                          blurRadius: 30,
                                        ),
                                      ],
                                    ),
                                    child: ScaleTransition(
                                      scale: _scaleAnimation,
                                      child: Image.asset(
                                        ImageClass.appIconPlain,
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.25,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Animated logo
                          ScaleTransition(
                            scale: _scaleAnimation,
                            child: ShaderMask(
                              shaderCallback: (bounds) => LinearGradient(
                                colors: [
                                  ColorClass.primaryColor,
                                  ColorClass.primaryColor.withOpacity(0.8),
                                ],
                              ).createShader(bounds),
                              child: Image.asset(
                                ImageClass.malarvadiLogo,
                                height:
                                    MediaQuery.of(context).size.height * 0.08,
                              ),
                            ),
                          ),
                          const SizedBox(height: 30),

                          // Welcome text and sparkles
                          ShaderMask(
                            shaderCallback: (bounds) => LinearGradient(
                              colors: [
                                ColorClass.primaryColor,
                                Colors.white,
                              ],
                            ).createShader(bounds),
                            child: AnimatedTextKit(
                              animatedTexts: [
                                TypewriterAnimatedText(
                                  'Welcome to Zai Toon',
                                  textStyle: const TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                  speed: const Duration(milliseconds: 100),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                              totalRepeatCount: 1,
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Subtitle with sparkles
                          FadeTransition(
                            opacity: _fadeAnimation,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _buildSparkle(),
                                const Text(
                                  'Magical stories await you',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: ColorClass.white70,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                _buildSparkle(),
                              ],
                            ),
                          ),
                          const SizedBox(height: 30),

                          // Custom loading indicator
                          _buildCustomLoader(),
                        ],
                      ),

                      // Powered by section
                      Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: _buildPoweredBySection(),
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

  Widget _buildSparkle() {
    return AnimatedBuilder(
      animation: _glowController,
      builder: (context, child) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Transform.scale(
            scale: 1 + _glowController.value * 0.2,
            child: const Text(
              '✨',
              style: TextStyle(fontSize: 16),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCustomLoader() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: ColorClass.primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: ColorClass.primaryColor.withOpacity(0.2),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CupertinoActivityIndicator(
              color: ColorClass.primaryColor,
              radius: 12,
            ),
            const SizedBox(width: 12),
            Text(
              'Getting your stories ready...',
              style: TextStyle(
                color: ColorClass.primaryColor.withOpacity(0.8),
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPoweredBySection() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Column(
        children: [
          const Text(
            'Powered by',
            style: TextStyle(
              fontSize: 12,
              color: ColorClass.white70,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(ImageClass.d4Logo,
                  height: 80, color: ColorClass.white),
            ],
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _mainController.dispose();
    _bounceController.dispose();
    _glowController.dispose();
    super.dispose();
  }
}

class StarfieldPainter extends CustomPainter {
  final AnimationController glowAnimation;
  final Color primaryColor;
  final List<Offset> stars = [];
  final Random random = Random();

  StarfieldPainter({required this.glowAnimation, required this.primaryColor})
      : super(repaint: glowAnimation) {
    for (int i = 0; i < 100; i++) {
      stars.add(Offset(
        random.nextDouble() * 400,
        random.nextDouble() * 800,
      ));
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    for (var star in stars) {
      final paint = Paint()
        ..color = primaryColor.withOpacity(0.1 + glowAnimation.value * 0.2)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
      canvas.drawCircle(star, 1 + glowAnimation.value * 2, paint);
    }
  }

  @override
  bool shouldRepaint(StarfieldPainter oldDelegate) => true;
}
