import 'package:material_ui/material_ui.dart';
import 'package:go_router/go_router.dart';
import 'package:music_go_routing/app/di.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: ListenableBuilder(
        listenable: notificationsController,
        builder: (context, _) => ListView(
          children: [
            for (final n in notificationsController.items)
              ListTile(
                contentPadding: const EdgeInsets.fromLTRB(20, 8, 16, 8),
                leading: Icon(
                  Icons.circle,
                  size: 10,
                  color: notificationsController.isRead(n.id) ? Colors.transparent : theme.colorScheme.primary,
                ),
                minLeadingWidth: 10,
                title: Text(n.title, style: const TextStyle(fontWeight: FontWeight.w700)),
                subtitle: Text(n.body),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () {
                  notificationsController.markRead(n.id);
                  // A payload carries a plain path. go() rebuilds the whole stack for it:
                  // switches to the right tab and puts the parent screens underneath.
                  context.go(n.location);
                },
              ),
          ],
        ),
      ),
    );
  }
}
