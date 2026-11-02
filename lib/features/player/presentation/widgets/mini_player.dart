import 'package:material_ui/material_ui.dart';
import 'package:music_go_routing/app/di.dart';
import 'package:music_go_routing/app/router/app_router.dart';
import 'package:music_go_routing/app/theme.dart';
import 'package:music_go_routing/app/widgets/glass_pill.dart';
import 'package:music_go_routing/features/catalog/presentation/widgets/cover_art.dart';

// Floating pill above the bottom bar. It lives in the shell, so it stays put across tabs and
// in-tab pages. Shown whenever something is queued; it is not tied to any route.
class MiniPlayer extends StatelessWidget {
  const MiniPlayer({super.key});

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: musicController,
    // Grows in when playback starts and collapses on close.
    builder: (context, _) => AnimatedSize(
      duration: (MediaQuery.maybeDisableAnimationsOf(context) ?? false)
          ? Duration.zero
          : const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
      alignment: Alignment.bottomCenter,
      child: _content(context),
    ),
  );

  Widget _content(BuildContext context) {
    final track = musicController.currentTrack;
    final album = musicController.currentAlbum;
    final artist = musicController.currentArtist;
    if (track == null || album == null || artist == null) {
      return const SizedBox(width: double.infinity);
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GlassPill(
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: () => PlayerRoute(trackId: track.id).push<void>(context),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 6, 8),
              child: Row(
                children: [
                  Hero(
                    tag: nowPlayingArtTag,
                    flightShuttleBuilder: (_, _, _, _, _) => coverArtFlight(album.color, album.title),
                    child: CoverArt(color: album.color, label: album.title, size: 52, radius: 26),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          track.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${album.title}, ${artist.name}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: AppColors.paper.withValues(alpha: 0.65), fontSize: 13),
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(2),
                          child: LinearProgressIndicator(
                            value: musicController.progress,
                            minHeight: 3,
                            backgroundColor: Colors.white12,
                            color: AppColors.marigold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 4),
                  IconButton(
                    tooltip: musicController.isPlaying ? 'Pause' : 'Play',
                    onPressed: musicController.toggle,
                    icon: Icon(musicController.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded, size: 34),
                  ),
                  IconButton(
                    tooltip: 'Close player',
                    onPressed: musicController.stop,
                    icon: const Icon(Icons.close_rounded, size: 26),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
