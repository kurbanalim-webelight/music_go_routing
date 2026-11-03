---
name: flutter-go-router-routing
description: Use when setting up or changing navigation in a Flutter app that uses go_router - adding screens or routes, bottom-bar tabs, inner tabs (TabBar), full-screen pages, auth/login guards, deep links, push or local notifications that open a screen, or deciding between go and push.
---

# Flutter go_router routing

## Overview

**The URL is the stack.** Every screen has a location (`/orders/past/product/42`). The location of
each route in the tree decides which tab it opens in, whether the bottom bar shows, and what is
underneath it. Deep links and notifications are just locations, and **one** handler opens them all.

Follow the project's existing style: typed routes (`go_router_builder`) or plain `GoRoute`.
Code to adapt is in `reference.md`.

## Architecture

Use this layout when setting up routing. In an existing project, keep its layout, and map these roles onto it.

```
lib/
├── main.dart                         runApp(App(router: appRouter)); appController.start()
├── app/
│   ├── app.dart                      MaterialApp.router(routerConfig: router)
│   ├── di.dart                       creates the app-wide instances, once, in dependency order
│   ├── app_controller.dart           incoming locations: holds them until startup, then hands them over
│   └── router/
│       ├── app_router.dart           rootNavigatorKey, createRouter(), every import + `part` line
│       ├── app_router.g.dart         generated, git-ignored
│       ├── app_pages.dart            custom transitions (fade, slide-up), honouring reduce-motion
│       ├── navigation_handler.dart   open(location) / enterShell(from:): the only go-or-push decision
│       ├── guards/
│       │   └── auth_guard.dart       part of app_router.dart: the router's redirect
│       └── routes/                   one folder per feature, each file `part of '../../app_router.dart'`
│           ├── shell/app_shell_routes.dart        StatefulShellRoute + branch order
│           ├── home/home_routes.dart              tab branch + its root route
│           ├── orders/orders_routes.dart          tab branch with inner-tab enum route
│           ├── catalog/product_routes.dart        shared relative route (several tabs)
│           ├── checkout/checkout_routes.dart      full-screen route
│           └── auth/auth_routes.dart              login (+ signup), splash
├── features/<feature>/presentation/
│   ├── screens/<name>_screen.dart    takes IDs + callbacks, never imports routes
│   └── controllers/                  state; no navigation
└── services/
    ├── deeplink/deep_link_service.dart             link → location
    └── notifications/<x>_notification_service.dart notification → location
```

| Layer | Owns | Never does |
|---|---|---|
| Screen | UI, plus callbacks like `onOpenProduct(id)` | Import routes, or call `context.go` with a hard-coded path |
| Route (`routes/<feature>/`) | Path, parameters, navigator key, page transition, wiring callbacks to `go`/`push` | Business logic |
| `app_router.dart` | Router config: keys, `redirect`, `errorBuilder`, `initialLocation` | Know about features beyond its imports |
| `NavigationHandler` | Opening external locations: validate, check sign-in, go or push | UI |
| `AppController` | Collecting locations from links and notifications, held until startup | Navigation decisions |
| Services | Turning platform events into locations | Know about routes |

**Setup checklist:**
1. **Packages:**
   - Dependencies: `go_router`, plus `app_links` for links and the notification package.
   - Dev dependencies: `go_router_builder` and `build_runner`, for typed routes.
2. Add `*.g.dart` to `.gitignore`. Generate with `dart run build_runner build --delete-conflicting-outputs`
   (`watch` while developing).
3. Create `app_router.dart` with `part 'app_router.g.dart';` and one `part` line per route file. A new route file
   means a new `part` line, then a regenerate.
4. Put a route in the folder of the feature that owns its screen. Tab branches go in the tab's folder. Shared screens get one
   file, and the route is listed under every tab that uses it.
5. Build the singletons in `di.dart`, in this order: router → `NavigationHandler(router)` → services →
   `AppController(services, handler)`.
6. `main()`: `runApp(...)`, then `unawaited(appController.start())`. The splash calls `completeStartup()`.
7. Check `go_router`'s changelog for Material requirements. In go_router 18, if the project uses the
   `material_ui` package, import it everywhere instead of `flutter/material.dart`, or page transitions are lost.
8. Format changed files at the project's line width (check `analysis_options.yaml` or the existing code).
   Never reformat the whole repo.

## 1. Ask before building

