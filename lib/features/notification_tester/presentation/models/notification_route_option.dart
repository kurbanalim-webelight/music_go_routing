// Placeholder names match the route paths, e.g. /home/album/:albumId.
enum RouteParameter {
  tab('Library tab', 'unknown-tab', 'No route matches this tab, so the tap is ignored.'),
  artistId('Artist', 'a99', 'Opens the screen with "Artist not found".'),
  albumId('Album', 'al99', 'Opens the screen with "Album not found".'),
  trackId('Track', 't99', 'Shows a "Track not found" toast and closes the player.');

  const RouteParameter(this.label, this.unknownValue, this.unknownOutcome);

  final String label;
  final String unknownValue;
  final String unknownOutcome;
}

class NotificationRouteOption {
  const NotificationRouteOption({required this.label, required this.path, required this.outcome});

  final String label;
  final String path;
  final String outcome;

  List<RouteParameter> get parameters {
    final names = RegExp(r':(\w+)').allMatches(path).map((match) => match.group(1)!).toSet();
    return RouteParameter.values.where((parameter) => names.contains(parameter.name)).toList();
  }

  String locationWith(Map<RouteParameter, String> values) {
    return path.replaceAllMapped(RegExp(r':(\w+)'), (match) {
      final parameter = RouteParameter.values.byName(match.group(1)!);
      return values[parameter] ?? parameter.unknownValue;
    });
  }
}

const List<NotificationRouteOption> notificationRouteOptions = [
  NotificationRouteOption(label: 'Home', path: '/home', outcome: 'Switches to the Home tab.'),
  NotificationRouteOption(
    label: 'Home · Album',
    path: '/home/album/:albumId',
    outcome: 'Opens the album inside Home. Back goes to Home.',
  ),
  NotificationRouteOption(
    label: 'Home · Artist',
    path: '/home/artist/:artistId',
    outcome: 'Opens the artist inside Home. Back goes to Home.',
  ),
  NotificationRouteOption(
    label: 'Home · Artist › Album',
    path: '/home/artist/:artistId/album/:albumId',
    outcome: 'Opens the album with the artist underneath. Back goes Artist, then Home.',
  ),
  NotificationRouteOption(
    label: 'Home · Notifications',
    path: '/home/notifications',
    outcome: 'Opens notifications inside Home.',
  ),
  NotificationRouteOption(label: 'Library · Tab', path: '/library/:tab', outcome: 'Switches to Library on that tab.'),
  NotificationRouteOption(
    label: 'Library · Album',
    path: '/library/:tab/album/:albumId',
    outcome: 'Opens the album inside Library, on that tab.',
  ),
  NotificationRouteOption(
    label: 'Library · Artist',
    path: '/library/:tab/artist/:artistId',
    outcome: 'Opens the artist inside Library, on that tab.',
  ),
  NotificationRouteOption(
    label: 'Library · Artist › Album',
    path: '/library/:tab/artist/:artistId/album/:albumId',
    outcome: 'Opens the album with the artist underneath, inside Library.',
  ),
  NotificationRouteOption(
    label: 'Library · Notifications',
    path: '/library/:tab/notifications',
    outcome: 'Opens notifications inside Library, on that tab.',
  ),
  NotificationRouteOption(label: 'Profile', path: '/profile', outcome: 'Switches to the Profile tab.'),
  NotificationRouteOption(
    label: 'Profile · Settings',
    path: '/profile/settings',
    outcome: 'Opens Settings inside Profile.',
  ),
  NotificationRouteOption(
    label: 'Profile · Settings › Account',
    path: '/profile/settings/account',
    outcome: 'Opens Account over the bottom bar, with Settings underneath.',
  ),
  NotificationRouteOption(
    label: 'Profile · Notifications',
    path: '/profile/notifications',
    outcome: 'Opens notifications inside Profile.',
  ),
  NotificationRouteOption(
    label: 'Player',
    path: '/player/:trackId',
    outcome: 'Plays the track and opens the player on top of the current screen.',
  ),
  NotificationRouteOption(
    label: 'Unknown route',
    path: '/does-not-exist',
    outcome: 'No route matches, so the tap is ignored. On a cold start the app opens Home.',
  ),
];
