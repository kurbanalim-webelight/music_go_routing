import 'package:go_router/go_router.dart';
import 'package:music_go_routing/app/app_controller.dart';
import 'package:music_go_routing/app/router/app_router.dart';
import 'package:music_go_routing/app/router/navigation_handler.dart';
import 'package:music_go_routing/features/auth/presentation/controllers/auth_controller.dart';
import 'package:music_go_routing/features/catalog/data/repositories/fake_catalog_repository.dart';
import 'package:music_go_routing/features/catalog/domain/repositories/catalog_repository.dart';
import 'package:music_go_routing/features/library/presentation/controllers/album_collection_controller.dart';
import 'package:music_go_routing/features/notifications/presentation/controllers/notifications_controller.dart';
import 'package:music_go_routing/features/player/presentation/controllers/music_controller.dart';
import 'package:music_go_routing/services/deeplink/deep_link_service.dart';

final CatalogRepository catalogRepository = FakeCatalogRepository();
final AuthController authController = AuthController();
final MusicController musicController = MusicController(catalogRepository);
final AlbumCollectionController favouritesController = AlbumCollectionController();
final AlbumCollectionController watchlistController = AlbumCollectionController();
final NotificationsController notificationsController = NotificationsController();

final GoRouter appRouter = createRouter();
final NavigationHandler navigationHandler = NavigationHandler(appRouter);
final DeepLinkService deepLinkService = DeepLinkService();
final AppController appController = AppController(deepLinkService, navigationHandler);
