import 'package:music_go_routing/features/auth/presentation/controllers/auth_controller.dart';
import 'package:music_go_routing/features/catalog/data/repositories/fake_catalog_repository.dart';
import 'package:music_go_routing/features/catalog/domain/repositories/catalog_repository.dart';
import 'package:music_go_routing/features/library/presentation/controllers/album_collection_controller.dart';
import 'package:music_go_routing/features/notifications/presentation/controllers/notifications_controller.dart';
import 'package:music_go_routing/features/player/presentation/controllers/player_controller.dart';

// ponytail: app-wide singletons as top-level finals. Move to get_it/provider when tests need to swap them.
final CatalogRepository catalogRepository = FakeCatalogRepository();
final AuthController authController = AuthController();
final PlayerController playerController = PlayerController();
final AlbumCollectionController favouritesController = AlbumCollectionController();
final AlbumCollectionController watchlistController = AlbumCollectionController();
final NotificationsController notificationsController = NotificationsController();
