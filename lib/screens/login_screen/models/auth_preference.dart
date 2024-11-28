import 'package:shared_preferences/shared_preferences.dart';

class UserPreferences {
  static const String _uidKey = 'user_uid';
  static const String _emailKey = 'user_email';

  // Save user data
  static Future<void> saveUserData({
    required String uid,
    String? email,
  }) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    await Future.wait([
      prefs.setString(_uidKey, uid),
      if (email != null) prefs.setString(_emailKey, email),
    ]);
  }

  // Get user data
  static Future<Map<String, String?>> getUserData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    return {
      'uid': prefs.getString(_uidKey),
      'email': prefs.getString(_emailKey),
    };
  }

  // Clear user data on logout
  static Future<void> clearUserData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    await Future.wait([
      prefs.remove(_uidKey),
      prefs.remove(_emailKey),
    ]);
  }
}
