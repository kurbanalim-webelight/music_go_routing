import 'package:material_ui/material_ui.dart';
import 'package:music_go_routing/app/di.dart';

// Opened on the root navigator: no bottom bar, no mini player.
class AccountScreen extends StatelessWidget {
  const AccountScreen({required this.onSignedOut, super.key});

  final VoidCallback onSignedOut;

  void _signOut() {
    musicController.stop();
    authController.signOut();
    onSignedOut();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Account')),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          ListTile(
            leading: const Icon(Icons.person_outline_rounded),
            title: const Text('Name'),
            subtitle: Text(authController.name),
          ),
          ListTile(
            leading: const Icon(Icons.mail_outline_rounded),
            title: const Text('Email'),
            subtitle: Text(authController.email),
          ),
          ListTile(
            leading: const Icon(Icons.workspace_premium_outlined),
            title: const Text('Plan'),
            subtitle: const Text('Free'),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 32, 20, 0),
            child: OutlinedButton.icon(
              onPressed: _signOut,
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(0, 52),
                foregroundColor: theme.colorScheme.error,
                side: BorderSide(color: theme.colorScheme.error.withValues(alpha: 0.5)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
              ),
              icon: const Icon(Icons.logout_rounded),
              label: const Text('Sign out'),
            ),
          ),
        ],
      ),
    );
  }
}
