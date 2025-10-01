import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:zaitoon/screens/quiz_screen/models/quiz_login_model.dart';
import 'package:zaitoon/helper/auth_helper.dart';
import 'package:zaitoon/screens/student_form/view/student_form.dart';

class QuizLoginProvider extends ChangeNotifier {
  bool _isLoading = false;
  bool _isOtpSent = false;
  String? _error;
  String _mobile = '';
  String _otp = '';
  int _resendTimer = 0;
  QuizLoginModel? _currentUser;
  Timer? _timer;

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
      final response = await http.post(
        Uri.parse('https://zaitoon-quiz-fdaeq.ondigitalocean.app/api/user/send-otp'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'mobile': _mobile,
        }),
      );

      debugPrint('Send OTP Response: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          _isOtpSent = true;
          _startResendTimer();
        } else {
          throw Exception(data['message'] ?? 'Failed to send OTP');
        }
      } else {
        throw Exception('Failed to send OTP. Please try again.');
      }
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<void> verifyOtp(BuildContext context) async {
    try {
      _setLoading(true);
      _clearError();
      if (_otp.length != 6) {
        throw Exception('Please enter a valid 6-digit OTP');
      }

      final response = await http.post(
        Uri.parse('https://zaitoon-quiz-fdaeq.ondigitalocean.app/api/user/verify-otp'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'mobile': _mobile,
          'otp': _otp,
        }),
      );

      debugPrint('Verify OTP Response: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          // Store auth token
          final token = data['token'] as String?;
          if (token == null) {
            throw Exception('No token received from server');
          }
          await AuthHelper.saveAuthToken(token);
          debugPrint('Auth token saved: $token');

          // Navigate to student form
          if (context.mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const StudentFormScreen()),
            );
          }
        } else {
          throw Exception(data['message'] ?? 'Invalid OTP');
        }
      } else {
        throw Exception('Failed to verify OTP: ${response.body}');
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
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
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
    _timer?.cancel();
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
} 