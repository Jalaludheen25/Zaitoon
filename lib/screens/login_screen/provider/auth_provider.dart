import 'package:flutter/material.dart';

// Auth state provider
class AuthProvider with ChangeNotifier {
  bool _isLoading = false;

  bool get isLoading => _isLoading;

  Future<void> signInWithApple() async {
    _isLoading = true;
    notifyListeners();
    // Implement Apple sign in logic here
    _isLoading = false;
    notifyListeners();
  }

  Future<void> signInWithGoogle() async {
    _isLoading = true;
    notifyListeners();
    // Implement Google sign in logic here
    _isLoading = false;
    notifyListeners();
  }
}
