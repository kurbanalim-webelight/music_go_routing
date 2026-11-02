part of '../../app_router.dart';

const notificationTesterRoute = TypedGoRoute<NotificationTesterRoute>(path: 'notification-tester');

class NotificationTesterRoute extends GoRouteData with $NotificationTesterRoute {
  const NotificationTesterRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) => const NotificationTesterScreen();
}
