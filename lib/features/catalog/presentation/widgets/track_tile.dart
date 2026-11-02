import 'package:material_ui/material_ui.dart';
import 'package:music_go_routing/app/di.dart';
import 'package:music_go_routing/features/catalog/domain/entities/track.dart';

class TrackTile extends StatelessWidget {
  const TrackTile({required this.track, required this.leading, required this.onTap, this.subtitle, super.key});

  final Track track;
  final Widget leading;
  final String? subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListenableBuilder(
      listenable: musicController,
      builder: (context, _) {
        final isCurrent = musicController.currentTrack?.id == track.id;
        return ListTile(
          onTap: onTap,
          leading: SizedBox(
            width: 40,
            child: Center(
              child: isCurrent ? Icon(Icons.graphic_eq_rounded, color: theme.colorScheme.primary) : leading,
            ),
          ),
          title: Text(
            track.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontWeight: FontWeight.w600, color: isCurrent ? theme.colorScheme.primary : null),
          ),
          subtitle: subtitle == null ? null : Text(subtitle!, maxLines: 1, overflow: TextOverflow.ellipsis),
          trailing: Text(formatDuration(track.duration), style: TextStyle(color: theme.colorScheme.onSurfaceVariant)),
        );
      },
    );
  }
}
