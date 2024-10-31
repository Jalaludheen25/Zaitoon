import 'package:d4tales/constants/color_class.dart';
import 'package:d4tales/helper/navigation_helper.dart';
import 'package:d4tales/screens/login_screen/login_screen.dart';
import 'package:flutter/material.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int currentPage = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(flex: 2),
            Expanded(
              flex: 14,
              child: PageView.builder(
                itemCount: demoData.length,
                onPageChanged: (value) {
                  setState(() {
                    currentPage = value;
                  });
                },
                itemBuilder: (context, index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  child: OnboardContent(
                    illustration: demoData[currentPage]["illustration"],
                    title: demoData[currentPage]["title"],
                    text: demoData[currentPage]["text"],
                  ),
                ),
              ),
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                demoData.length,
                (index) => DotIndicator(isActive: index == currentPage),
              ),
            ),
            const Spacer(flex: 2),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    if (currentPage < demoData.length - 1) {
                      currentPage++;
                    } else {
                      navigateTo(context: context, route: const AuthScreen());
                      // Navigate to the home screen
                    }
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF22A45D),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 40),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text("Get Started".toUpperCase()),
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
                child: Image.network(
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
    this.activeColor = const Color(0xFF22A45D),
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
    "illustration": "https://jih-asset.netlify.app/assets/img/onboarding1.png",
    "title": "Magical Stories Every Day",
    "text": "Discover enchanting tales that spark your child's imagination",
  },
  {
    "illustration": "https://jih-asset.netlify.app/assets/img/onboarding2.png",
    "title": "Read Together, Grow Together",
    "text": "Create precious bedtime moments with interactive storytelling",
  },
  {
    "illustration": "https://jih-asset.netlify.app/assets/img/onboarding3.png",
    "title": "Learning Made Fun",
    "text": "Stories filled with values, morals and educational adventures",
  },
];
