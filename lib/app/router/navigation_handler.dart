import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:music_go_routing/app/di.dart';
import 'package:music_go_routing/app/router/app_router.dart';

class NavigationHandler {
  NavigationHandler(this._router);

  final GoRouter _router;

  final Set<String> _independentRoutes = {const PlayerRoute().location};

  void open(String location) {
    final uri = Uri.tryParse(location);
    if (uri == null || !_canOpen(uri)) {
      return;
    }

    if (!authController.isSignedIn) {
      _router.go(LoginRoute(from: location).location);
      return;
    }

    if (_independentRoutes.contains(uri.path)) {
      _router.push<void>(location);
    } else {
      _router.go(location);
    }
  }

  Future<void> enterShell({String? from}) async {
    final homeLocation = const HomeRoute().location;
    final uri = from == null ? null : Uri.tryParse(from);

    if (uri == null) {
      _router.go(homeLocation);
      return;
    }

    if (!_canOpen(uri)) {
      _router.go(homeLocation);
      return;
    }

    final location = uri.toString();

    if (_independentRoutes.contains(uri.path)) {
      _router.go(homeLocation);
      await WidgetsBinding.instance.endOfFrame;
      _router.push<void>(location);
      return;
    }

    _router.go(location);
  }

  bool _canOpen(Uri uri) {
    final isKnownRoute = !_router.configuration.findMatch(uri).isError;
    final isAuthRoute = uri.path.startsWith(const LoginRoute().location);
    return isKnownRoute && !isAuthRoute;
  }
}
