# Music — go_router playground

A small music app that shows the go_router patterns a real app needs: auth redirect, a
bottom-nav shell with per-tab stacks, a persistent mini player, query-param tabs, routes that
cover the shell, and custom transitions. Typed routes (`go_router_builder`), feature-first folders.

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs   # routes -> app_router.g.dart
flutter run
flutter test                                               # navigation flows
```

Any email and a 6+ character password signs you in (in-memory, so every launch starts at login).

## Route map

```
/login                       fade in           signed-out only
└── signup
AppShellRoute (StatefulShellRoute: mini player + bottom bar, fade-through between tabs)
├── /home                    bell
│   ├── album/:albumId       in tab (bar + mini player stay)
│   ├── artist/:artistId     in tab
│   └── notifications        in tab (same screen in every tab, opened by the bell)
├── /library?tab=own|favourite   bell, TabBar driven by the query param
│   ├── playlist/:playlistId in tab
│   ├── album/:albumId       in tab (same screen, owned by the Library stack)
│   └── notifications        in tab
└── /profile                 bell
    ├── settings             in tab
    │   └── account          ROOT navigator: covers bar + mini player
    └── notifications        in tab
/player                      ROOT navigator, slides up, swipe down to close
```

## Where each pattern lives

| Pattern | Code |
|---|---|
| Route tree, auth redirect, root navigator key | `lib/app/router/app_router.dart`, `routes/` |
| Shell: mini player above the bottom bar, back-to-Home on Android | `lib/app/shell/app_shell.dart` |
| Tab-switch animation (`$navigatorContainerBuilder`) | `lib/app/shell/branch_container.dart` |
| Fade / slide-up pages | `lib/app/router/app_pages.dart` |
| Platform push transitions (Cupertino on iOS, predictive back on Android) | `lib/app/theme.dart` |
| Mini player, shared cover art hero into the full player | `lib/features/player/` |

## Rules this app follows

- **`push` to drill down, `go` to jump.** Inside a tab, details open with `push` so back returns where
  you were. `go` replaces the stack from a path: used for notification payloads, tab-query changes and
  auth. Re-tapping the active tab calls `goBranch(i, initialLocation: true)` to return to its root.
- **Hide the chrome by choosing the navigator, not with flags.** Anything nested in a branch shows the
  bar and mini player; anything with `$parentNavigatorKey = rootNavigatorKey` (account, player) covers them. The mini player only checks "is something playing".
- **Screens don't import routes.** Routes pass callbacks (`onOpenAlbum`, `onOpenSettings`), so the same
  `AlbumScreen` stacks inside Home or Library depending on who built it.
- **Auth is one redirect.** The router listens to `authController`; signing in or out never calls
  navigation directly. A signed-out deep link goes to `/login?from=...` and returns there after sign-in.
- **State in the URL survives.** `/library?tab=favourite` is kept by the branch, so leaving and
  returning to Library keeps the tab.

- **Import `material_ui`, not `flutter/material`.** go_router 18 builds pages from the `material_ui`
  package and looks for *its* `MaterialApp`. With `package:flutter/material.dart` it finds none and
  falls back to `NoTransitionPage`: every push appears instantly. The animation test guards this.

Skipped on purpose: real audio (a timer simulates playback; swap in `just_audio`), persisted login,
deep-link setup (`app_links`), state restoration.
