import 'package:material_ui/material_ui.dart';
import 'package:go_router/go_router.dart';
import 'package:music_go_routing/app/di.dart';
import 'package:music_go_routing/app/router/app_router.dart';
import 'package:music_go_routing/app/theme.dart';
import 'package:music_go_routing/app/widgets/empty_state.dart';
import 'package:music_go_routing/features/catalog/domain/entities/track.dart';
import 'package:music_go_routing/features/catalog/presentation/widgets/cover_art.dart';

class PlayerScreen extends StatelessWidget {
  const PlayerScreen({super.key});

  // /player can be opened by URL with nothing underneath: fall back to Home.
  void _close(BuildContext context) => context.canPop() ? context.pop() : const HomeRoute().go(context);

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: playerController,
    builder: (context, _) {
      final track = playerController.current;
      if (track == null) {
        return Scaffold(
          appBar: AppBar(
            leading: IconButton(onPressed: () => _close(context), icon: const Icon(Icons.keyboard_arrow_down_rounded)),
          ),
          body: const EmptyState(
            icon: Icons.music_off_rounded,
            title: 'Nothing playing',
            message: 'Pick an album or playlist and press Play.',
          ),
        );
      }
      final album = catalogRepository.album(track.albumId)!;
      final artist = catalogRepository.artist(album.artistId)!;
      final theme = Theme.of(context);
      return GestureDetector(
        // Swipe down to close, like the slide-up it opened with.
        onVerticalDragEnd: (d) {
          if ((d.primaryVelocity ?? 0) > 400) _close(context);
        },
        child: Scaffold(
          body: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color.lerp(album.color, AppColors.ink, 0.25)!, AppColors.ink],
                stops: const [0, 0.75],
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    Row(
                      children: [
                        IconButton(
                          tooltip: 'Close player',
                          onPressed: () => _close(context),
                          icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 32),
                        ),
                        Expanded(
                          child: Text(
                            album.title,
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ),
                        const SizedBox(width: 48),
                      ],
                    ),
                    // Fits the space left on any screen height; caps at 360 on tablets.
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 24),
                        child: LayoutBuilder(
                          builder: (context, c) => Center(
                            child: Hero(
                              tag: nowPlayingArtTag,
                              flightShuttleBuilder: (_, _, _, _, _) => coverArtFlight(album.color, album.title),
                              child: CoverArt(
                                color: album.color,
                                label: album.title,
                                size: [c.maxWidth, c.maxHeight, 360.0].reduce((a, b) => a < b ? a : b),
                                radius: 18,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                track.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.headlineSmall,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                artist.name,
                                style: TextStyle(fontSize: 16, color: AppColors.paper.withValues(alpha: 0.7)),
                              ),
                            ],
                          ),
                        ),
                        ListenableBuilder(
                          listenable: favouritesController,
                          builder: (context, _) {
                            final liked = favouritesController.contains(album.id);
                            return IconButton(
                              tooltip: liked ? 'Remove album from favourites' : 'Add album to favourites',
                              onPressed: () => favouritesController.toggle(album.id),
                              icon: Icon(liked ? Icons.favorite_rounded : Icons.favorite_border_rounded),
                              color: liked ? AppColors.marigold : null,
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        trackHeight: 3,
                        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                        overlayShape: SliderComponentShape.noOverlay,
                        activeTrackColor: AppColors.paper,
                        inactiveTrackColor: Colors.white24,
                        thumbColor: AppColors.paper,
                      ),
                      child: Slider(value: playerController.progress, onChanged: playerController.seek),
                    ),
                    const SizedBox(height: 8),
                    DefaultTextStyle.merge(
                      style: TextStyle(fontSize: 12, color: AppColors.paper.withValues(alpha: 0.6)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(formatDuration(playerController.position)),
                          Text(formatDuration(track.duration)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        IconButton(
                          tooltip: 'Previous',
                          onPressed: playerController.previous,
                          icon: const Icon(Icons.skip_previous_rounded, size: 40),
                        ),
                        IconButton.filled(
                          tooltip: playerController.isPlaying ? 'Pause' : 'Play',
                          onPressed: playerController.toggle,
                          style: IconButton.styleFrom(
                            backgroundColor: AppColors.paper,
                            foregroundColor: AppColors.ink,
                            fixedSize: const Size(72, 72),
                          ),
                          icon: Icon(
                            playerController.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                            size: 40,
                          ),
                        ),
                        IconButton(
                          tooltip: 'Next',
                          onPressed: playerController.hasNext ? playerController.next : null,
                          icon: const Icon(Icons.skip_next_rounded, size: 40),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    },
  );
}
