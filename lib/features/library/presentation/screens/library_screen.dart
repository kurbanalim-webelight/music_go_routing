import 'package:material_ui/material_ui.dart';
import 'package:music_go_routing/app/di.dart';
import 'package:music_go_routing/app/widgets/empty_state.dart';
import 'package:music_go_routing/features/catalog/presentation/widgets/album_list_tile.dart';
import 'package:music_go_routing/features/catalog/presentation/widgets/cover_art.dart';
import 'package:music_go_routing/features/notifications/presentation/widgets/notifications_button.dart';

enum LibraryTab { own, favourite }

// The selected tab comes from the URL (?tab=). The screen reports changes through onTabChanged
// and the route writes them back to the URL, so the Library branch remembers the tab.
class LibraryScreen extends StatefulWidget {
  const LibraryScreen({
    required this.tab,
    required this.onTabChanged,
    required this.onOpenPlaylist,
    required this.onOpenAlbum,
    super.key,
  });

  final LibraryTab tab;
  final ValueChanged<LibraryTab> onTabChanged;
  final ValueChanged<String> onOpenPlaylist;
  final ValueChanged<String> onOpenAlbum;

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabs = TabController(
    length: LibraryTab.values.length,
    vsync: this,
    initialIndex: widget.tab.index,
  )..addListener(_onTabs);

  void _onTabs() {
    if (_tabs.indexIsChanging || _tabs.index == widget.tab.index) return;
    widget.onTabChanged(LibraryTab.values[_tabs.index]);
  }

  @override
  void didUpdateWidget(LibraryScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.tab.index != _tabs.index) _tabs.animateTo(widget.tab.index);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Library'),
      actions: const [NotificationsButton(), SizedBox(width: 4)],
      bottom: TabBar(
        controller: _tabs,
        tabAlignment: TabAlignment.start,
        isScrollable: true,
        tabs: const [
          Tab(text: 'Own'),
          Tab(text: 'Favourite'),
        ],
      ),
    ),
    body: TabBarView(
      controller: _tabs,
      children: [
        _OwnTab(onOpenPlaylist: widget.onOpenPlaylist),
        _FavouriteTab(onOpenAlbum: widget.onOpenAlbum),
      ],
    ),
  );
}

class _OwnTab extends StatelessWidget {
  const _OwnTab({required this.onOpenPlaylist});

  final ValueChanged<String> onOpenPlaylist;

  @override
  Widget build(BuildContext context) => ListView(
    padding: EdgeInsets.fromLTRB(0, 8, 0, 8 + MediaQuery.paddingOf(context).bottom),
    children: [
      for (final playlist in catalogRepository.playlists)
        ListTile(
          onTap: () => onOpenPlaylist(playlist.id),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          leading: CoverArt(
            color: catalogRepository.album(catalogRepository.track(playlist.trackIds.first)!.albumId)!.color,
            label: playlist.name,
            size: 52,
            radius: 6,
          ),
          title: Text(playlist.name, style: const TextStyle(fontWeight: FontWeight.w600)),
          subtitle: Text('Playlist, ${playlist.trackIds.length} songs'),
          trailing: const Icon(Icons.chevron_right_rounded),
        ),
    ],
  );
}

class _FavouriteTab extends StatelessWidget {
  const _FavouriteTab({required this.onOpenAlbum});

  final ValueChanged<String> onOpenAlbum;

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: favouritesController,
    builder: (context, _) {
      final albums = favouritesController.albumIds.map(catalogRepository.album).nonNulls.toList();
      if (albums.isEmpty) {
        return const EmptyState(
          icon: Icons.favorite_border_rounded,
          title: 'No favourites yet',
          message: 'Tap the heart on any album to keep it here.',
        );
      }
      return ListView(
        padding: EdgeInsets.fromLTRB(0, 8, 0, 8 + MediaQuery.paddingOf(context).bottom),
        children: [for (final album in albums) AlbumListTile(album: album, onTap: () => onOpenAlbum(album.id))],
      );
    },
  );
}
