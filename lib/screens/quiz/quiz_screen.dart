import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zaitoon/constants/color_class.dart';
import 'package:zaitoon/constants/textstyle_class.dart';
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
        // Show result screen if quiz is completed
        if (quizProvider.currentQuizResult != null) {
          return const QuizResultScreen();
        }
        
        // Show active quiz screen if quiz is in progress
        if (quizProvider.isQuizActive) {
          return const QuizActiveScreen();
        }
        
        // Show home screen by default
        return const QuizHomeScreen();
      },
    );
  }
}
