import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zaitoon/screens/quiz/provider/quiz_provider.dart';
import 'package:zaitoon/screens/quiz/screens/quiz_home_screen.dart';
import 'package:zaitoon/screens/quiz/screens/quiz_active_screen.dart';
import 'package:zaitoon/screens/quiz/screens/quiz_result_screen.dart';

class QuizScreen extends StatelessWidget {
  const QuizScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<QuizProvider>(
      builder: (context, quizProvider, child) {
        try {
          debugPrint('QuizScreen: Building...');
          debugPrint(
              'QuizScreen: currentQuizResult = ${quizProvider.currentQuizResult}');
          debugPrint('QuizScreen: isQuizActive = ${quizProvider.isQuizActive}');
          debugPrint('QuizScreen: isLoading = ${quizProvider.isLoading}');

          // Show result screen if quiz is completed
          if (quizProvider.currentQuizResult != null) {
            debugPrint('QuizScreen: Rendering QuizResultScreen');
            return const QuizResultScreen();
          }

          // Show active quiz screen if quiz is in progress
          if (quizProvider.isQuizActive) {
            debugPrint('QuizScreen: Rendering QuizActiveScreen');
            return const QuizActiveScreen();
          }

          // Show home screen by default
          debugPrint('QuizScreen: Rendering QuizHomeScreen');
          return const QuizHomeScreen();
        } catch (e) {
          debugPrint('QuizScreen: Error in build method: $e');
          return Scaffold(
            backgroundColor: Colors.white,
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Quiz Error',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.red[400],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Error: $e',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          );
        }
      },
    );
  }
}
