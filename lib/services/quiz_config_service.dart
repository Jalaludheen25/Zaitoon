import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:zaitoon/constants/app_urls.dart';

class QuizConfigService {
  static Future<bool> shouldShowQuiz() async {
    try {
      final response = await http.get(Uri.parse(ApiUrls.quizConfig));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['data']['show_quiz'] ?? false;
      }
      return false;
    } catch (e) {
      // If API fails, default to not showing quiz
      return false;
    }
  }
}
