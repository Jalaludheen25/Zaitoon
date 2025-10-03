import 'package:flutter/material.dart';
import 'package:zaitoon/services/quiz_config_service.dart';
import 'package:zaitoon/screens/student_form/database/db_helper.dart';

class NavigationProvider extends ChangeNotifier {
  int _currentIndex = 0;
  bool _showQuiz = true; // Default to true to show quiz tab
  bool _quizLandingCompleted = false;

  int get currentIndex => _currentIndex;
  bool get showQuiz => _showQuiz;
  bool get quizLandingCompleted => _quizLandingCompleted;

  Future<void> checkQuizVisibility() async {
    _showQuiz = await QuizConfigService.shouldShowQuiz();
    await _checkQuizLandingCompletion();
    debugPrint(
        'NavigationProvider: showQuiz=$_showQuiz, quizLandingCompleted=$_quizLandingCompleted');
    notifyListeners();
  }

  Future<void> _checkQuizLandingCompletion() async {
    try {
      final dbHelper = DatabaseHelper();
      final students = await dbHelper.getAllStudents();
      // Temporarily force to false to test QuizLanding
      _quizLandingCompleted = students.isNotEmpty;
      debugPrint(
          'NavigationProvider: Found ${students.length} students, quizLandingCompleted = $_quizLandingCompleted');
    } catch (e) {
      debugPrint(
          'NavigationProvider: Error checking quiz landing completion: $e');
      _quizLandingCompleted = false;
    }
  }

  void markQuizLandingCompleted() {
    _quizLandingCompleted = true;
    notifyListeners();
  }

  // Method to set index directly without navigation logic (for initialization)
  void setIndexDirectly(int index) {
    _currentIndex = index;
    notifyListeners();
  }

  Future<void> setIndex(int index, BuildContext context) async {
    // For all tabs, just update the current index
    // Quiz tab content is handled by the IndexedStack in bottom_navigation.dart
    _currentIndex = index;
    notifyListeners();
  }
}
