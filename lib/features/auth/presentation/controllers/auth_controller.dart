class AuthController {
  AuthController();

  String? _email;
  String? _name;

  bool get isSignedIn => _email != null;
  String get email => _email ?? '';
  String get name => _name ?? '';

  void signIn({required String email, String? name}) {
    _email = email.trim();
    _name = _displayName(email: _email!, name: name);
  }

  void signOut() {
    _email = null;
    _name = null;
  }

  String _displayName({required String email, String? name}) {
    final trimmedName = name?.trim() ?? '';
    if (trimmedName.isNotEmpty) {
      return trimmedName;
    }
    return email.split('@').first;
  }
}
