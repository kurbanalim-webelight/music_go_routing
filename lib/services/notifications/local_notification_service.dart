import 'dart:async';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

// A notification's payload is an app location, e.g. /home/album/al1.
class LocalNotificationService {
  LocalNotificationService();

  static const NotificationDetails _details = NotificationDetails(
    android: AndroidNotificationDetails(
      'music_updates',
      'Music updates',
      importance: Importance.high,
      priority: Priority.high,
    ),
    iOS: DarwinNotificationDetails(),
  );

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  final StreamController<String> _tappedLocations = StreamController<String>.broadcast();

  Future<void>? _initialized;

  Stream<String> get tappedLocations => _tappedLocations.stream;

  Future<void> initialize() => _initialized ??= _initialize();

  // The location of the notification that launched the app, if one did.
  Future<String?> initialLocation() async {
    await initialize();

    final launchDetails = await _plugin.getNotificationAppLaunchDetails();
    if (launchDetails == null || !launchDetails.didNotificationLaunchApp) {
      return null;
    }

    return _locationFrom(launchDetails.notificationResponse?.payload);
  }

  // Scheduled by the OS, so it still appears if the app is closed or killed meanwhile.
  Future<void> schedule({
    required String title,
    required String body,
    required String location,
    Duration delay = const Duration(seconds: 3),
  }) async {
    await initialize();
    await _requestPermission();

    await _plugin.zonedSchedule(
      id: DateTime.now().millisecondsSinceEpoch.remainder(1 << 31),
      title: title,
      body: body,
      payload: location,
      scheduledDate: tz.TZDateTime.now(tz.UTC).add(delay),
      notificationDetails: _details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );
  }

  Future<void> _initialize() async {
    tz.initializeTimeZones();

    const settings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      ),
    );

    await _plugin.initialize(settings: settings, onDidReceiveNotificationResponse: _onNotificationTapped);
  }

  Future<void> _requestPermission() async {
    final iOS = _plugin.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
    await iOS?.requestPermissions(alert: true, badge: true, sound: true);

    final android = _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    await android?.requestNotificationsPermission();
  }

  void _onNotificationTapped(NotificationResponse response) {
    final location = _locationFrom(response.payload);
    if (location != null) {
      _tappedLocations.add(location);
    }
  }

  String? _locationFrom(String? payload) {
    final location = payload?.trim() ?? '';
    return location.isEmpty ? null : location;
  }
}
