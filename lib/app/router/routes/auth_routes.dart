part of '../app_router.dart';

@TypedGoRoute<LoginRoute>(
  path: '/login',
  routes: [TypedGoRoute<SignupRoute>(path: 'signup')],
)
class LoginRoute extends GoRouteData with $LoginRoute {
  const LoginRoute({this.from});

  // Query parameter: /login?from=/home/album/al1
  final String? from;

  // Fades in on sign-out (it replaces the whole app, it is not "back").
  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) => AppPages.fade(state, const LoginScreen());
}

class SignupRoute extends GoRouteData with $SignupRoute {
  const SignupRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) => const SignupScreen();
}
