// ignore_for_file: use_build_context_synchronously

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:zaitoon/constants/color_class.dart';
import 'package:zaitoon/constants/image_class.dart';
import 'package:zaitoon/helper/navigation_helper.dart';
import 'package:zaitoon/screens/bottom_navigation/bottom_navigation.dart';
import 'package:zaitoon/screens/home_screen/provider/home_provider.dart';
import 'package:zaitoon/screens/login_screen/login_screen.dart';
import 'package:zaitoon/screens/login_screen/provider/auth_provider.dart';
import 'package:zaitoon/screens/splash_screen/onboarding_screens.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAndNavigate();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeIn,
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutBack,
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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

    if (authProvider.isSignedIn) {
      if (isOnboardingCompleted) {
        navigateAndRemove(context: context, screen: const OnboardingScreen());
      } else {
        navigateAndRemove(
            context: context, screen: const BottomNavigationScreen());
      }
    } else {
      navigateAndRemove(context: context, screen: const AuthScreen());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorClass.black,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              ColorClass.black,
              ColorClass.black.withOpacity(0.8),
              ColorClass.black.withOpacity(0.6),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Animated mascot
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: ScaleTransition(
                    scale: _scaleAnimation,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.white.withOpacity(0.1),
                            spreadRadius: 5,
                            blurRadius: 15,
                          ),
                        ],
                      ),
                      child: Image.asset(
                        ImageClass.appIconPlain,
                        height: MediaQuery.of(context).size.height * 0.4,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 30),

                // Animated logo
                ScaleTransition(
                  scale: _scaleAnimation,
                  child: Image.asset(
                    ImageClass.malarvadiLogo,
                    height: MediaQuery.of(context).size.height * 0.1,
                  ),
                ),
                const SizedBox(height: 30),

                // Animated title
                AnimatedTextKit(
                  animatedTexts: [
                    TypewriterAnimatedText(
                      'Welcome to Zai Toon',
                      textStyle: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: ColorClass.white,
                      ),
                      speed: const Duration(milliseconds: 100),
                      textAlign: TextAlign.center,
                    ),
                  ],
                  totalRepeatCount: 1,
                ),
                const SizedBox(height: 16),

                // Animated subtitle
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: const Text(
                    'Interactive stories as you read along',
                    style: TextStyle(
                      fontSize: 16,
                      color: ColorClass.white70,
                      letterSpacing: 0.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 20),
                // Custom loading indicator
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      const CupertinoActivityIndicator(
                        color: ColorClass.white,
                        radius: 15,
                      ),
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: ColorClass.white.withOpacity(0.2),
                            width: 2,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                Column(
                  children: [
                    const Text(
                      'Powered by',
                      style: TextStyle(
                        fontSize: 12,
                        color: ColorClass.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          ImageClass.d4Logo,
                          height: 100,
                          fit: BoxFit.contain,
                          color: ColorClass.white,
                        ),
                        Image.asset(
                          ImageClass.d4dxLogo,
                          height: 100,
                          fit: BoxFit.contain,
                          color: ColorClass.white,
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
