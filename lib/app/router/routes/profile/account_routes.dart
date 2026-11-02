part of '../../app_router.dart';

const accountRoute = TypedGoRoute<AccountRoute>(path: 'account');

// Its URL is under Profile, but it opens on the root navigator: it covers the bottom bar and the mini player.
class AccountRoute extends GoRouteData with $AccountRoute {
  const AccountRoute();

  static final GlobalKey<NavigatorState> $parentNavigatorKey = rootNavigatorKey;

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      AccountScreen(onSignedOut: () => const LoginRoute().go(context));
}
