import 'package:material_ui/material_ui.dart';
import 'package:music_go_routing/app/di.dart';
import 'package:music_go_routing/features/auth/presentation/screens/auth_form.dart';

class SignupScreen extends StatelessWidget {
  const SignupScreen({super.key});

  @override
  Widget build(BuildContext context) => AuthForm(
    title: 'Create an account',
    message: 'Save albums and build playlists.',
    submitLabel: 'Create account',
    askName: true,
    onSubmit: ({required email, name}) => authController.signIn(email: email, name: name),
  );
}
