// Placeholder names match the route paths, e.g. /home/album/:albumId.
enum RouteParameter {
  tab('Library tab', 'unknown-tab', 'No route matches this tab, so nothing happens.'),
  artistId('Artist', 'a99', 'The artist screen opens and shows "Artist not found".'),
  albumId('Album', 'al99', 'The album screen opens and shows "Album not found".'),
  trackId('Track', 't99', 'A "Track not found" toast appears and the player closes.');

  const RouteParameter(this.label, this.unknownValue, this.unknownOutcome);

  final String label;
  final String unknownValue;
  final String unknownOutcome;
}

class TestRoute {
  const TestRoute({required this.label, required this.path, required this.outcome});

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

// Routes are grouped the way testers think about the app: by bottom-bar tab.
class TestRouteGroup {
  const TestRouteGroup({required this.title, required this.routes});

  final String title;
  final List<TestRoute> routes;
}

const List<TestRouteGroup> testRouteGroups = [
  TestRouteGroup(
    title: 'Home',
    routes: [
      TestRoute(label: 'Home', path: '/home', outcome: 'The Home tab is selected.'),
      TestRoute(
        label: 'Album',
        path: '/home/album/:albumId',
        outcome: 'The album opens in the Home tab. Back goes to Home.',
      ),
      TestRoute(
        label: 'Artist',
        path: '/home/artist/:artistId',
        outcome: 'The artist opens in the Home tab. Back goes to Home.',
      ),
      TestRoute(
        label: 'Artist › Album',
        path: '/home/artist/:artistId/album/:albumId',
        outcome: 'The album opens with the artist under it. Back goes to Artist, then Home.',
      ),
      TestRoute(
        label: 'Notifications',
        path: '/home/notifications',
        outcome: 'Notifications open in the Home tab. Back goes to Home.',
      ),
    ],
  ),
  TestRouteGroup(
    title: 'Library',
    routes: [
      TestRoute(label: 'Library tab', path: '/library/:tab', outcome: 'The Library tab is selected, on that tab.'),
      TestRoute(
        label: 'Album',
        path: '/library/:tab/album/:albumId',
        outcome: 'The album opens in the Library tab. Back goes to Library.',
      ),
      TestRoute(
        label: 'Artist',
        path: '/library/:tab/artist/:artistId',
        outcome: 'The artist opens in the Library tab. Back goes to Library.',
      ),
      TestRoute(
        label: 'Artist › Album',
        path: '/library/:tab/artist/:artistId/album/:albumId',
        outcome: 'The album opens with the artist under it, in the Library tab.',
      ),
      TestRoute(
        label: 'Notifications',
        path: '/library/:tab/notifications',
        outcome: 'Notifications open in the Library tab. Back goes to Library.',
      ),
    ],
  ),
  TestRouteGroup(
    title: 'Profile',
    routes: [
      TestRoute(label: 'Profile', path: '/profile', outcome: 'The Profile tab is selected.'),
      TestRoute(label: 'Settings', path: '/profile/settings', outcome: 'Settings opens in the Profile tab.'),
      TestRoute(
        label: 'Settings › Account',
        path: '/profile/settings/account',
        outcome: 'Account covers the bottom bar. Back goes to Settings.',
      ),
      TestRoute(
        label: 'Notifications',
        path: '/profile/notifications',
        outcome: 'Notifications open in the Profile tab. Back goes to Profile.',
      ),
    ],
  ),
  TestRouteGroup(
    title: 'Player',
    routes: [
      TestRoute(
        label: 'Player',
        path: '/player/:trackId',
        outcome: 'The track plays and the player opens on top. Back returns to the previous screen.',
      ),
    ],
  ),
  TestRouteGroup(
    title: 'Error cases',
    routes: [
      TestRoute(
        label: 'Unknown route',
        path: '/does-not-exist',
        outcome: 'Nothing happens. If the app was closed, it opens on Home.',
      ),
    ],
  ),
];
