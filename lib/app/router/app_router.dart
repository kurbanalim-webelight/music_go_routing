import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';
import 'package:go_router/go_router.dart';
import 'package:music_go_routing/app/di.dart';
import 'package:music_go_routing/app/router/app_pages.dart';
import 'package:music_go_routing/app/widgets/not_found_screen.dart';
import 'package:music_go_routing/features/shell/presentation/widgets/branch_container.dart';
import 'package:music_go_routing/features/shell/presentation/screens/app_shell.dart';
import 'package:music_go_routing/features/auth/presentation/screens/login_screen.dart';
import 'package:music_go_routing/features/auth/presentation/screens/signup_screen.dart';
import 'package:music_go_routing/features/catalog/presentation/screens/album_screen.dart';
import 'package:music_go_routing/features/catalog/presentation/screens/artist_screen.dart';
import 'package:music_go_routing/features/home/presentation/screens/home_screen.dart';
import 'package:music_go_routing/features/library/presentation/screens/library_screen.dart';
import 'package:music_go_routing/features/notification_tester/presentation/screens/notification_tester_screen.dart';
import 'package:music_go_routing/features/notifications/presentation/screens/notifications_screen.dart';
import 'package:music_go_routing/features/player/presentation/screens/player_screen.dart';
import 'package:music_go_routing/features/profile/presentation/screens/account_screen.dart';
import 'package:music_go_routing/features/profile/presentation/screens/profile_screen.dart';
import 'package:music_go_routing/features/profile/presentation/screens/settings_screen.dart';
import 'package:music_go_routing/features/splash/presentation/screens/splash_screen.dart';

part 'app_router.g.dart';
part 'guards/auth_guard.dart';
part 'routes/auth/auth_routes.dart';
part 'routes/catalog/album_routes.dart';
part 'routes/catalog/artist_routes.dart';
part 'routes/home/home_routes.dart';
part 'routes/library/library_routes.dart';
part 'routes/notification_tester/notification_tester_routes.dart';
part 'routes/notifications/notifications_routes.dart';
part 'routes/player/player_routes.dart';
part 'routes/profile/account_routes.dart';
part 'routes/profile/profile_routes.dart';
part 'routes/profile/settings_routes.dart';
part 'routes/shell/app_shell_routes.dart';
part 'routes/splash/splash_routes.dart';

// The one key handed to GoRouter(navigatorKey:). Routes that set $parentNavigatorKey to it
// open above the shell, so they cover the bottom bar and the mini player.
final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');

GoRouter createRouter() {
  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: const SplashRoute().location,
    routes: $appRoutes,
    redirect: authGuard,
    errorBuilder: (context, state) => NotFoundScreen(onGoHome: () => const HomeRoute().go(context)),
    debugLogDiagnostics: kDebugMode,
  );
}
