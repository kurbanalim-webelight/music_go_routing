import 'dart:ui';

import 'package:music_go_routing/features/catalog/domain/entities/album.dart';
import 'package:music_go_routing/features/catalog/domain/entities/artist.dart';
import 'package:music_go_routing/features/catalog/domain/entities/playlist.dart';
import 'package:music_go_routing/features/catalog/domain/entities/track.dart';
import 'package:music_go_routing/features/catalog/domain/repositories/catalog_repository.dart';

// In-memory catalog. Album colours stand in for cover art.
class FakeCatalogRepository implements CatalogRepository {
  FakeCatalogRepository();

  @override
  final List<Artist> artists = const [
    Artist(
      id: 'a1',
      name: 'Marlow Vane',
      bio: 'Slow synths and late trains. Recording out of a converted laundrette in Leeds.',
    ),
    Artist(id: 'a2', name: 'The Quiet Mile', bio: 'Four friends, two guitars, one very patient drummer.'),
    Artist(id: 'a3', name: 'Ines Okafor', bio: 'Jazz piano with a fondness for odd time signatures and warm rooms.'),
    Artist(
      id: 'a4',
      name: 'Halfpenny Choir',
      bio: 'Harmonies recorded in a church that has not seen a service since 1974.',
    ),
  ];

  @override
  final List<Album> albums = const [
    Album(
      id: 'al1',
      title: 'Night Bus',
      artistId: 'a1',
      year: 2023,
      color: Color(0xFF2F4858),
      trackIds: ['t1', 't2', 't3', 't4'],
    ),
    Album(
      id: 'al2',
      title: 'Low Tide Letters',
      artistId: 'a1',
      year: 2021,
      color: Color(0xFF8C5E3C),
      trackIds: ['t5', 't6', 't7'],
    ),
    Album(
      id: 'al3',
      title: 'Porch Light',
      artistId: 'a2',
      year: 2024,
      color: Color(0xFFB8402E),
      trackIds: ['t8', 't9', 't10', 't11'],
    ),
    Album(
      id: 'al4',
      title: 'Seven Over Four',
      artistId: 'a3',
      year: 2022,
      color: Color(0xFF1F6F5F),
      trackIds: ['t12', 't13', 't14'],
    ),
    Album(
      id: 'al5',
      title: 'Hymns for Nobody',
      artistId: 'a4',
      year: 2020,
      color: Color(0xFF5B3A7E),
      trackIds: ['t15', 't16', 't17', 't18'],
    ),
    Album(
      id: 'al6',
      title: 'Kettle Sessions',
      artistId: 'a3',
      year: 2025,
      color: Color(0xFFC79A2C),
      trackIds: ['t19', 't20'],
    ),
  ];

  final List<Track> _tracks = const [
    Track(id: 't1', title: 'Depot', albumId: 'al1', duration: Duration(minutes: 3, seconds: 41)),
    Track(id: 't2', title: 'Last Stop Before Yours', albumId: 'al1', duration: Duration(minutes: 4, seconds: 12)),
    Track(id: 't3', title: 'Fogged Glass', albumId: 'al1', duration: Duration(minutes: 2, seconds: 58)),
    Track(id: 't4', title: 'Terminus', albumId: 'al1', duration: Duration(minutes: 5, seconds: 3)),
    Track(id: 't5', title: 'Salt', albumId: 'al2', duration: Duration(minutes: 3, seconds: 20)),
    Track(id: 't6', title: 'Groyne', albumId: 'al2', duration: Duration(minutes: 3, seconds: 55)),
    Track(id: 't7', title: 'Postmark', albumId: 'al2', duration: Duration(minutes: 4, seconds: 30)),
    Track(id: 't8', title: 'Screen Door', albumId: 'al3', duration: Duration(minutes: 2, seconds: 47)),
    Track(id: 't9', title: 'Mosquito Summer', albumId: 'al3', duration: Duration(minutes: 3, seconds: 33)),
    Track(id: 't10', title: 'Porch Light', albumId: 'al3', duration: Duration(minutes: 4, seconds: 1)),
    Track(id: 't11', title: 'Headlights on the Ceiling', albumId: 'al3', duration: Duration(minutes: 3, seconds: 18)),
    Track(id: 't12', title: 'Seven Over Four', albumId: 'al4', duration: Duration(minutes: 6, seconds: 14)),
    Track(id: 't13', title: 'Room Tone', albumId: 'al4', duration: Duration(minutes: 4, seconds: 48)),
    Track(id: 't14', title: 'Left Hand Only', albumId: 'al4', duration: Duration(minutes: 5, seconds: 25)),
    Track(id: 't15', title: 'Nave', albumId: 'al5', duration: Duration(minutes: 3, seconds: 9)),
    Track(id: 't16', title: 'No One Came', albumId: 'al5', duration: Duration(minutes: 4, seconds: 4)),
    Track(id: 't17', title: 'Collection Plate', albumId: 'al5', duration: Duration(minutes: 2, seconds: 36)),
    Track(
      id: 't18',
      title: 'Last Light Through the Glass',
      albumId: 'al5',
      duration: Duration(minutes: 5, seconds: 50),
    ),
    Track(id: 't19', title: 'Kettle', albumId: 'al6', duration: Duration(minutes: 3, seconds: 2)),
    Track(id: 't20', title: 'Two Sugars', albumId: 'al6', duration: Duration(minutes: 3, seconds: 44)),
  ];

  @override
  final List<Playlist> playlists = const [
    Playlist(id: 'p1', name: 'Late shift', trackIds: ['t1', 't4', 't12', 't18']),
    Playlist(id: 'p2', name: 'Sunday kitchen', trackIds: ['t19', 't20', 't8', 't5']),
    Playlist(id: 'p3', name: 'Long drive', trackIds: ['t10', 't2', 't13', 't16', 't6']),
  ];

  @override
  Album? album(String id) => albums.where((a) => a.id == id).firstOrNull;

  @override
  Artist? artist(String id) => artists.where((a) => a.id == id).firstOrNull;

  @override
  Playlist? playlist(String id) => playlists.where((p) => p.id == id).firstOrNull;

  @override
  Track? track(String id) => _tracks.where((t) => t.id == id).firstOrNull;

  @override
  List<Track> tracksOf(Iterable<String> ids) => ids.map(track).nonNulls.toList();

  @override
  List<Album> albumsBy(String artistId) => albums.where((a) => a.artistId == artistId).toList();

  @override
  List<Album> search(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return const [];
    return albums
        .where((a) => a.title.toLowerCase().contains(q) || artist(a.artistId)!.name.toLowerCase().contains(q))
        .toList();
  }
}
