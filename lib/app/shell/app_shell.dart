import 'package:material_ui/material_ui.dart';
import 'package:go_router/go_router.dart';
import 'package:music_go_routing/app/shell/floating_nav_bar.dart';
import 'package:music_go_routing/features/player/presentation/widgets/mini_player.dart';

// Chrome shared by every tab: the branch navigators fill the screen and scroll underneath the
// floating mini player + bottom bar (extendBody). Scaffold reports their height to the body as
// MediaQuery bottom padding; lists add it so their last rows can scroll clear of the pills.
// Routes on the root navigator (player, notifications, account) cover all of it.
class AppShell extends StatelessWidget {
  const AppShell({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  static const _items = [
    FloatingNavItem(icon: Icons.home_outlined, selectedIcon: Icons.home_rounded, label: 'Home'),
    FloatingNavItem(icon: Icons.library_music_outlined, selectedIcon: Icons.library_music_rounded, label: 'Library'),
    FloatingNavItem(icon: Icons.person_outline_rounded, selectedIcon: Icons.person_rounded, label: 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    final index = navigationShell.currentIndex;
    // Android back at the root of a non-Home tab goes to Home instead of closing the app.
    // Pages pushed inside a branch still pop first.
    return PopScope(
      canPop: index == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) navigationShell.goBranch(0);
      },
      child: Scaffold(
        extendBody: true,
        body: navigationShell,
        bottomNavigationBar: SafeArea(
          top: false,
          minimum: const EdgeInsets.only(bottom: 8),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const MiniPlayer(),
                FloatingNavBar(
                  items: _items,
                  selectedIndex: index,
                  // Re-tapping the current tab pops it back to its root screen.
                  onSelected: (i) => navigationShell.goBranch(i, initialLocation: i == index),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
