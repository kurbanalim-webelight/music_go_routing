import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';
import 'package:go_router/go_router.dart';
import 'package:music_go_routing/app/di.dart';
import 'package:music_go_routing/app/router/app_pages.dart';
import 'package:music_go_routing/app/shell/branch_container.dart';
import 'package:music_go_routing/app/shell/app_shell.dart';
import 'package:music_go_routing/features/auth/presentation/screens/login_screen.dart';
import 'package:music_go_routing/features/auth/presentation/screens/signup_screen.dart';
import 'package:music_go_routing/features/catalog/presentation/screens/album_screen.dart';
import 'package:music_go_routing/features/catalog/presentation/screens/artist_screen.dart';
import 'package:music_go_routing/features/home/presentation/screens/home_screen.dart';
import 'package:music_go_routing/features/library/presentation/screens/library_screen.dart';
import 'package:music_go_routing/features/library/presentation/screens/playlist_screen.dart';
import 'package:music_go_routing/features/notifications/presentation/screens/notifications_screen.dart';
import 'package:music_go_routing/features/player/presentation/screens/player_screen.dart';
import 'package:music_go_routing/features/profile/presentation/screens/account_screen.dart';
import 'package:music_go_routing/features/profile/presentation/screens/profile_screen.dart';
import 'package:music_go_routing/features/profile/presentation/screens/settings_screen.dart';

part 'app_router.g.dart';
part 'routes/auth_routes.dart';
part 'routes/root_routes.dart';
part 'routes/shell_routes.dart';

// The one key handed to GoRouter(navigatorKey:). Routes that set $parentNavigatorKey to it
// open above the shell, so they cover the bottom bar and the mini player.
final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');

GoRouter createRouter({String? initialLocation}) => GoRouter(
  navigatorKey: rootNavigatorKey,
  initialLocation: initialLocation ?? const HomeRoute().location,
  routes: $appRoutes,
  refreshListenable: authController,
  redirect: authRedirect,
  debugLogDiagnostics: kDebugMode,
);

// Signed out: every route except /login/** goes to login, remembering where the user was headed.
// Signed in: login screens bounce to that remembered location, or home.
String? authRedirect(BuildContext context, GoRouterState state) {
  final onAuthScreen = state.matchedLocation.startsWith(const LoginRoute().location);
  if (!authController.isSignedIn) {
    return onAuthScreen ? null : LoginRoute(from: state.uri.toString()).location;
  }
  if (onAuthScreen) return state.uri.queryParameters['from'] ?? const HomeRoute().location;
  return null;
}
