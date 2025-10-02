import 'package:flutter/material.dart';
import 'package:zaitoon/services/quiz_config_service.dart';
import 'package:zaitoon/screens/student_form/database/db_helper.dart';
import 'package:zaitoon/screens/quiz/quiz_screen.dart';
import 'package:zaitoon/screens/student_form/view/student_form.dart';

class NavigationProvider extends ChangeNotifier {
  int _currentIndex = 0;
  bool _showQuiz = false;

  int get currentIndex => _currentIndex;
  bool get showQuiz => _showQuiz;

  Future<void> checkQuizVisibility() async {
    _showQuiz = await QuizConfigService.shouldShowQuiz();
    notifyListeners();
  }

  // Method to set index directly without navigation logic (for initialization)
  void setIndexDirectly(int index) {
    _currentIndex = index;
    notifyListeners();
  }

  Future<void> setIndex(int index, BuildContext context) async {
    // Handle quiz tab navigation through QuizLanding
    if (_showQuiz && index == 4) {
      try {
        final dbHelper = DatabaseHelper();
        final students = await dbHelper.getAllStudents();

        if (students.isNotEmpty) {
          // Student exists, navigate to quiz screen
          if (context.mounted) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const QuizScreen()),
            );
          }
        } else {
          // No student exists, navigate to registration form
          if (context.mounted) {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const StudentFormScreen()),
            );
          }
        }
      } catch (e) {
        // If there's an error, navigate to registration form as fallback
        if (context.mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const StudentFormScreen()),
          );
        }
      }
    } else {
      // For all other tabs, just update the current index
      _currentIndex = index;
      notifyListeners();
    }
  }
}
