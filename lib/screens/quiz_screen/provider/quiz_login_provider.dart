import 'package:flutter/material.dart';
import 'dart:async';
import 'package:zaitoon/screens/quiz_screen/services/quiz_api_service.dart';
import 'package:zaitoon/screens/quiz_screen/models/quiz_login_model.dart';

class QuizLoginProvider extends ChangeNotifier {
  bool _isLoading = false;
  bool _isOtpSent = false;
  String? _error;
  String _mobile = '';
  String _otp = '';
  int _resendTimer = 0;
  QuizLoginModel? _currentUser;

  bool get isLoading => _isLoading;
  bool get isOtpSent => _isOtpSent;
  String? get error => _error;
  String get mobile => _mobile;
  String get otp => _otp;
  int get resendTimer => _resendTimer;
  QuizLoginModel? get currentUser => _currentUser;

  void setMobile(String number) {
    _mobile = number;
    notifyListeners();
  }

  void setOtp(String otp) {
    _otp = otp;
    notifyListeners();
  }

  Future<void> sendOtp() async {
    try {
      _setLoading(true);
      _clearError();
      if (_mobile.length != 10) {
        throw Exception('Please enter a valid 10-digit mobile number');
      }
      final success = await QuizApiService.sendOtp(_mobile);
      if (!success) {
        throw Exception('Failed to send OTP. Please try again.');
      }
      _isOtpSent = true;
      _startResendTimer();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<void> verifyOtp({VoidCallback? onSuccess}) async {
    try {
      _setLoading(true);
      _clearError();
      if (_otp.length != 6) {
        throw Exception('Please enter a valid 6-digit OTP');
      }
      final user = await QuizApiService.verifyOtp(_mobile, _otp);
      if (user == null) {
        throw Exception('Invalid OTP. Please try again.');
      }
      _currentUser = user;
      if (onSuccess != null) {
        onSuccess();
      }
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  void resendOtp() {
    if (_resendTimer == 0) {
      sendOtp();
    }
  }

  void _startResendTimer() {
    _resendTimer = 300;
    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendTimer > 0) {
        _resendTimer--;
        notifyListeners();
      } else {
        timer.cancel();
      }
    });
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }

  void reset() {
    _isOtpSent = false;
    _mobile = '';
    _otp = '';
    _error = null;
    _resendTimer = 0;
    _currentUser = null;
    notifyListeners();
  }
} 