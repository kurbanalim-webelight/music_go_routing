import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

// Custom route transitions. Ordinary pushes use the theme's platform transitions (see AppTheme).
abstract final class AppPages {
  static bool _reduceMotion(BuildContext context) => MediaQuery.maybeDisableAnimationsOf(context) ?? false;

  // Switching worlds (signed out <-> signed in): a fade, not a push, so it doesn't read as "back".
  static Page<void> fade(GoRouterState state, Widget child) => CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 300),
    transitionsBuilder: (context, animation, _, child) => _reduceMotion(context)
        ? child
        : FadeTransition(
            opacity: CurveTween(curve: Curves.easeOut).animate(animation),
            child: child,
          ),
  );

  // Full-screen sheet-like page (Now Playing): slides up, slides back down.
  static Page<void> slideUp(GoRouterState state, Widget child) => CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 380),
    reverseTransitionDuration: const Duration(milliseconds: 300),
    transitionsBuilder: (context, animation, _, child) {
      if (_reduceMotion(context)) return child;
      return SlideTransition(
        position: CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        ).drive(Tween(begin: const Offset(0, 1), end: Offset.zero)),
        child: child,
      );
    },
  );
}