For every screen in the request, check the table below. **If neither the request nor the codebase
answers a question, ask the user.** Ask all the open questions in one go, each with a recommended
default (use AskUserQuestion when it's available). Don't guess silently.

| Question | Why it matters |
|---|---|
| Which tab(s) does this screen belong to? | Decides where it nests, and whether it's shared across tabs |
| Bottom bar visible on it, or full screen? | Decides the navigator (`rootNavigatorKey` or the tab's) |
| From a link or notification, what is underneath it, and where does back go? | Decides nested under a tab (`go`) or top-level (`push` on top of the current screen) |
| Does it need sign-in? Which routes are public? | Decides the guard's public list |
| Inner tabs: a fixed set? What are their names? | Decides the enum values and the path regex |
| Link format: custom scheme, or https App/Universal Links? | https needs a domain and verification files |

## 2. Place the route

| Screen | Declare | Open in-app | From a link |
|---|---|---|---|
| Bottom-bar tab | A branch of a `StatefulShellRoute` | `shell.goBranch(i)` | `go` |
| Page in one tab | Nested under that tab's route | `push` or `go` | `go`: parents rebuilt underneath |
| Page in several tabs | One relative route listed under each tab | `goRelative` (typed) or `go('$current/x')` | `go` |
| Full screen, has a parent tab | Nested under the tab + `parentNavigatorKey: rootNavigatorKey` | `push` | `go`: parent underneath |
| Full screen on top of **anything** (player, call, viewer) | Top-level, `parentNavigatorKey: rootNavigatorKey` | `push` | `push` on top of the current screen |
| Login / signup / splash | Top-level | `go` | Ignored, or replaced by the guard |

## 3. go vs push

- **`go`** sets the whole stack from the URL. Use it for tab switches, inner-tab switches,
  in-tab hierarchy, after login and logout, and every link or notification into the shell.
- **`push`** stacks a page on the current one, and back returns there. Use it for root-navigator pages opened
  in-app, and for top-level routes that arrive from a link.
- **Never** `push` a location that lives inside the shell from a link. It stacks a second copy of the tab.
- **Never** `go` to a top-level overlay route from a link. It throws away everything underneath.
- The handler decides `go` or `push` from the route match itself: no `ShellRouteMatch` means outside the
  shell, so push. **Never keep a hand-written list of "independent" routes.**

## 4. Inner tabs: always an enum in the path

Whenever a screen has a fixed set of tabs (Watchlist/Favourite, Active/Past):

1. `enum OrdersTab { active, past }`. No `int` indexes, no string lists.
2. One route, `/orders/:tab(active|past)`. The regex makes an unknown tab fail to match the route,
   instead of crashing. Keep it in sync with the enum.
3. The bare path redirects to the default tab: `/orders` goes to `/orders/active`. Set the branch's `initialLocation` to match.
4. Give the page a fixed key (`ValueKey('orders')`), so switching tabs updates the page instead of pushing a new one.
5. The screen gets `tab` and `onTabChanged`. The route does `go(OrdersRoute(tab: t))`. The screen syncs its
   `TabController` in `didUpdateWidget`, so links that change the tab animate it.

## 5. Route guard (only when some routes need sign-in)

- One top-level `redirect`. **Deny by default:** list the public routes, and protect everything else.
- Signed out on a protected route → `/login?from=<encoded requested location>`.
- Signed in on `/login` → `from`, or home.
- Let the splash through untouched while the session is restoring.
- After login, navigate explicitly: `navigationHandler.enterShell(from:)`. After logout, `go(login)`.
  Don't add `refreshListenable` unless the project already uses it.

**Choosing the guard type.** Ask the user which of these apply:

| Need | Where | Rule |
|---|---|---|
| Sign-in | Top-level `redirect` | Deny by default, with a public list |
| Onboarding or first launch | Top-level `redirect`, after the sign-in check | Signed in and not onboarded → `/onboarding?from=`. Let `/onboarding` itself through. |
| Role or permission (admin, premium) | That route's `redirect` override (`GoRouteData.redirect`) | Return an "upgrade" or "not allowed" route, or home. Never return null and let the screen hide the content. |
| Leaving with unsaved changes (checkout, forms) | That route's `onExit` override | Return `true` to leave, `false` to stay. Ask with a dialog. |
| Session expired (401 from the API) | `NavigationHandler.forceSignOut()` | Sign out, then `go(LoginRoute(from: current location))` |

**Guard rules:**
- **Order:** the top-level `redirect` runs first, then the route-level ones. Every redirect must stop changing the location, or
  you hit `redirectLimit` (5 by default). Each guard lets its own target through (`/login`, `/onboarding`).
- **Keep redirects synchronous.** Read in-memory state only. Async work, such as restoring the session or fetching the profile, happens in the splash
  before the first real navigation.
- **Links obey guards.** `NavigationHandler` and the guard use the same `isPublicPath` and role checks, so a
  link can never open what a tap can't.
- **Logout clears everything.** Use `go(login)`, never `push`. It removes the shell, so every tab's back stack is disposed.
  Also reset user-scoped controllers (cart, notifications). The next user then starts clean.
- **`onExit` runs on every navigation away**: back, `go`, a link, and even `go(login)` on a forced logout.
  When the user is signed out, return `true` straight away, so a dialog can't block the logout. Save drafts
  first if losing them matters.

Code: `reference.md` → "Auth guard" and "Guards".

## 6. Deep links and notifications: one pipeline

```
DeepLinkService ─────┐
NotificationService ─┼─→ AppController ─→ NavigationHandler ─→ GoRouter
(FCM / local)        ┘   holds the location   validates, then go or push
                         until startup is done
```

1. **The payload is the app location** (`/orders/past/product/42`), never a screen name or an ID alone.
2. **Turn off Flutter's built-in deep linking** so every link goes through the handler:
   - **Android:** `<meta-data android:name="flutter_deeplinking_enabled" android:value="false"/>`.
   - **iOS:** `FlutterDeepLinkingEnabled` = `false` in `Info.plist`.
   - Use `app_links` for the launch link and the stream of later links.
3. **Cold start:** read the launch link and the launch notification (`getInitialMessage` /
   `getNotificationAppLaunchDetails`). Hold the location until the splash and session restore finish,
   then hand it over once. A location that arrives during the splash replaces the held one.
4. **`NavigationHandler.open(location)`:**
   - Parse the location, then `findMatch`. Drop error matches and auth routes.
   - Signed out and the route isn't public (use the guard's same public list) → go to `login?from=location`.
   - Outside the shell → `push`. Otherwise → `go`.
5. **`enterShell(from:)`,** used after the splash and after login:
   - Inside the shell → `go(from)`.
   - Outside the shell → `go(home)`, wait for `WidgetsBinding.instance.endOfFrame`, then `push(from)`.
     Back then returns to Home, not to an empty stack.
6. Unknown IDs in a valid route open the screen, and the screen shows "not found". Unknown routes are ignored.
   On a cold start, unknown routes open home. Set an `errorBuilder` with a "Go home" button.

## 7. Make it testable from a build

Offer a debug **Tester** screen. It should list every route grouped by tab, with parameter pickers that include an
"unknown ID" option, and show the expected result. It should send a local notification after a delay you pick
(3 s, 5 s, 10 s, 1 min, to test the app open, in the background and killed), and show the deep link with Copy and Open
buttons, plus `xcrun simctl openurl` and `adb shell am start` commands.

## 8. Verify every route opens from a deep link and a notification (required)

A route is not done until it opens from a link and from a notification. Check it in three layers.

**a. Reachable by design.** Check these for each new route:
- Everything the screen needs comes from the location: path parameters and query parameters. Nothing comes from `extra`, a previous
  screen's state, or a constructor argument that a link can't supply.
- The screen loads its own data from those IDs, and shows "not found" for an unknown ID.
- If the route's parent needs parameters, they're in the path too (`/orders/:tab/product/:productId`).
- It isn't an auth route. Those are ignored on purpose.

**b. Automated route check.** Keep one test that loops over every testable location: the Tester list, or a
`const` list of sample locations. For each one, assert three things:
- `router.configuration.findMatch(uri)` is not an error;
- it's inside or outside the shell, as expected (that's what decides go or push);
- a location with an unknown ID still matches, and only the screen shows "not found".

