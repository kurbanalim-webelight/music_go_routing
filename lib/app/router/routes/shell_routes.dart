part of '../app_router.dart';

// Bottom bar. Branch order = tab index, keep in sync with AppShell's destinations.
// Each branch has its own Navigator: its stack survives tab switches, and every route
// nested under a branch shows the mini player and the bottom bar.
@TypedStatefulShellRoute<AppShellRoute>(
  branches: [
    TypedStatefulShellBranch<HomeBranch>(
      routes: [
        TypedGoRoute<HomeRoute>(
          path: '/home',
          routes: [
            TypedGoRoute<HomeAlbumRoute>(path: 'album/:albumId'),
            TypedGoRoute<HomeArtistRoute>(path: 'artist/:artistId'),
            TypedGoRoute<HomeNotificationsRoute>(path: 'notifications'),
          ],
        ),
      ],
    ),
    TypedStatefulShellBranch<LibraryBranch>(
      routes: [
        TypedGoRoute<LibraryRoute>(
          path: '/library',
          routes: [
            TypedGoRoute<LibraryPlaylistRoute>(path: 'playlist/:playlistId'),
            TypedGoRoute<LibraryAlbumRoute>(path: 'album/:albumId'),
            TypedGoRoute<LibraryNotificationsRoute>(path: 'notifications'),
          ],
        ),
      ],
    ),
    TypedStatefulShellBranch<ProfileBranch>(
      routes: [
        TypedGoRoute<ProfileRoute>(
          path: '/profile',
          routes: [
            TypedGoRoute<SettingsRoute>(
              path: 'settings',
              routes: [TypedGoRoute<AccountRoute>(path: 'account')],
            ),
            TypedGoRoute<ProfileNotificationsRoute>(path: 'notifications'),
          ],
        ),
      ],
    ),
  ],
)
class AppShellRoute extends StatefulShellRouteData {
  const AppShellRoute();

  // Tab switch animation. Without this the generator uses StatefulShellRoute.indexedStack (instant swap).
  static Widget $navigatorContainerBuilder(
    BuildContext context,
    StatefulNavigationShell navigationShell,
    List<Widget> children,
  ) => BranchContainer(currentIndex: navigationShell.currentIndex, children: children);

  // The shell fades in after sign-in instead of sliding like a pushed page.
  @override
  Page<void> pageBuilder(BuildContext context, GoRouterState state, StatefulNavigationShell navigationShell) =>
      AppPages.fade(state, AppShell(navigationShell: navigationShell));
}

// ---------------------------------------------------------------- Home

class HomeBranch extends StatefulShellBranchData {
  const HomeBranch();
}

class HomeRoute extends GoRouteData with $HomeRoute {
  const HomeRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) => HomeScreen(
    onOpenAlbum: (id) => HomeAlbumRoute(albumId: id).push<void>(context),
    onOpenArtist: (id) => HomeArtistRoute(artistId: id).push<void>(context),
  );
}

class HomeAlbumRoute extends GoRouteData with $HomeAlbumRoute {
  const HomeAlbumRoute({required this.albumId});

  final String albumId;

  @override
  Widget build(BuildContext context, GoRouterState state) => AlbumScreen(
    albumId: albumId,
    onOpenArtist: (id) => HomeArtistRoute(artistId: id).push<void>(context),
  );
}

class HomeArtistRoute extends GoRouteData with $HomeArtistRoute {
  const HomeArtistRoute({required this.artistId});

  final String artistId;

  @override
  Widget build(BuildContext context, GoRouterState state) => ArtistScreen(
    artistId: artistId,
    onOpenAlbum: (id) => HomeAlbumRoute(albumId: id).push<void>(context),
  );
}

// ---------------------------------------------------------------- Library

class LibraryBranch extends StatefulShellBranchData {
  const LibraryBranch();
}

class LibraryRoute extends GoRouteData with $LibraryRoute {
  const LibraryRoute({this.tab = LibraryTab.own});

  // Query parameter: /library?tab=favourite. go() keeps the same page (query is not part of
  // the page key), so the screen only animates its TabBar; the branch remembers the tab.
  final LibraryTab tab;

  @override
  Widget build(BuildContext context, GoRouterState state) => LibraryScreen(
    tab: tab,
    onTabChanged: (tab) => LibraryRoute(tab: tab).go(context),
    onOpenPlaylist: (id) => LibraryPlaylistRoute(playlistId: id).push<void>(context),
    onOpenAlbum: (id) => LibraryAlbumRoute(albumId: id).push<void>(context),
  );
}

class LibraryPlaylistRoute extends GoRouteData with $LibraryPlaylistRoute {
  const LibraryPlaylistRoute({required this.playlistId});

  final String playlistId;

  @override
  Widget build(BuildContext context, GoRouterState state) => PlaylistScreen(playlistId: playlistId);
}

// Same screen as HomeAlbumRoute, but owned by the Library branch so it stacks on the Library tab.
class LibraryAlbumRoute extends GoRouteData with $LibraryAlbumRoute {
  const LibraryAlbumRoute({required this.albumId});

  final String albumId;

  @override
  Widget build(BuildContext context, GoRouterState state) => AlbumScreen(albumId: albumId);
}

// ---------------------------------------------------------------- Profile

class ProfileBranch extends StatefulShellBranchData {
  const ProfileBranch();
}

class ProfileRoute extends GoRouteData with $ProfileRoute {
  const ProfileRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      ProfileScreen(onOpenSettings: () => const SettingsRoute().push<void>(context));
}

class SettingsRoute extends GoRouteData with $SettingsRoute {
  const SettingsRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      SettingsScreen(onOpenAccount: () => const AccountRoute().push<void>(context));
}

// Nested under the Profile branch (its URL is /profile/settings/account) but shown on the
// root navigator: it covers the bottom bar and the mini player. Back returns to Settings.
class AccountRoute extends GoRouteData with $AccountRoute {
  const AccountRoute();

  static final GlobalKey<NavigatorState> $parentNavigatorKey = rootNavigatorKey;

  @override
  Widget build(BuildContext context, GoRouterState state) => const AccountScreen();
}

// ---------------------------------------------------------------- Notifications (one per tab)

// Nested under every tab (/home|/library|/profile/notifications) so it opens inside the current
// tab's stack: the bottom bar and mini player stay, and back returns to that tab.
abstract class NotificationsRoute extends GoRouteData {
  const NotificationsRoute();

  // Picks the copy that belongs to the tab the bell was tapped in.
  factory NotificationsRoute.of(BuildContext context) => switch (GoRouterState.of(context).matchedLocation) {
    final path when path.startsWith(const LibraryRoute().location) => const LibraryNotificationsRoute(),
    final path when path.startsWith(const ProfileRoute().location) => const ProfileNotificationsRoute(),
    _ => const HomeNotificationsRoute(),
  };

  @override
  Widget build(BuildContext context, GoRouterState state) => const NotificationsScreen();
}

class HomeNotificationsRoute extends NotificationsRoute with $HomeNotificationsRoute {
  const HomeNotificationsRoute();
}

class LibraryNotificationsRoute extends NotificationsRoute with $LibraryNotificationsRoute {
  const LibraryNotificationsRoute();
}

class ProfileNotificationsRoute extends NotificationsRoute with $ProfileNotificationsRoute {
  const ProfileNotificationsRoute();
}
