import 'package:material_ui/material_ui.dart';
import 'package:music_go_routing/app/di.dart';
import 'package:music_go_routing/features/auth/presentation/screens/auth_form.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({required this.onSignedIn, required this.onOpenSignup, super.key});

  final VoidCallback onSignedIn;
  final VoidCallback onOpenSignup;

  void _signIn({required String email, String? name}) {
    authController.signIn(email: email);
    onSignedIn();
  }

  @override
  Widget build(BuildContext context) => AuthForm(
    title: 'Welcome back',
    message: 'Sign in to pick up where you left off.',
    submitLabel: 'Sign in',
    // Demo credentials so you can tap straight through.
    initialEmail: 'demo@music.app',
    initialPassword: 'password',
    onSubmit: _signIn,
    footer: TextButton(onPressed: onOpenSignup, child: const Text('New here? Create an account')),
  );
}
