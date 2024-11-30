// ignore_for_file: use_build_context_synchronously

import 'package:provider/provider.dart';
import 'package:zaitoon/constants/color_class.dart';
import 'package:zaitoon/constants/image_class.dart';
import 'package:zaitoon/helper/navigation_helper.dart';
import 'package:flutter/material.dart';
import 'package:zaitoon/screens/home_screen/provider/home_provider.dart';
import 'package:zaitoon/screens/login_screen/login_screen.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorClass.black,
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(flex: 2),
            Expanded(
              flex: 14,
              child: Consumer<HomeProvider>(
                builder: (context, provider, child) => PageView.builder(
                  itemCount: demoData.length,
                  onPageChanged: (value) {
                    provider.setCurrentPage(value);
                  },
                  itemBuilder: (context, index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    child: OnboardContent(
                      illustration: demoData[provider.currentPage]
                          ["illustration"],
                      title: demoData[provider.currentPage]["title"],
                      text: demoData[provider.currentPage]["text"],
                    ),
                  ),
                ),
              ),
            ),
            const Spacer(),
            Consumer<HomeProvider>(
              builder: (context, provider, child) => Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  demoData.length,
                  (index) =>
                      DotIndicator(isActive: index == provider.currentPage),
                ),
              ),
            ),
            const Spacer(flex: 2),
            Consumer<HomeProvider>(
              builder: (context, provider, child) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ElevatedButton(
                  onPressed: () async {
                    if (provider.currentPage < demoData.length - 1) {
                      provider.nextPage();
                    } else {
                      await provider.setOnboardingCompleted();
                      navigateAndRemove(
                        context: context,
                        screen: const AuthScreen(),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorClass.primaryColor,
                    foregroundColor: ColorClass.white,
                    minimumSize: const Size(double.infinity, 40),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text("Get Started".toUpperCase()),
                ),
              ),
            ),
            const Spacer(),
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
    return Column(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: AspectRatio(
              aspectRatio: 1,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.asset(
                  illustration!,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          title!,
          style: Theme.of(context).textTheme.titleLarge!.copyWith(
                fontWeight: FontWeight.bold,
                color: ColorClass.white,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          text!,
          style: Theme.of(context)
              .textTheme
              .bodyMedium!
              .copyWith(color: ColorClass.white),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class DotIndicator extends StatelessWidget {
  const DotIndicator({
    super.key,
    this.isActive = false,
    this.activeColor = ColorClass.primaryColor,
    this.inActiveColor = const Color(0xFF868686),
  });

  final bool isActive;
  final Color activeColor, inActiveColor;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      margin: const EdgeInsets.symmetric(horizontal: 16 / 2),
      height: 5,
      width: 8,
      decoration: BoxDecoration(
        color: isActive ? activeColor : inActiveColor.withOpacity(0.25),
        borderRadius: const BorderRadius.all(Radius.circular(20)),
      ),
    );
  }
}

// Demo data for our Onboarding screen
List<Map<String, dynamic>> demoData = [
  {
    "illustration": ImageClass.onboarding1,
    "title": "Magical Stories Every Day",
    "text": "Discover enchanting tales that spark your child's imagination",
  },
  {
    "illustration": ImageClass.onboarding2,
    "title": "Read Together, Grow Together",
    "text": "Create precious bedtime moments with interactive storytelling",
  },
  {
    "illustration": ImageClass.onboarding3,
    "title": "Learning Made Fun",
    "text": "Stories filled with values, morals and educational adventures",
  },
];
