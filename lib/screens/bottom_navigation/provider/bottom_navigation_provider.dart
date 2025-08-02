import 'package:flutter/material.dart';
import 'package:zaitoon/helper/auth_helper.dart';
import 'package:zaitoon/screens/quiz/quiz_screen.dart';
import 'package:zaitoon/screens/quiz_screen/quiz_login_screen.dart';

class NavigationProvider extends ChangeNotifier {
  int _currentIndex = 0;

  int get currentIndex => _currentIndex;

  Future<void> setIndex(int index, BuildContext context) async {
    // Check if trying to access quiz section (index 3)
    if (index == 3) {
      final isLoggedIn = await AuthHelper.isLoggedIn();
      if (isLoggedIn) {
        // User is logged in, navigate to quiz screen
        if (context.mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const QuizScreen()),
          );
        }
      } else {
        // User is not logged in, show login screen
        if (context.mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const QuizLoginScreen()),
          );
        }
      }
    } else {
      _currentIndex = index;
      notifyListeners();
    }
  }
}