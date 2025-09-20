// ignore_for_file: use_build_context_synchronously

import 'package:provider/provider.dart';
import 'package:zaitoon/constants/color_class.dart';
import 'package:zaitoon/constants/image_class.dart';
import 'package:flutter/material.dart';
import 'package:zaitoon/screens/home_screen/provider/home_provider.dart';
import 'package:zaitoon/screens/login_screen/login_screen.dart';
import 'package:google_fonts/google_fonts.dart';

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
    debugPrint('🎯 OnboardingScreen initialized');
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //extendBodyBehindAppBar: true,
      body: Consumer<HomeProvider>(
        builder: (context, provider, child) => PageView.builder(
          controller: _pageController,
          itemCount: data.length,
          onPageChanged: (value) {
            provider.setCurrentPage(value);
          },
          physics: const NeverScrollableScrollPhysics(),
          pageSnapping: true,
          itemBuilder: (context, index) => OnboardContent(
            illustration: data[index]["illustration"],
            title: data[index]["title"],
            text: data[index]["text"],
            currentPage: provider.currentPage,
            totalPages: data.length,
            onNext: () {
              if (provider.currentPage == data.length - 1) {
                // Last page - go to login screen
                provider.setOnboardingCompleted().then((_) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const AuthScreen()),
                  );
                });
              } else {
                // Next page with smooth slide animation
                _pageController.nextPage(
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeInOutCubic,
                );
              }
            },
            onSkip: () async {
              await provider.setOnboardingCompleted();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const AuthScreen()),
              );
            },
          ),
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
    required this.currentPage,
    required this.totalPages,
    required this.onNext,
    required this.onSkip,
  });

  final String? illustration, title, text;
  final int currentPage;
  final int totalPages;
  final VoidCallback onNext;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: Stack(
        children: [
          // Full screen background image
          Positioned.fill(
            child: Image.asset(
              illustration!,
              fit: BoxFit.cover,
              filterQuality: FilterQuality.high,
              isAntiAlias: true,
              alignment: Alignment.center,
            ),
          ),

          // Skip Button - Top Right with system UI consideration
          if (currentPage != totalPages - 1)
            Positioned(
              top: MediaQuery.of(context).padding.top +
                  20, // Account for status bar
              right: 20,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: GestureDetector(
                  onTap: onSkip,
                  child: Text(
                    "Skip",
                    style: GoogleFonts.openSans(
                      fontWeight: FontWeight.w400,
                      fontSize: 16.0,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),

          // Bottom overlay with text and controls - extending over screen
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.fromLTRB(
                32,
                40,
                32,
                MediaQuery.of(context).padding.bottom +
                    40, // Account for navigation bar
              ),
              child: Column(
                children: [
                  // Text 1 (Title) with gradient
                  ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [
                        ColorClass.grad1,
                        ColorClass.grad2,
                        ColorClass.grad3,
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ).createShader(bounds),
                    child: Text(
                      title!,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.fredoka(
                        fontSize: 24.0,
                        height: 1.2,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Text 2 (Description)
                  Text(
                    text!,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.openSans(
                      fontWeight: FontWeight.w400,
                      color: ColorClass.black87,
                      fontSize: 16.0,
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Page indicators and Next button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildPageIndicator(),
                      _buildNextButton(),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPageIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: List.generate(totalPages, (index) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          margin: const EdgeInsets.only(right: 8.0),
          width: index == currentPage ? 20.0 : 8.0,
          height: 8.0,
          decoration: BoxDecoration(
            gradient: index == currentPage
                ? const LinearGradient(
                    colors: [
                      ColorClass.grad1,
                      ColorClass.grad2,
                      ColorClass.grad3,
                    ],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  )
                : null,
            color: index == currentPage ? null : ColorClass.black87,
            borderRadius: BorderRadius.circular(4.0),
            boxShadow: index == currentPage
                ? [
                    BoxShadow(
                      color: ColorClass.grad2.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    )
                  ]
                : null,
          ),
        );
      }),
    );
  }

  Widget _buildNextButton() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      child: GestureDetector(
        onTap: onNext,
        child: Container(
          width: 117.0,
          height: 45.0,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                ColorClass.grad1,
                ColorClass.grad2,
                ColorClass.grad3,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24.0),
            boxShadow: [
              BoxShadow(
                color: ColorClass.grad2.withOpacity(0.4),
                blurRadius: 3,
                offset: const Offset(0, 1),
                spreadRadius: 0,
              ),
              BoxShadow(
                color: ColorClass.grad1.withOpacity(0.2),
                blurRadius: 20,
                offset: const Offset(0, 10),
                spreadRadius: 0,
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(24.0),
              onTap: onNext,
              child: Center(
                child: Text(
                  currentPage == totalPages - 1 ? "Get Started" : "Next",
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w600,
                    fontSize: 16.0,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Demo data for our Onboarding screen
List<Map<String, dynamic>> data = [
  {
    "illustration": ImageClass.onboard1,
    "title": "ZaiToon Kids – Where\nStories Come Alive!",
    "text":
        "Discover magical stories in\nMalayalam, English, Hindi & Urdu –\ncrafted to spark imagination and joy.",
  },
  {
    "illustration": ImageClass.onboard2,
    "title": "Playful Reading\nAdventures.",
    "text":
        "Dive into enchanting tales and fun\nquizzes that spark imagination,\ncreativity, and language skills.",
  },
  {
    "illustration": ImageClass.onboard3,
    "title": "Watch & Enjoy\nTogether",
    "text":
        "A safe platform filled with kid-\nfriendly entertainment and\neducational content.",
  },
  {
    "illustration": ImageClass.onboard4,
    "title": "Create Your Story\nWorld",
    "text":
        "Bookmark stories, continue where\nyou left off, and enjoy bedtime reads\nwith your favorites.",
  },
];
