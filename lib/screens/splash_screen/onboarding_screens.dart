// ignore_for_file: use_build_context_synchronously

import 'package:provider/provider.dart';
import 'package:zaitoon/constants/color_class.dart';
import 'package:zaitoon/constants/image_class.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:zaitoon/screens/home_screen/provider/home_provider.dart';
import 'package:zaitoon/screens/login_screen/login_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zaitoon/providers/theme_provider.dart';

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

  String _getIllustrationForTheme(int index, bool isDark) {
    if (isDark) {
      switch (index) {
        case 0:
          return ImageClass.dark1;
        case 1:
          return ImageClass.dark2;
        case 2:
          return ImageClass.dark3;
        case 3:
          return ImageClass.dark4;
        default:
          return data[index]["illustration"];
      }
    } else {
      return data[index]["illustration"];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final isDark = themeProvider.isDarkMode;

        // Set system UI overlay style based on theme
        SystemChrome.setSystemUIOverlayStyle(
          SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness:
                isDark ? Brightness.light : Brightness.light,
            statusBarBrightness: isDark ? Brightness.dark : Brightness.dark,
            systemNavigationBarColor: Colors.transparent,
            systemNavigationBarIconBrightness:
                isDark ? Brightness.light : Brightness.dark,
          ),
        );

        return Scaffold(
          extendBodyBehindAppBar: true,
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
                illustration: _getIllustrationForTheme(index, isDark),
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
                        MaterialPageRoute(
                            builder: (context) => const AuthScreen()),
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
      },
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
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final isDark = themeProvider.isDarkMode;
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
                          color: isDark ? Colors.white : Colors.black,
                          fontSize: 16.0,
                          height: 1.5,
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Page indicators and button (Next or Get Started)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildPageIndicator(isDark),
                          currentPage == totalPages - 1
                              ? _buildGetStartedButton(context)
                              : _buildNextButton(),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPageIndicator(bool isDark) {
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
            color: index == currentPage
                ? null
                : (isDark ? Colors.white70 : ColorClass.black87),
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
                  "Next",
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w400,
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

  Widget _buildGetStartedButton(BuildContext context) {
    final isDark = context.read<ThemeProvider>().isDarkMode;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      child: GestureDetector(
        onTap: onNext,
        child: Container(
          width: 153,
          height: 45,
          clipBehavior: Clip.hardEdge,
          decoration: BoxDecoration(
            color: isDark ? Colors.black : Colors.white,
          ),
          child: SizedBox(
            width: double.infinity,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned(
                  left: 0,
                  top: 0,
                  child: Container(
                    width: 153,
                    height: 45,
                    clipBehavior: Clip.hardEdge,
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.horizontal(
                        left: Radius.circular(24),
                      ),
                      gradient: LinearGradient(
                        colors: [
                          Color(0xFFAC28DC),
                          Color(0xFF7E1EB7),
                          Color(0xFF501392)
                        ],
                        stops: [0, 0.50, 1],
                      ),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: const BorderRadius.horizontal(
                          left: Radius.circular(24),
                        ),
                        onTap: onNext,
                        child: Center(
                          child: Text(
                            "Get Started",
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.w400,
                              fontSize: 16.0,
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Demo data for our Onboarding screen
List<Map<String, dynamic>> data = [
  //final isDark = context.watch<ThemeProvider>().isDarkMode;
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
