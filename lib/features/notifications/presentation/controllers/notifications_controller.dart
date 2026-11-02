import 'package:flutter/foundation.dart';

// `location` is a plain app path, the same shape a push payload or deep link would carry.
class AppNotification {
  const AppNotification({required this.id, required this.title, required this.body, required this.location});

  final String id;
  final String title;
  final String body;
  final String location;
}

class NotificationsController extends ChangeNotifier {
  NotificationsController();

  final List<AppNotification> items = const [
    AppNotification(
      id: 'n1',
      title: 'New from Ines Okafor',
      body: 'Kettle Sessions is out now.',
      location: '/home/album/al6',
    ),
    AppNotification(
      id: 'n2',
      title: 'Night Bus is on your watchlist',
      body: 'Ready when you are.',
      location: '/library/watchlist/album/al1',
    ),
    AppNotification(
      id: 'n3',
      title: 'Meet Halfpenny Choir',
      body: 'Harmonies from an empty church.',
      location: '/home/artist/a4',
    ),
    AppNotification(
      id: 'n4',
      title: 'Check your account',
      body: 'Confirm the email on your account.',
      location: '/profile/settings/account',
    ),
  ];

  final Set<String> _read = {};

  int get unreadCount => items.where((n) => !_read.contains(n.id)).length;

  bool isRead(String id) => _read.contains(id);

  void markRead(String id) {
    if (_read.add(id)) notifyListeners();
  }
}
