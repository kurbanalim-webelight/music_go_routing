import 'package:music_go_routing/features/catalog/domain/entities/album.dart';
import 'package:music_go_routing/features/catalog/domain/entities/artist.dart';
import 'package:music_go_routing/features/catalog/domain/entities/playlist.dart';
import 'package:music_go_routing/features/catalog/domain/entities/track.dart';

abstract class CatalogRepository {
  List<Album> get albums;
  List<Artist> get artists;
  List<Playlist> get playlists;

  Album? album(String id);
  Artist? artist(String id);
  Playlist? playlist(String id);
  Track? track(String id);

  List<Track> tracksOf(Iterable<String> ids);
  List<Album> albumsBy(String artistId);
  List<Album> search(String query);
}
