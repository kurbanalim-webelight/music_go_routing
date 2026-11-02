import 'package:material_ui/material_ui.dart';
import 'package:music_go_routing/app/di.dart';
import 'package:music_go_routing/features/notifications/presentation/widgets/notifications_button.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({required this.onOpenSettings, super.key});

  final VoidCallback onOpenSettings;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Profile'), actions: const [NotificationsButton(), SizedBox(width: 4)]),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 34,
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                  child: Text(
                    authController.name.isEmpty ? '?' : authController.name.characters.first.toUpperCase(),
                    style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(authController.name, style: theme.textTheme.titleLarge),
                      Text(authController.email, style: TextStyle(color: theme.colorScheme.onSurfaceVariant)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          ListenableBuilder(
            listenable: favouritesController,
            builder: (context, _) => ListTile(
              leading: const Icon(Icons.favorite_border_rounded),
              title: const Text('Favourite albums'),
              trailing: Text('${favouritesController.albumIds.length}', style: theme.textTheme.titleMedium),
            ),
          ),
          ListenableBuilder(
            listenable: watchlistController,
            builder: (context, _) => ListTile(
              leading: const Icon(Icons.bookmark_border_rounded),
              title: const Text('Watchlist'),
              trailing: Text('${watchlistController.albumIds.length}', style: theme.textTheme.titleMedium),
            ),
          ),
          const Divider(indent: 20, endIndent: 20, height: 24),
          ListTile(
            leading: const Icon(Icons.settings_outlined),
            title: const Text('Settings'),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: onOpenSettings,
          ),
        ],
      ),
    );
  }
}
