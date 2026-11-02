import 'dart:async';

import 'package:music_go_routing/app/router/navigation_handler.dart';
import 'package:music_go_routing/services/deeplink/deep_link_service.dart';
import 'package:music_go_routing/services/notifications/local_notification_service.dart';

// Deep links and notification taps both arrive here as app locations. Until the splash is done
// they are held; after that they open straight away through NavigationHandler.
class AppController {
  AppController(this._deepLinkService, this._notificationService, this._navigationHandler);

  final DeepLinkService _deepLinkService;
  final LocalNotificationService _notificationService;
  final NavigationHandler _navigationHandler;

  Future<void>? _started;
  final List<StreamSubscription<String>> _subscriptions = [];
  bool _isStartupComplete = false;
  String? _pendingLocation;

  Future<void> start() => _started ??= _listenToIncomingLocations();

  Future<String?> completeStartup() async {
    await start();
    _isStartupComplete = true;

    final location = _pendingLocation;
    _pendingLocation = null;
    return location;
  }

  Future<void> dispose() async {
    for (final subscription in _subscriptions) {
      await subscription.cancel();
    }
    _subscriptions.clear();
  }

  Future<void> _listenToIncomingLocations() async {
    final notificationLocation = await _notificationService.initialLocation();
    final deepLinkLocation = await _deepLinkService.initialLocation();
    _pendingLocation = notificationLocation ?? deepLinkLocation;

    _subscriptions.add(_deepLinkService.incomingLocations.listen(_onIncomingLocation));
    _subscriptions.add(_notificationService.tappedLocations.listen(_onIncomingLocation));
  }

  void _onIncomingLocation(String location) {
    if (!_isStartupComplete) {
      _pendingLocation = location;
      return;
    }

    _navigationHandler.open(location);
  }
}
