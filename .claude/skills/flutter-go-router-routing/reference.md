# Reference code

Adapt the names to the project. The code uses typed routes (`go_router_builder`). With plain `GoRoute`,
the same shapes apply.

## pubspec.yaml

```yaml
dependencies:
  go_router: ^<latest>
  app_links: ^<latest> # deep links
  flutter_local_notifications: ^<latest> # and/or firebase_messaging
dev_dependencies:
  go_router_builder: ^<latest>
  build_runner: ^<latest>
```

## main.dart, app.dart, di.dart

```dart
// main.dart
void main() {
  runApp(App(router: appRouter));
  unawaited(appController.start()); // starts listening to links and notifications right away
}

// app/app.dart
class App extends StatelessWidget {
  const App({required this.router, super.key});
  final GoRouter router;

  @override
  Widget build(BuildContext context) => MaterialApp.router(routerConfig: router);
}

// app/di.dart: app-wide instances, created once, in dependency order
final AuthController authController = AuthController();
final GoRouter appRouter = createRouter();
final NavigationHandler navigationHandler = NavigationHandler(appRouter);
final DeepLinkService deepLinkService = DeepLinkService();
final LocalNotificationService notificationService = LocalNotificationService();
final AppController appController = AppController(deepLinkService, notificationService, navigationHandler);
```

## app/router/app_router.dart

All route files are `part`s of this one library, so the generated `$appRoutes` and the `$XRoute` mixins can see them.

```dart
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:my_app/app/di.dart';
import 'package:my_app/app/router/app_pages.dart';
// ...one import per screen used by a route, alphabetical

part 'app_router.g.dart';
part 'guards/auth_guard.dart';
part 'routes/auth/auth_routes.dart';
part 'routes/catalog/product_routes.dart';
part 'routes/checkout/checkout_routes.dart';
part 'routes/home/home_routes.dart';
part 'routes/orders/orders_routes.dart';
part 'routes/shell/app_shell_routes.dart';
// ...one part per route file, alphabetical

// Routes that set $parentNavigatorKey to this open above the shell and cover the bottom bar.
final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');

GoRouter createRouter() => GoRouter(
  navigatorKey: rootNavigatorKey,
  initialLocation: const SplashRoute().location,
  routes: $appRoutes, // generated from every @TypedGoRoute / @TypedStatefulShellRoute
  redirect: authGuard,
  errorBuilder: (context, state) => NotFoundScreen(onGoHome: () => const HomeRoute().go(context)),
  debugLogDiagnostics: kDebugMode,
);
```

## A route file: app/router/routes/<feature>/<name>_routes.dart

```dart
part of '../../app_router.dart';

// Nested routes are `const` values listed in a parent's `routes:`. Top-level routes use the @ annotation.
const productRoute = TypedRelativeGoRoute<ProductRoute>(path: 'product/:productId');

class ProductRoute extends RelativeGoRouteData with $ProductRoute {
  const ProductRoute({required this.productId});
  final String productId;

  @override
  Widget build(BuildContext context, GoRouterState state) => ProductScreen(
    productId: productId,
    onCheckout: () => const CheckoutRoute().push<void>(context), // callbacks wired here, not in the screen
  );
}
```

## Shell: app/router/routes/shell/app_shell_routes.dart

```dart
part of '../../app_router.dart';

// Branch order = tab index. Keep it in sync with the bottom bar's items. Home stays at 0.
@TypedStatefulShellRoute<AppShellRoute>(branches: [homeBranch, ordersBranch, accountBranch])
class AppShellRoute extends StatefulShellRouteData {
  const AppShellRoute();

  @override
  Widget builder(BuildContext context, GoRouterState state, StatefulNavigationShell shell) => AppShell(shell: shell);
}

// AppShell: bottom bar with onSelected: (i) => shell.goBranch(i, initialLocation: i == shell.currentIndex),
// plus PopScope(canPop: index == 0, onPopInvokedWithResult: (didPop, _) { if (!didPop) shell.goBranch(0); }).
```

