import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class SavedAccount {
  final String token;
  final String userId;
  final String userName;
  final String role;
  final String? profilePicture;

  const SavedAccount({
    required this.token,
    required this.userId,
    required this.userName,
    this.role = 'otro',
    this.profilePicture,
  });

  Map<String, dynamic> toJson() => {
        'token': token,
        'userId': userId,
        'userName': userName,
        'role': role,
        if (profilePicture != null) 'profilePicture': profilePicture,
      };

  factory SavedAccount.fromJson(Map<String, dynamic> j) => SavedAccount(
        token: j['token'] as String,
        userId: j['userId'] as String,
        userName: j['userName'] as String,
        role: j['role'] as String? ?? 'otro',
        profilePicture: j['profilePicture'] as String?,
      );

  bool get isGuardian => role == 'padre' || role == 'madre';
}

class AuthStorage {
  static const _accountsKey = 'saved_accounts';
  static const _activeKey = 'active_user_id';

  static Future<List<SavedAccount>> loadAll() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_accountsKey);
    if (raw == null) return [];
    final list = jsonDecode(raw) as List<dynamic>;
    return list
        .map((e) => SavedAccount.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  static Future<SavedAccount?> loadActive() async {
    final prefs = await SharedPreferences.getInstance();
    final activeId = prefs.getString(_activeKey);
    if (activeId == null) return null;
    final accounts = await loadAll();
    try {
      return accounts.firstWhere((a) => a.userId == activeId);
    } catch (_) {
      return accounts.isEmpty ? null : accounts.first;
    }
  }

  static Future<void> saveAccount(SavedAccount account) async {
    final prefs = await SharedPreferences.getInstance();
    final accounts = await loadAll();
    final idx = accounts.indexWhere((a) => a.userId == account.userId);
    if (idx >= 0) {
      accounts[idx] = account;
    } else {
      accounts.add(account);
    }
    await prefs.setString(_accountsKey, jsonEncode(accounts.map((a) => a.toJson()).toList()));
    await prefs.setString(_activeKey, account.userId);
  }

  static Future<void> setActive(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_activeKey, userId);
  }

  static Future<void> removeAccount(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final accounts = await loadAll();
    accounts.removeWhere((a) => a.userId == userId);
    await prefs.setString(_accountsKey, jsonEncode(accounts.map((a) => a.toJson()).toList()));
    final activeId = prefs.getString(_activeKey);
    if (activeId == userId) {
      await prefs.setString(_activeKey, accounts.isEmpty ? '' : accounts.first.userId);
    }
  }

  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_accountsKey);
    await prefs.remove(_activeKey);
  }
}