A new route must be added to that list. Template: `reference.md` → "Route check test".

**c. On a device.** Fill this grid for each new route, using the Tester screen or the commands in `reference.md`:

| | App open | Background | Killed |
|---|---|---|---|
| Deep link | ☐ | ☐ | ☐ |
| Notification | ☐ | ☐ | ☐ |

Also check once: signed out → login → after sign-in, the app lands on the route.

Each cell passes when:
- the right tab is selected;
- the parent screens are underneath, and back walks up through them (a top-level overlay goes back to the previous screen; after a cold start, to Home);
- the bottom bar is shown or hidden as designed;
- the data matches the link's IDs.

**Report what you verified.** Say which layers ran and which grid cells you tested. If you couldn't run on a
device, say that layer c is still to do. Don't call the route done.

## Common mistakes

| Mistake | Fix |
|---|---|
| Guessing whether a page covers the bottom bar | Ask (section 1) |
| `OrdersTabs(tab: 0)` with one route per tab | Enum + regex path + shared page key (section 4) |
| `router.push(payload)` straight from a notification | Send it through `NavigationHandler`: validate, guard, then go or push |
| Flutter deep linking left on alongside a custom handler | Turn it off, or links get handled twice and skip the checks |
| Opening a link before the router or session is ready | Hold it in `AppController` until startup completes |
| A top-level detail page reached by `go` from a link | Nest it under its tab, or push it |
| A `Set` of "push routes" | Detect them from the match (`ShellRouteMatch`) |
| `pushRelative` with go_router_builder | `goRelative`. Relative paths only resolve in `go`. |
| A guard that lists protected routes | List the public ones. New routes are protected by default. |
| Screens importing route classes | Pass IDs and callbacks. Routes build the screens. |
| A screen loading data from `extra` | Pass IDs in the path, and let the screen load its own data. `extra` is lost on links and restarts. |
| "Route added, done", after only tapping through the app | Run section 8: the route check test plus the link and notification grid |
| A premium screen that checks the role inside the screen | Route-level `redirect`, so links are blocked too |
| Onboarding redirect that also catches `/onboarding` | Each guard lets its own target through, or the redirects loop |
| `push(login)` on logout or session expiry | `go(login)`, which disposes the tab stacks |
| Testing only with the app open | The killed state takes a different code path (the launch link or notification, then the splash). Test all three states. |
