import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:go_router/go_router.dart';
import 'package:music_go_routing/app/app.dart';
import 'package:music_go_routing/app/di.dart';
import 'package:music_go_routing/app/router/app_router.dart';
import 'package:music_go_routing/app/shell/floating_nav_bar.dart';
import 'package:music_go_routing/features/catalog/presentation/screens/album_screen.dart';
import 'package:music_go_routing/features/profile/presentation/screens/account_screen.dart';
import 'package:music_go_routing/features/player/presentation/widgets/mini_player.dart';

late GoRouter router;

Future<void> start(WidgetTester tester, {bool signedIn = true}) async {
  if (signedIn) authController.signIn(email: 'test@music.app');
  router = createRouter();
  await tester.pumpWidget(MusicApp(router: router));
  await tester.pumpAndSettle();
}

Future<void> open(WidgetTester tester, void Function() navigate) async {
  navigate();
  await tester.pumpAndSettle();
}

String get location => router.state.uri.toString();

void main() {
  tearDown(() {
    playerController.stop();
    authController.signOut();
  });

  test('every app path resolves', () {
    final r = createRouter();
    for (final path in [
      '/login',
      '/login/signup',
      '/home',
      '/home/album/al1',
      '/home/artist/a1',
      '/library?tab=favourite',
      '/library/playlist/p1',
      '/library/album/al1',
      '/profile',
      '/profile/settings',
      '/profile/settings/account',
      '/player',
      '/home/notifications',
      '/library/notifications',
      '/profile/notifications',
    ]) {
      expect(r.configuration.findMatch(Uri.parse(path)).isError, isFalse, reason: path);
    }
  });

  testWidgets('signed out goes to login, signing in returns to the requested page', (tester) async {
    await start(tester, signedIn: false);
    expect(location, '/login?from=%2Fhome');

    await open(tester, () => router.go('/library/playlist/p1'));
    expect(location, '/login?from=%2Flibrary%2Fplaylist%2Fp1');

    await open(tester, () => authController.signIn(email: 'a@b.c'));
    expect(location, '/library/playlist/p1');
    expect(find.text('Late shift'), findsOneWidget);
  });

  testWidgets('mini player and bottom bar persist in tabs, hide on account and player', (tester) async {
    await start(tester);
    expect(find.byType(MiniPlayer), findsOneWidget);
    expect(find.text('Depot'), findsNothing);

    await open(tester, () => const HomeAlbumRoute(albumId: 'al1').push<void>(rootNavigatorKey.currentContext!));
    await tester.tap(find.text('Play'));
    await tester.pumpAndSettle();
    expect(find.descendant(of: find.byType(MiniPlayer), matching: find.text('Depot')), findsOneWidget);

    // Switch tab: the mini player stays, and Home keeps its album page.
    await tester.tap(find.text('Library'));
    await tester.pumpAndSettle();
    expect(find.descendant(of: find.byType(MiniPlayer), matching: find.text('Depot')), findsOneWidget);
    await tester.tap(find.text('Home'));
    await tester.pumpAndSettle();
    expect(location, '/home/album/al1');

    // Re-tap Home: back to the tab root.
    await tester.tap(find.text('Home'));
    await tester.pumpAndSettle();
    expect(location, '/home');

    // Settings stays in the tab; Account covers the shell.
    await tester.tap(find.text('Profile'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();
    expect(find.byType(FloatingNavBar), findsOneWidget);
    await tester.tap(find.text('Account'));
    await tester.pumpAndSettle();
    expect(location, '/profile/settings/account');
    expect(find.byType(FloatingNavBar), findsNothing);
    expect(find.text('Depot'), findsNothing);

    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.byType(FloatingNavBar), findsOneWidget);
    expect(find.text('Depot'), findsOneWidget);

    // Mini player opens the full player on the root navigator.
    await tester.tap(find.text('Depot'));
    await tester.pumpAndSettle();
    expect(find.byType(FloatingNavBar), findsNothing);
    expect(find.byTooltip('Close player'), findsOneWidget);

    playerController.stop(); // the playback ticker must not outlive the test
  });

  testWidgets('library tab lives in the URL and survives tab switches', (tester) async {
    await start(tester);
    await tester.tap(find.text('Library'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Favourite'));
    await tester.pumpAndSettle();
    expect(location, '/library?tab=favourite');
    expect(find.text('No favourites yet'), findsOneWidget);

    await tester.tap(find.text('Home'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Library'));
    await tester.pumpAndSettle();
    expect(location, '/library?tab=favourite');
  });

  testWidgets('notification opens its target inside the right tab', (tester) async {
    await start(tester);
    await tester.tap(find.byTooltip('Notifications'));
    await tester.pumpAndSettle();
    expect(location, '/home/notifications');
    expect(find.byType(FloatingNavBar), findsOneWidget);
    await tester.tap(find.text('Late shift was updated'));
    await tester.pumpAndSettle();
    expect(location, '/library/playlist/p1');
    expect(find.byType(FloatingNavBar), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(location, '/library');
  });

  // go_router only animates pages when it finds a material_ui MaterialApp above it; with
  // package:flutter/material's MaterialApp it silently falls back to NoTransitionPage.
  testWidgets('pushes animate inside a tab and on the root navigator', (tester) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    await start(tester);

    double midPush<T extends Widget>() => ModalRoute.of(tester.element(find.byType(T)))!.animation!.value;

    router.push('/home/album/al1');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(midPush<AlbumScreen>(), inExclusiveRange(0, 1));
    await tester.pumpAndSettle();

    router.push('/profile/settings/account');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(midPush<AccountScreen>(), inExclusiveRange(0, 1));
    await tester.pumpAndSettle();

    debugDefaultTargetPlatformOverride = null;
  });
}
