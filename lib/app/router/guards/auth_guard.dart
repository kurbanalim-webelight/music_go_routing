part of '../app_router.dart';

String? authGuard(BuildContext context, GoRouterState state) {
  final isOnSplash = state.matchedLocation == const SplashRoute().location;
  if (isOnSplash) {
    return null;
  }

  final isOnAuthScreen = state.matchedLocation.startsWith(const LoginRoute().location);

  if (!authController.isSignedIn) {
    return _redirectSignedOut(state, isOnAuthScreen: isOnAuthScreen);
  }

  if (isOnAuthScreen) {
    return _redirectAfterSignIn(state);
  }

  return null;
}

String? _redirectSignedOut(GoRouterState state, {required bool isOnAuthScreen}) {
  if (isOnAuthScreen) {
    return null;
  }

  final requestedLocation = state.uri.toString();
  return LoginRoute(from: requestedLocation).location;
}

String _redirectAfterSignIn(GoRouterState state) {
  final requestedLocation = state.uri.queryParameters['from'];
  return requestedLocation ?? const HomeRoute().location;
}
