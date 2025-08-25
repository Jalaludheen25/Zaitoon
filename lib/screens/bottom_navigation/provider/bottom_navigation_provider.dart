import 'package:flutter/material.dart';
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
    // Always 5 tabs: Episodes(0), Stories(1), Bookmarks(2), BrightBox(3), Quiz/Settings(4)
    // When quiz is enabled: 5th tab is Quiz (but navigates to separate screen)
    // When quiz is disabled: 5th tab is Settings (normal tab behavior)
    
    // Check if trying to access quiz section (index 4 when quiz is enabled)
    if (_showQuiz && index == 4) {
      // Don't change the current index, just navigate to quiz
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
      // For all other tabs (Episodes, Stories, Bookmarks, BrightBox, Settings), update the current index
      _currentIndex = index;
      notifyListeners();
    }
  }
}
