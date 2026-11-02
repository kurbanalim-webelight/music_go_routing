part of '../../app_router.dart';

@TypedGoRoute<LoginRoute>(
  path: '/login',
  routes: [TypedGoRoute<SignupRoute>(path: 'signup')],
)
class LoginRoute extends GoRouteData with $LoginRoute {
  const LoginRoute({this.from});

  // Where to go after signing in: /login?from=/home/album/al1
  final String? from;

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) => AppPages.fade(
    state,
    LoginScreen(
      onSignedIn: () => context.go(from ?? const HomeRoute().location),
      onOpenSignup: () => SignupRoute(from: from).push<void>(context),
    ),
  );
}

class SignupRoute extends GoRouteData with $SignupRoute {
  const SignupRoute({this.from});

  final String? from;

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      SignupScreen(onSignedIn: () => context.go(from ?? const HomeRoute().location));
}
