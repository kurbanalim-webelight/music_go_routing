import 'package:material_ui/material_ui.dart';
import 'package:music_go_routing/app/di.dart';
import 'package:music_go_routing/app/router/app_router.dart';
import 'package:music_go_routing/features/auth/presentation/screens/auth_form.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) => AuthForm(
    title: 'Welcome back',
    message: 'Sign in to pick up where you left off.',
    submitLabel: 'Sign in',
    // Demo credentials so you can tap straight through.
    initialEmail: 'demo@music.app',
    initialPassword: 'password',
    // No navigation here: signing in notifies the router, and its redirect moves on.
    onSubmit: ({required email, name}) => authController.signIn(email: email),
    footer: TextButton(
      onPressed: () => const SignupRoute().push<void>(context),
      child: const Text('New here? Create an account'),
    ),
  );
}
