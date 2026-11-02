part of '../../app_router.dart';

// Bottom bar. Branch order = tab index, keep in sync with AppShell's destinations.
@TypedStatefulShellRoute<AppShellRoute>(branches: [homeBranch, libraryBranch, profileBranch])
class AppShellRoute extends StatefulShellRouteData {
  const AppShellRoute();

  static Widget $navigatorContainerBuilder(
    BuildContext context,
    StatefulNavigationShell navigationShell,
    List<Widget> children,
  ) => BranchContainer(currentIndex: navigationShell.currentIndex, children: children);

  @override
  Page<void> pageBuilder(BuildContext context, GoRouterState state, StatefulNavigationShell navigationShell) =>
      AppPages.fade(state, AppShell(navigationShell: navigationShell));
}
