import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:zaitoon/screens/quiz_screen/models/quiz_login_model.dart';

class QuizApiService {
  static const String _baseUrl = 'https://zaitoon-quiz-fdaeq.ondigitalocean.app';

  static Future<bool> sendOtp(String mobileNumber) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/user/send-otp'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'mobile': mobileNumber,
        }),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['success'] ?? false;
      } else {
        debugPrint('Send OTP failed: status=${response.statusCode}, body=${response.body}');
      }
      return false;
    } catch (e) {
      debugPrint('Send OTP exception: $e');
      return false;
    }
  }

  static Future<QuizLoginModel?> verifyOtp(String mobileNumber, String otp) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/user/verify-otp'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'mobile': mobileNumber,
          'otp': otp,
        }),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return QuizLoginModel.fromJson(data['user']);
        }
      } else {
        debugPrint('Verify OTP failed: status=${response.statusCode}, body=${response.body}');
      }
      return null;
    } catch (e) {
      debugPrint('Verify OTP exception: $e');
      return null;
    }
  }
}