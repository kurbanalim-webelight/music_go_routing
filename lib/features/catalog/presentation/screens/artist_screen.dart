import 'package:material_ui/material_ui.dart';
import 'package:music_go_routing/app/di.dart';
import 'package:music_go_routing/app/widgets/empty_state.dart';
import 'package:music_go_routing/features/catalog/presentation/widgets/album_list_tile.dart';

class ArtistScreen extends StatelessWidget {
  const ArtistScreen({required this.artistId, required this.onOpenAlbum, super.key});

  final String artistId;
  final ValueChanged<String> onOpenAlbum;

  @override
  Widget build(BuildContext context) {
    final artist = catalogRepository.artist(artistId);
    if (artist == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const EmptyState(
          icon: Icons.person_off_outlined,
          title: 'Artist not found',
          message: 'This link points to an artist that is not in the catalog.',
        ),
      );
    }
    final albums = catalogRepository.albumsBy(artist.id);
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(),
      body: ListView(
        padding: EdgeInsets.only(bottom: 24 + MediaQuery.paddingOf(context).bottom),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
            child: CircleAvatar(
              radius: 56,
              backgroundColor: albums.isEmpty ? theme.colorScheme.surfaceContainerHigh : albums.first.color,
              child: Text(
                artist.name.characters.first,
                style: const TextStyle(fontSize: 44, fontWeight: FontWeight.w900, color: Colors.white),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
            child: Text(artist.name, style: theme.textTheme.headlineMedium, textAlign: TextAlign.center),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              artist.bio,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurfaceVariant, height: 1.45),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 28, 20, 4),
            child: Text('Albums', style: theme.textTheme.titleLarge),
          ),
          for (final album in albums) AlbumListTile(album: album, onTap: () => onOpenAlbum(album.id)),
        ],
      ),
    );
  }
}
