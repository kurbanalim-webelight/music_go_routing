part of '../../app_router.dart';

const homeBranch = TypedStatefulShellBranch<HomeBranch>(
  routes: [
    TypedGoRoute<HomeRoute>(path: '/home', routes: [albumRoute, artistRoute, notificationsRoute]),
  ],
);

class HomeBranch extends StatefulShellBranchData {
  const HomeBranch();
}

class HomeRoute extends GoRouteData with $HomeRoute {
  const HomeRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) => HomeScreen(
    onOpenAlbum: (albumId) => AlbumRoute(albumId: albumId).goRelative(context),
    onOpenArtist: (artistId) => ArtistRoute(artistId: artistId).goRelative(context),
  );
}
