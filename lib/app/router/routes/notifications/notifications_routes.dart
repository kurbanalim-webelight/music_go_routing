part of '../../app_router.dart';

const notificationsRoute = TypedRelativeGoRoute<NotificationsRoute>(path: 'notifications');

class NotificationsRoute extends RelativeGoRouteData with $NotificationsRoute {
  const NotificationsRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) => const NotificationsScreen();
}
