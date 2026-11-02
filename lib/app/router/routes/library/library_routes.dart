part of '../../app_router.dart';

const libraryBranch = TypedStatefulShellBranch<LibraryBranch>(
  routes: [
    TypedGoRoute<LibraryRoute>(path: '/library/:tab', routes: [albumRoute, artistRoute, notificationsRoute]),
    TypedGoRoute<LibraryRootRoute>(path: '/library'),
  ],
);

class LibraryBranch extends StatefulShellBranchData {
  const LibraryBranch();

  static const String $initialLocation = '/library/watchlist';
}

class LibraryRoute extends GoRouteData with $LibraryRoute {
  const LibraryRoute({required this.tab});

  final LibraryTab tab;

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) => MaterialPage<void>(
    key: const ValueKey('library'),
    child: LibraryScreen(
      tab: tab,
      onTabChanged: (tab) => LibraryRoute(tab: tab).go(context),
      onOpenAlbum: (albumId) => AlbumRoute(albumId: albumId).goRelative(context),
    ),
  );
}

class LibraryRootRoute extends GoRouteData with $LibraryRootRoute {
  const LibraryRootRoute();

  @override
  String? redirect(BuildContext context, GoRouterState state) {
    return const LibraryRoute(tab: LibraryTab.watchlist).location;
  }
}
