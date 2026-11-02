part of '../../app_router.dart';

const settingsRoute = TypedGoRoute<SettingsRoute>(path: 'settings', routes: [accountRoute, notificationTesterRoute]);

class SettingsRoute extends GoRouteData with $SettingsRoute {
  const SettingsRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) => SettingsScreen(
    onOpenAccount: () => const AccountRoute().push<void>(context),
    onOpenNotificationTester: () => const NotificationTesterRoute().push<void>(context),
  );
}
