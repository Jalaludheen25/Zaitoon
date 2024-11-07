// ignore_for_file: use_build_context_synchronously

import 'package:zaitoon/helper/navigation_helper.dart';
import 'package:zaitoon/screens/home_screen/home_screen.dart';
import 'package:zaitoon/screens/home_screen/provider/home_provider.dart';
import 'package:zaitoon/screens/splash_screen/onboarding_screens.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateBasedOnOnboardingStatus();
  }

  Future<void> _navigateBasedOnOnboardingStatus() async {
    // Access HomeProvider to check onboarding status
    final homeProvider = Provider.of<HomeProvider>(context, listen: false);
    bool isOnboardingCompleted = await homeProvider.isOnboardingCompleted();
    homeProvider.loadSelectedLanguage();

    Future.delayed(const Duration(seconds: 2), () {
      if (isOnboardingCompleted) {
        // Navigate to HomeScreen if onboarding is completed
        navigateTo(context: context, route: const HomeScreen());
      } else {
        // Otherwise, navigate to OnboardingScreen
        navigateTo(context: context, route: const OnboardingScreen());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Mascot character container
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: Image.asset(
                    'assets/images/tiger1.png',
                    height: MediaQuery.sizeOf(context).height * 0.4,
                  ),
                ),
              ),
              const SizedBox(height: 15),

              // Headline text
              const Text(
                'Welcome to Zai Toon',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),

              // Subtitle
              const Text(
                'Interactive stories with sound effects as you read along',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),

              const CupertinoActivityIndicator(
                color: Colors.white,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
