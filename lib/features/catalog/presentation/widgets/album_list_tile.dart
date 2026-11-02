import 'package:material_ui/material_ui.dart';
import 'package:music_go_routing/app/di.dart';
import 'package:music_go_routing/features/catalog/domain/entities/album.dart';
import 'package:music_go_routing/features/catalog/presentation/widgets/cover_art.dart';

class AlbumListTile extends StatelessWidget {
  const AlbumListTile({required this.album, required this.onTap, super.key});

  final Album album;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => ListTile(
    onTap: onTap,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    leading: CoverArt(color: album.color, label: album.title, size: 52, radius: 6),
    title: Text(album.title, style: const TextStyle(fontWeight: FontWeight.w600)),
    subtitle: Text('${catalogRepository.artist(album.artistId)?.name ?? ''}, ${album.year}'),
    trailing: const Icon(Icons.chevron_right_rounded),
  );
}
