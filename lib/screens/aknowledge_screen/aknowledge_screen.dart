import 'package:d4tales/helper/navigation_helper.dart';
import 'package:d4tales/screens/home_screen/home_screen.dart';
import 'package:flutter/material.dart';

class StoryScreen extends StatelessWidget {
  const StoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color.fromARGB(255, 35, 40, 43), // Sky blue
                  Color.fromARGB(255, 56, 56, 56), // Darker blue for lake
                ],
              ),
            ),
          ),

          // Mountains and Lake

          // Animated Butterflies
          const Positioned(
            top: 100,
            left: 50,
            child: AnimatedButterfly(),
          ),
          const Positioned(
            top: 150,
            right: 50,
            child: AnimatedButterfly(),
          ),

          // Fairy Character
          Positioned(
            top: MediaQuery.of(context).size.height * 0.3,
            left: MediaQuery.of(context).size.width * 0.4,
            child: const AnimatedFairy(
              image: 'assets/images/tiger4.png',
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).size.height * 0.1,
            left: MediaQuery.of(context).size.width * 0.05,
            child: const AnimatedFairy(
              image: 'assets/images/tiger3.png',
            ),
          ),

          // Content Card
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(32),
                  topRight: Radius.circular(32),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Reading to children benefits their emotional development',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  const BulletPoint(
                    text:
                        'Just one story a day makes a huge positive impact for kids.',
                    highlightedWord: 'positive',
                  ),
                  const SizedBox(height: 16),
                  const BulletPoint(
                    text:
                        'Our stories include moral lessons as well as educational topics.',
                    highlightedWord: 'educational',
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      navigateTo(context: context, route: const HomeScreen());
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Continue'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class BulletPoint extends StatelessWidget {
  final String text;
  final String highlightedWord;

  const BulletPoint({
    super.key,
    required this.text,
    required this.highlightedWord,
  });

  @override
  Widget build(BuildContext context) {
    final parts = text.split(highlightedWord);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '• ',
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: const TextStyle(color: Colors.white, fontSize: 16),
              children: [
                TextSpan(text: parts[0]),
                TextSpan(
                  text: highlightedWord,
                  style: const TextStyle(fontWeight: FontWeight.bold),
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

class AnimatedFairy extends StatefulWidget {
  final String image;
  const AnimatedFairy({super.key, required this.image});

  @override
  State<AnimatedFairy> createState() => _AnimatedFairyState();
}

class _AnimatedFairyState extends State<AnimatedFairy>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _floatAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _floatAnimation = Tween<double>(begin: -20.0, end: 10.0).animate(
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
          child: SizedBox(
            width: 200,
            height: 200,
            child: Image.asset(
              widget.image,
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

class AnimatedButterfly extends StatefulWidget {
  const AnimatedButterfly({super.key});

  @override
  State<AnimatedButterfly> createState() => _AnimatedButterflyState();
}

class _AnimatedButterflyState extends State<AnimatedButterfly>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _floatAnimation;

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
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(_floatAnimation.value, _floatAnimation.value),
          child: const Text(
            '🦋',
            style: TextStyle(fontSize: 24),
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
