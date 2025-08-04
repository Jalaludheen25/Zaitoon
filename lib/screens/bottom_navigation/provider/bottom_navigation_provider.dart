import 'package:flutter/material.dart';
import 'package:zaitoon/helper/auth_helper.dart';
import 'package:zaitoon/screens/quiz/quiz_screen.dart';
import 'package:zaitoon/screens/student_form/view/student_form.dart';
import 'package:zaitoon/services/quiz_config_service.dart';

class NavigationProvider extends ChangeNotifier {
  int _currentIndex = 0;
  bool _showQuiz = false;

  int get currentIndex => _currentIndex;
  bool get showQuiz => _showQuiz;

  Future<void> checkQuizVisibility() async {
    _showQuiz = await QuizConfigService.shouldShowQuiz();
    notifyListeners();
  }

  Future<void> setIndex(int index, BuildContext context) async {
    // Check if trying to access quiz section (index 3 when quiz is shown)
    if (_showQuiz && index == 3) {
      // Navigate directly to student form
      if (context.mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const StudentFormScreen()),
        );
      }
    } else {
      _currentIndex = index;
      notifyListeners();
    }
  }
}
