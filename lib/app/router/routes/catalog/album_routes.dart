part of '../../app_router.dart';

const albumRoute = TypedRelativeGoRoute<AlbumRoute>(path: 'album/:albumId');

class AlbumRoute extends RelativeGoRouteData with $AlbumRoute {
  const AlbumRoute({required this.albumId});

  final String albumId;

  @override
  Widget build(BuildContext context, GoRouterState state) => AlbumScreen(albumId: albumId);
}
