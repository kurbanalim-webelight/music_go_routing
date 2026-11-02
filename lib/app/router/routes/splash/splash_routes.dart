part of '../../app_router.dart';

@TypedGoRoute<SplashRoute>(path: '/splash')
class SplashRoute extends GoRouteData with $SplashRoute {
  const SplashRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) => SplashScreen(
    onSignedIn: (initialLink) =>
        initialLink == null ? const HomeRoute().go(context) : navigationHandler.enterShell(from: initialLink),
    onSignedOut: (initialLink) => LoginRoute(from: initialLink).go(context),
  );
}