## Inner tabs: enum + regex path + shared page key

```dart
enum OrdersTab { active, past }

const ordersBranch = TypedStatefulShellBranch<OrdersBranch>(
  routes: [
    TypedGoRoute<OrdersRoute>(path: '/orders/:tab(active|past)', routes: [productRoute]),
    TypedGoRoute<OrdersRootRoute>(path: '/orders'),
  ],
);

class OrdersBranch extends StatefulShellBranchData {
  const OrdersBranch();
  static const String $initialLocation = '/orders/active';
}

class OrdersRoute extends GoRouteData with $OrdersRoute {
  const OrdersRoute({required this.tab});
  final OrdersTab tab;

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) => MaterialPage<void>(
    key: const ValueKey('orders'), // same page for every tab, so switching doesn't push
    child: OrdersScreen(tab: tab, onTabChanged: (tab) => OrdersRoute(tab: tab).go(context)),
  );
}

class OrdersRootRoute extends GoRouteData with $OrdersRootRoute {
  const OrdersRootRoute();
  @override
  String? redirect(BuildContext context, GoRouterState state) => const OrdersRoute(tab: OrdersTab.active).location;
}
```

In the screen, keep the `TabController` in sync both ways:

```dart
late final TabController _tabs = TabController(length: OrdersTab.values.length, vsync: this, initialIndex: widget.tab.index)
  ..addListener(() {
    if (_tabs.indexIsChanging || _tabs.index == widget.tab.index) return;
    widget.onTabChanged(OrdersTab.values[_tabs.index]);
  });

@override
void didUpdateWidget(OrdersScreen old) {
  super.didUpdateWidget(old);
  if (_tabs.index != widget.tab.index) _tabs.animateTo(widget.tab.index); // a link changed the tab
}
```

## Shared screen in several tabs

```dart
const productRoute = TypedRelativeGoRoute<ProductRoute>(path: 'product/:productId');
// Listed under /home and /orders/:tab. Opened with ProductRoute(productId: id).goRelative(context),
// from the screen on top. /home -> /home/product/42, /orders/past -> /orders/past/product/42
```

## Full-screen page

```dart
class CheckoutRoute extends GoRouteData with $CheckoutRoute {
  static final GlobalKey<NavigatorState> $parentNavigatorKey = rootNavigatorKey; // covers the bottom bar
  ...
}
```

## Auth guard (deny by default)

```dart
String? authGuard(BuildContext context, GoRouterState state) {
  final location = state.matchedLocation;
  if (location == const SplashRoute().location) return null; // session still restoring

  final isOnAuthScreen = location.startsWith(const LoginRoute().location);
  if (!authController.isSignedIn) {
    return isOnAuthScreen ? null : LoginRoute(from: state.uri.toString()).location;
  }
  if (isOnAuthScreen) {
    return state.uri.queryParameters['from'] ?? const HomeRoute().location;
  }
  return null;
}
```

If some screens are public, share one check between the guard and `NavigationHandler`.
Call it before the sign-in test:

```dart
// Splash and auth screens are handled separately. Return false here when every screen needs sign-in.
bool isPublicPath(String path) => path == '/home' || path.startsWith('/home/product/');
```

## Guards

### Onboarding, in the top-level redirect, after the sign-in check

```dart
final isOnOnboarding = location.startsWith(const OnboardingRoute().location);
if (!authController.isOnboarded && !isOnOnboarding) {
  return OnboardingRoute(from: state.uri.toString()).location;
}
```

### Role, as a route-level redirect

```dart
class AdminRoute extends GoRouteData with $AdminRoute {
  const AdminRoute();

  @override
  String? redirect(BuildContext context, GoRouterState state) =>
      authController.user?.isAdmin == true ? null : const NotAllowedRoute().location;
  ...
}
```

