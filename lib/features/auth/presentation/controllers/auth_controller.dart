import 'package:flutter/foundation.dart';

// In-memory session. The router listens to it (refreshListenable) and redirects on every change.
class AuthController extends ChangeNotifier {
  AuthController();

  String? _email;
  String? _name;

  bool get isSignedIn => _email != null;
  String get email => _email ?? '';
  String get name => _name ?? '';

  void signIn({required String email, String? name}) {
    _email = email.trim();
    _name = (name == null || name.trim().isEmpty) ? _email!.split('@').first : name.trim();
    notifyListeners();
  }

  void signOut() {
    _email = null;
    _name = null;
    notifyListeners();
  }
}
