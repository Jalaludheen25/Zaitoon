// ignore_for_file: use_build_context_synchronously

import 'package:provider/provider.dart';
import 'package:zaitoon/constants/color_class.dart';
import 'package:zaitoon/constants/image_class.dart';
import 'package:zaitoon/helper/navigation_helper.dart';
import 'package:flutter/material.dart';
import 'package:zaitoon/screens/home_screen/provider/home_provider.dart';
import 'package:zaitoon/screens/login_screen/login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<HomeProvider>(
        builder: (context, provider, child) => Stack(
          children: [
            // Full screen PageView with images
            PageView.builder(
              controller: _pageController,
              itemCount: demoData.length,
              onPageChanged: (value) {
                provider.setCurrentPage(value);
              },
              itemBuilder: (context, index) => OnboardContent(
                illustration: demoData[index]["illustration"],
                title: demoData[index]["title"],
                text: demoData[index]["text"],
              ),
            ),

            // Skip button - top right (simple text)
            Positioned(
              top: MediaQuery.of(context).padding.top + 16,
              right: 16,
              child: GestureDetector(
                onTap: () async {
                  await provider.setOnboardingCompleted();
                  navigateAndRemove(
                    context: context,
                    screen: const AuthScreen(),
                  );
                },
                child: const Text(
                  'Skip',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),

            // Dot indicators - left bottom corner
            Positioned(
              bottom: MediaQuery.of(context).padding.bottom + 40,
              left: 20,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(
                  demoData.length,
                  (index) =>
                      DotIndicator(isActive: index == provider.currentPage),
                ),
              ),
            ),

            // Get Started button - half-cut pill shape on right side (only on last slide)
            if (provider.currentPage == demoData.length - 1)
              Positioned(
                bottom: MediaQuery.of(context).padding.bottom + 40,
                right: 0,
                child: Container(
                  width: 140,
                  height: 50,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        ColorClass.violet30,
                        ColorClass.violet10,
                      ],
                    ),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(25),
                      bottomLeft: Radius.circular(25),
                    ),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(25),
                        bottomLeft: Radius.circular(25),
                      ),
                      onTap: () async {
                        await provider.setOnboardingCompleted();
                        navigateAndRemove(
                          context: context,
                          screen: const AuthScreen(),
                        );
                      },
                      child: const Center(
                        child: Padding(
                          padding: EdgeInsets.only(right: 16),
                          child: Text(
                            'Get Started',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

            // Next button - bottom right (for other slides)
            if (provider.currentPage != demoData.length - 1)
              Positioned(
                bottom: MediaQuery.of(context).padding.bottom + 40,
                right: 16,
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        ColorClass.violet30,
                        ColorClass.violet10,
                      ],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    onPressed: () {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                    icon: const Icon(
                      Icons.arrow_forward,
                      color: ColorClass.white,
                      size: 24,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class OnboardContent extends StatelessWidget {
  const OnboardContent({
    super.key,
    required this.illustration,
    required this.title,
    required this.text,
  });

  final String? illustration, title, text;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Full screen background image
        Positioned.fill(
          child: Image.asset(
            illustration!,
            fit: BoxFit.cover,
          ),
        ),

        // Gradient overlay for better text readability
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.transparent,
                  Colors.black.withOpacity(0.3),
                  Colors.black.withOpacity(0.7),
                ],
                stops: const [0.0, 0.4, 0.7, 1.0],
              ),
            ),
          ),
        ),

        // Text content positioned lower
        Positioned(
          bottom: 140,
          left: 20,
          right: 20,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                title!,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  height: 1.2,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                text!,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.white,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class DotIndicator extends StatelessWidget {
  const DotIndicator({
    super.key,
    this.isActive = false,
    this.activeColor = ColorClass.white,
    this.inActiveColor = const Color(0xFF868686),
  });

  final bool isActive;
  final Color activeColor, inActiveColor;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      height: 8,
      width: isActive ? 24 : 8,
      decoration: BoxDecoration(
        gradient: isActive
            ? const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  ColorClass.violet30,
                  ColorClass.violet10,
                ],
              )
            : null,
        color: isActive ? null : inActiveColor.withOpacity(0.5),
        borderRadius: const BorderRadius.all(Radius.circular(4)),
      ),
    );
  }
}

// Demo data for our Onboarding screen
List<Map<String, dynamic>> demoData = [
  {
    "illustration": ImageClass.onboarding1,
    "title": "ZaiToon Kids – Where\nStories Come Alive!",
    "text":
        "Discover magical stories in\nMalayalam, English, Hindi & Urdu –\ncrafted to spark imagination and joy.",
  },
  {
    "illustration": ImageClass.onboarding2,
    "title": "Playful Reading\nAdventures.",
    "text":
        "Dive into enchanting tales and fun\nquizzes that spark imagination,\ncreativity, and language skills.",
  },
  {
    "illustration": ImageClass.onboarding3,
    "title": "Watch & Enjoy\nTogether",
    "text":
        "A safe platform filled with kid-\nfriendly entertainment and\neducational content.",
  },
  {
    "illustration": ImageClass.onboarding4,
    "title": "Create Your Story\nWorld",
    "text":
        "Bookmark stories, continue where\nyou left off, and enjoy bedtime reads\nwith your favorites.",
  },
];
