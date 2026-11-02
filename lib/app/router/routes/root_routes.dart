part of '../app_router.dart';

// Top-level siblings of the shell. They live on the root navigator, so they cover the
// bottom bar and the mini player. Open them with push() so back returns to the tab.

@TypedGoRoute<PlayerRoute>(path: '/player')
class PlayerRoute extends GoRouteData with $PlayerRoute {
  const PlayerRoute();

  static final GlobalKey<NavigatorState> $parentNavigatorKey = rootNavigatorKey;

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) => AppPages.slideUp(state, const PlayerScreen());
}
