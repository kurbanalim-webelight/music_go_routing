import 'dart:async';

import 'package:music_go_routing/app/router/navigation_handler.dart';
import 'package:music_go_routing/services/deeplink/deep_link_service.dart';

class AppController {
  AppController(this._deepLinkService, this._navigationHandler);

  final DeepLinkService _deepLinkService;
  final NavigationHandler _navigationHandler;

  Future<void>? _started;
  StreamSubscription<String>? _linkSubscription;
  bool _isStartupComplete = false;
  String? _pendingLocation;

  Future<void> start() => _started ??= _listenToDeepLinks();

  Future<String?> completeStartup() async {
    await start();
    _isStartupComplete = true;

    final location = _pendingLocation;
    _pendingLocation = null;
    return location;
  }

  Future<void> dispose() async {
    await _linkSubscription?.cancel();
    _linkSubscription = null;
  }

  Future<void> _listenToDeepLinks() async {
    _pendingLocation = await _deepLinkService.initialLocation();
    _linkSubscription = _deepLinkService.incomingLocations.listen(_onDeepLink);
  }

  void _onDeepLink(String location) {
    if (!_isStartupComplete) {
      _pendingLocation = location;
      return;
    }

    _navigationHandler.open(location);
  }
}
