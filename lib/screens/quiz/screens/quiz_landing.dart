import 'package:flutter/material.dart';
import 'package:zaitoon/constants/image_class.dart';
import 'package:zaitoon/constants/color_class.dart';
import 'package:zaitoon/constants/textstyle_class.dart';
import 'package:zaitoon/screens/student_form/view/student_form.dart';
import 'package:flutter/services.dart';

class QuizLanding extends StatelessWidget {
  const QuizLanding({super.key});

  void _goToStudentForm(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const StudentFormScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: Stack(
          children: [
            // Full screen background image (like onboarding)
            Positioned.fill(
              child: Image.asset(
                ImageClass.quizBg,
                fit: BoxFit.cover,
                filterQuality: FilterQuality.high,
                isAntiAlias: true,
                alignment: Alignment.center,
              ),
            ),

            // Bottom overlay content (title, description, CTA)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: EdgeInsets.fromLTRB(
                  32,
                  0,
                  32,
                  MediaQuery.of(context).padding.bottom + 20,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Gradient title (matches onboarding style)
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
                        'Quiz Time',
                        textAlign: TextAlign.center,
                        style: TextStyleClass.fredoka(
                          fontSize: 24,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Let’s Start the Quiz!',
                      textAlign: TextAlign.center,
                      style: TextStyleClass.openSans(
                        color: ColorClass.black87,
                        fontSize: 16.0,
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Subtitle / description
                    Text(
                      'Have fun answering questions, earn stars, and learn cool new things along the way!',
                      textAlign: TextAlign.center,
                      style: TextStyleClass.openSans(
                        color: ColorClass.black87.withOpacity(0.6),
                        fontSize: 16.0,
                      ),
                    ),

                    const SizedBox(height: 32),

                    // CTA Button
                    _StartQuizButton(onTap: () => _goToStudentForm(context)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StartQuizButton extends StatelessWidget {
  const _StartQuizButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 215,
          height: 45,
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
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(24.0),
              onTap: onTap,
              child: Center(
                child: Text(
                  'Get Started',
                  style: TextStyleClass.fredoka(
                    fontSize: 16.0,
                    color: Colors.white,
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
