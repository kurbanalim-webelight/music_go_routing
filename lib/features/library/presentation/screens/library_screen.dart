import 'package:material_ui/material_ui.dart';
import 'package:music_go_routing/app/di.dart';
import 'package:music_go_routing/app/widgets/empty_state.dart';
import 'package:music_go_routing/features/catalog/presentation/widgets/album_list_tile.dart';
import 'package:music_go_routing/features/library/presentation/controllers/album_collection_controller.dart';
import 'package:music_go_routing/features/notifications/presentation/widgets/notifications_button.dart';

enum LibraryTab { watchlist, favourite }

// The selected tab comes from the URL (/library/:tab). The screen reports changes through
// onTabChanged and the route writes them back to the URL, so the Library branch remembers the tab.
class LibraryScreen extends StatefulWidget {
  const LibraryScreen({required this.tab, required this.onTabChanged, required this.onOpenAlbum, super.key});

  final LibraryTab tab;
  final ValueChanged<LibraryTab> onTabChanged;
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
          Tab(text: 'Watchlist'),
          Tab(text: 'Favourite'),
        ],
      ),
    ),
    body: TabBarView(
      controller: _tabs,
      children: [
        _AlbumCollectionTab(
          collection: watchlistController,
          onOpenAlbum: widget.onOpenAlbum,
          emptyIcon: Icons.bookmark_border_rounded,
          emptyTitle: 'Your watchlist is empty',
          emptyMessage: 'Tap the bookmark on any album to save it here.',
        ),
        _AlbumCollectionTab(
          collection: favouritesController,
          onOpenAlbum: widget.onOpenAlbum,
          emptyIcon: Icons.favorite_border_rounded,
          emptyTitle: 'No favourites yet',
          emptyMessage: 'Tap the heart on any album to keep it here.',
        ),
      ],
    ),
  );
}

class _AlbumCollectionTab extends StatelessWidget {
  const _AlbumCollectionTab({
    required this.collection,
    required this.onOpenAlbum,
    required this.emptyIcon,
    required this.emptyTitle,
    required this.emptyMessage,
  });

  final AlbumCollectionController collection;
  final ValueChanged<String> onOpenAlbum;
  final IconData emptyIcon;
  final String emptyTitle;
  final String emptyMessage;

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: collection,
    builder: (context, _) {
      final albums = collection.albumIds.map(catalogRepository.album).nonNulls.toList();
      if (albums.isEmpty) {
        return EmptyState(icon: emptyIcon, title: emptyTitle, message: emptyMessage);
      }
      return ListView(
        padding: EdgeInsets.fromLTRB(0, 8, 0, 8 + MediaQuery.paddingOf(context).bottom),
        children: [for (final album in albums) AlbumListTile(album: album, onTap: () => onOpenAlbum(album.id))],
      );
    },
  );
}
