import 'package:material_ui/material_ui.dart';
import 'package:music_go_routing/app/di.dart';
import 'package:music_go_routing/features/auth/presentation/screens/auth_form.dart';

class SignupScreen extends StatelessWidget {
  const SignupScreen({required this.onSignedIn, super.key});

  final VoidCallback onSignedIn;

  void _signUp({required String email, String? name}) {
    authController.signIn(email: email, name: name);
    onSignedIn();
  }

  @override
  Widget build(BuildContext context) => AuthForm(
    title: 'Create an account',
    message: 'Save albums to your watchlist and favourites.',
    submitLabel: 'Create account',
    askName: true,
    onSubmit: _signUp,
  );
}
