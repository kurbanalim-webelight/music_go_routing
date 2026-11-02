import 'package:material_ui/material_ui.dart';
import 'package:music_go_routing/app/di.dart';
import 'package:music_go_routing/app/widgets/empty_state.dart';
import 'package:music_go_routing/features/catalog/presentation/widgets/cover_art.dart';
import 'package:music_go_routing/features/catalog/presentation/widgets/track_tile.dart';

class AlbumScreen extends StatelessWidget {
  const AlbumScreen({required this.albumId, this.onOpenArtist, super.key});

  final String albumId;

  // Null when the owning branch has no artist route (Library): the artist name is then plain text.
  final ValueChanged<String>? onOpenArtist;

  @override
  Widget build(BuildContext context) {
    final album = catalogRepository.album(albumId);
    if (album == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const EmptyState(
          icon: Icons.album_outlined,
          title: 'Album not found',
          message: 'This link points to an album that is not in the catalog.',
        ),
      );
    }
    final artist = catalogRepository.artist(album.artistId)!;
    final tracks = catalogRepository.tracksOf(album.trackIds);
    final theme = Theme.of(context);
    final total = tracks.fold(Duration.zero, (sum, t) => sum + t.duration);

    return Scaffold(
      appBar: AppBar(
        actions: [
          ListenableBuilder(
            listenable: watchlistController,
            builder: (context, _) {
              final saved = watchlistController.contains(album.id);
              return IconButton(
                tooltip: saved ? 'Remove from watchlist' : 'Add to watchlist',
                onPressed: () => watchlistController.toggle(album.id),
                icon: Icon(saved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded),
                color: saved ? theme.colorScheme.primary : null,
              );
            },
          ),
          ListenableBuilder(
            listenable: favouritesController,
            builder: (context, _) {
              final liked = favouritesController.contains(album.id);
              return IconButton(
                tooltip: liked ? 'Remove from favourites' : 'Add to favourites',
                onPressed: () => favouritesController.toggle(album.id),
                icon: Icon(liked ? Icons.favorite_rounded : Icons.favorite_border_rounded),
                color: liked ? theme.colorScheme.primary : null,
              );
            },
          ),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.only(bottom: 24 + MediaQuery.paddingOf(context).bottom),
        children: [
          Center(
            child: CoverArt(color: album.color, label: album.title, size: 220, radius: 14),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 4),
            child: Text(album.title, style: theme.textTheme.headlineMedium),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                onPressed: onOpenArtist == null ? null : () => onOpenArtist!(artist.id),
                style: TextButton.styleFrom(
                  foregroundColor: theme.colorScheme.primary,
                  disabledForegroundColor: theme.colorScheme.onSurface,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
                child: Text(artist.name),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              '${album.year}, ${tracks.length} songs, ${total.inMinutes} min',
              style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
            child: FilledButton.icon(
              onPressed: () => musicController.playTracks(tracks),
              icon: const Icon(Icons.play_arrow_rounded),
              label: const Text('Play'),
            ),
          ),
          for (final (i, track) in tracks.indexed)
            TrackTile(
              track: track,
              leading: Text('${i + 1}', style: TextStyle(color: theme.colorScheme.onSurfaceVariant)),
              onTap: () => musicController.playTracks(tracks, startAt: i),
            ),
        ],
      ),
    );
  }
}
