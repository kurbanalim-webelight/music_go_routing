import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:music_go_routing/app/di.dart';
import 'package:music_go_routing/app/router/app_router.dart';

class NavigationHandler {
  NavigationHandler(this._router);

  final GoRouter _router;

  final Set<String> _independentRoutes = {'/player/:trackId'};

  void open(String location) {
    final match = _findOpenableMatch(location);
    if (match == null) {
      return;
    }

    if (!authController.isSignedIn) {
      _router.go(LoginRoute(from: location).location);
      return;
    }

    if (_independentRoutes.contains(match.fullPath)) {
      _router.push<void>(location);
    } else {
      _router.go(location);
    }
  }

  Future<void> enterShell({String? from}) async {
    final homeLocation = const HomeRoute().location;
    final match = from == null ? null : _findOpenableMatch(from);

    if (match == null) {
      _router.go(homeLocation);
      return;
    }

    final location = match.uri.toString();

    if (_independentRoutes.contains(match.fullPath)) {
      _router.go(homeLocation);
      await WidgetsBinding.instance.endOfFrame;
      _router.push<void>(location);
      return;
    }

    _router.go(location);
  }

  RouteMatchList? _findOpenableMatch(String location) {
    final uri = Uri.tryParse(location);
    if (uri == null) {
      return null;
    }

    final match = _router.configuration.findMatch(uri);
    final isAuthRoute = uri.path.startsWith(const LoginRoute().location);
    if (match.isError || isAuthRoute) {
      return null;
    }

    return match;
  }
}
