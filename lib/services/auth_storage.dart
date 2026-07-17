import 'package:shared_preferences/shared_preferences.dart';

class AuthStorage {
  static const _token = 'auth_token';
  static const _userId = 'auth_user_id';
  static const _userName = 'auth_user_name';
  static const _profilePicture = 'auth_profile_picture';

  static Future<void> save({
    required String token,
    required String userId,
    required String userName,
    String? profilePicture,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_token, token);
    await prefs.setString(_userId, userId);
    await prefs.setString(_userName, userName);
    if (profilePicture != null) {
      await prefs.setString(_profilePicture, profilePicture);
    }
  }

  static Future<Map<String, String?>?> load() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_token);
    final userId = prefs.getString(_userId);
    if (token == null || userId == null) return null;
    return {
      'token': token,
      'userId': userId,
      'userName': prefs.getString(_userName) ?? '',
      'profilePicture': prefs.getString(_profilePicture),
    };
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
