part of '../../app_router.dart';

const artistRoute = TypedRelativeGoRoute<ArtistRoute>(path: 'artist/:artistId', routes: [albumRoute]);

class ArtistRoute extends RelativeGoRouteData with $ArtistRoute {
  const ArtistRoute({required this.artistId});

  final String artistId;

  @override
  Widget build(BuildContext context, GoRouterState state) => ArtistScreen(
    artistId: artistId,
    onOpenAlbum: (albumId) => AlbumRoute(albumId: albumId).goRelative(context),
  );
}
