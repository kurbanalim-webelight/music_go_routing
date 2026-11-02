import 'package:material_ui/material_ui.dart';
import 'package:music_go_routing/app/di.dart';
import 'package:music_go_routing/app/widgets/empty_state.dart';
import 'package:music_go_routing/features/catalog/presentation/widgets/cover_art.dart';
import 'package:music_go_routing/features/catalog/presentation/widgets/track_tile.dart';

class PlaylistScreen extends StatelessWidget {
  const PlaylistScreen({required this.playlistId, super.key});

  final String playlistId;

  @override
  Widget build(BuildContext context) {
    final playlist = catalogRepository.playlist(playlistId);
    if (playlist == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const EmptyState(
          icon: Icons.queue_music_rounded,
          title: 'Playlist not found',
          message: 'This link points to a playlist that no longer exists.',
        ),
      );
    }
    final tracks = catalogRepository.tracksOf(playlist.trackIds);
    final theme = Theme.of(context);
    final color = catalogRepository.album(tracks.first.albumId)!.color;
    return Scaffold(
      appBar: AppBar(),
      body: ListView(
        padding: EdgeInsets.only(bottom: 24 + MediaQuery.paddingOf(context).bottom),
        children: [
          Center(
            child: CoverArt(color: color, label: playlist.name, size: 200, radius: 14),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 4),
            child: Text(playlist.name, style: theme.textTheme.headlineMedium),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'Your playlist, ${tracks.length} songs',
              style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
            child: FilledButton.icon(
              onPressed: () => playerController.play(tracks),
              icon: const Icon(Icons.play_arrow_rounded),
              label: const Text('Play'),
            ),
          ),
          for (final (i, track) in tracks.indexed)
            TrackTile(
              track: track,
              leading: CoverArt(
                color: catalogRepository.album(track.albumId)!.color,
                label: track.title,
                size: 40,
                radius: 4,
              ),
              subtitle: catalogRepository.artist(catalogRepository.album(track.albumId)!.artistId)!.name,
              onTap: () => playerController.play(tracks, startAt: i),
            ),
        ],
      ),
    );
  }
}
