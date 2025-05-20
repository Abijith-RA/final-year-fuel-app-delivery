import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const _isLoggedInKey = 'is_logged_in';
  static const _userEmailKey = 'user_email';

  // Check if user is logged in
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isLoggedInKey) ?? false;
  }

  // Save login state
  static Future<void> setLoggedIn(bool value, String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isLoggedInKey, value);
    await prefs.setString(_userEmailKey, email);
  }

  // Clear login state (for logout)
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_isLoggedInKey);
    await prefs.remove(_userEmailKey);
  }
}
