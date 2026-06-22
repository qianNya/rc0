import 'package:shared_preferences/shared_preferences.dart';

class AuthCredentialsStore {
  AuthCredentialsStore._();

  static const _rememberKey = 'rc0_remember_username';
  static const _usernameKey = 'rc0_saved_username';

  static Future<({bool remember, String? username})> loadSavedUsername() async {
    final prefs = await SharedPreferences.getInstance();
    final remember = prefs.getBool(_rememberKey) ?? false;
    if (!remember) return (remember: false, username: null);
    final username = prefs.getString(_usernameKey);
    if (username == null || username.isEmpty) {
      return (remember: false, username: null);
    }
    return (remember: true, username: username);
  }

  static Future<void> save({
    required String username,
    required bool rememberMe,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_rememberKey, rememberMe);
    if (rememberMe) {
      await prefs.setString(_usernameKey, username);
    } else {
      await prefs.remove(_usernameKey);
    }
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_rememberKey);
    await prefs.remove(_usernameKey);
  }
}
