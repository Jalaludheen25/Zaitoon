import 'package:flutter/material.dart';
import 'package:zaitoon/helper/auth_helper.dart';
import 'package:zaitoon/screens/quiz/quiz_screen.dart';
import 'package:zaitoon/screens/student_form/view/student_form.dart';
import 'package:zaitoon/screens/student_form/database/db_helper.dart';
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
    // Calculate quiz index based on whether quiz is shown
    // Tabs: Episodes(0), Stories(1), Bookmarks(2), BrightBox(3), Quiz(4 if shown), Settings(4 or 5)
    final quizIndex = _showQuiz ? 4 : -1;
    
    // Check if trying to access quiz section
    if (_showQuiz && index == quizIndex) {
      // Check if student exists in database
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
              MaterialPageRoute(builder: (context) => const StudentFormScreen()),
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
      _currentIndex = index;
      notifyListeners();
    }
  }
}
