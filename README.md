# Music — go_router reference app

A small music app that shows how a real Flutter app can handle navigation with
[go_router](https://pub.dev/packages/go_router): typed routes, a bottom-bar shell with a stack per tab,
a persistent mini player, shared screens across tabs, an auth guard, a splash screen, deep links and
notification taps, all going through one navigation path.

---

## Contents

- [Getting started](#getting-started)
- [Tech stack](#tech-stack)
- [Project structure](#project-structure)
- [Routing](#routing)
- [App start, deep links and notifications](#app-start-deep-links-and-notifications)
- [Testing links and notifications](#testing-links-and-notifications)
- [State](#state)
- [Adding a new screen](#adding-a-new-screen)
- [Known limitations](#known-limitations)

---

## Getting started

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs   # generates lib/app/router/app_router.g.dart
flutter run
```

`app_router.g.dart` is generated and not committed, so run `build_runner` after every clone and after
changing any route.

**Signing in:** any email containing `@` and a password of 6+ characters works (the login form is
pre-filled with `demo@music.app`). The session is saved on the device and restored on the next launch.

---

## Tech stack

| Package | Used for |
|---|---|
| `go_router` + `go_router_builder` | Typed routes, shell routes, redirects |
| `material_ui` / `cupertino_ui` | Widgets and page transitions (see [Rules](#rules)) |
| `app_links` | Receiving deep links |
| `flutter_local_notifications` + `timezone` | Scheduling local notifications and handling taps |
| `shared_preferences` | Keeping the user signed in |

Built with Flutter 3.47.

---

## Project structure

```
lib/
├── main.dart                         runApp + start listening for links and notification taps
├── app/
│   ├── app.dart                      MaterialApp.router
│   ├── app_controller.dart           Collects incoming locations (links, notification taps)
│   ├── di.dart                       App-wide instances (controllers, router, services)
│   ├── theme.dart
│   ├── router/
│   │   ├── app_router.dart           GoRouter, root navigator key, error page
│   │   ├── navigation_handler.dart   Opens a location coming from outside the app
│   │   ├── app_pages.dart            Custom transitions (fade, slide up)
│   │   ├── guards/auth_guard.dart    Signed-out → /login?from=…
│   │   └── routes/<feature>/…        One routes file per feature
│   └── widgets/                      Shared widgets (empty state, not-found page, …)
├── features/                         auth, catalog, home, library, notifications,
│   └── <feature>/                    notification_tester, player, profile, shell, splash
│       ├── data/ domain/             (where a feature has its own data)
│       └── presentation/             controllers/, screens/, widgets/
└── services/
    ├── deeplink/deep_link_service.dart
    └── notifications/local_notification_service.dart
```

Route definitions live under `lib/app/router/routes/`, grouped by feature. They are `part of`
`app_router.dart`, because `go_router_builder` generates all routes into one file.

---

## Routing

### Route map

```
/splash                                          start screen (always the first route)
/login                                           fade in
└── signup
/player/:trackId                                 root navigator: covers the bottom bar, slides up

Shell (StatefulShellRoute: bottom bar + mini player, one Navigator per tab)
├── /home
│   ├── album/:albumId
│   ├── artist/:artistId
│   │   └── album/:albumId
│   └── notifications
├── /library                                     redirects to /library/watchlist
├── /library/:tab(watchlist|favourite)
│   ├── album/:albumId
│   ├── artist/:artistId
│   │   └── album/:albumId
│   └── notifications
└── /profile
    ├── settings
    │   ├── account                              root navigator: covers the bottom bar
    │   └── notification-tester
    └── notifications
```

Every route above that is not on the root navigator opens inside its tab: the bottom bar and the
mini player stay visible, and each tab keeps its own back stack when you switch tabs.

### Hierarchical and independent routes

| Kind | Routes | How it opens |
|---|---|---|
| **Hierarchical** | Everything inside the shell, and Account | The URL *is* the stack. `go()` builds every parent screen in the right tab, so back always leads to the parent. |
| **Independent** | `/player/:trackId` | Opens on top of whatever is on screen; back returns there. |

Independent routes are listed in `NavigationHandler._independentRoutes` by their route pattern
(`'/player/:trackId'`).

### Shared screens across tabs

Album, Artist and Notifications appear in more than one tab. Each is a single
`TypedRelativeGoRoute` declared once as a `const` and listed under every tab that needs it:

```dart
const albumRoute = TypedRelativeGoRoute<AlbumRoute>(path: 'album/:albumId');
const artistRoute = TypedRelativeGoRoute<ArtistRoute>(path: 'artist/:artistId', routes: [albumRoute]);
```

They are opened with the generated `goRelative()`, which appends to the current location:

```dart
// on /library/favourite
const AlbumRoute(albumId: 'al1').goRelative(context);   // → /library/favourite/album/al1
// on /home
const AlbumRoute(albumId: 'al1').goRelative(context);   // → /home/album/al1
```

- Call `goRelative()` from the screen that is currently on top, since it uses the router's current location.
- Use `goRelative()`, not `pushRelative()`. In go_router 18.1.2, relative paths (`./…`) are only
  resolved by `go()`.
- Artist can contain Album, but Album does not contain Artist, because a route tree cannot loop.

### Library tabs

The Library tab is part of the path: `/library/watchlist`, `/library/favourite`.

- The path is `/library/:tab(watchlist|favourite)`. The regular expression means any other value
  doesn't match the route, instead of crashing.
- When adding a value to `LibraryTab`, add it to the expression too.
- Bare `/library` redirects to `/library/watchlist`.
- Both tabs share one page key, so switching tabs updates the page instead of pushing a new one.

### Auth guard

`authGuard` is the router's `redirect`:

- Signed out → every route except `/splash`, `/login` and `/login/signup` redirects to
  `/login?from=<where you were going>`.
- Signed in and on `/login` → redirects to `from`, or `/home`.

Navigation after signing in or out is explicit: login and signup call
`navigationHandler.enterShell(from: …)`, and sign-out goes to `LoginRoute`. The router does not listen
to auth changes (no `refreshListenable`).

### Not found

`NotFoundScreen` is the router's `errorBuilder`. Its **Go home** button opens `/home`. go_router's
default error page goes to `/`, which this app does not have.

### Rules

- **`go` to jump, `push` to stack.** Hierarchical routes use `go` (the URL decides the stack).
  `push` is for root-navigator pages opened in-app, like Settings → Account and the mini player → Player.
- **Hide the bottom bar by choosing the navigator.** Routes with
  `$parentNavigatorKey = rootNavigatorKey` (Player, Account) cover the shell. Everything else keeps it.
- **Screens don't import routes.** Routes pass callbacks (`onOpenAlbum`, `onSignedIn`, …), so a screen
  can be reused wherever a route builds it.
- **Import `material_ui`, not `package:flutter/material.dart`.** go_router 18 looks for `material_ui`'s
  `MaterialApp`. With `flutter/material` it doesn't find one and falls back to pages with no transition.
- **Every screen is reachable by URL.** Pass IDs as path parameters, and let screens load their own
  data from those IDs. Then deep links and notifications work for new screens without extra code.

---

## App start, deep links and notifications

Deep links and notification taps both come in as an **app location** (for example
`/home/artist/a1/album/al2`) and go through one path:

```
DeepLinkService ───────────┐
                           ├──→ AppController ──→ NavigationHandler ──→ GoRouter
LocalNotificationService ──┘      holds the location       decides go / push
                                  until the splash is done
```

| Piece | Responsibility |
|---|---|
| `DeepLinkService` | Turns `musicgo://share/<location>` into a location: the launch link, plus a stream of later links. |
| `LocalNotificationService` | Schedules notifications. Gives the location of the notification that launched the app, plus a stream of later taps. The payload is the location. |
| `AppController` | Reads both launch values, then listens to both streams. Holds anything that arrives during the splash. After that, passes locations to `NavigationHandler`. |
| `NavigationHandler` | Opens a location. Ignores unknown and `/login` locations. Signed out → `/login?from=…`. Independent → `push`, otherwise `go`. |

### Startup flow

1. `main()` runs the app and calls `appController.start()`.
2. The app opens on `/splash`. `SplashController` restores the saved session and waits at least 3 seconds.
3. The splash calls `appController.completeStartup()`, which returns the location to open, if any.
4. The splash then opens one of:

| Signed in? | Location? | Opens |
|---|---|---|
| Yes | No | `/home` |
| Yes | Yes | `navigationHandler.enterShell(from: location)`: goes to the location; an independent route opens on top of Home |
| No | Either | `/login?from=<location>`; after sign-in, `enterShell(from)` opens it |

### Deep links

- Format: `musicgo://share/<location>`, e.g. `musicgo://share/home/album/al1`.
- Flutter's built-in deep linking is switched off, so every link goes through `NavigationHandler`:
  - **Android:** `flutter_deeplinking_enabled = false`, plus an intent filter for `musicgo://share`.
  - **iOS:** `FlutterDeepLinkingEnabled = false`, plus the `musicgo` URL scheme in `Info.plist`.

### Notifications

| App state when tapped | Handled by |
|---|---|
| Killed | `getNotificationAppLaunchDetails()`, then the startup flow above |
| In the background or open | `onDidReceiveNotificationResponse`, then `NavigationHandler.open()` |

Notifications are scheduled with `zonedSchedule`, so the OS fires them even if the app is killed.

**Platform setup:**
- **iOS:** `AppDelegate` sets `UNUserNotificationCenter.current().delegate`.
- **Android:**
  - core library desugaring is enabled in `build.gradle.kts`;
  - the scheduled-notification receivers and `RECEIVE_BOOT_COMPLETED` are in the manifest.
- **Permission** is requested the first time a notification is sent.

**Adding remote push** (e.g. Firebase Cloud Messaging) later: send the location in the message data.
The new service should, like `LocalNotificationService`, provide the launch location and a stream of
taps, and `AppController` should listen to it. No routing code changes.

---

## Testing links and notifications

### Notification tester

**Profile → Settings → Notification tester** (`/profile/settings/notification-tester`):

1. Pick a screen. Every route is listed, plus "Unknown route".
2. Pick its parameters: Library tab, artist, album, track. Each list ends with an "Unknown …" option.
3. Check the preview: the exact location, and what should happen.
4. Tap **Send in 3 seconds**. Stay in the app, or close it to test a cold start.

### Deep links on the iOS Simulator

```bash
xcrun simctl openurl booted "musicgo://share/home/artist/a1/album/al2"
xcrun simctl openurl booted "musicgo://share/library/favourite"
xcrun simctl openurl booted "musicgo://share/player/t5"

# Test the "app killed" case: quit first, then open a link
xcrun simctl terminate booted com.example.musicGoRouting
xcrun simctl openurl booted "musicgo://share/profile/settings/account"
```

On Android: `adb shell am start -a android.intent.action.VIEW -d "musicgo://share/home/album/al1"`.

Sample IDs: artists `a1`–`a4`, albums `al1`–`al6`, tracks `t1`–`t20`.

| Link | Result |
|---|---|
| A known screen | Opens it in the right tab, with its parent screens underneath |
| `/player/<known id>` | Plays the track and opens the player on top |
| `/player/<unknown id>` | Toast "Track not found", player closes |
| Unknown album or artist ID | The screen shows "Album not found" / "Artist not found" |
| Unknown route or Library tab | Ignored. On a cold start the app opens Home. |
| `/login`, `/login/signup` | Ignored |

---

## State

App-wide instances are created once in `lib/app/di.dart`. Controllers are plain classes or
`ChangeNotifier`s, and widgets rebuild with `ListenableBuilder`.

| Instance | Holds |
|---|---|
| `authController` | Signed-in user, saved with `shared_preferences` |
| `musicController` | What is playing: track, album, artist, position and controls. Drives the mini player and the player. |
| `favouritesController`, `watchlistController` | Saved albums. Two instances of `AlbumCollectionController`. |
| `notificationsController` | In-app notification list and read state |
| `catalogRepository` | Sample albums, artists and tracks |
| `appRouter`, `navigationHandler`, `appController` | Routing and incoming locations |

---

## Adding a new screen

1. Create the screen in `lib/features/<feature>/presentation/screens/`. Give it IDs and callbacks, not routes.
2. Add a route in `lib/app/router/routes/<feature>/`:
   - **in one tab:** a `TypedGoRoute` nested in that tab's route list;
   - **in several tabs:** a `TypedRelativeGoRoute` const, listed under each tab;
   - **over the bottom bar:** set `$parentNavigatorKey = rootNavigatorKey`.
3. If it should open on top of the current screen from a link or notification, add its path
   pattern to `NavigationHandler._independentRoutes`.
4. Add the `part` line to `app_router.dart` and run `build_runner`.
5. Add it to `notificationRouteOptions` so it can be tested from the Notification tester.

Deep links and notifications then reach the new screen with no further code.

---

## Known limitations

- **Links:** only the custom scheme `musicgo://` is set up. HTTPS links (App Links / Universal Links)
  need a domain and verification files.
- **Auth links:** links to `/login` or `/login/signup` are ignored.
- **Android timing:** notifications use inexact scheduling, so they can arrive a little after 3 seconds.
  Some manufacturers' Android versions delay background work further.
- **ID pairs aren't checked:** an album under an artist is not checked to belong to that artist.
- **Playback is simulated** with a timer. Use a real audio package (e.g. `just_audio`) for sound.
- **Saved albums and notification read state** are kept in memory only.
- **No automated tests.**