### Unsaved changes, with onExit

```dart
class CheckoutRoute extends GoRouteData with $CheckoutRoute {
  @override
  Future<bool> onExit(BuildContext context, GoRouterState state) async {
    // onExit also runs on go(login) during a forced logout. Never block that.
    if (!authController.isSignedIn || !checkoutController.hasUnsavedChanges) return true;
    final leave = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Discard changes?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Stay')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Discard')),
        ],
      ),
    );
    return leave ?? false;
  }
  ...
}
```

### Forced logout: add to NavigationHandler

Call this from the HTTP layer on a 401, or when the session expires.

```dart
void forceSignOut() {
  final current = _router.routerDelegate.currentConfiguration.uri.toString();
  authController.signOut();
  resetUserScopedState(); // cart, notifications, caches
  _router.go(LoginRoute(from: current).location); // go, not push: tab stacks are disposed
}
```

## NavigationHandler

```dart
class NavigationHandler {
  NavigationHandler(this._router);
  final GoRouter _router;

  void open(String location) {
    final match = _findOpenableMatch(location);
    if (match == null) return;

    // Same public list as the guard, so public links still open when signed out.
    if (!authController.isSignedIn && !isPublicPath(match.uri.path)) {
      _router.go(LoginRoute(from: location).location);
      return;
    }

    if (_isOutsideShell(match)) {
      _router.push<void>(location);
    } else {
      _router.go(location);
    }
  }

  // After the splash or login. A route outside the shell gets Home underneath it.
  Future<void> enterShell({String? from}) async {
    final home = const HomeRoute().location;
    final match = from == null ? null : _findOpenableMatch(from);
    if (match == null) {
      _router.go(home);
      return;
    }

    final location = match.uri.toString();
    if (_isOutsideShell(match)) {
      _router.go(home);
      await WidgetsBinding.instance.endOfFrame;
      _router.push<void>(location);
      return;
    }
    _router.go(location);
  }

  // Inside the shell, go() rebuilds the stack. Outside, go() would leave the page alone, so push.
  bool _isOutsideShell(RouteMatchList match) => !match.matches.any((m) => m is ShellRouteMatch);

  RouteMatchList? _findOpenableMatch(String location) {
    final uri = Uri.tryParse(location);
    if (uri == null) return null;
    final match = _router.configuration.findMatch(uri);
    final isAuthRoute = uri.path.startsWith(const LoginRoute().location);
    return match.isError || isAuthRoute ? null : match;
  }
}
```

## AppController: hold locations until startup is done

```dart
class AppController {
  AppController(this._deepLinks, this._notifications, this._navigationHandler);

  final DeepLinkService _deepLinks;
  final NotificationService _notifications;
  final NavigationHandler _navigationHandler;

  Future<void>? _started;
  bool _isStartupComplete = false;
  String? _pendingLocation;

  Future<void> start() => _started ??= _listen(); // called from main()

  // Called by the splash once the session is restored. Returns the launch location, if any.
  Future<String?> completeStartup() async {
    await start();
    _isStartupComplete = true;
    final location = _pendingLocation;
    _pendingLocation = null;
    return location;
  }

  Future<void> _listen() async {
    _pendingLocation = await _notifications.initialLocation() ?? await _deepLinks.initialLocation();
    _deepLinks.incomingLocations.listen(_onLocation);
    _notifications.tappedLocations.listen(_onLocation);
  }

  void _onLocation(String location) {
    if (!_isStartupComplete) {
      _pendingLocation = location;
      return;
    }
    _navigationHandler.open(location);
  }
}
```

Splash: `final location = await appController.completeStartup();`. Then, if signed in,
`navigationHandler.enterShell(from: location)`. If signed out, `LoginRoute(from: location).go(context)`.

## DeepLinkService (app_links)

