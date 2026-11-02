part of '../../app_router.dart';

@TypedGoRoute<PlayerRoute>(path: '/player/:trackId')
class PlayerRoute extends GoRouteData with $PlayerRoute {
  const PlayerRoute({required this.trackId});

  static final GlobalKey<NavigatorState> $parentNavigatorKey = rootNavigatorKey;

  final String trackId;

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) =>
      AppPages.slideUp(state, PlayerScreen(trackId: trackId));
}
