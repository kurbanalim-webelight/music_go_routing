part of '../../app_router.dart';

const profileBranch = TypedStatefulShellBranch<ProfileBranch>(
  routes: [
    TypedGoRoute<ProfileRoute>(path: '/profile', routes: [settingsRoute, notificationsRoute]),
  ],
);

class ProfileBranch extends StatefulShellBranchData {
  const ProfileBranch();
}

class ProfileRoute extends GoRouteData with $ProfileRoute {
  const ProfileRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      ProfileScreen(onOpenSettings: () => const SettingsRoute().push<void>(context));
}