```dart
class DeepLinkService {
  static const _scheme = 'myapp';
  static const _host = 'share';
  static String linkFor(String location) => '$_scheme://$_host$location';

  final AppLinks _appLinks = AppLinks();
  Uri? _initialLink;

  Future<String?> initialLocation() async {
    final link = await _appLinks.getInitialLink();
    if (link == null) return null;
    _initialLink = link;
    return _locationFrom(link);
  }

  // The stream replays the launch link once. Skip it, because initialLocation() already returned it.
  Stream<String> get incomingLocations => _appLinks.uriLinkStream
      .where((link) {
        if (link != _initialLink) return true;
        _initialLink = null;
        return false;
      })
      .map(_locationFrom)
      .where((l) => l != null)
      .cast();

  String? _locationFrom(Uri link) {
    if (link.scheme != _scheme || link.host != _host) return null;
    return Uri(path: link.path, query: link.query.isEmpty ? null : link.query).toString();
  }
}
```

For https links, check `link.host == 'yourdomain.com'` instead, and add App Links and Universal Links setup.

## NotificationService contract

Any notification source (`flutter_local_notifications`, FCM, OneSignal) only has to provide these two things:

```dart
Future<String?> initialLocation(); // the notification that launched the app
Stream<String> get tappedLocations; // taps while the app is open or in the background
```

- **Local** (`flutter_local_notifications`):
  - Launch: `getNotificationAppLaunchDetails()` → `notificationResponse?.payload`.
  - Taps: `onDidReceiveNotificationResponse`.
  - Schedule with `zonedSchedule` so the OS fires it even after the app is killed.
- **FCM:** `getInitialMessage()` for the launch, `onMessageOpenedApp` for taps. The location goes in `message.data['location']`.

## Platform switches

- **Android** `AndroidManifest.xml`, inside the main activity:

  ```xml
  <meta-data android:name="flutter_deeplinking_enabled" android:value="false" />
  <intent-filter>
    <action android:name="android.intent.action.VIEW" />
    <category android:name="android.intent.category.DEFAULT" />
    <category android:name="android.intent.category.BROWSABLE" />
    <data android:scheme="myapp" android:host="share" />
  </intent-filter>
  ```

- **iOS** `Info.plist`:
  - `FlutterDeepLinkingEnabled` = `false`.
  - `CFBundleURLTypes` with the URL scheme `myapp`.

## Route check test

`test/route_check_test.dart` fails as soon as a location stops matching, or moves between the shell and the root.
Extend `cases` whenever a route is added. If the app has a Tester screen, build `cases` from its list instead.

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:my_app/app/router/app_router.dart';

// location → true if it opens outside the shell (pushed on top), false if inside (go).
const cases = <String, bool>{
  '/home': false,
  '/home/product/p1': false,
  '/orders/active': false,
  '/orders/past/product/p1': false,
  '/orders/past/product/unknown-id': false, // still matches; the screen shows "not found"
  '/account': false,
  '/checkout': true,
};

void main() {
  final router = createRouter();

  for (final MapEntry(key: location, value: outsideShell) in cases.entries) {
    test(location, () {
      final match = router.configuration.findMatch(Uri.parse(location));
      expect(match.isError, isFalse, reason: 'no route matches $location');
      final isOutside = !match.matches.any((m) => m is ShellRouteMatch);
      expect(isOutside, outsideShell, reason: 'wrong navigator for $location: go/push would be wrong');
    });
  }

  test('unknown inner tab does not match', () {
    expect(router.configuration.findMatch(Uri.parse('/orders/unknown-tab')).isError, isTrue);
  });
}
```

Run it with `flutter test test/route_check_test.dart`. If `createRouter()` touches services that need
platform plugins, create the router with fakes in the test.

## Test commands

```bash
xcrun simctl openurl booted "myapp://share/orders/past/product/42"
adb shell am start -a android.intent.action.VIEW -d "myapp://share/orders/past/product/42"
```
