import 'package:material_ui/material_ui.dart';
import 'package:music_go_routing/app/di.dart';
import 'package:music_go_routing/features/catalog/presentation/widgets/cover_art.dart';
import 'package:music_go_routing/features/notifications/presentation/widgets/notifications_button.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({required this.onOpenAlbum, required this.onOpenArtist, super.key});

  final ValueChanged<String> onOpenAlbum;
  final ValueChanged<String> onOpenArtist;

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 18) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final albums = catalogRepository.albums;
    return Scaffold(
      appBar: AppBar(title: Text(_greeting), actions: const [NotificationsButton(), SizedBox(width: 4)]),
      body: ListView(
        padding: EdgeInsets.only(bottom: 24 + MediaQuery.paddingOf(context).bottom),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
            child: Text('New albums', style: theme.textTheme.titleLarge),
          ),
          SizedBox(
            height: 212,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: albums.length,
              separatorBuilder: (_, _) => const SizedBox(width: 14),
              itemBuilder: (context, i) {
                final album = albums[i];
                return Semantics(
                  button: true,
                  label: album.title,
                  child: GestureDetector(
                    onTap: () => onOpenAlbum(album.id),
                    child: SizedBox(
                      width: 150,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CoverArt(color: album.color, label: album.title, size: 150, radius: 12),
                          const SizedBox(height: 10),
                          Text(
                            album.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                          Text(
                            catalogRepository.artist(album.artistId)!.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 28, 20, 4),
            child: Text('Artists', style: theme.textTheme.titleLarge),
          ),
          for (final artist in catalogRepository.artists)
            ListTile(
              onTap: () => onOpenArtist(artist.id),
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
              leading: CircleAvatar(
                radius: 24,
                backgroundColor: catalogRepository.albumsBy(artist.id).first.color,
                child: Text(
                  artist.name.characters.first,
                  style: const TextStyle(fontWeight: FontWeight.w800, color: Colors.white),
                ),
              ),
              title: Text(artist.name, style: const TextStyle(fontWeight: FontWeight.w600)),
              subtitle: Text('${catalogRepository.albumsBy(artist.id).length} albums'),
            ),
        ],
      ),
    );
  }
}
