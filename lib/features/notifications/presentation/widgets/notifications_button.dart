import 'package:material_ui/material_ui.dart';
import 'package:music_go_routing/app/di.dart';
import 'package:music_go_routing/app/router/app_router.dart';

// Bell for the app bar of every tab's root screen.
class NotificationsButton extends StatelessWidget {
  const NotificationsButton({super.key});

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: notificationsController,
    builder: (context, _) {
      final unread = notificationsController.unreadCount;
      return IconButton(
        tooltip: 'Notifications',
        onPressed: () => NotificationsRoute.of(context).push<void>(context),
        icon: Badge(
          isLabelVisible: unread > 0,
          label: Text('$unread'),
          child: const Icon(Icons.notifications_none_rounded),
        ),
      );
    },
  );
}
