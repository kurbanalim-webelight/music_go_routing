import 'package:material_ui/material_ui.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({required this.onOpenAccount, super.key});

  final VoidCallback onOpenAccount;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // ponytail: local UI state only; persist with shared_preferences when settings must survive restarts.
  bool _highQuality = true;
  bool _explicit = false;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Settings')),
    body: ListView(
      children: [
        ListTile(
          leading: const Icon(Icons.manage_accounts_outlined),
          title: const Text('Account'),
          subtitle: const Text('Email, sign out'),
          trailing: const Icon(Icons.chevron_right_rounded),
          onTap: widget.onOpenAccount,
        ),
        const Divider(indent: 20, endIndent: 20, height: 24),
        SwitchListTile(
          secondary: const Icon(Icons.high_quality_outlined),
          title: const Text('Stream in high quality'),
          value: _highQuality,
          onChanged: (v) => setState(() => _highQuality = v),
        ),
        SwitchListTile(
          secondary: const Icon(Icons.explicit_outlined),
          title: const Text('Allow explicit songs'),
          value: _explicit,
          onChanged: (v) => setState(() => _explicit = v),
        ),
        const AboutListTile(
          icon: Icon(Icons.info_outline_rounded),
          applicationName: 'Music',
          applicationVersion: '1.0.0',
        ),
      ],
    ),
  );
}
