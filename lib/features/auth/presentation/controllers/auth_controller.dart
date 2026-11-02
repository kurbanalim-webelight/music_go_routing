import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';

class AuthController {
  AuthController();

  static const String _emailKey = 'auth.email';
  static const String _nameKey = 'auth.name';

  final SharedPreferencesAsync _storage = SharedPreferencesAsync();

  String? _email;
  String? _name;

  bool get isSignedIn => _email != null;
  String get email => _email ?? '';
  String get name => _name ?? '';

  Future<void> restoreSession() async {
    _email = await _storage.getString(_emailKey);
    _name = await _storage.getString(_nameKey);
  }

  void signIn({required String email, String? name}) {
    _email = email.trim();
    _name = _displayName(email: _email!, name: name);
    unawaited(_saveSession());
  }

  void signOut() {
    _email = null;
    _name = null;
    unawaited(_clearSession());
  }

  Future<void> _saveSession() async {
    await _storage.setString(_emailKey, email);
    await _storage.setString(_nameKey, name);
  }

  Future<void> _clearSession() async {
    await _storage.remove(_emailKey);
    await _storage.remove(_nameKey);
  }

  String _displayName({required String email, String? name}) {
    final trimmedName = name?.trim() ?? '';
    if (trimmedName.isNotEmpty) {
      return trimmedName;
    }
    return email.split('@').first;
  }
}
