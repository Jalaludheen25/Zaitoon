import 'package:flutter/material.dart';
import 'package:zaitoon/constants/color_class.dart';
import 'package:zaitoon/helper/navigation_helper.dart';
import 'package:zaitoon/screens/kids_corner_screen/submission_screen.dart';

class GetStartedScreen extends StatelessWidget {
  const GetStartedScreen({super.key});

  Widget _buildActionButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Container(
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF7C53F4),
              Color(0xFF4A25AA),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Back Button Section
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: _buildActionButton(
                    icon: Icons.arrow_back_ios_new,
                    onPressed: () => navigateBack(context),
                  ),
                ),
              ),

              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Kids Corner',
                        style: TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontFamily: 'Comic Sans MS',
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Upload your own stories, poems and drawings!',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 48),
                      const Text(
                        'Hey Kids! 👋',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Share your amazing stories, express yourself through beautiful poems, and show off your creative drawings! Join our fun community of young artists and storytellers.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 48),
                      SizedBox(
                        width: double.infinity,
                        height: 60,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const SubmissionScreen(),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Color(0xFF7C53F4),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            elevation: 5,
                          ),
                          child: const Text(
                            'Get Started! ✨',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
